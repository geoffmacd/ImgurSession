//
//  IMGClient.m
//  ImgurSession
//
//  Created by Johann Pardanaud on 29/06/13.
//  Distributed under the MIT license.
//

#import "IMGSession.h"

#import "IMGResponseSerializer.h"
#import "IMGRequestSerializer.h"
#import "IMGAccountRequest.h"


@interface IMGSession ()

@property (readwrite, nonatomic,copy) NSString *clientID;
@property (readwrite, nonatomic, copy) NSString *secret;
@property (readwrite, nonatomic, copy) NSString *refreshToken;
@property (readwrite, nonatomic, copy) NSString *accessToken;
@property (readwrite, nonatomic, copy) NSString *codeAwaitingAuthentication;
@property (readwrite, nonatomic) NSDate *accessTokenExpiry;
@property (readwrite, nonatomic) IMGAuthType authType;
@property (readwrite,nonatomic) NSInteger creditsUserRemaining;
@property (readwrite,nonatomic) NSInteger creditsUserLimit;
@property (readwrite,nonatomic) NSInteger creditsUserReset;
@property (readwrite,nonatomic) NSInteger creditsClientRemaining;
@property (readwrite,nonatomic) NSInteger creditsClientLimit;
@property  (readwrite,nonatomic) NSInteger warnRateLimit;
@property (readwrite, nonatomic) BOOL isAnonymous;
@property (readwrite, nonatomic) IMGAccount * user;

-(void)accessTokenExpired;

@end

@implementation IMGSession;

#pragma mark - Initialize

+ (instancetype)sharedInstance{
    
    static dispatch_once_t onceToken;
    static IMGSession *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[IMGSession alloc] init];
    });
    
    return sharedInstance;
}

+(instancetype)authenticatedSessionWithClientID:(NSString *)clientID secret:(NSString *)secret authType:(IMGAuthType)authType{
    
    NSParameterAssert(clientID);
    NSParameterAssert(secret);
    
    [[IMGSession sharedInstance] resetWithClientID:clientID secret:secret authType:authType];
    
    return [self sharedInstance];
}

+(instancetype)anonymousSessionWithClientID:(NSString *)clientID{
    
    NSParameterAssert(clientID);
    
    [[IMGSession sharedInstance] resetWithClientID:clientID secret:nil authType:IMGNoAuthType];
    
    return [self sharedInstance];
}

- (instancetype)init{
    
    if(self = [self initWithBaseURL:[NSURL URLWithString:IMGBaseURL]]){

        
        //to enable rate tracking
        IMGResponseSerializer * responseSerializer = [IMGResponseSerializer serializer];
        [self setResponseSerializer:responseSerializer];
        
//        //to prevent requests with no authorization
//        IMGRequestSerializer * reqSerializer = [IMGRequestSerializer serializer];
//        [self setRequestSerializer:reqSerializer];
    }
    return self;
}

-(void)setupClientWithID:(NSString*)clientID secret:(NSString*)secret authType:(IMGAuthType)authType{
    
    //ensure stale fields are null
    self.secret = nil;
    self.accessToken = nil;
    self.refreshToken =  nil;
    self.accessTokenExpiry = nil;
    self.user = nil;
    self.codeAwaitingAuthentication = nil;
    
    if(secret){
        self.secret = secret;
        self.isAnonymous = NO;
        
        [self informClientAuthStateChanged:IMGAuthStateNone];
    } else {
        //assumed anon if no secret given
        self.isAnonymous = YES;
        authType = IMGNoAuthType;
        [self setAnonmyousAuthenticationWithID:clientID];
        
        [self informClientAuthStateChanged:IMGAuthStateAnon];
    }
    
    self.clientID = clientID;
    //default
    self.warnRateLimit = 100;
    self.authType = authType;
    
}

-(void)resetWithClientID:(NSString*)clientID secret:(NSString*)secret authType:(IMGAuthType)authType{
    
    //need at least this
    NSParameterAssert(clientID);
    
    [self setupClientWithID:clientID secret:secret authType:authType];
}

#pragma mark - Authentication Notifications

-(void)accessTokenExpired{
    
    [self refreshAuthentication:nil failure:nil];
}

-(void)badRefreshToken{
    
    //refresh token is no longer working, probably banned from API
    self.refreshToken = nil;
    
    [self informClientAuthStateChanged:IMGAuthStateBad];
}

