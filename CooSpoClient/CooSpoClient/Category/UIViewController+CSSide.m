//
//  UIViewController+CSSide.m
//  CooSpoClient
//
//  Created by 马远征 on 14-10-10.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "UIViewController+CSSide.h"

@implementation UIViewController (CSSide)
- (CSSideController*)sideController
{
    if ([self.parentViewController isKindOfClass:[CSSideController class]])
    {
        return (CSSideController*)(self.parentViewController);
    }
    return nil;
}
@end
