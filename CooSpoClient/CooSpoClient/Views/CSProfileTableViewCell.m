//
//  CSProfileTableViewCell.m
//  CooSpoClient
//
//  Created by 马远征 on 14-10-15.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "CSProfileTableViewCell.h"

@implementation CSProfileTableViewCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        UIView *bgView = [[UIView alloc]init];
        bgView.backgroundColor = [UIColor whiteColor];
        self.backgroundView = bgView;
        
        UIView *selectedBgView = [[UIView alloc]init];
        selectedBgView.backgroundColor = [UIColor grayColor];
        self.selectedBackgroundView = selectedBgView;
        
        self.backgroundColor = [UIColor clearColor];
        
        _resultLabel = [[UILabel alloc]init];
        _resultLabel.backgroundColor = [UIColor clearColor];
        _resultLabel.highlightedTextColor = [UIColor blackColor];
        _resultLabel.textColor = [UIColor blackColor];
        [self addSubview:_resultLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    CGRect imageFrame = self.imageView.frame;
    imageFrame.origin.y += 5.0;
    imageFrame.origin.x += 13.0;
    imageFrame.size.height -= 10.0;
    imageFrame.size.width = imageFrame.size.height;
    self.imageView.frame = imageFrame;
    self.imageView.layer.cornerRadius = self.imageView.frame.size.height*0.5;
    
    CGRect accessoryViewframe = self.accessoryView.frame;
    accessoryViewframe.origin.x -= 5;
    self.accessoryView.frame = accessoryViewframe;
    
    CGFloat XdifValue = (self.imageView.image != nil) ? 30: 10;
    CGRect textlabelframe = self.textLabel.frame;
    textlabelframe.origin.x += XdifValue;
    self.textLabel.frame = textlabelframe;
    
    CGRect detailTextlabelframe = self.detailTextLabel.frame;
    detailTextlabelframe.origin.x += 10;
    self.detailTextLabel.frame = detailTextlabelframe;
    
    CGRect frame = self.backgroundView.frame;
    frame.origin.x = 10;
    frame.size.width = self.frame.size.width - 20;
    self.backgroundView.frame = frame;
    
    CGRect selectframe = self.selectedBackgroundView.frame;
    selectframe.origin.x = 10;
    selectframe.size.width = self.frame.size.width - 20;
    self.selectedBackgroundView.frame = selectframe;
    
    CGSize size = [self.textLabel.text sizeWithFont:self.textLabel.font];
    CGFloat originX = self.textLabel.frame.origin.x + size.width;
    _resultLabel.frame = CGRectMake(originX + 10, (self.frame.size.height - 24)*0.5, 160, 24);
}

@end
