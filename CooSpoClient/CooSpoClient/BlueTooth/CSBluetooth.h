//
//  CSBluetooth.h
//  CooSpoClient
//
//  Created by 马远征 on 14-10-16.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "CSBluetoothSDK.h"
#import "CSCoreData.h"

@interface CSBluetooth : CSBluetoothSDK
@property (nonatomic, copy) dispatch_block_t completeBlock;
- (void)initialize;
- (void)completeTransmission:(dispatch_block_t)block;
@end
