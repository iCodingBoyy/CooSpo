//
//  CSAlertView.h
//  CooSpoClient
//
//  Created by 马远征 on 14-10-15.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^completeBlock) (NSUInteger buttonIndex);

@interface CSAlertView : UIView
- (id)initWithTitle:(NSString*)title
            message:(NSString *)message
           complete:(completeBlock)block
  cancelButtonTitle:(NSString *)cancelButtonTitle
 confirmButtonTitle:(NSString *)confirmButtonTitle;
- (void)show;

@end
