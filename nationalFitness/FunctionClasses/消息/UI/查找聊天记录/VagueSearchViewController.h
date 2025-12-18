//
//  VagueSearchViewController.h
//  nationalFitness
//
//  Created by joe on 2018/2/3.
//  Copyright © 2018年 chenglong. All rights reserved.
//

#import "NFbaseViewController.h"

#import "VagueSearchTableViewCell.h"
#import "MessageChatViewController.h"
#import "GroupChatViewController.h"


#define groupMacroName [NSString stringWithFormat:@"qunzu%@",self.groupCreateSEntity.groupId]


@interface VagueSearchViewController : NFbaseViewController


@property (nonatomic, strong) FMDBService  *fmdbServicee;






//1单聊 2群聊
@property(nonatomic,strong)NSString *fromType;

//会话id【消息历史表名】 群组需要加上qunzu
@property(nonatomic,strong)NSString *conversationId;


//单人聊天实体
@property (nonatomic, strong) ZJContact *singleContactEntity;

//群聊实体
@property(nonatomic,strong)GroupCreateSuccessEntity *groupCreateSEntity;







@end
