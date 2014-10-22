//
//  CSRSynchCellContentView.m
//  CooSpoClient
//
//  Created by 马远征 on 14-10-15.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "CSRSynchCellContentView.h"
#import "CooSpoDefine.h"

@implementation CSRSynchCellContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setSteps:(NSUInteger)steps
{
    if (steps != _steps)
    {
        _steps = steps;
        [self setNeedsDisplay];
    }
}

- (void)setDistance:(NSString *)distance
{
    if (distance != _distance)
    {
        _distance = distance;
        [self setNeedsDisplay];
    }
}

- (void)setCalories:(NSString *)calories
{
    if (calories != _calories)
    {
        _calories = calories;
        [self setNeedsDisplay];
    }
}

- (void)setFinishGoals:(BOOL)finishGoals
{
    if (finishGoals != _finishGoals)
    {
        _finishGoals = finishGoals;
        [self setNeedsDisplay];
    }
}


- (void)drawRect:(CGRect)rect
{
    UIImage *stepIconImage = [UIImage imageNamed:@"cs_records_synch_cell_icon"];
    [stepIconImage drawAtPoint:CGPointMake(5, 10)];
    
    UIImage *synchImage = [UIImage imageNamed:@"cs_records_synch_cell_bg"];
    [synchImage drawInRect:CGRectMake(45, 5, rect.size.width-53, rect.size.height-10)];
    
    if (_finishGoals)
    {
        UIImage *synchIconImage = [UIImage imageNamed:@"cs_records_synch_cell_bg_icon"];
        [synchIconImage drawAtPoint:CGPointMake(rect.size.width-70, 15)];
    }
    
    {
        UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
        [UIColorFromRGB(0x2e2e2e)set];
        NSString *drawString = @"当日步数";
        [drawString drawAtPoint:CGPointMake(60, 25) withFont:font];
    }
    
    {
        UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
        [UIColorFromRGB(0x2e2e2e)set];
        NSString *drawString = @"步";
        [drawString drawAtPoint:CGPointMake(rect.size.width-85, 25) withFont:font];
    }
    
    {
        _steps = (_steps > 100000) ? 100000 :_steps;
        NSString *stepsString = [NSString stringWithFormat:@"%lu",(unsigned long)_steps];
        NSString *string = @"000000";
        string = [string substringToIndex:string.length - stepsString.length];
        string = [string stringByAppendingString:stepsString];
        
        UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:35];
        [UIColorFromRGB(0x007ac0)set];
        CGRect frame = CGRectMake(110, 10, rect.size.width-190, 40);
        [string drawInRect:frame withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
    }
    
    {
        UIFont *font = [UIFont fontWithName:@"Helvetica" size:12];
        [UIColorFromRGB(0x7e7e7e)set];
        NSString *drawString = @"距离(米)";
        [drawString drawAtPoint:CGPointMake(60, 70)
                       withFont:font];
    }
    
    {
        UIFont *font = [UIFont fontWithName:@"Helvetica" size:12];
        [UIColorFromRGB(0x7e7e7e)set];
        NSString *drawString = @"卡路消耗(千卡)";
        [drawString drawAtPoint:CGPointMake(rect.size.width*0.5+29, 70)
                       withFont:font];
    }
    
    if (_distance)
    {
        [UIColorFromRGB(0xed9d1c)set];
        UIFont *font = [UIFont fontWithName:@"Arial" size:24];
        [_distance drawAtPoint:CGPointMake(60, 90) withFont:font];
    }
    
    if (_calories)
    {
        [UIColorFromRGB(0x7e7e7e)set];
        UIFont *font = [UIFont fontWithName:@"Arial" size:24];
        [_calories drawAtPoint:CGPointMake(rect.size.width*0.5+29, 90) withFont:font];
    }
}

@end
