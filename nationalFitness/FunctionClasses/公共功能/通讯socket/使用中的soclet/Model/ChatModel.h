//
//  ChatModel.h
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/4/14.
//  Copyright © 2017年 mengyao. All rights reserved.
//
/*
 https://github.com/coderMyy/CocoaAsyncSocket_Demo  github地址 ,会持续更新关于即时通讯的细节 , 以及最终的UI代码
 
 https://github.com/coderMyy/MYCoreTextLabel  图文混排 , 实现图片文字混排 , 可显示常规链接比如网址,@,话题等 , 可以自定义链接字,设置关键字高亮等功能 . 适用于微博,微信,IM聊天对话等场景 . 实现这些功能仅用了几百行代码，耦合性也较低
 
 https://github.com/coderMyy/MYDropMenu  上拉下拉菜单，可随意自定义，随意修改大小，位置，各个项目通用
 
 https://github.com/coderMyy/MYPhotoBrowser 照片浏览器。功能主要有 ： 点击点放大缩小 ， 长按保存发送给好友操作 ， 带文本描述照片，从点击照片放大，当前浏览照片缩小等功能。功能逐渐完善增加中.
 
 https://github.com/coderMyy/MYNavigationController  导航控制器的压缩 , 使得可以将导航范围缩小到指定区域 , 实现页面中的页面效果 . 适用于路径选择,文件选择等

 如果有好的建议或者意见 ,欢迎博客或者QQ指出 , 您的支持是对贡献代码最大的鼓励,谢谢. 求STAR ..😊😊😊
 */


#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger) {
    
    SocketConnectStatus_UnConnected       = 0<<0,//未连接状态
    SocketConnectStatus_Connected         = 1<<0,//连接状态
//    SocketConnectStatus_DisconnectByUser  = 2<<0,//主动断开连接
    SocketConnectStatus_Unknow            = 3<<0 //未知
    
}SocketConnectStatus;




