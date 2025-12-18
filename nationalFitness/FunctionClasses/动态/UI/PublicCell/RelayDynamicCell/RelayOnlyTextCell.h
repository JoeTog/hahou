//
//  RelayOnlyTextCell.h
//  nationalFitness
//
//  Created by Joe on 2017/7/10.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NFCommentInputView.h"

#define RelayOnlyTextCellFontSize 15


@interface RelayOnlyTextCell : UITableViewCell<UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIButton *zanBtn;

@property (weak, nonatomic) IBOutlet UIButton *commentBtn;

@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UIButton *qubaoBtn;

@property (weak, nonatomic) IBOutlet UIButton *showMoreBtn;

@property (weak, nonatomic) IBOutlet UIButton *editBtn;


+ (CGFloat)getContentCellHeight:(NSString  *)str seeingMore:(BOOL)seeingMore;

- (void)showCellWithEntity:(id)entity withDataSource:(NSMutableArray *)dataArr commentView:(NFCommentInputView *)commentView withTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;


@end
