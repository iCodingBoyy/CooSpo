//
//  CSSideController.m
//  CooSpoClient
//
//  Created by 马远征 on 14-10-10.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "CSSideController.h"
#import "CooSpoDefine.h"

#define KFrameSizeWidth self.view.frame.size.width
#define KFrameSizeHeight self.view.frame.size.height

#define KLeftSideWidth 210.0f
#define KRightSideWidth 210.0f

@interface CSSideController()<UIGestureRecognizerDelegate>
{
    
}
@property (nonatomic, strong) UIView *rootContentView;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) BOOL panMovingOnRight;
@property (nonatomic, copy  ) dispatch_block_t dispatchBlock;
@end

@implementation CSSideController

- (void)performOpenSideMenu:(dispatch_block_t)block
{
    _dispatchBlock = block;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController_
               leftViewContrller:(UIViewController *)leftViewController_
             rightViewContorller:(UIViewController *)rightViewcontorller_
{
    self = [super init];
    if (self)
    {
        NSAssert(rootViewController_ != nil, @"你必须设置一个根视图");
        self.leftViewController = leftViewController_;
        self.rootViewController = rootViewController_;
        self.rightViewController = rightViewcontorller_;
    }
    return self;
}

- (void)setUp
{
    _rootContentView = [[UIView alloc]initWithFrame:self.view.bounds];
    _rootContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _rootContentView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_rootContentView];
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureRecognizer:)];
    [_panGestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:_panGestureRecognizer];
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureRecognizer:)];
    [_tapGestureRecognizer setDelegate:self];
    [_tapGestureRecognizer setEnabled:NO];
    [self.rootContentView addGestureRecognizer:_tapGestureRecognizer];
}


- (void)showShadow:(BOOL)show
{
    _rootViewController.view.layer.shadowOpacity = 0.8;
    _rootViewController.view.layer.shadowRadius = 4.0f;
    _rootViewController.view.layer.shadowOffset = CGSizeZero;
    CGRect bounds = _rootViewController.view.bounds;
    _rootViewController.view.layer.shadowPath   = [UIBezierPath bezierPathWithRect:bounds].CGPath;
}

- (void)loadView
{
    [super loadView];
    UIView *view = [[UIView alloc]initWithFrame:[[UIScreen mainScreen]applicationFrame]];
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUp];
    // 初始化加载根视图
    NSAssert(self.rootViewController != nil, @"你必须设置一个根视图控制器");
    self.rootViewController.view.autoresizingMask = self.view.autoresizingMask;
    [self.rootContentView addSubview:self.rootViewController.view];
    [self showShadow:YES];
}

- (void)setRootViewController:(UIViewController *)rootViewController
{
    if (_rootViewController != rootViewController)
    {
        if (_rootViewController)
        {
            [_rootViewController removeFromParentViewController];
        }
        _rootViewController = rootViewController;
        if (_rootViewController)
        {
            [self addChildViewController:_rootViewController];
        }
    }
}

- (void)setLeftViewController:(UIViewController *)leftViewController
{
    if (_leftViewController != leftViewController)
    {
        if (_leftViewController)
        {
            [_leftViewController removeFromParentViewController];
        }
        _leftViewController = leftViewController;
        if (_leftViewController)
        {
            [self addChildViewController:_leftViewController];
        }
    }
}

- (void)setRightViewController:(UIViewController *)rightViewController
{
    if (_rightViewController != rightViewController)
    {
        if (_rightViewController)
        {
            [_rightViewController removeFromParentViewController];
        }
        _rightViewController = rightViewController;
        if (_rightViewController)
        {
            [self addChildViewController:_rightViewController];
        }
    }
}

- (void)setRootViewController:(UIViewController *)rootViewController animated:(BOOL)animated
{
    NSAssert(rootViewController != nil, @"新的根视图控制器不能为空！");
    if (rootViewController == nil)
    {
        return;
    }
    if (_rootViewController == rootViewController)
    {
        // 如果是同一个控制器则隐藏侧边栏
        [self showRootViewController:YES];
        return;
    }
    
    if (self.leftViewController)
    {
        self.leftViewController.view.userInteractionEnabled = NO;
    }
    if (self.rightViewController)
    {
        self.rightViewController.view.userInteractionEnabled = NO;
    }
    
    UIViewController *previousController = _rootViewController;
    
    _rootViewController = rootViewController;
    [self addChildViewController:_rootViewController];
    
    _rootViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    CGFloat sideWidth = _panMovingOnRight ? KLeftSideWidth : KRightSideWidth;
    CGFloat offset = sideWidth + (self.view.frame.size.width-sideWidth)/2.0;
    offset = _panMovingOnRight ? offset : -offset;
    
    WEAKSELF;
    [self showShadow:YES];
    [UIView animateWithDuration:0.2 animations:^{
        STRONGSELF;
        
        CGAffineTransform tranform = CGAffineTransformMakeTranslation(offset, 0.0f);
        strongSelf.rootContentView.transform = CGAffineTransformScale(tranform,1.0,1.0);
        
    } completion:^(BOOL finished) {
        STRONGSELF;
        [strongSelf.rootContentView addSubview:_rootViewController.view];
        [strongSelf.rootViewController didMoveToParentViewController:weakSelf];
        
        [previousController willMoveToParentViewController:nil];
        [previousController removeFromParentViewController];
        [previousController.view removeFromSuperview];
        
        _panMovingOnRight = NO;
        [UIView animateWithDuration:0.4 animations:^{
            
            STRONGSELF;
            strongSelf.rootContentView.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.0,1.0);
            
        }completion:^(BOOL finished)
         {
             STRONGSELF;
             [strongSelf.leftViewController.view removeFromSuperview];
             [strongSelf.rightViewController.view removeFromSuperview];
         }];
    }];
}



