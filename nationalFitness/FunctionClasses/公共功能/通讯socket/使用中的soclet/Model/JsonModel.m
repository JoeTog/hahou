//
//  JsonModel.m
//  WebSocket
//
//  Created by King on 2017/7/1.
//  Copyright © 2017年 King. All rights reserved.
//

#import "JsonModel.h"

@implementation JsonModel

//字典转json字符串方法
+(NSString *)convertToJsonData:(NSDictionary *)dict

{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    //NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
//    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
//    if ([mutStr containsString:@"\\"]) {
//        if ([mutStr containsString:@"\\\\"]) {
//            NSLog(@"");
//        }
//        [mutStr stringByReplacingOccurrencesOfString:@"\\\\" withString:@""];
//        
//    }
    
    return mutStr;
}

//json转字典
+(NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        //NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}


@end
