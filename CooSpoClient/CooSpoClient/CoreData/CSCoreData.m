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
    _operationQueue.maxConcurrentOperationCount = 1;
    
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
            entity.age = @(30);
            entity.sex = @(YES);
            entity.height = @(175);
            entity.stride = @(40);
            entity.weight = @(650);
            entity.goal = @(100000);
            [weakSelf saveContext];
        }
        // 初始化默认睡眠参数
        NSEntityDescription *swParamsEntity = [NSEntityDescription entityForName:@"SwParamsEntity" inManagedObjectContext:context];
        [fetchRequest setEntity:swParamsEntity];
        count = [context countForFetchRequest:fetchRequest error:&error];
        if (count == 0)
        {
            SwParamsEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:@"SwParamsEntity" inManagedObjectContext:context];
            entity.stHour = @(22);
            entity.stMininute = @(00);
            entity.spHour = @(10);
            entity.spMininute = @(00);
            entity.nmSthreshold = @(10);
            entity.aifSthreshold = @(200);
            entity.autoSWEnable = @(YES);
            entity.needUpdate = @(YES);
            [weakSelf saveContext];
        }
    }];
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
            if ([NSThread isMainThread])
            {
                if (block)
                {
                    block(retObject, nil);
                }
            }
            else
            {
                NSManagedObjectContext *mContext = self.mainManagedObjectContext;
                [mContext performBlockAndWait:^{
                    if (block)
                    {
                        block(retObject, nil);
                    }
                }];
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
    [context performBlockAndWait:^{
        WEAKSELF;STRONGSELF;
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
            goalObject.utcTime = [strongSelf.dateFormatter dateFromString:utcDateString];
        }
        else
        {
            DailyGoalsEntity *goalObject = [NSEntityDescription insertNewObjectForEntityForName:@"DailyGoalsEntity"
                                                                        inManagedObjectContext:context];
            goalObject.dateTime = utcDateString;
            goalObject.dailyGoals = params[@"goal"];
            goalObject.utcTime = [strongSelf.dateFormatter dateFromString:utcDateString];
        }
        [weakSelf saveContext];
    }];
    
}

- (NSArray*)fetchAllGoals:(BOOL)asynch result:(void(^)(NSArray *ret, NSError *error))block
{
    __block NSArray *retArray = nil;
    NSManagedObjectContext *context = self.backReadManagedObjectContext;
    void (^fetchBlock) (void) = ^{
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"DailyGoalsEntity"
                                                  inManagedObjectContext:context];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"utcTime" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setResultType:NSDictionaryResultType];
        NSError *error = nil;
        retArray = [context executeFetchRequest:fetchRequest error:&error];
        if (error)
        {
            if (block)
            {
                block(nil,error);
            }
        }
        else
        {
            if (block)
            {
                block(retArray,error);
            }
        }
    };
    if (asynch)
    {
        [context performBlock:fetchBlock];
    }
    else
    {
        [context performBlockAndWait:fetchBlock];
    }
    return retArray;
}

- (NSDictionary*)fetchGoal:(BOOL)asynch byDate:(NSDate*)date result:(void(^)(NSDictionary *ret, NSError *error))block
{
    __block NSDictionary *retDic = nil;
    NSManagedObjectContext *context = self.backReadManagedObjectContext;
    void (^fetchBlock) (void) = ^{
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"DailyGoalsEntity"
                                                  inManagedObjectContext:context];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"utcTime" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"utcTime <= %@", date];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setResultType:NSDictionaryResultType];
        [fetchRequest setSortDescriptors:sortDescriptors];
        NSError *error = nil;
        NSArray *fetchArray = [context executeFetchRequest:fetchRequest error:&error];
        DEBUG_METHOD(@"---fetchArray--%@",fetchArray);
        if (!error && fetchArray && fetchArray.count > 0)
        {
            retDic = [fetchArray firstObject];
            if ([NSThread isMainThread])
            {
                if (block)
                {
                    block(retDic,nil);
                }
            }
            else
            {
                NSManagedObjectContext *mContext = self.mainManagedObjectContext;
                [mContext performBlockAndWait:^{
                    if (block)
                    {
                        block(retDic,nil);
                    }
                }];
            }
        }
        else
        {
            if ([NSThread isMainThread])
            {
                if (block)
                {
                    block(nil,error);
                }
            }
            else
            {
                NSManagedObjectContext *mContext = self.mainManagedObjectContext;
                [mContext performBlockAndWait:^{
                    if (block)
                    {
                        block(nil,error);
                    }
                }];
            }
        }
    };
    if (asynch)
    {
        [context performBlock:fetchBlock];
    }
    else
    {
        [context performBlockAndWait:fetchBlock];
    }
    return retDic;
}


