//
//  IMGConversationTest.m
//  ImgurSession
//
//  Created by Xtreme Dev on 2014-03-20.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGIntegratedTestCase.h"

@interface IMGConversationTest : IMGIntegratedTestCase

@end


@implementation IMGConversationTest

-(void)testLoadConversations{
    
    __block BOOL isSuccess;
    
    [IMGConversationRequest conversations:^(NSArray * messages) {
        
        IMGConversation * first = [messages firstObject];
        
        if(first){
            expect(first.conversationID).beGreaterThan(0);
            expect(first.lastMessage).beTruthy();
            
            [IMGConversationRequest conversationWithMessageID:first.conversationID success:^(IMGConversation * convseration) {
                
                isSuccess = YES;
                
            } failure:failBlock];
        } else {
            
            isSuccess = YES;
        }
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}


-(void)testSendConversatioToSelfAndDelete{
    
    __block BOOL didDelete;
    
    [IMGConversationRequest createMessageWithRecipient:imgurUnitTestParams[@"recipientId"] withBody:@"you must be the designer of this api" success:^{
        
        [IMGConversationRequest conversations:^(NSArray * allConvos) {
            
            [allConvos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
               
                IMGConversation * con = obj;
                
                if([con.fromUsername isEqualToString:@"Ravener"]){
                    *stop = YES;
                    
                    [IMGConversationRequest deleteConversation:con.conversationID success:^{
                        
                        didDelete = YES;
                        
                    } failure:failBlock];
                }
            }];
            
        } failure:failBlock];

    } failure:failBlock];
    
    expect(didDelete).will.beTruthy();
}


-(void)testBlockSender{
    
    //can't figure out how to test this
}

-(void)testReportSender{
    
    //can't figure out how to test this
}

@end
