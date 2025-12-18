//
//  FMDBService.m
//  nationalFitness
//
//  Created by Joe on 2017/9/1.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "FMDBService.h"
#import "JQFMDB.h"

//缓存群组成员
#define qunDetail [NSString stringWithFormat:@"qunDetail%@",self.chatCreateSuccessEntity.groupId]


@implementation FMDBService{
    
    
    JQFMDB *jqFmdb;
    
    
    
}

//懒加载
-(GroupCreateSuccessEntity *)chatCreateSuccessEntity{
    if (!_chatCreateSuccessEntity) {
        _chatCreateSuccessEntity = [[GroupCreateSuccessEntity alloc] init];
    }
    return _chatCreateSuccessEntity;
}


-(MessageChatListEntity *)messageChatListEntity{
    if (!_messageChatListEntity) {
        _messageChatListEntity = [[MessageChatListEntity alloc] init];
    }
    return _messageChatListEntity;
}


-(NFMyManage *)myManage{
    if (!_myManage) {
        _myManage = [[NFMyManage alloc] init];
    }
    return _myManage;
}


//根据字典转 会话列表实体MessageChatListEntity
-(MessageChatListEntity *)returnMessageChatListEntityFromDict:(NSDictionary *)dict{
    MessageChatListEntity *messageChatListEntity = [MessageChatListEntity new];
    messageChatListEntity.IsUpSet = NO;
    messageChatListEntity.IsSingleChat = YES;
    messageChatListEntity.conversationId = [[dict objectForKey:@"userId"] description];
    messageChatListEntity.last_send_message = [dict objectForKey:@"strContent"];
    if (![[dict objectForKey:@"update_time"] isEqualToString:@""]) {
        NSString *updateTime = [dict objectForKey:@"update_time"];
        updateTime = [NFMyManage timestampSwitchTime:[updateTime integerValue]];
        messageChatListEntity.update_time = updateTime;
        messageChatListEntity.originTimeString = [[dict objectForKey:@"update_time"] description];
    }else{
        messageChatListEntity.update_time = [NFMyManage getCurrentTimeStamp];
        messageChatListEntity.originTimeString = [NFMyManage getCurrentTimeStamp];
    }
    messageChatListEntity.receive_user_name = [[dict objectForKey:@"userName"] description];
    messageChatListEntity.receive_user_id = [[dict objectForKey:@"userId"] description];
    //缓存会话列表
    return messageChatListEntity;
    
}


//发送单聊消息 缓存到会话列表 【当有groupId时候 则为缓存、变更群聊绘画】
-(void)cacheChatListWithZJContact:(ZJContact *)contact AndDic:(NSDictionary *)dict{
        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
        //缓存会话列表
        MessageChatListEntity *messageChatListEntity = [MessageChatListEntity new];
        messageChatListEntity.IsUpSet = NO;
        if (contact.groupId.length > 0) {
            messageChatListEntity.IsSingleChat = NO;
        }else{
            messageChatListEntity.IsSingleChat = YES;
        }
        messageChatListEntity.conversationId = contact.friend_userid;
        messageChatListEntity.headPicpath = contact.iconUrl;
        messageChatListEntity.last_message_id = [[dict objectForKey:@"last_message_id"] description];
        NSString *currentTime = [NFMyManage getCurrentTimeStamp];
//        messageChatListEntity.update_time = [NFMyManage timestampSwitchTime:[currentTime integerValue]];
    messageChatListEntity.nickName = contact.friend_nickname;
    if (messageChatListEntity.nickName.length == 0) {
        messageChatListEntity.nickName = [[dict objectForKey:@"nickName"] description];//
        if (messageChatListEntity.nickName.length == 0) {
            messageChatListEntity.nickName = [[dict objectForKey:@"userName"] description];
        }
    }
        if ([dict objectForKey:@"strContent"]) {
            messageChatListEntity.last_send_message = [dict objectForKey:@"strContent"];
        }else if ([dict objectForKey:@"picture"]){
            messageChatListEntity.last_send_message = @"[图片]";
        }else if ([dict objectForKey:@"audio"]){
            messageChatListEntity.last_send_message = @"[语音]";
        }else{
            if ([dict objectForKey:@"voice"]) {
                messageChatListEntity.last_send_message = @"[语音]";
            }else if ([dict objectForKey:@"image"]){
                messageChatListEntity.last_send_message = @"[图片]";
            }else{
//                messageChatListEntity.last_send_message = @"[未知消息类型]";
                messageChatListEntity.last_send_message = @"[系统消息]";
            }
        }
    ////消息类型 0文字 1图片 2语音 3红包  4 名片    5红包领取记录
    if([[[dict objectForKey:@"type"] description] isEqualToString:@"3"]){
        messageChatListEntity.msgType = @"red";
        messageChatListEntity.last_send_message = [[[dict objectForKey:@"strContent"] description] containsString:@"[多信红包]"]?[dict objectForKey:@"strContent"]:[NSString stringWithFormat:@"[多信红包] %@",[dict objectForKey:@"strContent"]];
    }else if([[[dict objectForKey:@"type"] description] isEqualToString:@"4"]){
        messageChatListEntity.msgType = @"card";
        messageChatListEntity.last_send_message = @"[名片消息]";
    }
    
    NSString *updateTime = [[dict objectForKey:@"update_time"] description];
        if (updateTime.length != 0) {
            NSString *updateTime = [dict objectForKey:@"update_time"];
            messageChatListEntity.update_time = [NFMyManage timestampSwitchTime:[updateTime integerValue]];;
            messageChatListEntity.originTimeString = [[dict objectForKey:@"update_time"] description];
            messageChatListEntity.last_send_time = [[dict objectForKey:@"update_time"] description];
        }else{
            
            messageChatListEntity.update_time = [NFMyManage timestampSwitchTime:[currentTime integerValue]];
            messageChatListEntity.originTimeString = currentTime;
            messageChatListEntity.last_send_time = currentTime;
        }
        messageChatListEntity.receive_user_name = contact.friend_username;//用户昵称
        messageChatListEntity.nickName = contact.friend_nickname;//用户昵称
        messageChatListEntity.receive_user_id = contact.friend_userid;
    __block NSArray *arrss = [NSArray new];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        arrss = [strongSelf ->jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:[NSString stringWithFormat:@"where %@ = '%@' and %@ = '%@'",@"conversationId",messageChatListEntity.conversationId,@"IsSingleChat",contact.groupId.length > 0?@"0":@"1"]];//contact.groupId.length > 0 大于0 说明为群聊
    }];
    if (arrss.count == 1) {
        MessageChatListEntity *entity =[arrss firstObject];
        //当需要缓存的最后一条消息和外面会话列表一样的话 则return
        if ([[entity.last_send_message description] isEqualToString:[messageChatListEntity.last_send_message description]]) {
            return;
        }
        messageChatListEntity.IsUpSet = entity.IsUpSet;
        [self.myManage changeFMDBData:messageChatListEntity KeyWordKey:@"conversationId" KeyWordValue:messageChatListEntity.conversationId FMDBID:@"tongxun.sqlite" secondKeyWordKey:@"IsSingleChat" secondKeyWordValue:contact.groupId.length > 0?@"0":@"1" TableName:@"huihualiebiao"];
    }else {
        MessageChatListEntity *entity =[arrss firstObject];
        messageChatListEntity.IsUpSet = entity.IsUpSet;
        //当有重复会话列表数据 或 没有会话列表
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
             [strongSelf ->jqFmdb jq_deleteTable:@"huihualiebiao" whereFormat:[NSString stringWithFormat:@"where %@ = '%@' and %@ = '%@'",@"conversationId",messageChatListEntity.conversationId,@"IsSingleChat",contact.groupId.length > 0?@"0":@"1"]];
        }];
        
        //删除完再新建
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            if (messageChatListEntity.conversationId.length>0 && messageChatListEntity.receive_user_name.length > 0) {
                BOOL ret = [strongSelf ->jqFmdb jq_insertTable:@"huihualiebiao" dicOrModel:messageChatListEntity];
                if (ret) {
                    NSLog(@"");
                }
            }
        }];
    }
