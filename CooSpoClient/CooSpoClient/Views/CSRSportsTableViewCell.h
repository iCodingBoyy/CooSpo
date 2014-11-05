//
//  CSRSportsTableViewCell.h
//  CooSpoClient
//
//  Created by 马远征 on 14-10-17.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSRSportsContentView.h"
#import "CSRSportsGraphView.h"

@interface CSRSportsTableViewCell : UITableViewCell
@property (nonatomic, strong) CSRSportsContentView *scView;
@property (nonatomic, strong) CSRSportsGraphView *graphView;
@property (nonatomic, strong) UIScrollView *graphScrollView;
@end