- (NSDictionary*)fetchLateLyGoal:(BOOL)asynch result:(void(^)(NSDictionary *ret, NSError *error))block
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
            tmpDic = [fetchArray firstObject];
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
    
    if (asynch)
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
#pragma mark 运动记录统计

- (NSDictionary*)fetchSumOfSportsData:(BOOL)asynch result:(void(^)(NSDictionary *ret, NSError *error))block
{
    __block NSDictionary *retDic = nil;
    NSManagedObjectContext *context = self.backReadManagedObjectContext;
    void (^fetchBlock) (void) = ^{
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"SportsDataEntity"
                                                  inManagedObjectContext:context];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
        [fetchRequest setEntity:entity];
        [fetchRequest setResultType:NSDictionaryResultType];
        [fetchRequest setPropertiesToFetch:@[@"steps",@"distance",@"calorie"]];
        NSError *error = nil;
        NSArray *fetchArray = [context executeFetchRequest:fetchRequest error:&error];
        if (!error && fetchArray && fetchArray.count > 0)
        {
            NSNumber *stepNum = [fetchArray valueForKeyPath:@"@sum.steps"];
            NSNumber *distanceNum = [fetchArray valueForKeyPath:@"@sum.distance"];
            NSNumber *calorieNum = [fetchArray valueForKeyPath:@"@sum.calorie"];
            retDic = @{@"sum.steps":stepNum,@"sum.distance":distanceNum,@"sum.calorie":calorieNum};
            if (block)
            {
                block(retDic,nil);
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
    if (asynch)
    {
        [context performBlock:fetchBlock];
    }
    else
    {
        [context performBlockAndWait:fetchBlock];
    }
    return retDic;
}

- (NSDictionary*)fetchDailySumOfSportsData:(BOOL)asynch byDate:(NSDate*)date result:(void(^)(NSDictionary *ret, NSError *error))block
{
    __block NSDictionary *retDic = nil;
    NSManagedObjectContext *context = self.backReadManagedObjectContext;
    void (^fetchBlock) (void) = ^{
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"SportsDataEntity" inManagedObjectContext:context];
        
        [self.dateFormatter setDateFormat:@"yyyy"];
        NSString *year = [self.dateFormatter stringFromDate:date];
        
        [self.dateFormatter setDateFormat:@"MM"];
        NSString *month = [self.dateFormatter stringFromDate:date];
        
        [self.dateFormatter setDateFormat:@"dd"];
        NSString *day = [self.dateFormatter stringFromDate:date];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"year = %@ AND month = %@ AND day = %@", year,month,day];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setResultType:NSDictionaryResultType];
        NSError *error = nil;
        NSArray *fetchArray = [context executeFetchRequest:fetchRequest error:&error];
        if (!error && fetchArray && fetchArray.count > 0)
        {
            NSNumber *stepNum = [fetchArray valueForKeyPath:@"@sum.steps"];
            NSNumber *distanceNum = [fetchArray valueForKeyPath:@"@sum.distance"];
            NSNumber *calorieNum = [fetchArray valueForKeyPath:@"@sum.calorie"];
            retDic = @{@"sum.steps":stepNum,@"sum.distance":distanceNum,@"sum.calorie":calorieNum};
            if (block)
            {
                block(retDic,nil);
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
    
    if (asynch)
    {
        [context performBlock:fetchBlock];
    }
    else
    {
        [context performBlockAndWait:fetchBlock];
    }
    return retDic;
}

- (NSArray*)fetchDailyRecord:(BOOL)asynch result:(void(^)(NSArray *ret, NSError *error))block
{
    NSManagedObjectContext *context = self.backReadManagedObjectContext;
    __block NSArray *retArray = nil;
    void (^fetchBlock) (void) = ^{
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"SportsDataEntity" inManagedObjectContext:context];
        NSSortDescriptor *yearSortDes = [[NSSortDescriptor alloc] initWithKey:@"year" ascending:NO];
        NSSortDescriptor *monthSortDes = [[NSSortDescriptor alloc] initWithKey:@"month" ascending:NO];
        NSSortDescriptor *daySortDes = [[NSSortDescriptor alloc] initWithKey:@"day" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:yearSortDes,monthSortDes,daySortDes, nil];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
        [fetchRequest setEntity:entity];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setResultType:NSDictionaryResultType];
        [fetchRequest setReturnsDistinctResults:YES];
        [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"year",@"month",@"day",nil]];
        NSError *error = nil;
        NSArray *fetchArray = [context executeFetchRequest:fetchRequest error:&error];
        
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *retDic in fetchArray)
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"year = %@ AND month = %@ AND day = %@", retDic[@"year"],retDic[@"month"],retDic[@"day"]];
            
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:entity];
            [request setPredicate:predicate];
            [request setResultType:NSDictionaryResultType];
            [request setPropertiesToFetch:@[@"steps",@"distance",@"calorie"]];
            NSArray *fetchArray = [context executeFetchRequest:request error:&error];
            if (!error && fetchArray && fetchArray.count > 0)
            {
                NSNumber *stepNum = [fetchArray valueForKeyPath:@"@sum.steps"];
                NSNumber *distanceNum = [fetchArray valueForKeyPath:@"@sum.distance"];
                NSNumber *calorieNum = [fetchArray valueForKeyPath:@"@sum.calorie"];
                NSString *date = [NSString stringWithFormat:@"%@-%@-%@",retDic[@"year"],retDic[@"month"],retDic[@"day"]];
                NSDictionary *dic = @{@"date":date,@"steps":stepNum,@"distance":distanceNum,@"calorie":calorieNum};
                [array addObject:dic];
            }
        }
        retArray = [NSArray arrayWithArray:array];
        if (block)
        {
            block(retArray,nil);
        }
    };
    if (asynch)
    {
        [context performBlock:fetchBlock];
    }
    else
    {
        [context performBlockAndWait:fetchBlock];
    }
    return retArray;
}