//        NSArray *arsrr = [jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:@""];
}

//缓存到会话列表 用的创建群组成功实体 GroupCreateSuccessEntity
-(void)cacheChatGroupCreateList:(GroupCreateSuccessEntity *)entity{
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    self.chatCreateSuccessEntity = entity;
    self.messageChatListEntity.IsUpSet = NO;
    self.messageChatListEntity.IsSingleChat = NO;
    self.messageChatListEntity.conversationId = self.chatCreateSuccessEntity.groupId;
    self.messageChatListEntity.headPicpath = entity.groupHeadPic;
    //        self.messageChatListEntity.user_id = self.chatCreateSuccessEntity.groupId;
    //        self.messageChatListEntity.user_name = self.chatCreateSuccessEntity.groupId;
    self.messageChatListEntity.last_send_time = [NFMyManage getCurrentTimeStamp];
    self.messageChatListEntity.last_send_message = @"";
    
    self.messageChatListEntity.unread_message_count = @"0";
    self.messageChatListEntity.update_time = [NFMyManage timestampSwitchTime:[entity.join_time integerValue]];
    NSString *currentTime =  [NFMyManage getCurrentTimeStamp];
    self.messageChatListEntity.originTimeString = currentTime;
    self.messageChatListEntity.last_send_time = currentTime;
    self.messageChatListEntity.receive_user_name = self.chatCreateSuccessEntity.groupName;
    
    __block NSArray *arrss = [NSArray new];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        arrss = [strongSelf ->jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:[NSString stringWithFormat:@"where %@ = '%@' and %@ = '%@'",@"conversationId",strongSelf.messageChatListEntity.conversationId,@"IsSingleChat",@"0"]];
    }];
    if (arrss.count == 1) {
        [self.myManage changeFMDBData:self.messageChatListEntity KeyWordKey:@"conversationId" KeyWordValue:self.messageChatListEntity.conversationId FMDBID:@"tongxun.sqlite" secondKeyWordKey:@"IsSingleChat" secondKeyWordValue:@"0" TableName:@"huihualiebiao"];
    }else {
        //当有重复会话列表数据 或 没有会话列表
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
             [strongSelf ->jqFmdb jq_deleteTable:@"huihualiebiao" whereFormat:[NSString stringWithFormat:@"where %@ = '%@' and %@ = '%@'",@"conversationId",self.messageChatListEntity.conversationId,@"IsSingleChat",@"0"]];
        }];
        
        //删除完再新建
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            if (strongSelf.messageChatListEntity.conversationId.length>0 && strongSelf.messageChatListEntity.receive_user_name.length > 0) {
                BOOL ret = [strongSelf ->jqFmdb jq_insertTable:@"huihualiebiao" dicOrModel:strongSelf.messageChatListEntity];
                if (ret) {
                    NSLog(@"");
                }
            }
        }];
    }
    
//    NSArray *arsrr = [jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:@""];
    NSLog(@"");
}

//根据 groupid 取出群组详情、成员缓存
-(NSArray *)getGroupDetailEntityAndMemberListWithGroupId:(NSString *)groupId{
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    //    groupId = [self.myManage NumToString:groupId];
    
//    NSArray *groupArdrs = [jqFmdb jq_lookupTable:@"groupDetailliebiao" dicOrModel:[GroupCreateSuccessEntity class] whereFormat:@""];
    
    //下面一般为一条数据
    __block NSArray *groupArrs = [NSArray new];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        groupArrs = [strongSelf ->jqFmdb jq_lookupTable:@"groupDetailliebiao" dicOrModel:[GroupCreateSuccessEntity class] whereFormat:@"where groupId = '%@'",groupId];
    }];
//    BOOL ret = [jqFmdb jq_insertTable:[NSString stringWithFormat:@"qunDetail%@",self.chatCreateSuccessEntity.groupId] dicOrModel:memberEntity];

    __block NSArray *memberArrs = [NSArray new];
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        memberArrs = [strongSelf ->jqFmdb jq_lookupTable:[NSString stringWithFormat:@"qunDetail%@",groupId] dicOrModel:[ZJContact class] whereFormat:@""];
    }];
    [self.groupDetailAndMemberArr removeAllObjects];
    if (groupArrs.count > 0) {
        [self.groupDetailAndMemberArr addObject:[groupArrs firstObject]];
    }else{
        [self.groupDetailAndMemberArr addObject:[GroupCreateSuccessEntity new]];
    }
    
    [self.groupDetailAndMemberArr addObject:memberArrs];
    
    return self.groupDetailAndMemberArr;
}

//groupDetailAndMemberArr
-(NSMutableArray *)groupDetailAndMemberArr{
    if (!_groupDetailAndMemberArr) {
        _groupDetailAndMemberArr = [[NSMutableArray alloc] init];
    }
    return _groupDetailAndMemberArr;
}

