//
//  CSSleepDataOperation.h
//  CooSpoClient
//
//  Created by 马远征 on 14-10-17.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSSleepDataOperation : NSOperation
- (id)initWithData:(NSData*)receiveData_ utcTime:(UInt32)utcTime_;
@end
