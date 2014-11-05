//
//  CSRSleepTableViewCell.m
//  CooSpoClient
//
//  Created by 马远征 on 14/10/27.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "CSRSleepTableViewCell.h"

@implementation CSRSleepTableViewCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.textLabel.textColor = [UIColor blackColor];
        self.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
        
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView.hidden = YES;
        self.selectedBackgroundView.hidden = YES;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _sContentView = [[CSRSleepContentView alloc]init];
        [self addSubview:_sContentView];

        _sScrollView = [[UIScrollView alloc]init];
        _sScrollView.backgroundColor = [UIColor clearColor];
        [_sScrollView setShowsHorizontalScrollIndicator:NO];
        _sScrollView.bounces = NO;
        [self addSubview:_sScrollView];
        
        _graphView = [[CSRSleepGraphView alloc]init];
        [_sScrollView addSubview:_graphView];
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize size = [self.detailTextLabel.text sizeWithFont:self.detailTextLabel.font];
    if (size.width > self.bounds.size.width-20)
    {
        self.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
    }
    self.textLabel.frame = CGRectMake(10, 5, 180, 24);
    self.detailTextLabel.frame = CGRectMake(10, 30, self.bounds.size.width-20, 24);
    
    self.sContentView.frame = CGRectMake(0, 54, self.bounds.size.width, self.bounds.size.height - 54);
    self.sScrollView.frame = CGRectMake(40, 54, self.bounds.size.width-60, self.bounds.size.height-54);
    
    CGRect frame = self.sScrollView.bounds;
    frame.size.width = self.xPoints*144 > self.bounds.size.width-60 ? self.xPoints*144:self.bounds.size.width-60;
    frame.origin.x = 0;
    frame.origin.y = 0;
    self.graphView.frame = frame;
    self.sScrollView.contentSize = CGSizeMake(frame.size.width, frame.size.height);
}

@end
