//
//  CSBluetoothSDK.m
//  CSBluetoothSDK
//
//  Created by 马远征 on 14-10-16.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "CSBluetoothSDK.h"

#ifdef DEBUG
#   define DEBUG_STR(...) NSLog(__VA_ARGS__);
#   define DEBUG_METHOD(format, ...) NSLog(format, ##__VA_ARGS__);
#else
#   define DEBUG_STR(...)
#   define DEBUG_METHOD(format, ...)
#endif

#define WEAKSELF __weak typeof(self)  weakSelf = self;
#define STRONGSELF __strong typeof(self)  strongSelf = weakSelf;


// 蓝牙手环特征值
static NSString * const kServiceUUID = @"FC00";
static NSString * const kReadCharacteristicUUID = @"FC20";
static NSString * const kWriteCharacteristicUUID = @"FC21";

@interface CSBluetoothSDK() <CBCentralManagerDelegate,CBPeripheralDelegate>
@property (nonatomic) CBCharacteristic *writeCharacteristic;
@property (nonatomic) dispatch_queue_t operationQueue;
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *servicePeripheral;
@property (nonatomic, assign) BOOL isBluetoothEnable;
@property (nonatomic, assign) UInt32 sportsDataUtcTime;
@property (nonatomic, assign) UInt32 sleepDataUtcTime;

@property (nonatomic, copy) BluetoothStatusBlock bleSBlock;
@end

@implementation CSBluetoothSDK
+ (id)shared
{
    static dispatch_once_t pred;
    static CSBluetoothSDK *sharedinstance = nil;
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
        NSString *queueName = NSStringFromClass([self class]);
        _operationQueue = dispatch_queue_create([queueName UTF8String], NULL);
        _centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:_operationQueue];
    }
    return self;
}

- (void)updateBleStatus:(BluetoothStatus)status
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_bleSBlock)
        {
            _bleSBlock(status);
        }
    });
}


#pragma mark -
#pragma mark 扫描设备/停止扫描

