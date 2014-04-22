//
//  NSError+IMGError.h
//  ImgurSession
//
//  Created by Xtreme Dev on 2014-04-22.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <Foundation/Foundation.h>

//error keys
#define IMGErrorDomain                          @"com.geoffmacdonald.imgursession"
#define IMGErrorServerDescription               NSLocalizedDescriptionKey  //the 'error' key within the 'data' object delivered by failed requests
#define IMGErrorServerMethod                    @"ImgurErrorMethod"     //the 'method' key within the 'data' object delivered by failed requests
#define IMGErrorServerPath                      @"ImgurErrorPath"       //the 'request' key within the 'data' object delivered by failed requests
#define IMGErrorDecoding                        @"ImgurOriginalDecodingError"     //key for original error object when decoding
#define IMGErrorAuthenticationError             @"ImgurAuthenticationError"     //key for original error object when decoding

//error codes from model object creation
#define IMGErrorMalformedResponseFormat         0   //Response data is in wrong format for model object to be created
#define IMGErrorResponseMissingParameters       1   //some critical fields are not in response for model objects

//status codes
#define IMGErrorRequiresUserAuthentication      401   //valid tokens?
#define IMGErrorForbidden                       403   //valid tokens or rate limiting?
#define IMGErrorUserRateLimitExceeded           429   //user rate limit hit
#define IMGErrorMissingClientAuthentication     2   //no authentication parameters for authorized session
#define IMGErrorCouldNotAuthenticate            3   //refresh token did not succeed, possibly banned or rate limited?

@interface NSError (IMGError)

@end
