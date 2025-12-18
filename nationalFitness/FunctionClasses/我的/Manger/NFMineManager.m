//
//  NFMineManager.m
//  nationalFitness
//
//  Created by Joe on 2017/7/14.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "NFMineManager.h"

@implementation NFMineManager


//意见反馈
-(void)SendAddviseManager{
    __strong NSDictionary *infoDic = [_argList objectAtIndex:0];
    
    //获取request对象-----网络层构建
    requestGetter = ^ {
        NSURLRequest *request = [NFMineRequest gotRequest:infoDic andURL:@""];
        
        return request;
    };
    
    //网络数据解析为结构化数据----解析层
    handler = ^(NSURLResponse* response, NSData* data, NSError* connectionError) {
//        id bizData = [NFMineParser SendAddviseParser:data];
        //        return bizData;
        return @{};
    };
}





@end
