
//  NFParser.m
//  nationalFitness
//
//  Created by 程long on 14-10-28.
//  Copyright (c) 2014年 chenglong. All rights reserved.
//

#import "NFBaseParser.h"
#import "NFPacketHandler.h"
#import "JSON.h"
#import "NSData+Encrypt.h"


@implementation NFBaseParser


+ (id)gotDataParser : (NSData *)data
{
    NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSData *keyData = [NFPacketHandler hexStringToNSData:dataStr];
    
    NSData *decdata = [keyData AES256DecryptWithKey:[NSString stringWithFormat:@"%@%@",AES_KEY,[SystemInfo shareSystemInfo].deviceId] keyEncoding:NSUTF8StringEncoding];
    NSString *aStr = [[NSString alloc] initWithData:decdata encoding:NSUTF8StringEncoding];
    
//    NSLog(@"%@",aStr);
    
    if (!decdata)
    {
        return @{kWrongDlog:kWrongMessage};
    }
    
//    NSString *aStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    
//    if (!data)
//    {
//        return @{kWrongDlog:kWrongMessage};
//    }
    
    NSError __autoreleasing *error = nil;
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *parserDict = [parser objectWithString:aStr];
    
    if (!error)
    {
        if (parserDict == nil ||  ![[[parserDict objectForKey:@"header"] objectForKey:@"retStatus"] isEqualToString:@"0"])
        {
            NSString *wrong = [[parserDict objectForKey:@"header"] objectForKey:@"retMessage"];
            if (wrong && wrong.length > 0)
            {
                return @{kWrongDlog:wrong};
            }
            else
            {
                return @{kWrongDlog:kWrongMessage};
            }
        }
        
        //正确的接口会返回用户BODY报文
//        DLog(@"正确的报文--%@", [parserDict objectForKey:@"body"]);
        
        return [parserDict objectForKey:@"body"];
    }
    
    return @{kWrongDlog:kWrongMessage};
}

+ (id)gotDataNoKeyParser : (NSData *)data
{
    NSString *aStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    if (!data)
    {
        return @{kWrongDlog:kWrongMessage};
    }
    
    NSLog(@"%@",aStr);
    
    NSError __autoreleasing *error = nil;
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *parserDict = [parser objectWithString:aStr];
    
    return parserDict;
    
    
    if (!error)
    {
        if (parserDict == nil ||  ![[[parserDict objectForKey:@"header"] objectForKey:@"retStatus"] isEqualToString:@"0"])
        {
            NSString *wrong = [[parserDict objectForKey:@"header"] objectForKey:@"retMessage"];
            if (wrong && wrong.length > 0)
            {
                return @{kWrongDlog:wrong};
            }
            else
            {
                return @{kWrongDlog:kWrongMessage};
            }
        }
        
        //正确的接口会返回用户BODY报文
//        DLog(@"正确的报文--%@", [parserDict objectForKey:@"body"]);
        
        return [parserDict objectForKey:@"body"];
    }
    
    return @{kWrongDlog:kWrongMessage};
}




//解析提取数组
-(NSArray*)ArrWithKey:(NSString *)key fromDict:(NSDictionary *)dict{
    id arr = [dict objectForKey:key];
    if ([arr isKindOfClass:[NSArray class]]) {
        return arr;
    }
    NSLog(@"应该返回数组可是返回了其他类型");
    return @[];
}
//解析提取字典
-(NSDictionary *)DictWithKey:(NSString *)key fromDict:(NSDictionary *)dict{
    id dictionary = [dict objectForKey:key];
    if ([dictionary isKindOfClass:[NSDictionary class]]) {
        
        return dictionary;
    }
    NSLog(@"应该返回字典可是返回了其他类型");
    return @{};
}



//解析提取字符串
-(NSString *)NSStringWithKey:(NSString *)key fromDict:(NSDictionary *)dict{
    id string = [[dict objectForKey:key] description];
    if ([string isKindOfClass:[NSString class]]) {
        
        return string;
    }
    NSLog(@"应该返回字符串可是返回了其他类型");
    return @"";
}

//解析提取数组
+(NSArray*)ArrWithKey:(NSString *)key fromDict:(NSDictionary *)dict{
    id arr = [dict objectForKey:key];
    if ([arr isKindOfClass:[NSArray class]]) {
        
        return arr;
    }
    NSLog(@"应该返回数组可是返回了其他类型");
    return @[];
}

//解析提取数组
+(NSArray*)ArrWithKey:(NSString *)key fromDict:(NSDictionary *)dict MethodName:(NSString *)method parameterString:(NSString *)parameter{
    id arr = [dict objectForKey:key];
    if ([arr isKindOfClass:[NSArray class]]) {
        
        return arr;
    }
    NSLog(@"%@:%@,应该返回数组可是返回了其他类型",method,parameter);
    return @[];
}
//解析提取字典
+(NSDictionary *)DictWithKey:(NSString *)key fromDict:(NSDictionary *)dict{
    id dictionary = [dict objectForKey:key];
    if ([dictionary isKindOfClass:[NSDictionary class]]) {
        
        return dictionary;
    }
    NSLog(@"应该返回字典可是返回了其他类型");
    return @{};
}

