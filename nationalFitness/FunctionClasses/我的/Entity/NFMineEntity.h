//
//  NFMineEntity.h
//  nationalFitness
//
//  Created by 程long on 14-12-11.
//  Copyright (c) 2014年 chenglong. All rights reserved.
//
//http://47.98.105.33:7999/web_file/Public/uploads/


@interface NFMineEntity : NSObject

@end

//我的
@interface NFMineInfoEntity : NSObject
//
@property (nonatomic, strong) NSString *userType;
//
@property (nonatomic, strong) NSString *leaguerNum;
//
@property (nonatomic, strong) NSString *leaguerRank;
//
@property (nonatomic, strong) NSString *leaguerPicPath;
//
@property (nonatomic, strong) NSString *leaguerTitle;
//
@property (nonatomic, strong) NSString *shoppingCartNum;
//
@property (nonatomic, strong) NSString *toBePaymentNum;
//
@property (nonatomic, strong) NSString *toBeShippedNum;
//
@property (nonatomic, strong) NSString *toBeReceiptNum;
//
@property (nonatomic, strong) NSString *toBeEvaluateNum;
//
@property (nonatomic, strong) NSString *cardPackageNum;
//
@property (nonatomic, strong) NSString *couponNum;


@end

//会员中心
@interface memberCenterEntity : NSObject
//会员等级（LV.2数字部分）
@property (nonatomic, strong) NSString *leaguerRank;
//会员等级对应的名称（普通会员）
@property (nonatomic, strong) NSString *leaguerTitle;

//会员总成长值
@property (nonatomic, strong) NSString *growthValue;
//当前等级成长值
@property (nonatomic, strong) NSString *currentValue;
//升级还需要等成长值
@property (nonatomic, strong) NSString *upValue;
//用户当前积分
@property (nonatomic, strong) NSString *userIntegral;
//等级规则查看的HTML地址
@property (nonatomic, strong) NSString *ruleHtmlPath;
//用户特权LIST
@property (nonatomic, strong) NSString *privilegeList;

//特权图片
@property (nonatomic, strong) NSString *privilegePicPath;
//特权描述文字
@property (nonatomic, strong) NSString *privilegeTitle;





@end


@interface MineCardEntity : NSObject
//会员卡Id
@property (nonatomic, strong) NSString *cardId;
//会员卡图片地址
@property (nonatomic, strong) NSString *picPath;
//会员卡类型 0.储值卡（一卡通，健身卡等） 1.时限卡（年卡，月卡，季卡等） 3.次卡
@property (nonatomic, strong) NSString *cardType;
//会员卡名称
@property (nonatomic, strong) NSString *cardName;
//余额
@property (nonatomic, strong) NSString *balance;
//购买日期
@property (nonatomic, strong) NSString *purchaseDate;
//到期日期
@property (nonatomic, strong) NSString *ClosingDate;


@end

@interface MineConponEntity : NSObject
//优惠券Id
@property (nonatomic, strong) NSString *couponId;
//优惠劵类型 0：封顶 1：满减
@property (nonatomic, strong) NSString *couponType;
//优惠券名称
@property (nonatomic, strong) NSString *couponName;
//使用规则
@property (nonatomic, strong) NSString *useRule;
//截止日期
@property (nonatomic, strong) NSString *closingDate;
//优惠劵消费满多少才能用
@property (nonatomic, strong) NSString *couponMinMoney;
//优惠劵优惠的金额
@property (nonatomic, strong) NSString *couponCutMoney;
//优惠劵图标
@property (nonatomic, strong) NSString *couponPicPath;

@end

@interface MineAddressEntity : NSObject
//地址编号
@property (nonatomic, strong) NSString *addressId;
//收货姓名
@property (nonatomic, strong) NSString *userName;
//电话号码
@property (nonatomic, strong) NSString *phoneNumber;
//地址明细
@property (nonatomic, strong) NSString *addressDetail;
//是否默认 0：是 1：否
@property (nonatomic, strong) NSString *isDefault;

//addAddress 添加收货地址
//类型 0：添加 1：编辑
@property (nonatomic, strong) NSString *type;
//省CODE
@property (nonatomic, strong) NSString *proCode;
//市CODE
@property (nonatomic, strong) NSString *cityCode;
//区CODE
@property (nonatomic, strong) NSString *distCode;
//街道CODE
@property (nonatomic, strong) NSString *townCode;
//省市区详细地址，编辑不传
@property (nonatomic, strong) NSString *cityName;
//街道详细地址，编辑不传
@property (nonatomic, strong) NSString *townName;

@end

#pragma mark - 设置
//消息通知
@interface NewMessageNotifyEntity : NSObject
//设置id
@property (nonatomic, strong) NSString *setId;
//接收新消息通知
@property (nonatomic, assign) BOOL receiveNewMessageNotify;
//声音
@property (nonatomic, assign) BOOL soundNotify;
//震动
@property (nonatomic, assign) BOOL ShakeNotify;
//铃声名字
@property (nonatomic, strong) NSString *voiceName;



@end

//隐私设置
@interface PrivacySetEntity : NSObject
//设置id
@property (nonatomic, strong) NSString *setId;
//加我为朋友时候需要验证
@property (nonatomic, assign) BOOL needVerificate;
//想我推荐通讯录好友
@property (nonatomic, assign) BOOL recommendMailList;


@end



#pragma mark - 主题实体
@interface ThemeSetEntity : NSObject

//图片
@property (nonatomic, strong) NSString *picPath;

//标题名字
@property (nonatomic, strong) NSString *themeTitle;
//版本号
@property (nonatomic, strong) NSString *version;
//是否应用
@property (nonatomic, assign) BOOL IsUse;



@end

#pragma mark - 缓存实体
@interface CacheKeepBoxEntity : NSObject

//唯一id
@property (nonatomic, strong) NSString *keepBoxId;

//主题选中index 0 科技黑 1常规白
@property (nonatomic, assign) NSInteger themeSelectedIndex;

//主题图片
@property (nonatomic, assign) NSString *themeSelectedImageName;

//主题sectionheader颜色
@property (nonatomic, copy) UIColor *themeSectionHeaderColor;

//主题字体颜色
@property (nonatomic, copy) UIColor *themeMainTextColor;



@end


#pragma mark - 个人信息详情
@interface PersonalInfoDetailEntity : NSObject


//用户头像
@property (nonatomic, strong) NSString *userHeadPicPath;

//用户id
@property (nonatomic, strong) NSString *userId;

//用户名
@property (nonatomic, strong) NSString *userName;

//昵称
@property (nonatomic, strong) NSString *nick_name;

//性别
@property (nonatomic, strong) NSString *sex;

//地区
@property (nonatomic, strong) NSString *area;

//个性签名
@property (nonatomic, strong) NSString *sign;


// 0没有绑定多信 1绑定了多信  YES绑定了
@property (nonatomic) BOOL isBang;



@property (nonatomic) BOOL isSetPwd;



@end


