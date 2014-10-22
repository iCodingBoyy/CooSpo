//
//  CSSportsDataOperation.m
//  CooSpoClient
//
//  Created by 马远征 on 14-10-17.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "CSSportsDataOperation.h"
#import "CSCoreData.h"
#import "NSManagedObjectContext+Package.h"

@interface CSSportsDataOperation()
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSData *receiveData;
@property (nonatomic, assign) UInt32 utcTime;
@end

@implementation CSSportsDataOperation

- (instancetype)initWithData:(NSData*)data_ utcTime:(UInt32)utcTime_
{
    self = [super init];
    if (self)
    {
        _receiveData = data_;
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
    self.context = [[CSCoreDataBaseClass shared]sportsManagedObjectContext];
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
    
    NSEntityDescription *sportsEntity = [NSEntityDescription entityForName:@"SportsDataEntity"
                                                    inManagedObjectContext:self.context];
    NSDate *utcDate = [NSDate dateWithTimeIntervalSince1970:_utcTime];
    
    if (cValue[1] == 0x01)
    {
        for (int i = 6; i < length - 1; i += 2)
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
            
            SportsDataEntity *entity = (SportsDataEntity*)[[NSManagedObject alloc]initWithEntity:sportsEntity insertIntoManagedObjectContext:self.context];
            entity.year = year;
            entity.month = month;
            entity.day = day;
            entity.time = time;
            entity.utcTime = utcDate;
            entity.steps = @(cValue[i]);
            if ( i + 1 < length - 1 )
            {
                entity.calorie = @(cValue[i+1]);
            }
        }
        _utcTime += 60;
    }
    
    if (cValue[1] == 0x02)
    {
        for (int i = 2; i < length - 1; i += 2)
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
            
            SportsDataEntity *entity = (SportsDataEntity*)[[NSManagedObject alloc]initWithEntity:sportsEntity insertIntoManagedObjectContext:self.context];
            entity.year = year;
            entity.month = month;
            entity.day = day;
            entity.time = time;
            entity.utcTime = utcDate;
            entity.calorie = @(cValue[i]);
            if ( i + 1 < length - 1 )
            {
                entity.steps = @(cValue[i+1]);
            }
            _utcTime += 60;
        }
    }
    [self.context saveSynchronously];
}
@end
