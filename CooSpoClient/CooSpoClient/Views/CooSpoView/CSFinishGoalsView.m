//
//  CSFinishGoalsView.m
//  CooSpoClient
//
//  Created by 马远征 on 14-10-15.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "CSFinishGoalsView.h"
#import "CooSpoDefine.h"

@implementation CSFinishGoalsView
- (void)awakeFromNib
{
    [super awakeFromNib];
    self.backgroundColor = [UIColor whiteColor];
}

- (void)setFillRate:(NSString *)fillRate
{
    if (fillRate != _fillRate)
    {
        _fillRate = fillRate;
        [self setNeedsDisplay];
    }
}

- (void)setGoalSteps:(NSUInteger)goalSteps
{
    if (goalSteps != _goalSteps)
    {
        _goalSteps = goalSteps;
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    // 绘制竖线
    {
        UIImage *image = [UIImage imageNamed:@"cs_vline_image"];
        [image drawInRect:CGRectMake(rect.size.width*0.5-0.5, 0, 1, rect.size.height)];
    }
    // 绘制文字
    {
        [[UIColor blackColor] set];
        UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
        NSString *drawString = @"今日目标";
        [drawString drawAtPoint:CGPointMake(20, rect.size.height*0.25) withFont:font];
        
        _goalSteps = (_goalSteps > 999999) ? 999999 :_goalSteps;
        NSString *stepsString = [NSString stringWithFormat:@"%lu",(unsigned long)_goalSteps];
        NSString *goalString = @"000000";
        goalString = [goalString substringToIndex:goalString.length - stepsString.length];
        goalString = [goalString stringByAppendingString:stepsString];
        
        [UIColorFromRGB(0x7e7e7e)set];
        UIFont *goalFont = [UIFont fontWithName:@"Arial" size:31];
        [goalString drawAtPoint:CGPointMake(20, rect.size.height*0.5) withFont:goalFont];
        
        [[UIColor blackColor] set];
        font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
        CGSize size = [goalString sizeWithFont:goalFont];
        drawString = @"步";
        [drawString drawAtPoint:CGPointMake(25+size.width, rect.size.height*0.5+15) withFont:font];
    }
    {
        [[UIColor blackColor] set];
        UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
        NSString *drawString = @"完成目标";
        [drawString drawAtPoint:CGPointMake(rect.size.width*0.5 + 20, rect.size.height*0.25) withFont:font];
        
        [UIColorFromRGB(0x7e7e7e)set];
        UIFont *goalFont = [UIFont fontWithName:@"Arial" size:31];
        _fillRate = _fillRate == nil ? @"0.0":_fillRate;
        [_fillRate drawAtPoint:CGPointMake(rect.size.width*0.5 + 20, rect.size.height*0.5) withFont:goalFont];
        
        [[UIColor blackColor] set];
        font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
        CGSize size = [_fillRate sizeWithFont:goalFont];
        drawString = @"%";
        [drawString drawAtPoint:CGPointMake(rect.size.width*0.5 + 25+size.width, rect.size.height*0.5+15) withFont:font];
    }
    
    // 绘制底部线
    {
        UIImage *image = [UIImage imageNamed:@"cs_hline_image"];
        [image drawInRect:CGRectMake(0, rect.size.height-1, rect.size.width, 1)];
    }
}
@end
