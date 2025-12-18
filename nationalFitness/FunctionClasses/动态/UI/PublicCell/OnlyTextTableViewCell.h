//
//  OnlyTextTableViewCell.h
//  nationalFitness
//
//  Created by Joe on 2017/7/7.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NFDynamicEntity.h"
#import "NFDynamicManager.h"
#import "DynamicNewDetailViewController.h"
#import "NFCommentInputView.h"
#import "DynamicViewController.h"
#import "SocketModel.h"
#import "LWWeChatActionSheet.h"
#import "OpinionRequestViewController.h"
#import "JQFMDB.h"

#import "SDAutoLayout.h"

#define OnlyTextTableViewCellFontSize 14
#define leadAndTailConstaint 16 //头尾间距



@interface OnlyTextTableViewCell : UITableViewCell<UIActionSheetDelegate,ChatHandlerDelegate>

@property (copy, nonatomic) NSMutableDictionary *parms;    //懒加载

//头像 公开是为了传出点击事件
@property (weak, nonatomic) IBOutlet NFHeadImageView *headImageView;


@property (weak, nonatomic) IBOutlet UIButton *editBtn;

@property (weak, nonatomic) IBOutlet UIButton *showMoreBtn;

@property (weak, nonatomic) IBOutlet UIButton *zanBtn;

@property (weak, nonatomic) IBOutlet UIButton *shareBtn;

@property (weak, nonatomic) IBOutlet UIButton *commentBtn;

@property (weak, nonatomic) IBOutlet UIButton *qubaoBtn;

//底部线
@property (weak, nonatomic) IBOutlet UIImageView *bottomLineImage;
//底部线高度约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLineHeightConstaint;
//赞上面线
@property (weak, nonatomic) IBOutlet UILabel *middleLineLabel;

+ (CGFloat)getContentCellHeight:(NSString *)str seeingMore:(BOOL)seeingMore;

- (void)showCellWithEntity:(id)entity withDataSource:(NSMutableArray *)dataArr CacheHeightDict:(NSMutableDictionary *)cacheHeightDict commentView:(NFCommentInputView *)commentView withTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;


@end
