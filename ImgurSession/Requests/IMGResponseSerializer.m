//
//  IMGResponseSerializer.m
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-07.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGResponseSerializer.h"

#import "IMGSession.h"

@implementation IMGResponseSerializer

/**
 Returns data for IMG Request classes to parse from network request. The json should be parsed from data using the JSON serializer which this class inherits from. Thus the json should be the basic model described at https://api.imgur.com/models/basic . The 'data' key is all that matters unless we have 403 or success=false. We also use this opportunity to grab the response headers and track rate limiting since this method is called for every single response.
 */
-(id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error{
    
    IMGSession * ses = [IMGSession sharedInstance];
    NSHTTPURLResponse * httpRes = (NSHTTPURLResponse *)response;
    
    //should be a json result with basic model, relevant json is the "data" key
    NSDictionary * jsonResult = [super responseObjectForResponse:response data:data error:error];
    
    if(!*error){
        
        //let response continue processing by ImgurSession completion blocks
        if(jsonResult[@"data"]){
            
            //update rate limit tracking in the session
            [ses updateClientRateLimiting:httpRes];
            
            if([jsonResult[@"success"] boolValue]){
                //successful requests
                //pass back only "data" for simplicity
                return jsonResult[@"data"];
            }
        }
        
        //for login, where the basic model is not respected for some reason
        return jsonResult;
        
    } else {
        //unacceptable status code or decoding error
        
        if([httpRes statusCode] == 403){
            //forbidden request, may need to sign in with access token
            
            if(jsonResult[@"data"][@"error"]){
                
                NSLog(@"%@ for request - %@", jsonResult[@"data"][@"error"], jsonResult[@"data"][@"request"]);
                return nil;
            }
        }
    }
    
    NSLog(@"%@", [*error localizedDescription]);
    return nil;
}
@end
