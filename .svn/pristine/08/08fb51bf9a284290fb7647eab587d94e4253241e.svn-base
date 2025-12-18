//
//  NFBaseEntity.h
//  nationalFitness
//
//  Created by 程long on 14-11-8.
//  Copyright (c) 2014年 chenglong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NFBaseEntity : NSObject

@end


/**
 *  相册实体 - 通用
 */
@interface albumListEntity : NSObject
//相册来源类型
@property (nonatomic, strong) NSString *albuType;
//相册编号
@property (nonatomic, strong) NSString *albumId;
//大图地址
@property (nonatomic, strong) NSString *bigpicPath;
//点赞数
@property (nonatomic, strong) NSString *chanNum;
//评论数
@property (nonatomic, strong) NSString *commNum;
@property (nonatomic, strong) NSString *createDate;
@property (nonatomic, strong) NSString *createUser;
@property (nonatomic, strong) NSString *delFlag;
//发表时描述
@property (nonatomic, strong) NSString *descript;
@property (nonatomic, strong) NSString *fkId;
//想法
@property (nonatomic, strong) NSString *idea;
//关键字
@property (nonatomic, strong) NSString *keyWord;
//昵称
@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, assign) NSInteger sex;
//smallpicPath
@property (nonatomic, strong) NSString *smallpicPath;
@property (nonatomic, strong) NSString *updateUser;
//用户小头像
@property (nonatomic, strong) NSString *usersmallPath;
//高度
@property (nonatomic, assign) CGFloat height;
//宽度
@property (nonatomic, assign) CGFloat width;
//是否点赞 0：点赞 1：未点赞
@property (nonatomic, assign) NSInteger praFlag;
//年龄
@property (nonatomic, strong) NSString *age;
//推送状态 0:未推送 1:已推送
@property (nonatomic, strong) NSString * pushType;
//相册来源名称
@property (nonatomic, strong) NSString *albumFkName;
//相册创建时间（时间格式：yyyy/MM/dd hh:mm）
@property (nonatomic, strong) NSString *showDate;
//相册数量
@property (nonatomic, strong) NSString *albumNum;

@end

/**
 *  评论实体 - 通用
 */
@interface commentEntity : NSObject

//评论主键
@property (nonatomic, strong) NSString *commId;
//数据来源类型
@property (nonatomic, strong) NSString *commType;
//评论人ID
@property (nonatomic, strong) NSString *commUserId;
//评论人昵称
@property (nonatomic, strong) NSString *nickName;
//评论人性别
@property (nonatomic, assign) NSInteger sex;
//年龄
@property (nonatomic, strong) NSString *age;
//大头像地址
@property (nonatomic, strong) NSString *bigPicpath;
//小头像地址
@property (nonatomic, strong) NSString *smallPicpath;
//评论内容
@property (nonatomic, strong) NSString *content;
//评论时间(用于显示)
@property (nonatomic, strong) NSString *commDate;
//分页时间(用于分页)
@property (nonatomic, strong) NSString *pageCommDate;
//评论时间到现在间隔
@property (nonatomic, strong) NSString *showDate;
//回复ID
@property (nonatomic, strong) NSString *replyId;
//回复人
@property (nonatomic, strong) NSString *replyUserId;
//回复人昵称
@property (nonatomic, strong) NSString *replyNickName;
//回复人头像地址
@property (nonatomic, strong) NSString *replyBigPicPath;
@property (nonatomic, strong) NSString *replySmallPicPath;
//回复内容
@property (nonatomic, strong) NSString *replyContent;
//评论赞数
@property (nonatomic, strong) NSString *praNum;
//是否点赞 0已经点赞 1未点赞
@property (nonatomic, strong) NSString *praFlag;

//被评论人昵称
@property (nonatomic, strong) NSString *bynickName;
//处理类型 0.评论 1.回复
@property (nonatomic,strong) NSString * pubType;
//评论创建人
@property (nonatomic,strong) NSString *createUser;
//分页时间
@property (nonatomic,strong) NSString *pagecommDate;
//回复对象的内容
@property (nonatomic,strong) NSString *highLevelContent;


