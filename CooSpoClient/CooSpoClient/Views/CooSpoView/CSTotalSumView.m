//
//  CSTotalSumView.m
//  CooSpoClient
//
//  Created by 马远征 on 14-10-15.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "CSTotalSumView.h"
#import "CooSpoDefine.h"

@implementation CSTotalSumView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setBackgroundColor:[UIColor whiteColor]];
}

- (void)setTotalSteps:(NSUInteger)totalSteps
{
    if (totalSteps != _totalSteps)
    {
        _totalSteps = totalSteps;
        [self setNeedsDisplay];
    }
}

- (void)setTotalDistance:(NSUInteger)totalDistance
{
    if (totalDistance != _totalDistance)
    {
        _totalDistance = totalDistance;
        [self setNeedsDisplay];
    }
}

- (void)setTotalCalories:(NSUInteger)totalCalories
{
    if (totalCalories != _totalCalories)
    {
        _totalCalories = totalCalories;
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    // 绘制顶部线
    {
        UIImage *image = [UIImage imageNamed:@"cs_hline_image"];
        [image drawInRect:CGRectMake(0, 0, rect.size.width, 1)];
    }
    // 绘制中间线
    {
        UIImage *image = [UIImage imageNamed:@"cs_hline_image"];
        [image drawInRect:CGRectMake(0, rect.size.height*0.5-11, rect.size.width, 1)];
    }
    
    // 绘制文字和图标
    {
        UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
        [UIColorFromRGB(0x2e2e2e)set];
        NSString *drawString = @"历史累计步数";
        [drawString drawAtPoint:CGPointMake(10, rect.size.height*0.25-10) withFont:font];
    }
    
    {
        UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
        [UIColorFromRGB(0x2e2e2e)set];
        NSString *drawString = @"步";
        [drawString drawAtPoint:CGPointMake(rect.size.width-25, rect.size.height*0.25-10) withFont:font];
    }
    
    // 绘制步数
    {
        _totalSteps = (_totalSteps > 999999999) ? 999999999 :_totalSteps;
        NSString *stepsString = [NSString stringWithFormat:@"%lu",(unsigned long)_totalSteps];
        NSString *string = @"000000000";
        string = [string substringToIndex:string.length - stepsString.length];
        string = [string stringByAppendingString:stepsString];
        
        UIFont *font = [UIFont fontWithName:@"Arial" size:36];
        [UIColorFromRGB(0x999999)set];
        
        CGSize size = [string sizeWithFont:font];
        CGFloat originY = (rect.size.height*0.5- size.height)*0.5 + 6-10;
        CGRect frame = CGRectMake(70, originY, rect.size.width-80, 40);
        [string drawInRect:frame withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
    }
    
    // 绘制竖线
    {
        UIImage *image = [UIImage imageNamed:@"cs_vline_image"];
        [image drawInRect:CGRectMake(rect.size.width*0.5-0.5, rect.size.height*0.5-10, 1, rect.size.height*0.5+10)];
    }
    
    // 绘制距离与卡路里
    {
        UIImage *rulerImage = [UIImage imageNamed:@"cs_ruler_icon_gray"];
        [rulerImage drawAtPoint:CGPointMake(20, rect.size.height*0.5+20-10)];
        
        [[UIColor blackColor]set];
        UIFont *font = [UIFont fontWithName:@"Arial" size:14];
        NSString *drawString = @"距离(米)";
        [drawString drawAtPoint:CGPointMake(55, rect.size.height*0.5+18-10) withFont:font];
        
        [UIColorFromRGB(0x999999)set];
        
        _totalDistance = (_totalDistance > 9999999) ? 9999999 :_totalDistance;
        CGFloat distance = _totalDistance/100;
        NSString *stepsString = [NSString stringWithFormat:@"%0.0f",distance];
        NSString *string = @"0000000";
        string = [string substringToIndex:string.length - stepsString.length];
        string = [string stringByAppendingString:stepsString];
 
        font = [UIFont fontWithName:@"Arial" size:26];
        CGSize size = [string sizeWithFont:font];
        CGFloat originY = rect.size.height - size.height - 20-10;
        if (originY < rect.size.height*0.5+38-10)
        {
            originY = rect.size.height*0.5 + 38-10;
        }
        [string drawAtPoint:CGPointMake(20, originY) withFont:font];

    }
    
    {
        UIImage *rulerImage = [UIImage imageNamed:@"cs_calories_icon_gray"];
        [rulerImage drawAtPoint:CGPointMake(rect.size.width*0.5+20, rect.size.height*0.5+20-10)];
        
        [[UIColor blackColor]set];
        UIFont *font = [UIFont fontWithName:@"Arial" size:14];
        NSString *drawString = @"卡路消耗(千卡)";
        [drawString drawAtPoint:CGPointMake(rect.size.width*0.5 + 55, rect.size.height*0.5+18-10) withFont:font];
        
        [UIColorFromRGB(0x999999)set];
        _totalCalories = (_totalCalories > 9999999) ? 9999999 :_totalCalories;
        CGFloat calories = _totalCalories/10;
        NSString *stepsString = [NSString stringWithFormat:@"%.0f",calories];
        NSString *string = @"0000000";
        string = [string substringToIndex:string.length - stepsString.length];
        string = [string stringByAppendingString:stepsString];
        
        font = [UIFont fontWithName:@"Arial" size:26];
        CGSize size = [string sizeWithFont:font];
        CGFloat originY = rect.size.height - size.height - 20-10;
        if (originY < rect.size.height*0.5+38-10)
        {
            originY = rect.size.height*0.5 + 38-10;
        }
        [string drawAtPoint:CGPointMake(rect.size.width*0.5 + 55, originY) withFont:font];
    }

}
@end
