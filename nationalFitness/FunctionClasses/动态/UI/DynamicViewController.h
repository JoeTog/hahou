//
//  DynamicViewController.h
//  nationalFitness
//
//  Created by Joe on 2017/6/28.
//  Copyright © 2017年 chenglong. All rights reserved.
//


#import "NFbaseViewController.h"
#import "OnlyTextTableViewCell.h"
#import "NFDynamicManager.h"
#import "NFDynamicEntity.h"
#import "DynamicNewDetailViewController.h"
#import "PublishDynamicViewController.h"
#import "ContentNewCell.h"

#import "RelayOnlyTextCell.h"
#import "RelayTextAndPicCell.h"
#import "DynamicCommentTableViewCell.h"
#import "FMLinkLabel.h"
#import "NFCommentInputView.h"
#import "SDAutoLayout.h"
#import "PointListTableViewController.h"



@interface DynamicViewController : NFbaseViewController

@property (copy, nonatomic) NSMutableDictionary *parms;    //懒加载

@property (strong, nonatomic) NSIndexPath *zanIndexpath;    //点击cell中的赞 记录点击的indexpath

@property (strong, nonatomic) NFCommentInputView *messageToolView;

//记录选中的indexpath 选中的评论
@property (strong, nonatomic) NSIndexPath *selectCommentIndexpath;



- (void)getNoteList;


@end
