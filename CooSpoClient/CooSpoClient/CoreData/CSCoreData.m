//
//  CSCoreData.m
//  CooSpoClient
//
//  Created by 马远征 on 14-10-16.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "CSCoreData.h"
#import "CooSpoDefine.h"
#import "NSManagedObjectContext+Package.h"

@implementation CSCoreData

- (NSDateFormatter*)dateFormatter
{
    if (_dateFormatter == nil)
    {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd"];
        [_dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    return _dateFormatter;
}

- (NSOperationQueue*)operationQueue
{
    if (_operationQueue)
    {
        return _operationQueue;
    }
    _operationQueue = [[NSOperationQueue alloc]init];
    
    return _operationQueue;
}

#pragma mark -
#pragma mark 默认参数，包括用户信息和睡眠唤醒参数

- (void)initializeDefaultParams
{
    NSManagedObjectContext *context = self.mainManagedObjectContext;
    WEAKSELF;
    [context performBlock:^{
        // 初始化默认用户资料
        NSEntityDescription *userInfoEntity = [NSEntityDescription entityForName:@"UserInfoEntity"
                                                          inManagedObjectContext:context];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:userInfoEntity];
        NSError *error = nil;
        NSInteger count = [context countForFetchRequest:fetchRequest error:&error];
        if (count == 0)
        {
            UserInfoEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:@"UserInfoEntity"
                                                                   inManagedObjectContext:context];
            entity.age = [NSNumber numberWithInt:30];
            entity.sex = [NSNumber numberWithBool:YES];
            entity.height = [NSNumber numberWithInt:175];
            entity.stride = [NSNumber numberWithInt:40];
            entity.weight = [NSNumber numberWithInt:650];
            entity.goal = [NSNumber numberWithInt:100000];
            [weakSelf saveContext];
        }
        // 初始化默认睡眠参数
        NSEntityDescription *swParamsEntity = [NSEntityDescription entityForName:@"SwParamsEntity" inManagedObjectContext:context];
        [fetchRequest setEntity:swParamsEntity];
        count = [context countForFetchRequest:fetchRequest error:&error];
        if (count == 0)
        {
            SwParamsEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:@"SwParamsEntity" inManagedObjectContext:context];
            entity.stHour = [NSNumber numberWithInt:21];
            entity.stMininute = [NSNumber numberWithInt:30];
            entity.spHour = [NSNumber numberWithInt:07];
            entity.spMininute = [NSNumber numberWithInt:00];
            entity.nmSthreshold = [NSNumber numberWithInt:10];
            entity.aifSthreshold = [NSNumber numberWithInt:200];
            entity.autoSWEnable = [NSNumber numberWithBool:YES];
            entity.needUpdate = [NSNumber numberWithBool:YES];
            [weakSelf saveContext];
        }
    }];
}

#pragma mark -
#pragma mark 最近同步记录

- (void)insertOrUpdateLastSynchRecord:(NSDictionary*)params
{
    if(params == nil) return;
    NSManagedObjectContext *context = self.mainManagedObjectContext;
    WEAKSELF;
    [context performBlockAndWait:^{
        STRONGSELF;
        NSEntityDescription *userInfoEntity = [NSEntityDescription entityForName:@"RecentSynchEntity" inManagedObjectContext:context];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:userInfoEntity];
        NSError *error = nil;
        NSArray *fetchArray = [context executeFetchRequest:fetchRequest error:&error];
        if (fetchArray == nil || fetchArray.count <= 0)
        {
            RecentSynchEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:@"RecentSynchEntity" inManagedObjectContext:context];
            entity.calorie = params[@"calorie"];
            entity.steps = params[@"steps"];
            entity.distance = params[@"distance"];
            entity.utcTime = params[@"utcTime"];
        }
        else
        {
            RecentSynchEntity *entity = (RecentSynchEntity*)[fetchArray lastObject];
            entity.calorie = params[@"calorie"];
            entity.steps = params[@"steps"];
            entity.distance = params[@"distance"];
            entity.utcTime = params[@"utcTime"];
        }
        [strongSelf.backReadManagedObjectContext saveAsynchronously];
    }];
}


