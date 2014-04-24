//
//  IMGClient.h
//  ImgurSession
//
//  Geoff MacDonald - Pivotal Labs
//  Distributed under the MIT license.
//

#import "IMGAccount.h"

//endpoints
static NSString * const IMGBaseURL = @"https://api.imgur.com";
static NSString * const IMGAPIVersion = @"3";
static NSString * const IMGOAuthEndpoint = @"oauth2/token";

//rate limit header names
static NSString * const IMGHeaderUserLimit = @"X-RateLimit-UserLimit";
static NSString * const IMGHeaderUserRemaining = @"X-RateLimit-UserRemaining";
static NSString * const IMGHeaderUserReset = @"X-RateLimit-UserReset";
static NSString * const IMGHeaderClientLimit = @"X-RateLimit-ClientLimit";
static NSString * const IMGHeaderClientRemaining = @"X-RateLimit-ClientRemaining";

//notification names
static NSString * const IMGRateLimitExceededNotification = @"IMGRateLimitExceededNotification";
static NSString * const IMGRateLimitNearLimitNotification = @"IMGRateLimitNearLimitNotification";
static NSString * const IMGNeedsExternalWebviewNotification = @"IMGNeedsExternalWebviewNotification";
static NSString * const IMGModelFetchedNotification = @"IMGModelFetchedNotification";
static NSString * const IMGAuthChangedNotification = @"IMGAuthChangedNotification";
static NSString * const IMGAuthRefreshedNotification = @"IMGAuthRefreshedNotification";
static NSString * const IMGRefreshedUser = @"IMGRefreshedUser";
static NSString * const IMGRefreshedNotifications = @"IMGRefreshedNotifications";

/**
 Type of authorization to use, you will probably use PIN. See https://api.imgur.com/oauth2
 */
typedef NS_ENUM(NSInteger, IMGAuthType){
    IMGNoAuthType,
    IMGPinAuth,
    IMGTokenAuth,
    IMGCodeAuth
};

/**
 State of authentication
 */
typedef NS_ENUM(NSInteger, IMGAuthState){
    IMGAuthStateMissingParameters = 0,
    IMGAuthStateBad = 0,
    IMGAuthStateNone,
    IMGAuthStateAuthenticated,
    IMGAuthStateAnon,
    IMGAuthStateExpired,
    IMGAuthStateAwaitingCodeInput
};


/**
 Protocol to be alerted of ImgurSession notifcations. Called on main thread.
 */
@protocol IMGSessionDelegate <NSObject>

@required

/**
 Alerts delegate that request limit is hit and cannot continue
 */
-(void)imgurSessionRateLimitExceeded;
/**
 Alerts delegate that webview is needed to present Imgur OAuth authentication. Call completion upon authenticating with asyncAuthenticateWithType when you want to ensure previous requests do not fail, as this method was called lazily by the session.
 */
-(void)imgurSessionNeedsExternalWebview:(NSURL*)url completion:(void(^)())completion;

@optional

/**
 Alerts delegate that request limit is being approached
 */
-(void)imgurSessionNearRateLimit:(NSInteger)remainingRequests;
/**
 Informs delegate of new model objects being created
 @param model Model object that was created
 */
-(void)imgurSessionModelFetched:(id)model;
/**
 Informs delegate of new access token refreshs
 */
-(void)imgurSessionTokenRefreshed;
/**
 Informs delegate of new authentication success
 @param state authentication state of the session. You can call sessionAuthState anytime for this value.
 */
-(void)imgurSessionAuthStateChanged:(IMGAuthState)state;
/**
 Informs delegate of user refreshes
 */
-(void)imgurSessionUserRefreshed:(IMGAccount*)user;
/**
 Informs delegate of fresh notifications
 */
-(void)imgurSessionNewNotifications:(NSArray*)freshNotifications;


@end


/**
 Session manager class for ImgurSession Session instance. Controls all requests by subclassing AFHTTPSessionManager
 */
@interface IMGSession : AFHTTPSessionManager


// client authorization

/**
 App Id as registered with Imgur at http://imgur.com/account/settings/apps
 */
@property (readonly, nonatomic,copy) NSString *clientID;
/**
 App Secret as registered with Imgur at http://imgur.com/account/settings/apps
 */
@property (readonly, nonatomic, copy) NSString *secret;
/**
 Refresh token as retrieved from oauth/token GET request. Subsequent requests invalidate previous refresh tokens.
 */
@property (readonly, nonatomic, copy) NSString *refreshToken;
/**
 Access token as retrieved from oauth/token GET request with PIN. Expires after 1 hour after retrieval as in the 'expires_in' header
 */
@property (readonly, nonatomic, copy) NSString *accessToken;
/**
 Code retrieved from imgur by using external URL for authentication. Set via setAuthCode to input code from web service.
 */
@property (readonly, nonatomic, copy) NSString * codeAwaitingAuthentication;
/**
 Access token expiry date
 */
@property (readonly, nonatomic) NSDate *accessTokenExpiry;
/**
 Type of authentication intended, IMGNoAuthType if anon
 */
@property (readonly, nonatomic) IMGAuthType authType;
/**
 Is current session anonymous?
 */