//缓存群组【@[群组成员]】
-(void)cacheGroupMemberWith:(ZJContact *)contact AndGroupId:(NSString *)groupid{
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    [jqFmdb jq_inDatabase:^{
        BOOL IsExist = [jqFmdb jq_isExistTable:[NSString stringWithFormat:@"groupmemberlist%@",groupid]];
        if (!IsExist) {
            [jqFmdb jq_createTable:[NSString stringWithFormat:@"groupmemberlist%@",groupid] dicOrModel:[ZJContact class]];
        }
        NSArray *groupMemberArr = [NSArray new];
        groupMemberArr = [jqFmdb jq_lookupTable:[NSString stringWithFormat:@"groupmemberlist%@",groupid] dicOrModel:[ZJContact class] whereFormat:@"where friend_userid = '%@'",contact.friend_userid];
        if (groupMemberArr.count == 0) {
            BOOL ret = [jqFmdb jq_insertTable:[NSString stringWithFormat:@"groupmemberlist%@",groupid] dicOrModel:contact];
            //NSArray *arr = [jqFmdb jq_lookupTable:[NSString stringWithFormat:@"qunDetail%@",groupid] dicOrModel:[ZJContact class] whereFormat:@""];
        }else if(groupMemberArr.count == 1){
            ZJContact *checkContact = [groupMemberArr firstObject];
            if(![checkContact.friend_username isEqualToString:contact.friend_username] || ![checkContact.friend_nickname isEqualToString:contact.friend_nickname] || (contact.friend_originalnickname && ![checkContact.friend_originalnickname isEqualToString:contact.friend_originalnickname]) || ![checkContact.iconUrl isEqualToString:contact.iconUrl] || ![checkContact.is_admin isEqualToString:contact.is_admin] || ![checkContact.is_creator isEqualToString:contact.is_creator] || (contact.friend_comment_name && ![checkContact.friend_comment_name isEqualToString:contact.friend_comment_name])){
                BOOL ret = [jqFmdb jq_updateTable:[NSString stringWithFormat:@"groupmemberlist%@",groupid] dicOrModel:contact whereFormat:@"where friend_userid = '%@'",contact.friend_userid];
            }
        }else if(groupMemberArr.count > 1){
            BOOL ret = [jqFmdb jq_deleteTable:[NSString stringWithFormat:@"groupmemberlist%@",groupid] whereFormat:@"where friend_userid = '%@'",contact.friend_userid];
            BOOL retSec = [jqFmdb jq_insertTable:[NSString stringWithFormat:@"groupmemberlist%@",groupid] dicOrModel:contact];
        }
    }];
    
    
}


//缓存群组详情 群详情【@[群组成员]】
-(void)cacheGroupDetail:(GroupCreateSuccessEntity *)groupEntity{
    self.chatCreateSuccessEntity = groupEntity;
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __weak typeof(self)weakSelf=self;
    //缓存群聊详情
    BOOL isNeedGroupCache = YES;
    //取缓存
    __block NSArray *groupArr = [NSArray new];
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        groupArr = [strongSelf ->jqFmdb jq_lookupTable:@"groupDetailliebiao" dicOrModel:[GroupCreateSuccessEntity class] whereFormat:@""];
    }];
    //遍历本地缓存
    for (GroupCreateSuccessEntity *groupEntity in groupArr) {
        //当缓存里面有改会话 则设置不需要插入缓存 更新即可
        if ([groupEntity.groupId isEqualToString:self.chatCreateSuccessEntity.groupId]) {
            isNeedGroupCache = NO;
            break;
        }
    }
    //如果为可插入 说明表里面没有该 群聊id 则insert 新建
    if (isNeedGroupCache) {
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            //                weakSelf.chatCreateSuccessEntity.groupAllUser = nil;
            BOOL ret = [strongSelf ->jqFmdb jq_insertTable:@"groupDetailliebiao" dicOrModel:strongSelf.chatCreateSuccessEntity];
            if (ret) {
                NSLog(@"");
            }
        }];
        __block BOOL IsExistYC = NO;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            IsExistYC = [strongSelf ->jqFmdb jq_isExistTable:[NSString stringWithFormat:@"qunDetail%@",self.chatCreateSuccessEntity.groupId]];
        }];
        if (!IsExistYC) {
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                 [strongSelf ->jqFmdb jq_createTable:[NSString stringWithFormat:@"qunDetail%@",strongSelf.chatCreateSuccessEntity.groupId] dicOrModel:[ZJContact class]];
            }];
        }
        
        //缓存群组成员
//        __block NSArray *nameArr = [NSArray new];
//        [jqFmdb jq_inDatabase:^{
//            __strong typeof(weakSelf)strongSelf=weakSelf;
//            nameArr = [strongSelf ->jqFmdb jq_columnNameArray:[NSString stringWithFormat:@"qunDetail%@",strongSelf.chatCreateSuccessEntity.groupId]];
//        }];
        [jqFmdb jq_inDatabase:^{
            //先删除群成员 再insert【防止油残留】
            __strong typeof(weakSelf)strongSelf=weakSelf;
            //                for (ZJContact *friendEntity in arrs) {
            BOOL ret = [strongSelf ->jqFmdb jq_deleteTable:[NSString stringWithFormat:@"qunDetail%@",strongSelf.chatCreateSuccessEntity.groupId] whereFormat:@""];
            
        }];
//        for (ZJContact *memberEntity in self.chatCreateSuccessEntity.groupAllUser) {
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                 [jqFmdb jq_insertTable:[NSString stringWithFormat:@"qunDetail%@",strongSelf.chatCreateSuccessEntity.groupId] dicOrModelArray:self.chatCreateSuccessEntity.groupAllUser];
            }];
