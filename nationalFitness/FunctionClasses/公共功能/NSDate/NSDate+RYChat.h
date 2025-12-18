//
//  NSDate+RYChat.h
//  RYKit
//
//  Created by zhangll on 16/8/23.
//  Copyright © 2016年 安徽软云信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDate+Extension.h"
#import "NSDate+Utilities.h"

@interface NSDate (RYChat)

- (NSString *)chatTimeInfo;

- (NSString *)conversaionTimeInfo;

- (NSString *)chatFileTimeInfo;

/**
 * 比较from和self的时间差值
 */
- (NSDateComponents *)deltaFrom:(NSDate *)from;

/**
 * 是否为今年
 */
- (BOOL)isThisYear;

/**
 * 是否为今天
 */
- (BOOL)isToday;

/**
 * 是否为昨天
 */
- (BOOL)isYesterday;

- (NSString *)dateDescription;
+ (NSDate *)dateFromLongLong:(long long)msSince1970;

@end