@property (readonly, nonatomic) BOOL isAnonymous;
/**
 User Account if logged in
 */
@property (readonly, nonatomic) IMGAccount * user;
/**
 Time period when notification updates are requested to see if user has new updates. Set to 0 to disable. 30 seconds by default. Only for authroized Sessions.
 */
@property  (readwrite,nonatomic) NSInteger notificationRefreshPeriod;

// rate limiting

/**
 Requests current user has remaining
 */
@property (readonly,nonatomic) NSInteger creditsUserRemaining;
/**
 Daily limit on user requests
 */
@property (readonly,nonatomic) NSInteger creditsUserLimit;
/**
 unix epoch date when user credits are reset
 */
@property (readonly,nonatomic) NSInteger creditsUserReset;
/**
 Requests app has remaining
 */
@property (readonly,nonatomic) NSInteger creditsClientRemaining;
/**
 Daily limit for the app
 */
@property (readonly,nonatomic) NSInteger creditsClientLimit;
/**
 Warn client after going below this number of available requests. The default is 100 requests.
 */
@property  (readonly,nonatomic) NSInteger warnRateLimit;

/**
 Required delegate to warn of imgur events.
 */
@property (weak) id<IMGSessionDelegate> delegate;


#pragma mark - Initialize

/**
 Returns shared instance, or else creates one with nil authentication params.
 @return Session manager
 */
+ (instancetype)sharedInstance;
/**
 Returns authenticated session with these parameters
 @param clientID    client Id string as registered with Imgur
 @param secret      secret string as registered with Imgur
 @param authType    type of authorization - code, pin or token
 @return            Session manager for interacting with Imgur account
 */
+(instancetype)authenticatedSessionWithClientID:(NSString *)clientID secret:(NSString *)secret authType:(IMGAuthType)authType;
/**
 Returns anonymous session with client ID
 @param clientID    client Id string as registered with Imgur
 @return            Session manager for interacting with Imgur anonymously
 */
+(instancetype)anonymousSessionWithClientID:(NSString *)clientID;    
/**
 Reset the session with these manual parameters. Leave secret nil and authType IMGNoAuthType for anonymous session configuraton.
 @param clientID    client Id string as registered with Imgur
 @param secret      secret string as registered with Imgur
 @param authType    type of auth for session
 */
-(void)resetWithClientID:(NSString*)clientID secret:(NSString*)secret authType:(IMGAuthType)authType;

#pragma mark - Authentication

/**
 Returns status of session authentication. Based on token expiry, not gauranteed to work live.
 @return    IMGAuthState state of current session
 */
-(IMGAuthState)sessionAuthState;
/**
 Retrieves URL associated with website authorization page for session authentication type
 @return    authorization URL to open in Webview or Safari
 */
- (NSURL *)authenticateWithExternalURL;
/**
 Asynchronously requests refresh tokens using inputted pin code.
 @param authType     authorization type pin,code,token
 @param code     code input string for authorization
 */
- (void)authenticateWithType:(IMGAuthType)authType withCode:(NSString*)code success:(void (^)(NSString * refreshToken))success failure:(void (^)(NSError *error))failure;
/**
 Sets the session input code retrieved by the OAuth service upon allowing the application permission via external web service. This code will be used the next time a request is made to acquire a new refresh token
 @param code input code to be submitted to OAuth to retrieve refresh token with
 */
-(void)setAuthCode:(NSString*)code;
/**
 Manually authenticate directly from refresh token bypassing code input. Note that code input from oath/token will invalidate previous refresh tokens.
 @param refreshToken     valid refresh token to manually set
 */
-(void)authenticateWithRefreshToken:(NSString*)refreshToken;
/**
 String constant for auth type
 */
+(NSString*)strForAuthType:(IMGAuthType)authType;


#pragma mark - Authorized User Account

/**
 Requests the logged-in user's account.
 @param success completion block invoked on successful account retrieval
 @param failure block invoked on failed request
 */
-(void)refreshUserAccount:(void (^)(IMGAccount * user))success failure:(void (^)(NSError * err))failure;

#pragma mark - Requests

-(NSURLSessionDataTask *)PUT:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)( NSError *))failure;

-(NSURLSessionDataTask *)DELETE:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)( NSError *))failure;

-(NSURLSessionDataTask *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSError *))failure;

-(NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)( NSError *))failure;

/**
 Post request with body completion block. Needed to re-implement from AFNetworking implementation without super call because progress is not handled in AFnetworking
 */
-(NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block success:(void (^)(NSURLSessionDataTask *, id))success progress:(void (^)(CGFloat progress))progressHandler failure:(void (^)(NSError *))failure;


#pragma mark - Rate Limit Tracking

/**
 Tracks rate limiting using HTTP headers from the response
 @param response HTTP response returned from Imgur call
 */
-(void)updateClientRateLimiting:(NSHTTPURLResponse*)response;

#pragma mark - Model Tracking

/**
 Tracks new imgur Model objects being created to allow introspection by client
 @param model the model object that was created
 */
-(void)trackModelObjectsForDelegateHandling:(id)model;


@end
