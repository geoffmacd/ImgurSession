//
//  IMGResponseSerializer.m
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-07.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGResponseSerializer.h"

#import "IMGSession.h"
#import "IMGModel.h"


@implementation IMGResponseSerializer

/**
 Returns data for IMG Request classes to parse from network request. The json should be parsed from data using the JSON serializer which this class inherits from. Thus the json should be the basic model described at https://api.imgur.com/models/basic . The 'data' key is all that matters unless we have 403 or success=false. We also use this opportunity to grab the response headers and track rate limiting since this method is called for every single response.
 */
-(id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error{
    
    IMGSession * ses = [IMGSession sharedInstance];
    NSHTTPURLResponse * httpRes = (NSHTTPURLResponse *)response;
    
    //should be a json result with basic model, relevant json is the "data" key
    NSDictionary * jsonResult = [super responseObjectForResponse:response data:data error:error];
    
    if(!*error && httpRes.statusCode == 200){
        
        //let response continue processing by ImgurSession completion blocks
        if(jsonResult[@"data"]){
            
            //update rate limit tracking in the session
            [ses updateClientRateLimiting:httpRes];
            
            if([jsonResult[@"success"] boolValue]){
                //successful requests
                //pass back only "data" for simplicity
                return jsonResult[@"data"];
            } else {
                NSAssert(NO, @"Server reporting unsuccessful attempt without bad status code");
            }
        }
        
        //for login, where the basic model is not respected for some reason
        return jsonResult;
        
    } else {
        //unacceptable status code or decoding error
        
        if([httpRes statusCode] == 400){
            //request malformed
            
            if(jsonResult[@"data"][@"error"]){
                /*This error indicates that a required parameter is missing or a parameter has a value that is out of bounds or otherwise incorrect. This status code is also returned when image uploads fail due to images that are corrupt or do not meet the format requirements.*/
                
                *error = [NSError errorWithDomain:IMGErrorDomain code:400 userInfo:@{@"error":jsonResult[@"data"][@"error"]}];
            }
        } else if([httpRes statusCode] == 401){
            //session needs login for this action
            
            if(jsonResult[@"data"][@"error"]){
                
                *error = [NSError errorWithDomain:IMGErrorDomain code:IMGErrorRequiresUserAuthentication userInfo:@{@"error":jsonResult[@"data"][@"error"]}];
            }
        } else if([httpRes statusCode] == 403){
            //forbidden request, may need to refresh access token with refresh token, performed in IMGSession once before failing
            
            if(jsonResult[@"data"][@"error"]){
                
                *error = [NSError errorWithDomain:IMGErrorDomain code:403 userInfo:@{@"error":jsonResult[@"data"][@"error"]}];
            }
        } else if([httpRes statusCode] == 404){
            //not found
            
            if(jsonResult[@"data"][@"error"]){
                
                *error = [NSError errorWithDomain:IMGErrorDomain code:404 userInfo:@{@"error":jsonResult[@"data"][@"error"]}];
            }
        } else if([httpRes statusCode] == 429){
            //user rate limiting
            
            if(jsonResult[@"data"][@"error"]){
                
                *error = [NSError errorWithDomain:IMGErrorDomain code:IMGErrorUserRateLimitExceeded userInfo:@{@"error":jsonResult[@"data"][@"error"]}];
            }
        } else if([httpRes statusCode] == 500){
            //server error
            
            if(jsonResult[@"data"][@"error"]){
                
                *error = [NSError errorWithDomain:IMGErrorDomain code:500 userInfo:@{@"error":jsonResult[@"data"][@"error"]}];
            }
        }
    }
    return nil;
}
@end