- (NSDictionary*)fetchLastSynchRecord:(BOOL)asynchQuery result:(void(^)(NSDictionary *ret, NSError *error))block
{
    NSManagedObjectContext *context = self.backReadManagedObjectContext;
    __block NSDictionary *retObject = nil;
    void (^fetchBlock)(void) = ^{
        NSEntityDescription *userInfoEntity = [NSEntityDescription entityForName:@"RecentSynchEntity" inManagedObjectContext:context];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:userInfoEntity];
        [fetchRequest setResultType:NSDictionaryResultType];
        NSError *error = nil;
        NSArray *fetchArray = [context executeFetchRequest:fetchRequest error:&error];
//        NSLog(@"fetchArray---%@",fetchArray);
        if(error || fetchArray == nil || fetchArray.count <= 0)
        {
            if (block)
            {
                block(nil,error);
            }
        }
        else
        {
            retObject = [fetchArray lastObject];
            if (block)
            {
                block(retObject, nil);
            }
        }
    };
    
    if (asynchQuery)
    {
        [context performBlock:fetchBlock];
    }
    else
    {
        [context performBlockAndWait:fetchBlock];
    }
    return retObject;
}


#pragma mark -
#pragma mark 用户资料

- (void)insertOrUpdateUserInfo:(NSDictionary *)params
{
    if (params == nil) return;
    NSManagedObjectContext *context = self.mainManagedObjectContext;
    WEAKSELF;
    [context performBlockAndWait:^{
        NSEntityDescription *userInfoEntity = [NSEntityDescription entityForName:@"UserInfoEntity"
                                                          inManagedObjectContext:context];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:userInfoEntity];
        NSError *error = nil;
        NSArray *fetchArray = [context executeFetchRequest:fetchRequest error:&error];
        if (fetchArray == nil || fetchArray.count <= 0)
        {
            UserInfoEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:@"UserInfoEntity"
                                                                   inManagedObjectContext:context];
            for (NSString *key in params)
            {
                [entity setValue:params[key] forKey:key];
            }
        }
        else
        {
            UserInfoEntity *entity = (UserInfoEntity*)[fetchArray lastObject];
            for (NSString *key in params)
            {
                [entity setValue:params[key] forKey:key];
            }
        }
        [weakSelf saveContext];
    }];
}

- (NSDictionary*)fetchUserInfo:(BOOL)asynchQuery result:(void(^)(NSDictionary *ret, NSError *error))block
{
    NSManagedObjectContext *context = self.backReadManagedObjectContext;
    __block NSDictionary *retObject = nil;
    void (^fetchBlock) (void) = ^{
        NSEntityDescription *userInfoEntity = [NSEntityDescription entityForName:@"UserInfoEntity" inManagedObjectContext:context];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:userInfoEntity];
        [fetchRequest setResultType:NSDictionaryResultType];
        NSError *error = nil;
        NSArray *fetchArray = [context executeFetchRequest:fetchRequest error:&error];
//        NSLog(@"fetchArray---%@",fetchArray);
        if(error || fetchArray == nil || fetchArray.count <= 0)
        {
            if (block)
            {
                block(nil,error);
            }
        }
        else
        {
            retObject = [fetchArray lastObject];
            if (block)
            {
                block(retObject, nil);
            }
        }
    };
    if (asynchQuery)
    {
        [context performBlock:fetchBlock];
    }
    else
    {
        [context performBlockAndWait:fetchBlock];
    }
    return retObject;
}

#pragma mark -
#pragma mark 睡眠参数

