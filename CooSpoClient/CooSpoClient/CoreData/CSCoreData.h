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
#import "DailyGoalsEntity.h"
#import "SleepDataEntity.h"
#import "SportsDataEntity.h"
#import "CSSportsDataOperation.h"
#import "CSSleepDataOperation.h"

@interface CSCoreData : CSCoreDataBaseClass
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

- (void)initializeDefaultParams;

// 用户资料管理
- (void)insertOrUpdateUserInfo:(NSDictionary *)params;
- (NSDictionary*)fetchUserInfo:(BOOL)asynchQuery result:(void(^)(NSDictionary *ret, NSError *error))block;

// 睡眠参数管理
- (void)insertOrUpdateSwParams:(NSDictionary *)params;
- (NSDictionary*)fetchSwParams:(BOOL)asynchQuery result:(void(^)(NSDictionary *ret, NSError *error))block;


// 每日目标设定管理
- (void)insertOrUpdateTGoal:(NSDictionary*)params;
- (NSArray*)fetchAllGoals:(BOOL)asynch result:(void(^)(NSArray *ret, NSError *error))block;
- (NSDictionary*)fetchLateLyGoal:(BOOL)asynch result:(void(^)(NSDictionary *ret, NSError *error))block;
- (NSDictionary*)fetchGoal:(BOOL)asynch byDate:(NSDate*)date result:(void(^)(NSDictionary *ret, NSError *error))block;

- (NSDictionary*)fetchSumOfSportsData:(BOOL)asynch result:(void(^)(NSDictionary *ret, NSError *error))block;
- (NSArray*)fetchDailyRecord:(BOOL)asynch result:(void(^)(NSArray *ret, NSError *error))block;
- (NSDictionary*)fetchDailySumOfSportsData:(BOOL)asynch byDate:(NSDate*)date result:(void(^)(NSDictionary *ret, NSError *error))block;

// 查询一天的每15分钟的详细记录
- (NSArray*)fetchDailyDetailRecord:(BOOL)asynch result:(void (^)(NSArray *ret, NSError *error))block;

// 查询每日睡眠统计记录

- (NSArray*)fetchDaliySleepData:(BOOL)asynch stTime:(NSString*)stTime spTime:(NSString*)spTime result:(void (^)(NSArray *ret, NSError *error))block;

// 运动记录管理
- (void)insertNewSleepData:(NSMutableArray*)dataArray;
- (void)insertNewSportData:(NSMutableArray*)dataArray;
@end
