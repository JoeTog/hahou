//
//  YourBaseManager.m
//  SummaryHoperun
//
//  Created by 程long on 14-7-31.
//  Copyright (c) 2014年 chenglong. All rights reserved.
//

#import "NFBaseManager.h"

#import <objc/runtime.h>

@implementation NFBaseManager

+ (void)execute:(SEL)entrance target:(id)target callback:(SEL)method args:(id)arg,...
{
    va_list args;
    
    NFBaseManager *object = [[self alloc] init];
    
    va_start(args, arg);
    
    [object setArguments:args arg:arg];
    
    va_end(args);
    
    IMP imp = [object methodForSelector:entrance];
    void (*func)(__strong id, SEL,...) = (void(*)(__strong id, SEL,...))imp;
    //    (*imp)(object, entrance);
    func(object, entrance);
    
    [object actual:target callback:method];
}


- (void)actual:(id)target callback:(SEL)method
{
    Class originalTargetClass = object_getClass(target);
    
    if (bizDataGetter != NULL)
    {
        //查询数据库
        id bizData = bizDataGetter();
        
        if (bizData)
        {
            //如果获取到数据库数据,则回调UI方法进行刷新
            //显式调用更新UI函数
            if (originalTargetClass == object_getClass(target))
            {
                void (*imp)(id, SEL, id, NSError *) = (void(*)(id, SEL, id, NSError *))[target methodForSelector:method];
                (*imp)(target, method, bizData, nil);
            }
        }
    }
    
    if (requestGetter != NULL)
    {
        //获取request对象
        NSURLRequest *request = requestGetter();
        
        if (request)
        {
            NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                                    completionHandler:
                                          ^(NSData *data, NSURLResponse *response, NSError *connectionError) {
                                              
                                              if (handler != NULL) {
                                                  
                                                  //将报文数据交由解析模块处理
                                                  id bizData = handler(response, data, connectionError);
                                                  
                                                  //将最新数据更新到页面
                                                  if (originalTargetClass == object_getClass(target))
                                                  {
                                                      if (method)
                                                      {
                                                          
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              
                                                              //展示结构化数据
                                                              void (*imp)(id, SEL, id, NSError *) = (void(*)(id, SEL, id, NSError *))[target methodForSelector:method];
                                                              
                                                              if (connectionError)
                                                              {
                                                                  (*imp)(target, method, bizData, connectionError);
                                                              }
                                                              else
                                                              {
                                                                  (*imp)(target, method, bizData, _error);
                                                              }
                                                          });
                                                          
                                                      }
                                                  }
                                                  
                                                  if (updateDatabaseSetter != NULL)
                                                  {
                                                      if (bizData)
                                                      {
                                                          //更新数据库
                                                          updateDatabaseSetter(bizData);
                                                      }
                                                  }
                                              }
                                          }];
            
            [task resume];
//            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
//            {
//                //可优先处理数据的共通
//                if (handler != NULL) {
//                    
//                    //将报文数据交由解析模块处理
//                    id bizData = handler(response, data, connectionError);
//                    
//                    //将最新数据更新到页面
//                    if (originalTargetClass == object_getClass(target))
//                    {
//                        if (method)
//                        {
//                            //展示结构化数据
//                            void (*imp)(id, SEL, id, NSError *) = (void(*)(id, SEL, id, NSError *))[target methodForSelector:method];
//                            
//                            if (connectionError)
//                            {
//                                (*imp)(target, method, bizData, connectionError);
//                            }
//                            else
//                            {
//                                (*imp)(target, method, bizData, _error);
//                            }
//                        }
//                    }
//                    
//                    if (updateDatabaseSetter != NULL)
//                    {
//                        if (bizData)
//                        {
//                            //更新数据库
//                            updateDatabaseSetter(bizData);
//                        }
//                    }
//                }
//            }];
        }
    }
}


- (void)setArguments:(va_list)args arg:(id)arg
{
    if (arg)
    {
        _argList = [[NSMutableArray alloc] initWithObjects:arg, nil];
        
        while (YES)
        {
            id obj = nil;
            
            obj = va_arg(args, id);
            
            if (!obj )
            {
                break;
            }
            
            [_argList addObject:obj];
        }
    }
}

@end