- (NSArray*)fetchDailyDetailRecord:(BOOL)asynch result:(void (^)(NSArray *ret, NSError *error))block
{
    __block NSArray *retArray = nil;
    NSManagedObjectContext *context = self.backReadManagedObjectContext;
    void (^fetchBlock) (void) = ^{
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"SportsDataEntity" inManagedObjectContext:context];
        NSSortDescriptor *yearSortDes = [[NSSortDescriptor alloc] initWithKey:@"year" ascending:NO];
        NSSortDescriptor *monthSortDes = [[NSSortDescriptor alloc] initWithKey:@"month" ascending:NO];
        NSSortDescriptor *daySortDes = [[NSSortDescriptor alloc] initWithKey:@"day" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:yearSortDes,monthSortDes,daySortDes, nil];
        
        // 查询有多少天的记录
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
        [fetchRequest setEntity:entity];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setResultType:NSDictionaryResultType];
        [fetchRequest setReturnsDistinctResults:YES];
        [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"year",@"month",@"day",nil]];
        
        NSError *error = nil;
        NSArray *fetchArray = [context executeFetchRequest:fetchRequest error:&error];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entity];
        [request setResultType:NSDictionaryResultType];
        
        NSMutableArray *dailyRecordsArray = [NSMutableArray array];
        for (NSDictionary *retDic in fetchArray)
        {
            // 对于每天的记录，每15分钟统计一条数据
            NSString *dateString = [NSString stringWithFormat:@"%@-%@-%@ 00:00:00",retDic[@"year"],retDic[@"month"],retDic[@"day"]];
            [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *date = [self.dateFormatter dateFromString:dateString];
            NSTimeInterval timeStamp = [date timeIntervalSince1970];
            // 从0点开始每隔15分钟查询一次记录
            NSMutableArray *array = [NSMutableArray array];
            for (int i = 1; i <= 96 ; i++)
            {
                NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:timeStamp+(i-1)*900];
                NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:timeStamp+i*900];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"utcTime >= %@ AND utcTime < %@",startDate,endDate];
                [request setPredicate:predicate];
                NSError *err = nil;
                NSArray *tmpArray = [context executeFetchRequest:request error:&err];
                if (!err && fetchArray && fetchArray.count > 0)
                {
                    NSNumber *stepNum = [tmpArray valueForKeyPath:@"@sum.steps"];
                    NSNumber *calorieNum = [tmpArray valueForKeyPath:@"@sum.calorie"];
                    NSDictionary *dic = @{@"steps":stepNum,@"calorie":calorieNum};
                    [array addObject:dic];
                }
                else
                {
                    [array addObject:[NSNull null]];
                }
            }
            NSString *string = [NSString stringWithFormat:@"%@-%@-%@",retDic[@"year"],retDic[@"month"],retDic[@"day"]];
            NSDictionary *dic = @{@"date":string,@"value":array};
            [dailyRecordsArray addObject:dic];
        }
        // 切换到主线程回调
        retArray = [NSArray arrayWithArray:dailyRecordsArray];
        if ([NSThread isMainThread])
        {
            if (block)
            {
                block(retArray,error);
            }
        }
        else
        {
            NSManagedObjectContext *mContext = self.mainManagedObjectContext;
            [mContext performBlockAndWait:^{
                if (block)
                {
                    block(retArray,error);
                }
            }];
        }
    };
    
    if (asynch)
    {
        [context performBlock:fetchBlock];
    }
    else
    {
        [context performBlockAndWait:fetchBlock];
    }
    return retArray;
}


