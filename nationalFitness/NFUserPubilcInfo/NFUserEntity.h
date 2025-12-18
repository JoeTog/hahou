//
//  NFUserEntity.h
//  SummaryHoperun
//
//  Created by 程long on 14-7-30.
//  Copyright (c) 2014年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NFMineEntity.h"
#import "CLLocation+WGS_GCJ.h"
#import "NewHomeEntity.h"
//#import <CoreLocation/CoreLocation.h>
//#import "convert.h"

//#ifdef __OBJC__
//
//#endif

/**
 *  用户在登陆首页选择的操作类型
 */
typedef NS_ENUM(NSInteger, OPERATION_TYOE)
{
    OT_LoginDefault,
    /**
     *  用户名密码登陆
     */
    OT_LoginUseName,
    /**
     *  QQ登陆
     */
    OT_LoginUseQQ,
    /**
     *  新浪微博登陆
     */
    OT_LoginUseWB,
    /**
     *  人人网登陆
     */
    OT_LoginUseRR,
    /**
     *  微信登陆
     */
    OT_LoginUseWX,
    /**
     *  智能门户登陆
     */
    OT_LoginUseMyNj,
    /**
     *  找回密码操作
     */
    OT_FindPassword,
    /**
     *  注册用户操作
     */
    OT_RegsterUser,
    /*
     活动报名
     */
    OT_EnterFor
    
};

typedef NS_ENUM(NSInteger, NFUserPermission) {
    NFUserGeneral    =    0,    //普通用户
    NFUserVolunteer,            //志愿者
    NFUserMyNJ,                 //智能门户用户
    NFUserClub,                 //普通用户（代表商团)
    NFUserQQ,                   //QQ
    NFUserRR,                   //人人
    NFUserWX,                   //微信
    NFUserXL                    //新浪微博
};

/**
 *  用户性别
 */
typedef NS_ENUM(NSInteger, NFSex) {
    
    /**
     *  0 未知
     */
    NFUnknow = 0,
    /**
     *  1 男
     */
    NFMan,
    /**
     *  女
     */
    NFWoman
};

/**
 *  活动属性代码 1：个人活动 2：场馆；3：俱乐部；4：商家（卖产品）；5：官方
 */

typedef NS_ENUM(NSInteger, AttCode) {
    //个人活动
    AttCodePersonal = 1,
    //场馆
    AttCodeVenues = 2,
    //俱乐部
    AttCodeClub = 3,
    //商家
    AttCodeSeller = 4,
    //官方
    AttCodeOfficial = 5,
};

//创建活动的身份
typedef NS_ENUM(NSUInteger, CreatUserType) {
    //个人
    CreatUserTypeSelf,
    //场地
    CreatUserTypeSpace,
    //社团
    CreatUserTypeClub,
    //公共主页
    CreatUserTypePublic
};

//活动类型
typedef NS_ENUM(NSUInteger, CreatActType) {
    //基础类型活动
    CreatActTypePublic,
    //培训课程
    CreatActTypeTrain,
    //走跑活动
    CreatActTypeRun,
    //赛事售票
    CreatActTypeEvent
};

/**
 *  相册或者活动所属类型
 */
typedef NS_ENUM(NSInteger,SuperTheirType) {
    /**
     *  热点
     */
    SuperTheirTypeHot = 0,
    /**
     *  活动
     */
    SuperTheirTypeActivity = 1,
    /**
     *  场馆
     */
    SuperTheirTypeVenues = 2,
    /**
     *  俱乐部
     */
    SuperTheirTypeClub = 3,
    /**
     *  个人
     */
    SuperTheirTypeSelf = 4,
    /**
     *  动态界面
     */
    SuperTheirTypeDynamic = 5,
    
    /**
     教练
     */
    SuperTheirTypeCoach = 6,
    
    /*
     常州培训相册
     */
    SuperTheirTypePX = 7,
    
    /*
     *举报
     */
    
    SuperTheirTypeReport = 9,
    /**
     *  瀑布流相册
     */
    SuperTheirTypeAlbum = 1000,
    /**
     *  健身设备
     */
    SuperTheirTypeHealth = 10,
    /**
     *  赛事
     */
    SuperTheirTypeSaiShi = 17,
    /**
     *  培训
     */
    SuperTheirTypePeiXun = 18
};


