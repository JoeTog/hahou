//
//  DatabaseQueue.h
//  SummaryHoperun
//
//  Created by 程long on 14-7-30.
//  Copyright (c) 2014年 chenglong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FMDB.h"

FOUNDATION_EXPORT      NSString             *const databaseKey;

@interface DatabaseQueue : NSObject

/*!
 @method
 @abstract      数据库队列的实体单例
 
 @note          该对象中的对象属性不可被多线程共享访问修改
 
 @result        返回数据库队列的单例对象
 */
+ (FMDatabaseQueue *)shareInstance;

@end
