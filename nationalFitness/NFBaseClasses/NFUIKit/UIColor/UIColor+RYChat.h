//
//  UIColor+RYChat.h
//  RYKit
//
//  Created by zhangll on 16/8/18.
//  Copyright © 2016年 安徽软云信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NFbaseViewController.h"

@interface UIColor (RYChat)

#pragma mark - 红包背景浅色
+ (UIColor *)colorRedPacketBackColor;
#pragma mark - 红包不可点
+ (UIColor *)colorRedPacketUnableColor;
#pragma mark - sectionheadview 背景色
+ (UIColor *)colorSectionHeader;

#pragma mark - textfield 背景色
+ (UIColor *)colorTextfieldBackground;

+ (UIColor *)colorTextfieldBackBackground;

#pragma mark - 字体颜色
+ (UIColor *)colorMainTextColor;

#pragma mark - 二号字体颜色 例如申请中名字后面的的日期
+ (UIColor *)colorMainSecTextColor;

#pragma mark - 三号号字体颜色 例如申请中名字后面的的日期
+ (UIColor *)colorMainThirdTextColor;

#pragma mark - 导航栏背景色
+ (UIColor *)colorNavigationBackground;
    
#pragma mark - 主题颜色
+ (UIColor *)colorThemeColor;

#pragma mark - 主题tint颜色
+ (UIColor *)colorThemeTintColor;

#pragma mark - section标题颜色
+ (UIColor *)colorSectionTitleColor;

#pragma mark - 蓝色颜色
+ (UIColor *)Thecolor_blueColor;

#pragma mark - # 字体
+ (UIColor *)colorTextBlack;
+ (UIColor *)colorTextGray;
//+ (UIColor *)colorTextGray1;
//
//
//#pragma mark - 灰色
//+ (UIColor *)colorGrayBG;           // 浅灰色默认背景
//+ (UIColor *)colorGrayCharcoalBG;   // 较深灰色背景（聊天窗口, 朋友圈用）
//+ (UIColor *)colorGrayLine;
//+ (UIColor *)colorGrayForChatBar;
//+ (UIColor *)colorGrayForMoment;
//
//
//
//#pragma mark - 绿色
//+ (UIColor *)colorGreenDefault;
//
//
//#pragma mark - 蓝色
//+ (UIColor *)colorBlueMoment;
//
//
//#pragma mark - 黑色
//+ (UIColor *)colorBlackForNavBar;
//+ (UIColor *)colorBlackBG;
//+ (UIColor *)colorBlackAlphaScannerBG;
//+ (UIColor *)colorBlackForAddMenu;
//+ (UIColor *)colorBlackForAddMenuHL;

@end
