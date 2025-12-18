//
//  NFFAddImageCell.h
//  nationalFitness
//
//  Created by Joe on 2017/7/7.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PublishDynamicViewController.h"
#import "AddImageCollectionViewCell.h"

#define kSelecetMax   9

@interface NFFAddImageCell : UITableViewCell<UICollectionViewDelegate, UICollectionViewDataSource>



@property(nonatomic) CGFloat height;

@property(nonatomic, strong) NSMutableArray *picMuArr;

- (void)setCellWith:(NSIndexPath *)indexPath SGPhotoImageArr:(NSArray *)imageArr withCtrol:(PublishDynamicViewController *)ctrol;

@end
