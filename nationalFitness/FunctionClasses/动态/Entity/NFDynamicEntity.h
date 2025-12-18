//
//  NFDynamicEntity.h
//  nationalFitness
//
//  Created by liumac on 16/1/4.
//  Copyright © 2016年 chenglong. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface NFDynamicEntity : NSObject

@end

//评论实体
@interface NoteCommentEntity : NSObject

@property (strong ,nonatomic) NSString *circle_id; // 动态id

@property (strong, nonatomic) NSString *comment_content; // 评论内容

@property (strong, nonatomic) NSString *comment_id; // 评论id

@property (strong, nonatomic) NSString *comment_target_id; // 评论对象id

@property (strong, nonatomic) NSString *comment_time; // 评论时间

@property (strong, nonatomic) NSString *comment_date; // 评论时间

@property (strong, nonatomic) NSString *is_del; // 是否删除

@property (strong, nonatomic) NSString *is_read; // 是否已读

@property (strong, nonatomic) NSString *photo; // 头像

@property (strong, nonatomic) NSString *user_id; //

@property (strong, nonatomic) NSString *user_name; //

@property (strong, nonatomic) NSString *user_nickName; //评论人昵称

@property (strong, nonatomic) NSString *replyToId; //回复人id


@property (strong, nonatomic) NSString *replyToName; //回复人name

@property (strong, nonatomic) NSString *replyToNickName; //回复人昵称

@property (strong, nonatomic) NSString *replyContent; //回复者评论内容

@end

// 帖子中包含的帖子 社团 活动 场馆等实体
@interface NoteContentEntity : NSObject

@property (strong ,nonatomic) NSString *noteId; // 帖子／场馆／社团／活动 主键

@property (strong, nonatomic) NSString *noteContent; // 帖子的内容

@property (strong, nonatomic) NSString *createDate; // 帖子发布时间

@property (strong, nonatomic) NSString *range; // 帖子范围 1全部公开 2部分公开

@property (strong, nonatomic) NSString *isUpdate; // 帖子的编辑状态 0否 1是

@property (strong, nonatomic) NSString *relAddress; // 帖子发布地点

@property (strong, nonatomic) NSString *fkid; // 帖子关联的主键

@property (strong, nonatomic) NSString *nickName; // 发帖人昵称

@property (strong, nonatomic) NSString *userPicPath; // 发帖人头像

@property (strong, nonatomic) NSString *noteSource; // 帖子来源 1普通 2活动帖子 3社团帖子

@property (strong, nonatomic) NSString *actName; // 活动或社团或场馆名称

@property (strong, nonatomic) NSString *proName; // 活动类型

@property (strong, nonatomic) NSString *bigPicPath; // 大图路径

@property (strong, nonatomic) NSString *smallPicPath; // 小图路径

@property (strong, nonatomic) NSString *month; // 月份

@property (strong, nonatomic) NSString *day; // 日期

@property (strong, nonatomic) NSString *times; // 时间  时分

@property (strong, nonatomic) NSString *startDate; // 开始时间

@property (strong, nonatomic) NSString *endDate; // 结束时间

@property (strong, nonatomic) NSString *lowPrice; // 最低价

@property (strong, nonatomic) NSString *highPrice; // 最高价

@property (strong, nonatomic) NSString *perPrice; // 优惠价

@property (strong, nonatomic) NSString *clubType; // 社团或者场馆类型

@property (strong, nonatomic) NSString *logoPath; // logo图片

@property (strong, nonatomic) NSArray *photoList; // 图片集合

@property (strong, nonatomic) NSString *isVedio; // 当前帖子是否是视频帖子 0不是 1是

@property (assign, nonatomic) BOOL isExetend; // 当前是否展开显示全部的内容

@property (strong, nonatomic) NSString *praNum; // 当前分享内容的赞数

@end

// 帖子的列表实体
@interface NoteListEntity : NSObject

@property (strong, nonatomic) NSString *circle_id; // 帖子的主键

@property (strong, nonatomic) NSString *like_id; // 

@property (strong, nonatomic) NSString *user_id; // 发表人id

@property (strong, nonatomic) NSString *user_name; // 发表人

@property (strong, nonatomic) NSString *photo; // 头像

@property (strong, nonatomic) NSString *nickname; // 昵称

@property (strong, nonatomic) NSString *circle_content; // 内容

@property (strong, nonatomic) NSString *post_address; // 发帖地址

@property (strong, nonatomic) NSString *post_time; // 发表时间 昨天、日期

@property (strong, nonatomic) NSString *praiseCount; // 赞数量

@property (strong, nonatomic) NSString *isPraise; // 是否点赞过 0未点赞 1点赞过

@property (strong, nonatomic) NSString *currentUserLike; // 点赞id

@property (strong, nonatomic) NSArray *circleImageArr; //

@property (strong, nonatomic) NSMutableArray *photoList; // 帖子的图片或者是视频集合

@property (strong, nonatomic) NSMutableArray *commentArr; //评论列表





@property (strong, nonatomic) NSString *noteId; // 帖子的主键

@property (strong, nonatomic) NSString *noteContent; // 帖子的内容

@property (strong, nonatomic) NSString *noteShareUrl; // 帖子的分享链接

@property (strong, nonatomic) NSString *redDate; // 帖子的发布时间

