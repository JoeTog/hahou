//
//  MessageChatListTableViewCell.h
//  nationalFitness
//
//  Created by Joe on 2017/6/30.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageEntity.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Addtions.h"


@interface MessageChatListTableViewCell : UITableViewCell



@property (nonatomic, strong) MessageChatListEntity *chatListEntity;


@property (weak, nonatomic) IBOutlet UILabel *unReadMessageCount;

//最后一条消息
@property (weak, nonatomic) IBOutlet UILabel *MessageLabel;



@end
