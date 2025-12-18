//
//  NewHomeParser.h
//  nationalFitness
//
//  Created by 童杰 on 2017/2/25.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "NFBaseParser.h"
#import "MessageEntity.h"
#import "ZJContact.h"
#import "UIImageView+WebCache.h"
#import "NewHomeEntity.h"
#import "NFMyManage.h"
#import "YYModel.h"



@interface NewHomeParser : NFBaseParser

//联系人列表

+(id)contantListManagerParserr:(NSArray *)data;


//FriendAddListEntity
+(id)FriendAddListParser:(NSDictionary *)data;

//搜索好友解析
+(id)FriendSearchResultListParser:(NSDictionary *)data;


//所有 参与会话的群组
+(id)allGroupListManagerParserr:(NSArray *)data;







@end
