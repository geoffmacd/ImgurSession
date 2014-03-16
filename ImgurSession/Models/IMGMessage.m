//
//  IMGMessage.m
//  ImgurKit
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGMessage.h"

@implementation IMGMessage

#pragma mark - Init With Json

- (instancetype)initWithJSONObject:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error{
    
    if(self = [super init]) {
        
        _messageId = jsonData[@"id"];
        _fromUsername = jsonData[@"from"];
        _authorId = [jsonData[@"account_id"] integerValue];
        _recipientId = [jsonData[@"recipient_account_id"] integerValue];
        _subject = jsonData[@"subject"];
        _body = jsonData[@"body"];
        _timeMessage = jsonData[@"timestamp"];
        _parentId = [jsonData[@"parent_id"] integerValue];
    }
    return [self trackModels];
}

#pragma mark - Describe

- (NSString *)description{
    return [NSString stringWithFormat:@"%@ ; subject: \"%@\"; author: \"%@\"; message: %@;", [super description], _subject, _fromUsername, _body];
}



@end
