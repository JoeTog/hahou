//
//  KeepAppBox.h
//  qmjs
//  将用户数据存储到沙河文件
//  Created by 程龙 on 14-5-7.
//  Copyright (c) 2014年 sea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NFUserEntity.h"

@interface KeepAppBox : NSObject

//增加值存储
+ (void)keepVale:(id)value forKey:(NSString *)key;

//减少值
+ (void)deleteValueForkey:(NSString *)key;

//根据KEY查找对应的值-不存在返回nil
+ (id)checkValueForkey:(NSString *)key;

//爱好只能由中文、字母组成
+ (BOOL)isValidateHobby:(NSString *)nickname;

//昵称只能由中文、字母或数字组成
+ (BOOL)isValidateNick:(NSString *)nickname;

//验证真实姓名
+ (BOOL)isValidateRealname:(NSString *)realname;

//验证账号是不是纯英文 或者 英文加数字
+ (BOOL)isValidateNickname:(NSString *)email;

//验证邮箱格式
+ (BOOL)isValidateEmail:(NSString *)email;

//验证电话格式
+ (BOOL)isValidatePhone:(NSString *)phone;

//验证身份证格式
+ (BOOL)isIdNumberValid:(NSString *)idNum;

//返回字符字节长度
+ (NSInteger)convertToInt:(NSString *)strtemp;

//返回当前传入的下层最近的一个UIViewController
+ (UIViewController *)viewController:(id)view;

//最上层viewctrol
+ (UIViewController*)topViewController;

//性别
+ (void)showMemberSex:(UIImageView *)imageView state:(NSString *)state;

//设置默认头像
+ (void)showMemberHead:(UIImageView *)imageView state:(NSInteger)state;

//设置订单状态
+ (void)setOrderStatusWith:(NSString *)str withLabel:(UILabel *)label;

//用户所在段位
+ (void)setRankLevelWithString:(NSString *)levelStr withLabel:(UILabel *)label;

//设置段位图片
+ (void)setRankImageWithString:(NSString *)str withImage:(UIImageView *)imageView;

//根据活动类型返回不同的背景颜色
+ (UIColor *)getActBackColor:(NSString *)typeStr;

////设置赛事类型

/***
 
 typeStr 赛事类型名字
 str  段位所在段位(等级) 1:黄金三阶;2:黄金二阶;3:黄金一阶;4:白银三阶;5:白银二阶;6:白银一阶;7:青铜三阶;8:青铜二阶;9:青铜一阶
 ***/
+ (void)setRankTypeImageWithStr:(NSString *)typeStr andDWstr:(NSString *)str andImageView:(UIImageView *)imageView;

+ (void)showStarWithLevel:(NSString *)levelStr andImageView:(UIImageView *)imageView;

@end
