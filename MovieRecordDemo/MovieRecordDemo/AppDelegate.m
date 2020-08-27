//
//  AppDelegate.m
//  MovieRecordDemo
//
//  Created by 关晓珂 on 2020/8/19.
//  Copyright © 2020 TencentIOS. All rights reserved.
//

#import "AppDelegate.h"
#import "MovieRecordController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    MovieRecordController *viewController = [[MovieRecordController alloc] init];
    UINavigationController *navigationController  = [[UINavigationController alloc]initWithRootViewController:viewController];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
