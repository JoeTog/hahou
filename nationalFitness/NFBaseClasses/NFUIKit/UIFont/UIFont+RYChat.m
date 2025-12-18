//
//  UIFont+RYChat.m
//  RYKit
//
//  Created by zhangll on 16/8/18.
//  Copyright © 2016年 安徽软云信息科技有限公司. All rights reserved.
//

#import "UIFont+RYChat.h"

@implementation UIFont (RYChat)

#pragma Courier 字体
+ (UIFont *) fontName_Courier_Size:(CGFloat)size
{
    return [UIFont fontWithName:@"Courier" size:size];
}



+ (UIFont *) fontMainText
{
//    return [UIFont boldSystemFontOfSize:17];
    return [UIFont systemFontOfSize:17];
    
}


+ (UIFont *) fontSectionBadge
{
    return [UIFont boldSystemFontOfSize:8];
}

+ (UIFont *) fontSectionBigBadge
{
    return [UIFont boldSystemFontOfSize:11];
}

+ (UIFont *) fontSectionHeader
{
    return [UIFont boldSystemFontOfSize:12.5f];
}


+ (UIFont *) fontNavBarTitle
{
    return [UIFont boldSystemFontOfSize:17.5f];
}

+ (UIFont *) fontConversationUsername
{
    return [UIFont systemFontOfSize:17.0f];
}

+ (UIFont *) fontConversationDetail
{
    return [UIFont systemFontOfSize:14.0f];
}

+ (UIFont *) fontConversationTime
{
    return [UIFont systemFontOfSize:12.5f];
}

+ (UIFont *) fontFriendsUsername
{
    return [UIFont systemFontOfSize:17.0f];
}

+ (UIFont *) fontMineNikename
{
    return [UIFont systemFontOfSize:17.0f];
}

+ (UIFont *) fontMineUsername
{
    return [UIFont systemFontOfSize:14.0f];
}

+ (UIFont *) fontSettingHeaderAndFooterTitle
{
    return [UIFont systemFontOfSize:14.0f];
}

+ (UIFont *)fontTextMessageText
{
    CGFloat size = [[NSUserDefaults standardUserDefaults] doubleForKey:@"CHAT_FONT_SIZE"];
    if (size == 0) {
        size = 16.0f;
    }
    return [UIFont systemFontOfSize:size];
}

@end
