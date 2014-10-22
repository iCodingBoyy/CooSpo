//
//  YZProgressHUD.h
//  CarPooling_Project
//
//  Created by 马远征 on 14-5-31.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YZProgressHUD : NSObject
+ (instancetype)HUD;

- (void)showWithError:(UIWindow *)window labelText:(NSString *)labelText detailText:(NSString *)detailText;
- (void)showWithSuccess:(UIWindow *)window labelText:(NSString *)labelText detailText:(NSString *)detailText;

- (void)showOnWindow:(UIWindow*)window
           labelText:(NSString*)labelText
          detailText:(NSString*)detailText;

- (void)showOnView:(UIView*)view
         labelText:(NSString*)labelText
        detailText:(NSString*)detailText;

- (void)hideWithSuccess:(NSString*)labelText
             detailText:(NSString*)detailText;

- (void)hideWithError:(NSString*)labelText
           detailText:(NSString*)detailText;

- (void)showProgressOnView:(UIView *)view
                 labelText:(NSString *)labelText
                detailText:(NSString *)detailText;

- (void)changeHUDWithText:(NSString*)labelText
               detailText:(NSString*)detailText;

- (void)updateProgress:(double)value
             labelText:(NSString *)labelText
            detailText:(NSString *)detailText;

- (void)hide;
@end
