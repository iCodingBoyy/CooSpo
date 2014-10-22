//
//  CSCoreDataBaseClass.h
//  CooSpoClient
//
//  Created by 马远征 on 14-10-16.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CSCoreDataBaseClass : NSObject
@property (nonatomic, strong) NSManagedObjectContext *masterManagedObjectContext;
@property (nonatomic, strong) NSManagedObjectContext *mainManagedObjectContext;
@property (nonatomic, strong) NSManagedObjectContext *backReadManagedObjectContext;
@property (nonatomic, strong) NSManagedObjectContext *sportsManagedObjectContext;
@property (nonatomic, strong) NSManagedObjectContext *sleepManagedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
+ (instancetype)shared;
- (void)saveContext;
+ (void)saveAsynchronously;
+ (void)saveSynchronously;
+ (void)saveContextAndWait:(BOOL)andWait;
@end
