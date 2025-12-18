//
//  NFDynamicParser.h
//  nationalFitness
//
//  Created by liumac on 16/1/4.
//  Copyright © 2016年 chenglong. All rights reserved.
//

#import "NFBaseParser.h"
#import "NFMyManage.h"
#import "YYModel.h"


@interface NFDynamicParser : NFBaseParser

// 发布动态
+ (id)publishNoteParser:(NSData *)data;

// 关联的活动和社团
+ (id)connectNoteParser:(NSData *)data;

// 帖子列表
+ (id)noteListParser:(NSData *)data;

// 帖子详情页
+ (id)detailNoteParser:(NSData *)data;

// 活动帖子列表
+ (id)actNoteListParser:(NSData *)data;

// 删除帖子
+ (id)deleteNoteParser:(NSData *)data;

// 评论列表
+ (id)noteCommentListParser:(NSData *)data;

// 评论
+ (id)commentNoteParser:(NSData *)data;

// 评论回复列表
+ (id)commentRelyParser:(NSData *)data;

// 点赞
+ (id)priseNoteParser:(NSData *)data;

// 取消点赞
+ (id)cancelPriseNoteParser:(NSData *)data;

// 删除评论
+ (id)deleteCommentParser:(NSData *)data;

// 动态插入
+ (id)recommendParser:(NSData *)data;

// 可能认识的人
+ (id)mayKnowPeoParser:(NSData *)data;

//收藏公众号
+ (id)collPublicNoParser:(NSData *)data;

//取消收藏公众号
+ (id)cancelCollPublicNoParser:(NSData *)data;

// 动态提醒评论列表
+ (id)dynamicCommentListParser:(NSArray *)data;
    
    
    
@end
