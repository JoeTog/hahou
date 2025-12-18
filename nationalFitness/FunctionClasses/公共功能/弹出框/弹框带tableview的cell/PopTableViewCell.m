//
//  PopTableViewCell.m
//  nationalFitness
//
//  Created by 童杰 on 2017/3/1.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "PopTableViewCell.h"

@implementation PopTableViewCell{
    
    
    __weak IBOutlet NSLayoutConstraint *leadindContant;
    
    __weak IBOutlet NSLayoutConstraint *tailingContant;
    
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.selectBtn.userInteractionEnabled = NO;
    
    [self.selectBtn setImage:[UIImage imageNamed:@"授权管理未选中"] forState:UIControlStateNormal];
    [self.selectBtn setImage:[UIImage imageNamed:@"授权管理选中"] forState:UIControlStateSelected];
    
    leadindContant.constant = kPLUS_SCALE_X(25);//文字左边 leading距离
    tailingContant.constant = kPLUS_SCALE_X(20);//选择圈按钮 tailing距离
    
    self.titleLabel.font = [UIFont systemFontOfSize:17];
    
}







- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
