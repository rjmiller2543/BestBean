//
//  AppDelegate.h
//  BestBean
//
//  Created by Robert Miller on 3/31/14.
//  Copyright (c) 2014 Robert Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

+(id)sharedInstance;

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain) PFUser *parseUser;
@property (nonatomic, retain) UIColor * subViewTintColor;

@end
