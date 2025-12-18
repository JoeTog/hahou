//
//  ChatTexLable.m
//  qmjs
//
//  Created by 程long on 14-9-1.
//  Copyright (c) 2014年 sea. All rights reserved.
//

#import "ChatTexLable.h"


@implementation ChatTexLable

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


#pragma mark - 生成表情文字混合排列和点击事件响应 - begin

- (id)initWithText:(NSString *)text withFrame:(CGRect)frame
{
    self = [super init];
    if (self)
    {
        self.emojiDelegate = self;
        
        //禁用点击邮箱-电话-链接
        self.disableThreeCommon = YES;
    
        self.lineBreakMode = NSLineBreakByCharWrapping;
        
        self.customEmojiRegex = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
        //表情plist
//        self.customEmojiPlistName = @"expression.plist";
        
        [self setEmojiText:text];
        if (frame.size.height > 0)
        {
            self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
        }
        else
        {
            self.numberOfLines = 0;
            self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 0);
            [self sizeToFit];
        }
    }
    return self;
}

- (void)mlEmojiLabel:(MLEmojiLabel*)emojiLabel didSelectLink:(NSString*)link withType:(MLEmojiLabelLinkType)type
{
    switch(type){
        case MLEmojiLabelLinkTypeURL:
            NSLog(@"点击了链接%@",link);
            break;
        case MLEmojiLabelLinkTypePhoneNumber:
            NSLog(@"点击了电话%@",link);
            break;
        case MLEmojiLabelLinkTypeEmail:
            NSLog(@"点击了邮箱%@",link);
            break;
        default:
            NSLog(@"点击了不知道啥%@",link);
            break;
    }
}


@end
