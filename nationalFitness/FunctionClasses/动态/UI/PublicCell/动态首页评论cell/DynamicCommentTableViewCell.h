//
//  DynamicCommentTableViewCell.h
//  nationalFitness
//
//  Created by Joe on 2017/9/20.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMLinkLabel.h"
#import "NFDynamicEntity.h"


#import "UIView+SDAutoLayout.h"

@interface DynamicCommentTableViewCell : UITableViewCell


//评论
@property (weak, nonatomic) IBOutlet FMLinkLabel *commentLabel;

@property (nonatomic, strong) NoteCommentEntity *model;

//根据文字的长度适配cell的高度
+ (CGFloat)getContentCellHeight:(NoteCommentEntity  *)commentEntity seeingMore:(BOOL)seeingMore;

















@end
