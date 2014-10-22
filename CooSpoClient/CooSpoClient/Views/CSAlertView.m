//
//  CSAlertView.m
//  CooSpoClient
//
//  Created by 马远征 on 14-10-15.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "CSAlertView.h"
#import "CooSpoDefine.h"
#import "AppDelegate.h"

@interface CSAlertView()
{
    UIImageView *_centerImageView;
    UILabel *_titlelabel;
    UILabel *_messagelabel;
}
@property (nonatomic, strong) NSMutableArray *buttonsArray;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;
@property (nonatomic,   copy) completeBlock block;
@end

@implementation CSAlertView

- (id)initWithTitle:(NSString*)title
            message:(NSString *)message
           complete:(completeBlock)block
  cancelButtonTitle:(NSString *)cancelButtonTitle
 confirmButtonTitle:(NSString *)confirmButtonTitle
{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self)
    {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:.35];
        UIImage *image = [UIImage imageNamed:@"alert_view_bg_image"];
        _centerImageView = [[UIImageView alloc]initWithImage:image];
        _centerImageView.userInteractionEnabled = YES;
        _centerImageView.frame = CGRectMake(0, 0, 280, 180);
        _centerImageView.center = CGPointMake(KScreenWidth*0.5, self.frame.size.height*0.5);
        [self addSubview:_centerImageView];
        
        _title = title;
        _message = message;
        _block = block;
        
        NSMutableArray *arrays = [NSMutableArray array];
        if (cancelButtonTitle)
        {
            [arrays addObject:cancelButtonTitle];
        }
        if (confirmButtonTitle)
        {
            [arrays addObject:confirmButtonTitle];
        }
        
        self.buttonsArray = arrays;
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    if (_title)
    {
        _titlelabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 15, 280, 24)];
        [_titlelabel setBackgroundColor:[UIColor clearColor]];
        [_titlelabel setTextColor:[UIColor blackColor]];
        [_titlelabel setTextAlignment:NSTextAlignmentCenter];
        [_titlelabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
        [_titlelabel setNumberOfLines:2];
        [_titlelabel setLineBreakMode:NSLineBreakByWordWrapping];
        [_titlelabel setText:_title];
        [_centerImageView addSubview:_titlelabel];
    }
    // 设置内容
    if (_message)
    {
        _messagelabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 35, 280, 100)];
        [_messagelabel setBackgroundColor:[UIColor clearColor]];
        [_messagelabel setTextColor:[UIColor colorWithRed:0.365 green:0.365 blue:0.365 alpha:1.0]];
        [_messagelabel setTextAlignment:NSTextAlignmentCenter];
        [_messagelabel setFont:[UIFont fontWithName:@"Helvetica" size:17]];
        [_messagelabel setNumberOfLines:0];
        [_messagelabel setLineBreakMode:NSLineBreakByWordWrapping];
        [_messagelabel setText:_message];
        [_centerImageView addSubview:_messagelabel];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)show
{
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [delegate.window addSubview:self];
    [self fadeIn];
}


- (void)showInView:(UIView *)aView animated:(BOOL)animated
{
    [aView addSubview:self];
    if (animated) {
        [self fadeIn];
    }
}


- (void)fadeIn
{
    self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.alpha = 0;
    [UIView animateWithDuration:.25 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void)fadeOut
{
    [UIView animateWithDuration:.25 animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}



- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *myTouch = [touches anyObject];
    if ([myTouch.view isEqual:self])
    {
        [self fadeOut];
    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    size_t locationsCount = 2;
    CGFloat locations[2] = {0.0f, 1.0f};
    CGFloat colors[8] = {0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.75f};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
    CGColorSpaceRelease(colorSpace);
    
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    float radius = MIN(self.bounds.size.width , self.bounds.size.height) ;
    CGContextDrawRadialGradient (context, gradient, center, 0, center, radius, kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient);
}

@end
