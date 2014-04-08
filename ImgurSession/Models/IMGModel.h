//
//  IMGModel.h
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//


//error codes
#define IMGErrorDomain                          @"com.imgursession"

#define IMGErrorMalformedResponseFormat         0   //Response data is in wrong format
#define IMGErrorResponseMissingParameters       1   //some critical fields are not in response
#define IMGErrorRequiresUserAuthentication      401   //for when anonymous sessions attempt calls only logged in users can perform
#define IMGErrorUserRateLimitExceeded           429   //user rate limit hit


@interface IMGModel : NSObject <NSCoding>

/**
 Common initializer for JSON HTTP response which processes the "data" JSON object into model object class
 @return initilialized instancetype object
 */
- (instancetype)initWithJSONObject:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error;

/**
 Intercept class to allow notification/delegates
 @return initilialized instancetype object
 */
- (instancetype)trackModels;



@end
