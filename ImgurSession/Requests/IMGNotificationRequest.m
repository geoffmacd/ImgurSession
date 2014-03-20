//
//  IMGNotificationRequest.m
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGNotificationRequest.h"
#import "IMGNotification.h"
#import "IMGSession.h"

@implementation IMGNotificationRequest

#pragma mark - Path Component for requests

+(NSString*)pathComponent{
    return @"notification";
}

#pragma mark - Load

+ (void)notifications:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    return [IMGNotificationRequest notificationsWithFresh:YES success:success failure:failure];
}

+ (void)notificationsWithFresh:(BOOL)freshOnly success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self path];
    
    [[IMGSession sharedInstance] GET:path parameters:@{@"new":[NSNumber numberWithBool:freshOnly]} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        
        NSArray * repliesJSON = responseObject[@"replies"];
        NSMutableArray * replies = [NSMutableArray new];
        for(NSDictionary * replyJSON in repliesJSON){
            NSError *JSONError = nil;
            IMGNotification * notification = [[IMGNotification alloc] initReplyNotificationWithJSONObject:replyJSON error:&JSONError];
            if(!JSONError && notification)
                [replies addObject:notification];
        }
        
        NSArray * messagesJSON = responseObject[@"messages"];
        NSMutableArray * messages = [NSMutableArray new];
        for(NSDictionary * messageJSON in messagesJSON){
            NSError *JSONError = nil;
            IMGNotification * notification = [[IMGNotification alloc] initMessageNotificationWithJSONObject:messageJSON error:&JSONError];
            if(!JSONError && notification)
                [messages addObject:notification];
        }
        
        NSMutableArray * result = [NSMutableArray arrayWithArray:messages];
        [result addObjectsFromArray:replies];
        
        if(success)
            success([NSArray arrayWithArray:result]);
        
    } failure:failure];
}

+ (void)notificationWithID:(NSString*)notificationId success:(void (^)(IMGNotification *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithId:notificationId];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSError *JSONError = nil;
        IMGNotification * notification;
        
        //is it a reply or message
        if(responseObject[@"content"][@"caption"]){
            //reply
            notification = [[IMGNotification alloc] initMessageNotificationWithJSONObject:responseObject error:&JSONError];
        } else {
            //message
            notification = [[IMGNotification alloc] initMessageNotificationWithJSONObject:responseObject error:&JSONError];
        }
        
        if(!JSONError && notification) {
            if(success)
                success(notification);
        }
        else {
            
            if(failure)
                failure(JSONError);
        }
    } failure:failure];
}


#pragma mark - Delete

+ (void)notificationViewed:(NSString *)notificationId success:(void (^)())success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithId:notificationId];
    
    //PUT or POST or DELETE
    [[IMGSession sharedInstance] DELETE:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success(nil);
        
    } failure:failure];
}
@end
