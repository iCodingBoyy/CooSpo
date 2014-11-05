//
//  CSRSleepTableViewCell.h
//  CooSpoClient
//
//  Created by 马远征 on 14/10/27.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSRSleepContentView.h"
#import "CSRSleepGraphView.h"

@interface CSRSleepTableViewCell : UITableViewCell
@property (nonatomic, strong, readonly) CSRSleepContentView *sContentView;
@property (nonatomic, strong, readonly) CSRSleepGraphView *graphView;
@property (nonatomic, assign) NSUInteger xPoints;
@property (nonatomic, strong) UIScrollView *sScrollView;
@end