-(IMGAuthState)sessionAuthState{
    
    if(self.isAnonymous){
        //anon clients only need the clientID to log in
        if(self.clientID.length)
            return IMGAuthStateAnon;
        else
            return IMGAuthStateMissingParameters;
    } else {
        
        if(self.accessToken.length && [self.accessTokenExpiry timeIntervalSince1970] > [[NSDate date] timeIntervalSince1970])
            return IMGAuthStateAuthenticated;                   //continue with request
        else if(self.codeAwaitingAuthentication.length)
            return IMGAuthStateAwaitingCodeInput;               //no access token, delay the request until tokens are retrieved
        else if(self.refreshToken.length)
            return IMGAuthStateExpired;                         //access token is expired, delay request until new access token retrieved
        else if(self.clientID.length && self.secret.length)
            return IMGAuthStateNone;                            //enough information to retrieve tokens, wait until tokens are retrieved
        else
            return IMGAuthStateMissingParameters;               //not enough information to login
    }
}


#pragma mark - Authentication

+(NSString*)strForAuthType:(IMGAuthType)authType{
    NSString * authStr;
    switch (authType) {
        case IMGPinAuth:
            authStr = @"pin";
            break;
        case IMGTokenAuth:
            authStr = @"token";
            break;
        case IMGCodeAuth:
            authStr = @"code";
            break;
        default:
            NSAssert(NO, @"Bad ImgurSession Authorization Type");
            break;
    }
    return authStr;
}

- (NSURL *)authenticateWithExternalURL{
    
    if(self.isAnonymous)
        return nil;
    
    NSString *path = [NSString stringWithFormat:@"%@/oauth2/authorize?response_type=%@&client_id=%@", IMGBaseURL, [IMGSession strForAuthType:self.authType], _clientID];
    return [NSURL URLWithString:path];
}

- (void)authenticateWithType:(IMGAuthType)authType withCode:(NSString*)code success:(void (^)(NSString * refreshToken))success failure:(void (^)(NSError *error))failure{
    
    //cancel all
    [self.operationQueue cancelAllOperations];
    [self.requestSerializer clearAuthorizationHeader];
    
    NSString * grantTypeStr = (authType == IMGPinAuth ? [IMGSession strForAuthType:IMGPinAuth] : @"authorization_code");
    
    //call oauth/token with auth type
    NSDictionary * params = @{[IMGSession strForAuthType:authType]:code, @"client_id":_clientID, @"client_secret":_secret, @"grant_type":grantTypeStr};
    
    //use super to bypass tracking
    [super POST:IMGOAuthEndpoint parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //alert delegate
        [self informClientAuthStateChanged:IMGAuthStateAuthenticated];
        
        NSDictionary * json = responseObject;
        //set auth header
        [self setAuthorizationHeader:json];
        //retrieve user account
        [self refreshUserAccount:nil failure:nil];
        
        if(success)
            success(self.refreshToken);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"%@", [error description]);
        if(failure)
            failure(error);
    }];
}

-(void)setAuthCode:(NSString*)code{
    
    self.codeAwaitingAuthentication = code;
}

