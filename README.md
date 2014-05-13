# ImgurSession

__ImgurSession__ is an Objective-C networking library to easily make [Imgur](http://imgur.com) API requests within iOS and OS X apps. It is built on [AFNetworking's](http://afnetworking.com/) AFHTTPSessionManager baseclass. ImgurSession provides access for V3 of the API. It handles OAuth2 authentication for user-authenticated sessions and also supports basic authentication for anonymous sessions. It covers all documented endpoints on Imgur's [documentation](https://api.imgur.com/).

### Imgur API Support - V3

- `IMGGalleryRequest - Viral, User Submitted, top voted and configurable gallery lists`
- `IMGAccountRequest - Account retrieval and modification, account images, albums, submissions and favourites`
- `IMGConversationRequest - Conversations with other users`
- `IMGNotificationRequest - Notifications. Automatically configured to retrieve every 30 seconds.`
- `IMGImageRequest,IMGAlbumRequest - CRUD actions with iamges and albums`
- `IMGCommentRequest -  Post comments on images in the gallery`

# Using

Just import ImgurSession.h and setup the session with your credentials before making any requests. Two delegate methods are required,

```

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
     [IMGSession authenticatedSessionWithClientID:@"clientID" secret:@"secret" authType:IMGCodeAuth withDelegate:self];
    
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{


     //call completion with retrieved code from URL

}

#pragma mark - IMGSessionDelegate

-(void)imgurSessionNeedsExternalWebview:(NSURL *)url completion:(void (^)())completion{
    
    //save the completion block for later use when URL is opened above
    
    //open imgur website to authenticate with callback url
    [[UIApplication sharedApplication] openURL:url];
}

-(void)imgurSessionRateLimitExceeded{
     ...alert your view controllers...
}

```

Or anonymous session (as configured by registered app on Imgur).

```
[IMGSession anonymousSessionWithClientID:@"anonToken" withDelegate:self];
```

Anywhere else in the app, make requests which will use the session singleton previously created to handle authentication and error handling. To retrieve the viral gallery:


```
    [IMGGalleryRequest hotGalleryPage:0 success:^(NSArray *objects) {
        
          .....
        
    } failure:^(NSError *error) {
        
        //handle error
    }];

```
