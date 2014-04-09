//
//  IMGClient.m
//  ImgurSession
//
//  Created by Johann Pardanaud on 29/06/13.
//  Distributed under the MIT license.
//

#import "IMGSession.h"

#import "IMGResponseSerializer.h"

@interface IMGSession ()

@property (readwrite, nonatomic,copy) NSString *clientID;
@property (readwrite, nonatomic, copy) NSString *secret;
@property (readwrite, nonatomic, copy) NSString *refreshToken;
@property (readwrite, nonatomic, copy) NSString *accessToken;
@property (readwrite, nonatomic) NSDate *accessTokenExpiry;
@property (readwrite, nonatomic) IMGAuthType lastAuthType;
@property (readwrite,nonatomic) NSInteger creditsUserRemaining;
@property (readwrite,nonatomic) NSInteger creditsUserLimit;
@property (readwrite,nonatomic) NSInteger creditsUserReset;
@property (readwrite,nonatomic) NSInteger creditsClientRemaining;
@property (readwrite,nonatomic) NSInteger creditsClientLimit;
@property  (readwrite,nonatomic) NSInteger warnRateLimit;
@property (readwrite, nonatomic) BOOL isAnonymous;

-(void)accessTokenExpired;

@end

@implementation IMGSession;

#pragma mark - Initialize

+ (instancetype)sharedInstance{
    return [self sharedInstanceWithClientID:nil secret:nil];
}


+(instancetype)sharedInstanceWithClientID:(NSString *)clientID secret:(NSString *)secret{
    
    static dispatch_once_t onceToken;
    static IMGSession *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[IMGSession alloc] initWithClientID:clientID secret:secret];
    });
    return sharedInstance;
}

- (instancetype)initWithClientID:(NSString *)clientID secret:(NSString *)secret{
    if(self = [self initWithBaseURL:[NSURL URLWithString:IMGBaseURL]]){

        if(secret){
            self.secret = secret;
            self.isAnonymous = NO;
        } else {
            //should be anonymous
            self.isAnonymous = YES;
            [self setAnonmyousAuthenticationWithID:clientID];
        }
        
        self.clientID = clientID;
        //default
        self.warnRateLimit = 100;
        self.lastAuthType = IMGNoAuthType;
        
        //to enable rate tracking
        IMGResponseSerializer * serializer = [IMGResponseSerializer serializer];
        [self setResponseSerializer:serializer];
    }
    return self;
}

#pragma mark - Authentication

-(NSString*)strForAuthType:(IMGAuthType)authType{
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

- (NSURL *)authenticateWithLink{
    return [self authenticateWithExternalURLForType:IMGPinAuth];
}

- (NSURL *)authenticateWithExternalURLForType:(IMGAuthType)authType{
    
    NSString *path = [NSString stringWithFormat:@"oauth2/authorize?response_type=%@&client_id=%@", [self strForAuthType:authType], _clientID];
    return [NSURL URLWithString:path relativeToURL:[NSURL URLWithString:IMGBaseURL]];
}

-(void)accessTokenExpired{
    //does not pro-actively refresh, just informs delegates, lazily waits until request fails to refresh
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_delegate && [_delegate respondsToSelector:@selector(imgurSessionAuthStateChanged:)])
            [_delegate imgurSessionAuthStateChanged:IMGAuthStateExpired];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:IMGAuthChangedNotification object:nil];
    });
}

-(void)refreshTokenBad{
    //refresh token is no longer working, probably banned from API
    self.refreshToken = nil;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_delegate && [_delegate respondsToSelector:@selector(imgurSessionAuthStateChanged:)])
            [_delegate imgurSessionAuthStateChanged:IMGAuthStateBad];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:IMGAuthChangedNotification object:nil];
    });
}

-(IMGAuthState)sessionAuthState{
    
    if(!self.refreshToken)
        return IMGAuthStateNone;
    else if(self.accessTokenExpiry && [self.accessTokenExpiry timeIntervalSince1970] > [[NSDate date] timeIntervalSince1970])
        return IMGAuthStateAuthenticated;
    else
        return IMGAuthStateExpired;
}

