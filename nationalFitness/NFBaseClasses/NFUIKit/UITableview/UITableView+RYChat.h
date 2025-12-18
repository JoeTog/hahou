//
//  UITableView+RYChat.h
//  RYKit
//
//  Created by zhangll on 16/8/16.
//  Copyright © 2016年 安徽软云信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (RYChat)
//
- (void)scrollToBottomWithAnimation:(BOOL)animation offset:(CGFloat)height;

- (void)groupScrollToBottomWithAnimation:(BOOL)animation offset:(CGFloat)height;


//发送消息后 消息滑倒底部
-(void)SendMessageLetTableScrollToBottom:(BOOL)animation offset:(CGFloat)height;
-(void)SendMessageLetTableScrollToBottomBegin:(BOOL)animation offset:(CGFloat)height;






@end
