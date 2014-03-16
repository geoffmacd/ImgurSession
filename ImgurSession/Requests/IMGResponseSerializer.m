//
//  IMGResponseSerializer.m
//  ImgurKit
//
//  Created by Geoff MacDonald on 2014-03-07.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGResponseSerializer.h"
#import "IMGSession.h"

@implementation IMGResponseSerializer


-(id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error{
    
    IMGSession * ses = [IMGSession sharedInstance];
    
    //should be a json result with basic model, relevant json is the "data" key
    NSDictionary * jsonResult = [super responseObjectForResponse:response data:data error:error];
    
    if(!*error){
    
        //let response continue processing by ImgurKit completion blocks
        if(jsonResult[@"data"]){
            
            //update rate limit tracking in the session
            NSHTTPURLResponse * httpRes = (NSHTTPURLResponse *)response;
            [ses updateClientRateLimiting:httpRes];
            
            //pass back only "data" for simplicity
            if(jsonResult[@"success"])
                return jsonResult[@"data"];
            else{
                NSLog(@"server error or malformed request");
                return nil;
            }
        }
        //for login, where the basic model is not respected for some reason
        return jsonResult;
    } 
    NSLog(@"%@", [*error localizedDescription]);
    return nil;
}
@end
