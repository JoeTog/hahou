//
//  JsonModel.h
//  WebSocket
//
//  Created by King on 2017/7/1.
//  Copyright © 2017年 King. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface JsonModel : NSObject

//Json转字典
+(NSString *)convertToJsonData:(NSDictionary *)dict;

//字典转Json
+(NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

@end










