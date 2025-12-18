//
//  NFCommentInputView.h
//  MessageDisplay
//
//  Created by zhoubin@moshi on 14-5-10.
//  Copyright (c) 2014年 Crius_ZB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBMessageTextView.h"

typedef enum
{
  NFCommentInputViewStyleDefault, // ios7 样式
  NFCommentInputViewStyleQuasiphysical
} NFCommentInputViewStyle;

@protocol NFCommentInputViewDelegate <NSObject>

@required

/**
 *  输入框刚好开始编辑
 *
 *  @param messageInputTextView 输入框对象
 */
- (void)inputTextViewDidBeginEditing:(ZBMessageTextView *)messageInputTextView;

/**
 *  输入框将要开始编辑
 *
 *  @param messageInputTextView 输入框对象
 */
- (void)inputTextViewWillBeginEditing:(ZBMessageTextView *)messageInputTextView;

/**
 *  输入框输入时候
 *
 *  @param messageInputTextView 输入框对象
 */
- (void)inputTextViewDidChange:(ZBMessageTextView *)messageInputTextView;

/**
 *  键盘将要弹出
 *
 *  @param messageInputTextView 输入框对象
 */

- (void)keyBoardWillShow:(CGRect)rect animationDuration:(CGFloat)duration;

/**
 *  键盘将要消失
 *
 *  @param messageInputTextView 输入框对象
 */

- (void)keyBoardWillHidden:(CGRect)rect animationDuration:(CGFloat)duration;

/**
 *  键盘已经弹出
 *
 *  @param messageInputTextView 输入框对象
 */

- (void)keyBoardChange:(CGRect)rect animationDuration:(CGFloat)duration;

@optional

/**
 *  点击语音按钮Action
 */
- (void)didChangeSendImage:(BOOL)changed;

/**
 *  发送文本消息，包括系统的表情
 *
 *  @param messageInputTextView 输入框对象
 */
- (void)didSendTextAction:(ZBMessageTextView *)messageInputTextView;

/**
 *  发送第三方表情
 */
- (void)didSendFaceAction:(BOOL)sendFace;

/**
 *  获取的图片
 */

- (void)getImagePickerController:(UIImagePickerController *)picker withInfo:(NSDictionary *)info;

/**
 *  评论成功
 */

- (void)commentSuccess;

@end

@interface NFCommentInputView : UIImageView

@property (nonatomic,weak) id<NFCommentInputViewDelegate> delegate;

@property (copy, nonatomic) NSMutableDictionary *parms;    //懒加载


@property (nonatomic, assign) BOOL isFromHome; // 是否是从动态列表页进来的 暂时无效

/**
 *  评论的对象 1活动赞助 2帖子
 */
@property (nonatomic, strong) NSString *commentType;

/**
 *  评论的对象ID
 */
@property (nonatomic, strong) NSString *commentId;

/**
 *  当回复时传递评论ID
 */
@property (nonatomic, strong) NSString *byCommId;

/**
 *  评论主键
 */
@property (nonatomic, strong) NSString *commId;

/**
 *  用于输入文本消息的输入框
 */
@property (nonatomic,strong,readonly) ZBMessageTextView *messageInputTextView;

/**
 *  当前输入工具条的样式
 */
@property (nonatomic, assign) NFCommentInputViewStyle messageInputViewStyle;

/**
 *  切换文本和语音的按钮
 */
@property (nonatomic, strong, readonly) UIButton *voiceChangeButton;

/**
 *  +号按钮
 */
@property (nonatomic, strong, readonly) UIButton *multiMediaSendButton;

/**
 *  第三方表情按钮
 */
@property (nonatomic, strong, readonly) UIButton *faceSendButton;

/**
 *  语音录制按钮
 */
@property (nonatomic, strong, readonly) UIButton *holdDownButton;

#pragma mark methods
/**
 *  动态改变高度
 *
 *  @param changeInHeight 目标变化的高度
 */
- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight;

/**
 *  获取输入框内容字体行高
 *
 *  @return 返回行高
 */
+ (CGFloat)textViewLineHeight;

/**
 *  获取最大行数
 *
 *  @return 返回最大行数
 */
+ (CGFloat)maxLines;

/**
 *  获取根据最大行数和每行高度计算出来的最大显示高度
 *
 *  @return 返回最大显示高度
 */
+ (CGFloat)maxHeight;


//隐藏键盘
-(void)hideKeyBoard;

#pragma end

@end
