//
//  RelayTextAndPicCell.h
//  nationalFitness
//
//  Created by Joe on 2017/7/11.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NFCommentInputView.h"

#define RelayTextAndPicCellHeight (550 - 268.f + kPLUS_SCALE_X(268.f))


@interface RelayTextAndPicCell : UITableViewCell<UIActionSheetDelegate>



@property (weak, nonatomic) IBOutlet UIButton *showMoreBtn;

@property (weak, nonatomic) IBOutlet UIButton *zanBtn;

@property (weak, nonatomic) IBOutlet UIButton *commentBtn;

@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UIButton *qubaoBtn;

@property (weak, nonatomic) IBOutlet UIButton *editBtn;

+ (CGFloat)getContentCellHeight:(NSString  *)str seeingMore:(BOOL)seeingMore;

- (void)showCellWithEntity:(id)entity withDataSource:(NSMutableArray *)dataArr commentView:(NFCommentInputView *)commentView withTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;

@end
