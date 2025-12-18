//
//  NFDynamicManager.h
//  nationalFitness
//
//  Created by liumac on 16/1/4.
//  Copyright © 2016年 chenglong. All rights reserved.
//

#import "NFBaseManager.h"

@interface NFDynamicManager : NFBaseManager

//发布帖子
- (void)publishNoteManager;

//关联的活动和社团
- (void)connectNoteManager;

//帖子列表
- (void)noteListManager;

//帖子详情
- (void)detailNoteManager;

//活动帖子列表
- (void)actNoteListManager;

// 删除帖子
- (void)deleteNoteManager;

// 评论列表
- (void)noteCommentListManager;

// 评论
- (void)commentNoteManager;

// 评论回复列表
- (void)commentRelyManager;

// 点赞
- (void)priseNoteManager;

// 取消点赞
- (void)cancelPriseNoteManager;

// 删除评论
- (void)deleteCommentManager;

// 动态插入
- (void)recommendManager;

// 可能认识的人
- (void)mayKnowPeoManager;

//收藏公众号
- (void)collPublicNoManager;

//取消收藏
- (void)cancelCollPublicNoManager;

@end
