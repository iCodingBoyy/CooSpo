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
//        self.textLabel.textColor = UIColorFromRGB(0x7e7e7e);
//        self.textLabel.textAlignment = NSTextAlignmentCenter;
//        self.textLabel.font = [UIFont fontWithName:@"Arial" size:15];
//        self.textLabel.backgroundColor = [UIColor clearColor];
        
        self.textLabel.hidden = YES;
        self.detailTextLabel.hidden = YES;
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView.hidden = YES;
        self.selectedBackgroundView.hidden = YES;

        self.scView = [[CSRSportsContentView alloc]init];
        [self addSubview:self.scView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
//    CGRect bounds = self.bounds;
//    self.textLabel.frame = CGRectMake(10, 5, bounds.size.width-20, 24);
    self.scView.frame = self.bounds;
}

@end
