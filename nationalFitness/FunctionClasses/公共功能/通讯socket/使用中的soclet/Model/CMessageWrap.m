//
//  CMessageWrap.m
//  WebSocket
//
//  Created by King on 2017/6/30.
//  Copyright © 2017年 King. All rights reserved.

#import "CMessageWrap.h"

@implementation CMessageWrap


- (NSString *)CreateWordMessageWrapWithFromUsr:(NSString *)m_nsFromUsr ToUsr:(NSString *)m_nsToUsr Content:(NSString *)m_nsContent Type:(int)m_uiMessageType time:(int)m_uiCreateTime
{
    NSMutableDictionary *messageDic = [[NSMutableDictionary alloc] init];
    messageDic[@"m_nsFromUsr"] = m_nsFromUsr;
    messageDic[@"m_nsToUsr"] = m_nsToUsr;
    messageDic[@"m_nsContent"] = m_nsContent;
    messageDic[@"m_uiMessageType"] = [NSString stringWithFormat:@"%d",m_uiMessageType];
    messageDic[@"m_uiCreateTime"] = [NSString stringWithFormat:@"%d",m_uiCreateTime];
    NSString *jsonStr = [self convertToJsonData:messageDic];
    return jsonStr;
}




//字典转json字符串方法
-(NSString *)convertToJsonData:(NSDictionary *)dict

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
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}
@end
