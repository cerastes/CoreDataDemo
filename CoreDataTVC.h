//
//  CoreDataTVC.h
//  CoreDataDemo
//
//  Created by jimmy Chan on 2017/3/14.
//  Copyright © 2017年 jimmychan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"
@interface CoreDataTVC : UITableViewController<NSFetchedResultsControllerDelegate>
@property(strong,nonatomic)NSFetchedResultsController *frc;
-(void)performFetch;
@end
