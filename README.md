# ImgurSession

__ImgurSession__ is an Objective-C networking library to easily make [Imgur](http://imgur.com) API requests within iOS and OS X apps, it is built on [AFNetworking's](http://afnetworking.com/) AFHTTPSessionManager baseclass. ImgurSession provides access for V3 of the API. It handles OAuth2 authentication for user-authenticated sessions and also supports basic authentication for anonymous sessions. It covers all documented endpoints on Imgur's [documentation](https://api.imgur.com/).

# Using

Just import ImgurSession.h and setup the session with your credentials before making any requests. A delegate is required for launching external webviews.

```

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
     [IMGSession authenticatedSessionWithClientID:@"clientID" secret:@"secret" authType:IMGCodeAuth withDelegate:self];
    
    return YES;
}

#pragma mark - IMGSessionDelegate

-(void)imgurSessionNeedsExternalWebview:(NSURL *)url completion:(void (^)())completion{
    
    NSLog(@"need webview");
    
    self.loginCompletion = completion;
    
    [[UIApplication sharedApplication] openURL:url];
}

```

Or anonymous session (as configured by registered app on Imgur).

```
[IMGSession anonymousSessionWithClientID:@"anonToken" withDelegate:self];
```

Anywhere else in the app. Make requests which will use the session singleton previously created to handle authentication and error handling. For example, to retrieve the viral gallery images and albums.


```
    [IMGGalleryRequest hotGalleryPage:0 success:^(NSArray *objects) {
        
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
        //handle error
    }];

```