@end


/**
 *  相片实体 - 通用
 */
@interface photoEntity : NSObject

//相册图片编号
@property (nonatomic, strong) NSString *albumphoId;
//赞数量
@property (nonatomic, strong) NSString *chanNum;
//评论数量
@property (nonatomic, strong) NSString *commNUM;
//大图地址
@property (nonatomic, strong) NSString *bigpicPath;
//小图地址
@property (nonatomic, strong) NSString *smallpicPath;

@end


/**
 *  活动图片节点 - 通用
 */
@interface userPhotoEntity : NSObject

//	String		图片ID
@property (nonatomic, strong) NSString *photoId;
//	String		图片来源1：活动   2:帖子 3：评论
@property (nonatomic, strong) NSString *photoSource;
//	String		图片地址
@property (nonatomic, strong) NSString *bigPicPath;
//	String		图片地址
@property (nonatomic, strong) NSString *smallPicPath;
//	String		视频地址
@property (nonatomic, strong) NSString *videoPicPath;
//	String		宽
@property (nonatomic, strong) NSString *width;
//	String		高
@property (nonatomic, strong) NSString *height;
//是否本人发布  1：是 0：不是
@property (nonatomic, strong) NSString *isSelf;

@end

///**
// * 排序实体 - 通用
// */
//@interface CodemxEntity : NSObject
////编号
//@property (nonatomic,strong)NSString * codeMx;
////值
//@property (nonatomic,strong)NSString * codemxValue;
////图片地址
//@property (nonatomic,strong)NSString *  codemxpicPath;
////排序号
//@property (nonatomic,strong)NSString * codemxSort;
//@end



/**
 *  个人信息 - 通用
 */
@interface personalInfoEntity : NSObject

//昵称
@property (nonatomic, strong) NSString *nickName;
//id
@property (nonatomic, strong) NSString *userId;
//年龄
@property (nonatomic, strong) NSString *age;
//性别
@property (nonatomic) NSInteger sex;
//身高
@property (nonatomic, unsafe_unretained)    float   height;
//体重
@property (nonatomic, unsafe_unretained)    float   weight;
//大 用户背景图
@property (nonatomic, strong) NSString *bgBigPicPath;
//小 用户背景图
@property (nonatomic, strong) NSString *bgSmallPicPath;
//签名
@property (nonatomic, strong) NSString *sigNature;
//运动项目
@property (nonatomic, strong) NSString *hoobyProject;
//运动项目名称 - 爱好
@property (nonatomic, strong) NSString *hobbyProname;
//大图地址
@property (nonatomic, strong) NSString *bigPicPath;
//小图地址
@property (nonatomic, strong) NSString *smallPicPath;
//是否加关注
@property (nonatomic, strong) NSString *isAttention;
//是否是好友
@property (nonatomic, assign) BOOL isFriend;
//手机号
@property (nonatomic, strong) NSString *mobile;
//用户等级
@property (nonatomic, strong) NSString *levelIcon;
//是否是教练(0:是,1:否)
@property (nonatomic, strong) NSString *isCoach;
//访客数量
@property (nonatomic, strong) NSString *visitorNum;
// 性取向code
@property (nonatomic, strong) NSString *sexUalitycode;
// 性取向
@property (nonatomic, strong) NSString *sexUality;
// 星座code
@property (nonatomic, strong) NSString *conStellcode;
// 星座
@property (nonatomic, strong) NSString *conStell;
// 电影爱好code
@property (nonatomic, strong) NSString *movieHobbycode;
// 电影爱好
@property (nonatomic, strong) NSString *movieHobby;
// 音乐爱好code
@property (nonatomic, strong) NSString *musicHobbycode;
// 音乐爱好
@property (nonatomic, strong) NSString *musicHobby;
// 小说爱好code
@property (nonatomic ,strong) NSString *storyHobbycode;
// 小说爱好
@property (nonatomic ,strong) NSString *storyHobby;
// 是否是俱乐部掌门人 0 yes 1 no
@property (nonatomic, strong) NSString *isClubMan;
// 省code
@property (nonatomic, strong) NSString *procode;
// 省
@property (nonatomic, strong) NSString *pro;
// 市code
@property (nonatomic, strong) NSString *citycode;
// 市
@property (nonatomic, strong) NSString *city;
//县区
@property (nonatomic, strong) NSString *districtcode;
//县区
@property (nonatomic, strong) NSString *district;
// 个人简介
@property (nonatomic, strong) NSString *introduction;