//        }
    }else{
        __block NSArray *nameArr = [NSArray new];
        __weak typeof(self)weakSelf=self;
//        [jqFmdb jq_inDatabase:^{
//            __strong typeof(weakSelf)strongSelf=weakSelf;
//            nameArr = [strongSelf ->jqFmdb jq_columnNameArray:[NSString stringWithFormat:@"qunDetail%@",strongSelf.chatCreateSuccessEntity.groupId]];
//        }];
        //如果有会话历史，则更新 groupid
        //先删除该 groupid缓存的成员
        __block NSArray *arrs = [NSArray new];
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            arrs = [strongSelf ->jqFmdb jq_lookupTable:[NSString stringWithFormat:@"qunDetail%@",strongSelf.chatCreateSuccessEntity.groupId] dicOrModel:[ZJContact class] whereFormat:[NSString stringWithFormat:@""]];
        }];
        //当收到服务器返回的群组人数和本地不一样时 才进行先删除后insert
        if (self.chatCreateSuccessEntity.groupAllUser.count != arrs.count) {
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
//                for (ZJContact *friendEntity in arrs) {
                    BOOL ret = [strongSelf ->jqFmdb jq_deleteTable:[NSString stringWithFormat:@"qunDetail%@",strongSelf.chatCreateSuccessEntity.groupId] whereFormat:@""];
                    if (ret) {
                        NSLog(@"删除成功");
                    }
//                }
            }];
            //删除后缓存群组成员
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                [strongSelf ->jqFmdb jq_insertTable:[NSString stringWithFormat:@"qunDetail%@",strongSelf.chatCreateSuccessEntity.groupId] dicOrModelArray:strongSelf.chatCreateSuccessEntity.groupAllUser];
                
            }];
        }
        //缓存群组详情
        //        NSArray *asrrs = [jqFmdb jq_lookupTable:@"groupDetailliebiao" dicOrModel:[GroupCreateSuccessEntity class] whereFormat:[NSString stringWithFormat:@""]];
        [self.myManage changeFMDBData:weakSelf.chatCreateSuccessEntity KeyWordKey:@"groupId" KeyWordValue:weakSelf.chatCreateSuccessEntity.groupId FMDBID:@"tongxun.sqlite" TableName:@"groupDetailliebiao"];
        
        
    }
}

#pragma mark - 收到群组消息 更改会话列表群组缓存 【消息缓存在 didreceive代理中】
-(void)receiveGroupMessageChangeChatListCache:(NSDictionary *)resulyDict{
    //更改会话列表最后一条信息缓存 conversationId receive_user_name
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
//    NSArray *arrds = [jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:@""];
//    NSArray *arrs = [jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:[NSString stringWithFormat:@"where %@ = '%@' and %@ = '%@'",@"conversationId",[[resulyDict objectForKey:@"group_id"] description],@"receive_user_name",[[resulyDict objectForKey:@"group_name"] description]]];
    //IsSingleChat
    __block NSArray *arrss = [NSArray new];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        arrss = [strongSelf ->jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:[NSString stringWithFormat:@"where %@ = '%@' and %@ = '%@'",@"conversationId",[[resulyDict objectForKey:@"group_id"] description],@"IsSingleChat",@"0"]];
    }];
    if (arrss.count == 1) {
        //一般为一条数据
        MessageChatListEntity *chatListEntity = [arrss lastObject];
        if ([[resulyDict objectForKey:@"group_msg_type"] isEqualToString:@"normal"]) {
            chatListEntity.last_send_message = [[resulyDict objectForKey:@"group_msg_content"] description];
        }else if ([[resulyDict objectForKey:@"group_msg_type"] isEqualToString:@"image"]){
            chatListEntity.last_send_message = @"[图片]";
        }else if ([[resulyDict objectForKey:@"group_msg_type"] isEqualToString:@"audio"]){
            chatListEntity.last_send_message = @"[语音]";
        }else if ([[resulyDict objectForKey:@"group_msg_type"] isEqualToString:@"red"]){
            chatListEntity.last_send_message = [[resulyDict objectForKey:@"group_msg_content"] description];
        }else if ([[resulyDict objectForKey:@"group_msg_type"] isEqualToString:@"redRecord"]){
            chatListEntity.last_send_message = [[resulyDict objectForKey:@"group_msg_content"] description];
        }else{
//            chatListEntity.last_send_message = @"[未知消息类型]";
            chatListEntity.last_send_message = @"[系统消息]";
        }
        chatListEntity.last_message_id = [[resulyDict objectForKey:@"last_message_id"] description];
        if (![[[resulyDict objectForKey:@"group_msg_time"] description] isEqualToString:@""]) {
            int a = [[NFMyManage new] checkIsHaveNumAndLetter:[[resulyDict objectForKey:@"group_msg_time"] description]];
            if (a == 1) {
                chatListEntity.update_time = [[NFbaseViewController new] timestampSwitchTime:[[resulyDict objectForKey:@"group_msg_time"] integerValue]];
            }else{
                chatListEntity.update_time = @"";
            }
        }else{
            chatListEntity.update_time = @"";
        }
        if ([resulyDict objectForKey:@"photo"]) {
            if ([[resulyDict objectForKey:@"photo"] containsString:@"http"]) {
                chatListEntity.headPicpath = [[resulyDict objectForKey:@"photo"] description];
            }else{
                chatListEntity.headPicpath = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[[resulyDict objectForKey:@"photo"] description]];
            }
        }else{
            if ([[resulyDict objectForKey:@"photo"] containsString:@"http"]) {
                chatListEntity.headPicpath = [[resulyDict objectForKey:@"group_photo"] description];
            }else{
                chatListEntity.headPicpath = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[[resulyDict objectForKey:@"group_photo"] description]];
            }
        }
        chatListEntity.IsSingleChat = NO;
        chatListEntity.originTimeString = [[resulyDict objectForKey:@"group_msg_time"] description];
        chatListEntity.last_send_time = [[resulyDict objectForKey:@"group_msg_time"] description];
        NSString *currentTime = [NFMyManage getCurrentTimeStamp];
        if (chatListEntity.last_send_time.length == 0) {
            chatListEntity.originTimeString = currentTime;
            chatListEntity.last_send_time = currentTime;
            chatListEntity.update_time = [NFMyManage timestampSwitchTime:[currentTime integerValue]];
        }
        [self.myManage changeFMDBData:chatListEntity KeyWordKey:@"conversationId" KeyWordValue:[[resulyDict objectForKey:@"group_id"] description] FMDBID:@"tongxun.sqlite" secondKeyWordKey:@"IsSingleChat" secondKeyWordValue:@"0" TableName:@"huihualiebiao"];
    }else {
        //当有重复会话列表数据 或 为新建时
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            [strongSelf ->jqFmdb jq_deleteTable:@"huihualiebiao" whereFormat:[NSString stringWithFormat:@"where %@ = '%@' and %@ = '%@'",@"conversationId",[[resulyDict objectForKey:@"group_id"] description],@"IsSingleChat",@"0"]];
        }];
        
        //删除完再新建
        MessageChatListEntity *chatListEntity = [MessageChatListEntity new];
        chatListEntity.IsUpSet = NO;
        chatListEntity.IsSingleChat = NO;
        chatListEntity.conversationId = [[resulyDict objectForKey:@"group_id"] description];
        chatListEntity.last_send_message =[[resulyDict objectForKey:@"group_msg_content"] description];
        chatListEntity.last_message_id = [[resulyDict objectForKey:@"last_message_id"] description]?[resulyDict objectForKey:@"last_message_id"]:[[resulyDict objectForKey:@"group_msg_id"] description];
        if ([resulyDict objectForKey:@"photo"]) {
            if ([[resulyDict objectForKey:@"photo"] containsString:@"http"]) {
                chatListEntity.headPicpath = [[resulyDict objectForKey:@"photo"] description];
            }else{
                chatListEntity.headPicpath = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[[resulyDict objectForKey:@"photo"] description]];
            }
        }else{
            if ([[resulyDict objectForKey:@"photo"] containsString:@"http"]) {
                chatListEntity.headPicpath = [[resulyDict objectForKey:@"group_photo"] description];
            }else{
                chatListEntity.headPicpath = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[[resulyDict objectForKey:@"group_photo"] description]];
            }
        }
        chatListEntity.unread_message_count = @"0";
        //NSString *updateTime = [[resulyDict objectForKey:@"group_msg_time"] description];
        chatListEntity.originTimeString = [[resulyDict objectForKey:@"group_msg_time"] description];
        chatListEntity.last_send_time = [[resulyDict objectForKey:@"group_msg_time"] description];
        NSString *currentTime = [NFMyManage getCurrentTimeStamp];
        if (chatListEntity.last_send_time.length == 0) {
            chatListEntity.originTimeString = currentTime;
            chatListEntity.last_send_time = currentTime;
            chatListEntity.update_time = [NFMyManage timestampSwitchTime:[currentTime integerValue]];
        }