typedef NS_ENUM(NSInteger){
    
    SecretLetterType_SocketConnectChanged            = 68<<0, //socket连接发生变化 在需要请求数据的界面需要重新请求刷新
    
    //登陆
    SecretLetterType_Login            = 0<<0,
    SecretLetterType_LoginReceipt     = 5<<0, //登录回执
//    SecretLetterType_LoginReceiptFail     = 71<<0, //登录失败
    SecretLetterType_RegisterReceipt     = 13<<0, //注册
    SecretLetterType_RegisterVerication     = 54 <<0, //验证码发送成功
    SecretLetterType_RegisterVericationOften     = 56 <<0, //验证码发送频繁
    SecretLetterType_RegisterVericationAlreadyBinging     = 57 <<0, //手机号已经被绑定
    SecretLetterType_RegisterVericationAlreadyError     = 58 <<0, //验证码错误
    SecretLetterType_RegisterVericationRetSuccess     = 59 <<0, //重置成功
    SecretLetterType_RegisterVericationBingingSuccess     = 60 <<0, //绑定多信账号成功
    SecretLetterType_QRCodeLoginFeedBack     = 75 <<0, //扫码成功或失败
    
    //好友请求 群组请求
    SecretLetterType_Validate         = 2<<0, //验证消息,添加好友,申请入群等..
    SecretLetterType_System           = 3<<0, //系统消息 ,xxx退出群,xxx加入群等..
    SecretLetterType_FriendAddList     = 7<<0, //接收好友请求列表 【所有申请通知】
    SecretLetterType_FriendAddRequest     = 11<<0, //接收到好友请求列表 【某一条请求】
    SecretLetterType_FriendAddIgnoreSuccess     = 21<<0, //忽略好友请求【不拒绝也不同意】
    SecretLetterType_FriendAddAlreadyAgree     = 26<<0, //对方已同意你的好友请求
    SecretLetterType_FriendNotExist     = 27<<0, //您已不在对方好友列表
    SecretLetterType_FriendDeleteSuccess     = 28<<0, //您已不在对方好友列表
    SecretLetterType_FriendSearchResult     = 33<<0, //搜索好友
    SecretLetterType_FriendAddSendSuccess     = 34<<0, //发送好朋友请求成功
    SecretLetterType_SingleChatDetail     = 47<<0, //单聊详情
    SecretLetterType_PullBlack     = 48<<0, //单聊详情请求拉黑
    SecretLetterType_ReportIllegal     = 50<<0, //举报
    
    //好友列表
    SecretLetterType_FriendList           = 6<<0, //好友列表
    //群组列表
    SecretLetterType_GroupList           = 31<<0, //群组列表
    SecretLetterType_AllGroupList           = 74<<0, // 所有参与群聊的群组列表。                 **恢复数据**
    
    //接收到消息 聊天
    SecretLetterType_Normal           = 1<<0, //正常消息,文字,图片,语音,文件,撤回,提示语等..
    SecretLetterType_NormalReceipt           = 41<<0,
    SecretLetterType_ChatHistory           = 9<<0,//聊天历史消息 单聊
    SecretLetterType_ChatAllHistory           = 72<<0,//聊天 所有历史消息 单聊。              **恢复数据**
    SecretLetterType_getChatSessionList           = 10<<0,//获取会话列表
    SecretLetterType_notifyGetChatSessionList           = 12<<0,//收到新会话 通知获取会话列表
    SecretLetterType_notifyRefreshChatSessionList           = 15<<0,//收到新消息 需要刷新会话列表 只适应在会话列表界面收到消息有效
    SecretLetterType_ChatEntering           = 24<<0,//对方正在输入
    SecretLetterType_ChatEndEnter           = 25<<0,//对方结束输入
    SecretLetterType_ChatAlreadyRead           = 61<<0,//已读
    SecretLetterType_GroupSetPersonalInfo           = 62<<0,//群设置信息成功
    SecretLetterType_GroupQRCodeInviteSuccess           = 63<<0,//扫码进群成功 暂未用到】 用的SecretLetterType_groupCreateSuccess
    SecretLetterType_GroupQRCodeInviteFail           = 64<<0,//扫码进群失败
    SecretLetterType_GroupQRCodeAlreadyExist           = 65<<0,//扫码进群 已经在群里
    SecretLetterType_GroupQRCodeInviteSuccessNotificate           = 66<<0,//扫码进群成功通知群成员
    SecretLetterType_GroupForbidden           = 76<<0,//群开启禁言且不是管理员，无法发言 【发言的时候】
    
    SecretLetterType_notifyGetgroupDetail           = 14<<0,//群组详情
    
    //提示信息 比如申请通知...
    SecretLetterType_Promet           = 8<<0, //通知相关
    SecretLetterType_acceptFriendSuccess           = 29<<0, //接受好友成功
    
    //群组
    SecretLetterType_groupList           = 17<<0, //
//    SecretLetterType_groupCreate           = 16<<0, //
    SecretLetterType_groupCreateSuccess           = 18<<0, //建群成功
    SecretLetterType_ReceiveGroupMessage           = 19<<0,//收到群消息
    SecretLetterType_GroupDetail           = 20<<0,//群详情
    SecretLetterType_GroupAddMemberSuccess           = 22<<0,//添加成员成功
    SecretLetterType_GroupBreak           = 23<<0, //群解散
    SecretLetterType_GroupExit           = 24<<0, //个人退群
    SecretLetterType_GroupChatHistory           = 30<<0,//聊天历史消息 群聊
    SecretLetterType_GroupChatAllHistory           = 73<<0,//聊天 All所有历史消息 群聊。       **恢复数据**
    SecretLetterType_GroupSaveSuccess           = 46<<0,//群组保存成功
    SecretLetterType_GroupCreateRepeat           = 32<<0,//重复创建群组
    SecretLetterType_GroupMessageDrowSuccess           = 43<<0,//群组消息撤回成功
    SecretLetterType_GroupMessageDrowFailed           = 44<<0,//群组消息撤回失败
    SecretLetterType_GroupDropSuccess           = 67<<0,//群组踢人成功
    SecretLetterType_GroupMemberDrop           = 70<<0,//群组有人被踢
    SecretLetterType_GroupDetailChanged           = 69<<0,//群组信息改变
    SecretLetterType_GroupSetManageSucess           = 77<<0,//设置群管理成功
    SecretLetterType_GroupDelManageSucess           = 78<<0,//取消群管理成功
    SecretLetterType_GroupSetForbid           = 79<<0,//设置群禁言成功
    SecretLetterType_GroupDelForbid           = 80<<0,//取消群禁言成功
    
    
    
    SecretLetterType_jubao           = 81<<0,//举报
    
    SecretLetterType_yanzheng           = 82<<0,//进群需要验证
    SecretLetterType_yanzhengOver           = 83<<0,//进群验证 失效
    SecretLetterType_yanzhengReject           = 84<<0,//进群拒绝成功
    SecretLetterType_yanzhengAccept           = 85<<0,//进群同意成功
    SecretLetterType_zhuanrangSuccess           = 86<<0,//转让群主成功
    
    
    //红包
    
    
    SecretLetterType_checkAmount           = 87<<0,//查询我的余额
    SecretLetterType_setMypassword           = 88<<0,//设置支付密码
    SecretLetterType_rechargeSuccess          = 89<<0,//充值成功
    SecretLetterType_rechargeFail          = 89<<0,//充值失败
    SecretLetterType_checkAmountFail           = 90<<0,//查询我的余额
    SecretLetterType_setPasswordSuccess           = 91<<0,//设置支付密码成功
    SecretLetterType_setPasswordRepeat           = 92<<0,//已经设置过
    SecretLetterType_receiveRedpacket           = 93<<0,//收到红包消息 【群】
    SecretLetterType_passwordError           = 94<<0,//支付密码错误
    
    SecretLetterType_sendPacketSuccess         = 95<<0,//发送红包成功
    
    SecretLetterType_openPacketSuccess         = 96<<0,//拆红包成功返回。这里可以加一个参数 说明已经拆过红包
    
    SecretLetterType_lookPacket       = 97<<0,//已经拆过 跳转详情 //这里可以做成红包详情返回
    SecretLetterType_checkGet       = 98<<0,//支付 checkvalue获取
    SecretLetterType_receivePacket         = 99<<0,//收到红包消息
    SecretLetterType_packetCheck         = 100<<0,//红包详情 state 1可以抢 0强过了
    SecretLetterType_cashResult         = 101<<0,//提现返回
    SecretLetterType_cashRecord         = 102<<0,//零钱记录
//    SecretLetterType_accountDetail         = 103<<0,//余额查询
    
    SecretLetterType_tixianPwdCheck         = 104<<0,//提现支付检查
    SecretLetterType_mianmiPayCheck         = 105<<0,//免密支付
    
    SecretLetterType_sendRedFaill         = 106<<0,//红包发送失败 【服务器没查到红包消息】
    
    SecretLetterType_HuifuPasswordSeted         = 107<<0,//设置过了汇付支付密码
    SecretLetterType_HuifuPasswordNOSeted         = 108<<0,//设置过了汇付支付密码
    SecretLetterType_RedOverdue         = 109<<0,//红包过期 跳转到红包详情
    SecretLetterType_NoPasswordSendSuccess         = 110<<0,//免密授权 发送验证码返回
    SecretLetterType_NoPasswordSetSuccess         = 111<<0,//免密授权  设置成功
    SecretLetterType_RegisterVericationFail     = 112 <<0, //验证码发送失败
    SecretLetterType_checkPayCodeSuccess     = 113 <<0, // 修改支付密码 验证码错误
    SecretLetterType_NoPasswordCancelSuccess         = 114<<0,//免密授权  取消成功
    SecretLetterType_RedRecordList         = 115<<0,//红包记录 发出的
    SecretLetterType_RedRecordAcceptList         = 116<<0,//红包记录 收到的
    SecretLetterType_BankCardList         = 117<<0,//银行卡列表
    SecretLetterType_BankCardBindResult         = 118<<0,//银行卡绑定结果
    SecretLetterType_BankCardCutResult         = 119<<0,//银行卡解除绑定结果
    SecretLetterType_qianghongbaoFail         = 120<<0,//抢红包失败
    SecretLetterType_RobredPacketRecord         = 121<<0,//抢红包 推送 xxx抢了你的红包
    SecretLetterType_BillList         = 122<<0,//账单
    SecretLetterType_SingleChatRedPacket         = 123<<0,//单聊红包
    SecretLetterType_kaihuSuccess         = 124<<0,//开户成功
    SecretLetterType_SubAmountOpenSuccess         = 125<<0,//设置子账户成功
    SecretLetterType_OpenAmountSuccess         = 126<<0,//开户成功
    SecretLetterType_UserNotOpenHuiFu         = 127<<0,// 多信账户 没有开户汇付
    SecretLetterType_UserOpenHuiFued         = 128<<0,// 多信账户 已经开户汇付
    SecretLetterType_UserHuanBingSuccess         = 129<<0,// 手机号换绑成功
    SecretLetterType_PullBlackSuccess         = 130<<0,// 好友拉黑成功
    SecretLetterType_CancelPullBlackSuccess         = 131<<0,// 好友 解除拉黑成功
    SecretLetterType_friendBlackState         = 132<<0,// 好友 是否拉黑
    SecretLetterType_friendBlackList         = 133<<0,// 黑名单列表
    SecretLetterType_sendMessageFailBlack         = 134<<0,// faxiaoxi shibai zaiduifang 黑名单
    SecretLetterType_systemMessage         = 135<<0,// 系统通知
    SecretLetterType_collectPicture         = 136<<0,// 收藏的表情返回
    SecretLetterType_ValidateManager         = 137<<0,// 管理员收到进群申请
    SecretLetterType_GroupNoticeMessage         = 138<<0,// 群系统通知
    SecretLetterType_GroupAllMemberId         = 139<<0,// 所有群成员id请求
    SecretLetterType_GrouppartMemberDetail         = 140<<0,// 群成员详情 数组 请求
    SecretLetterType_HelperMessageList         = 141<<0,// 小助手消息列表
    SecretLetterType_logoffSuccess         = 142<<0,// 注销多信成功
    SecretLetterType_receiveNewDynamicOrNewcomment         = 143<<0,// 多信收到 有朋友发布新动态 或者有新的评论
    SecretLetterType_receiveDynamicCommentList         = 144<<0,// 多信 朋友圈评论列表
    SecretLetterType_receiveDynamicCount         = 145<<0,// 多信 朋友圈提醒角标
    
    SecretLetterType_chagemoneySendcode         = 146<<0,// 充值发送短信
    SecretLetterType_chagemoneyCheckcode         = 147<<0,// 充值验证短信
    SecretLetterType_CheckPasswordSuccess         = 148<<0,// 修改支付密码 验证成功
    SecretLetterType_CheckPasswordFail         = 149<<0,// 修改支付密码 验证失败
    SecretLetterType_cardNotExist         = 150<<0,// 提现结果 银行卡不存在
    SecretLetterType_tixianFail         = 151<<0,// 提现结果 提现失败
    SecretLetterType_tixianShenhezhong         = 152<<0,// 提现结果 提现审核中
    SecretLetterType_repeatAddCardTip         = 153<<0,// 重复添加银行卡 提示
    SecretLetterType_receiveBackMessage         = 154<<0,// 收到撤回消息
    
    
    
    
    
    
    
    
    
    
    
    
    //个人信息
    SecretLetterType_PersonalInfoSet           = 35<<0,//个人信息设置
    SecretLetterType_PersonalInfoDetail           = 51<<0,//个人信息详情
    //动态相关
    SecretLetterType_DynamicSuccess           = 36<<0, //成功
    SecretLetterType_DynamicFail           = 42<<0, //失败
    SecretLetterType_DynamicList           = 37<<0, //动态列表
    SecretLetterType_DynamicDianzan           = 38<<0, //动态点赞
    SecretLetterType_DynamicReturnDict           = 39<<0, //动态返回字典 【发布动态成功、】
    SecretLetterType_DynamicCommentList           = 40<<0, //动态评论列表
    SecretLetterType_DynamicDetail           = 45<<0, //获取动态详情成功
    SecretLetterType_SocketRequestFailed           = 53<<0, //请求失败 【服务器未链接】
    SecretLetterType_Unknow    = 999<<0   // 未知消息类型 用  55
    
}SecretLetterModel;