-(void)refreshAuthentication:(void (^)(NSString *))success failure:(void (^)(NSError *error))failure{
    
    NSLog(@"...attempting reauth...");
    
    if(!_refreshToken){
        //alert app that it needs to present webview or go to safari
        if(_delegate && [_delegate conformsToProtocol:@protocol(IMGSessionDelegate)]){
            
            if(failure)
                failure([NSError errorWithDomain:@"com.imgursession" code:0 userInfo:nil]);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if(_delegate && [_delegate conformsToProtocol:@protocol(IMGSessionDelegate)])
                    [_delegate imgurSessionNeedsExternalWebview:[self authenticateWithExternalURLForType:IMGPinAuth]];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:IMGNeedsExternalWebviewNotification object:nil];
            });
        } else {
            if(failure)
                failure([NSError errorWithDomain:@"com.imgursession" code:0 userInfo:nil]);
        }
    } else {
        //else get new access token with refresh token

        NSDictionary * refreshParams = @{@"refresh_token":_refreshToken, @"client_id":_clientID, @"client_secret":_secret, @"grant_type":@"refresh_token"};
        
        [super POST:IMGOAuthEndpoint parameters:refreshParams success:^(NSURLSessionDataTask *task, id responseObject) {
            
            NSDictionary * json = responseObject;
            //set auth header
            [self setAuthorizationHeader:json];
            
            NSLog(@"refreshed authentication : %@   with expiry: %@", _accessToken, [_accessTokenExpiry description]);
            
            if(_delegate && [_delegate respondsToSelector:@selector(imgurSessionTokenRefreshed)]){
                dispatch_async(dispatch_get_main_queue(), ^{
                
                    if(_delegate && [_delegate respondsToSelector:@selector(imgurSessionTokenRefreshed)])
                        [_delegate imgurSessionTokenRefreshed];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:IMGAuthRefreshedNotification object:nil];
                });
            }
            
            if(success)
                success(_refreshToken);
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
            //not working anymore
            NSHTTPURLResponse * resp = (NSHTTPURLResponse *)task.response;
            
            //in my experience, banned
            if(resp.statusCode == 400)
                [self refreshTokenBad];
            
            NSLog(@"%@", [error description]);
            if(failure)
                failure(error);
        }];
    }
}

- (void)authenticateWithType:(IMGAuthType)authType withCode:(NSString*)code success:(void (^)(NSString * refreshToken))success failure:(void (^)(NSError *error))failure{
    
    //call oauth/token with pin
    NSDictionary * pinParams = @{[self strForAuthType:authType]:code, @"client_id":_clientID, @"client_secret":_secret, @"grant_type":@"pin"};
    
    //use super to bypass tracking
    [super POST:IMGOAuthEndpoint parameters:pinParams success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //if never logged in before, alert delegate
        if(_lastAuthType == IMGNoAuthType){
            dispatch_async(dispatch_get_main_queue(), ^{
            
                if(_delegate && [_delegate respondsToSelector:@selector(imgurSessionAuthStateChanged:)])
                    [_delegate imgurSessionAuthStateChanged:IMGAuthStateAuthenticated];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:IMGAuthChangedNotification object:nil];
            });
        }
        _lastAuthType = authType;
        
        NSDictionary * json = responseObject;
        //set auth header
        [self setAuthorizationHeader:json];
        
        if(success)
            success(_refreshToken);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"%@", [error description]);
        if(failure)
            failure(error);
    }];
}

#pragma mark - Authorization header

-(void)setAnonmyousAuthenticationWithID:(NSString*)clientID{
    
    //change the serializer to include this authorization header
    AFHTTPRequestSerializer * serializer = self.requestSerializer;
    [serializer setValue:[NSString stringWithFormat:@"Client-ID %@", clientID] forHTTPHeaderField:@"Authorization"];
}

- (void)setAuthorizationHeader:(NSDictionary *)tokens{
    //store authentication from oauth/token response
    
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

#pragma mark - Rate Limit Tracking

-(void)updateClientRateLimiting:(NSHTTPURLResponse*)response{
    
    @synchronized(self){
        NSDictionary * headers = response.allHeaderFields;
        self.creditsClientRemaining = [headers[IMGHeaderClientRemaining] integerValue];
        self.creditsClientLimit = [headers[IMGHeaderClientLimit] integerValue];
        self.creditsUserLimit = [headers[IMGHeaderUserLimit] integerValue];
        self.creditsUserRemaining = [headers[IMGHeaderUserRemaining] integerValue];
        self.creditsUserReset = [headers[IMGHeaderUserReset] integerValue];
        
        //warn delegate if necessary
        if(_creditsClientRemaining < _warnRateLimit && _creditsClientRemaining > 0){
            
            dispatch_async(dispatch_get_main_queue(), ^{
            
                if(_delegate && [_delegate respondsToSelector:@selector(imgurSessionNearRateLimit:) ]){
                    [_delegate imgurSessionNearRateLimit:_creditsClientRemaining];
                }
                
                //post notifications as well
                [[NSNotificationCenter defaultCenter] postNotificationName:IMGRateLimitNearLimitNotification object:nil];
            });
        } else if (_creditsClientRemaining == 0){
            
            dispatch_async(dispatch_get_main_queue(), ^{
            
                if(_delegate && [_delegate conformsToProtocol:@protocol(IMGSessionDelegate) ]){
                    [_delegate imgurSessionRateLimitExceeded];
                }
                
                //post notifications as well
                [[NSNotificationCenter defaultCenter] postNotificationName:IMGRateLimitExceededNotification object:nil];
            });
        }
        
        NSLog(@"Remaining daily allowable client requests: %ld",(long)_creditsClientRemaining);
    }
}

#pragma mark - Requests
//needed to subclass to manage re-authentication

-(NSURLSessionDataTask *)PUT:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)( NSError *))failure{
    
    return [super PUT:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success(task,responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [self attemptRefreshWithResponse:(NSHTTPURLResponse*)task.response error:error success:^{
            //retry
            [self PUT:URLString parameters:parameters success:success failure:failure];
            
        } failure:^(NSError * error) {
            if(failure)
                failure(error);
        }];
    }];
}