//        NSString *groupname = [NSString stringWithFormat:@""];
        chatListEntity.receive_user_name = [[resulyDict objectForKey:@"group_name"] description];
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            if (chatListEntity.conversationId.length>0 && chatListEntity.receive_user_name.length > 0) {
                [strongSelf ->jqFmdb jq_insertTable:@"huihualiebiao" dicOrModel:chatListEntity];
                
            }
        }];
        
    }
}

//MessageChatEntityToUUMessageFrame
#pragma mark - UUMessageFrame转MessageChatEntity
-(MessageChatEntity *)UUMessageFrameToMessageChatEntity:(UUMessageFrame *)messageFrame{
    MessageChatEntity *entity = [MessageChatEntity new];
    UUMessage *messagee = [UUMessage new];
    messagee = messageFrame.message;
    entity.chatId = messagee.chatId;
    entity.failStatus = messagee.failStatus;
    entity.headPicPath = messagee.strIcon;
    entity.user_id = messagee.userId;
    entity.user_name = messagee.userName;
    entity.nickName = messagee.nickName;
    entity.originalNickName = messagee.originalNickName;
    //    entity.receive_user_name = messagee.userName;//这个是自己
    entity.message_content = messagee.strContent;
    entity.message_read_time = messagee.strTime;
    entity.localReceiveTime = messagee.localReceiveTime;
    entity.localReceiveTimeString = messagee.localReceiveTimeString;
    //貌似没用下面
    entity.yuehouYinCang = messagee.yuehouYinCang;
    //    entity.guanjiShanChu = messagee.guanjiShanChu;
    entity.create_time = messagee.strTime;
    entity.create_time_head = messagee.strTimeHeader;
    if (messagee.voice) {
        entity.voiceData = messagee.voice;
    }
    if (messagee.strVoiceTime) {
        entity.strVoiceTime = messagee.strVoiceTime;
    }
    if (messagee.pictureUrl) {
        //        entity.pictureData = UIImagePNGRepresentation(messagee.picture);
        entity.pictureUrl = messagee.pictureUrl;
        entity.pictureScale = messagee.pictureScale;
        entity.fileId = messagee.fileId;
        entity.message_content = @"[图片]";
    }else if (messageFrame.message.type == UUMessageTypeVoice){
        entity.message_content = @"[语音]";
    }
    if (messageFrame.message.invitor.length > 0) {
        entity.invitor = messageFrame.message.invitor;
        entity.localReceiveTime = messageFrame.message.localReceiveTime;
        entity.localReceiveTimeString = messageFrame.message.localReceiveTimeString;
        entity.pulledMemberString = messageFrame.message.pulledMemberString;
        entity.pullType = messageFrame.message.pullType;
    }
    if (messagee.type == 0) {
        entity.type = @"0";
    }else if (messagee.type == 1){
        entity.type = @"1";
        entity.msgType = @"image";
    }else if (messagee.type == 2){
        entity.type = @"2";
        entity.msgType = @"audio";
    }else if (messagee.type == 3){
        //红包
        entity.type = @"3";
        entity.redpacketString = messagee.redpacketString;
        entity.redIsTouched = messagee.redIsTouched;
        entity.msgType = @"red";
//                entity.redPrice = messagee.priceAccount;
//                entity.redCount = messagee.redCount;
    }else if (messagee.type == 4){
        //名片
        entity.type = @"4";
        entity.message_content = messageFrame.message.strContent;
        entity.fileId = [NSString stringWithFormat:@"%@",messageFrame.message.fileId];//头像
        entity.strVoiceTime = messageFrame.message.strVoiceTime;//语音时间存的是名片用户名
        entity.pictureUrl = messageFrame.message.pictureUrl;//图片地址存的是名片昵称
        entity.redpacketString = messageFrame.message.strId;
        entity.msgType = @"card";
        //
    }else if (messagee.type == 5 && messagee.redpacketString.length == 0){
        //领取记录
        entity.type = @"5";
        entity.pulledMemberString = messageFrame.message.pulledMemberString;
    }else if (messagee.type == 6){
            //转账
            entity.type = @"6";
            entity.redpacketString = messagee.redpacketString;
            entity.msgType = @"transfer";
            entity.headPicPath = messagee.priceAccount;
    //                entity.redPrice = messagee.priceAccount;
    //                entity.redCount = messagee.redCount;
    }else if (messagee.type == 5 && messagee.redpacketString.length > 0){
        //转账领取记录
        entity.type = @"5";
        entity.pulledMemberString = messageFrame.message.pulledMemberString;
        entity.redpacketString = messagee.redpacketString;
        //entity.msgType = @"transfer";
        entity.headPicPath = messagee.priceAccount;
    }else if (messagee.type == 7 && messagee.redpacketString.length == 0){
        //系统消息
        entity.type = @"7";
        entity.pulledMemberString = messageFrame.message.pulledMemberString;
    }
    entity.isSelf = messagee.from == UUMessageFromMe?@"0":@"1";
    
    
    return entity;
}

