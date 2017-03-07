//
//  AppDelegate.m
//  CoreDataDemo
//
//  Created by jimmy Chan on 2017/2/23.
//  Copyright © 2017年 jimmychan. All rights reserved.
//

#import "AppDelegate.h"
#import "CoreDataHelper.h"
#import "Item+CoreDataClass.h"
#import "Item+CoreDataProperties.h"
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
    [self cdh];
    [self demo];
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

-(void)demo{
//    NSArray *newItemNames = @[@"apple",@"orange",@"ban",@"milk",@"coffee",@"fish"];
//    for (NSString *newItemName in newItemNames) {
//        Item *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:_coreDataHelper.context];
//        newItem.name = newItemName;
//        NSLog(@"Inserted new Managed Object for %@",newItem.name);
//    }
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    //    模板谓词
//    NSFetchRequest *request = [[[_coreDataHelper model]fetchRequestTemplateForName:@"Test"] copy];
//    排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sort]];
//    谓词
//    NSPredicate *filter = [NSPredicate predicateWithFormat:@"name != %@",@"apple"];
//    [request setPredicate:filter];
    
    
    
    NSArray *Items = [_coreDataHelper.context executeFetchRequest:request error:nil];
    NSLog(@"%@",Items);
    [Items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Item *item = obj;
        NSLog(@"%@",item.name);
//        删除托管对象
//        [_coreDataHelper.context deleteObject:item];
    }];
}



































@end
