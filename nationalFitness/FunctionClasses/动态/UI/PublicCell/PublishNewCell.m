//
//  PublishNewCell.m
//  newTestUe
//
//  Created by 林向阳 on 15/12/15.
//  Copyright © 2015年 程龙. All rights reserved.
//

#import "PublishNewCell.h"
#import "PublicDefine.h"
#import "NFShowImageView.h"

@implementation PublishNewCell
{
    __weak IBOutlet NFShowImageView *headImageView;
    __weak IBOutlet UILabel *videoLabel;
    __weak IBOutlet UILabel *picLabel;
    __weak IBOutlet UILabel *shuoshuoLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    ViewRadius(shuoshuoLabel, 3);
    ViewRadius(picLabel, 3);
    ViewRadius(videoLabel, 3);
    self.selectionStyle = UITableViewCellSelectionStyleNone;
//    ViewRadius(headImageView, headImageView.frame.size.width/2);
    [headImageView ShowImageWithUrlStr:[NFUserEntity shareInstance].smallpicpath completion:nil];
    // Initialization code
}

- (void)reloadImage
{
//    [headImageView ShowImageWithUrlStr:[NFUserEntity shareInstance].mineHeadView completion:nil];
    [headImageView ShowImageWithUrlStr:[NFUserEntity shareInstance].mineHeadView placeHoldName:defaultHeadImaghe completion:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