-(void)refreshAuthentication:(void (^)(NSString *))success failure:(void (^)(NSError *error))failure{
    
    if(!self.refreshToken.length){
        //we need to retrieve refresh token with client credentials first
        
        if(!self.codeAwaitingAuthentication){
            
            [self informClientAuthStateChanged:IMGAuthStateAwaitingCodeInput];
            
            //alert app that it needs to present webview or go to safari
            dispatch_async(dispatch_get_main_queue(), ^{
                if(_delegate && [_delegate conformsToProtocol:@protocol(IMGSessionDelegate)])
                    [_delegate imgurSessionNeedsExternalWebview:[self authenticateWithExternalURL] completion:^{
                        
                        [self refreshAuthentication:^(NSString * refresh) {
                            
                            if(success)
                                success(refresh);
                            
                        } failure:failure];
                    }];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:IMGNeedsExternalWebviewNotification object:nil];
            });
        } else {
            
            //post input code to retrieve tokens asynchronously
            [self authenticateWithType:self.authType withCode:self.codeAwaitingAuthentication success:^(NSString *refreshToken){
                
                //set to nil so we don't do this again
                self.codeAwaitingAuthentication = nil;
                
                //continue with requests which were paused until this routine was finished
                if(success)
                    success(self.refreshToken);
                
            } failure:^(NSError *error) {
                //if this fails, we have no choice but to tell the user we could not authenticate with the client and secret
                
                //alert delegate
                [self badRefreshToken];
                
                if(failure)
                    failure([NSError errorWithDomain:IMGErrorDomain code:IMGErrorCouldNotAuthenticate userInfo:@{IMGErrorAuthenticationError:error}]);
            }];
        }

    } else {
        
        //refresh access token with refresh token
        NSDictionary * refreshParams = @{@"refresh_token":_refreshToken, @"client_id":_clientID, @"client_secret":_secret, @"grant_type":@"refresh_token"};
        
        [super POST:IMGOAuthEndpoint parameters:refreshParams success:^(NSURLSessionDataTask *task, id responseObject) {
            
            NSDictionary * json = responseObject;
            //set auth header
            [self setAuthorizationHeader:json];
            //immediately request latest user updates
            [self refreshUserAccount:nil failure:nil];
            
            //alert
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(_delegate && [_delegate respondsToSelector:@selector(imgurSessionTokenRefreshed)])
                    [_delegate imgurSessionTokenRefreshed];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:IMGAuthRefreshedNotification object:nil];
            });
            
            if(success)
                success(_refreshToken);
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            //in my experience, usually banned at this point, refresh codes shouldn't expire
            
            //set to nil to ensure we attempt to request new tokens
            self.refreshToken = nil;
            
            //need to ask user for a new code input
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate imgurSessionNeedsExternalWebview:[self authenticateWithExternalURL] completion:^{
                    
                    //post code and retrieve newstokens
                    [self refreshAuthentication:^(NSString * refresh) {
                        
                        if(success)
                            success(refresh);
                        
                    } failure:failure]; //failure will generate IMGErrorCouldNotAuthenticate error code as per above
                }];
            });
        }];
    }
}

-(void)authenticateWithRefreshToken:(NSString*)refreshToken{
    
    self.refreshToken = refreshToken;
    
    [self refreshAuthentication:nil failure:nil];
}

-(void)informClientAuthStateChanged:(IMGAuthState)authState{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_delegate && [_delegate respondsToSelector:@selector(imgurSessionAuthStateChanged:)])
            [_delegate imgurSessionAuthStateChanged:authState];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:IMGAuthChangedNotification object:[NSNumber numberWithInt:authState]];
    });
}

#pragma mark - Authorized User Account

-(void)refreshUserAccount:(void (^)(IMGAccount * user))success failure:(void (^)(NSError * err))failure{
    
    [IMGAccountRequest accountWithUser:@"me" success:^(IMGAccount *account) {
        
        //set need user
        self.user = account;
        
        if(success)
            success(account);
        
    } failure:failure];
}


#pragma mark - Authorization header

-(void)setAnonmyousAuthenticationWithID:(NSString*)clientID{
    
    //suspend until complete
    [self.operationQueue setSuspended:YES];
    
    //change the serializer to include this authorization header
    AFHTTPRequestSerializer * serializer = self.requestSerializer;
    [serializer setValue:[NSString stringWithFormat:@"Client-ID %@", clientID] forHTTPHeaderField:@"Authorization"];
    
    [self.operationQueue setSuspended:NO];
}

