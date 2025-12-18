//
//  NFDynamicManager.m
//  nationalFitness
//
//  Created by liumac on 16/1/4.
//  Copyright © 2016年 chenglong. All rights reserved.
//

#import "NFDynamicManager.h"
#import "NFDynamicRequest.h"
#import "NFDynamicParser.h"

@implementation NFDynamicManager

// 我的主页
- (void)publishNoteManager
{
    __strong NSDictionary *infoDic = [_argList objectAtIndex:0];
    
    //获取request对象-----网络层构建
    requestGetter = ^ {
        NSURLRequest *request = [NFDynamicRequest gotRequest:infoDic andURL:@""];
        
        return request;
    };
    
    //网络数据解析为结构化数据----解析层
    handler = ^(NSURLResponse* response, NSData* data, NSError* connectionError) {
        id bizData = [NFDynamicParser publishNoteParser:data];
        return bizData;
    };
}

//关联的活动和社团
- (void)connectNoteManager
{
    __strong NSDictionary *infoDic = [_argList objectAtIndex:0];
    
    //获取request对象-----网络层构建
    requestGetter = ^ {
        NSURLRequest *request = [NFDynamicRequest gotRequest:infoDic andURL:@""];
        
        return request;
    };
    
    //网络数据解析为结构化数据----解析层
    handler = ^(NSURLResponse* response, NSData* data, NSError* connectionError) {
        id bizData = [NFDynamicParser connectNoteParser:data];
        return bizData;
    };
}

//帖子列表
- (void)noteListManager
{
    __strong NSDictionary *infoDic = [_argList objectAtIndex:0];
    
    //获取request对象-----网络层构建
    requestGetter = ^ {
        NSURLRequest *request = [NFDynamicRequest gotRequest:infoDic andURL:@""];
        
        return request;
    };
    
    //网络数据解析为结构化数据----解析层
    handler = ^(NSURLResponse* response, NSData* data, NSError* connectionError) {
        id bizData = [NFDynamicParser noteListParser:data];
        return bizData;
    };
}

//帖子详情
- (void)detailNoteManager
{
    __strong NSDictionary *infoDic = [_argList objectAtIndex:0];
    
    //获取request对象-----网络层构建
    requestGetter = ^ {
        NSURLRequest *request = [NFDynamicRequest gotRequest:infoDic andURL:@""];
        
        return request;
    };
    
    //网络数据解析为结构化数据----解析层
    handler = ^(NSURLResponse* response, NSData* data, NSError* connectionError) {
        id bizData = [NFDynamicParser detailNoteParser:data];
        return bizData;
    };
}

//各种帖子列表（活动社团场地等）
- (void)actNoteListManager
{
    __strong NSDictionary *infoDic = [_argList objectAtIndex:0];
    
    //获取request对象-----网络层构建
    requestGetter = ^ {
        NSURLRequest *request = [NFDynamicRequest gotRequest:infoDic andURL:@""];
        
        return request;
    };
    
    //网络数据解析为结构化数据----解析层
    handler = ^(NSURLResponse* response, NSData* data, NSError* connectionError) {
        id bizData = [NFDynamicParser actNoteListParser:data];
        return bizData;
    };
}

// 评论列表
- (void)noteCommentListManager
{
    __strong NSDictionary *infoDic = [_argList objectAtIndex:0];
    
    //获取request对象-----网络层构建
    requestGetter = ^ {
        NSURLRequest *request = [NFDynamicRequest gotRequest:infoDic andURL:@""];
        
        return request;
    };
    
    //网络数据解析为结构化数据----解析层
    handler = ^(NSURLResponse* response, NSData* data, NSError* connectionError) {
        id bizData = [NFDynamicParser noteCommentListParser:data];
        return bizData;
    };
}

// 评论回复列表
- (void)commentRelyManager
{
    __strong NSDictionary *infoDic = [_argList objectAtIndex:0];
    
    //获取request对象-----网络层构建
    requestGetter = ^ {
        NSURLRequest *request = [NFDynamicRequest gotRequest:infoDic andURL:@""];
        
        return request;
    };
    
    //网络数据解析为结构化数据----解析层
    handler = ^(NSURLResponse* response, NSData* data, NSError* connectionError) {
        id bizData = [NFDynamicParser commentRelyParser:data];
        return bizData;
    };
}

// 删除帖子
- (void)deleteNoteManager
{
    __strong NSDictionary *infoDic = [_argList objectAtIndex:0];
    
    //获取request对象-----网络层构建
    requestGetter = ^ {
        NSURLRequest *request = [NFDynamicRequest gotRequest:infoDic andURL:@""];
        
        return request;
    };
    
    //网络数据解析为结构化数据----解析层
    handler = ^(NSURLResponse* response, NSData* data, NSError* connectionError) {
        id bizData = [NFDynamicParser deleteNoteParser:data];
        return bizData;
    };
}

