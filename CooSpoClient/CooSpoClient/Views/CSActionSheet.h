//
//  CSActionSheet.h
//  CooSpoClient
//
//  Created by 马远征 on 14-10-17.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^completeBlock)(NSInteger result);

@interface CSActionSheet : UIView
- (id)initWithTitle:(NSString*)title Unit:(NSString*)uint Parmas:(NSArray*)parmas;
- (void)show:(completeBlock)block;
@end