- (void)showLeftViewController:(BOOL)animated
{
    if (_leftViewController == nil)
    {
        return;
    }
    if (_dispatchBlock)
    {
        _dispatchBlock();
    }
    
    [self.view endEditing:YES];
    if (_leftViewController.view.superview == nil)
    {
        _leftViewController.view.frame = self.view.bounds;
        _leftViewController.view.autoresizingMask = self.view.autoresizingMask;
        [self.view insertSubview:_leftViewController.view belowSubview:self.rootContentView];
    }
    
    NSTimeInterval animatedTime = 0;
    if (animated)
    {
        CGFloat originX = self.rootContentView.frame.origin.x;
        animatedTime = ABS(KLeftSideWidth - originX) / KLeftSideWidth * 0.35;
    }
    
    WEAKSELF;
    [UIView animateWithDuration:animatedTime animations:^{
        
        STRONGSELF;
//        CGFloat scale = ABS(600 - ABS(KLeftSideWidth)) / 600;
//        scale = MAX(0.8, scale);
        CGAffineTransform transform = CGAffineTransformMakeTranslation(KLeftSideWidth, 0.0f);
        strongSelf.rootContentView.transform = CGAffineTransformScale(transform,1.0,1.0);
        
    }completion:^(BOOL finished) {
        
        STRONGSELF;
        strongSelf.panMovingOnRight = YES;
        strongSelf.tapGestureRecognizer.enabled = YES;
        strongSelf.leftViewController.view.userInteractionEnabled = YES;
        strongSelf.rootViewController.view.userInteractionEnabled = NO;
    }];
}

- (void)showRightViewController:(BOOL)animated
{
    if (_rightViewController == nil)
    {
        return;
    }
    
    [self.view endEditing:YES];
    if (_rightViewController.view.superview == nil)
    {
        _rightViewController.view.frame = self.view.bounds;
        _rightViewController.view.autoresizingMask = self.view.autoresizingMask;
        [self.view insertSubview:_rightViewController.view belowSubview:self.rootContentView];
    }
    
    NSTimeInterval animatedTime = 0;
    if (animated)
    {
        CGFloat originX = self.rootContentView.frame.origin.x;
        animatedTime = ABS(KRightSideWidth + originX) / KRightSideWidth * 0.35;
    }
    
    WEAKSELF;
    [UIView animateWithDuration:animatedTime animations:^{
        STRONGSELF;
        
//        CGFloat scale = ABS(600 - ABS(KRightSideWidth)) / 600;
//        scale = MAX(0.8, scale);
        CGAffineTransform transform = CGAffineTransformMakeTranslation(-KRightSideWidth, 0.0f);
        strongSelf.rootContentView.transform = CGAffineTransformScale(transform,1.0,1.0);
        
    }completion:^(BOOL finished) {
        STRONGSELF;
        strongSelf.panMovingOnRight = NO;
        strongSelf.tapGestureRecognizer.enabled = YES;
        strongSelf.rootViewController.view.userInteractionEnabled = NO;
        strongSelf.rightViewController.view.userInteractionEnabled = YES;
    }];
}

- (void)showRootViewController:(BOOL)animated
{
    _panMovingOnRight = NO;
    
    NSTimeInterval animatedTime = 0;
    UIView *view = _rootContentView;
    if (animated)
    {
        animatedTime = ABS(view.frame.origin.x / (view.frame.origin.x > 0?KLeftSideWidth:KRightSideWidth)) * 0.35;
    }
    
    if (self.leftViewController)
    {
        self.leftViewController.view.userInteractionEnabled = NO;
    }
    
    if (self.rightViewController)
    {
        self.rightViewController.view.userInteractionEnabled = NO;
    }
    
    WEAKSELF;
    [UIView animateWithDuration:animatedTime animations:^{
        
        STRONGSELF;
        strongSelf.rootContentView.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.0,1.0);
        
    }completion:^(BOOL finished)
     {
         STRONGSELF;
         [strongSelf.tapGestureRecognizer setEnabled:NO];
         [strongSelf.rootViewController.view setUserInteractionEnabled:YES];
         [strongSelf.leftViewController.view removeFromSuperview];
         [strongSelf.rightViewController.view removeFromSuperview];
         
     }];
    
}

