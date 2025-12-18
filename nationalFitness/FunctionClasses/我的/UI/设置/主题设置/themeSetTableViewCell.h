//
//  themeSetTableViewCell.h
//  nationalFitness
//
//  Created by Joe on 2017/8/7.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NFMineEntity.h"
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"
#import "NFShowImageView.h"

@interface themeSetTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet NFShowImageView *imageV;

//标题
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

//版本号
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

//已应用label
@property (weak, nonatomic) IBOutlet UILabel *isUseLabel;

//应用按钮
@property (weak, nonatomic) IBOutlet UIButton *userBtn;

//ThemeSetEntity
@property(nonatomic,strong)ThemeSetEntity *themeEntity;


@end
