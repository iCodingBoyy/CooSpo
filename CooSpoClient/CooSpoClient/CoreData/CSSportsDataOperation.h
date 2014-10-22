//
//  CSSportsDataOperation.h
//  CooSpoClient
//
//  Created by 马远征 on 14-10-17.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSSportsDataOperation : NSOperation
- (instancetype)initWithData:(NSData*)receiveData utcTime:(UInt32)utcTime;
@end