#pragma mark -
#pragma mark 手势及其协议

// 锁定竖直方向的平移手势
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == _panGestureRecognizer)
    {
        // 平移速度小于600，切水平偏移大于垂直偏移(左右移动),启用手势
        UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer*)gestureRecognizer;
        CGPoint translation = [panGesture translationInView:self.view];
        CGPoint velocity = [panGesture velocityInView:self.view];
        if (velocity.x < 600 && ABS(translation.x) / ABS(translation.y) > 1 )
        {
            return YES;
        }
        return NO;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer == _tapGestureRecognizer && _tapGestureRecognizer.enabled)
    {
        if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"] ||
            [NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewLabel"] ||
            [NSStringFromClass([touch.view class]) isEqualToString:@"UIImageView"])
        {
            return NO;
        }
    }
    return YES;
}

- (void)tapGestureRecognizer:(UITapGestureRecognizer*)tapGestureRecognizer
{
    [self showRootViewController:YES];
}

- (void)panGestureRecognizer:(UIPanGestureRecognizer*)panGestureRecognizer
{
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        _startPoint = _rootContentView.frame.origin;
        CGPoint velocity = [_panGestureRecognizer velocityInView:self.view];
        if (velocity.x > 0)
        {
            // 右移显示左侧边
            if(_startPoint.x >= 0 && _leftViewController && _leftViewController.view.superview == nil)
            {
                _leftViewController.view.frame = self.view.bounds;
                _leftViewController.view.autoresizingMask = self.view.autoresizingMask;
                [self.view insertSubview:_leftViewController.view belowSubview:self.rootContentView];
                
                if (_rightViewController && _rightViewController.view.superview)
                {
                    [_rightViewController.view removeFromSuperview];
                }
            }
        }
        else
        {
            // 左移显示右侧边
            if (_startPoint.x <= 0 && _rightViewController && _rightViewController.view.superview == nil)
            {
                // 插入右边侧边视图
                _rightViewController.view.frame = self.view.bounds;
                _rightViewController.view.autoresizingMask = self.view.autoresizingMask;
                [self.view insertSubview:_rightViewController.view belowSubview:self.rootContentView];
                
                if (_leftViewController && _leftViewController.view.superview)
                {
                    [_leftViewController.view removeFromSuperview];
                }
            }
        }
        return;
    }
    
    CGPoint translation = [panGestureRecognizer translationInView:self.view];
    CGFloat xOffSet = _startPoint.x + translation.x;
    if (xOffSet < 0)
    {
        // 向左滑动
        if (_rightViewController && _rightViewController.view.superview)
        {
            xOffSet = MAX(-200, xOffSet);
        }
        else
        {
            xOffSet = 0;
        }
    }
    
    if (xOffSet > 0)
    {
        // 向右滑动
        if (_leftViewController && _leftViewController.view.superview)
        {
            xOffSet = MIN(200, xOffSet);
        }
        else
        {
            xOffSet = 0;
        }
    }
    
    if (xOffSet != _rootContentView.frame.origin.x)
    {
        
//        CGFloat scale = ABS(600 - ABS(xOffSet)) / 600;
//        scale = MAX(0.8, scale);
        CGAffineTransform transform = CGAffineTransformMakeTranslation(xOffSet, 0.0f);
        self.rootContentView.transform = CGAffineTransformScale(transform,1.0,1.0);
    }
    
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        if (_rootContentView.frame.origin.x != 0 &&
            _rootContentView.frame.origin.x != KLeftSideWidth &&
            _rootContentView.frame.origin.x != -KRightSideWidth)
        {
            if (_panMovingOnRight && _rootContentView.frame.origin.x > 20)
            {
                [self showLeftViewController:YES];
            }
            else if(!_panMovingOnRight && _rootContentView.frame.origin.x < -20)
            {
                [self showRightViewController:YES];
            }
            else
            {
                [self showRootViewController:YES];
            }
        }
    }
    else
    {
        CGPoint velocity = [panGestureRecognizer velocityInView:self.view];
        if (velocity.x > 0)
        {
            _panMovingOnRight = YES;
        }
        else if(velocity.x < 0)
        {
            _panMovingOnRight = false;
        }
    }
}

@end
