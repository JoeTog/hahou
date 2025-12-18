//
//  YourDatabaseQueue.h
//  SummaryHoperun
//
//  Created by 程long on 14-7-30.
//  Copyright (c) 2014年 chenglong. All rights reserved.
//

#import "DatabaseQueue.h"

@interface NFDatabaseQueue : DatabaseQueue

/*!
 @method
 @abstract      创建需要的数据库表
 
 @note          可以一次性创建，也可多次创建
 
 @result        在数据库中创建出需要用的数据库表
 */
-(void)createAllTables;

/*!
 @method
 @abstract      清除数据库数据
 
 @note          可以和沙河内缓存文件一起清除，在需要清楚缓存数据的时候使用
 
 @result        清除所有表跟用户相关的数据
 */
-(BOOL)clearCache;



//插入缓存数据
+ (BOOL)insertManagerCache: (NSString *)url dataStr:(NSString *)dataStr;

//取出缓存数据
+ (NSString *)selectManagerCache: (NSString *)url;

@end
