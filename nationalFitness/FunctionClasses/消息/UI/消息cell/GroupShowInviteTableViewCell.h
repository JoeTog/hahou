//
//  GroupShowInviteTableViewCell.h
//  nationalFitness
//
//  Created by Joe on 2017/9/14.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FMLinkLabel.h"

@interface GroupShowInviteTableViewCell : UITableViewCell

//展示 xxx 被拉入群聊

@property (weak, nonatomic) IBOutlet FMLinkLabel *GroupShowMessageLabel;


@property (weak, nonatomic) IBOutlet UIButton *ClickBtnn;


@end
