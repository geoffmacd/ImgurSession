//
//  IMGCommentTests.m
//  ImgurSession
//
//  Created by Xtreme Dev on 2014-03-20.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGIntegratedTestCase.h"

@interface IMGCommentTests : IMGIntegratedTestCase

@end


@implementation IMGCommentTests

/**
 Posts image to comment on, comments on it, replies to comment, then deletes everything
 */
#warning: may fail due to comment rate, which imgur thinks is spam
- (void)testCommentReplyAndDelete{
    
    __block BOOL deleteSuccess = NO;
    
    [self postTestImage:^(IMGImage * image, void(^success)()){
        
        [IMGCommentRequest submitComment:@"test comment" withImageID:image.imageID success:^(NSInteger commentId) {
            
            [IMGCommentRequest replyToComment:@"test reply" withImageID:image.imageID withParentCommentID:commentId success:^(NSInteger replyId) {
                
                
                [IMGCommentRequest deleteCommentWithID:replyId success:^() {
                    
                    [IMGCommentRequest deleteCommentWithID:commentId  success:^() {
                        
                        success();
                        deleteSuccess = YES;
                        
                    } failure:failBlock];
                    
                } failure:failBlock];
                
            } failure:failBlock];
            
        } failure:failBlock];
    }];
    
    expect(deleteSuccess).will.beTruthy();
}

-(void)testReportComment{
    
    //Not sure how to implement test of this without destroying account
}

@end
