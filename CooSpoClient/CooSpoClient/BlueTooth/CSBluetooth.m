//
//  CSBluetooth.m
//  CooSpoClient
//
//  Created by 马远征 on 14-10-16.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "CSBluetooth.h"
#import "CooSpoDefine.h"

@implementation CSBluetooth

- (void)didReceiveSynchData:(UInt32)steps distance:(UInt32)distance calorie:(UInt32)calorie utcTime:(UInt32)utcTime
{
    [super didReceiveSynchData:steps distance:distance calorie:calorie utcTime:utcTime];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSDictionary *retdic = [[CSCoreData shared]fetchLastGoal:NO result:nil];
        NSLog(@"----retdic--%@",retdic);
        
        NSUInteger goals = (retdic == nil) ? 100000:[retdic[@"goal"]unsignedIntegerValue];
        BOOL complete = (steps >= goals ? YES:NO);
        
        NSDictionary *params = @{@"steps":@(steps),@"distance":@(distance),@"calorie":@(calorie),@"utcTime":@(utcTime),@"complete":@(complete)};
        
        [[CSCoreData shared]insertOrUpdateDailySynchRecord:params];
        [[CSCoreData shared]insertOrUpdateLastSynchRecord:params];
        
        // 通知UI更新部分数据
    });
}

- (void)didReceiveSportsData:(NSData *)sportsData utcTime:(UInt32)utcTime
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[CSCoreData shared]insertNewSportData:sportsData utcTime:utcTime];
    });
}

- (void)didReceiveSleepData:(NSData *)sleepData utcTime:(UInt32)utcTime
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[CSCoreData shared]insertNewSleepData:sleepData utcTime:utcTime];
    });
}

- (void)didReceiveUserInfo:(NSMutableDictionary *)params
{
    [super didReceiveUserInfo:params];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[CSCoreData shared]insertOrUpdateUserInfo:params];
    });
}

- (BOOL)shouldSynchUpdateUTCTime
{
    return YES;
}

- (NSDictionary*)subClassFetchUserInfo
{
    DEBUG_METHOD(@"---subClassFetchUserInfo--%@",[NSThread currentThread]);
    return [[CSCoreData shared]fetchUserInfo:NO result:nil];
}


- (NSDictionary*)subClassFetchSWParams
{
    DEBUG_METHOD(@"---subClassFetchSWParams--%@",[NSThread currentThread]);
    return [[CSCoreData shared]fetchSwParams:NO result:nil];
}

- (void)didSuccessUpdateSWParams
{
    DEBUG_METHOD(@"---didSuccessUpdateSWParams--%@",[NSThread currentThread]);
    [[CSCoreData shared]insertOrUpdateSwParams:@{@"needUpdate":@(NO)}];
}

- (void)completeTransmission:(dispatch_block_t)block
{
    _completeBlock = block;
}

- (void)initialize
{
    [[CSCoreData shared]initializeDefaultParams];
}

- (void)didCompleteBluetoothDataTransmission
{
    DEBUG_METHOD(@"---%s--",__FUNCTION__);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_completeBlock)
        {
            _completeBlock();
        }
    });
}

@end
