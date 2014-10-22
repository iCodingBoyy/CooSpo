//
//  CSCoreData.h
//  CooSpoClient
//
//  Created by 马远征 on 14-10-16.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "CSCoreDataBaseClass.h"
#import "UserInfoEntity.h"
#import "SwParamsEntity.h"
#import "RecentSynchEntity.h"
#import "DailyGoalsEntity.h"
#import "SleepDataEntity.h"
#import "SynchDataEntity.h"
#import "SportsDataEntity.h"
#import "CSSportsDataOperation.h"
#import "CSSleepDataOperation.h"

@interface CSCoreData : CSCoreDataBaseClass
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

- (void)initializeDefaultParams;
// 最后同步记录
- (void)insertOrUpdateLastSynchRecord:(NSDictionary*)params;
- (NSDictionary*)fetchLastSynchRecord:(BOOL)asynchQuery result:(void(^)(NSDictionary *ret, NSError *error))block;


// 用户资料管理
- (void)insertOrUpdateUserInfo:(NSDictionary *)params;
- (NSDictionary*)fetchUserInfo:(BOOL)asynchQuery result:(void(^)(NSDictionary *ret, NSError *error))block;

// 睡眠参数管理
- (void)insertOrUpdateSwParams:(NSDictionary *)params;
- (NSDictionary*)fetchSwParams:(BOOL)asynchQuery result:(void(^)(NSDictionary *ret, NSError *error))block;


// 每日目标设定管理
- (void)insertOrUpdateTGoal:(NSDictionary*)params;
- (NSDictionary*)fetchLastGoal:(BOOL)asynchFetch result:(void(^)(NSDictionary *ret, NSError *error))block;
- (NSArray*)fetchTGoal:(BOOL)asynchFetch result:(void(^)(NSArray *ret, NSError *error))block;

// 每日记录管理
- (void)insertOrUpdateDailySynchRecord:(NSDictionary *)params;
- (NSDictionary*)fetchTotalRecords:(BOOL)asynchQuery result:(void(^)(NSDictionary *ret, NSError *error))block;
- (NSDictionary*)fetchSynchRecord:(BOOL)asynchQuery byDate:(NSDate*)date result:(void (^)(NSDictionary *ret, NSError *error))block;

// 运动记录管理
- (void)insertNewSportData:(NSData*)data utcTime:(UInt32)utcTime;
- (void)insertNewSleepData:(NSData*)data utcTime:(UInt32)utcTime;
@end
