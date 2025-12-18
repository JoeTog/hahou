//
//  EmojiShift.m
//  表情
//
//  Created by ShawnJI on 2017/9/25.
//  Copyright © 2017年 Shawnji. All rights reserved.
//

#import "EmojiShift.h"

@implementation EmojiShift

//表情转文字
+(NSString *)emojiShiftstring:(NSString *)content
{
    return content;//不进行表情转文字了
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"faceList" ofType:@"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:[data allKeys] forKeys:[data allValues]];
    for (NSString *a in [dataDict allKeys]) {
        if([content rangeOfString:a].location!=NSNotFound){
            content = [content stringByReplacingOccurrencesOfString:a withString:dataDict[a] options:NSRegularExpressionSearch range:NSMakeRange (0, content.length)];
        }
        //判断是否含有表情 如果没有直接break
        if (![ClearManager stringContainsEmoji:content]) {
            break;
        }
    }
//    for (NSString *s in [data allValues]) {
//    
//        NSArray *keys = [data allKeys];
//        NSString *theKey = nil;
//        for(NSString *key in keys)
//        {
//            NSString *value = data[key];
//            if([value isEqualToString:s]){
//                theKey = key;
//                break;
//            }
//        }
//        if([content rangeOfString:s].location!=NSNotFound){
//            content = [content stringByReplacingOccurrencesOfString:s withString:theKey options:NSRegularExpressionSearch range:NSMakeRange (0, content.length)];
//        }
//    }
    return content;
}

//文字转表情
+(NSString *)stringShiftemoji:(NSString *)content
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"faceList" ofType:@"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    for (NSString *s in [data allKeys]) {
        NSLog(@"s:%@",s);
        if([content rangeOfString:s].location!=NSNotFound){
            content = [content stringByReplacingOccurrencesOfString:s withString:data[s]];
        }
        //判断当不含有 中括号 break
        if (![content containsString:@"["] && ![content containsString:@"]"]) {
            break;
        }
        //正则判断是否有表情相关文字 [两个汉字]
//        @"\[[\u4e00-\u9fa5]\]{2}"[笑脸]
//        NSString *string = @"\\[[\u4e00-\u9fa5]{1,2}\\]";
//        BOOL ret = [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", string] evaluateWithObject:content];
//        if (!ret) {
//            break;
//        }
    }
    return content;
}

@end