- (void)startScaning:(BluetoothStatusBlock)block
{
    if (_servicePeripheral && [_servicePeripheral isConnected] )
    {
        return;
    }
    _bleSBlock = block;
    [self updateBleStatus:BluetoothStatusSearching];
    [_centralManager scanForPeripheralsWithServices:@[] options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
}

- (void)startScaning
{
    [self updateBleStatus:BluetoothStatusSearching];
    [_centralManager scanForPeripheralsWithServices:@[] options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
}

- (void) stopScanning
{
    [_centralManager stopScan];
}

#pragma mark -
#pragma mark CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    // 蓝牙设备状态更新回调
    if (central.state == CBCentralManagerStateUnknown)
    {
        DEBUG_STR(@" 初始的时候是未知的（刚刚创建的时候）");
    }
    
    if (central.state == CBCentralManagerStateResetting)
    {
        DEBUG_STR(@"蓝牙设备重置状态");
    }
    
    if (central.state == CBCentralManagerStateUnsupported)
    {
        DEBUG_STR(@"设备不支持的状态");
    }
    
    if (central.state == CBCentralManagerStateUnauthorized)
    {
        DEBUG_STR(@"设备未授权状态");
    }
    if (central.state == CBCentralManagerStatePoweredOff)
    {
        DEBUG_STR(@"设备关闭状态");
        [self stopScanning];
    }
    if (central.state == CBCentralManagerStatePoweredOn)
    {
        DEBUG_STR(@"蓝牙设备可以使用");
        [self startScaning];
        _isBluetoothEnable = YES;
    }
    else
    {
        _isBluetoothEnable = NO;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
#ifdef DEBUG
    NSString *UUID1 = CFBridgingRelease(CFUUIDCreateString(NULL, peripheral.UUID));
    DEBUG_METHOD(@"----发现外设----%@",UUID1);
#endif
    
    if ( _servicePeripheral != peripheral && [peripheral.name isEqualToString:@"Oone"] )
    {
        _servicePeripheral = peripheral;
        DEBUG_METHOD(@"Connecting to peripheral %@", peripheral);
        [self updateBleStatus:BluetoothStatusFoundPeripheral];
        [_centralManager connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    DEBUG_STR(@"----成功连接外设----");
    [self updateBleStatus:BluetoothStatusConnectOk];
    // 停止扫描
    [self stopScanning];
    [_servicePeripheral setDelegate:self];
    [_servicePeripheral discoverServices:@[ [CBUUID UUIDWithString:kServiceUUID]]];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    DEBUG_STR(@"----连接外设失败----Error:%@",error);
    [self updateBleStatus:BluetoothStatusConnectFailed];
    [self cleanup];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    DEBUG_STR(@"-----外设断开连接------%@",error);
    _servicePeripheral = nil;
    [self updateBleStatus:BluetoothStatusDisConnect];
    [self cleanup];
}

#pragma mark -
#pragma mark CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error
{
    if (error)
    {
        DEBUG_METHOD(@"Error discovering service: %@", [error localizedDescription]);
        [self cleanup];
        return;
    }
    
    for (CBService *service in aPeripheral.services)
    {
        DEBUG_METHOD(@"Service found with UUID: %@", service.UUID);
        if ([service.UUID isEqual:[CBUUID UUIDWithString:kServiceUUID]])
        {
            [_servicePeripheral discoverCharacteristics:@[[CBUUID UUIDWithString:kReadCharacteristicUUID],
                                                          [CBUUID UUIDWithString:kWriteCharacteristicUUID]]
                                             forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
        DEBUG_METHOD(@"Error discovering characteristic: %@", [error localizedDescription]);
        return;
    }
    
    if ([service.UUID isEqual:[CBUUID UUIDWithString:kServiceUUID]])
    {
        for (CBCharacteristic *characteristic in service.characteristics)
        {
            DEBUG_METHOD(@"----didDiscoverCharacteristicsForService---%@",characteristic);
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kReadCharacteristicUUID]])
            {
                [peripheral readValueForCharacteristic:characteristic];
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            }
            
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kWriteCharacteristicUUID]])
            {
                _writeCharacteristic = characteristic;
            }
        }
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        DEBUG_METHOD(@"Error changing notification state: %@", error.localizedDescription);
    }
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kReadCharacteristicUUID]] )
    {
        if (characteristic.isNotifying)
        {
            DEBUG_METHOD(@"Notification began on %@", characteristic);
            [peripheral readValueForCharacteristic:characteristic];
        }
        else
        {
            DEBUG_METHOD(@"Notification stopped on %@.  Disconnecting", characteristic);
            [_centralManager cancelPeripheralConnection:_servicePeripheral];
            DEBUG_METHOD(@"------重新启动扫描---");
            [self updateBleStatus:BluetoothStatusSearching];
            [_centralManager scanForPeripheralsWithServices:@[] options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
        }
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    [self updateBleStatus:BluetoothStatusTransferring];
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kReadCharacteristicUUID]])
    {
        Byte cValue[100] = {0};
        NSData *data = characteristic.value;
        [data getBytes:&cValue length:data.length];
        
        Byte highByte = ((cValue[0] & 0xf0) >> 4);
        
        /* Packet for inquire user info*/
        if( (cValue[0] & 0x0f) == 0x01 )
        {
            DEBUG_METHOD(@"--0xd1--Packet for inquire user info---");
            if ( ![self resultOfCheckSum:cValue length:data.length] )
            {
                DEBUG_METHOD(@"----【%s】-0xd1-检验和出错----",__FUNCTION__);
                [self writeResponseWithperipheral:peripheral sequenceNum:highByte ackByte:0x01];
            }
            else
            {
                // 同步更新睡眠参数
                NSDictionary *swParams = [self subClassFetchSWParams];
                if (swParams && [swParams[@"needUpdate"]boolValue])
                {
                    DEBUG_METHOD(@"-----更新睡眠参数信息---");
                    Byte ackValue[9] = {0};
                    ackValue[0] = 0xe3;
                    ackValue[1] = [swParams[@"autoSWEnable"]intValue];
                    ackValue[2] = [swParams[@"stHour"]intValue];
                    ackValue[3] = [swParams[@"stMininute"]intValue];
                    ackValue[4] = [swParams[@"spHour"]intValue];
                    ackValue[5] = [swParams[@"spMininute"]intValue];
                    ackValue[6] = [swParams[@"nmSthreshold"]intValue];
                    ackValue[7] = [swParams[@"aifSthreshold"]intValue];
                    ackValue[8] = ackValue[0]+ackValue[1]+ackValue[2]+ackValue[3]+ackValue[4]+ackValue[5]+ackValue[6]+ackValue[7];
                    [self didSuccessUpdateSWParams];
                    NSData *data = [NSData dataWithBytes:&ackValue length:sizeof(ackValue)];
                    [peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
                    return;
                }
                
                int weight = (cValue[7] << 8)  + cValue[8];
                int age = cValue[9];
                int height = cValue[10];
                int stride = cValue[11];
                int sex = cValue[12];
                int target = (cValue[13]<<16)  + (cValue[14]<<8) + cValue[15];
                NSDictionary *userInfoParams = [self subClassFetchUserInfo];
                if (userInfoParams == nil)
                {
                    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                    [userInfo setObject:@(weight) forKey:@"weight"];
                    [userInfo setObject:@(age)    forKey:@"age"];
                    [userInfo setObject:@(height) forKey:@"height"];
                    [userInfo setObject:@(stride) forKey:@"stride"];
                    [userInfo setObject:@(sex)    forKey:@"sex"];
                    [userInfo setObject:@(target) forKey:@"target"];
                    [self didReceiveUserInfo:userInfo];
                    [self writeResponseWithperipheral:peripheral sequenceNum:highByte ackByte:0x00];
                }
                else
                {
                    int nAge = [userInfoParams[@"age"] intValue];
                    int nSex = [userInfoParams[@"sex"] intValue];
                    int nHeight = [userInfoParams[@"height"] intValue];
                    int nStride = [userInfoParams[@"stride"] intValue];
                    int nWeight = [userInfoParams[@"weight"] intValue];
                    int ntarget = [userInfoParams[@"target"] intValue];
                    if (nWeight == weight && nHeight == height && nStride == stride && nSex == sex && ntarget == target && nAge == age)
                    {
                        [self writeResponseWithperipheral:peripheral sequenceNum:highByte ackByte:0x00];
                    }
                    else
                    {
                        DEBUG_METHOD(@"-----同步更新用户信息----");
                        Byte ackValue[12] = {0};
                        ackValue[0] = 0xe1;
                        ackValue[1] = highByte;
                        ackValue[2] = (nWeight >> 8) & 0xFF; ackValue[3] = nWeight & 0xFF;
                        ackValue[4] = nAge;
                        ackValue[5] = nHeight;
                        ackValue[6] = nStride;
                        ackValue[7] = nSex;
                        ackValue[8] = (ntarget >> 16) & 0xFF;ackValue[9] = (ntarget >> 8) & 0xFF; ackValue[10] = ntarget & 0xFF;
                        ackValue[11] = (ackValue[0] + ackValue[1] + ackValue[2] + ackValue[3] + ackValue[4] + ackValue[5] +ackValue[6] + ackValue[7] + ackValue[8] + ackValue[9] + ackValue[10]) & 0xFF;
                        
                        NSData *data = [NSData dataWithBytes:&ackValue length:sizeof(ackValue)];
                        [peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
                    }
                }
            }
        }
        
        /* Packet for asking or UTC sync*/
        if( (cValue[0] & 0x0f) == 0x02 )
        {
            DEBUG_METHOD(@"--0xd2--Packet for asking or UTC sync----");
            if ( ![self resultOfCheckSum:cValue length:data.length] )
            {
                DEBUG_METHOD(@"----【%s】-0xd2-检验和出错----",__FUNCTION__);
                [self writeResponseWithperipheral:peripheral sequenceNum:highByte ackByte:0x01];
            }
            else
            {
                if ([self shouldSynchUpdateUTCTime])
                {
                    // 更新UTC时间
                    NSTimeZone *zone = [NSTimeZone systemTimeZone];
                    NSInteger interval = [zone secondsFromGMTForDate:[NSDate date]];
                    NSDate *localeDate = [[NSDate date]  dateByAddingTimeInterval: interval];
                    NSTimeInterval timeStamp = [localeDate timeIntervalSince1970];
                    UInt32 dTime = (UInt32)timeStamp;
                    
                    Byte ACKValue[7] = {0};
                    ACKValue[0] = 0xe2;
                    ACKValue[1] = highByte;
                    ACKValue[2] = (dTime >> 24) & 0xFF;
                    ACKValue[3] = (dTime >> 16) & 0xFF;
                    ACKValue[4] = (dTime >> 8) & 0XFF;
                    ACKValue[5] = dTime & 0xFF;
                    ACKValue[6] = (ACKValue[0] + ACKValue[1] + ACKValue[2] + ACKValue[3] + ACKValue[4] + ACKValue[5]) & 0xFF;
                    NSData *data = [NSData dataWithBytes:&ACKValue length:sizeof(ACKValue)];
                    [peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
                }
                else
                {
                    [self writeResponseWithperipheral:peripheral sequenceNum:highByte ackByte:0x00];
                }
            }
        }
        
        /*Packet for uploading time and date last sync and total steps and calories since
         last sync.*/
        if ( (cValue[0] & 0x0f) == 0x03)
        {
            DEBUG_METHOD(@"--0xd3--Packet for asking or UTC sync----");
            if ( ![self resultOfCheckSum:cValue length:data.length])
            {
                DEBUG_STR(@"----【%s】-0xd3-检验和出错----",__FUNCTION__);
                [self writeResponseWithperipheral:peripheral sequenceNum:highByte ackByte:0x01];
            }
            else
            {
                UInt32 UTCTime = (cValue[1]<<24) + (cValue[2]<<16) + (cValue[3]<<8) + cValue[4];
                UInt32 steps = (cValue[5]<<16) + (cValue[6]<<8) + cValue[7];
                UInt32 distance = (cValue[8]<<16) +(cValue[9]<<8) + cValue[10];
                UInt32 calorie = (cValue[11]<<16) + (cValue[12]<<8) + cValue[13];
                
                DEBUG_METHOD(@"------UTC时间---%lu",(unsigned long)UTCTime);
                [self didReceiveSynchData:steps distance:distance calorie:calorie utcTime:UTCTime];
                [self writeResponseWithperipheral:peripheral sequenceNum:highByte ackByte:0x00];
            }
        }
        
        /* Packets for every 15 min(maximun)*/
        if( (cValue[0] & 0x0f) == 0x04 )
        {
            DEBUG_METHOD(@"--0xd4--Packets for every 15 min(maximun)----%@",characteristic.value);
            if ( ![self resultOfCheckSum:cValue length:data.length] )
            {
                DEBUG_STR(@"----【%s】-0xd4-检验和出错----",__FUNCTION__);
                [self writeResponseWithperipheral:peripheral sequenceNum:highByte ackByte:0x01];
            }
            else
            {
                if (cValue[1] == 0x03)
                {
                    [self writeResponseWithperipheral:peripheral sequenceNum:highByte ackByte:0x00];
                }
                
                if (cValue[1] == 0x01 || cValue[1] == 0x02)
                {
                    if ( cValue[1] == 0x01 )
                    {
                        _sportsDataUtcTime =  (cValue[2]<<24) + (cValue[3]<<16) + (cValue[4]<<8) + cValue[5];
                    }
                    
                    if ( cValue[1] == 0x02 )
                    {
                        _sportsDataUtcTime += 6*60;
                    }
                    [self didReceiveSportsData:characteristic.value utcTime:_sportsDataUtcTime];
                }
            }
        }
        
        /* Packet for sleeping data*/
        if( (cValue[0] & 0x0f) == 0x05 )
        {
            DEBUG_METHOD(@"--0xd5---Packet for sleeping data----");
            if ( ![self resultOfCheckSum:cValue length:data.length])
            {
                DEBUG_STR(@"----【%s】-0xd5-检验和出错----",__FUNCTION__);
                [self writeResponseWithperipheral:peripheral sequenceNum:highByte ackByte:0x01];
            }
            else
            {
                if (cValue[1] == 0x03)
                {
                    [self writeResponseWithperipheral:peripheral sequenceNum:highByte ackByte:0x00];
                }
                
                if (cValue[1] == 0x01 || cValue[1] == 0x02 )
                {
                    if ( cValue[1] == 0x01)
                    {
                        _sleepDataUtcTime =  (cValue[2]<<24) + (cValue[3]<<16) + (cValue[4]<<8) + cValue[5];
                    }
                    
                    if ( cValue[1] == 0x02 )
                    {
                        _sleepDataUtcTime += 13*5*60;
                    }
                    [self didReceiveSleepData:characteristic.value utcTime:_sleepDataUtcTime];
                }
            }
        }
        
        /* Transfer Complete,the iphone app can disconnect from bracelet*/
        if( (cValue[0] & 0x0f) == 0x06 )
        {
            DEBUG_METHOD(@"--0xd6---Transfer Complete,the iphone app can disconnect from bracelet----");
            if ( [self resultOfCheckSum:cValue length:data.length])
            {
                [self writeResponseWithperipheral:peripheral sequenceNum:highByte ackByte:0x00];
            }
            else
            {
                [self writeResponseWithperipheral:peripheral sequenceNum:highByte ackByte:0x01];
            }
            
            [self updateBleStatus:BluetoothStatusCompleteTransfer];
            [self didCompleteBluetoothDataTransmission];
            [self cleanup];
        }//if
    }
}


- (BOOL)resultOfCheckSum:(Byte*)receiveBytes length:(NSUInteger)length
{
    unsigned long checkSum = 0;
    for (int i = 0; i < length-1; i++)
    {
        checkSum += receiveBytes[i];
    }
    
    if ((checkSum & 0xFF) == receiveBytes[length-1])
    {
        return YES;
    }
    return NO;
}

- (void)writeResponseWithperipheral:(CBPeripheral *)peripheral sequenceNum:(Byte)snByte ackByte:(Byte)ackByte
{
    if (_writeCharacteristic && peripheral)
    {
        Byte ACkValue[4] = {0};
        ACkValue[0] = 0xe0; ACkValue[1] = snByte; ACkValue[2] = ackByte; ACkValue[3] = ACkValue[0] + ACkValue[1] + ACkValue[2];
        NSData *data = [NSData dataWithBytes:&ACkValue length:sizeof(ACkValue)];
        [peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
    }
}


- (void)cleanup
{
    if (!_servicePeripheral.isConnected)
    {
        return;
    }
    
    if (_servicePeripheral.services != nil)
    {
        for (CBService *service in _servicePeripheral.services)
        {
            if (service.characteristics != nil)
            {
                for (CBCharacteristic *characteristic in service.characteristics)
                {
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kReadCharacteristicUUID]])
                    {
                        if (characteristic.isNotifying)
                        {
                            [_servicePeripheral setNotifyValue:NO forCharacteristic:characteristic];
                            return;
                        }
                    }
                }//for
            }
        }//for
    }
    
    [_centralManager cancelPeripheralConnection:_servicePeripheral];
    [self updateBleStatus:BluetoothStatusDisConnect];
    DEBUG_METHOD(@"------重新启动扫描---");
    [_centralManager scanForPeripheralsWithServices:@[] options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES }];
    [self updateBleStatus:BluetoothStatusSearching];
}


#pragma mark -
#pragma mark subClass override

- (void)didReceiveSynchData:(UInt32)steps distance:(UInt32)distance calorie:(UInt32)calorie utcTime:(UInt32)UTCTime
{
    DEBUG_METHOD(@"-----{\n steps:%u \n distance:%u \n calorie:%u \n }",(unsigned int)steps,(unsigned int)distance,(unsigned int)calorie);
}

- (void)didReceiveSportsData:(NSData*)sportsData utcTime:(UInt32)utcTime
{
    
}

- (void)didReceiveSleepData:(NSData*)sleepData utcTime:(UInt32)utcTime
{
    
}

- (void)didReceiveUserInfo:(NSMutableDictionary*)params
{
    DEBUG_METHOD(@"----%s---[%@]",__FUNCTION__,params);
}

- (BOOL)shouldSynchUpdateUTCTime
{
    return YES;
}

- (NSDictionary*)subClassFetchSWParams
{
    return nil;
}

- (NSDictionary*)subClassFetchUserInfo
{
    return nil;
}

- (void)didSuccessUpdateSWParams
{
    
}

- (void)didCompleteBluetoothDataTransmission
{
    
}

@end
