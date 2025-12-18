//
//  DynamicPreviewViewController.h
//  nationalFitness
//
//  Created by Joe on 2017/7/8.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "NFbaseViewController.h"

#import "NFDynamicEntity.h"
#import "OnlyTextTableViewCell.h"
#import "ContentNewCell.h"


@interface DynamicPreviewViewController : NFbaseViewController


//预览的帖子
@property (nonatomic, strong) NoteListEntity *entity;

@end
