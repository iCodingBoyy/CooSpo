//
//  CSBluetooth.m
//  CooSpoClient
//
//  Created by 马远征 on 14-10-16.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "CSBluetooth.h"


@implementation CSBluetooth

- (void)didReceiveSynchData:(UInt32)steps distance:(UInt32)distance calorie:(UInt32)calorie utcTime:(UInt32)utcTime
{
    DEBUG_METHOD(@"-----{\n steps:%u \n distance:%u \n calorie:%u \n }",(unsigned int)steps,(unsigned int)distance,(unsigned int)calorie);
    dispatch_async(dispatch_get_main_queue(), ^{
        // 存储最后同步时间
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setValue:@(utcTime) forKey:@"lastSynch.utcTime"];
        [userDefaults synchronize];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"Event_LastSynch_Time_Update_Notify" object:nil];
    });
}

- (void)didReceiveSportsPackage:(NSMutableArray*)dataArray
{
    [[CSCoreData shared]insertNewSportData:dataArray];
}

- (void)didReceiveSleepPackage:(NSMutableArray*)dataArray
{
    [[CSCoreData shared]insertNewSleepData:dataArray];
}

- (void)didReceiveUserInfo:(NSMutableDictionary *)params
{
    DEBUG_METHOD(@"----%s---[%@]",__FUNCTION__,params);
    [[CSCoreData shared]insertOrUpdateUserInfo:params];
}

- (BOOL)shouldSynchUpdateUTCTime
{
    return YES;
}

- (NSDictionary*)subClassFetchUserInfo
{
    return [[CSCoreData shared]fetchUserInfo:NO result:nil];
}


- (NSDictionary*)subClassFetchSWParams
{
    return [[CSCoreData shared]fetchSwParams:NO result:nil];
}

- (void)didSuccessUpdateSWParams
{
    [[CSCoreData shared]insertOrUpdateSwParams:@{@"needUpdate":@(NO)}];
}



- (void)initialize
{
    [[CSCoreData shared]initializeDefaultParams];
}

- (void)completeTransmission:(dispatch_block_t)block
{
    _completeBlock = block;
}

- (void)didCompleteBluetoothDataTransmission
{
    if (_completeBlock)
    {
        _completeBlock();
    }
}

@end
