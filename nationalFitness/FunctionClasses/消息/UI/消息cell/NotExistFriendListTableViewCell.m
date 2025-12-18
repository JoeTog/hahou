//
//  NotExistFriendListTableViewCell.m
//  nationalFitness
//
//  Created by Joe on 2017/9/6.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "NotExistFriendListTableViewCell.h"



@implementation NotExistFriendListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    
    ViewRadius(self.titleLabel, 2);
    
    //titleLabel
    
//    if (SCREEN_WIDTH == 320) {
//        self.fmLinkBtnRightConstaint.constant = 50;
//    }
    
    [self.titleLabel addClickText:@"点击发送好友请求" attributeds:@{NSForegroundColorAttributeName : [UIColor blueColor]} transmitBody:(id)@"呵呵哒 被点击了" clickItemBlock:^(id transmitBody) {
        NSLog(@"被点击了");
    }];
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
