//
//  GroupApplyTableViewCell.m
//  nationalFitness
//
//  Created by joe on 2019/8/12.
//  Copyright © 2019年 chenglong. All rights reserved.
//

#import "GroupApplyTableViewCell.h"

#import "UIColor+RYChat.h"
#import "UIFont+RYChat.h"

@implementation GroupApplyTableViewCell{
    
    
    __weak IBOutlet NSLayoutConstraint *widthConstant;
     
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    
    widthConstant.constant = self.frame.size.height;
    
    
    ViewRadius(self.badgeImageV, 2.5);
    
    //self.timeLabel.hidden = YES;
    
    //self.agreeBtn.hidden = YES;
    
    
    self.applyDetailLabel.textColor = [UIColor colorMainTextColor];
    //self.statusLabel.textColor = [UIColor colorMainThirdTextColor];
    self.timeLabel.textColor = [UIColor colorMainSecTextColor];
    
    //ViewRadius(self.headImageView, self.headImageView.frame.size.width/2);
    //    ViewRadius(self.headImageView, 3);
    self.applyDetailLabel.font = [UIFont fontConversationDetail];
    
    
    self.applyDetailLabel.textColor = [UIColor colorMainTextColor];
    self.stateLabel.textColor = [UIColor colorMainThirdTextColor];
    self.timeLabel.textColor = [UIColor colorMainSecTextColor];
    
    
    
    
}








- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
