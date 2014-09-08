//
//  AppDelegate.h
//  blendcamerapro
//
//  Created by Dung NP on 8/22/12.
//  Copyright (c) 2012 Applistar Vietnam. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate>
{
    NSURL *currentLink;
}
@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

@end
