//
//  RPFJson.h
//  NIM
//
//  Created by King on 2019/2/12.
//  Copyright © 2019年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RPFTool : NSObject

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
+(NSString *)convertToJsonData:(NSDictionary *)dict;

+(NSString *)ConvertStrToTime:(NSString *)timeStr;
//是否调试状态
+(BOOL)inRefreshInfo;

@end

NS_ASSUME_NONNULL_END
