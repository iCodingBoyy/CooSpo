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
@property (nonatomic) dispatch_queue_t operationQueue;

@property (nonatomic, strong) CBCharacteristic *writeCharacteristic;
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *servicePeripheral;
@property (nonatomic, assign) BOOL isBluetoothEnable;
@property (nonatomic, copy) BluetoothStatusBlock bleSBlock;

@property (nonatomic, strong) NSMutableArray *packetArray;
@property (nonatomic, assign) UInt32 utcTime;// 用于校验包是否重发
@property (nonatomic, strong) NSNumber *serialNum;
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

- (NSMutableArray*)packetArray
{
    if (_packetArray == nil)
    {
        _packetArray = [[NSMutableArray alloc]init];
    }
    return _packetArray;
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
//    NSString *UUID1 = CFBridgingRelease(CFUUIDCreateString(NULL, peripheral.UUID));
//    DEBUG_METHOD(@"----发现外设----%@",UUID1);
#endif
    
    if ( _servicePeripheral != peripheral && ([peripheral.name isEqualToString:@"Oone"] ||[peripheral.name isEqualToString:@"COOBIT"]))
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
    [self.packetArray removeAllObjects];
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
                DEBUG_METHOD(@"--年龄[%d]-\n-性别[%d]-\n-身高[%d]-\n-体重[%d]-\n-目标[%d]-\n-步距[%d]-\n-",age,sex,height,weight,target,stride);
                NSDictionary *userInfoParams = [self subClassFetchUserInfo];
                if (userInfoParams == nil)
                {
                    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                    [userInfo setObject:@(weight) forKey:@"weight"];
                    [userInfo setObject:@(age)    forKey:@"age"];
                    [userInfo setObject:@(height) forKey:@"height"];
                    [userInfo setObject:@(stride) forKey:@"stride"];
                    [userInfo setObject:@(sex)    forKey:@"sex"];
                    [userInfo setObject:@(target) forKey:@"goal"];
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
                    int ntarget = [userInfoParams[@"goal"] intValue];
                    
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
                [self writeResponseWithperipheral:peripheral sequenceNum:highByte ackByte:0x01];
            }
            else
            {
                self.serialNum = @( (cValue[0] & 0xf0 ) >> 4); // 提取0x-3包的序号
                UInt32 UTCTime = (cValue[1]<<24) + (cValue[2]<<16) + (cValue[3]<<8) + cValue[4];
                UInt32 steps = (cValue[5]<<16) + (cValue[6]<<8) + cValue[7];
                UInt32 distance = (cValue[8]<<16) +(cValue[9]<<8) + cValue[10];
                UInt32 calorie = (cValue[11]<<16) + (cValue[12]<<8) + cValue[13];
                
                DEBUG_METHOD(@"------UTC时间---%@",[NSDate dateWithTimeIntervalSince1970:UTCTime]);
                [self didReceiveSynchData:steps distance:distance calorie:calorie utcTime:UTCTime];
                [self writeResponseWithperipheral:peripheral sequenceNum:highByte ackByte:0x00];
            }
        }
        
        /* Packets for every 15 min(maximun)*/ /* Packet for sleeping data*/
        if( (cValue[0] & 0x0f) == 0x04 || (cValue[0] & 0x0f) == 0x05 )
        {
            if ((cValue[0] & 0x0f) == 0x04)
            {
                DEBUG_METHOD(@"--0xd4--Packets for every 15 min(maximun)----%@",characteristic.value);
            }
            else
            {
                DEBUG_METHOD(@"--0xd5---Packet for sleeping data----%@",characteristic.value);
            }
            
            if (cValue[1] == 0x03)
            {
                int serialNo =  (cValue[0] & 0xf0 ) >> 4;// 0x03包得序号
                Byte hByte = ((cValue[0] & 0xf0) >> 4);
                int packets = cValue[2]; // 收到的数据包数
                DEBUG_METHOD(@"-packets[%d]--Num[%d]-",packets,self.packetArray.count);
                if ( ![self resultOfCheckSum:cValue length:data.length] )
                {
                    DEBUG_METHOD(@"---0x03校验和出错---");
                    if (self.packetArray.count > 0)
                    {
                        [self.packetArray removeAllObjects];
                    }
                    [self writeResponseWithperipheral:peripheral sequenceNum:highByte ackByte:0x01];
                    return;
                }
                
                // 检查下一包的uct时间和上一包的utc时间是否相等，相等则是重复的包
                if (self.packetArray.count > 0)
                {
                    NSData *data = (NSData*)[self.packetArray firstObject];
                    Byte value[100] = {0};
                    [data getBytes:&value length:data.length];
                    
                    if (value[1] == 0x01)
                    {
                        UInt32 utcTime_ = (value[2]<<24) + (value[3]<<16) + (value[4]<<8) + value[5];
                        if (utcTime_ == self.utcTime)
                        {
                            // 更新最后的包序号
                            int serialNum =  (value[0] & 0xf0 ) >> 4;
                            self.serialNum = (serialNum -1 >= 0 ? @(serialNum -1):@(0x0f));
                            DEBUG_METHOD(@"---重复的包----");
                        }
                        else
                        {
                            int oldSqByte = self.serialNum ? [self.serialNum intValue]:0;
                            DEBUG_METHOD(@"---{%d:%d}",oldSqByte,((value[0] & 0xF0)>>4));
                            if ( ((oldSqByte + 1) & 0x0F) != ((value[0] & 0xF0)>>4))
                            {
                                DEBUG_METHOD(@"---上下报的序号不连续---");
                                if (self.packetArray.count > 0)
                                {
                                    [self.packetArray removeAllObjects];
                                }
                                [self writeResponseWithperipheral:peripheral sequenceNum:hByte ackByte:0x01];
                                return;
                            }
                        }
                    }
                }

                // 对收到的包进行校验和校验，有错误则重发
                BOOL checkError = NO;
                for (int i = 0; i < self.packetArray.count; i++)
                {
                    NSData *tdata = [self.packetArray objectAtIndex:i];
                    Byte value[100] = {0};
                    [tdata getBytes:&value length:tdata.length];
                    if (![self resultOfCheckSum:value length:tdata.length])
                    {
                        checkError = YES;
                        break;
                    }
                }
                if (checkError)
                {
                    DEBUG_METHOD(@"---收到的包校验和出错----");
                    if (self.packetArray.count > 0)
                    {
                        [self.packetArray removeAllObjects];
                    }
                    [self writeResponseWithperipheral:peripheral sequenceNum:hByte ackByte:0x01];
                    return;
                }
                
                // 校验收到包数是否完整
                if (self.packetArray.count != packets)
                {
                    DEBUG_METHOD(@"---收到的包不完整---");
                    if (self.packetArray.count > 0)
                    {
                        [self.packetArray removeAllObjects];
                    }
                    [self writeResponseWithperipheral:peripheral sequenceNum:hByte ackByte:0x01];
                    return;
                }
                
                //对收到的数据包进行序号校验
                for (int i = 0; i < self.packetArray.count; i++)
                {
                    NSData *tdata = [self.packetArray objectAtIndex:i];
                    Byte value[100] = {0};
                    [tdata getBytes:&value length:tdata.length];
                    if (i+1 < self.packetArray.count)
                    {
                        NSData *data1 = [self.packetArray objectAtIndex:i+1];
                        Byte value1[100] = {0};
                        [data1 getBytes:&value1 length:data1.length];
                        if ( ((((value[0] & 0xF0)>>4) + 1) & 0x0F) != ((value1[0] & 0xF0)>>4) )
                        {
                            checkError = YES;
                            break;
                        }
                    }
                    else
                    {
                        if ( ((((value[0] & 0xF0)>>4) + 1) & 0x0F) != serialNo )
                        {
                            checkError = YES;
                            break;
                        }
                    }
                }
                
                if (checkError)
                {
                    DEBUG_METHOD(@"---收到的包内部序号校验出错---");
                    if (self.packetArray.count > 0)
                    {
                        [self.packetArray removeAllObjects];
                    }
                    [self writeResponseWithperipheral:peripheral sequenceNum:hByte ackByte:0x01];
                    return;
                }
                
                
                
                // 校验没有问题,输出数据
                DEBUG_METHOD(@"---输出数据---");
                self.serialNum = @(serialNo);
                if (self.packetArray.count > 0)
                {
                    NSData *data = (NSData*)[self.packetArray firstObject];
                    Byte value[100] = {0};
                    [data getBytes:&value length:data.length];
                    
                    if (value[1] == 0x01)
                    {
                        self.utcTime = (value[2]<<24) + (value[3]<<16) + (value[4]<<8) + value[5];
                    }
                }
                [self didReceiveSportsPackage:self.packetArray];
                if (self.packetArray.count > 0)
                {
                    [self.packetArray removeAllObjects];
                }
                [self writeResponseWithperipheral:peripheral sequenceNum:highByte ackByte:0x00];
            }
            else
            {
                if (![self.packetArray containsObject:characteristic.value])
                {
                    [self.packetArray addObject:characteristic.value];
                }
            }
        }
        
        /* Transfer Complete,the iphone app can disconnect from bracelet*/
        if( (cValue[0] & 0x0f) == 0x06 )
        {
            DEBUG_METHOD(@"--0xd6---Transfer Complete,the iphone app can disconnect from bracelet----%@",characteristic.value);
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
            
            // reset数据
            [self.packetArray removeAllObjects];
            
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

- (void)didReceiveSportsPackage:(NSMutableArray*)dataArray
{
    DEBUG_METHOD(@"--SPPackage--%@",dataArray);
}

- (void)didReceiveSleepPackage:(NSMutableArray*)dataArray
{
    DEBUG_METHOD(@"--SLPackage--%@",dataArray);
}

- (void)didReceiveSynchData:(UInt32)steps distance:(UInt32)distance calorie:(UInt32)calorie utcTime:(UInt32)UTCTime
{
    
}

- (void)didReceiveUserInfo:(NSMutableDictionary*)params
{
    
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
