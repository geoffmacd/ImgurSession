//
//  IMGConversation.m
//  ImgurSession
//
//  Created by Xtreme Dev on 2014-03-20.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGConversation.h"
#import "IMGMessage.h"

@implementation IMGConversation

#pragma mark - Init With Json

- (instancetype)initWithJSONObject:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error{
    
    if(self = [super init]) {
        
        _conversationID = [jsonData[@"id"] integerValue];
        _fromUsername = jsonData[@"with_account"];
        _authorId = [jsonData[@"with_account_id"] integerValue];
        _lastMessage = jsonData[@"last_message_preview"];
        _messageCount = [jsonData[@"message_count"] integerValue];
        _datetime = [NSDate dateWithTimeIntervalSince1970:[jsonData[@"datetime"] integerValue]];
        
        NSMutableArray * msgs  = [NSMutableArray new];
        for(NSDictionary * json in jsonData[@"messages"]){
            
            NSError * JSONError;
            IMGMessage * msg = [[IMGMessage alloc] initWithJSONObject:json error:&JSONError];
            
            if(msg && !JSONError){
               [msgs addObject:msg];
            }
        }
        _messages = [NSArray arrayWithArray:msgs];
    }
    return [self trackModels];
}

- (instancetype)initWithJSONObjectFromNotification:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error{
    
    if(self = [super init]) {
        
        _conversationID = [jsonData[@"id"] integerValue];
        _fromUsername = jsonData[@"from"];
        _authorId = [jsonData[@"with_account"] integerValue];
        _lastMessage = jsonData[@"last_message"];
        _messageCount = [jsonData[@"message_num"] integerValue];
        _datetime = [NSDate dateWithTimeIntervalSince1970:[jsonData[@"datetime"] integerValue]];
    }
    return [self trackModels];
}

#pragma mark - Describe

- (NSString *)description{
    return [NSString stringWithFormat:@"%@  author: \"%@\"; last message: %@; count: %lu;", [super description], self.fromUsername, self.lastMessage, self.messageCount];
}



@end
