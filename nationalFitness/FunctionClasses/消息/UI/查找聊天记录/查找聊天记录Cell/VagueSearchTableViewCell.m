
//
//  VagueSearchTableViewCell.m
//  nationalFitness
//
//  Created by joe on 2018/2/3.
//  Copyright © 2018年 chenglong. All rights reserved.
//

#import "VagueSearchTableViewCell.h"
#import "NFShowImageView.h"

@implementation VagueSearchTableViewCell{
    
    //头像
    __weak IBOutlet NFShowImageView *headPicImageV;
    
    
    //名字
    __weak IBOutlet UILabel *nameLabel;
    
    
    //内容
    __weak IBOutlet UILabel *contentLabel;
    
    
    //时间
    __weak IBOutlet UILabel *timeLabel;
    
    
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    
    
    
}

//单聊设置头像
-(void)setHeadPicPath:(NSString *)headPicPath{
    [headPicImageV ShowImageWithUrlStr:headPicPath placeHoldName:defaultHeadImaghe completion:nil];
}


-(void)setChatEntity:(MessageChatEntity *)chatEntity{
    
    [headPicImageV ShowImageWithUrlStr:chatEntity.headPicPath placeHoldName:defaultHeadImaghe completion:nil];
    nameLabel.text = chatEntity.nickName;
    contentLabel.text = chatEntity.message_content;
    NSString *time =  [NFMyManage getTimeStringWithNum:chatEntity.localReceiveTime ToFormat:@"yyyy-MM-dd HH:mm"];
    timeLabel.text = time;
    
}











- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
