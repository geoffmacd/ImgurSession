//
//  IMGImageTests.m
//  ImgurSession
//
//  Created by Xtreme Dev on 2014-05-13.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGTestCase.h"

@interface IMGImageTests : IMGTestCase

@end


@implementation IMGImageTests

-(void)testPostImage{
    
    __block BOOL isPosted;
    
    [self stubWithFile:@"postimage.json"];
    
    [IMGImageRequest uploadImageWithURL:testfileURL success:^(IMGImage *image) {
        
        isPosted = YES;
    } failure:failBlock];
    
    expect(isPosted).will.beTruthy();
}

-(void)testImageNotFound{
    
    __block BOOL isSuccess = NO;
    
    //should fail request with not found
    [self stubWithFile:@"imagenotfound.json" withStatusCode:404];
    
    [IMGImageRequest imageWithID:@"fdsfdsfdsa" success:^(IMGImage *image) {
        
        //should not success
        failBlock([NSError errorWithDomain:IMGErrorDomain code:0 userInfo:nil]);
        
    } failure:^(NSError *error) {
        
        //imgur sometimes responds with previous account requests for some reasons saying it is a cache hit even though it is a different URL
        //in this case this test will fail with code 1 == IMGErrorResponseMissingParameters
        
        expect(error.code == 404).beTruthy();
        expect([error.userInfo[IMGErrorServerMethod] isEqualToString:@"GET"]).beTruthy();
        
        //should go here
        isSuccess = YES;
    }];
    
    expect(isSuccess).will.beTruthy();
}

@end
