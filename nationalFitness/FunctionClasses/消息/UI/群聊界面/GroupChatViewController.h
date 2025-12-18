//
//  GroupChatViewController.h
//  nationalFitness
//  根据最后一条消息id 请求消息历史【没有传0】
//  Created by Joe on 2017/8/29.
//  Copyright © 2017年 chenglong. All rights reserved.
//
//图片压缩 语音处理
//dealTheFunctionData


#import "NFbaseViewController.h"

//#import "MessageTableViewCell.h"
#import "GroupMessageTableViewCell.h"

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
#import "GroupShowInviteTableViewCell.h"
#import "YTEmojiView.h"
#import "EmojiShift.h"
#import "MKPAlertView.h"
#import "bottomEditMenuView.h"
#import "FMDBService.h"
//#import "UIButton+touch.h"


#import "RedPacketOtherTableViewCell.h"
#import "TableViewAnimationKitHeaders.h"


#import "RecommendFriendTableViewCell.h"
#import "RecommendFridOtherTableViewCell.h"

#import "GroupAddMemberViewController.h"

#import "GCDTimerManager.h"

#import "UIButton+BtnClick.h"




//点击了红包按钮  执行 [[NTESRedPacketManager sharedManager] sendRedPacket:@{@"groupId":self.groupCreateSEntity.groupId,@"memberId":contact.friend_userid}];
//整合参数 执行[jrmf doActionPresentSendRedEnvelopeViewController:[self topViewController] thirdToken:THIRD_TOKEN
//跳转到 RPFSendRedPacketVC 界面
//点击塞进红包 发送红包消息，收到发送成功后 pop到群聊界面、执行_sendRPFinishBlock 代理执行dojrmfActionDidSendEnvelopedWithID
// 执行_sendRPFinishBlock 暂时没有用处




@interface GroupChatViewController : NFbaseViewController<UIImagePickerControllerDelegate,UITextViewDelegate,SGPhotoPickerDelegate,UINavigationControllerDelegate>

//懒加载
@property (strong, nonatomic) NFMyManage *myManage;    //懒加载 fmdbServicee
//懒加载
@property (copy, nonatomic) NSMutableDictionary *parms;    //懒加载

@property (copy, nonatomic) NSMutableDictionary *cacheDataRowSendStatusDict;    //懒加载

@property (strong, nonatomic) FMDBService *fmdbServicee;

//会话id
@property(nonatomic,strong)NSString *conversationId;

//群组名字
@property(nonatomic,strong)NSString *groupName;

//群组聊天 联系人数组
@property(nonatomic,copy)NSArray *memberArr;

//群组聊天 群组总人数
@property(nonatomic,strong)NSString *groupTotalNum;

//GroupCreateSuccessEntity 用到的
@property(nonatomic,strong)GroupCreateSuccessEntity *groupCreateSEntity;


//群组实体
//@property (nonatomic, strong)GroupChatEntity *groupContactEntity;

//键盘输入框
@property(nonatomic,strong)UUInputFunctionView *IFView_;

//当来自搜索聊天记录时候 下面大于0 需要展示表中 后historyIndex条数据
@property (nonatomic, assign)   int historyIndex;


#pragma mark - 刷新函数
-(void)refresh;


//是否有未读
@property(nonatomic)BOOL IsHaveNotRead;

//是否能够发消息 【当正在重连的时候 不允许发消息】 willappear时 就设置为NO 【从detail界面pop回来时 也需要请求历史消息】
@property (nonatomic, assign) BOOL isCanSendMessage;

//未读条数【由于消息在会话列表界面进行了消息缓存 那么进来请求消息count则为0，就算外面显示99未读 进来也没有右上角的提示 所以需要记录未读】
@property (nonatomic, assign)   NSInteger unreadCount;

//会话列表总未读消息
@property (nonatomic, assign)   NSInteger unreadAllCount;





-(void)tapTableView;

- (void)tableViewScrollToBottomOffSetUseByMoreView;




@end








