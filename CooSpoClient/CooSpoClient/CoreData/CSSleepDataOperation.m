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
@property (nonatomic, strong) NSFetchRequest *fetchRequest;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic,   copy) NSMutableArray *dataArray;
@property (nonatomic, assign) UInt32 utcTime;
@end

@implementation CSSleepDataOperation
- (id)initWithNewData:(NSMutableArray*)array
{
    self = [super init];
    if (self)
    {
        _dataArray = [array copy];
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

- (NSFetchRequest*)fetchRequest
{
    if (_fetchRequest == nil)
    {
        _fetchRequest = [[NSFetchRequest alloc] init];
    }
    return _fetchRequest;
}

- (void)main
{
    NSManagedObjectContext *sContext = [[CSCoreData shared]sReadManagedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SleepDataEntity"
                                                    inManagedObjectContext:sContext];
    
    for (NSData *data in self.dataArray)
    {
        Byte cValue[100] = {0};
        NSUInteger length = data.length;
        [data getBytes:&cValue length:length];
        
        if (cValue[1] == 0x01)
        {
            _utcTime = (cValue[2]<<24) + (cValue[3]<<16) + (cValue[4]<<8) + cValue[5];
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
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"year = %@ AND month = %@ AND day = %@ AND time = %@", year,month,day,time];
                [self.fetchRequest setPredicate:predicate];
                [self.fetchRequest setEntity:entity];
                
                NSError *error = nil;
                NSUInteger count = [sContext countForFetchRequest:self.fetchRequest error:&error];
                
                if (count <= 0)
                {
                    SleepDataEntity *objectEntity = (SleepDataEntity*)[[NSManagedObject alloc]initWithEntity:entity
                                                                              insertIntoManagedObjectContext:sContext];
                    objectEntity.year = year;
                    objectEntity.month = month;
                    objectEntity.day = day;
                    objectEntity.time = time;
                    objectEntity.sleepData = @(cValue[i]);
                    objectEntity.utcTime = date;
                }
                if (![sContext save:&error])
                {
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                }
                _utcTime += 300;
            }
        }//if 0x01
        
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
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"year = %@ AND month = %@ AND day = %@ AND time = %@", year,month,day,time];
                [self.fetchRequest setPredicate:predicate];
                [self.fetchRequest setEntity:entity];
                
                NSError *error = nil;
                
                NSUInteger count = [sContext countForFetchRequest:self.fetchRequest error:&error];
                
                if (count <= 0)
                {
                    SleepDataEntity *objectEntity = (SleepDataEntity*)[[NSManagedObject alloc]initWithEntity:entity insertIntoManagedObjectContext:sContext];
                    objectEntity.year = year;
                    objectEntity.month = month;
                    objectEntity.day = day;
                    objectEntity.time = time;
                    objectEntity.sleepData = @(cValue[i]);
                    objectEntity.utcTime = date;
                }
                if (![sContext save:&error])
                {
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                }
                _utcTime += 300;
            }
            
        }// if 0x02
    }
}

@end
