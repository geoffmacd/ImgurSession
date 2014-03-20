//
//  IMGConversationTest.m
//  ImgurSession
//
//  Created by Xtreme Dev on 2014-03-20.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGTestCase.h"

@interface IMGConversationTest : IMGTestCase

@end


@implementation IMGConversationTest

-(void)testLoadConversations{
    
    __block IMGConversation * convo;
    
    [IMGConversationRequest conversations:^(NSArray * messages) {
        
        IMGConversation * first = [messages firstObject];
        
        expect(first.conversationID).beGreaterThan(0);
        expect(first.lastMessage).beTruthy();
        
        [IMGConversationRequest conversationWithMessageID:first.conversationID success:^(IMGConversation * convseration) {
            
            convo = convseration;
            
        } failure:failBlock];
        
        
    } failure:failBlock];
    
    expect(convo).will.beTruthy();
}


-(void)testSendConversatioToSelfAndDelete{
    
    __block BOOL didDelete;
    
    [IMGConversationRequest createMessageWithRecipient:@"geoffmacd" withBody:@"you must be the designer of this api" success:^{
        
        [IMGConversationRequest conversations:^(NSArray * allConvos) {
            
            [allConvos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
               
                IMGConversation * con = obj;
                
                if([con.fromUsername isEqualToString:@"geoffmacd"]){
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
