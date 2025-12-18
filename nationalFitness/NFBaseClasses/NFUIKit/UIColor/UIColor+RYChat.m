//
//  UIColor+RYChat.m
//  RYKit
//
//  Created by zhangll on 16/8/18.
//  Copyright © 2016年 安徽软云信息科技有限公司. All rights reserved.
//

#import "UIColor+RYChat.h"
#import "NFbaseViewController.h"

@implementation UIColor (RYChat)

#pragma mark - sectionheadview 背景色
+ (UIColor *)colorSectionHeader{
    if ([NFUserEntity shareInstance].selectedTheme) {
     //   NSLog(@"主题已缓存");
    }else{
        CacheKeepBoxEntity *entityy = [[NFbaseViewController new] getAllCacheDataEntity];
        [NFUserEntity shareInstance].selectedTheme = entityy.themeSelectedIndex;
    }
    
    if ([NFUserEntity shareInstance].selectedTheme == 0) {
        return [UIColor blackColor];
    }else if ([NFUserEntity shareInstance].selectedTheme == 1){
        return [UIColor groupTableViewBackgroundColor];
    }
    return [UIColor groupTableViewBackgroundColor];
    
}

//导航栏背景色
+ (UIColor *)colorNavigationBackground{
    //  浅灰色
    UIColor *color = UIColorFromRGB(0x465add);
    //color = [UIColor redColor];
    return color;
}

//0xF9FAFB
+ (UIColor *)colorTextfieldBackground{
    //  浅灰色
    UIColor *color = UIColorFromRGB(0xF1F2F3);
    return color;
}

+ (UIColor *)colorTextfieldBackBackground{
    //  浅灰色
    UIColor *color = [UIColor whiteColor];
    return color;
}

#pragma mark - 字体颜色
+ (UIColor *)colorMainTextColor{
    
    if ([NFUserEntity shareInstance].selectedTheme) {
//        NSLog(@"主题已缓存");
    }else{
        CacheKeepBoxEntity *entityy = [[NFbaseViewController new] getAllCacheDataEntity];
        [NFUserEntity shareInstance].selectedTheme = entityy.themeSelectedIndex;
    }
    if ([NFUserEntity shareInstance].selectedTheme == 0) {
        return [UIColor whiteColor];
    }else if ([NFUserEntity shareInstance].selectedTheme == 1){
        return UIColorFromRGB(0x5b77b8);
//        return [UIColor blackColor];
    }
    return [UIColor blackColor];
}

#pragma mark - section标题颜色
+ (UIColor *)colorSectionTitleColor{
    
    return [UIColor grayColor];
}

#pragma mark - 红包背景浅色
+ (UIColor *)colorRedPacketBackColor{
    
    return UIColorFromRGB(0xf7f0f2);
}

#pragma mark - 红包不可点
+ (UIColor *)colorRedPacketUnableColor{
    
    return UIColorFromRGB(0xe59ca7);
}

#pragma mark - 主题颜色  咖啡色 后来改成 灰色
+ (UIColor *)colorThemeColor{
    if ([NFUserEntity shareInstance].selectedTheme) {
//        NSLog(@"主题已缓存");
    }else{
        CacheKeepBoxEntity *entityy = [[NFbaseViewController new] getAllCacheDataEntity];
        if (entityy) {
            [NFUserEntity shareInstance].selectedTheme = entityy.themeSelectedIndex;
        }else{
            [NFUserEntity shareInstance].selectedTheme = 99;
        }
    }
    if ([NFUserEntity shareInstance].selectedTheme == 0) {
        return [UIColor whiteColor];
    }else if ([NFUserEntity shareInstance].selectedTheme == 1){
        return UIColorFromRGB(0xff6699);
//        return UIColorFromRGB(0x503536);
    }else{
        return UIColorFromRGB(0xff6699);
    }
    return [UIColor blackColor];
}

#pragma mark - 主题tint颜色
+ (UIColor *)colorThemeTintColor{
    if ([NFUserEntity shareInstance].selectedTheme) {
//        NSLog(@"主题已缓存");
    }else{
        CacheKeepBoxEntity *entityy = [[NFbaseViewController new] getAllCacheDataEntity];
        if (entityy) {
            [NFUserEntity shareInstance].selectedTheme = entityy.themeSelectedIndex;
        }else{
            [NFUserEntity shareInstance].selectedTheme = 99;
        }
    }
    if ([NFUserEntity shareInstance].selectedTheme == 0) {
        return [UIColor whiteColor];
    }else if ([NFUserEntity shareInstance].selectedTheme == 1){
        return [UIColor whiteColor];
    }else{
        return [UIColor whiteColor];
    }
    return [UIColor blackColor];
}

#pragma mark - 二号字体颜色 例如会话列表最后一条消息s=
+ (UIColor *)colorMainSecTextColor{
    if ([NFUserEntity shareInstance].selectedTheme) {
  //      NSLog(@"主题已缓存");
    }else{
        CacheKeepBoxEntity *entityy = [[NFbaseViewController new] getAllCacheDataEntity];
        if (entityy) {
            [NFUserEntity shareInstance].selectedTheme = entityy.themeSelectedIndex;
        }else{
            [NFUserEntity shareInstance].selectedTheme = 99;
        }
    }
    if ([NFUserEntity shareInstance].selectedTheme == 0) {
        return [UIColor whiteColor];
    }else if ([NFUserEntity shareInstance].selectedTheme == 1){
        return UIColorFromRGB(0x848585);
    }else{
        return UIColorFromRGB(0x848585);
    }
    return [UIColor blackColor];
}

#pragma mark - 三号号字体颜色 例如申请中名字后面的的日期
+ (UIColor *)colorMainThirdTextColor{
    if ([NFUserEntity shareInstance].selectedTheme) {
      //  NSLog(@"主题已缓存");
    }else{
        CacheKeepBoxEntity *entityy = [[NFbaseViewController new] getAllCacheDataEntity];if (entityy) {
            [NFUserEntity shareInstance].selectedTheme = entityy.themeSelectedIndex;
        }else{
            [NFUserEntity shareInstance].selectedTheme = 99;
        }
    }
    if ([NFUserEntity shareInstance].selectedTheme == 0) {
        return [UIColor whiteColor];
    }else if ([NFUserEntity shareInstance].selectedTheme == 1){
        return UIColorFromRGB(0xcdcdcd);
    }else{
        return UIColorFromRGB(0xcdcdcd);
    }
    return [UIColor blackColor];
}

#pragma mark - # 字体
+ (UIColor *)colorTextBlack {
    if ([NFUserEntity shareInstance].selectedTheme) {
    //    NSLog(@"主题已缓存");
    }else{
        CacheKeepBoxEntity *entityy = [[NFbaseViewController new] getAllCacheDataEntity];
        if (entityy) {
            [NFUserEntity shareInstance].selectedTheme = entityy.themeSelectedIndex;
        }else{
            [NFUserEntity shareInstance].selectedTheme = 99;
        }
    }
    if ([NFUserEntity shareInstance].selectedTheme == 0) {
        return [UIColor whiteColor];
    }else if ([NFUserEntity shareInstance].selectedTheme == 1){
        return [UIColor blackColor];
    }else{
        return [UIColor blackColor];
    }
    return [UIColor blackColor];
}

#pragma mark - 蓝色颜色
+ (UIColor *)Thecolor_blueColor {
    return UIColorFromRGB(0x157efb);
}


+ (UIColor *)colorTextGray {
    return [UIColor grayColor];
}


@end
