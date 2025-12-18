//
//  PublishDynamicViewController.h
//  nationalFitness
//
//  Created by Joe on 2017/7/7.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "NFbaseViewController.h"
#import "NFDynamicEntity.h"
#import "DynamicPreviewViewController.h"
#import "SocketModel.h"
#import "UIImageView+WebCache.h"

#import "SocketRequest.h"

#import "ClearManager.h"



typedef void(^publishSuccessBlock)(BOOL);

typedef NS_ENUM(NSInteger,ShareNoteType) {
    ShareTypeDefault, // 默认
    ShareTypeOffNote, // 分享的普通帖子类型
    ShareTypeOffAct, // 分享的活动类型
    ShareTypeOffClub, // 分享的社团类型
    ShareTypeOffVen, // 分享的场馆类型
    ShareTypeOffjubao, // 举报
};

@interface PublishDynamicViewController : NFbaseViewController
@property (copy, nonatomic) NSMutableDictionary *parms;    //懒加载

// 如果是对原有的帖子进行编辑，需要传入要编辑的对象
@property (nonatomic, strong) NoteListEntity *editEntity;

// 分享的类型
@property (nonatomic, assign) ShareNoteType shareType;

// 如果是分享的普通的帖子（因为这里要预览啊 所以要把分享的内容也要带过来。烦烦烦）
@property (nonatomic ,strong) NoteListEntity *noteEntity;

//// 如果是分享的活动 将活动实体传过来
//@property (nonatomic,strong) activityEntity *shareActEntity;
//
//// 如果分享的场地 将场地实体传过来
//@property (nonatomic,strong) venueEntity *shareVenEntity;
//
//// 在活动中发布的帖子传入活动的对象
//@property (nonatomic, strong) activityEntity *actEntity;
//
//// 在场馆中发布的帖子传入场地的对象
//@property (nonatomic, strong) venueEntity *venEntity;

//在公众号发帖子传来的实体
@property (nonatomic, strong) PublicNoEntity * pubEntity;

//在赛事结果发帖子传来的赛事id
@property (nonatomic, strong) NSString * ctypeId;

@property (nonatomic, strong) publishSuccessBlock successBlock;

- (void)selectPic;

- (void)deleteImageClick: (NSInteger)index;



@property (nonatomic, strong) NSString * groupid;
@property (nonatomic, strong) NSString * friendId;






@end
