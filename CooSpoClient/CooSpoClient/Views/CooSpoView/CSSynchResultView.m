//
//  CSSynchResultView.m
//  CooSpoClient
//
//  Created by 马远征 on 14-10-15.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "CSSynchResultView.h"
#import "CooSpoDefine.h"

@implementation CSSynchResultView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.backgroundColor = [UIColor whiteColor];
}

- (void)setSteps:(NSUInteger)steps
{
    if (steps != _steps)
    {
        _steps = steps;
        [self setNeedsDisplay];
    }
}

- (void)setDistance:(NSUInteger)distance
{
    if (distance != _distance)
    {
        _distance = distance;
        [self setNeedsDisplay];
    }
}

- (void)setCalories:(NSUInteger)calories
{
    if (calories != _calories)
    {
        _calories = calories;
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    // 绘制中间线
    {
        UIImage *image = [UIImage imageNamed:@"cs_hline_image"];
        [image drawInRect:CGRectMake(0, rect.size.height*0.5-1, rect.size.width, 1)];
    }
    // 绘制底部线
    {
        UIImage *image = [UIImage imageNamed:@"cs_hline_image"];
        [image drawInRect:CGRectMake(0, rect.size.height-1, rect.size.width, 1)];
    }
    
    // 绘制文字和图标
    {
        UIImage *stepImage = [UIImage imageNamed:@"cs_run_mark_icon"];
        [stepImage drawAtPoint:CGPointMake(15, rect.size.height*0.25-23)];
        
        UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
        [UIColorFromRGB(0x2e2e2e)set];
        NSString *drawString = @"今日步数";
        [drawString drawAtPoint:CGPointMake(10, rect.size.height*0.25) withFont:font];
    }
    
    {
        UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
        [UIColorFromRGB(0x2e2e2e)set];
        NSString *drawString = @"步";
        [drawString drawAtPoint:CGPointMake(rect.size.width-25, rect.size.height*0.25) withFont:font];
    }
    
    // 绘制步数
    {
        _steps = (_steps > 999999) ? 999999 :_steps;
        NSString *stepsString = [NSString stringWithFormat:@"%lu",(unsigned long)_steps];
        NSString *string = @"000000";
        string = [string substringToIndex:string.length - stepsString.length];
        string = [string stringByAppendingString:stepsString];
        
        UIFont *font = [UIFont fontWithName:@"Arial" size:62];
        [UIColorFromRGB(0x007ac0)set];
        
        CGSize size = [string sizeWithFont:font];
        CGFloat originY = (rect.size.height*0.5- size.height)*0.5;
        CGRect frame = CGRectMake(60, originY, rect.size.width-80, 40);
        [string drawInRect:frame withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
    }
    
    // 绘制竖线
    {
        UIImage *image = [UIImage imageNamed:@"cs_vline_image"];
        [image drawInRect:CGRectMake(rect.size.width*0.5-0.5, rect.size.height*0.5, 1, rect.size.height*0.5)];
    }
    
    // 绘制距离与卡路里
    {
        UIImage *rulerImage = [UIImage imageNamed:@"cs_ruler_icon"];
        [rulerImage drawAtPoint:CGPointMake(20, rect.size.height*0.5+20)];
        
        [[UIColor blackColor]set];
        UIFont *font = [UIFont fontWithName:@"Arial" size:14];
        NSString *drawString = @"距离(米)";
        [drawString drawAtPoint:CGPointMake(55, rect.size.height*0.5+18) withFont:font];
        
        [UIColorFromRGB(0xEA9A00)set];

        CGFloat distanceValue = (CGFloat)_distance/100;
        NSString *distanceString = [NSString stringWithFormat:@"%.1f",distanceValue];
        font = [UIFont fontWithName:@"Helvetica-Bold" size:24];
        CGSize size = [distanceString sizeWithFont:font];
        CGFloat originY = rect.size.height - size.height - 20;
        if (originY < rect.size.height*0.5+38)
        {
            originY = rect.size.height*0.5 + 38;
        }
        [distanceString drawAtPoint:CGPointMake(20, originY) withFont:font];
        
    }
    
    {
        UIImage *rulerImage = [UIImage imageNamed:@"cs_calories_icon"];
        [rulerImage drawAtPoint:CGPointMake(rect.size.width*0.5+20, rect.size.height*0.5+20)];
        
        [[UIColor blackColor]set];
        UIFont *font = [UIFont fontWithName:@"Arial" size:14];
        NSString *drawString = @"卡路消耗(千卡)";
        [drawString drawAtPoint:CGPointMake(rect.size.width*0.5 + 55, rect.size.height*0.5+18) withFont:font];

        [UIColorFromRGB(0xDE533C)set];

        CGFloat caloriesValue = (CGFloat)_calories/10;
        NSString *caloriesString = [NSString stringWithFormat:@"%.1f",caloriesValue];
        font = [UIFont fontWithName:@"Helvetica-Bold" size:24];
        CGSize size = [caloriesString sizeWithFont:font];
        CGFloat originY = rect.size.height - size.height - 20;
        if (originY < rect.size.height*0.5+38)
        {
            originY = rect.size.height*0.5 + 38;
        }
        [caloriesString drawAtPoint:CGPointMake(rect.size.width*0.5 + 55, originY) withFont:font];
    }

}
@end
