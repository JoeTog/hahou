//
//  NewHomeManager.m
//  nationalFitness
//
//  Created by 童杰 on 2017/2/25.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "NewHomeManager.h"

@implementation NewHomeManager

//联系人列表
-(void)contantListManager{
    
    __strong NSDictionary *infoDic = [_argList objectAtIndex:0];
    
    //获取request对象-----网络层构建
    requestGetter = ^ {
        NSURLRequest *request = [NewHomeRequest gotRequest:infoDic andURL:contantListManagerUrl];

        return request;
    };
    
    //网络数据解析为结构化数据----解析层
    handler = ^(NSURLResponse* response, NSData* data, NSError* connectionError) {
                id bizData = [NewHomeParser contantListManagerParserr:@[]];
        //        return bizData;
        return bizData;
    };
    
}
















@end