//typedef NS_ENUM(NSInteger){
//    //登陆
//    ChatMessageType_Login            = 0<<0,
//    ChatMessageType_LoginReceipt     = 5<<0, //登录回执
//    //好友请求 群组请求
//    ChatMessageType_Validate         = 2<<0, //验证消息,添加好友,申请入群等..
//    ChatMessageType_System           = 3<<0, //系统消息 ,xxx退出群,xxx加入群等..
//    
//    //接收到消息 聊天
//    ChatMessageType_Normal           = 1<<0, //正常消息,文字,图片,语音,文件,撤回,提示语等..
//    
//    ChatMessageType_NormalReceipt    = 4<<0, //发送消息回执
//    ChatMessageType_InvalidReceipt   = 6<<0, //消息发送失败回执
//    ChatMessageType_RepealReceipt    = 7<<0, //撤回消息回执
//    ChatMessageType_ContantList    = 8<<0, //撤回消息回执
//    
//    ChatMessageContentType_Unknow    = 20<<0   // 未知消息类型
//    
//}ChatMessageTyp;


typedef NS_ENUM(NSInteger){
    
    ChatMessageContentType_Text       = 0<<0, //普通文本消息,表情..
    ChatMessageContentType_Audio      = 1<<0, //语音消息
    ChatMessageContentType_Picture    = 2<<0, //图片消息
    ChatMessageContentType_Video      = 3<<0, //视频消息
    ChatMessageContentType_File       = 4<<0, //文件消息
    ChatMessageContentType_Repeal     = 5<<0, //撤回消息
    ChatMessageContentType_Tip        = 6<<0,  //提示消息,例如: 你俩还不是好友,需要验证.. 以上为打招呼内容.. xxx退出群 , 加入群...
    
}ChatMessageContentType;


