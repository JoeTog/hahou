//
//  MessageChatViewController.h
//  nationalFitness
// 聊天消息界面  群组聊天（多个详情） //  根据最后一条消息id 请求消息历史【没有传0】
//  Created by Joe on 2017/6/28.
//  Copyright © 2017年 chenglong. All rights reserved.
//
//图片压缩 语音处理
//dealTheFunctionData

#import "NFbaseViewController.h"
#import "MessageTableViewCell.h"
#import "UUMessageFrame.h"
#import "UUMessage.h"
#import "UUInputFunctionView.h"
#import "NFDatabaseQueue.h"
#import "NFPacketHandler.h"
#import "PopView.h"
#import "JSON.h"
#import "JsonModel.h"
#import "SocketModel.h"
#import "SocketRequest.h"
#import "AppDelegate.h"
#import "SingleChatDetailTableViewController.h"
#import "GroupChatDetailTableViewController.h"
#import "JQFMDB.h"
#import "UITableView+RYChat.h"
#import "SGPhotoPickerViewController.h"
#import "MessageChatManage.h"
#import "NotExistFriendListTableViewCell.h"
#import "FMDBService.h"
#import "MKPAlertView.h"
#import "ClearManager.h"
#import "UUMessageContentButton.h"
#import "bottomEditMenuView.h"
//#import "UIButton+touch.h"
#import "NFShowImageView.h"

//controller
#import "RedDetailViewController.h"
#import "RedDetailTableViewController.h"

//cell
#import "RedPacketTableViewCell.h"


#import "DWURunLoopWorkDistribution.h"//优化tableview 滑动


#import "NTESRedPacketManager.h"


//红包详情
#import "RPFRedpacketDetailVC.h"

#import "GroupShowInviteTableViewCell.h"

//转账
#import "TransferAccountTableViewController.h"

#import "SendTableViewController.h"

//上传图片到 阿里云
#import <AliyunOSSiOS/OSSService.h>
#import "AliyunOSSUpload.h"




//#import "SocketModel+ease.h"

@interface MessageChatViewController : NFbaseViewController<UIImagePickerControllerDelegate,UITextViewDelegate,SGPhotoPickerDelegate,UINavigationControllerDelegate>

//懒加载
@property (strong, nonatomic) NFMyManage *myManage;    //懒加载 fmdbServicee

@property (strong, nonatomic) FMDBService *fmdbServicee;
//懒加载
@property (copy, nonatomic) NSMutableDictionary *parms;    //懒加载

@property (copy, nonatomic) NSMutableDictionary *cacheDataRowSendStatusDict;    //懒加载

//聊天标题
@property(nonatomic,strong)NSString *titleName;

//会话id  或 好友id 【从会话列表进来 或 从联系人进来】
@property(nonatomic,strong)NSString *conversationId;

//会话类型 0单聊 1群聊(有个群组详情按钮)
@property(nonatomic,strong)NSString *chatType;

//当来自搜索聊天记录时候 下面大于0 需要展示表中 后historyIndex条数据
@property (nonatomic, assign)   int historyIndex;

//群组聊天 联系人数组
@property(nonatomic,copy)NSArray *memberArr;

//是否来自添加聊天 这样的恶化退出时候要退出到住界面
@property(nonatomic)BOOL IsFromAdd;

//是否来自名片推荐 来自名片 不请求历史记录
@property(nonatomic)BOOL IsFromCard;


//单人聊天实体 MessageChatListEntity 弃用
//@property (nonatomic, strong) MessageChatListEntity *singleEntity;
//单人聊天实体
@property (nonatomic, strong) ZJContact *singleContactEntity;

//
//@property (nonatomic, strong) ZJContact *singleContant;

//双方姓名
@property(nonatomic,strong)NSString *meName;

@property(nonatomic,strong)NSString *otherName;

//键盘输入框
@property(nonatomic,strong)UUInputFunctionView *IFView_;

#pragma mark - 请求单聊消息历史 在delegate收到推送 并且在单聊界面时候 【不行 当不是和推送对象是同一个人时 不对】
-(void)getSingelChatData;

#pragma mark - 刷新函数
-(void)refresh;

//是否有未读 如果有未读 则强制进行已读请求
@property(nonatomic)BOOL IsHaveNotRead;
    
//是否能够发消息 【当正在重连的时候 不允许发消息】 willappear时 就设置为NO 【从detail界面pop回来时 也需要请求历史消息】
@property (nonatomic, assign) BOOL isCanSendMessage;

//当单聊也和群聊一样有 在会话列表界面就进行了缓存 则需要用到下面参数
//未读条数【由于消息在会话列表界面进行了消息缓存 那么进来请求消息count则为0，就算外面显示99未读 进来也没有右上角的提示 所以需要记录未读】
@property (nonatomic, assign)   NSInteger unreadCount;

//会话列表总未读消息
@property (nonatomic, assign)   NSInteger unreadAllCount;


@end





