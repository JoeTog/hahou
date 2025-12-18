//
//  PayManager.m
//  nationalFitness
//
//  Created by joe on 2019/11/15.
//  Copyright © 2019年 chenglong. All rights reserved.
//

#import "PayManager.h"

@implementation PayManager



//
#pragma mark - 开户
-(void)openAccountManager{
    __strong NSDictionary *infoDic = [_argList objectAtIndex:0];
    
    //获取request对象-----网络层构建
    requestGetter = ^ {
        NSURLRequest *request = [PayRequest gotRequest:infoDic andURL:openAccountManagerUrl];
        
        return request;
    };
    
    //网络数据解析为结构化数据----解析层
    handler = ^(NSURLResponse* response, NSData* data, NSError* connectionError) {
        id bizData = [PayParser openAccountManagerParser:data];
        return bizData;
    };
}









@end
