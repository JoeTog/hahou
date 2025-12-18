//
//  QACodeParser.m
//  nationalFitness
//
//  Created by 程long on 14-12-25.
//  Copyright (c) 2014年 chenglong. All rights reserved.
//

#import "QRCodeParser.h"

@implementation QRCodeParser

//扫描二维码
+ (id)querySignOrdersParser:(NSData*)data
{
    NSDictionary *bodyDic = [self gotDataParser:data];
    
    if (bodyDic)
    {
        if ([bodyDic objectForKey:kWrongDlog])
        {
            return bodyDic;
        }
        
//        NSInteger returnType = [[bodyDic objectForKey:@"returnType"] integerValue];
//       
//        NSDictionary *retMuDic = [[NSMutableDictionary alloc] initWithCapacity:7];
        
    }
    
    return nil;
}

//确认签到信息
+ (id)signOrdersParser:(NSData*)data
{
    NSDictionary *bodyDic = [self gotDataParser:data];
    
    if (bodyDic)
    {
        return bodyDic;
    }
    
    return nil;
}

@end
