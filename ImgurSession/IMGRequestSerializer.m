//
//  IMGRequestSerializer.m
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-04-18.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGRequestSerializer.h"

@implementation IMGRequestSerializer

-(NSMutableURLRequest *)requestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(id)parameters error:(NSError *__autoreleasing *)error{
    
//    IMGAuthState auth = [[IMGSession sharedInstance] sessionAuthState];
//    if(auth == IMGNoAuthType || auth == IMGAuthStateExpired){
//        
//        *error = [NSError errorWithDomain:IMGErrorDomain code:IMGErrorRequiresUserAuthentication userInfo:nil];//@{IMGErrorServerPath:[URLString lastPathComponent]}];
//        return nil;
//    }
    
    return [super requestWithMethod:method URLString:URLString parameters:parameters error:error];
}

@end