#pragma mark - 根据收到的单聊dict 缓存单聊消息到本地 收到web端消息
-(void)addSingleSpecifiedItem:(NSDictionary *)dic{
    UUMessageFrame *messageFrame = [[UUMessageFrame alloc]init];
    UUMessage *message = [[UUMessage alloc] init];
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    NSString *URLStr = @"http://img0.bdstatic.com/img/image/shouye/xinshouye/mingxing16.jpg";
    URLStr = @"";
    [dataDic setObject:@1 forKey:@"from"];
    [dataDic setObject:[[NSDate date] description] forKey:@"strTime"];
    if ([dic objectForKey:@"userName"]) {
        [dataDic setObject:[dic objectForKey:@"userName"] forKey:@"userName"];
    }
    if ([dic objectForKey:@"strIcon"]) {
        [dataDic setObject:URLStr forKey:@"strIcon"];
    }
    //设置消息内容数据
    [message setWithDict:dataDic];
//    [message minuteOffSetStart:previousTime end:dataDic[@"strTime"]];
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSTimeInterval interval = [currentDate timeIntervalSince1970];
    message.localReceiveTime = interval;
    NSInteger time = interval;
    message.localReceiveTimeString = [NSString stringWithFormat:@"%ld",time];
    message.strTime = [[NFbaseViewController new] timestampSwitchTime:interval anddFormatter:@"HH:mm"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:interval];
    if (![confromTimesp isThisYear]) {
        message.strTimeHeader = [[NFbaseViewController new] timestampSwitchTime:interval anddFormatter:@"YYYY年MM月dd日"];
    }else{
        message.strTimeHeader = [[NFbaseViewController new] timestampSwitchTime:interval anddFormatter:@"MM月dd日"];
    }
    message.chatId = dataDic[@"chatId"];//当自己发的消息 这里没有
    [messageFrame setMessage:message];
    MessageChatEntity *entity = [self UUMessageFrameToMessageChatEntity:messageFrame];
    entity.IsSingleChat = YES;
    entity.failStatus = @"0";
    if(![entity.type isEqualToString:@"4"]){
        entity.redpacketString = @"";
    }
    
    __weak typeof(self)weakSelf=self;
    
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        NSLog(@"strongSelf ->");
        BOOL rett = [strongSelf ->jqFmdb jq_insertTable:[dic objectForKey:@"userId"] dicOrModel:entity];
        if (!rett) {
            [SVProgressHUD showInfoWithStatus:@"缓存消息失败"];
            return;
        }
        //        NSArray *arr = [weakSelf showHistoryData];
    }];
    
    
    
}









#pragma mark - FMDB
#pragma mark - 更改数据库数据
-(void)changeFMDBData:(id)entity KeyWordKey:(NSString *)key KeyWordValue:(NSString *)keyValue FMDBID:(NSString *)fmdbId TableName:(NSString *)tableName{
    //    BOOL ret = [jqFmdb jq_insertTable:self.singleEntity.receive_user_name dicOrModel:entity];
    jqFmdb = [JQFMDB shareDatabase:fmdbId];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        BOOL rett = [strongSelf ->jqFmdb jq_updateTable:tableName dicOrModel:entity whereFormat:[NSString stringWithFormat:@"where %@ = '%@'",key,keyValue]];
        if (rett) {
            NSLog(@"更新success");
        }
    }];
}

#pragma mark - 更改数据库数据 两个条件
-(void)changeFMDBData:(id)entity KeyWordKey:(NSString *)key KeyWordValue:(NSString *)keyValue FMDBID:(NSString *)fmdbId secondKeyWordKey:(NSString *)secondKey secondKeyWordValue:(NSString *)secondKeyValue TableName:(NSString *)tableName{
    //    BOOL ret = [jqFmdb jq_insertTable:self.singleEntity.receive_user_name dicOrModel:entity];
    jqFmdb = [JQFMDB shareDatabase:fmdbId];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        BOOL rett = [strongSelf ->jqFmdb jq_updateTable:tableName dicOrModel:entity whereFormat:[NSString stringWithFormat:@"where %@ = '%@' and %@ = '%@'",key,keyValue,secondKey,secondKeyValue]];
        if (rett) {
            NSLog(@"更新success");
        }
    }];
}

#pragma mark - 根据会话列表群组会话的两个参数将未读设置为0
-(void)ConversationListUnReadSetZeroWithGroupId:(NSString *)groupId AndGroupName:(NSString *)groupName{
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __block NSArray *arrs = [NSArray new];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        arrs = [strongSelf ->jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:[NSString stringWithFormat:@"where %@ = '%@' and %@ = '%@'",@"conversationId",groupId,@"IsSingleChat",@"0"]];
    }];
    MessageChatListEntity *entity = [arrs lastObject];
    entity.unread_message_count = @"0";
    [[NFMyManage new] changeFMDBData:entity KeyWordKey:@"conversationId" KeyWordValue:groupId FMDBID:@"tongxun.sqlite" secondKeyWordKey:@"IsSingleChat" secondKeyWordValue:@"0" TableName:@"huihualiebiao"];
    
}

#pragma mark -  获取联系人列表
-(NSArray *)getLianxirenList{
    //取缓存中的联系人列表
    __block NSMutableArray *contacts = [NSMutableArray new];
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        contacts = [NSMutableArray arrayWithArray:[strongSelf ->jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact class] whereFormat:@""]];
    }];
    
    return contacts;
}

#pragma mark -  传入 ZJContact 传出 是否有备注的 ZJContact
-(ZJContact *)checkContactIsHaveCommmentname:(ZJContact *)outContact{
    //取缓存中的联系人列表
    __block NSMutableArray *contacts = [NSMutableArray new];
    __block ZJContact *contacttt = [ZJContact new];
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        contacts = [NSMutableArray arrayWithArray:[strongSelf ->jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact class] whereFormat:@""]];
        for (ZJContact *contact in contacts) {
            if ([contact.friend_userid isEqualToString:outContact.friend_userid]) {
                if (contact.friend_comment_name && contact.friend_comment_name.length > 0) {
                    outContact.friend_originalnickname = contact.friend_originalnickname;
                    outContact.friend_nickname = contact.friend_nickname;
                    outContact.friend_comment_name = contact.friend_comment_name;
                }
                break;
            }
        }
    }];
    
    return outContact;
}


