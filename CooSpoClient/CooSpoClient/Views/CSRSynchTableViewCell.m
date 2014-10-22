//
//  CSRSynchTableViewCell.m
//  CooSpoClient
//
//  Created by 马远征 on 14-10-15.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "CSRSynchTableViewCell.h"
#import "CooSpoDefine.h"

@implementation CSRSynchTableViewCell
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.textLabel.textColor = UIColorFromRGB(0x7e7e7e);
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.font = [UIFont fontWithName:@"Arial" size:15];
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView.hidden = YES;
        self.selectedBackgroundView.hidden = YES;
        
        self.synchView = [[CSRSynchCellContentView alloc]init];
        [self addSubview:self.synchView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    self.textLabel.frame = CGRectMake(10, 5, bounds.size.width-20, 24);
    
    self.synchView.frame = CGRectMake(0, 30, bounds.size.width, bounds.size.height-30);
}
@end
