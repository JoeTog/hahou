//
//  LoginParser.h
//  nationalFitness
//
//  Created by 童杰 on 2017/3/13.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "NFBaseParser.h"
#import "LoginEntity.h"


@interface LoginParser : NFBaseParser


//验证码请求


//登陆请求
+ (id)loginRequestManagerParser:(NSData *)data;

//登陆请求
+ (id)loginRequestManagerHttpParser:(NSData *)data;

//上传图片
+ (id)uploadPictureManagerParser:(NSData *)data;


//修改密码
+ (id)changePassWordManagerParser:(NSData *)data;

#pragma mark - 请求ip地址
+ (id)getIPManagerManagerParser:(NSData *)data;

//三方登录 微信根据code获取用户信息
+ (id)WXGetAccess_tokenParser:(NSData *)data;


#pragma mark - 微信请求用户信息22222
+ (id)WXGetUserInfoParser:(NSData *)data;



@end
