//
//  SaveSetCustomTableViewCell.m
//  nationalFitness
//
//  Created by Joe on 2017/7/24.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "SaveSetCustomTableViewCell.h"
#import "UIColor+RYChat.h"
@implementation SaveSetCustomTableViewCell{
    
    
    __weak IBOutlet UILabel *zidingyiLabel;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    
    self.titleLabel.textColor = [UIColor colorMainTextColor];
    zidingyiLabel.textColor = [UIColor colorMainTextColor];
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
