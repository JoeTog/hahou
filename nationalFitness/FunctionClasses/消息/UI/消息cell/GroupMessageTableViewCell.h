//
//  GroupMessageTableViewCell.h
//  nationalFitness
//
//  Created by Joe on 2017/9/2.
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
#import "ZJContactDetailTableViewController.h"
#import "HCDTimer.h"
#import "NFMyManage.h"
#import "PopView.h"

//查看聊天图片
#import "GQImageViewer.h"
#import "UIImage+GQImageViewrCategory.h"
#import "GQImageDataDownload.h"

#import "SocketRequest.h"



#define outTime 8

typedef void (^ReturnEditBlock)(void);
typedef void (^ReturnCancelBlock)(void);

typedef void (^ReturnDrowBlock)(void);
typedef void (^ReturnRegisterResponderBlock)(void);
typedef void (^ReturnheadViewLongPressBlock)(void);
typedef void (^ReturnDeleteBlock)(void);

@interface GroupMessageTableViewCell : UITableViewCell<UUAVAudioPlayerDelegate,UITableViewDelegate,UITableViewDataSource>

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

//长按 对方头像 艾特某人
@property(nonatomic,copy)ReturnheadViewLongPressBlock returnLongBlock;
-(void)returnLong:(ReturnheadViewLongPressBlock)block;



//放弃第一响应者
@property(nonatomic,copy)ReturnRegisterResponderBlock returnRegisterResponderBlock;
-(void)returnRegisterResponder:(ReturnRegisterResponderBlock)block;

@property (nonatomic, strong) UUMessageFrame *messageFrame;

@property(nonatomic,strong)HCDTimer *timer;

@property (strong, nonatomic) NFMyManage *myManage;    //懒加载 fmdbServicee


//对方头像
@property (weak, nonatomic) IBOutlet NFHeadImageView *youImageView;
//[cell.youImageView afterClickHeadImage:^{

//发送失败按钮图片
//@property (weak, nonatomic) IBOutlet UIImageView *failSendImageV;

//重发按钮
@property (weak, nonatomic) IBOutlet UIButton *reSendBtn;



@property (weak, nonatomic) IBOutlet NSLayoutConstraint *otherContanttWidthConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *otherContanttHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mineContanttHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mineContanttWidthConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *otherContanttTopConstaint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mineContantTopConstaint;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *otherIconImageTopConstaint;

//个人详情view
@property (nonatomic, strong) ZJContactDetailTableViewController *ZJContactDetailController;


@property(nonatomic,strong)UITableView *groupTableV;

@property(nonatomic,strong)UIViewController *groupViewController;

@property(nonatomic,strong)UIControl *imageBackControl;

@property(nonatomic,strong)NSIndexPath *selectedIndexPath;

@property(nonatomic,strong)NSMutableArray *dataArr;

@property(nonatomic,strong)NSString *groupChatTableName;

@property(nonatomic,strong)UIViewController *singleViewController;


@property (nonatomic, retain)UUMessageContentButton *btnContent;


@property(nonatomic,strong)NSString *meName;

@property(nonatomic,strong)NSString *otherName;


@property(nonatomic,strong)NSString *GroupId;

//群组消息缓存表名字 上面有
//@property(nonatomic,strong)NSString *cacheGroupName;

//点击的消息中的 网址数组【消息中有一条网址则就有一条数据】
@property (nonatomic, copy) NSMutableArray *searchedURLArr;

@end