@interface NFUserEntity : NSObject<NSLayoutManagerDelegate,CLLocationManagerDelegate>

//@interface NFUserEntity : NSObject<NSLayoutManagerDelegate>
/*!
 @property
 @abstract      用户登录状态
 
 */
@property (nonatomic, assign)   BOOL userIsConncected;

/*!
 @property
 @abstract      用户唯一id
 
 */
@property (nonatomic, strong)   NSString *userId;

/*!
 @property
 @abstract      clientId 暂时设置成user cust id
 
 */
@property (nonatomic, strong)   NSString *clientId;


//这是 是否设置了提现密码
//
@property(nonatomic,assign)BOOL isTiXianPassWord;


//这是 是否授权m了免密支付
//
@property(nonatomic,assign)BOOL isShouquanCancelPwd;
#pragma mark - 密聊单例
/*!
 @property
 @abstract      是否有 申请与通知
 
 */
@property (nonatomic, assign)   BOOL IsApplyAndNotify;

/*!
 @property
 @abstract      当前聊天对象id 没有聊天对象就是nil 现在取的 username 因为username也是唯一的
 
 */
@property (nonatomic, strong)   NSString *currentChatId;

/*!
 @property
 @abstract      是否为单聊 0没有正在聊天 1单聊 2群聊
 
 */
@property (nonatomic, strong)   NSString *isSingleChat;

/*!
 @property
 @abstract      记录聊天界面
 
 */
@property (nonatomic, strong)   UIViewController *currentController;


/*!
 @property
 @abstract      阅后隐藏
 
 */
@property (nonatomic, assign)   NSInteger yuehouYincang;

/*!
 @property
 @abstract      关机清空
 
 */
@property (nonatomic, assign)   NSInteger guanjiQingkong;

//#warning IsReallyDelete
//是否关机清空 默认为yes
@property (nonatomic, assign)   BOOL isGuanjiClear;


/*!
 @property
 @abstract      会话列表badge角标设置
 
 */
@property (nonatomic, assign)   NSInteger badgeCount;

/*!
 @property
 @abstract      联系人badge角标设置
 
 */
@property (nonatomic, assign)   NSInteger contactBadgeCount;


/*!
 @property
 @abstract      朋友圈badge角标设置
 
 */
@property (nonatomic, assign)   NSInteger dynamicBadgeCount;

/*!
 @property
 @abstract      超时计算开始
 
 */
@property (nonatomic, assign)   BOOL timeOutCountBegin;

/*!
 @property
 @abstract      背景设置
 
 */
@property (nonatomic, strong)   NSString *backgroundImage;

/*!
 @property
 @abstract      记录背景index
 
 */
@property (nonatomic, assign)   NSInteger backgroundIndex;

//CacheKeepBoxEntity
/*!
 @property
 @abstract      记录缓存设置在全局里面
 
 */
@property (nonatomic, strong) CacheKeepBoxEntity *KeepBoxEntity;

//CacheKeepBoxEntity
/*!
 @property
 @abstract      个人头像
 
 */
@property (nonatomic, strong) NSString *mineHeadView;

@property (nonatomic, strong) UIImage *mineHeadViewImage;

@property (nonatomic, strong) NSString *HeadPicpathAppendingString;


//
/*!
 @property
 @abstract      是否刷新好友列表
 
 */
@property (nonatomic)   BOOL    isNeedRefreshFriendList;

/*!
 @property
 @abstract      是否刷新会话列表
 
 */
@property (nonatomic)   BOOL    isNeedRefreshChatList;

/*!
 @property
 @abstract      是否只是刷新本地会话列表
 
 */
@property (nonatomic)   BOOL    isNeedRefreshLocalChatList;

/*!
 @property
 @abstract      是否刷新会话列表 单聊群聊通用
 
 */
@property (nonatomic)   BOOL    isNeedRefreshChatData;

/*!
 @property
 @abstract      是否请求单聊历史
 
 */
@property (nonatomic)   BOOL    isNeedRefreshSingleChatHistory;

/*!
 @property
 @abstract      是否请求群聊历史
 
 */
