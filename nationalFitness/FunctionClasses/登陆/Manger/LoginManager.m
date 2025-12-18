//
//  LoginManager.m
//  nationalFitness
//
//  Created by 童杰 on 2017/3/13.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "LoginManager.h"

@implementation LoginManager

//验证码请求
-(void)gotVerificationManager{
    __strong NSDictionary *infoDic = [_argList objectAtIndex:0];
    
    //获取request对象-----网络层构建
    requestGetter = ^ {
        NSURLRequest *request = [LoginRequest gotRequest:infoDic andURL:checkVerificationURL];
        
        return request;
    };
    
    //网络数据解析为结构化数据----解析层
//    handler = ^(NSURLResponse* response, NSData* data, NSError* connectionError) {
//                id bizData = [LoginParser gotVerificationManagerParser:data];
        //        return bizData;
//        return nil;
//    };
}

//登陆请求loginRequestManagerURL
-(void)loginRequestManager{
    __strong NSDictionary *infoDic = [_argList objectAtIndex:0];
    
    //获取request对象-----网络层构建
    requestGetter = ^ {//
        NSURLRequest *request = [LoginRequest gotRequest:infoDic andURL:loginRequestURL];
        
        return request;
    };
    
    //网络数据解析为结构化数据----解析层
    handler = ^(NSURLResponse* response, NSData* data, NSError* connectionError) {
                id bizData = [LoginParser loginRequestManagerHttpParser:data];
                return bizData;
        
    };
}

//修改密码
-(void)changePassWordManager{
    __strong NSDictionary *infoDic = [_argList objectAtIndex:0];
//    __strong NSData *imageData = [_argList objectAtIndex:1];
    
    //获取request对象-----网络层构建
    requestGetter = ^ {//
        NSURLRequest *request = [LoginRequest gotRequest:infoDic andURL:changePassWordURL];
        
        return request;
    };
//    requestGetter = ^ {
//        NSURLRequest *request = [LoginRequest uploadPicRequestWithParams:infoDic imageData:imageData];
//
//        return request;
//    };
    
    //网络数据解析为结构化数据----解析层
    handler = ^(NSURLResponse* response, NSData* data, NSError* connectionError) {
        id bizData = [LoginParser changePassWordManagerParser:data];
                return bizData;
//        return nil;
    };
}

//修改头像
-(void)changeHeadPicpathManager{
    __strong NSDictionary *infoDic = [_argList objectAtIndex:0];
    __strong NSData *imageData = [_argList objectAtIndex:1];
    
    requestGetter = ^ {
        NSURLRequest *request = [LoginRequest uploadPicRequestWithParams:infoDic imageData:imageData];
        
        return request;
    };
    
    //网络数据解析为结构化数据----解析层
    handler = ^(NSURLResponse* response, NSData* data, NSError* connectionError) {
        id bizData = [LoginParser uploadPictureManagerParser:data];
        return bizData;
        //        return nil;
    };
}

#pragma mark - 请求ip地址
-(void)getIPManagerManager{
    __strong NSDictionary *infoDic = [_argList objectAtIndex:0];
    
    requestGetter = ^ {//
        NSURLRequest *request = [LoginRequest gotRequest:infoDic andURL:@"http://ip.taobao.com/service/getIpInfo.php?ip=myip"];
        
        return request;
    };
    
    //网络数据解析为结构化数据----解析层
    handler = ^(NSURLResponse* response, NSData* data, NSError* connectionError) {
        id bizData = [LoginParser getIPManagerManagerParser:data];
        return bizData;
        //        return nil;
    };
}


//三方登录 微信根据code获取用户信息
-(void)WXGetAccess_token{
    __strong NSDictionary *infoDic = [_argList objectAtIndex:0];
    
    requestGetter = ^ {//
        NSURLRequest *request = [LoginRequest gotRequest:@{} andURL:[infoDic objectForKey:@"URL"]];
        return request;
    };
    
    //网络数据解析为结构化数据----解析层
    handler = ^(NSURLResponse* response, NSData* data, NSError* connectionError) {
        id bizData = [LoginParser WXGetAccess_tokenParser:data];
        return bizData;
        //        return nil;
    };
}

#pragma mark - 微信请求用户信息22222 
-(void)WXGetUserInfo{
    __strong NSDictionary *infoDic = [_argList objectAtIndex:0];
    
    requestGetter = ^ {//
        NSURLRequest *request = [LoginRequest gotRequest:@{} andURL:[infoDic objectForKey:@"URL"]];
        return request;
    };
    
    //网络数据解析为结构化数据----解析层
    handler = ^(NSURLResponse* response, NSData* data, NSError* connectionError) {
        id bizData = [LoginParser WXGetUserInfoParser:data];
        return bizData;
        //        return nil;
    };
}

//获取图片后缀
+ (NSString *)typeForImageData:(NSData *)data {
    uint8_t c;
    
    [data getBytes:&c length:1];
    
    switch (c) {
            
        case 0xFF:
            
            return @"jpeg";
            
        case 0x89:
            
            return @"png";
            
        case 0x47:
            
            return @"gif";
            
        case 0x49:
            
        case 0x4D:
            
            return @"tiff";
            
    }
    
    return nil;
    
}


@end
