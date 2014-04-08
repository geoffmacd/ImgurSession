//
//  IMGMessage.m
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGMessage.h"

@implementation IMGMessage

#pragma mark - Init With Json

- (instancetype)initWithJSONObject:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error{
    
    if(self = [super init]) {
        
        _messageID = jsonData[@"id"];
        _fromUsername = jsonData[@"from"];
        _authorID = [jsonData[@"sender_id"] integerValue];
        _subject = jsonData[@"subject"];
        _body = jsonData[@"body"];
        _datetime = [NSDate dateWithTimeIntervalSince1970:[jsonData[@"datetime"] integerValue]];
        _conversationID = [jsonData[@"conversation_id"] integerValue];
    }
    return [self trackModels];
}

#pragma mark - Describe

- (NSString *)description{
    return [NSString stringWithFormat:@"%@ ; subject: \"%@\"; author: \"%@\"; message: %@;", [super description], self.subject, self.fromUsername, self.body];
}

-(BOOL)isEqual:(id)object{
    
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[IMGMessage class]]) {
        return NO;
    }
    
    return ([[object messageID] isEqualToString:self.messageID]);
}

@end
