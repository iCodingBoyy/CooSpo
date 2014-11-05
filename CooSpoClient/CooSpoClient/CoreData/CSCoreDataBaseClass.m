//
//  CSCoreDataBaseClass.m
//  CooSpoClient
//
//  Created by 马远征 on 14-10-16.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "CSCoreDataBaseClass.h"

@implementation CSCoreDataBaseClass
+ (instancetype)shared
{
    static dispatch_once_t pred;
    static CSCoreDataBaseClass *sharedinstance = nil;
    dispatch_once(&pred, ^{
        sharedinstance = [[self alloc] init];
    });
    return sharedinstance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self registerMasterSaveNotification];
    }
    return self;
}

- (void)registerMasterSaveNotification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
    typeof(self) __weak weakSelf = self;
    [[NSNotificationCenter defaultCenter]addObserverForName:NSManagedObjectContextDidSaveNotification
                                                     object:nil
                                                      queue:nil
                                                 usingBlock:^(NSNotification *note) {
                                                     typeof(self) __strong strongSelf = weakSelf;
                                                     NSManagedObjectContext *moc = strongSelf.mainManagedObjectContext;
                                                     if (moc != note.object)
                                                     {
                                                         [moc performBlock:^{
                                                             [moc mergeChangesFromContextDidSaveNotification:note];
                                                         }];
                                                     }}];
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - NSManagedObjectContext

- (NSManagedObjectContext*)masterManagedObjectContext
{
    if (_masterManagedObjectContext)
    {
        return _masterManagedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _masterManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_masterManagedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _masterManagedObjectContext;
}

- (NSManagedObjectContext*)mainManagedObjectContext
{
    if (_mainManagedObjectContext)
    {
        return _mainManagedObjectContext;
    }
    NSManagedObjectContext *masterContext = [self masterManagedObjectContext];
    if (masterContext)
    {
        _mainManagedObjectContext = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_mainManagedObjectContext setParentContext:masterContext];
    }
    return _mainManagedObjectContext;
}

- (NSManagedObjectContext*)sleepManagedObjectContext
{
    if (_sleepManagedObjectContext)
    {
        return _sleepManagedObjectContext;
    }
    NSManagedObjectContext *mainContext = [self mainManagedObjectContext];
    if (mainContext)
    {
        _sleepManagedObjectContext = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_sleepManagedObjectContext setParentContext:mainContext];
    }
    return _sleepManagedObjectContext;
}

- (NSManagedObjectContext*)sportsManagedObjectContext
{
    if (_sportsManagedObjectContext)
    {
        return _sportsManagedObjectContext;
    }
    NSManagedObjectContext *mainContext = [self mainManagedObjectContext];
    if (mainContext)
    {
        _sportsManagedObjectContext = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_sportsManagedObjectContext setParentContext:mainContext];
    }
    return _sportsManagedObjectContext;
}

- (NSManagedObjectContext*)sReadManagedObjectContext
{
    if (_sReadManagedObjectContext)
    {
        return _sReadManagedObjectContext;
    }
    _sReadManagedObjectContext = [[NSManagedObjectContext alloc]init];
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator)
    {
        [_sReadManagedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _sReadManagedObjectContext;
}


- (NSManagedObjectContext*)backReadManagedObjectContext
{
    if (_backReadManagedObjectContext)
    {
        return _backReadManagedObjectContext;
    }
    NSManagedObjectContext *mainContext = [self mainManagedObjectContext];
    if (mainContext)
    {
        _backReadManagedObjectContext = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_backReadManagedObjectContext setParentContext:mainContext];
    }
    return _backReadManagedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel)
    {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CSDataModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CSDataModel.sqlite"];
    NSError *error = nil;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:options error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return _persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Save Context

- (void)saveContext
{
    [self saveContextAndWait:NO];
}

+ (void)saveSynchronously
{
    [[CSCoreDataBaseClass shared]saveContextAndWait:YES];
}

+ (void)saveAsynchronously
{
    [[CSCoreDataBaseClass shared]saveContextAndWait:NO];
}

+ (void)saveContextAndWait:(BOOL)andWait
{
    [[CSCoreDataBaseClass shared]saveContextAndWait:andWait];
}

- (void)saveContextAndWait:(BOOL)andWait
{
    if (_mainManagedObjectContext && [_mainManagedObjectContext hasChanges])
    {
        [_mainManagedObjectContext performBlockAndWait:^{
            NSError *error = nil;
            [_mainManagedObjectContext save:&error];
            if (error)
            {
                NSLog(@"主线程上下文保存错误: %@", error);
            }
        }];
    }
    
    void (^savePrivate) (void) = ^{
        
        NSError *error = nil;
        [_masterManagedObjectContext save:&error];
        if (error)
        {
            NSLog(@"父线程上下文保存错误: %@", error);
        }
    };
    
    if (_masterManagedObjectContext && [_masterManagedObjectContext hasChanges])
    {
        if (andWait)
        {
            [_masterManagedObjectContext performBlockAndWait:savePrivate];
        }
        else
        {
            [_masterManagedObjectContext performBlock:savePrivate];
        }
    }
}

@end
