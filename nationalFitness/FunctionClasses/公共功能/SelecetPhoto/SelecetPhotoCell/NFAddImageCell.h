//
//  NFAddImageCell.h
//  nationalFitness
//  没用到 暂时用NFFAddImageCell 代替
//  Created by 程long on 14-11-22.
//  Copyright (c) 2014年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "PublishDynamicViewController.h"
#import "NewHomeViewController.h"
#import "PublishDynamicViewController.h"

#define kSelecetMax   9

@interface NFAddImageCell : UITableViewCell<UICollectionViewDelegate, UICollectionViewDataSource>

@property(nonatomic) CGFloat height;

@property(nonatomic, strong) NSMutableArray *picMuArr;

- (void)setCellWith:(NSIndexPath *)indexPath withCtrol:(PublishDynamicViewController *)ctrol;

+(CGFloat)heightForCellWithData:(NSArray *)data;





@end
