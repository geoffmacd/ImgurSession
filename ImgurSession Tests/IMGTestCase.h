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

@interface IMGTestCase : XCTestCase <IMGSessionDelegate>{
    
    //various metadata to store
    NSDictionary *imgurVariousValues;
    NSURL * testfileURL;
    __unsafe_unretained __block void(^ failBlock)(NSError * error);
}

-(void)postTestGalleryImage:(void(^)(IMGGalleryImage *,void(^)()))success;
-(void)postTestImage:(void(^)(IMGImage *,void(^)()))success;
-(void)postTestGalleryAlbumWithOneImage:(void(^)(IMGGalleryAlbum *,void(^)()))success;
-(void)postTestAlbumWithOneImage:(void(^)(IMGAlbum *,void(^)()))success;

@end