- (void)insertOrUpdateSwParams:(NSDictionary *)params
{
    if (params == nil)  return;
    NSManagedObjectContext *context = self.backReadManagedObjectContext;
    WEAKSELF;
    [context performBlockAndWait:^{
        STRONGSELF;
        NSEntityDescription *userInfoEntity = [NSEntityDescription entityForName:@"SwParamsEntity" inManagedObjectContext:context];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:userInfoEntity];
        NSError *error = nil;
        NSArray *fetchArray = [context executeFetchRequest:fetchRequest error:&error];
        if (fetchArray == nil || fetchArray.count <= 0)
        {
            SwParamsEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:@"SwParamsEntity" inManagedObjectContext:context];
            for (NSString *key in params)
            {
                [entity setValue:params[key] forKey:key];
            }
        }
        else
        {
            DEBUG_METHOD(@"-----更新参数完成---");
            SwParamsEntity *entity = (SwParamsEntity*)[fetchArray lastObject];
            for (NSString *key in params)
            {
                [entity setValue:params[key] forKey:key];
            }
        }
        [strongSelf.backReadManagedObjectContext saveAsynchronously];
    }];
}

- (NSDictionary*)fetchSwParams:(BOOL)asynchQuery result:(void(^)(NSDictionary *ret, NSError *error))block
{
    NSManagedObjectContext *context = self.backReadManagedObjectContext;
    __block NSDictionary *tmpDic = nil;
    void (^fetchBlock) (void) = ^{
        NSEntityDescription *userInfoEntity = [NSEntityDescription entityForName:@"SwParamsEntity"
                                                          inManagedObjectContext:context];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:userInfoEntity];
        [fetchRequest setResultType:NSDictionaryResultType];
        NSError *error = nil;
        NSArray *fetchArray = [context executeFetchRequest:fetchRequest error:&error];
        if (!error && fetchArray && fetchArray.count > 0)
        {
            tmpDic = (NSDictionary*)[fetchArray firstObject];
            if (block)
            {
                block(tmpDic,nil);
            }
        }
        else
        {
            if (block)
            {
                block(nil,error);
            }
        }
    };
    
    if (asynchQuery)
    {
        [context performBlock:fetchBlock];
    }
    else
    {
        [context performBlockAndWait:fetchBlock];
    }
    return tmpDic;
}

#pragma mark -
#pragma mark 同步记录

- (void)insertOrUpdateDailySynchRecord:(NSDictionary *)params
{
    if (params == nil) return;
    NSManagedObjectContext *context = self.mainManagedObjectContext;
    WEAKSELF;
    [context performBlockAndWait:^{
        STRONGSELF;
        NSTimeInterval utcTime = [params[@"utcTime"]doubleValue];
        NSDate *utcDate = [NSDate dateWithTimeIntervalSince1970:utcTime];
        
        [strongSelf.dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *utcDateString = [strongSelf.dateFormatter stringFromDate:utcDate];
        
        [strongSelf.dateFormatter setDateFormat:@"yyyy"];
        NSString *year = [self.dateFormatter stringFromDate:utcDate];
        
        [self.dateFormatter setDateFormat:@"MM"];
        NSString *month = [self.dateFormatter stringFromDate:utcDate];
        
        [self.dateFormatter setDateFormat:@"dd"];
        NSString *day = [self.dateFormatter stringFromDate:utcDate];
        
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"SynchDataEntity" inManagedObjectContext:context];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"utcTime = %@", utcDateString];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"utcTime" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        NSError *queryError = nil;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&queryError];
        if (fetchedObjects.count > 0)
        {
            SynchDataEntity *syncObject = [fetchedObjects objectAtIndex:0];
            syncObject.utcTime = utcDateString;
            syncObject.steps = @([params[@"steps"]longLongValue]);
            syncObject.distance = @([params[@"distance"]longLongValue]);
            syncObject.calorie = @([params[@"calorie"]longLongValue]);
            syncObject.complete = @([params[@"complete"]boolValue]);
            syncObject.year = year;
            syncObject.month = month;
            syncObject.day = day;
        }
        else
        {
            SynchDataEntity *syncObject = [NSEntityDescription insertNewObjectForEntityForName:@"SynchDataEntity"
                                                                        inManagedObjectContext:context];
            syncObject.utcTime = utcDateString;
            syncObject.steps = @([params[@"steps"]longLongValue]);
            syncObject.distance = @([params[@"distance"]longLongValue]);
            syncObject.calorie = @([params[@"calorie"]longLongValue]);
            syncObject.complete = @([params[@"complete"]boolValue]);
            syncObject.year = year;
            syncObject.month = month;
            syncObject.day = day;
        }
        [weakSelf saveContext];
    }];
}