//解析提取字典
+(NSDictionary *)DictWithKey:(NSString *)key fromDict:(NSDictionary *)dict MethodName:(NSString *)method parameterString:(NSString *)parameter{
    id dictionary = [dict objectForKey:key];
    if ([dictionary isKindOfClass:[NSDictionary class]]) {
        
        return dictionary;
    }
    NSLog(@"%@:%@,应该返回字典可是返回了其他类型",method,parameter);
    return @{};
}

//解析提取字符串
+(NSString *)NSStringWithKey:(NSString *)key fromDict:(NSDictionary *)dict{
    id string = [[dict objectForKey:key] description];
    if ([string isKindOfClass:[NSString class]]) {
        
        return string;
    }
    NSLog(@"应该返回字符串可是返回了其他类型");
    return @"";
}

//解析提取字符串 返回方法名
+(NSString *)NSStringWithKey:(NSString *)key fromDict:(NSDictionary *)dict MethodName:(NSString *)method parameterString:(NSString *)parameter{
    id string = [[dict objectForKey:key] description];
    if ([string isKindOfClass:[NSString class]]) {
        
        return string;
    }
    NSLog(@"%@,%@:应该返回字符串可是返回了其他类型",method,parameter);
    return @"";
}

//解析提取名字字符串
+(NSString *)NSStringWithNameKey:(NSString *)key fromDict:(NSDictionary *)dict{
    id string = [[dict objectForKey:key] description];
    if ([string isKindOfClass:[NSString class]]) {
        NSString *str = string;
        if (str.length == 0) {
            return @" ";
        }
        return string;
    }
    NSLog(@"应该返回字符串可是返回了其他类型");
    return @" ";
}

//解析提取名字字符串
+(NSString *)NSStringWithNameKey:(NSString *)key fromDict:(NSDictionary *)dict MethodName:(NSString *)method parameterString:(NSString *)parameter{
    id string = [[dict objectForKey:key] description];
    if ([string isKindOfClass:[NSString class]]) {
        NSString *str = string;
        if (str.length == 0) {
            return @" ";
        }
        return string;
    }
    NSLog(@"%@,%@:应该返回字符串可是返回了其他类型",method,parameter);
    return @" ";
}

//解析提取数字字符串
+(NSString *)NSStringWithNumKey:(NSString *)key fromDict:(NSDictionary *)dict{
    id string = [[dict objectForKey:key] description];
    if ([string isKindOfClass:[NSString class]]) {
        NSString *str = string;
        if (str.length==0) {
            return @"0";
        }
        return string;
    }
    NSLog(@"应该返回字符串可是返回了其他类型");
    return @"0";
}

//解析提取数字字符串
+(NSString *)NSStringWithNumKey:(NSString *)key fromDict:(NSDictionary *)dict MethodName:(NSString *)method parameterString:(NSString *)parameter{
    id string = [[dict objectForKey:key] description];
    if ([string isKindOfClass:[NSString class]]) {
        NSString *str = string;
        if (str.length==0) {
            return @"0";
        }
        return string;
    }
    NSLog(@"%@,%@:应该返回字符串可是返回了其他类型",method,parameter);
    return @"0";
}

#pragma mark - 数据获取健壮,在数据获取起始写了该方法，后面几本无需判断
//将NSDictionary中的Null类型的项目转化成@""
+(NSDictionary *)nullDic:(NSDictionary *)myDic
{
    NSArray *keyArr = [myDic allKeys];
    NSMutableDictionary *resDic = [[NSMutableDictionary alloc]init];
    for (int i = 0; i < keyArr.count; i ++)
    {
        id obj = [myDic objectForKey:keyArr[i]];
        
        obj = [self changeType:obj];
        
        [resDic setObject:obj forKey:keyArr[i]];
    }
    return resDic;
}

//将NSArray中的Null类型的项目转化成@""
+(NSArray *)nullArr:(NSArray *)myArr
{
    NSMutableArray *resArr = [[NSMutableArray alloc] init];
    for (int i = 0; i < myArr.count; i ++)
    {
        id obj = myArr[i];
        
        obj = [self changeType:obj];
        
        [resArr addObject:obj];
    }
    return resArr;
}

//将NSString类型的原路返回
+(NSString *)stringToString:(NSString *)string
{
    return string;
}

//将Null类型的项目转化成@""
+(NSString *)nullToString
{
    return @"";
}

//主要方法
//类型识别:将所有的NSNull类型转化成@""
+(id)changeType:(id)myObj
{
    if ([myObj isKindOfClass:[NSDictionary class]])
    {
        return [self nullDic:myObj];
    }
    else if([myObj isKindOfClass:[NSArray class]])
    {
        return [self nullArr:myObj];
    }
    else if([myObj isKindOfClass:[NSString class]])
    {
        return [self stringToString:myObj];
    }
    else if([myObj isKindOfClass:[NSNull class]])
    {
        return [self nullToString];
    }
    else
    {
        return myObj;
    }
}


@end
