//
//  LoginManager.h
//  nationalFitness
//
//  Created by 童杰 on 2017/3/13.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "NFBaseManager.h"
#import "LoginParser.h"
#import "LoginRequest.h"

@interface LoginManager : NFBaseManager



//验证码请求
-(void)gotVerificationManager;

//登陆请求
-(void)loginRequestManager;

//修改密码
-(void)changePassWordManager;

//修改头像
-(void)changeHeadPicpathManager;

//获取图片后缀
+ (NSString *)typeForImageData:(NSData *)data;

//
-(void)getIPManagerManager;


//三方登录 微信根据code获取用户信息
-(void)WXGetAccess_token;

#pragma mark - 微信请求用户信息22222
-(void)WXGetUserInfo;





@end