typedef NS_ENUM(NSInteger){
    
    ChatMessageTypeMark_Login            = 0<<0,
    ChatMessageTypeMark_Normal           = 1<<0, //正常消息,文字,图片,语音,文件,撤回,提示语等..
    ChatMessageTypeMark_Validate         = 2<<0, //验证消息,添加好友,申请入群等..
    ChatMessageTypeMark_System           = 3<<0, //系统消息 ,xxx退出群,xxx加入群等..
    ChatMessageTypeMark_NormalReceipt    = 4<<0, //发送消息回执
    ChatMessageTypeMark_LoginReceipt     = 5<<0, //登录回执
    ChatMessageTypeMark_InvalidReceipt   = 6<<0, //消息发送失败回执
    ChatMessageTypeMark_RepealReceipt    = 7<<0, //撤回消息回执
    ChatMessageContentTypeMark_Unknow    = 8<<0   // 未知消息类型
    
}ChatMessageMarkType;

@class ChatContentModel;

@interface ChatModel : NSObject

@property (nonatomic, copy) NSString *groupID; //群ID

@property (nonatomic, copy) NSString *fromUserID; //消息发送者ID

@property (nonatomic, copy) NSString *toUserID;  //对方ID

@property (nonatomic, copy) NSString *fromPortrait; //发送者头像url

