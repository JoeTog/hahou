//
//  NotExistFriendListTableViewCell.h
//  nationalFitness
//
//  Created by Joe on 2017/9/6.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMLinkLabel.h"


@interface NotExistFriendListTableViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet FMLinkLabel *titleLabel;


@property (weak, nonatomic) IBOutlet UIButton *fmLinkClickBtn;

//发送好友请求按钮 右侧约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fmLinkBtnRightConstaint;



@end