#pragma mark - 缓存ZJContact联系人到 联系人缓存
-(void)cacheZJContactListWithArr:(NSArray *)ZJContactArr{
    //取缓存中的联系人列表
    __block NSMutableArray *contacts = [NSMutableArray new];
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        contacts = [NSMutableArray arrayWithArray:[strongSelf ->jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact class] whereFormat:@""]];
    }];
    
    if(contacts.count > ZJContactArr.count){
        [jqFmdb jq_inDatabase:^{
            BOOL rett = [jqFmdb jq_deleteAllDataFromTable:@"lianxirenliebiao"];
            if(rett){
                NSLog(@"");
            }
        }];
    }
    
    for (ZJContact *friendEntity in ZJContactArr) {
        __block NSArray *existContactArr = [NSArray new];
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            existContactArr = [strongSelf ->jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact class] whereFormat:@"where friend_userid = '%@'",friendEntity.friend_userid];
        }];
        if (existContactArr.count > 1) {
            ZJContact *existContact = [existContactArr firstObject];
            friendEntity.IsShieldDynamic = existContact.IsShieldDynamic;
            friendEntity.IsShield = existContact.IsShield;
            __block BOOL ret;
            __weak typeof(self)weakSelf=self;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                BOOL ret = [strongSelf ->jqFmdb jq_deleteTable:@"lianxirenliebiao" whereFormat:@"where friend_userid = '%@'",friendEntity.friend_userid];
                if (ret) {
                    //先删除 再insert
                     [strongSelf ->jqFmdb jq_insertTable:@"lianxirenliebiao" dicOrModel:friendEntity];
                }
            }];
        }else if (existContactArr.count == 1){
            ZJContact *existContact = [existContactArr firstObject];
            friendEntity.IsShieldDynamic = existContact.IsShieldDynamic;
            friendEntity.IsShield = existContact.IsShield;
            __block BOOL ret;
            __weak typeof(self)weakSelf=self;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                ret = [strongSelf ->jqFmdb jq_updateTable:@"lianxirenliebiao" dicOrModel:friendEntity whereFormat:@"where friend_userid = '%@'",friendEntity.friend_userid];
            }];
        }else{
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                [strongSelf ->jqFmdb jq_insertTable:@"lianxirenliebiao" dicOrModel:friendEntity];
            }];
        }
    }
//    __block NSArray *arr = [NSArray new];
//    [jqFmdb jq_inDatabase:^{
//        __strong typeof(weakSelf)strongSelf=weakSelf;
//        arr = [NSMutableArray arrayWithArray:[strongSelf ->jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact class] whereFormat:@""]];
//        NSLog(@"");
//    }];
    
}

#pragma mark - 插入一条消息到某个单聊表
-(void)insertAMessageToSingleChatTable:(NSString *)table AndDic:(NSDictionary *)dic{
            MessageChatEntity *entity = [MessageChatEntity new];
            entity.chatId = [[dic objectForKey:@"chatId"] description];
            entity.failStatus = @"0";
    //        entity.headPicPath = [[dic objectForKey:@"chatId"] description];
            entity.user_id = [[dic objectForKey:@"receiveId"] description];
            entity.user_name = [[dic objectForKey:@"receiveName"] description];
            entity.nickName = [[dic objectForKey:@"receiveNickName"] description];
            //entity.originalNickName = messagee.originalNickName;
            entity.message_content = [[dic objectForKey:@"strContent"] description];
            //entity.message_read_time = messagee.strTime;
            //entity.localReceiveTime = messagee.localReceiveTime;
    //        entity.localReceiveTimeString = messagee.localReceiveTimeString;
            entity.type = @"0";
            entity.isSelf = [[[dic objectForKey:@"receiveId"] description] isEqualToString:[NFUserEntity shareInstance].userId]?@"1":@"0";
            //插入数据
            __weak typeof(self)weakSelf=self;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                BOOL rett = [strongSelf ->jqFmdb jq_insertTable:table dicOrModel:entity];
                if (!rett) {
                    [SVProgressHUD showInfoWithStatus:@"缓存消息失败"];
    //                return;
                }
            }];
}



#pragma mark - 数据库是否存在某群组聊天表
-(void)IsExistGroupChatHistory:(NSString *)groupId ISNeedAppend:(BOOL)IsNeed{
    NSString *groupTableName = [NSString stringWithFormat:@"qunzu%@",groupId];
    if (IsNeed) {
        groupTableName = [NSString stringWithFormat:@"qunzu%@",groupId];
    }else{
        groupTableName = groupId;
    }
    
    __block BOOL ret = NO;
    __weak typeof(self)weakSelf=self;
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        ret = [strongSelf ->jqFmdb jq_isExistTable:groupTableName];
    }];
    if (!ret) {
        __block BOOL ret = NO;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            ret = [strongSelf ->jqFmdb jq_createTable:groupTableName dicOrModel:[MessageChatEntity class]];
//            ret = [strongSelf ->jqFmdb jq_createTable:groupTableName dicOrModel:[MessageChatEntity class] excludeName:@[@"update_time",@"redCount",@"headPicPath",@"cachePicPath",@"send_Time",@"msgType",@"receive_user_name",@"redPrice",@"receive_user_id",@"pictureData",@"is_receive_message",@"messgae_length",@"is_message_read"]];
        }];
        if (!ret) {
            //创建失败
        }
    }else{
        //检查是否需要增加新字段
        __block NSArray *keys = [NSArray new];
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            keys = [strongSelf ->jqFmdb jq_columnNameArray:groupTableName];
        }];
        if (keys.count != ChatEntityKeyCount) {
//            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                BOOL ret = [strongSelf ->jqFmdb jq_alterTable:groupTableName dicOrModel:[MessageChatEntity class]];
//            }];
            
        }
    }
}

#pragma mark - 数据库是否存在 和某人聊天表
-(void)IsExistSingleChatHistory:(NSString *)friendId{
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    //建表
    __block BOOL ret = NO;
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        ret = [strongSelf ->jqFmdb jq_isExistTable:friendId];
        
    }];
    if (!ret) {
        __block BOOL rett = NO;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            rett = [strongSelf ->jqFmdb jq_createTable:friendId dicOrModel:[MessageChatEntity class]];
//            rett = [strongSelf ->jqFmdb jq_createTable:friendId dicOrModel:[MessageChatEntity class] excludeName:@[@"update_time",@"redCount",@"headPicPath",@"cachePicPath",@"send_Time",@"msgType",@"receive_user_name",@"redPrice",@"receive_user_id",@"pictureData",@"is_receive_message",@"messgae_length",@"is_message_read"]];
        }];
    }else{
        //检查是否需要增加新字段
        __block NSArray *keys = [NSArray new];
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            keys = [strongSelf ->jqFmdb jq_columnNameArray:friendId];
        }];
        if (keys.count != ChatEntityKeyCount) {
//            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                 [strongSelf ->jqFmdb jq_alterTable:friendId dicOrModel:[MessageChatEntity class]];
//            }];
        }
    }
    
    //StrongQuit;
}

