//
//  RPFCard.h
//  NIM
//
//  Created by King on 2019/3/6.
//  Copyright © 2019年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESCustomAttachmentDefines.h"

NS_ASSUME_NONNULL_BEGIN

//@interface RPFCardAttachment : NSObject<NIMCustomAttachment,NTESCustomAttachmentInfo>
@interface RPFCardAttachment : NSObject

/*
//名片信息
 #define CMCardSendUserId     @"sendCardUserId"
 #define CMCardId     @"cardId"
 #define CMCardName       @"cardName"
 #define CMCardTitle     @"cardTitle"
 #define CMCardIsGroup       @"isGroup"
 #define CMCardTitle     @"cardTitle"
 #define CMCardIconUrl     @"cardIconUrl"
 */

 @property (nonatomic, copy) NSString *cardId;//名片对应的用户的ID
 @property (nonatomic, copy) NSString *sendUserId;//发名片的人的id
@property (nonatomic, copy) NSString *name;//名片对应的用户名
@property (nonatomic, copy) NSString *iconUrl;//图片url

 @property (nonatomic, copy) NSString *title;//标题：r个人名片
 @property (nonatomic, assign) BOOL isGroup;//是否是群
 


@end

NS_ASSUME_NONNULL_END