- (NSDictionary*)fetchSynchRecord:(BOOL)asynchQuery byDate:(NSDate*)date result:(void (^)(NSDictionary *ret, NSError *error))block;
{
    __block NSDictionary *retObject = nil;
    if (date == nil)
    {
        if (block)
        {
            block(nil,nil);
        }
        return nil;
    }
    WEAKSELF; STRONGSELF;
    NSManagedObjectContext *context = self.backReadManagedObjectContext;
    void (^fetchBlock)(void) = ^{
        
        [strongSelf.dateFormatter setDateFormat:@"yyyy"];
        NSString *year = [self.dateFormatter stringFromDate:date];
        
        [strongSelf.dateFormatter setDateFormat:@"MM"];
        NSString *month = [self.dateFormatter stringFromDate:date];
        
        [strongSelf.dateFormatter setDateFormat:@"dd"];
        NSString *day = [self.dateFormatter stringFromDate:date];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"year = %@ AND month = %@ AND day = %@", year,month,day];
        
        NSEntityDescription *userInfoEntity = [NSEntityDescription entityForName:@"SynchDataEntity" inManagedObjectContext:context];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setEntity:userInfoEntity];
        [fetchRequest setResultType:NSDictionaryResultType];
        NSError *error = nil;
        NSArray *fetchArray = [context executeFetchRequest:fetchRequest error:&error];
        if(error || fetchArray == nil || fetchArray.count <= 0)
        {
            if (block)
            {
                block(nil,error);
            }
        }
        else
        {
            retObject = [fetchArray lastObject];
            if (block)
            {
                block(retObject, nil);
            }
        }
    };
    
    if (asynchQuery)
    {
        [context performBlock:fetchBlock];
    }
    else
    {
        [context performBlockAndWait:fetchBlock];
    }
    return retObject;
}


- (NSDictionary*)fetchTotalRecords:(BOOL)asynchQuery result:(void(^)(NSDictionary *ret, NSError *error))block
{
    NSManagedObjectContext *context = self.backReadManagedObjectContext;
    __block NSDictionary *tmpDic = nil;
    void (^fetchBlock) (void) = ^{
        NSEntityDescription *userInfoEntity = [NSEntityDescription entityForName:@"SynchDataEntity"
                                                          inManagedObjectContext:context];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:userInfoEntity];
        [fetchRequest setResultType:NSDictionaryResultType];
        [fetchRequest setPropertiesToFetch:@[@"steps",@"distance",@"calorie"]];
        NSError *error = nil;
        NSArray *fetchArray = [context executeFetchRequest:fetchRequest error:&error];
        if (!error && fetchArray && fetchArray.count > 0)
        {
            NSNumber *stepNum = [fetchArray valueForKeyPath:@"@sum.steps"];
            NSNumber *distanceNum = [fetchArray valueForKeyPath:@"@sum.distance"];
            NSNumber *calorieNum = [fetchArray valueForKeyPath:@"@sum.calorie"];
            tmpDic = @{@"steps":stepNum,@"distance":distanceNum,@"calorie":calorieNum};
            if (block)
            {
                block(tmpDic,nil);
            }
        }
        else
        {
            if (block)
            {
                block(nil,error);
            }
        }
    };
    
    if (asynchQuery)
    {
        [context performBlock:fetchBlock];
    }
    else
    {
        [context performBlockAndWait:fetchBlock];
    }
    return tmpDic;
}