#pragma mark - 检查联系人列表
-(void)IsExistLianxirenLieBiao{
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __block BOOL IsExistYinC = NO;
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        IsExistYinC = [strongSelf ->jqFmdb jq_isExistTable:@"lianxirenliebiao"];
        if (!IsExistYinC) {
             [strongSelf ->jqFmdb jq_createTable:@"lianxirenliebiao" dicOrModel:[ZJContact class]];
        }
    }];
    if (IsExistYinC) {
        //检查是否属性不全
        NSArray *keys = [NSArray new];
        keys = [jqFmdb jq_columnNameArray:@"lianxirenliebiao"];
        if (keys.count != ZJContactEntityKeyCount) {
             [jqFmdb jq_alterTable:@"lianxirenliebiao" dicOrModel:[ZJContact class]];
        }
    }
    
    
}

#pragma mark - 检查隐藏联系人表
-(void)IsExistYinCangLianxirenLieBiao{
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __block BOOL ret = NO;
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        ret = [strongSelf ->jqFmdb jq_isExistTable:@"yincanglianxiren"];
        if (!ret) {
            [strongSelf ->jqFmdb jq_createTable:@"yincanglianxiren" dicOrModel:[ZJContact class]];
        }
    }];
    if (ret) {
        //检查是否属性不全
        __block NSArray *keys = [NSArray new];
        __weak typeof(self)weakSelf=self;
        keys = [jqFmdb jq_columnNameArray:@"yincanglianxiren"];
        if (keys.count != ZJContactEntityKeyCount) {
            __block BOOL rett = NO;
            rett = [jqFmdb jq_alterTable:@"yincanglianxiren" dicOrModel:[ZJContact class]];
        }
    }
    
}

#pragma mark - 检查申请与通知表
-(void)IsExistShenQingTongZhi{
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __block BOOL ret = NO;
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        ret = [strongSelf ->jqFmdb jq_isExistTable:@"shenqingtongzhi"];
        if (!ret) {
             [strongSelf ->jqFmdb jq_createTable:@"shenqingtongzhi" dicOrModel:[FriendAddListEntity class]];
        }else{
            //检查是否属性不全
            __block NSArray *keys = [NSArray new];
//            keys = [jqFmdb jq_columnNameArray:@"shenqingtongzhi"];
//            if (keys.count != ShenqingliebiaoCount) {
//                __block BOOL rett = NO;
//                rett = [jqFmdb jq_alterTable:@"shenqingtongzhi" dicOrModel:[FriendAddListEntity class]];
//            }
        }
    }];
    
}

#pragma mark - 检查群组列表 表
-(void)IsExistQunzuLiebiao{
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __block BOOL ret = NO;
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        ret = [strongSelf ->jqFmdb jq_isExistTable:@"qunzuliebiao"];
        if (!ret) {
            [strongSelf ->jqFmdb jq_createTable:@"qunzuliebiao" dicOrModel:[GroupListEntity class]];
        }
    }];
    if (ret) {
        //检查是否属性不全
        __block NSArray *keys = [NSArray new];
        keys = [jqFmdb jq_columnNameArray:@"qunzuliebiao"];
        if (keys.count != QunzuliebiaoCount) {
            __block BOOL rett = NO;
            rett = [jqFmdb jq_alterTable:@"qunzuliebiao" dicOrModel:[GroupListEntity class]];
        }
    }
}

#pragma mark - 检查会话列表 表
-(void)IsExistHuihualiebiao{
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __weak typeof(self)weakSelf=self;
    __block BOOL IsExistYC = NO;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        IsExistYC = [strongSelf ->jqFmdb jq_isExistTable:@"huihualiebiao"];
    }];
    if (!IsExistYC) {
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            BOOL ret = [strongSelf ->jqFmdb jq_createTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class]];
            if (!ret) {
            }
        }];
    }else{
        __block NSArray *keys = [NSArray new];
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            keys = [strongSelf ->jqFmdb jq_columnNameArray:@"huihualiebiao"];
        }];
        if (keys.count != ChatListEntityKeyCount) {
//            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                 [strongSelf ->jqFmdb jq_alterTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class]];
//            }];
        }
    }
}

#pragma mark - 检查群组详情 表
-(void)IsExistGroupDetailTable{
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __weak typeof(self)weakSelf=self;
    __block BOOL ret = NO;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        ret = [strongSelf ->jqFmdb jq_isExistTable:@"groupDetailliebiao"];
        if (!ret) {
             [strongSelf ->jqFmdb jq_createTable:@"groupDetailliebiao" dicOrModel:[GroupCreateSuccessEntity class]];
        }
    }];
    if (ret) {
        //检查是否属性不全
        __block NSArray *keys = [NSArray new];
        keys = [jqFmdb jq_columnNameArray:@"groupDetailliebiao"];
        if (keys.count != GroupDetailliebiaoCount) {
            __block BOOL rett = NO;
            rett = [jqFmdb jq_alterTable:@"groupDetailliebiao" dicOrModel:[GroupCreateSuccessEntity class]];
        }
    }
}

#pragma mark - 检查群组成员 表
-(void)IsExistGroupMemberTable{
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __weak typeof(self)weakSelf=self;
    __block BOOL ret = NO;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        ret = [strongSelf ->jqFmdb jq_isExistTable:@"groupMemberliebiao"];
        if (!ret) {
            [strongSelf ->jqFmdb jq_createTable:@"groupMemberliebiao" dicOrModel:[FriendListEntity class]];
        }
    }];
    if (ret) {
        //检查是否属性不全
        __block NSArray *keys = [NSArray new];
        keys = [jqFmdb jq_columnNameArray:@"groupMemberliebiao"];
        if (keys.count != GroupMemberliebiaoCount) {
            __block BOOL rett = NO;
            rett = [jqFmdb jq_alterTable:@"groupMemberliebiao" dicOrModel:[FriendListEntity class]];
        }
    }
}


#pragma mark -  根据userid，查找本地是否有该联系人
-(NSArray *)checkContactWithId:(NSString * )userid{
    __block NSArray *existContactArr = [NSArray new];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        existContactArr = [strongSelf ->jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact class] whereFormat:@"where friend_userid = '%@'",userid];
    }];
    return existContactArr;
}




@end