@property (nonatomic, copy) NSString *toPortrait; //对方头像url

@property (nonatomic, copy) NSString *nickName; //我对好友命名的昵称

@property (nonatomic, copy) NSArray<NSString *> *atToUserIDs; // @目标ID

@property (nonatomic, copy) NSString *messageType; //消息类型

@property (nonatomic, copy) NSString *contenType; //内容类型

@property (nonatomic, copy) NSString *chatType;  //聊天类型 , 群聊,单聊

@property (nonatomic, copy) NSString *deviceType; //设备类型

@property (nonatomic, copy) NSString *versionCode; //TCP版本码

@property (nonatomic, copy) NSString *messageID; //消息ID

@property (nonatomic, strong) NSNumber *byMyself; //消息是否为本人所发

@property (nonatomic, copy) NSNumber *isSend;  //是否已经发送成功

@property (nonatomic, strong) NSNumber *isRead; //是否已读

@property (nonatomic, copy) NSString *sendTime; //时间戳

@property (nonatomic, copy) NSString *beatID; //心跳标识

@property (nonatomic, copy) NSString *groupName; //群名称

@property (nonatomic, strong) NSNumber *noDisturb; //免打扰状态  , 1为正常接收  , 2为免打扰状态 , 3为屏蔽状态

@property (nonatomic, strong) ChatContentModel *content; //内容

@property (nonatomic, strong) NSNumber *isSending; //是否正在发送中

@property (nonatomic, strong) NSNumber *progress; //进度

#pragma mark - chatlist独有部分
@property (nonatomic, strong) NSNumber *unreadCount; //未读数
@property (nonatomic, copy) NSString *lastMessage; //最后一条消息
@property (nonatomic, copy) NSString *lastTimeString; //最后一条消息时间



#pragma mark - 额外需要部分属性
@property (nonatomic , assign) CGFloat messageHeight; //消息高度
@property (nonatomic, assign,getter=shouldShowTime) BOOL showTime; // 是否展示时间

@end


@interface ChatContentModel :NSObject



@property (nonatomic, copy) NSString *text; //文本

@property (nonatomic, assign) CGSize picSize; //图片尺寸

@property (nonatomic, strong) NSString *seconds; //时长

@property (nonatomic, copy) NSString *fileName; //文件名

@property (nonatomic, strong) NSNumber *videoDuration; //语音时长

@property (nonatomic, copy) NSString *videoSize;  //视频大小

@property (nonatomic, copy) NSString *bigPicAdress; //图片大图地址

@property (nonatomic, strong) NSString *fileSize; //文件大小

@property (nonatomic, copy) NSString *fileType; //文件类型

@property (nonatomic, copy) NSString *fileIconAdress; //文件缩略图地址

@end


