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
    
    
    BOOL useMigrationManager = NO;
    if (useMigrationManager && [self isMigrationNecessaryForStore:[self storeURL]]) {
        [self performBackgroundManagedMigrationForStore:[self storeURL]];
    }
    else
    {
        NSDictionary *options = @{
                                  NSMigratePersistentStoresAutomaticallyOption:@YES,
                                  NSInferMappingModelAutomaticallyOption:@YES,
                                  NSSQLitePragmasOption:@{@"journal_mode":@"DELETE"}};
        NSError *error = nil;
        _store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeURL] options:options error:&error];
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


-(BOOL)isMigrationNecessaryForStore:(NSURL *)stroeUrl{
    if (debug ==1) {
        NSLog(@"Running %@ %@",self.class,NSStringFromSelector(_cmd));
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self storeURL].path]) {
        return NO;
    }
    NSError *error = nil;
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:stroeUrl error:&error];
    NSManagedObjectModel *destinationModel = _coordinator.managedObjectModel;
    if ([destinationModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata]) {
        if (debug == 1) {
            return NO;
        }
    }
    return YES;
}

-(BOOL)migrateStore:(NSURL *)sourceStore{
    if (debug ==1) {
        NSLog(@"Running %@ %@",self.class,NSStringFromSelector(_cmd));
    }
    BOOL success = NO;
    NSError *error = nil;
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:sourceStore error:&error];
    NSManagedObjectModel *sourceModel = [NSManagedObjectModel mergedModelFromBundles:nil    forStoreMetadata:sourceMetadata];
    NSManagedObjectModel *destinModel = _model;
    NSMappingModel *mappingModel = [NSMappingModel mappingModelFromBundles:nil forSourceModel:sourceModel destinationModel:destinModel];
    if (mappingModel) {
        NSError *error = nil;
        NSMigrationManager *migrationManager = [[NSMigrationManager alloc]initWithSourceModel:sourceModel destinationModel:destinModel];
        [migrationManager addObserver:self forKeyPath:@"migrationProgress" options:NSKeyValueObservingOptionNew context:NULL];
        NSURL *destinStore = [[self applicationStoreDirectory] URLByAppendingPathComponent:@"Temp.sqlite"];
        success = [migrationManager migrateStoreFromURL:sourceStore type:NSSQLiteStoreType options:nil withMappingModel:mappingModel toDestinationURL:destinStore destinationType:NSSQLiteStoreType destinationOptions:nil error:&error];
        if (success) {
            if ([self replaceStore:sourceStore withStore:destinStore]) {
                [migrationManager removeObserver:self forKeyPath:@"migrationProgress"];
            }
        }
    }
    return YES;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (debug ==1) {
        NSLog(@"Running %@ %@",self.class,NSStringFromSelector(_cmd));
    }
    if ([keyPath isEqualToString:@"migrationProgress"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            float process = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
            self.viewController.processView.progress = process;
            int precent = process * 100;
            self.viewController.label.text = [NSString stringWithFormat:@"Migration Progress %i%%",precent];
        });
    }
}

-(BOOL)replaceStore:(NSURL *)old withStore:(NSURL *)new{
    if (debug ==1) {
        NSLog(@"Running %@ %@",self.class,NSStringFromSelector(_cmd));
    }
    BOOL success = NO;
    NSError *error = nil;
    if ([[NSFileManager defaultManager] removeItemAtURL:old error:&error]) {
        error = nil;
        if ([[NSFileManager defaultManager] moveItemAtURL:new toURL:old error:&error]) {
            success = YES;
        }
    }
    return success;
}

-(void)performBackgroundManagedMigrationForStore:(NSURL *)storeURL{
    if (debug ==1) {
        NSLog(@"Running %@ %@",self.class,NSStringFromSelector(_cmd));
    }
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.viewController = [sb instantiateViewControllerWithIdentifier:@"migration"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        BOOL done = [self migrateStore:storeURL];
        if (done) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error = nil;
                _store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeURL] options:nil error:&error];
                if (!_store) {
                    abort();
                }
                else
                {
                }
            });
        }
    });
}















@end