#pragma mark -
#pragma mark 睡眠记录查询

// 比较开始时间是否早于结束时间
- (BOOL)stTime:(NSString*)stTime isEarlier:(NSString*)spTime
{
    [self.dateFormatter setDateFormat:@"HH:mm:ss"];
    NSDate *stDate = [self.dateFormatter dateFromString:stTime];
    NSDate *spDate = [self.dateFormatter dateFromString:spTime];
    NSTimeInterval stTI = [stDate timeIntervalSince1970];
    NSTimeInterval spTI = [spDate timeIntervalSince1970];
    if (stTI < spTI)
    {
        return YES;
    }
    return NO;
}


- (NSArray*)fetchDaliySleepData:(BOOL)asynch stTime:(NSString*)stTime spTime:(NSString*)spTime result:(void (^)(NSArray *ret, NSError *error))block
{
    __block NSArray *retArray = nil;
    if (stTime == nil || spTime == nil)
    {
        if (block)
        {
            block(nil,nil);
        }
        return retArray;
    }
    NSManagedObjectContext *context = self.backReadManagedObjectContext;
    void (^fetchBlock) (void) = ^{
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"SleepDataEntity" inManagedObjectContext:context];
        NSSortDescriptor *yearSortDes = [[NSSortDescriptor alloc] initWithKey:@"year" ascending:NO];
        NSSortDescriptor *monthSortDes = [[NSSortDescriptor alloc] initWithKey:@"month" ascending:NO];
        NSSortDescriptor *daySortDes = [[NSSortDescriptor alloc] initWithKey:@"day" ascending:NO];
        
        // 查询有多少天的记录
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
        [fetchRequest setEntity:entity];
        [fetchRequest setSortDescriptors:@[yearSortDes,monthSortDes,daySortDes]];
        [fetchRequest setResultType:NSDictionaryResultType];
        [fetchRequest setReturnsDistinctResults:YES];
        [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"year",@"month",@"day",nil]];
        NSError *error = nil;
        NSArray *fetchArray = [context executeFetchRequest:fetchRequest error:&error];
        
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entity];
        [request setResultType:NSDictionaryResultType];
        [request setReturnsDistinctResults:YES];
        NSSortDescriptor *utcSort = [[NSSortDescriptor alloc] initWithKey:@"utcTime" ascending:YES];
        [request setSortDescriptors:@[utcSort]];

        NSMutableArray *tmpRetArray = [NSMutableArray array];
        for (NSDictionary *dateDic in fetchArray)
        {
            NSString *year = dateDic[@"year"];
            NSString *month = dateDic[@"month"];
            NSString *day = dateDic[@"day"];
            
            NSString *date = [NSString stringWithFormat:@"%@-%@-%@",year,month,day];
            // 开始日期
            [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *stDateStr = [NSString stringWithFormat:@"%@ %@",date,stTime];
            NSDate *stDate = [self.dateFormatter dateFromString:stDateStr];
            NSTimeInterval sttime = [stDate timeIntervalSince1970];
            // 结束日期
            [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *spDateStr = [NSString stringWithFormat:@"%@ %@",date,spTime];
            NSDate *spDate = [self.dateFormatter dateFromString:spDateStr];
            if (![self stTime:stTime isEarlier:spTime])
            {
                spDate = [NSDate dateWithTimeInterval:24*60*60 sinceDate:spDate];
            }
            NSTimeInterval sptime = [spDate timeIntervalSince1970];
            
            // 查询梅每天入睡时间到第二天起床时间的所有记录
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"utcTime > %@ AND utcTime < %@",[NSDate dateWithTimeIntervalSince1970:sttime],[NSDate dateWithTimeIntervalSince1970:sptime]];
            [request setPredicate:predicate];
            
            NSArray *array = [context executeFetchRequest:request error:&error];
            NSArray *deepSleepArray = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"sleepData < %d",1]];
            NSArray *lightSleepArray = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"sleepData >= %d",1]];
            NSDictionary *dic = @{@"deepSleep":@(deepSleepArray.count*300),@"lightSleep":@(lightSleepArray.count*300),
                                  @"totalTime":@(sttime-sptime),@"date":date,@"records":array};
            [tmpRetArray addObject:dic];
        }// for
        
        retArray = [NSArray arrayWithArray:tmpRetArray];
        if ([NSThread isMainThread])
        {
            if (block)
            {
                block(retArray,nil);
            }
        }
        else
        {
            NSManagedObjectContext *mContext = self.mainManagedObjectContext;
            [mContext performBlockAndWait:^{
                if (block)
                {
                    block(retArray,error);
                }
            }];
        }
    };
    
    if (asynch)
    {
        [context performBlock:fetchBlock];
    }
    else
    {
        [context performBlockAndWait:fetchBlock];
    }
    return retArray;
}

#pragma mark -
#pragma mark 插入运动记录和睡眠记录

- (void)insertNewSleepData:(NSMutableArray*)dataArray
{
    if (dataArray == nil || dataArray.count <= 0)
    {
        return;
    }
    CSSleepDataOperation *operation = [[CSSleepDataOperation alloc]initWithNewData:dataArray];
    [self.operationQueue addOperation:operation];
}

- (void)insertNewSportData:(NSMutableArray*)dataArray
{
    if (dataArray == nil || dataArray.count <= 0)
    {
        return;
    }
    CSSportsDataOperation *operation = [[CSSportsDataOperation alloc]initWithNewData:dataArray];
    [self.operationQueue addOperation:operation];
}
@end
