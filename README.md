# ImgurSession

__ImgurSession__ is an Objective-C networking library to easily make [Imgur](http://imgur.com) API requests within iOS and OS X apps, it is built on [AFNetworking's](http://afnetworking.com/) AFHTTPSessionManager baseclass. ImgurSession provides access for V3 of the API. It handles OAuth2 authentication for user-authenticated sessions and also supports basic authentication for anonymous sessions. It covers all documented endpoints on Imgur's [documentation](https://api.imgur.com/).

# Using

Just import ImgurSession.h and setup the session with your credentials before making any requests. 

```

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //set anonymous session if refresh token is not found otherwise use authenticated session
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"refreshToken"];
    NSString * refreshToken = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if(refreshToken){
        
        [IMGSession authenticatedSessionWithClientID:@"clientID" secret:@"secret" authType:IMGCodeAuth withDelegate:self];
    } else {
        
        [IMGSession anonymousSessionWithClientID:@"anonToken" withDelegate:self];
    }
    
    
    return YES;
}

```

Anywhere else in the app. Make requests which will use the session singleton previously created to handle authentication and error handling. For example, to retrieve the viral gallery images and albums.


```
    [IMGGalleryRequest hotGalleryPage:0 success:^(NSArray *objects) {
        
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
        //handle error
    }];

```
