//
//  CSRSynchCellContentView.h
//  CooSpoClient
//
//  Created by 马远征 on 14-10-15.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSRSynchCellContentView : UIView
@property (nonatomic, strong) NSString *distance;
@property (nonatomic, strong) NSString *calories;
@property (nonatomic, assign) NSUInteger steps;
@property (nonatomic, assign) BOOL finishGoals;
@end
