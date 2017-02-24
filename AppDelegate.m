//
//  AppDelegate.m
//  CoreDataDemo
//
//  Created by jimmy Chan on 2017/2/23.
//  Copyright © 2017年 jimmychan. All rights reserved.
//

#import "AppDelegate.h"
#import "CoreDataHelper.h"
@interface AppDelegate ()
@property (strong ,nonatomic, readonly)CoreDataHelper *coreDataHelper;
@end

@implementation AppDelegate
#define debug 1


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application {
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[self cdh] saveContext];
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
}
- (void)applicationWillTerminate:(UIApplication *)application {
    [[self cdh] saveContext];
}

-(CoreDataHelper *)cdh{
    if (debug ==1) {
        NSLog(@"Running %@ %@",self.class,NSStringFromSelector(_cmd));
    }
    if (!_coreDataHelper) {
        _coreDataHelper = [CoreDataHelper new];
        [_coreDataHelper setupCoreData];
    }
    return _coreDataHelper;
}
@end
