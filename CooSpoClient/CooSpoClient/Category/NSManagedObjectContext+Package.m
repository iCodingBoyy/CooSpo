//
//  NSManagedObjectContext+Package.m
//  CooSpoClient
//
//  Created by 马远征 on 14-10-16.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "NSManagedObjectContext+Package.h"
#import "CSCoreDataBaseClass.h"

@implementation NSManagedObjectContext (Package)

- (void)saveSynchronously
{
    [self saveAndWait:YES];
}

- (void)saveAsynchronously
{
    [self saveAndWait:NO];
}

- (void)saveAndWait:(BOOL)wait
{
    NSError *error = nil;
    [self save:&error];
    if (error)
    {
        NSLog(@"Error saving tempContext: %@", error);
    }
    [CSCoreDataBaseClass saveContextAndWait:wait];
}

@end
