//
//  EmojiShift.h
//  表情
//
//  Created by ShawnJI on 2017/9/25.
//  Copyright © 2017年 Shawnji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClearManager.h"

@interface EmojiShift : NSObject
//表情转文字
+(NSString *)emojiShiftstring:(NSString *)content;

//文字转表情
+(NSString *)stringShiftemoji:(NSString *)content;



@end
