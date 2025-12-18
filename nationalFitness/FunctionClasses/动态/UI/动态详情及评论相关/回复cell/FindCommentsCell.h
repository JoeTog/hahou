//
//  FindCommentsCell.h
//  newTestUe
//
//  Created by liumac on 15/12/18.
//  Copyright © 2015年 程龙. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NFBaseEntity.h"
#import "ReplyCommentsViewController.h"
#import "NFDynamicEntity.h"



typedef void(^commentInput)(BOOL comment);

@interface FindCommentsCell : UITableViewCell

@property (strong ,nonatomic) commentInput input;

- (void)setTextStr:(NoteCommentEntity *)entity withFkId:(NSString *)fkId; // 带回复的

+ (CGFloat)getContentCellHeight:(NoteCommentEntity *)entity; // 带有回复的

- (void)setContentStr:(commentEntity *)entity withFkId:(NSString *)fkId; // 不带回复的 暂无效

+ (CGFloat)getContentCellHeightWithOutReply:(NoteCommentEntity *)entity; // 不带回复的 暂无效

@end



