//
//  VagueSearchTableViewCell.h
//  nationalFitness
//
//  Created by joe on 2018/2/3.
//  Copyright © 2018年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageEntity.h"
#import "NFMyManage.h"


@interface VagueSearchTableViewCell : UITableViewCell



@property(nonatomic,strong)MessageChatEntity *chatEntity;

//headPicPath
@property(nonatomic,strong)NSString *headPicPath;


@end
