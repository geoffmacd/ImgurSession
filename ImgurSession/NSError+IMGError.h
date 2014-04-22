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
#define IMGErrorDecoding                        @"OriginalDecodingError"     //key for original error object when decoding

#define IMGErrorMalformedResponseFormat         0   //Response data is in wrong format
#define IMGErrorResponseMissingParameters       1   //some critical fields are not in response
#define IMGErrorNoAuthentication                2   //no authentication, anon or otherwise
#define IMGErrorCouldNotAuthenticate            3   //refresh token did not succeed

//status codes
#define IMGErrorRequiresUserAuthentication      401   //valid tokens?
#define IMGErrorForbidden                       403   //valid tokens or rate limiting?
#define IMGErrorUserRateLimitExceeded           429   //user rate limit hit

@interface NSError (IMGError)

@end
