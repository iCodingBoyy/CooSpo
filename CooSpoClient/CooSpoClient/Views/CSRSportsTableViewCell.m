//
//  CSRSportsTableViewCell.m
//  CooSpoClient
//
//  Created by 马远征 on 14-10-17.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "CSRSportsTableViewCell.h"
#import "CooSpoDefine.h"

@implementation CSRSportsTableViewCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.textLabel.hidden = YES;
        self.detailTextLabel.hidden = YES;
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView.hidden = YES;
        self.selectedBackgroundView.hidden = YES;

        self.scView = [[CSRSportsContentView alloc]init];
        [self addSubview:self.scView];
        
        _graphScrollView = [[UIScrollView alloc]init];
        [_graphScrollView setShowsHorizontalScrollIndicator:NO];
        _graphScrollView.bounces = NO;
        [self addSubview:_graphScrollView];
        
        _graphView = [[CSRSportsGraphView alloc]init];
        [_graphScrollView addSubview:_graphView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.scView.frame = self.bounds;
    
    self.graphScrollView.frame = CGRectMake(40, 59, self.bounds.size.width-80, 172);
    
    CGRect frame = self.graphScrollView.bounds;
    frame.size.width = 24*160;
    frame.origin.x = 0;
    frame.origin.y = 0;
    self.graphView.frame = frame;
    self.graphScrollView.contentSize = CGSizeMake(24*160, frame.size.height);
}

@end
