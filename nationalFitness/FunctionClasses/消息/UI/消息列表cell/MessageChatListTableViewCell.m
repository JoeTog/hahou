//
//  MessageChatListTableViewCell.m
//  nationalFitness
//
//  Created by Joe on 2017/6/30.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "MessageChatListTableViewCell.h"
#import "NFbaseViewController.h"
#import "UIView+Badge.h"

#import "NFShowImageView.h"



@implementation MessageChatListTableViewCell{
    
    
    __weak IBOutlet NFShowImageView *headImageView;
    
    
    //对方名称
    __weak IBOutlet UILabel *titleLabel;
    //最后一条消息
    
    //时间
    __weak IBOutlet UILabel *timeLabel;
    //未读数量
    __weak IBOutlet NSLayoutConstraint *aiteWidthConstant;
    
    __weak IBOutlet UILabel *aitelabel;
    
    
    
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    titleLabel.textColor = [UIColor colorMainTextColor];
    self.MessageLabel.textColor = [UIColor colorMainSecTextColor];
    timeLabel.textColor = [UIColor colorMainThirdTextColor];
    
    self.unReadMessageCount.backgroundColor = [UIColor redColor];
    self.unReadMessageCount.textColor = [UIColor whiteColor];
    ViewRadius(self.unReadMessageCount, self.unReadMessageCount.frame.size.height/2);//未读远角
//    ViewRadius(headImageView, headImageView.frame.size.width/2);
    ViewRadius(headImageView, 5);//头像圆角
    titleLabel.font = [UIFont fontMainText];
    
}


