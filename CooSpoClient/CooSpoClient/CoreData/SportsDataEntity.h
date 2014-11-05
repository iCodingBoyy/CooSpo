//
//  SportsDataEntity.h
//  CooSpoClient
//
//  Created by 马远征 on 14/10/23.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SportsDataEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * calorie;
@property (nonatomic, retain) NSString * day;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSString * month;
@property (nonatomic, retain) NSNumber * steps;
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSDate * utcTime;
@property (nonatomic, retain) NSString * year;

@end
