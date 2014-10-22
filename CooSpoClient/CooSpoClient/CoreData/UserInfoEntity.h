//
//  UserInfoEntity.h
//  CooSpoClient
//
//  Created by 马远征 on 14-10-16.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserInfoEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSNumber * sex;
@property (nonatomic, retain) NSNumber * stride;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) NSNumber * goal;

@end
