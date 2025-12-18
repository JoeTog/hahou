//
//  MessageTableViewCell.h
//  nationalFitness
//
//  Created by Joe on 2017/6/28.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageEntity.h"
#import "UUMessageFrame.h"
#import "UUMessage.h"
#import "UIImageView+WebCache.h"
#import "UUAVAudioPlayer.h"
#import "UUMessageContentButton.h"
#import "UIImage+SDResize.h"
#import "SVProgressHUD.h"
#import "MessageChatListViewController.h"
#import "LWWeChatActionSheet.h"
#import "ZJContact.h"
#import "HCDTimer.h"
#import "GYHSectorProgressView.h"
#import "NFMyManage.h"
#import "NFHeadImageView.h"

//查看聊天图片
#import "GQImageViewer.h"
#import "UIImage+GQImageViewrCategory.h"
#import "GQImageDataDownload.h"
#import "LWWeChatActionSheet.h"

#import "PopView.h"

#import "UIColor+RYChat.h"


#import "SocketRequest.h"



#define outTime 8

//#import <CoreImage/CoreImage.h> //保存图片

typedef void (^ReturnLongTapBlock)(void);
typedef void (^ReturnEditBlock)(void);
typedef void (^ReturnCancelBlock)(void);
typedef void (^ReturnDeleteBlock)(void);
typedef void (^ReturnDrowBlock)(void);
typedef void (^ReturnRegisterResponderBlock)(void);

@interface MessageTableViewCell : UITableViewCell<UUAVAudioPlayerDelegate>

//点击更多
@property(nonatomic,copy)ReturnEditBlock returnEditBlock;
-(void)returnEdit:(ReturnEditBlock)block;
//点击取消【没用到】
@property(nonatomic,copy)ReturnCancelBlock returnCancelBlock;
-(void)returnCancel:(ReturnCancelBlock)block;
//点击删除
@property(nonatomic,copy)ReturnDeleteBlock returnDeleteBlock;
-(void)returnDelete:(ReturnDeleteBlock)block;
//点击撤回
@property(nonatomic,copy)ReturnDrowBlock returnDrowBlock;
-(void)returnDrow:(ReturnDrowBlock)block;
//长按
@property(nonatomic,copy)ReturnLongTapBlock returnLongTapBlock;
-(void)returnLongTap:(ReturnLongTapBlock)block;
//放弃第一响应者
@property(nonatomic,copy)ReturnRegisterResponderBlock returnRegisterResponderBlock;
-(void)returnRegisterResponder:(ReturnRegisterResponderBlock)block;

@property(nonatomic,strong)HCDTimer *timer;

@property (strong, nonatomic) NFMyManage *myManage;    //懒加载 fmdbServicee

@property (nonatomic, strong) UUMessageFrame *messageFrame;

//要紧的显示
@property (nonatomic, strong) UUMessageFrame *messageFrameUrgent;


@property (weak, nonatomic) IBOutlet UIImageView *failSendImageV;



@property (weak, nonatomic) IBOutlet NFHeadImageView *youImageView;

//重新发送按钮
@property (weak, nonatomic) IBOutlet UIButton *reSendBtn;


//对方消息 高度 宽度约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *otherContantWidthConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *otherContantHeightConstraint;

//自己消息 高度 宽度约束

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mineContantWidthConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mineContantHeightConstraint;

//对方消息距离顶部约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *otherContantTopConstaint;


//我的消息距离顶部约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mineContantTopConstaint;

//对方头像距离顶部距离
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *otherIconImageTopConstaint;



@property (nonatomic, retain)UUMessageContentButton *btnContent;


@property(nonatomic,strong)NSString *meName;

@property(nonatomic,strong)NSString *otherName;


@property(nonatomic,strong)NSString *chatMemberId;


//头像
@property(nonatomic,strong)NSString *headPicpath;

@property(nonatomic,strong)UITableView *singleTableV;

@property(nonatomic,strong)UIViewController *singleViewController;

@property(nonatomic,strong)NSIndexPath *selectedIndexPath;

@property(nonatomic,strong)NSMutableArray *dataArr;

@property (nonatomic, strong) ZJContact *singleContactEntity;

//文字中的网址 【用于记录】
@property (nonatomic, copy) NSString *urlStr;

//点击的消息中的 网址数组【消息中有一条网址则就有一条数据】
@property (nonatomic, copy) NSMutableArray *searchedURLArr;



@end