- (void)setAuthorizationHeader:(NSDictionary *)tokens{
    //store authentication from oauth/token response and set metadata
    
    //suspend until complete
    [self.operationQueue setSuspended:YES];
    
    @synchronized(self){
        //refresh token
        if(tokens[@"refresh_token"]){
            self.refreshToken = tokens[@"refresh_token"];
        }
        
        //set expiracy time, currrently at 3600 seconds after
        NSInteger expirySeconds = [tokens[@"expires_in"] integerValue];
        self.accessTokenExpiry = [NSDate dateWithTimeIntervalSinceReferenceDate:([[NSDate date] timeIntervalSinceReferenceDate] + expirySeconds)];
        NSTimer * timer = [NSTimer timerWithTimeInterval:expirySeconds target:self selector:@selector(accessTokenExpired) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        self.accessToken = tokens[@"access_token"];
        
        //change the serializer to include this authorization header
        AFHTTPRequestSerializer * serializer = self.requestSerializer;
        [serializer setValue:[NSString stringWithFormat:@"Bearer %@", tokens[@"access_token"]] forHTTPHeaderField:@"Authorization"];
    }
    
    [self.operationQueue setSuspended:NO];
}

#pragma mark - Rate Limit Tracking

-(void)updateClientRateLimiting:(NSHTTPURLResponse*)response{
    
    NSDictionary * headers = response.allHeaderFields;
    //sometimes the headers aren't there and 0 is the result which will wrongly trigger ratelimitexceeded
    if(headers[IMGHeaderClientRemaining])
        self.creditsClientRemaining = [headers[IMGHeaderClientRemaining] integerValue];
    if(headers[IMGHeaderClientLimit])
        self.creditsClientLimit = [headers[IMGHeaderClientLimit] integerValue];
    if(headers[IMGHeaderUserLimit])
        self.creditsUserLimit = [headers[IMGHeaderUserLimit] integerValue];
    if(headers[IMGHeaderUserRemaining])
        self.creditsUserRemaining = [headers[IMGHeaderUserRemaining] integerValue];
    if(headers[IMGHeaderUserReset])
        self.creditsUserReset = [headers[IMGHeaderUserReset] integerValue];
    
    //warn delegate if necessary
    if(_creditsUserRemaining < _warnRateLimit && _creditsUserRemaining > 0){
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            if(_delegate && [_delegate respondsToSelector:@selector(imgurSessionNearRateLimit:) ]){
                [_delegate imgurSessionNearRateLimit:_creditsUserRemaining];
            }
            
            //post notifications as well
            [[NSNotificationCenter defaultCenter] postNotificationName:IMGRateLimitNearLimitNotification object:nil];
        });
    } else if (_creditsUserRemaining == 0){
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            if(_delegate && [_delegate conformsToProtocol:@protocol(IMGSessionDelegate) ]){
                [_delegate imgurSessionRateLimitExceeded];
            }
            
            //post notifications as well
            [[NSNotificationCenter defaultCenter] postNotificationName:IMGRateLimitExceededNotification object:nil];
        });
    }
}

#pragma mark - Request authorization management

//needed to subclass to manage authentication state

-(NSURLSessionDataTask *)methodRequest:(NSString *)URLString parameters:(NSDictionary *)parameters completion:(NSURLSessionDataTask * (^)())completion success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)( NSError *))failure{
    
    IMGAuthState auth = [self sessionAuthState];
    if(auth == IMGAuthStateMissingParameters){
        if(failure)
            failure([NSError errorWithDomain:IMGErrorDomain code:IMGErrorMissingClientAuthentication userInfo:nil]);
        
        return nil;
    } else if (auth == IMGAuthStateExpired || auth == IMGAuthStateNone || auth == IMGAuthStateAwaitingCodeInput){
        
        //refresh or ask delegate for external webview to login for first time
        [self refreshAuthentication:^(NSString * refreshToken) {
            
            completion();
            
        } failure:^(NSError *error) {
            
            //inform of either refresh failure or delegate needs to login
            if(error.code == IMGErrorCouldNotAuthenticate){
                if(failure)
                    failure(error);
            }
        }];
        return nil;
    } else {
        //continue with request
        return completion();
    }
    
}

-(BOOL)canRequestFailureBeRecovered:(NSError*)error{

    if(self.isAnonymous){
        //if anon, nothing we can do but tell the user
        return NO;
    } else {
        //if authenticated, attempt refresh or worst case code input in case of 401 and 403
        
        return (error.code == IMGErrorForbidden || error.code == IMGErrorRequiresUserAuthentication);
    }
}

#pragma mark - Requests

-(NSURLSessionDataTask *)PUT:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)( NSError *))failure{
    
    
    return [self methodRequest:URLString parameters:parameters completion:^{
        
        return [super PUT:URLString parameters:parameters success:success failure:^(NSURLSessionDataTask *task, NSError *error) {
            
            if([self canRequestFailureBeRecovered:error]){
                
                [self refreshAuthentication:^(NSString * accessCode) {
                    
                    [super PUT:URLString parameters:parameters success:success failure:^(NSURLSessionDataTask *task, NSError *error){
                        
                        if(failure)
                            failure(error);
                    }];
                } failure:^(NSError *error) {
                    
                    if(failure)
                        failure(error);
                }];
                
            } else {
                
                if(failure)
                    failure(error);
            }
        }];
        
    } success:success failure:failure];
}

