//
//  GMMAppDelegate.h
//  SampleApp
//
//  Created by Xtreme Dev on 2014-05-13.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImgurSession.h"

@interface GMMAppDelegate : UIResponder <UIApplicationDelegate,IMGSessionDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (copy) void(^continueHandler)();

@end
