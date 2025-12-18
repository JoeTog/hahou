//
//  RecommendFriendTableViewCell.m
//  nationalFitness
//
//  Created by joe on 2019/12/30.
//  Copyright © 2019年 chenglong. All rights reserved.
//

#import "RecommendFriendTableViewCell.h"

@implementation RecommendFriendTableViewCell{
    
    
    __weak IBOutlet NSLayoutConstraint *nackLeadConstant;
    
    
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    
    nackLeadConstant.constant = SCREEN_WIDTH/5 + 40 + 8;
    
    
}






















- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