-(NSURLSessionDataTask *)DELETE:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)( NSError *))failure{
    
    return [self methodRequest:URLString parameters:parameters completion:^{
        
        return [super DELETE:URLString parameters:parameters success:success failure:^(NSURLSessionDataTask *task, NSError *error) {
            
            if([self canRequestFailureBeRecovered:error]){
                
                [self refreshAuthentication:^(NSString * accessCode) {
                    
                    [super DELETE:URLString parameters:parameters success:success failure:^(NSURLSessionDataTask *task, NSError *error){
                        
                        if(failure)
                            failure(error);
                    }];
                } failure:^(NSError *error) {
                    
                    if(failure)
                        failure(error);
                }];
                
            } else {
                
                if(failure)
                    failure(error);
            }

        }];
        
    } success:success failure:failure];
}

-(NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)( NSError *))failure{
    
    return [self methodRequest:URLString parameters:parameters completion:^{
        
        return [super POST:URLString parameters:parameters success:success failure:^(NSURLSessionDataTask *task, NSError *error) {
            
            if([self canRequestFailureBeRecovered:error]){
                
                
                [self refreshAuthentication:^(NSString * accessCode) {
                    
                    [super POST:URLString parameters:parameters success:success failure:^(NSURLSessionDataTask *task, NSError *error) {
                        
                        if(failure)
                            failure(error);
                    }];
                } failure:^(NSError *error) {
                    
                    if(failure)
                        failure(error);
                }];
                
            } else {
                
                if(failure)
                    failure(error);
            }
        }];
        
    } success:success failure:failure];
}


-(NSURLSessionDataTask *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSError *))failure{
    
    return [self methodRequest:URLString parameters:parameters completion:^{
        
        return [super GET:URLString parameters:parameters success:success failure:^(NSURLSessionDataTask *task, NSError *error) {
            
            if([self canRequestFailureBeRecovered:error]){
                
                [self refreshAuthentication:^(NSString * accessCode) {
                    
                    [super GET:URLString parameters:parameters success:success failure:^(NSURLSessionDataTask *task, NSError *error) {
                        
                        if(failure)
                            failure(error);
                    }];
                } failure:^(NSError *error) {
                    
                    if(failure)
                        failure(error);
                }];
                
            } else {
            
                if(failure)
                    failure(error);
            }
        }];
        
    } success:success failure:failure];
}

//needed to re-implement from AFNetworking implementation without super call because progress is not handled in AFnetworking
-(NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block success:(void (^)(NSURLSessionDataTask *, id))success progress:(void (^)(CGFloat progress))progressHandler failure:(void (^)(NSError *))failure{
    
    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters constructingBodyWithBlock:block error:nil];
    
    NSProgress * progress;
    __block NSURLSessionDataTask *task = [self uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
        [progress removeObserver:self forKeyPath:@"fractionCompleted" context:NULL];
        if (error) {
            
            if(failure)
                failure(error);
            
        } else {
            if(success)
                success(task, responseObject);
        }
    }];
    
    [task resume];
    
    [progress addObserver:self
               forKeyPath:@"fractionCompleted"
                  options:NSKeyValueObservingOptionNew
                  context:(__bridge void *)(progressHandler)];
    return task;
}


#pragma mark - KVO for progress upload

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"fractionCompleted"]) {
        //we were tracking image upload progress probably
        NSProgress *progress = (NSProgress *)object;
        
        //the progress handler was passed to context, type cast back to pass in float to alert requester of progress
        void (^handler)(CGFloat progress) = (__bridge void (^)(CGFloat progress))context;
        handler(progress.fractionCompleted);
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Model Tracking

-(void)trackModelObjectsForDelegateHandling:(id)model{
    
    //post notifications as well to class name
    dispatch_async(dispatch_get_main_queue(), ^{
    
        //tell delegate if necessary
        if(_delegate && [_delegate respondsToSelector:@selector(imgurSessionModelFetched:)]){
                [_delegate imgurSessionModelFetched:model];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:IMGModelFetchedNotification object:model];
    });
}


@end
