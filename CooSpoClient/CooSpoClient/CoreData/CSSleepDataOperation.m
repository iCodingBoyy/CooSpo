//
//  CSSleepDataOperation.m
//  CooSpoClient
//
//  Created by 马远征 on 14-10-17.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "CSSleepDataOperation.h"
#import "CSCoreData.h"
#import "NSManagedObjectContext+Package.h"

@interface CSSleepDataOperation()
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSData *receiveData;
@property (nonatomic, assign) UInt32 utcTime;
@end

@implementation CSSleepDataOperation
- (id)initWithData:(NSData*)receiveData_ utcTime:(UInt32)utcTime_
{
    self = [super init];
    if (self)
    {
        _receiveData = receiveData_;
        _utcTime = utcTime_;
    }
    return self;
}

- (NSDateFormatter*)dateFormatter
{
    if (_dateFormatter)
    {
        return _dateFormatter;
    }
    _dateFormatter = [[NSDateFormatter alloc]init];
    [_dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    return _dateFormatter;
}

- (void)main
{
    self.context = [[CSCoreData shared]sleepManagedObjectContext];
    typeof(self) __weak weakSelf = self;
    [self.context performBlockAndWait:^{
        [weakSelf insertNewData];
    }];
}

- (void)insertNewData
{
    Byte cValue[100] = {0};
    NSUInteger length = _receiveData.length;
    [_receiveData getBytes:&cValue length:length];
    
    
    NSEntityDescription *sportsEntity = [NSEntityDescription entityForName:@"SleepDataEntity"
                                                    inManagedObjectContext:self.context];
    if (cValue[1] == 0x01)
    {
        for ( int i = 6; i < length - 1; i += 1 )
        {
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:_utcTime];
            [self.dateFormatter setDateFormat:@"yyyy"];
            NSString *year = [self.dateFormatter stringFromDate:date];
            
            [self.dateFormatter setDateFormat:@"MM"];
            NSString *month = [self.dateFormatter stringFromDate:date];
            
            [self.dateFormatter setDateFormat:@"dd"];
            NSString *day = [self.dateFormatter stringFromDate:date];
            
            [self.dateFormatter setDateFormat:@"HH:mm:ss"];
            NSString *time = [self.dateFormatter stringFromDate:date];
            
            SleepDataEntity *objectEntity = (SleepDataEntity*)[[NSManagedObject alloc]initWithEntity:sportsEntity
                                                                      insertIntoManagedObjectContext:self.context];
            objectEntity.year = year;
            objectEntity.month = month;
            objectEntity.day = day;
            objectEntity.time = time;
            objectEntity.sleepData = @(cValue[i]);
            objectEntity.utcTime = date;
            _utcTime += 300;
        }
    }
    // 0xd4:0x02包
    if (cValue[1] == 0x02)
    {
        for ( int i = 2; i < length - 1; i += 2 )
        {
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:_utcTime];
            [self.dateFormatter setDateFormat:@"yyyy"];
            NSString *year = [self.dateFormatter stringFromDate:date];
            
            [self.dateFormatter setDateFormat:@"MM"];
            NSString *month = [self.dateFormatter stringFromDate:date];
            
            [self.dateFormatter setDateFormat:@"dd"];
            NSString *day = [self.dateFormatter stringFromDate:date];
            
            [self.dateFormatter setDateFormat:@"HH:mm:ss"];
            NSString *time = [self.dateFormatter stringFromDate:date];
            
            SleepDataEntity *objectEntity = (SleepDataEntity*)[[NSManagedObject alloc]initWithEntity:sportsEntity insertIntoManagedObjectContext:self.context];
            objectEntity.year = year;
            objectEntity.month = month;
            objectEntity.day = day;
            objectEntity.time = time;
            objectEntity.sleepData = @(cValue[i]);
            objectEntity.utcTime = date;
            _utcTime += 300;
        }
    }
    // 保存背后数据
    [self.context saveSynchronously];
}


@end
