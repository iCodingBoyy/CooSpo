//
//  SwParamsEntity.h
//  CooSpoClient
//
//  Created by 马远征 on 14-10-16.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SwParamsEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * aifSthreshold;
@property (nonatomic, retain) NSNumber * autoSWEnable;
@property (nonatomic, retain) NSNumber * needUpdate;
@property (nonatomic, retain) NSNumber * nmSthreshold;
@property (nonatomic, retain) NSNumber * spHour;
@property (nonatomic, retain) NSNumber * spMininute;
@property (nonatomic, retain) NSNumber * stHour;
@property (nonatomic, retain) NSNumber * stMininute;

@end
