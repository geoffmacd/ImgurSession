//
//  IMGModel.m
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGModel.h"

#import "IMGSession.h"


@implementation IMGModel

- (instancetype)initWithJSONObject:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error{
    NSAssert(NO, @"Should be overridden by subclass");
    return nil;
}

-(instancetype)trackModels{
    
    //track if object is not nil
    if(self)
        [[IMGSession sharedInstance] trackModelObjectsForDelegateHandling:self];
    
    return self;
}

@end
