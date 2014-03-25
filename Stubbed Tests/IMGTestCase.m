//
//  IMGTestCase.m
//  ImgurSession
//
//  Created by Xtreme Dev on 2014-03-18.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGTestCase.h"

@implementation IMGTestCase

- (void)setUp {
    [super setUp];
    //run before each test
    
    //5 second timeout
    [Expecta setAsynchronousTestTimeout:5.0];
        
    // Storing various testing values
    NSDictionary *infos = [[NSBundle bundleForClass:[self class]] infoDictionary];
    
    //need various values such as image title
    imgurUnitTestParams = infos[@"imgurUnitTestParams"];
    
    //failure block
    failBlock = ^(NSError * error) {
        XCTAssert(nil, @"FAIL");
    };
}

- (void)tearDown {
    [super tearDown];
}

-(void)stubWithFile:(NSString * )filename {
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        // Stub it with our "wsresponse.json" stub file
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(filename,nil)
                                                statusCode:200 headers:@{@"Content-Type":@"text/json"}];
    }];
}

#pragma mark - IMGSessionDelegate Delegate methods

-(void)imgurSessionNeedsExternalWebview:(NSURL *)url{
}

-(void)imgurSessionModelFetched:(id)model{
    
    NSLog(@"New imgur model fetched: %@", [model description]);
}

-(void)imgurSessionRateLimitExceeded{
    
    NSLog(@"Hit rate limit");
    failBlock(nil);
}

@end
