//
//  LoginParser.m
//  nationalFitness
//
//  Created by 童杰 on 2017/3/13.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "LoginParser.h"

@implementation LoginParser

//上传图片
+ (id)uploadPictureManagerParser:(NSData *)data{
    NSDictionary * bodyDic = [self gotDataNoKeyParser:data];
    if (bodyDic) {
        
        return bodyDic;
    }
    return nil;
}

//登陆请求
+ (id)loginRequestManagerParser:(NSDictionary *)data{
    if (data) {
        //        NSDictionary *resultDic = [NSDictionary new];
        //        resultDic = data[@"result"];
        //登陆
        data = [self nullDic:data];
        LoginEntity *entityy = [[LoginEntity alloc] init];
        entityy.clientId = [[data objectForKey:@"user_cust_id"] description];
        if (!entityy.clientId) {
            entityy.clientId = @"";
        }
        //汇付 提现支付密码 是否设置
        if ([[[data objectForKey:@"huifu_pwd"] description] isEqualToString:@"1"]) {
            entityy.isSetTixian = YES;
        }
        //汇付是否开启免密支付
        if ([[[data objectForKey:@"huifu_no_pwd_pay"] description] isEqualToString:@"1"]) {
            entityy.isCancelPwd = YES;
        }
        
        entityy.nickName = [[data objectForKey:@"nick_name"] description];
        entityy.userId = [[data objectForKey:@"user_id"] description];
        entityy.userName = [[data objectForKey:@"user_name"] description];
        entityy.sign = [[data objectForKey:@"sign"] description];
        entityy.isBang = [[data objectForKey:@"isBang"] description];
        entityy.phoneNum = [[data objectForKey:@"phone"] description];
        if (entityy.isBang.length == 0) {
            entityy.isBang = @"1";
        }
//        if ([[[data objectForKey:@"photo"] description] containsString:@"head_man"]) {
//            entityy.headPicPath = [[data objectForKey:@"photo"] description];
//        }else{
            if ([[[data objectForKey:@"photo"] description] containsString:@"http"] || [[[data objectForKey:@"photo"] description] containsString:@"wx.qlogo.cn"]) {
                entityy.headPicPath = [[data objectForKey:@"photo"] description];
            }else{
                entityy.headPicPath = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[[data objectForKey:@"photo"] description]];
            }
//        }
        return entityy;
    }
    return nil;
}


//登陆请求
+ (id)loginRequestManagerHttpParser:(NSData *)data{
    NSDictionary * bodyDic = [self gotDataNoKeyParser:data];
    if (bodyDic) {
        if ([[[bodyDic objectForKey:@"status"] description] isEqualToString:@"0"]) {
            //发生错误
            if ( [[bodyDic objectForKey:@"data"] isKindOfClass:[NSArray class]]) {
                for (NSDictionary *errorDict in [bodyDic objectForKey:@"data"]) {
                    NSString *errorInfo = [[errorDict objectForKey:@"info"] description];
                    if (errorInfo.length > 0) {
                        return @{@"status":@"0",kWrongDlog:errorInfo};
                    }
                    
                }
            }
        }else if ([[[bodyDic objectForKey:@"status"] description] isEqualToString:@"1"]){
            return @{@"status":@"1"};
        }
        return bodyDic;
    }
    return nil;
}


//修改密码
+ (id)changePassWordManagerParser:(NSData *)data{
    NSDictionary * bodyDic = [self gotDataNoKeyParser:data];
    if (bodyDic) {
        if ([[[bodyDic objectForKey:@"status"] description] isEqualToString:@"0"]) {
            //发生错误
            if ( [[bodyDic objectForKey:@"data"] isKindOfClass:[NSArray class]]) {
                for (NSDictionary *errorDict in [bodyDic objectForKey:@"data"]) {
                    NSString *errorInfo = [[errorDict objectForKey:@"info"] description];
                    if (errorInfo.length > 0) {
                        return @{@"status":@"0",kWrongDlog:errorInfo};
                    }
                    
                }
            }
        }else if ([[[bodyDic objectForKey:@"status"] description] isEqualToString:@"1"]){
            return @{@"status":@"1"};
        }
        return bodyDic;
    }
    return nil;
}

+ (id)getIPManagerManagerParser:(NSData *)data{
    NSDictionary * bodyDic = [self gotDataNoKeyParser:data];
    if (bodyDic) {
        
        return bodyDic;
    }
    return nil;
}

//三方登录 微信根据code获取用户信息
+ (id)WXGetAccess_tokenParser:(NSData *)data{
    NSDictionary * bodyDic = [self gotDataNoKeyParser:data];
    if (bodyDic) {
        
        return bodyDic;
    }
    return nil;
}

#pragma mark - 微信请求用户信息22222
+ (id)WXGetUserInfoParser:(NSData *)data{
    NSDictionary * bodyDic = [self gotDataNoKeyParser:data];
    if (bodyDic) {
        
        return bodyDic;
    }
    return nil;
}

@end
