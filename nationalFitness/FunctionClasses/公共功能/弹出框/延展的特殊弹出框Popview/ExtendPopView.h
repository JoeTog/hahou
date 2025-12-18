//
//  ExtendPopView.h
//  nationalFitness
//
//  Created by 童杰 on 2017/4/13.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NFbaseViewController.h"
#import "Masonry.h"
#import "ExtendPopTableTableViewCell.h"




@interface ExtendPopView : UIView<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>

//
@property (nonatomic, strong) UIView *backV_;


//带tableview
@property(nonatomic,strong)void(^choseSure)(BOOL,NSInteger);

@property(nonatomic,strong)void(^clickCell)(NSInteger);

/**实现单选
 *
 */
@property(nonatomic)BOOL isOnlyOne;

/**带tableview 的选择弹窗
 *
 */
-(instancetype)initWithFrame:(CGRect)frame message:(NSString *)message isNeedCancel:(BOOL)isNeedCancel CellTitleArr:(NSArray *)CellArr CellContantArr:(NSArray *)contantArr isSureBlock:(void(^)(BOOL sureBlock,NSInteger index))sureBlock ClickCellBlock:(void(^)(NSInteger index))clickCellBlock;


@property(nonatomic)BOOL isCanEdit;

@end
