//
//  AppDelegate.m
//  fjdhfjkad
//
//  Created by raymon_wang on 14-11-10.
//  Copyright (c) 2014年 wang3140@hotmail.com. All rights reserved.
//

#import "AppDelegate.h"
#include "PhotoInPhoneController.h"
#import "AppHelper.h"
#import "PhotoAlbumsController.h"
#import "TestRootViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    UIStoryboard *storyboard = [AppHelper stroyboardWithName:@"MainStoryboard"];
    
//    PhotoAlbumsController *ctl = [storyboard instantiateViewControllerWithIdentifier:@"PhotoAlbumsController"];
    TestRootViewController *ctl = [storyboard instantiateViewControllerWithIdentifier:@"TestRootViewController"];
    UINavigationController *rootNav = [[UINavigationController alloc] init];
    rootNav.viewControllers = @[ctl];
    
//    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
//    UIViewController* vc = [sb instantiateViewControllerWithIdentifier:@"PhotoInPhoneController"];
//    
    self.window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
//    [_window addSubview: vc.view];
    [_window setRootViewController:rootNav];
    [_window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
