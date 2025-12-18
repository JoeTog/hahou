//
//  NFMineParser.m
//  nationalFitness
//
//  Created by 程long on 14-12-17.
//  Copyright (c) 2014年 chenglong. All rights reserved.
//

#import "NFMineParser.h"

@implementation NFMineParser

//意见反馈
+(id)SendAddviseParser:(NSData *)data{
    
    
    return @{};
}

#pragma mark - 请求个人信息详情
+(id)PersonalInfoDetailParser:(NSDictionary *)data{
    if (data) {
        NSDictionary *info = [self nullDic:data];
        PersonalInfoDetailEntity *entity = [PersonalInfoDetailEntity new];
        entity.nick_name = [[info objectForKey:@"friendCommentName"] description];
        if (entity.nick_name.length == 0) {
            entity.nick_name = [info objectForKey:@"nick_name"]&&[[[info objectForKey:@"nick_name"] description] length]>0?[[info objectForKey:@"nick_name"] description]:[[info objectForKey:@"name"] description];
        }
        entity.sex = [[info objectForKey:@"sex"] description];
        entity.area = [[info objectForKey:@"area"] description];
        entity.sign = [[info objectForKey:@"sign"] description];
        entity.userName = [[info objectForKey:@"name"] description];
        entity.userId = [[info objectForKey:@"id"] description];
//        if ([[[info objectForKey:@"photo"] description] containsString:@"http"] || [[[info objectForKey:@"photo"] description] containsString:@"head_man"] || [[[info objectForKey:@"photo"] description] containsString:@"wx.qlogo.cn"]) {
            if ([[[info objectForKey:@"photo"] description] containsString:@"http"]|| [[[info objectForKey:@"photo"] description] containsString:@"wx.qlogo.cn"]) {
            //当为是完整的图片地址 或者为 本地图片 则不需要拼接服域名J
            entity.userHeadPicPath = [[info objectForKey:@"photo"] description];
        }else{
            entity.userHeadPicPath = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[[info objectForKey:@"photo"] description]];
        }
        
        if ([[[info objectForKey:@"isBang"] description] isEqualToString:@"0"]) {
            entity.isBang = NO;
        }else if ([[[info objectForKey:@"isBang"] description] isEqualToString:@"1"]){
            entity.isBang = YES;
        }else{
            entity.isBang = YES;
        }
        
        if ([[[info objectForKey:@"huifu_pwd"] description] isEqualToString:@"0"]) {
            entity.isSetPwd = NO;
        }else if ([[[info objectForKey:@"huifu_pwd"] description] isEqualToString:@"1"]){
            entity.isSetPwd = YES;
        }
        
        
        return entity;
    }
    return nil;
}

//设置个人信息
+(id)PersonalInfoSetParser:(NSDictionary *)data{
    if (data) {
        NSDictionary *info = [self nullDic:data];
        
        return info;
    }
    return nil;
}












@end