@property (nonatomic)   BOOL    isNeedRefreshGroupChatHistory;

/*!
 @property
 @abstract      选择的主题
 
 */
@property (nonatomic)   NSInteger    selectedTheme;

/*!
 @property
 @abstract      3d touch 进去扫一扫 【nil、0、1】
 程序第一次运行时为nil然后立马赋值为0【在主页里面】这时候表明程序在后台运行了，
 当点击了3d touch后 
 判断是否为0，为0则取当前显示的controller 跳转后设置为0
 如果为nil 立马设置为1 在主页面进行跳转 跳转后设置为0
 //当在主页时
 为1 表示为3dtouch点击跳转到扫描二维码
 为2 表示跳转到单聊
 为3 表示跳转到群聊
 为4 表示跳转到申请详情
 */
@property (nonatomic, strong)   NSString    *PushQRCode;

/*!
 @property
 @abstract      好友添加详情
 
 */
@property (nonatomic, strong)   FriendAddListEntity    *friendAddDetailEntity;

/*!
 @property
 @abstract      我的二维码图片
 
 */
@property (nonatomic, strong)   UIImage    *MineQRCodeImage;


/*!
 @property
 @abstract      是否需要测试弹窗
 
 */
@property (nonatomic)   BOOL    IsNotNeedTestView;

/*!
 @property
 @abstract      是否在上传图片
 
 */
@property (nonatomic)   BOOL    IsUploadingPicture;


#pragma mark - 动态相关
/*!
 @property
 @abstract      是否请求最新动态
 
 */
@property (nonatomic)   BOOL    IsRequestNearestDynamic;


/*!
 @property
 @abstract      是否需要删除 didselected 跳转过去的动态 用完需要置空
 
 */
@property (nonatomic)   BOOL    isNeedDeleteDidselectedPush;


/*!
 @property
 @abstract      是否显示隐藏消息
 
 */
@property (nonatomic)   BOOL    showHidenMessage;

/*!
 @property
 @abstract      是否需要提示音
 
 */
@property (nonatomic)   BOOL    showPrompt;

/*!
 @property
 @abstract      转发的图片
 
 */
@property (nonatomic, strong) UIImage *forwardImage;

/*!
 @property
 @abstract      app状态 处于前台 处于后台 【针对短线重连】 yes前台 no后台
 
 */
@property (nonatomic) BOOL appStatus;



/*!
 @property
 @abstract      是否需要刷新 好友申请列表
 
 */
@property (nonatomic) BOOL IsNeedRefreshApply;

//推送相关

/*!
 @property
 @abstract      推送类型
 
 */
@property (nonatomic, strong)   NSString    *pushType;

/*!
 @property
 @abstract      推送id 【收到推送 谁给我发送的消息】
 
 */
@property (nonatomic, strong)   NSString    *pushId;

/*!
 @property
 @abstract      极光推送注册id
 
 */
@property (nonatomic, strong)   NSString    *JPushId;

/*!
 @property
 @abstract      是否手动设置关闭推送
 
 */
@property (nonatomic) BOOL IsCloseJPush;

/*!
 @property
 @abstract      服务器是否断过
 
 */
@property (nonatomic) BOOL ServerIsClosed;

/*!
 @property
 @abstract      服务器连接状态 1断开 2接受中  用户登录状态：userIsConncected
 
 */
@property (nonatomic, strong)   NSString    *connectStatus;

/*!
 @property
 @abstract      微信头像
 
 */
@property (nonatomic, strong)   NSString    *WXHeadPicpath;

/*!
 @property
 @abstract      微信昵称
 
 */
@property (nonatomic, strong)   NSString    *WXNickName;


/*!
 @property
 @abstract      是否绑定了账号 1为绑定 0为未绑定【微信登录需要用到】
 
 */
@property (nonatomic) BOOL isBang;

/*!
 @property
 @abstract      网路IP
 
 */
@property (nonatomic, strong)   NSString    *netIP;

/*!
 @property
 @abstract      重连延迟时间 当第一次重连 速度要很快
 
 */
@property (nonatomic, assign)   CGFloat    reconnectTimeInterval;

/*!
 @property
 @abstract      是否正在恢复数据
 
 */
@property (nonatomic) BOOL IsRecovering;