@end


/**
 *  个人信息 - 动态实体
 */
@interface personalDynamicEntity : NSObject

//动态编号
@property (nonatomic, strong) NSString *dynamicId;
//用户编号
@property (nonatomic, strong) NSString *userId;
//动态内容
@property (nonatomic, strong) NSString *content;
//个人定位信息
@property (nonatomic, strong) NSString *showAddress;
/*
 **
   动态类型1：活动 2：场馆  3：俱乐部  5：个人动态页发布  6：运动日记 7：约运动    998：个性签名修改     999：修改头像
 **
 */
@property (nonatomic, strong) NSString *dynamicType;
//创建时间
@property (nonatomic, strong) NSString *createDate;
//关联的ID
@property (nonatomic, strong) NSString *fkId;
//关联的名称
@property (nonatomic, strong) NSString *showName;
//关联的描述
@property (nonatomic, strong) NSString *showDescription;
//关联的图片ID
@property (nonatomic, strong) NSString *fkPicId;
//其它类型的大图值
@property (nonatomic, strong) NSString *otherbigpicPath;
//其它类型的小图值
@property (nonatomic, strong) NSString *othersmallpicPath;
//图片宽
@property (nonatomic, assign) CGFloat width;
//图片高
@property (nonatomic, assign) CGFloat height;
//显示时间
@property (nonatomic, strong) NSString * showDate;
//头像大图地址
@property (nonatomic, strong) NSString * bigpicPath;
//头像小图地址
@property (nonatomic, strong) NSString * smallpicPath;
//昵称
@property (nonatomic, strong) NSString * nickName;
//赞数量
@property (nonatomic, strong) NSString * chanNum;
//评论数量
@property (nonatomic, strong) NSString *  commNum;
//1:显示图片 2:不显示图片
@property (nonatomic, strong) NSString * showType;
//性别
@property (nonatomic, strong) NSString * sex;
//是否点赞 0:是 1：不是
@property (nonatomic, assign) NSInteger  praFlag;
//赞列表
@property (nonatomic, strong)NSMutableArray *  praiseList;
//显示时间点
@property (nonatomic, strong)NSString * showTime;
@end

//支付方式实体
@interface SportsPaymentTypeEntity : NSObject

// 支付方式：1、慧动卡支付  2、支付宝  3、银联支付
@property (nonatomic, strong) NSString *type;
// 支付方式ID
@property (nonatomic, strong) NSString *typeId;
// 支付方式名称
@property (nonatomic, strong) NSString *name;
// 服务器端被动通知 URL
@property (nonatomic, strong) NSString *backendURL;
// 支付背景图片
@property (nonatomic, strong) NSString *picPath;
// 支付备注
@property (nonatomic, strong) NSString *remark;
// 排序号
@property (nonatomic, strong) NSString *sortNum;
// 支付地址
@property (nonatomic, strong) NSString *payAddress;
// 前台通知url
@property (nonatomic, strong) NSString *frontendUrl;
// 签名方式
@property (nonatomic, strong) NSString *sign;
// 版本号
@property (nonatomic, strong) NSString *versionNum;

@end

//赞成员实体 继承个人
@interface PraiseMeEntity : personalInfoEntity
//赞编号
@property (nonatomic, strong)NSString *  phopraId;
//赞地点
@property (nonatomic, strong)NSString * praAddress;
//赞时间
@property (nonatomic, strong)NSString *praDate;
//创建时间
@property (nonatomic, strong)NSString * createDate;
//个性签名
@property (nonatomic, strong)NSString * signature;
//生日
@property (nonatomic, strong)NSString * birthday;
@end



