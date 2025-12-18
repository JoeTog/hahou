//
//  GroupMemberCollectionViewCell.m
//  nationalFitness
//
//  Created by Joe on 2017/7/13.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "GroupMemberCollectionViewCell.h"
#import "UIColor+RYChat.h"

@implementation GroupMemberCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.nickNamelabel.textColor = [UIColor colorMainTextColor];
    
//    self.headImageV.backgroundColor = [UIColor clearColor];
    
}

@end
