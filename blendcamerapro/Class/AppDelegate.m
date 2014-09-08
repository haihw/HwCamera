//
//  AppDelegate.m
//  blendcamerapro
//
//  Created by Dung NP on 8/22/12.
//  Copyright (c) 2012 Applistar Vietnam. All rights reserved.
//
#define kAPP_ID     @"631191585"
#define kAPP_IDIpad @"631191585"
#import "AppDelegate.h"
#import "ViewController.h"
#import "MySHKConfigurator.h"
#import "SHKConfiguration.h"
#import "SHKFacebook.h"
#import "Appirater.h"
@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    DefaultSHKConfigurator *configurator = [[MySHKConfigurator alloc] init];
    [SHKConfiguration sharedInstanceWithConfigurator:configurator];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    {
        if ([UIScreen mainScreen].bounds.size.height > 480) {
            self.viewController = [[ViewController alloc] initWithNibName:@"ViewController4inch" bundle:nil];
        }
        else
        {
            self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
        }
    }
    else
    {
        self.viewController = [[ViewController alloc] initWithNibName:@"ViewControllerIpad" bundle:nil];
    }
   
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    //
    NSString *appID = kAPP_ID;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        appID = kAPP_IDIpad;
    [Appirater setAppId:appID];
    [Appirater setDaysUntilPrompt:2];
    [Appirater setUsesUntilPrompt:10];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:3];
//    [Appirater setDebug:YES];
    
    [Appirater appLaunched:YES];
    
    //Google Analytics
//    // Optional: automatically send uncaught exceptions to Google Analytics.
//    [GAI sharedInstance].trackUncaughtExceptions = YES;
//    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
//    [GAI sharedInstance].dispatchInterval = 20;
//    // Optional: set debug to YES for extra debugging information.
////    [GAI sharedInstance].debug = YES;
//    // Create tracker instance.
//    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-38276506-5"];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
//- (BOOL)handleOpenURL:(NSURL*)url
//{
//    NSString* scheme = [url scheme];
//    if ([scheme hasPrefix:[NSString stringWithFormat:@"fb%@", SHKCONFIG(facebookAppId)]])
//        return [SHKFacebook handleOpenURL:url];
//    return YES;
//}
//- (BOOL)application:(UIApplication *)application
//            openURL:(NSURL *)url
//  sourceApplication:(NSString *)sourceApplication
//         annotation:(id)annotation
//{
//    return [self handleOpenURL:url];
//}
//
//- (BOOL)application:(UIApplication *)application
//      handleOpenURL:(NSURL *)url
//{
//    
//    return [self handleOpenURL:url];
//}
//

@end
