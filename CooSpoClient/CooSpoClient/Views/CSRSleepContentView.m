//
//  CSRSleepContentView.m
//  CooSpoClient
//
//  Created by 马远征 on 14/10/27.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "CSRSleepContentView.h"

@implementation CSRSleepContentView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // 绘制虚横线
    {
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        CGContextSaveGState(currentContext);
        [[UIColor colorWithRed:0.863 green:0.863 blue:0.863 alpha:1.0]set];
        CGMutablePathRef pathRef = CGPathCreateMutable();
        CGPathMoveToPoint(pathRef, NULL, 40, rect.size.height*0.5-20);
        CGPathAddLineToPoint(pathRef, NULL,rect.size.width-20, rect.size.height*0.5-20);
        CGContextAddPath(currentContext, pathRef);
        CGContextSetLineWidth(currentContext, 2.0);
        CGContextDrawPath(currentContext, kCGPathStroke);
        CGPathRelease(pathRef);
    }
    // 绘制竖线
    {
        
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        CGContextSaveGState(currentContext);
        [[UIColor colorWithRed:0.514 green:0.690 blue:0.710 alpha:1.0]set];
        CGMutablePathRef pathRef = CGPathCreateMutable();
        CGPathMoveToPoint(pathRef, NULL, 40, 0);
        CGPathAddLineToPoint(pathRef, NULL,40, rect.size.height-40);
        CGContextAddPath(currentContext, pathRef);
        CGContextSetLineWidth(currentContext, 2.0);
        CGContextDrawPath(currentContext, kCGPathStroke);
        CGPathRelease(pathRef);
    }
    // 绘制短横线
    {
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        CGContextSaveGState(currentContext);
        [[UIColor colorWithRed:0.514 green:0.690 blue:0.710 alpha:1.0]set];
        CGMutablePathRef pathRef = CGPathCreateMutable();
        CGPathMoveToPoint(pathRef, NULL, 35,  rect.size.height*0.5-20);
        CGPathAddLineToPoint(pathRef, NULL,40,  rect.size.height*0.5-20);
        CGPathMoveToPoint(pathRef, NULL, 35, rect.size.height-40);
        CGPathAddLineToPoint(pathRef, NULL,40,rect.size.height-40);
        CGContextAddPath(currentContext, pathRef);
        CGContextSetLineWidth(currentContext, 2.0);
        CGContextDrawPath(currentContext, kCGPathStroke);
        CGPathRelease(pathRef);
    }
    
    // 绘制文字
    {
        UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
        [[UIColor colorWithRed:0.588 green:0.741 blue:0.227 alpha:1.0]set];
        NSString *drawString = @"深睡眠";
        [drawString drawInRect:CGRectMake(10, 5, 20, 80)
                      withFont:font
                 lineBreakMode:NSLineBreakByWordWrapping
                     alignment:NSTextAlignmentCenter];
        
        [[UIColor colorWithRed:0.565 green:0.804 blue:0.718 alpha:1.0]set];
        drawString = @"浅睡眠";
        [drawString drawInRect:CGRectMake(10,rect.size.height*0.5-15, 20, 80)
                      withFont:font
                 lineBreakMode:NSLineBreakByWordWrapping
                     alignment:NSTextAlignmentCenter];
    }
    
}

@end
