//
//  CSSynchStatusView.m
//  CooSpoClient
//
//  Created by 马远征 on 14-10-11.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "CSSynchStatusView.h"

@implementation CSSynchStatusView

- (void)setLastSynchTime:(NSString *)lastSynchTime
{
    if (_lastSynchTime != lastSynchTime)
    {
        _lastSynchTime = lastSynchTime;
        [self setNeedsDisplay];
    }
}


- (void)setSynchStatus:(NSString *)synchStatus
{
    if (_synchStatus != synchStatus)
    {
        _synchStatus = synchStatus;
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect
{
    if (_lastSynchTime)
    {
        [[UIColor blackColor]set];
        UIFont *font = [UIFont fontWithName:@"Helvetica" size:12];
        CGSize size = [_lastSynchTime sizeWithFont:font];
        [_lastSynchTime drawAtPoint:CGPointMake(5, rect.size.height*0.5-size.height*0.5) withFont:font];
    }
    
    {
        UIImage *image = [UIImage imageNamed:@"cs_bluetooth_image"];
        [image drawAtPoint:CGPointMake(rect.size.width*2/3-10, rect.size.height*0.5-10)];
    }
    
    
    if (_synchStatus)
    {
        [[UIColor redColor]set];
        UIFont *font = [UIFont fontWithName:@"Helvetica" size:12];
        CGSize size = [_synchStatus sizeWithFont:font];
        [_synchStatus drawAtPoint:CGPointMake(rect.size.width*2/3+10, rect.size.height*0.5-size.height*0.5)
                         withFont:font];
    }
    
    {
        UIImage *image = [UIImage imageNamed:@"cs_hline_image"];
        [image drawInRect:CGRectMake(0, rect.size.height-1, rect.size.width, 1)];
    }
}
@end
