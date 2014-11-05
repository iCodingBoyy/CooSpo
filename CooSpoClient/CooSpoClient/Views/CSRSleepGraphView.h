//
//  CSRSleepGraphView.h
//  CooSpoClient
//
//  Created by 马远征 on 14/10/27.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSRSleepGraphView : UIView
@property (nonatomic, strong) NSString *dateString;
@property (nonatomic, strong) NSArray *xPointsArray;
@property (nonatomic, strong) NSArray *xyPointsArray;
- (void)drawGraph:(NSArray*)xyPoints;
@end
