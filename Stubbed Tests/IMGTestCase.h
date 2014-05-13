//
//  IMGTestCase.h
//  ImgurSession
//
//  Created by Xtreme Dev on 2014-03-18.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ImgurSession.h"

#define EXP_SHORTHAND YES
#import "Expecta.h"
#import "OCMock.h"
#import <OHHTTPStubs.h>

@interface IMGTestCase : XCTestCase <IMGSessionDelegate>{
    
    //various metadata to store
    NSDictionary *imgurUnitTestParams;
    __block void(^ failBlock)(NSError * error);
    
    NSURL * testfileURL;
    NSURL * testGifURL;
    
}

@property BOOL calledImgurView;

/**
 Stub reponse for next request
 */
-(void)stubWithFile:(NSString * )filename;
/**
 Stub reponse for next request with status code option
 */
-(void)stubWithFile:(NSString *)filename withStatusCode:(int)status;
/**
 Stub reponse for next request with custom headers
 */
-(void)stubWithFile:(NSString * )filename withHeader:(NSDictionary*)headerDict;


@end
