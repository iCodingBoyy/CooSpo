//
//  CSRSleepGraphView.m
//  CooSpoClient
//
//  Created by 马远征 on 14/10/27.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "CSRSleepGraphView.h"
#import "CooSpoDefine.h"

@interface CSRSleepGraphView()
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation CSRSleepGraphView

+ (Class)layerClass {
    return [CATiledLayer class];
}

- (NSDateFormatter*)dateFormatter
{
    if (_dateFormatter == nil)
    {
        _dateFormatter = [[NSDateFormatter alloc]init];
        [_dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    return _dateFormatter;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setXPointsArray:(NSArray *)xPointsArray
{
    if (xPointsArray != _xPointsArray)
    {
        _xPointsArray = xPointsArray;
    }
}

- (void)drawGraph:(NSArray*)xyPoints
{
    self.xyPointsArray = nil;
    if (xyPoints && xyPoints.count > 0)
    {
        WEAKSELF; STRONGSELF;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            // 计算每个睡眠数据的坐标值
            NSString *hour = [_xPointsArray firstObject];
            NSString *stDateString = [NSString stringWithFormat:@"%@ %@:00:00",self.dateString,hour];
            [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *stDate = [self.dateFormatter dateFromString:stDateString];
            NSTimeInterval stTime = [stDate timeIntervalSince1970];
            
            NSMutableArray *array = [NSMutableArray array];
            for (NSDictionary *dic in xyPoints)
            {
                NSDate *date = dic[@"utcTime"];
                if (date)
                {
                    NSTimeInterval time = [date timeIntervalSince1970];
                    NSTimeInterval diffTime = (time - stTime) > 0 ? (time - stTime) : 0;
                    CGFloat xPoint = ((NSInteger)(diffTime/300))*12+2;
                    CGFloat yPoint = [dic[@"sleepData"]integerValue] < 1 ? 0:(186*0.5-20);
                    NSString *xyPoint = NSStringFromCGPoint(CGPointMake(xPoint, yPoint));
                    [array addObject:xyPoint];
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

- (void)drawGraphs
{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(currentContext);
    for (NSString *xyPoints in self.xyPointsArray)
    {
        CGPoint xyPoint = CGPointFromString(xyPoints);
        if (xyPoint.y >= self.bounds.size.height*0.5-20)
        {
            [[UIColor colorWithRed:0.569 green:0.804 blue:0.722 alpha:1.0]set];
        }
        else
        {
            [[UIColor colorWithRed:0.659 green:0.784 blue:0.424 alpha:1.0]set];
        }
        CGMutablePathRef path = CGPathCreateMutable();
        CGRect sRect = CGRectMake(xyPoint.x, fabs(xyPoint.y), 10, self.bounds.size.height - 40-fabs(xyPoint.y));
        CGPathAddRect(path, NULL, sRect);
        CGContextAddPath(currentContext, path);
        CGContextDrawPath(currentContext, kCGPathFill);
        CGPathRelease(path);
    }
    CGContextRestoreGState(currentContext);
}

- (void)drawHorizontalAxis
{
    // 绘制刻度线
    if (_xPointsArray && _xPointsArray.count > 0)
    {
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        CGContextSaveGState(currentContext);
        
        [[UIColor colorWithRed:1.000 green:0.302 blue:0.302 alpha:1.0]set];
        CGMutablePathRef pathRef = CGPathCreateMutable();
        for (int i = 1 ; i <= _xPointsArray.count ;i++)
        {
            CGPathMoveToPoint(pathRef, NULL, 144*i-1, self.bounds.size.height-40);
            CGPathAddLineToPoint(pathRef, NULL,144*i-1, self.bounds.size.height-35);
        }
        
        CGContextAddPath(currentContext, pathRef);
        CGContextSetLineWidth(currentContext, 2.0);
        CGContextDrawPath(currentContext, kCGPathStroke);
        
        CGPathRelease(pathRef);
        CGContextRestoreGState(currentContext);
    }
    
    // 绘制刻度值
    if (_xPointsArray && _xPointsArray.count > 0)
    {
        [[UIColor colorWithRed:1.000 green:0.302 blue:0.302 alpha:1.0]set];
        UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
        
        for (int i = 0 ; i < _xPointsArray.count ;i++)
        {
            NSString *markValue = [_xPointsArray objectAtIndex:i];
            if ([markValue integerValue] == 0)
            {
                [[UIColor colorWithRed:0.733 green:0.733 blue:0.733 alpha:1.0]set];
                UIFont *sfont = [UIFont fontWithName:@"Helvetica-Bold" size:16];
                NSString *drawString = @"|日分界线";
                [drawString drawAtPoint:CGPointMake(144*i-2, self.bounds.size.height-25) withFont:sfont];
            }
            [[UIColor colorWithRed:1.000 green:0.302 blue:0.302 alpha:1.0]set];
            CGSize size = [markValue sizeWithFont:font];
            if (i == 0)
            {
                [markValue drawAtPoint:CGPointMake(144*i, self.bounds.size.height-35) withFont:font];
            }
            else if (i == _xPointsArray.count - 1)
            {
                [markValue drawAtPoint:CGPointMake(144*i-size.width, self.bounds.size.height-35) withFont:font];
            }
            else
            {
                [markValue drawAtPoint:CGPointMake(144*i-size.width*0.5, self.bounds.size.height-35) withFont:font];
            }
        }
    }
}


- (void)drawBottomLine
{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(currentContext);
    [[UIColor colorWithRed:0.871 green:0.325 blue:0.235 alpha:1.0]set];
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathMoveToPoint(pathRef, NULL, 0,  self.bounds.size.height-40);
    CGPathAddLineToPoint(pathRef, NULL, self.bounds.size.width, self.bounds.size.height-40);
    CGContextAddPath(currentContext, pathRef);
    CGContextSetLineWidth(currentContext, 2.0);
    CGContextDrawPath(currentContext, kCGPathStroke);
    CGPathRelease(pathRef);
}

- (void)drawRect:(CGRect)rect
{
    // 绘制图表
    [self drawGraphs];
    // 绘制横坐标
    [self drawHorizontalAxis];
    // 绘制短横线
    [self drawBottomLine];
}


@end
