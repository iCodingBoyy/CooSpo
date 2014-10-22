//
//  SleepDataEntity.h
//  CooSpoClient
//
//  Created by 马远征 on 14-10-16.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SleepDataEntity : NSManagedObject

@property (nonatomic, retain) NSDate * utcTime;
@property (nonatomic, retain) NSString * year;
@property (nonatomic, retain) NSString * month;
@property (nonatomic, retain) NSString * day;
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSNumber * sleepData;

@end
