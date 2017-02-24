//
//  CoreDataHelper.m
//  CoreDataDemo
//
//  Created by jimmy Chan on 2017/2/23.
//  Copyright © 2017年 jimmychan. All rights reserved.
//

#import "CoreDataHelper.h"
@implementation CoreDataHelper
#define debug 1

#pragma mark - FILES
NSString *storeFileName = @"CoreData.sqlite";
#pragma mark - PATH
-(NSString *)applicationDocumentsDirectiory{
    if (debug ==1) {
        NSLog(@"Running %@ %@",self.class,NSStringFromSelector(_cmd));
    }
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}
-(NSURL *)applicationStoreDirectory{
    if (debug ==1) {
        NSLog(@"Running %@ %@",self.class,NSStringFromSelector(_cmd));
    }
    NSURL *storeDirectory = [[NSURL fileURLWithPath:[self applicationDocumentsDirectiory]] URLByAppendingPathComponent:@"Store"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:[storeDirectory path]]) {
        NSError *error = nil;
        if ([fileManager createDirectoryAtURL:storeDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
            if (error) {
                NSLog(@"Successfully created Stores directory");
            }
            else{
                NSLog(@"FAILED to created Stores directory:%@",error);
            }
        }
    }
    return storeDirectory;
}
-(NSURL *)storeURL{
    if (debug ==1) {
        NSLog(@"Running %@ %@",self.class,NSStringFromSelector(_cmd));
    }
    return  [[self applicationStoreDirectory] URLByAppendingPathComponent:storeFileName];
}
#pragma mark - SETUP
-(instancetype)init{
    if (debug ==1) {
        NSLog(@"Running %@ %@",self.class,NSStringFromSelector(_cmd));
    }
    self = [super init];
    if (!self) {
        return nil;
    }
    _model = [NSManagedObjectModel mergedModelFromBundles:nil];
    _coordinator = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:_model];
    _context = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_context setPersistentStoreCoordinator:_coordinator];
    return self;
}
-(void)loadStore{
    if (debug ==1) {
        NSLog(@"Running %@ %@",self.class,NSStringFromSelector(_cmd));
    }
    if (_store) {
        return;
    }
    NSError *error = nil;
    _store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeURL] options:nil error:&error];
    if (!_store) {
        NSLog(@"FAILED to add store:%@",error);
    }
    else
    {
        if (debug == 1) {
            NSLog(@"Successfully add store %@",_store);

        }
    }
}
-(void)setupCoreData{
    if (debug ==1) {
        NSLog(@"Running %@ %@",self.class,NSStringFromSelector(_cmd));
    }
    [self loadStore];
}
#pragma mark - SAVING
-(void)saveContext{
    if (debug ==1) {
        NSLog(@"Running %@ %@",self.class,NSStringFromSelector(_cmd));
    }
    if ([_context hasChanges]) {
        NSError *error = nil;
        if ([_context save:&error]) {
            NSLog(@"_context saved...");
        }
        else{
            NSLog(@"FAILED to save _context:%@",error);
        }
    }
    else{
        NSLog(@"SKIPPED _context save ,there is no changes!");
    }
}
@end
