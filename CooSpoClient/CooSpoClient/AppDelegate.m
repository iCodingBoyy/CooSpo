//
//  AppDelegate.m
//  CooSpoClient
//
//  Created by 马远征 on 14-10-10.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "AppDelegate.h"
#import "Controllers/CooSpoController/CooSpoViewController.h"
#import "Controllers/MenuController/CSMenuController.h"
#import "Controllers/SideController/CSSideController.h"
#import "Controllers/NavigationController/CSNavigationController.h"
#import "CSBluetooth.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CSMenuController *menuController = [storyBoard instantiateInitialViewController];
    
    UINavigationController *coospoController = [CSNavigationController shared];
    CSSideController *sideController = [[CSSideController alloc]initWithRootViewController:coospoController
                                                                         leftViewContrller:menuController
                                                                       rightViewContorller:nil];
    self.window.rootViewController = sideController;

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSLog(@"--paths---%@",paths);
    // 初始化默认参数
    [[CSBluetooth shared]initialize];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
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