/*!
 @property
 @abstract      扫码后是否自动返回
 
 */
@property (nonatomic) BOOL IsAutoBack;




#pragma mark - end





























/*!
 @property
 @abstract      用户唯一慧动id 用于持久取名称用到 作为userid
 
 */
@property (nonatomic, strong)   NSString *hdnumber;

/*!
 @property
 @abstract       缓存通讯录联系人
 
 */
@property (nonatomic, strong)   NSString *contantList;

/*!
 @property
 @abstract       缓存聊天记录 作为url 传入
 
 */
@property (nonatomic, strong)   NSString *contantData;

/*!
 @property
 @abstract      用户手机号
 
 */
@property (nonatomic, strong)   NSString *mobile;



/*!
 @property
 @abstract      单点登录需使用的token
 
 */
@property (nonatomic, strong)   NSString *accessToken;

/*!
 @property
 @abstract      健康状态 健康状态 1:超重  2:偏瘦 3:正常 4:完美
 
 */
@property (nonatomic, strong)   NSString *healthStatus;

/*!
 @property
 @abstract      邀请码
 
 */
@property (nonatomic, strong)   NSString *inviteCode;

/*!
 @property
 @abstract      登录名
 
 */
@property (nonatomic, strong)   NSString *loginName;

/*!
 @property
 @abstract      userName
 
 */
@property (nonatomic, strong)   NSString *userName;

/*!
 @property
 @abstract      密码
 
 */
@property (nonatomic, strong)   NSString *password;



/*!
 @property
 @abstract      用户类型
 
 */
@property (nonatomic, assign)   NFUserPermission    userType;


/*!
 @property
 @abstract      个人 性别  性别：1-男人、2-女人
 
 */
@property (nonatomic, assign)   NFSex    sex;


/*!
 @property
 @abstract      爱好 hobby
 
 */
@property (nonatomic, strong)   NSString    *hobby;

/*!
 @property
 @abstract      个人签名 signaTure
 
 */
@property (nonatomic, strong)   NSString    *signaTure;

/*!
 @property
 @abstract      最新动态 newDynamic
 
 */
@property (nonatomic, strong)   NSString    *dynamicNew;

/*!
 @property
 @abstract      地区 currentArea
 
 */
@property (nonatomic, strong)   NSString    *currentArea;

/*!
 @property
 @abstract      生日 birthDay 出生日期，例如 1975-01-01
 
 */
@property (nonatomic, strong)   NSString    *birthDay;

/*!
 @property
 @abstract      用户权限  0：普通用户  报修 ， 其它  管理员用户  安装
 
 */
@property (nonatomic, strong)   NSString    *roleType;

/*!
 @property
 @abstract      用户头像 bigpicpath
 
 */
@property (nonatomic, strong)   NSString    *bigpicpath;

/*!
 @property
 @abstract      用户头像 smallpicpath
 
 */
@property (nonatomic, strong)   NSString    *smallpicpath;

/*!
 @property
 @abstract      二维码图片字符串 matrixPicUrl
 
 */
@property (nonatomic, strong)   NSString    *matrixPicUrl;

/*!
 @property
 @abstract      群二维码图片字符串 groupMatrixPicUrl
 
 */
@property (nonatomic, strong)   NSString    *groupMatrixPicUrl;

/*!
 @property
 @abstract      小二维码图片地址 matrixPicUrl
 
 */
@property (nonatomic, strong)   NSString    *smallMatrixPicUrl;

/*!
 @property
 @abstract      用户经度 userLongitude
 
 */
@property (nonatomic, assign)   CGFloat    userLongitude;

/*!
 @property
 @abstract      用户纬度 userLatitude
 
 */
@property (nonatomic, assign)   CGFloat    userLatitude;

/*!
 @property
 @abstract      用户当前所在位置 currentLoName
 
 */
@property (nonatomic, strong)   NSString    *currentLoName;

/*!
 @property
 @abstract      查看数据的 － 户籍市 cityName
 
 */
@property (nonatomic, strong)   NSString    *cityName;

/*!
 @property
 @abstract      查看数据的 － 户籍市 cityCode
 
 */
@property (nonatomic, strong)   NSString    *cityCode;

