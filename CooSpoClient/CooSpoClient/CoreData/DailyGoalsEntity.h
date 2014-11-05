//
//  DailyGoalsEntity.h
//  CooSpoClient
//
//  Created by 马远征 on 14/10/24.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DailyGoalsEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * dailyGoals;
@property (nonatomic, retain) NSString * dateTime;
@property (nonatomic, retain) NSDate * utcTime;

@end
