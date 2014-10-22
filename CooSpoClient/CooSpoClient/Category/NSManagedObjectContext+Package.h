//
//  NSManagedObjectContext+Package.h
//  CooSpoClient
//
//  Created by 马远征 on 14-10-16.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (Package)
- (void)saveSynchronously;
- (void)saveAsynchronously;
@end
