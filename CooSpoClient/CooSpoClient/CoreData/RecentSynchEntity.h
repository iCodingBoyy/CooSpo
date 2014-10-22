//
//  RecentSynchEntity.h
//  CooSpoClient
//
//  Created by 马远征 on 14-10-16.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RecentSynchEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * calorie;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSNumber * steps;
@property (nonatomic, retain) NSNumber * utcTime;

@end
