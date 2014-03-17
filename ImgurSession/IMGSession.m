//
//  IMGClient.m
//  ImgurSession
//
//  Created by Johann Pardanaud on 29/06/13.
//  Distributed under the MIT license.
//

#import "IMGSession.h"
#import "IMGResponseSerializer.h"

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

        _clientID = clientID;
        _secret = secret;
        //default
        _warnRateLimit = 100;
        
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

-(void)refreshAuthentication:(void (^)(NSString *))success failure:(void (^)(NSError *error))failure{
    
    if(!_refreshToken){
        //alert app that it needs to present webview or go to safari
        if(_delegate && [_delegate conformsToProtocol:@protocol(IMGSessionDelegate)]){
//            dispatch_async(dispatch_get_main_queue(), ^{
                if(failure)
                    failure([NSError errorWithDomain:@"com.imgursession" code:0 userInfo:nil]);
                [_delegate imgurSessionNeedsExternalWebview:[self authenticateWithExternalURLForType:_lastAuthType]];
//            });
        } else {
            if(failure)
                failure([NSError errorWithDomain:@"com.imgursession" code:0 userInfo:nil]);
        }
    } else {
        //if access token exists and is not expired ( 1hour)
        if(_accessToken && [_accessTokenExpiry timeIntervalSinceReferenceDate] > [[NSDate date] timeIntervalSinceReferenceDate]){
            //refresh not needed
            if(success)
                success(_refreshToken);
        
        } else {
            //else get new access token with refresh token
    
            NSDictionary * refreshParams = @{@"refresh_token":_refreshToken, @"client_id":_clientID, @"client_secret":_secret, @"grant_type":@"refresh_token"};
            
            [super POST:IMGOAuthEndpoint parameters:refreshParams success:^(NSURLSessionDataTask *task, id responseObject) {
                
                NSDictionary * json = responseObject;
                _accessToken = json[@"access_token"];
                _accessTokenExpiry = [NSDate dateWithTimeIntervalSinceReferenceDate:([[NSDate date] timeIntervalSinceReferenceDate] + [json[@"expires_in"] integerValue])];
                if(success)
                    success(_refreshToken);
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                
                NSLog(@"%@", [error description]);
                if(failure)
                    failure(error);
            }];
        }
    }
}

- (void)authenticateWithType:(IMGAuthType)authType withCode:(NSString*)code success:(void (^)(NSString * refreshToken))success failure:(void (^)(NSError *error))failure{
    
    //call oauth/token with pin
    NSDictionary * pinParams = @{[self strForAuthType:authType]:code, @"client_id":_clientID, @"client_secret":_secret, @"grant_type":@"pin"};
    
    //use super to bypass tracking
    [super POST:IMGOAuthEndpoint parameters:pinParams success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary * json = responseObject;
        
        _accessToken = json[@"access_token"];
        _refreshToken = json[@"refresh_token"];
        _lastAuthType = authType;
        
        //set expiracy time, currrently at 3600 seconds after
        _accessTokenExpiry = [NSDate dateWithTimeIntervalSinceReferenceDate:([[NSDate date] timeIntervalSinceReferenceDate] + [json[@"expires_in"] integerValue])];
        //set auth header
        [self setAuthorizationHeaderWithToken:_accessToken];
        
        if(success)
            success(_refreshToken);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"%@", [error description]);
        if(failure)
            failure(error);
    }];
}

- (void)setAuthorizationHeaderWithToken:(NSString *)token{
    
    //change the serializer to include this authorization header
    AFHTTPRequestSerializer * serializer = self.requestSerializer;    
    [serializer setValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:@"Authorization"];
}

#pragma mark - Rate Limit Tracking

-(void)updateClientRateLimiting:(NSHTTPURLResponse*)response{
    
    @synchronized(self){
        NSDictionary * headers = response.allHeaderFields;
        _creditsClientRemaining = [headers[IMGHeaderClientRemaining] integerValue];
        _creditsClientLimit = [headers[IMGHeaderClientLimit] integerValue];
        _creditsUserLimit = [headers[IMGHeaderUserLimit] integerValue];
        _creditsUserRemaining = [headers[IMGHeaderUserRemaining] integerValue];
        _creditsUserReset = [headers[IMGHeaderUserReset] integerValue];
        
        
        //warn delegate if necessary
        if(_delegate && [_delegate respondsToSelector:@selector(imgurSessionNearRateLimit:) ]){
//            dispatch_async(dispatch_get_main_queue(), ^{
                if(_creditsClientRemaining < _warnRateLimit && _creditsClientRemaining > 0){
                    [_delegate imgurSessionNearRateLimit:_creditsClientRemaining];
                    
                    //post notifications as well
                    [[NSNotificationCenter defaultCenter] postNotificationName:IMGRateLimitNearLimitNotification object:nil];
                }
//            });
        }
        if(_delegate && [_delegate conformsToProtocol:@protocol(IMGSessionDelegate) ]){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (_creditsClientRemaining == 0){
                    [_delegate imgurSessionRateLimitExceeded];
                    
                    //post notifications as well
                    [[NSNotificationCenter defaultCenter] postNotificationName:IMGRateLimitExceededNotification object:nil];
                }
            });
        }
        
        NSLog(@"Remaining daily allowable client requests: %ld",(long)_creditsClientRemaining);
    }
}

#pragma mark - Requests

-(NSURLSessionDataTask *)PUT:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)( NSError *))failure{
    
    return [super PUT:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success(task,responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if(failure)
            failure(error);
        NSLog(@"failed : %@", [error localizedDescription]);
    }];
}

-(NSURLSessionDataTask *)DELETE:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)( NSError *))failure{
    
    return [super DELETE:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success(task,responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if(failure)
            failure(error);
        NSLog(@"failed : %@", [error localizedDescription]);
    }];
}

-(NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)( NSError *))failure{
    
    return [super POST:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success(task,responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if(failure)
            failure(error);
        NSLog(@"failed : %@", [error localizedDescription]);
    }];
}

-(NSURLSessionDataTask *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSError *))failure{
    
    return [super GET:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success(task,responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if(failure)
            failure(error);
        NSLog(@"failed : %@", [error localizedDescription]);
    }];
}

//needed to re-implement from AFNetworking implementation without super call because progress is not handled in AFnetworking
-(NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSError *))failure{

    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters constructingBodyWithBlock:block error:nil];
    NSProgress * progress;
    
    __block NSURLSessionDataTask *task = [self uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
        [progress removeObserver:self forKeyPath:@"fractionCompleted" context:NULL];
        if (error) {
            if (failure) {
                if(failure)
                    failure(error);
                NSLog(@"failed : %@", [error localizedDescription]);
            }
        } else {
            if (success) {
                if(success)
                    success(task, responseObject);
            }
        }
    }];
    
    [task resume];
    
    [progress addObserver:self
               forKeyPath:@"fractionCompleted"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    return task;
    
}

#pragma mark - KVO

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
    
    //warn delegate if necessary
    if(_delegate && [_delegate respondsToSelector:@selector(imgurSessionModelFetched:)]){
//        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate imgurSessionModelFetched:model];
//        });
    }
    
    //post notifications as well to class name
    [[NSNotificationCenter defaultCenter] postNotificationName:(NSStringFromClass ([model class])) object:model];
}


@end
