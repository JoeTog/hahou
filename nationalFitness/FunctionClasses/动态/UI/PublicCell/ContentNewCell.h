//
//  ContentNewCell.h
//  nationalFitness
//
//  Created by Joe on 2017/7/8.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NFCommentInputView.h"
#import "SocketModel.h"
#import "OpinionRequestViewController.h"
#import "JQFMDB.h"

#import "SDAutoLayout.h"

#define ContentNewCellFontSize 14
#define leadAndTailConstaint 16 //头尾间距

@interface ContentNewCell : UITableViewCell<UIActionSheetDelegate,ChatHandlerDelegate>

//头像
@property (weak, nonatomic) IBOutlet NFHeadImageView *headImageView;


@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;

@property (weak, nonatomic) IBOutlet UIButton *zanBtn;

@property (weak, nonatomic) IBOutlet UIButton *editBtn;

@property (weak, nonatomic) IBOutlet UIButton *showMoreBtn;

@property (weak, nonatomic) IBOutlet UIButton *qubaoBtn;

@property (copy, nonatomic) NSMutableDictionary *parms;    //懒加载

//底部线
@property (weak, nonatomic) IBOutlet UIImageView *bottomLineImage;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLineHeightConstaint;

//赞上面线
@property (weak, nonatomic) IBOutlet UILabel *middleLineLabel;


//是否视频
@property (nonatomic, assign)BOOL isVideo;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentHeightConstaint;



@property (nonatomic, strong) NoteListEntity *model;

+ (CGFloat)getContentCellHeight:(NSString *)str seeingMore:(BOOL)seeingMore;

- (void)showCellWithEntity:(id)entity withDataSource:(NSMutableArray *)dataArr CacheHeightDict:(NSMutableDictionary *)cacheHeightDict commentView:(NFCommentInputView *)commentView withTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;



@end
