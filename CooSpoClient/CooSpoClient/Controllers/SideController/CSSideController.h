//
//  CSSideController.h
//  CooSpoClient
//
//  Created by 马远征 on 14-10-10.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSSideController : UIViewController
@property (nonatomic, strong) UIViewController *leftViewController;
@property (nonatomic, strong) UIViewController *rightViewController;
@property (nonatomic, strong) UIViewController *rootViewController;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

- (id)initWithRootViewController:(UIViewController*)rootViewController_
               leftViewContrller:(UIViewController*)leftViewController_
             rightViewContorller:(UIViewController*)rightViewcontorller_;

// 设置一个新的根视图控制器
- (void)setRootViewController:(UIViewController *)rootViewController animated:(BOOL)animated;

// 显示左侧边控制器，如果存在
- (void)showLeftViewController:(BOOL)animated;

// 显示右侧边控制器，如果存在
- (void)showRightViewController:(BOOL)animated;

// 隐藏左或右侧边控制器，显示跟控制器，跟控制器必须存在
- (void)showRootViewController:(BOOL)animated;

- (void)performOpenSideMenu:(dispatch_block_t)block;
@end
