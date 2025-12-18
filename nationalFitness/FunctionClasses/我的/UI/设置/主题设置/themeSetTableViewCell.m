//
//  themeSetTableViewCell.m
//  nationalFitness
//
//  Created by Joe on 2017/8/7.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "themeSetTableViewCell.h"

@implementation themeSetTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    
    
    
}

//应用主题
- (IBAction)useThisThemeClick:(UIButton *)sender {
    
    
}

-(void)setThemeEntity:(ThemeSetEntity *)themeEntity{
    self.titleLabel.text = themeEntity.themeTitle;
    self.versionLabel.text = themeEntity.version;
    [self.imageV ShowImageWithUrlStr:themeEntity.picPath completion:^(BOOL success, UIImage *image) {
        
    }];
    
    
}




- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
