//
//  SDFaceToolBar.h
//  SDChat
//
//  Created by Megatron Joker on 2017/6/1.
//  Copyright © 2017年 SlowDony. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+FW.h"

typedef void (^ReturnSendBlock)(void);

typedef void (^ReturnCollectBlock)(void);
typedef void (^ReturnEmoilBlock)(void);



/**
 表情工具栏
 */
@interface SDFaceToolBar : UIView

@property(nonatomic,copy)ReturnSendBlock returnSendBlock;

@property(nonatomic,copy)ReturnCollectBlock returnCollectBlock;
@property(nonatomic,copy)ReturnEmoilBlock returnEmoilBlock;
//点击发送表情按钮
-(void)returnSend:(ReturnSendBlock)block;

//点击收藏表情按钮
-(void)returnCollectBlock:(ReturnSendBlock)block;

//点击表情按钮
-(void)returnEmoilBlock:(ReturnSendBlock)block;
/**
 发送按钮
 */
@property (nonatomic,strong)  UIButton *sendBtn;


/**
  收藏的表情 按钮 【为选中 而且不可点】
 */
@property (nonatomic,strong)  UIButton *collectBtn;

/**
 表情按钮 【为 未选中 选中后传出事件切换到表情】
 */
@property (nonatomic,strong)  UIButton *emoilBtn;


@end