@property (strong, nonatomic) NSString *createDate; // 帖子发布时间

@property (strong, nonatomic) NSString *relUserId; // 发帖人ID

@property (strong, nonatomic) NSString *range; // 帖子范围 1全部可见 2 部分可见

@property (strong, nonatomic) NSString *isUpdate; // 帖子的编辑状态 0 否 1 是

@property (strong, nonatomic) NSString *relAddress; // 帖子的发布地点

@property (strong, nonatomic) NSString *fkid; // 帖子关联的主键

//@property (strong, nonatomic) NSString *nickName; // 发帖人昵称

@property (strong, nonatomic) NSString *smallPicPath; // 发帖人头像

@property (strong, nonatomic) NSString *noteSource; // 帖子来源 1普通 2活动 3社团

@property (strong, nonatomic) NSString *shareType; // 分享类型 1帖子 2活动 3社团 4场馆

@property (strong, nonatomic) NSString *sportType; // 帖子关联的活动的运动类型

@property (strong, nonatomic) NSString *commentCount; // 评论的数量



@property (strong, nonatomic) NSString *actName; //帖子关联的活动或者是社团的名称

@property (strong, nonatomic) NSString *isFlag; // 当前用户与此帖子的关系 0是此人发布 1不是此人

@property (strong, nonatomic) NSString *isVedio; // 当前帖子是否是视频帖子 0不是 1是



@property (assign, nonatomic) BOOL isExetend; // 当前是否展开显示全部的内容


@property (strong, nonatomic) NSString *isExtenSion; // 是否是推广（广告） 0是 1不是

@property (strong, nonatomic) NSString *extensionType; // 推广类型 1 附近的约 2 精彩社团 3 周边活动 4附近场地 5广告
@property (strong, nonatomic) NSMutableArray *sportList; // 附近的约集合

@property (strong, nonatomic) NSMutableArray *clubList; // 精彩社团集合

@property (strong, nonatomic) NSMutableArray *exerciseList; // 周边活动集合

@property (strong, nonatomic) NSMutableArray *venueList; // 推荐的场地集合

@property (strong, nonatomic) NSMutableArray *homeFocusList; // 推广的广告集合

@property (strong, nonatomic) NoteContentEntity *noteEntity; // 帖子中包含的帖子 社团 活动 场馆等实体

@end


// 关联的活动实体
@interface ExericiseEntity : NSObject

@property (strong, nonatomic) NSString *actName; // 活动名称

@property (strong, nonatomic) NSString *sportType; // 活动类型

@property (strong, nonatomic) NSString *startDate; // 活动开始时间

@property (strong, nonatomic) NSString *actId; // 活动主键ID

@property (strong, nonatomic) NSString *smllPicPath; // 活动小图

@property (strong, nonatomic) NSString *bigPicPath; // 活动大图

@property (assign, nonatomic) BOOL isSelect; // 是否被选中

@end


// 关联的俱乐部实体
@interface ClubEntity : NSObject

@property (strong, nonatomic) NSString *clubId; // 社团主见ID

@property (strong, nonatomic) NSString *clubName; // 社团名称

@property (strong, nonatomic) NSString *smallPicPath; // 社团小图

@property (strong, nonatomic) NSString *bigPicPath; // 社团大图

@property (assign, nonatomic) BOOL isSelect; // 是否被选中

@end

// 关联的公共主页实体
@interface PublicNoEntity : NSObject

@property (strong, nonatomic) NSString *pubNoId; // 公共号主键id

@property (strong, nonatomic) NSString *smllPicPath; // 小图

@property (strong, nonatomic) NSString *bigPicPath; // 大图

@property (strong, nonatomic) NSString *nickName; // 昵称

@property (assign, nonatomic) BOOL isSelect; // 是否被选中

@property (strong, nonatomic) NSString * createDate; //用于分页

//公众号UserId
@property (strong, nonatomic) NSString * userId;

//点击数
@property (strong, nonatomic) NSString * clickNum;

//口号
@property (strong, nonatomic) NSString * sloganName;

//LOGO图片
@property (strong, nonatomic) NSString * logoUrl;

//公众号简介
@property (strong, nonatomic) NSString * introDuction;

//分享链接
@property (strong, nonatomic) NSString * shareUrl;

//是否点赞 0：已点赞 1：未点赞
@property (strong, nonatomic) NSString * praFlag;

//赞数量
@property (strong, nonatomic) NSString * praNum;

//是否收藏 0：已收藏 1：未收藏
@property (strong, nonatomic) NSString * collFlag;

@end


// 帖子的列表中图片实体
@interface NoteListPhotoEntity : NSObject

//图片
@property (strong, nonatomic) NSString * image_uri;

//图片id
@property (strong, nonatomic) NSString * image_id;


@end



// 评论列表 实体
@interface commentListEntity : NSObject

@property (strong, nonatomic) NSString *dymicId; //

@property (strong, nonatomic) NSString *headImageUrl; //

@property (strong, nonatomic) NSString *nickname; //

@property (strong, nonatomic) NSString *commentContent; //

@property (strong, nonatomic) NSString *dymicContent; //

@property (strong, nonatomic) NSString *timeStr; //

@property (strong, nonatomic) NSString *imageTUrl; //


@property (assign, nonatomic) BOOL IsDianZan; //











@end



