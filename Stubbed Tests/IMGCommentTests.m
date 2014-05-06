//
//  IMGCommentTests.m
//  ImgurSession
//
//  Created by Xtreme Dev on 2014-03-20.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGTestCase.h"

@interface IMGCommentTests : IMGTestCase

@end


@implementation IMGCommentTests

/**
 Posts image to comment on, comments on it, replies to comment, then deletes everything
 */
- (void)testCommentSubmit{
    
    __block BOOL isSuccess;
    [self stubWithFile:@"postcomment.json"];
        
    [IMGCommentRequest submitComment:@"test comment" withImageID:@"grsgdf" success:^(NSInteger commentId) {
        
        expect(commentId).beGreaterThan(0);
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

-(void)testCommentReply{
    
    __block BOOL isSuccess;
    [self stubWithFile:@"replytocomment.json"];
    
    [IMGCommentRequest replyToComment:@"test reply" withImageID:@"sdfsdf" withParentCommentID:4354363476 success:^(NSInteger replyId) {
        
        expect(replyId).beGreaterThan(0);
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

-(void)testCommentDelete{
    
    __block BOOL isSuccess;
    [self stubWithFile:@"deletecomment.json"];
    
    [IMGCommentRequest deleteCommentWithID:25235 success:^() {
        
        isSuccess = YES;
        
    } failure:failBlock];
    
    
    expect(isSuccess).will.beTruthy();
}

-(void)testReportComment{
    
    //Not sure how to implement test of this without destroying account
}

@end
