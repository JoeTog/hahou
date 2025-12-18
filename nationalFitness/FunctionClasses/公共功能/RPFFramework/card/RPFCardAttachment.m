//
//  RPFCard.m
//  NIM
//
//  Created by King on 2019/3/6.
//  Copyright © 2019年 Netease. All rights reserved.
//

#import "RPFCardAttachment.h"

@implementation RPFCardAttachment

/*
 //名片信息
 #define CMCardSendUserId     @"sendCardUserId"
 #define CMCardId     @"cardId"
 #define CMCardName       @"cardName"
 #define CMCardTitle     @"cardTitle"
 #define CMCardIsGroup       @"isGroup"
 #define CMCardIconUrl     @"cardIconUrl"
 */

- (NSString *)encodeAttachment {
    NSDictionary *dictContent = @{
                                  CMCardSendUserId   :  self.sendUserId,
                                  CMCardId :  self.cardId,
                                  CMCardName      :  self.name,
                                  CMCardTitle:self.title,
                                  CMCardIsGroup:self.isGroup?@"1":@"0",
                                  CMCardIconUrl:self.iconUrl,
                                  };
    
    
    NSDictionary *dict = @{CMType: @(CustomMessageTypeCard), CMData: dictContent};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0
                                                         error:nil];
    return [[NSString alloc] initWithData:jsonData
                                 encoding:NSUTF8StringEncoding];
}


//- (CGSize)contentSize:(NIMMessage *)message cellWidth:(CGFloat)width {
//    return CGSizeMake(249, 96);
//}


//- (UIEdgeInsets)contentViewInsets:(NIMMessage *)message {
//    CGFloat bubblePaddingForImage    = 3.f;
//    CGFloat bubbleArrowWidthForImage = 5.f;
//    if (message.isOutgoingMsg) {
//        return  UIEdgeInsetsMake(bubblePaddingForImage,bubblePaddingForImage,bubblePaddingForImage,bubblePaddingForImage + bubbleArrowWidthForImage);
//    }else{
//        return  UIEdgeInsetsMake(bubblePaddingForImage,bubblePaddingForImage + bubbleArrowWidthForImage, bubblePaddingForImage,bubblePaddingForImage);
//    }
//}

//- (NSString *)cellContent:(NIMMessage *)message{
//    return @"RPFCardMessageContentView";
//}

- (BOOL)canBeForwarded
{
    return NO;
}

- (BOOL)canBeRevoked
{
    return NO;
}



@end
