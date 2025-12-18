//
//  UIFont+RYChat.h
//  RYKit
//
//  Created by zhangll on 16/8/18.
//  Copyright © 2016年 安徽软云信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (RYChat)

#pragma Courier 字体
+ (UIFont *) fontName_Courier_Size:(CGFloat)size;




+ (UIFont *) fontMainText;

#pragma mark - badge未读消息
+ (UIFont *) fontSectionBadge;

#pragma mark - badge未读消息 大字体
+ (UIFont *) fontSectionBigBadge;

#pragma mark - section分区头字体font
+ (UIFont *) fontSectionHeader;


#pragma mark - Common
+ (UIFont *)fontNavBarTitle;

#pragma mark - Conversation
+ (UIFont *)fontConversationUsername;
+ (UIFont *)fontConversationDetail;
+ (UIFont *)fontConversationTime;

#pragma mark - Friends
+ (UIFont *) fontFriendsUsername;

#pragma mark - Mine
+ (UIFont *)fontMineNikename;
+ (UIFont *)fontMineUsername;

#pragma mark - Setting
+ (UIFont *)fontSettingHeaderAndFooterTitle;


#pragma mark - Chat
+ (UIFont *)fontTextMessageText;

@end
