//
//  IMGConversationRequest.m
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGConversationRequest.h"
#import "IMGMessage.h"
#import "IMGSession.h"

@implementation IMGConversationRequest
#pragma mark - Path

+(NSString *)pathComponent{
    return @"conversation";
}

#pragma mark - Load

+ (void)conversations:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    NSString * path = [self path];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        
        NSError *JSONError = nil;
        NSArray * messagesJSON = responseObject;
        NSMutableArray * messages = [NSMutableArray new];
        
        for(NSDictionary * msgJSON in messagesJSON){
            JSONError = nil;
            
            IMGMessage *msg = [[IMGMessage alloc] initWithJSONObject:msgJSON error:&JSONError];
            
            if(JSONError){
                
                if(failure)
                    failure(JSONError);
            } else {
                [messages addObject:msg];
            }
        }
        
        if(!JSONError) {
            if(success)
                success([NSArray arrayWithArray:messages]);
        }
        else {
            
            if(failure)
                failure(JSONError);
        }
        
    } failure:failure];
}

+ (void)conversationWithMessageID:(NSString*)messageId success:(void (^)(IMGMessage *))success failure:(void (^)(NSError *))failure{
    NSString * path = [self pathWithId:messageId];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSError *JSONError = nil;
        IMGMessage *message = [[IMGMessage alloc] initWithJSONObject:responseObject error:&JSONError];
        
        if(!JSONError) {
            if(success)
                success(message);
        }
        else {
            if(failure)
                failure(JSONError);
        }
        
    } failure:failure];
}

#pragma mark - Create


+ (void)createMessageWithRecipient:(NSString*)recipient withBody:(NSString*)body success:(void (^)())success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithId:recipient];
    NSDictionary * params = @{@"recipient":recipient,@"body":body};
    
    [[IMGSession sharedInstance] POST:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success();
        
    } failure:failure];
}

#pragma mark - Delete

+ (void)deleteConversation:(NSString *)messageId success:(void (^)())success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithId:messageId];
    
    [[IMGSession sharedInstance] DELETE:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success();
        
    } failure:failure];
}

#pragma mark - Report

+ (void)reportSender:(NSString*)username success:(void (^)())success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithOption:@"report" withId2:username];
    
    [[IMGSession sharedInstance] POST:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success();
        
    } failure:failure];
}

#pragma mark - Block

+ (void)blockSender:(NSString*)username success:(void (^)())success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithOption:@"block" withId2:username];
    
    [[IMGSession sharedInstance] POST:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success();
        
    } failure:failure];
}
@end
