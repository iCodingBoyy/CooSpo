//
//  SynchDataEntity.h
//  CooSpoClient
//
//  Created by 马远征 on 14-10-17.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SynchDataEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * calorie;
@property (nonatomic, retain) NSString * day;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSString * month;
@property (nonatomic, retain) NSNumber * steps;
@property (nonatomic, retain) NSString * utcTime;
@property (nonatomic, retain) NSString * year;
@property (nonatomic, retain) NSNumber * complete;

@end