#pragma mark -
#pragma mark 每日目标

- (void)insertOrUpdateTGoal:(NSDictionary*)params
{
    if (params == nil) return;
    WEAKSELF;
    STRONGSELF;
    
    NSManagedObjectContext *context = self.mainManagedObjectContext;
    [context performBlockAndWait:^{
        [strongSelf.dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *utcDateString = [strongSelf.dateFormatter stringFromDate:[NSDate date]];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"DailyGoalsEntity" inManagedObjectContext:context];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dateTime = %@", utcDateString];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
        
        NSError *queryError = nil;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&queryError];
        if (fetchedObjects.count > 0)
        {
            DailyGoalsEntity *goalObject = [fetchedObjects objectAtIndex:0];
            goalObject.dateTime = utcDateString;
            goalObject.dailyGoals = params[@"goal"];
        }
        else
        {
            DailyGoalsEntity *goalObject = [NSEntityDescription insertNewObjectForEntityForName:@"DailyGoalsEntity"
                                                                        inManagedObjectContext:context];
            goalObject.dateTime = utcDateString;
            goalObject.dailyGoals = params[@"goal"];
        }
        [weakSelf saveContext];
    }];
    
}

- (NSDictionary*)fetchLastGoal:(BOOL)asynchFetch result:(void(^)(NSDictionary *ret, NSError *error))block
{
    NSManagedObjectContext *context = self.backReadManagedObjectContext;
    __block NSDictionary *tmpDic = nil;
    void (^fetchBlock) (void) = ^{
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"DailyGoalsEntity"
                                                  inManagedObjectContext:context];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateTime" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setResultType:NSDictionaryResultType];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        
        NSError *error = nil;
        NSArray *fetchArray = [context executeFetchRequest:fetchRequest error:&error];
        if (!error && fetchArray && fetchArray.count > 0)
        {
            tmpDic = [fetchArray lastObject];;
            if (block)
            {
                block(tmpDic,nil);
            }
        }
        else
        {
            if (block)
            {
                block(nil,error);
            }
        }
    };
    
    if (asynchFetch)
    {
        [context performBlock:fetchBlock];
    }
    else
    {
        [context performBlockAndWait:fetchBlock];
    }
    return tmpDic;
}

- (NSArray*)fetchTGoal:(BOOL)asynchFetch result:(void(^)(NSArray *ret, NSError *error))block
{
    NSManagedObjectContext *context = self.backReadManagedObjectContext;
    __block NSArray *tmpArray = nil;
    void (^fetchBlock) (void) = ^{
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"DailyGoalsEntity"
                                                          inManagedObjectContext:context];

        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateTime" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setResultType:NSDictionaryResultType];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        
        NSError *error = nil;
        NSArray *fetchArray = [context executeFetchRequest:fetchRequest error:&error];
        if (!error && fetchArray && fetchArray.count > 0)
        {
            tmpArray = fetchArray;
            if (block)
            {
                block(tmpArray,nil);
            }
        }
        else
        {
            if (block)
            {
                block(nil,error);
            }
        }
    };
    
    if (asynchFetch)
    {
        [context performBlock:fetchBlock];
    }
    else
    {
        [context performBlockAndWait:fetchBlock];
    }
    return tmpArray;
}

- (void)insertNewSportData:(NSData*)data utcTime:(UInt32)utcTime
{
    if (data == nil) return;
    CSSportsDataOperation *operation = [[CSSportsDataOperation alloc]initWithData:data utcTime:utcTime];
    [self.operationQueue addOperation:operation];
}

- (void)insertNewSleepData:(NSData*)data utcTime:(UInt32)utcTime
{
    if (data == nil) return;
    CSSleepDataOperation *operation = [[CSSleepDataOperation alloc]initWithData:data utcTime:utcTime];
    [self.operationQueue addOperation:operation];
}
@end