-(void)setChatListEntity:(MessageChatListEntity *)chatListEntity{
    if (!chatListEntity.IsSingleChat) {
//        ViewBorderRadius(headImageView, 3, 1, [UIColor colorThemeColor]);
        ViewBorderRadius(headImageView, 3, 1.5, [UIColor whiteColor]);
        
    }
    //会话头像
    if (![chatListEntity.headPicpath containsString:[NFUserEntity shareInstance].HeadPicpathAppendingString]) {
        if (!chatListEntity.IsSingleChat) {
//            [headImageView ShowImageWithUrlStr:[NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,chatListEntity.headPicpath] placeHoldName:@"会话列表群组默认图" completion:^(BOOL success, UIImage *image) {
            
//            }];
            if([chatListEntity.headPicpath containsString:@"http"]){
                chatListEntity.headPicpath = [chatListEntity.headPicpath stringByReplacingOccurrencesOfString:@"http://121.43.116.159:7999/web_file/Public/uploads/" withString:@""];
            }
            [headImageView ShowImageWithUrlStr:[NSString stringWithFormat:@"%@%@",@"http://121.43.116.159:7999/web_file/Public/uploads/",chatListEntity.headPicpath] placeHoldName:@"会话列表群组默认图" completion:^(BOOL success, UIImage *image) {
            }];
            
        }else{
            if(chatListEntity.headPicpath.length > 0 || [chatListEntity.conversationId integerValue] > 0){
                if([chatListEntity.headPicpath containsString:@"http"]){//本身含有http
                    [headImageView ShowImageWithUrlStr:chatListEntity.headPicpath placeHoldName:defaultHeadImaghe completion:^(BOOL success, UIImage *image) {
                    }];
                }else{
                    [headImageView ShowImageWithUrlStr:[NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,chatListEntity.headPicpath] placeHoldName:defaultHeadImaghe completion:^(BOOL success, UIImage *image) {
                    }];
                }
                
            }else{
                if([chatListEntity.conversationId isEqualToString:@"00"]){
                    //小助手
                    [headImageView ShowImageWithUrlStr:@"多信logo" placeHoldName:defaultHeadImaghe completion:^(BOOL success, UIImage *image) {
                    }];
                }else{
                    //系统通知头像
                    [headImageView ShowImageWithUrlStr:@"系统通知" placeHoldName:defaultHeadImaghe completion:^(BOOL success, UIImage *image) {
                    }];
                }
                
            }
            
        }
    }else{
        if(!chatListEntity.IsSingleChat) {
//            [headImageView ShowImageWithUrlStr:chatListEntity.headPicpath placeHoldName:@"会话列表群组默认图" completion:^(BOOL success, UIImage *image) {
//            }];
            chatListEntity.headPicpath = [chatListEntity.headPicpath stringByReplacingOccurrencesOfString:[NFUserEntity shareInstance].HeadPicpathAppendingString withString:@"http://121.43.116.159:7999/web_file/Public/uploads/"];
            [headImageView ShowImageWithUrlStr:chatListEntity.headPicpath placeHoldName:@"会话列表群组默认图" completion:^(BOOL success, UIImage *image) {
            }];
        }else{
            [headImageView ShowImageWithUrlStr:chatListEntity.headPicpath placeHoldName:defaultHeadImaghe completion:^(BOOL success, UIImage *image) {
            }];
        }
        
    }
    NSMutableArray *groupHeadPicArr = [NSMutableArray new];
//    if (chatListEntity.groupFirstHeadPath.length > 0) {
//        if ([chatListEntity.groupFirstHeadPath containsString:@"head_man"]) {
//            [groupHeadPicArr addObject:[UIImage imageNamed:chatListEntity.groupFirstHeadPath]];
//        }else{
//            [groupHeadPicArr addObject:[NSURL URLWithString:chatListEntity.groupFirstHeadPath]];
//        }
//        //群组会话头像
//        headImageView.image = [UIImage groupIconWithURLArray:[NSArray arrayWithArray:groupHeadPicArr] bgColor:[UIColor groupTableViewBackgroundColor]];
//    }
    if (chatListEntity.nickName.length > 0) {
        titleLabel.text = chatListEntity.nickName;
    }else{
        titleLabel.text = chatListEntity.receive_user_name;
    }
    
    self.MessageLabel.text = chatListEntity.last_send_message;
    
    NSRange rangee = [chatListEntity.last_send_message rangeOfString:@"@"];
    if (rangee.length > 0) {
        NSRange rangeeee = [chatListEntity.last_send_message rangeOfString:[NFUserEntity shareInstance].nickName];
        NSRange rangeeeeeee = [chatListEntity.last_send_message rangeOfString:@"所有人"];
        if ((rangee.location < rangeeee.location || rangee.location < rangeeeeeee.location) && (rangeeee.length > 0 || rangeeeeeee.length > 0)) {
            //单例
            NSInteger aiteValue = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"qunzuAite%@",chatListEntity.conversationId]];
            //当记录 被艾特的消息id 小于最后一条消息的@，则显示 红字
            if ([chatListEntity.last_message_id integerValue] > aiteValue) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"qunzuAiteBool%@",chatListEntity.conversationId]];
                [[NSUserDefaults standardUserDefaults] setInteger:[chatListEntity.last_message_id integerValue] forKey:[NSString stringWithFormat:@"qunzuAite%@",chatListEntity.conversationId]];
            }
        }
    }
    BOOL isFirst = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"qunzuAiteBool%@",chatListEntity.conversationId]];
    if (isFirst && !chatListEntity.IsSingleChat) {
        aiteWidthConstant.constant = 55;
    }else{
        aiteWidthConstant.constant = 0.1;
        aitelabel.textColor = [UIColor clearColor];
    }
    
    if ([chatListEntity.update_time containsString:@"1970"] || chatListEntity.update_time.length == 0 || chatListEntity.update_time.length > 15 || chatListEntity.last_send_message.length == 0) {
        timeLabel.text = @"";
        if([chatListEntity.update_time containsString:@"20"]){
            timeLabel.text = chatListEntity.update_time;
        }
    }else{
        timeLabel.text = chatListEntity.update_time;
    }
//    chatListEntity.unread_message_count = @"4";
    if ([chatListEntity.unread_message_count integerValue] > 0) {
        //当大于99条消息，只显示99条
        NSString *unread_message_count = [NSString new];
        if ([chatListEntity.unread_message_count integerValue] >99) {
            unread_message_count = @"99";
        }else{
            unread_message_count = chatListEntity.unread_message_count;
        }
        self.unReadMessageCount.hidden = NO;
        self.unReadMessageCount.text = unread_message_count;
//        [headImageView yee_MakeBadgeText:unread_message_count textColor:[UIColor whiteColor] backColor:[UIColor redColor] Font:[UIFont fontSectionBadge]];
        if(!chatListEntity.IsDisturb){
        }else{
            //免打扰
            self.unReadMessageCount.backgroundColor = UIColorFromRGB(0xd4d4d4);
            self.unReadMessageCount.textColor = [UIColor whiteColor];
            ViewRadius(self.unReadMessageCount, self.unReadMessageCount.frame.size.height/2);//未读远角
        }
    }else{
        self.unReadMessageCount.hidden = YES;
    }
    //如果为顶置
    if (chatListEntity.IsUpSet) {
        self.backgroundColor = UIColorFromRGB(0xfffcf2);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
