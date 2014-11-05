//
//  CSRSportsGraphView.m
//  CooSpoClient
//
//  Created by 马远征 on 14/10/23.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "CSRSportsGraphView.h"
#import "CooSpoDefine.h"

@interface CSRSportsGraphView()
@property (nonatomic, strong) NSMutableArray *xyPointsArray;
@end

@implementation CSRSportsGraphView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)execUpdate:(NSArray*)resultArray
{
    self.xyPointsArray = nil;
    if (resultArray && resultArray.count > 0)
    {
        WEAKSELF;STRONGSELF;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *array = [NSMutableArray array];
            for (int i = 0; i < resultArray.count; i++)
            {
                id object = [resultArray objectAtIndex:i];
                if ([object isKindOfClass:[NSDictionary class]])
                {
                    NSDictionary *dic = (NSDictionary*)object;
                    NSInteger calorie = [dic[@"calorie"]integerValue]/10;
                    NSInteger steps = [dic[@"steps"]integerValue];
                    calorie = calorie > 500 ? 500:calorie;
                    steps = steps > 3000 ? 3000:steps;
                    
                    CGFloat xPoints = i*40+20;
                    CGFloat cPcg = (CGFloat)calorie/500.0;
                    CGFloat sPcg = (CGFloat)steps/3000.0;
                    CGFloat cyPoints = (1-cPcg)*151;
                    CGFloat syPoints = (1-sPcg)*151;
                    NSDictionary *retDic = @{@"xPoints":@(xPoints),@"calorie":@(cyPoints),@"steps":@(syPoints)};
                    [array addObject:retDic];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.xyPointsArray = [NSMutableArray arrayWithArray:array];
                [weakSelf setNeedsDisplay];
            });
        });
    }
    else
    {
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect
{
    // 绘制矩形图
    for (int i = 0 ; i < self.xyPointsArray.count; i++)
    {
        NSDictionary *dic = [self.xyPointsArray objectAtIndex:i];
        if (dic == nil)
        {
            continue;
        }
        CGFloat xPoints = [dic[@"xPoints"]floatValue];
        CGFloat cyPoints = [dic[@"calorie"]floatValue];
        CGFloat syPoint = [dic[@"steps"]floatValue];
        if (fabs(syPoint) < self.bounds.size.height - 21)
        {
            CGContextRef currentContext = UIGraphicsGetCurrentContext();
            CGContextSaveGState(currentContext);
            [[UIColor colorWithRed:0.443 green:0.627 blue:0.651 alpha:1.0]set];
            CGMutablePathRef path = CGPathCreateMutable();
            CGRect sRect = CGRectMake(xPoints, fabs(syPoint), 20, rect.size.height-fabs(syPoint) -21);
            CGPathAddRect(path, NULL, sRect);
            CGContextAddPath(currentContext, path);
            CGContextDrawPath(currentContext, kCGPathFill);
            CGPathRelease(path);
            CGContextRestoreGState(currentContext);
        }
        if (fabs(cyPoints) < self.bounds.size.height - 21)
        {
            CGContextRef currentContext = UIGraphicsGetCurrentContext();
            CGContextSaveGState(currentContext);
            [[UIColor colorWithRed:0.180 green:0.357 blue:0.388 alpha:1.0]set];
            CGMutablePathRef path = CGPathCreateMutable();
            CGRect sRect = CGRectMake(xPoints, fabs(cyPoints), 20, rect.size.height-fabs(cyPoints)-21);
            CGPathAddRect(path, NULL, sRect);
            CGContextAddPath(currentContext, path);
            CGContextDrawPath(currentContext, kCGPathFill);
            CGPathRelease(path);
            CGContextRestoreGState(currentContext);
        }
    }
    // 绘制底部红线
    {
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        CGContextSaveGState(currentContext);
        
        [[UIColor colorWithRed:1.000 green:0.302 blue:0.302 alpha:1.0]set];
        CGMutablePathRef pathRef = CGPathCreateMutable();
        CGPathMoveToPoint(pathRef, NULL, 0, rect.size.height-21);
        CGPathAddLineToPoint(pathRef, NULL,rect.size.width, rect.size.height-21);
        
        CGContextAddPath(currentContext, pathRef);
        CGContextSetLineWidth(currentContext, 2.0);
        CGContextDrawPath(currentContext, kCGPathStroke);
        
        CGPathRelease(pathRef);
        CGContextRestoreGState(currentContext);
    }
    
    // 绘制短线
    {

        [[UIColor colorWithRed:1.000 green:0.302 blue:0.302 alpha:1.0]set];
        UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
        for (int i = 1 ; i <= 24 ;i++)
        {
            NSString *string = [NSString stringWithFormat:@"%d",i];
            if (i == 24)
            {
                string = @"0 ";
            }
            CGSize size = [string sizeWithFont:font];
            [string drawAtPoint:CGPointMake(160*i-size.width*0.5, rect.size.height-17) withFont:font];
        }
    }
    
    // 绘制刻度
    {
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        CGContextSaveGState(currentContext);
        
        [[UIColor colorWithRed:1.000 green:0.302 blue:0.302 alpha:1.0]set];
        CGMutablePathRef pathRef = CGPathCreateMutable();
        for (int i = 1 ; i <= 24 ;i++)
        {
            CGPathMoveToPoint(pathRef, NULL, 160*i-1, rect.size.height-20);
            CGPathAddLineToPoint(pathRef, NULL,160*i-1, rect.size.height-15);
        }
        
        CGContextAddPath(currentContext, pathRef);
        CGContextSetLineWidth(currentContext, 2.0);
        CGContextDrawPath(currentContext, kCGPathStroke);
        
        CGPathRelease(pathRef);
        CGContextRestoreGState(currentContext);
    }
}

@end
