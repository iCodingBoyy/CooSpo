//
//  CSNavigationController.m
//  CooSpoClient
//
//  Created by 马远征 on 14-10-10.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "CSNavigationController.h"
#import "CooSpoDefine.h"

@implementation CSNavigationController
+ (instancetype)shared
{
    static dispatch_once_t pred;
    static CSNavigationController *sharedinstance = nil;
    dispatch_once(&pred, ^{
        // 使用storyBoard初始化控制器
        sharedinstance = [[self alloc] init];
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        sharedinstance = [storyBoard instantiateViewControllerWithIdentifier:@"CooSpoController"];
    });
    return sharedinstance;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // 设置阴影背景图片透明
//    [[UINavigationBar appearance]setShadowImage:[UIImage imageWithColor:[UIColor clearColor]]];
    
    NSString *imageName = iOS7 ? @"nav_bg_image_ios7":@"nav_bg_image";
    UIImage *bgImage = [UIImage imageNamed:imageName];
    bgImage = [bgImage stretchableImageWithLeftCapWidth:bgImage.size.width*0.5 topCapHeight:bgImage.size.height*0.5];
    [self.navigationBar setTranslucent:NO];
    [self.navigationBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];
    
    UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:21.0];
    [[UINavigationBar appearance]setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:font}];
}

#pragma mark -
#pragma mark 重载

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (animated)
    {
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.3];
        [animation setType: kCATransitionMoveIn];
        [animation setSubtype: kCATransitionFromRight];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
        [self.view.layer addAnimation:animation forKey:nil];
        [super pushViewController:viewController animated:NO];
    }
    else
    {
        [super pushViewController:viewController animated:animated];
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    if (animated)
    {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.3;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionReveal;
        transition.delegate = self;
        [self.view.layer addAnimation:transition forKey:nil];
        return  [super popViewControllerAnimated:NO];
    }
    else
    {
        return [super popViewControllerAnimated:animated];
    }
}

- (NSArray*)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (animated)
    {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.3;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionReveal;
        transition.delegate = self;
        [self.view.layer addAnimation:transition forKey:nil];
        return  [self popToViewController:viewController animated:NO];
    }
    else
    {
        return [super popToViewController:viewController animated:animated];
    }
}

- (NSArray*)popToRootViewControllerAnimated:(BOOL)animated
{
    if (animated)
    {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.3;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionReveal;
        transition.delegate = self;
        [self.view.layer addAnimation:transition forKey:nil];
        return  [self popToRootViewControllerAnimated:NO];
    }
    else
    {
        return [super popToRootViewControllerAnimated:animated];
    }
}

#pragma mark -
#pragma mark 子视图旋转方向

- (BOOL)shouldAutorotate
{
    return self.topViewController.shouldAutorotate;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return self.topViewController.supportedInterfaceOrientations;
}

@end
