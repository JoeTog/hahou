//
//  CMessageWrap.h
//  WebSocket
//
//  Created by King on 2017/6/30.
//  Copyright © 2017年 King. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMessageWrap : NSObject

//消息的发送者
@property (nonatomic ,copy) NSString *m_nsFromUsr;
//消息的接收者
@property (nonatomic ,copy) NSString *m_nsToUsr;
//消息的内容
@property (nonatomic ,copy) NSString *m_nsContent;
//消息类型
@property (nonatomic ,assign) int m_uiMessageType;
//消息发送时间
@property (nonatomic ,assign) int m_uiCreateTime;


//创建一个普通文字消息包
- (NSString *)CreateWordMessageWrapWithFromUsr:(NSString *)m_nsFromUsr ToUsr:(NSString *)m_nsToUsr Content:(NSString *)m_nsContent Type:(int)m_uiMessageType time:(int)m_uiCreateTime;















@end