/*!
 @property
 @abstract      用户所在 － 户籍市 cityName
 
 */
@property (nonatomic, strong)   NSString    *currentCityName;

/*!
 @property
 @abstract      用户所在 － 户籍市 cityCode
 
 */
@property (nonatomic, strong)   NSString    *currentCityCode;

/*!
 @property
 @abstract      用户切换的组织code
 
 */
@property (nonatomic, strong)   NSString    *orgCode;

/*!
 @property
 @abstract      用户切换的组织名称
 
 */
@property (nonatomic, strong)   NSString    *orgName;


/*!
 @property
 @abstract      用户切换的系统code
 
 */
@property (nonatomic, strong)   NSString    *sysCode;

/*!
 @property
 @abstract      用户切换的系统名称
 
 */
@property (nonatomic, strong)   NSString    *sysName;


/*!
 @property
 @abstract      身份证号 idNumber
 
 */
@property (nonatomic, strong)   NSString    *idNumber;

/*!
 @property
 @abstract      电话号码 phoneNum
 
 */
@property (nonatomic, strong)   NSString    *phoneNum;

/*!
 @property
 @abstract      昵称 nickName
 
 */
@property (nonatomic, strong)   NSString    *nickName;

/*!
 @property
 @abstract      个性签名 nickName
 
 */
@property (nonatomic, strong)   NSString    *signText;

/*!
 @property
 @abstract      备注 remark
 
 */
@property (nonatomic, strong)   NSString    *remark;

/*!
 @property
 @abstract      用户真实姓名
 
 */
@property (nonatomic, strong)   NSString    *realName;

/*!
 @property
 @abstract      户籍省 proName
 
 */
@property (nonatomic, strong)   NSString    *proName;

/*!
 @property
 @abstract      慧动号修改次数
 
 */
@property (nonatomic)   NSInteger    nickNameChanged;

/*!
 @property
 @abstract      用户类型 是否是爱趴直接登录用户
 
 */
@property (nonatomic)   BOOL    isUserMynj;

/*!
 @property
 @abstract      用户操作类型， 是找回密码还是注册用户判断
 
 */
@property (assign, nonatomic) OPERATION_TYOE orepationType;

/*!
 @property
 @abstract      用户的身高  身高，cm，格式176
 
 */
@property (nonatomic, strong)NSString      *userHeight;

/*!
 @property
 @abstract      用户的体重  体重,kg,格式8
 
 */
@property (nonatomic, strong) NSString      *userWeight;

/*!
 @property
 @abstract      用户导航
 
 */
@property (nonatomic, strong) CLLocationManager *locationManager;

//年龄
@property (nonatomic, strong) NSString      *userAge;

//星座
@property (nonatomic, strong) NSString      *conStell;

//性取向
@property (nonatomic, strong) NSString      *sexUality;

//广告的title
@property (nonatomic, strong) NSString      *alertTitleStr;

//广告的标题
@property (nonatomic, strong) NSString      *alertHtmlStr;

//是否刷新首页
@property (nonatomic, assign) BOOL reloadHomePage;

//是否刷新排名
@property (nonatomic, assign) BOOL reloadHomeRange;

//体型描述
@property (nonatomic, strong) NSString * shapeType;

//BMI指数
@property (nonatomic, strong) NSString * BMI;

//体重浮动数（预留）
@property (nonatomic, strong) NSString * weightFloat;

//积分商城地址
@property (nonatomic, strong) NSString * integralUrl;

//体重升降(预留字段) 0:升；1：降
@property (nonatomic, strong) NSString * weightUpDown;

//首页top背景图地址
@property (nonatomic, strong) NSString * backGroundPicPath;

//服务器下发的服务器地址
@property (nonatomic, strong) NSString *urlStr;

/*!
 @property
 @abstract      倒计时时间
 
 */
@property (nonatomic)   int    leftTime;

/*!
 @property
 @abstract      假数据判断字段
 
 */
@property (nonatomic, assign) BOOL isPicImageDynamic;


+ (instancetype)shareInstance;

//改变定位的精准度和代理对象
- (void)changeUserDistanceFilter:(CGFloat)distanceFilter andDelagate:(id)delagate;

//清空当前用户数据
- (void)clearUserData;

@end