-(NSURLSessionDataTask *)DELETE:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)( NSError *))failure{
    
    return [super DELETE:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success(task,responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self attemptRefreshWithResponse:(NSHTTPURLResponse*)task.response error:error success:^{
            //retry
            [self DELETE:URLString parameters:parameters success:success failure:failure];
            
        } failure:^(NSError * error) {
            if(failure)
                failure(error);
        }];
    }];
}

-(NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)( NSError *))failure{
    
    return [super POST:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success(task,responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [self attemptRefreshWithResponse:(NSHTTPURLResponse*)task.response error:error success:^{
            //retry
            [self POST:URLString parameters:parameters success:success failure:failure];
            
        } failure:^(NSError * error) {
            if(failure)
                failure(error);
        }];
    }];
}

-(NSURLSessionDataTask *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSError *))failure{
    
    return [super GET:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {

        if(success)
            success(task,responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [self attemptRefreshWithResponse:(NSHTTPURLResponse*)task.response error:error success:^{
            //retry
            [self GET:URLString parameters:parameters success:success failure:failure];
            
        } failure:^(NSError * error) {
            if(failure)
                failure(error);
        }];
    }];
}

//needed to re-implement from AFNetworking implementation without super call because progress is not handled in AFnetworking
-(NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSError *))failure{

    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters constructingBodyWithBlock:block error:nil];
    NSProgress * progress;
    
    __block NSURLSessionDataTask *task = [self uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
        [progress removeObserver:self forKeyPath:@"fractionCompleted" context:NULL];
        if (error) {
            
            [self attemptRefreshWithResponse:(NSHTTPURLResponse*)response error:error success:^{
                //retry
                [self POST:URLString parameters:parameters constructingBodyWithBlock:block success:success failure:failure];
                
            } failure:^(NSError * error) {
                if(failure)
                    failure(error);
            }];

        } else {
            if(success)
                success(task, responseObject);
        }
    }];
    
    [task resume];
    
    [progress addObserver:self
               forKeyPath:@"fractionCompleted"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    return task;
}


-(void)attemptRefreshWithResponse:(NSHTTPURLResponse*)response error:(NSError*)error success:(void (^)())success failure:(void (^)(NSError *))failure{
    
    if(response.statusCode == 403 && !self.isAnonymous){
        [self refreshAuthentication:^(NSString * refreshToken) {
            
            NSLog(@"continuing request after auth failed");
            
            //success block attempts retry
            if(success)
                success();
            
        } failure:^(NSError *error) {
            
            if(failure)
                failure(error);
            NSLog(@"failed refresh authentication : %@", [error localizedDescription]);
        }];
    } else {
        
        if(failure)
            failure(error);
        NSLog(@"failed : %@", [error localizedDescription]);
    }
}

#pragma mark - KVO for progress upload

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"fractionCompleted"]) {
        NSProgress *progress = (NSProgress *)object;
        NSLog(@"Progress… %f", progress.fractionCompleted);
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Model Tracking

-(void)trackModelObjectsForDelegateHandling:(id)model{
    
    NSLog(@"Fetched object of type: <%@>", (NSStringFromClass ([model class])));
    
    //post notifications as well to class name
    dispatch_async(dispatch_get_main_queue(), ^{
    
        //warn delegate if necessary
        if(_delegate && [_delegate respondsToSelector:@selector(imgurSessionModelFetched:)]){
                [_delegate imgurSessionModelFetched:model];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:IMGModelFetchedNotification object:model];
    });
}


@end
