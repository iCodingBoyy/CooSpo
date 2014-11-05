//
//  CSBluetoothSDK.h
//  CSBluetoothSDK
//
//  Created by 马远征 on 14-10-16.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


typedef NS_ENUM(NSInteger, BluetoothStatus)
{
    BluetoothStatusNoOperate = 0,
    BluetoothStatusSearching,
    BluetoothStatusFoundPeripheral,
    BluetoothStatusConnectOk,
    BluetoothStatusConnectFailed,
    BluetoothStatusTransferring,
    BluetoothStatusCompleteTransfer,
    BluetoothStatusDisConnect,
};

typedef void (^BluetoothStatusBlock)(BluetoothStatus status);

@interface CSBluetoothSDK : NSObject
+ (id)shared;
- (void)startScaning:(BluetoothStatusBlock)block;
- (void)didReceiveSynchData:(UInt32)steps distance:(UInt32)distance calorie:(UInt32)calorie utcTime:(UInt32)utcTime;
- (void)didReceiveUserInfo:(NSMutableDictionary*)params;
- (BOOL)shouldSynchUpdateUTCTime;
- (NSDictionary*)subClassFetchSWParams;
- (NSDictionary*)subClassFetchUserInfo;
- (void)didSuccessUpdateSWParams;
- (void)didCompleteBluetoothDataTransmission;

- (void)didReceiveSportsPackage:(NSMutableArray*)dataArray;
- (void)didReceiveSleepPackage:(NSMutableArray*)dataArray;
@end
