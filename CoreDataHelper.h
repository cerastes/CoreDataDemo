//
//  CoreDataHelper.h
//  CoreDataDemo
//
//  Created by jimmy Chan on 2017/2/23.
//  Copyright © 2017年 jimmychan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataHelper : NSObject
@property (nonatomic,readonly) NSManagedObjectContext *context;
@property (nonatomic,readonly) NSManagedObjectModel   *model;
@property (nonatomic,readonly) NSPersistentStoreCoordinator *coordinator;
@property (nonatomic,readonly) NSPersistentStore      *store;
-(void)setupCoreData;
-(void)saveContext;
@end
