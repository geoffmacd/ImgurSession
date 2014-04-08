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
    
    __block BOOL isSuccess;
    [self stubWithFile:@"conversations.json"];
    
    [IMGConversationRequest conversations:^(NSArray * messages) {
        
        expect(messages).haveCountOf(1);
        expect([messages firstObject]).beInstanceOf([IMGConversation class]);
        IMGConversation * first = [messages firstObject];
        expect(first.lastMessage).beTruthy();
        expect(first.conversationID).beTruthy();
        
        IMGConversation * copy = [first copy];
        expect(first.lastMessage).equal(copy.lastMessage);
        expect(first.conversationID == copy.conversationID).beTruthy();
        expect(first.authorID == copy.authorID).beTruthy();
        expect(first.messages == copy.messages).beTruthy();
        
        NSData * data = [NSKeyedArchiver archivedDataWithRootObject:copy];
        copy = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        expect(first.lastMessage).equal(copy.lastMessage);
        expect(first.conversationID == copy.conversationID).beTruthy();
        expect(first.authorID == copy.authorID).beTruthy();
        expect(first.messages == copy.messages).beTruthy();
        expect(copy).equal(first);
        
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

-(void)testLoadConversationWithID{
    
    __block BOOL isSuccess;
    [self stubWithFile:@"conversationwithid.json"];
    
    [IMGConversationRequest conversationWithMessageID:346346 success:^(IMGConversation * conversation) {
        
        expect(conversation.lastMessage).beTruthy();
        expect(conversation.conversationID).beTruthy();
        expect(conversation.messageCount).beTruthy();
        
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}


-(void)testSendConversation{
    
    __block BOOL isSuccess;
    [self stubWithFile:@"conversationpost.json"];
    
    [IMGConversationRequest createMessageWithRecipient:imgurUnitTestParams[@"recipientId"] withBody:@"you must be the designer of this api" success:^{
        
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

-(void)testDeleteConvo{
    
    __block BOOL isSuccess;
    [self stubWithFile:@"conversationdelete.json"];
    
    [IMGConversationRequest deleteConversation:634436 success:^{
        
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}


-(void)testBlockSender{
    
    //can't figure out how to test this
}

-(void)testReportSender{
    
    //can't figure out how to test this
}

@end
