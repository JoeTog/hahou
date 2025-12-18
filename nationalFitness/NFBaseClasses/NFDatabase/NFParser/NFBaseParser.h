//
//  NFParser.h
//  nationalFitness
//
//  Created by 程long on 14-10-28.
//  Copyright (c) 2014年 chenglong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PublicDefine.h"

@interface NFBaseParser : NSObject

/**
 *  统一解析报文，解密或者是判断错误
 *
 *  @param data 服务器返回的DATA报文
 *
 *  @return ID类型数据
 */
+ (id)gotDataParser : (NSData *)data;

+ (id)gotDataNoKeyParser : (NSData *)data;



//解析提取数组
-(NSArray*)ArrWithKey:(NSString *)key fromDict:(NSDictionary *)dict;

//解析提取字典
-(NSDictionary *)DictWithKey:(NSString *)key fromDict:(NSDictionary *)dict;

//解析提取字符串
-(NSString *)NSStringWithKey:(NSString *)key fromDict:(NSDictionary *)dict;

//解析提取数组
+(NSArray*)ArrWithKey:(NSString *)key fromDict:(NSDictionary *)dict;
+(NSArray*)ArrWithKey:(NSString *)key fromDict:(NSDictionary *)dict MethodName:(NSString *)method parameterString:(NSString *)parameter;

//解析提取字典
+(NSDictionary *)DictWithKey:(NSString *)key fromDict:(NSDictionary *)dict;
+(NSDictionary *)DictWithKey:(NSString *)key fromDict:(NSDictionary *)dict MethodName:(NSString *)method parameterString:(NSString *)parameter;

//解析提取字符串
+(NSString *)NSStringWithKey:(NSString *)key fromDict:(NSDictionary *)dict;
//解析提取字符串 返回方法名
+(NSString *)NSStringWithKey:(NSString *)key fromDict:(NSDictionary *)dict MethodName:(NSString *)method parameterString:(NSString *)parameter;

//解析提取名字字符串
+(NSString *)NSStringWithNameKey:(NSString *)key fromDict:(NSDictionary *)dict;
+(NSString *)NSStringWithNameKey:(NSString *)key fromDict:(NSDictionary *)dict MethodName:(NSString *)method parameterString:(NSString *)parameter;

//解析提取数字字符串
+(NSString *)NSStringWithNumKey:(NSString *)key fromDict:(NSDictionary *)dict;
+(NSString *)NSStringWithNumKey:(NSString *)key fromDict:(NSDictionary *)dict MethodName:(NSString *)method parameterString:(NSString *)parameter;

//将NSDictionary中的Null类型的项目转化成@""
+(NSDictionary *)nullDic:(NSDictionary *)myDic;


@end
