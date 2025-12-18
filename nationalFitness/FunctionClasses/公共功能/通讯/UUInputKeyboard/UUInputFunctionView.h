//
//  UUInputFunctionView.h
//  UUChatDemoForTextVoicePicture
//
//  Created by shake on 14-8-27.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIButton+Extensions.h"
#import "UIImage+FW.h"
#import "NFMyManage.h"

#import "SLGrowingTextView.h"
#import "YTKeyBoardView.h"
#import "UIView+YTLayer.h"
#import "UIImage+YTGif.h"
#import "YTDeviceTest.h"
#import "YTEmojiView.h"
#import "YTEmoji.h"
#import "YTMoreView.h"
#import "YTTextView.h"
#import "Masonry.h"
#import "SDChatAddFacekeyBoardView.h"
#import "SDFaceModel.h"
#import "NSString+Emoji.h"
#import "UIImage+Rotate.h"
#import "TZImagePickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "UIColor+RYChat.h"

#import "MessageEntity.h"
#import "RedTableViewController.h"
#import "RedSingleTableViewController.h"


//#import "NTESRedPacketManager.h"

#import "EmotionKeyboard.h"

//报警
//#import "SocketRequest.h"



#define AnimationTime 0.3


/* 小图标(录音,表情,更多)位置参数 */
//#define   ICON_LR     12.0f //左右边距
#define   ICON_LR     7.0f //左右边距
#define   ICON_TOP    8.0f  //顶端边距
//#define   ICON_WH     28.0f //宽高
#define   ICON_WH     35.0f //宽高
/* textView 高度默认补充 为了显示更好看 */
//#define   TOP_H       44.0f
#define   TOP_H       50.0f
#define   TEXT_FIT    10.0f
#define  DURTAION  0.25f

//注意 newframe 当界面的frame需要变动时候 全局跟着newframe 设置位置

typedef void(^beginEditTextView)(void);

typedef void(^endEditTextView)(void);

typedef void(^EditingTextView)(void);

typedef void(^ClickRedpacket)(void);

typedef void(^IInputAiTe)(void);

typedef void(^ClickTransferAccont)(void);

typedef void(^ClickCard)(void);


typedef void(^DeleteCollectPicture)(NSString *fileId);


typedef void(^ClickInvite)(void);


typedef void(^destorySelf)(void);

@class UUInputFunctionView;

@protocol UUInputFunctionViewDelegate <NSObject>

// 文字
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendMessage:(NSString *)message;

// text
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView showMessage:(NSString *)message SendMessage:(NSString *)sendMessage;

// image 废弃 增加了一个参数：是否为原图
//- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendPicture:(UIImage *)image;

//图片
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendPicture:(UIImage *)image IsselectedOrginalImage:(BOOL)ret;


//红包
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendRed:(RedEntity *)redEntity;


// audio
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendVoice:(NSData *)voice time:(NSInteger)second;

// 收藏中的图片
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendPictureUrl:(NSString *)url;

// 收藏中的图片 传出图片字典
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendPictureDict:(NSDictionary *)dictt;


@end

@interface UUInputFunctionView : UIView <UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate,RedTableViewDelegate,RedSingleTableViewDelegate>

//tableview
@property (nonatomic, retain) UIViewController *SuperController;


//是否需要正在输入等的回调
@property (nonatomic, assign) BOOL isNeedBlock;

//父视图tableview
@property (nonatomic, retain) UITableView *superTableview;

//相机 更多按钮 右2    // emojiBtn   btnSendMessage  
@property (nonatomic, retain) UIButton *btnSendMessage;
//语音小按钮 左1
@property (nonatomic, retain) UIButton *btnChangeVoiceState;
//语音大按钮
@property (nonatomic, retain) UIButton *btnVoiceRecord;
//输入框
@property (nonatomic, retain) SLGrowingTextView *TextViewInput;
//表情控制器
@property (nonatomic, retain) YTEmojiView *emojiView;
/**
 添加表情view
 */
@property (nonatomic,retain)SDChatAddFacekeyBoardView *addFaceView;
//表情图标 右1
@property (nonatomic, retain) UIButton *emojiBtn;
//更多功能按钮界面
@property (nonatomic, retain) YTMoreView *moreView;

@property (nonatomic, assign) BOOL isAbleToSendTextMessage;

@property (nonatomic, assign) UIViewController *superVC;

@property (nonatomic, assign) id<UUInputFunctionViewDelegate>delegate;

//开始编辑
@property(nonatomic,copy)beginEditTextView textEditBlock;
//结束编辑
@property(nonatomic,copy)endEditTextView textEndEditBlock;
//
@property(nonatomic,copy)EditingTextView textEditingBlock;

@property(nonatomic,copy)ClickRedpacket clickRedpacket;

@property(nonatomic,copy)ClickCard clickCard;


@property(nonatomic,copy)IInputAiTe inputAiTe;

@property(nonatomic,copy)ClickTransferAccont clickTransferAccont;

@property(nonatomic,copy)DeleteCollectPicture DeleteCollectpicture;


@property(nonatomic,copy)ClickInvite ClickInvite;


@property(nonatomic,copy)destorySelf destorySelfff;


// 最大和最小高度，根据行数、contentInset计算而来
@property (nonatomic, assign) int minHeight;
@property (nonatomic, assign) int maxHeight;

/**
 * 内部textView的insets
 */
@property (nonatomic, assign) UIEdgeInsets contentInset;

-(void)EditTextview:(beginEditTextView)block;

-(void)EndEditBlock:(endEditTextView)block;

-(void)textEditingBlock:(EditingTextView)block;

-(void)clickRedpacket:(ClickRedpacket)block;

-(void)clickCard:(ClickCard)block;


-(void)iinputAiTe:(IInputAiTe)block;

-(void)clickTransferAccont:(ClickTransferAccont)block;


//删除收藏的图片
-(void)deleteCollectPicture:(DeleteCollectPicture)block;


-(void)ClickInvite:(ClickInvite)block;

//暂时没用
-(void)destorySelfClick:(destorySelf)block;



- (id)initWithSuperVC:(UIViewController *)superVC;

- (void)changeSendBtnWithPhoto:(BOOL)isPhoto;

-(void)deallocMySelf;

-(void)AddNotification;

#pragma mark - 收起表情
-(void)hidenEmoji;

#pragma mark - 收起更多按钮
-(void)hidenMoreBtn;

#pragma mark - 收起输入框
-(void)hideninputView;

-(void)removeEmotionKeyboardOberser;




@end
