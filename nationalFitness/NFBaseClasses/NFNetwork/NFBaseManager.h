//
//  YourBaseManager.h
//  SummaryHoperun
//
//  Created by 程long on 14-7-31.
//  Copyright (c) 2014年 chenglong. All rights reserved.
//

#import <Foundation/Foundation.h>

//定义从数据库获取业务数据的block别名
typedef id (^BizDataGetter)(void);

//定义构建网络请求的block别名
typedef NSURLRequest *(^RequestGetter)(void);

//定义处理网络数据的block别名
typedef id (^NetWorkCompletionHandler)(NSURLResponse* response, NSData* data, NSError* connectionError);

//定义更新数据库的block别名
typedef BOOL (^UpdateDatabaseSetter)(id data);


@interface NFBaseManager : NSObject
{
    //查询数据库,返回UI所需要的结构化数据
    BizDataGetter                   bizDataGetter;
    
    //构建网络服务的request,并返回NSURLRequest 对象
    RequestGetter                   requestGetter;
    
    //配置网络服务返回后数据的处理流程
    NetWorkCompletionHandler        handler;
    
    //配置数据库数据更新流程
    UpdateDatabaseSetter            updateDatabaseSetter;
    
    //用于存放database,http请求所需的各个参数
    NSMutableArray                  *_argList;
    
    __block NSError                 *_error;
}
@property (nonatomic, strong) NSMutableArray    *argList;
@property (nonatomic, strong) __block NSError   *error;

/*!
 @method
 @abstract      程序入口管理类方法,该方法内部有一个固定模式的流程
 
 1.配置entrance方法中的设置(BizDataGetter,RequestGetter,NetWorkCompletionHandler,UpdateDatabaseSetter)
 2.
 
 
 
 @param         entrance
 继承SCBaseManager的子类,根据具体业务功能,定义公开消息函数。entrance方法中需要设置(BizDataGetter,RequestGetter,NetWorkCompletionHandler,UpdateDatabaseSetter)
 
 @param         target
 方法中等待界面刷新的对象
 
 @param         method
 target对应的消息函数。method需要两个参数,例:- (void)testCallback:(id)data error:(NSError *)error
 data:已经被结构化的数据。数据由BizDataGetter,NetWorkCompletionHandler产生
 error:错误信息
 
 @param         arg
 可变参数队列,用于传入BizDataGetter,RequestGetter所需要的参数
 注:只可以是对象类型,且以nil结束
 
 
 @note          基类内部定义了6个步骤的处理流程
 
 a.根据entrance中配置的BizDataGetter,查询数据库,获取需要的结构化数据,如果获取成功,则至b;否则,该方法结束
 b.通知UI更新
 c.根据entrance中配置的RequestGetter,获取需要发送的NSURLRequest对象,获取成功,则至d;否则,该方法结束
 d.发送request请求
 e.将网络服务返回的数据交给NetWorkCompletionHandler处理。数据正确,返回结构化数据,至f;否则,该方法结束
 f.通知UI更新
 g.将步骤e返回的数据交给UpdateDatabaseSetter做数据库更新
 h.方法正式结束
 
 @result        无
 */
+ (void)execute:(SEL)entrance target:(id)target callback:(SEL)method args:(id)arg,...;

@end
