//
//  LoginEntity.h
//  nationalFitness
//
//  Created by 童杰 on 2017/3/13.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginEntity : NSObject

//登陆中 这是 是否设置了红包支付密码
//
@property(nonatomic,strong)NSString *clientId;


@property(nonatomic,assign)BOOL isSetTixian;
@property(nonatomic,assign)BOOL isCancelPwd;


//昵称
@property(nonatomic,strong)NSString *nickName;

//个性签名
@property(nonatomic,strong)NSString *sign;

//userid
@property(nonatomic,strong)NSString *userId;

//名字
@property(nonatomic,strong)NSString *userName;

//头像
@property(nonatomic,strong)NSString *headPicPath;

//是否绑定了多信账号
@property(nonatomic,strong)NSString *isBang;

//电话号码
@property(nonatomic,strong)NSString *phoneNum;

//报错信息 正常为空 nil
@property(nonatomic,strong)NSString *wrongMessage;


@end