// 评论
- (void)commentNoteManager
{
    __strong NSDictionary *infoDic = [_argList objectAtIndex:0];
    
    //获取request对象-----网络层构建
    requestGetter = ^ {
        NSURLRequest *request = [NFDynamicRequest gotRequest:infoDic andURL:@""];
        
        return request;
    };
    
    //网络数据解析为结构化数据----解析层
    handler = ^(NSURLResponse* response, NSData* data, NSError* connectionError) {
        id bizData = [NFDynamicParser commentNoteParser:data];
        return bizData;
    };
}

// 点赞
- (void)priseNoteManager
{
    __strong NSDictionary *infoDic = [_argList objectAtIndex:0];
    
    //获取request对象-----网络层构建
    requestGetter = ^ {
        NSURLRequest *request = [NFDynamicRequest gotRequest:infoDic andURL:@""];
        
        return request;
    };
    
    //网络数据解析为结构化数据----解析层
    handler = ^(NSURLResponse* response, NSData* data, NSError* connectionError) {
        id bizData = [NFDynamicParser priseNoteParser:data];
        return bizData;
    };
}

// 取消点赞
- (void)cancelPriseNoteManager
{
    __strong NSDictionary *infoDic = [_argList objectAtIndex:0];
    
    //获取request对象-----网络层构建
    requestGetter = ^ {
        NSURLRequest *request = [NFDynamicRequest gotRequest:infoDic andURL:@""];
        
        return request;
    };
    
    //网络数据解析为结构化数据----解析层
    handler = ^(NSURLResponse* response, NSData* data, NSError* connectionError) {
        id bizData = [NFDynamicParser cancelPriseNoteParser:data];
        return bizData;
    };
}

// 删除评论
- (void)deleteCommentManager
{
    __strong NSDictionary *infoDic = [_argList objectAtIndex:0];
    
    //获取request对象-----网络层构建
    requestGetter = ^ {
        NSURLRequest *request = [NFDynamicRequest gotRequest:infoDic andURL:@""];
        
        return request;
    };
    
    //网络数据解析为结构化数据----解析层
    handler = ^(NSURLResponse* response, NSData* data, NSError* connectionError) {
        id bizData = [NFDynamicParser deleteCommentParser:data];
        return bizData;
    };
}

// 动态插入
- (void)recommendManager
{
    __strong NSDictionary *infoDic = [_argList objectAtIndex:0];
    
    //获取request对象-----网络层构建
    requestGetter = ^ {
        NSURLRequest *request = [NFDynamicRequest gotRequest:infoDic andURL:@""];
        
        return request;
    };
    
    //网络数据解析为结构化数据----解析层
    handler = ^(NSURLResponse* response, NSData* data, NSError* connectionError) {
        id bizData = [NFDynamicParser recommendParser:data];
        return bizData;
    };
}

// 可能认识的人
- (void)mayKnowPeoManager
{
    __strong NSDictionary *infoDic = [_argList objectAtIndex:0];
    
    //获取request对象-----网络层构建
    requestGetter = ^ {
        NSURLRequest *request = [NFDynamicRequest gotRequest:infoDic andURL:@""];
        
        return request;
    };
    
    //网络数据解析为结构化数据----解析层
    handler = ^(NSURLResponse* response, NSData* data, NSError* connectionError) {
        id bizData = [NFDynamicParser mayKnowPeoParser:data];
        return bizData;
    };
}

//收藏公众号
- (void)collPublicNoManager
{
    __strong NSDictionary *infoDic = [_argList objectAtIndex:0];
    
    //获取request对象-----网络层构建
    requestGetter = ^ {
        NSURLRequest *request = [NFDynamicRequest gotRequest:infoDic andURL:@""];
        
        return request;
    };
    
    //网络数据解析为结构化数据----解析层
    handler = ^(NSURLResponse* response, NSData* data, NSError* connectionError) {
        id bizData = [NFDynamicParser collPublicNoParser:data];
        return bizData;
    };
}

//取消收藏
- (void)cancelCollPublicNoManager
{
    __strong NSDictionary *infoDic = [_argList objectAtIndex:0];
    
    //获取request对象-----网络层构建
    requestGetter = ^ {
        NSURLRequest *request = [NFDynamicRequest gotRequest:infoDic andURL:@""];
        
        return request;
    };
    
    //网络数据解析为结构化数据----解析层
    handler = ^(NSURLResponse* response, NSData* data, NSError* connectionError) {
        id bizData = [NFDynamicParser cancelCollPublicNoParser:data];
        return bizData;
    };
}

@end
