//
//  DynamicNewDetailViewController.h
//  nationalFitness
//
//  Created by Joe on 2017/7/7.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "NFbaseViewController.h"
#import "NFDynamicEntity.h"
#import "NFCommentInputView.h"
#import "NFMessageFaceView.h"
#import "NFBaseEntity.h"
#import "FindCommentsCell.h"
#import "ContentNewCell.h"
#import "SocketModel.h"
#import "ReplyCommentTableViewCell.h"
#import "MKPAlertView.h"

/**
 *  键盘切换类型
 */
typedef NS_ENUM(NSInteger,ZBMessageViewState) {
    /**
     *  表情
     */
    ZBMessageViewStateShowFace,
    /**
     *  图片
     */
    ZBMessageViewStateShowVoice,
    /**
     *  默认
     */
    ZBMessageViewStateShowNone,
};

typedef void (^ReturnDeleteDynamicBlock)();

typedef void (^ReturnPraiseBlock)(BOOL ret);

@interface DynamicNewDetailViewController : NFbaseViewController

@property (copy, nonatomic) NSMutableDictionary *parms;    //懒加载

@property(nonatomic,copy)ReturnDeleteDynamicBlock ReturnDeleteDynamicBlock;

-(void)returnDeleteBlock:(ReturnDeleteDynamicBlock)block;

@property(nonatomic,copy)ReturnPraiseBlock returnPraiseBlock;

-(void)returnPraise:(ReturnPraiseBlock)block;

// 关联的帖子
@property (strong, nonatomic) NSString *entityid;

// 是否是点击评论进来的 如果是的话 需要将键盘弹出
@property (assign, nonatomic) BOOL isFromComment;

//
@property (nonatomic, strong) NoteListEntity *noteListEntity;











@end
