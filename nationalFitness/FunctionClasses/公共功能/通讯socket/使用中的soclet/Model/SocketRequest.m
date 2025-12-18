//
//  SocketRequest.m
//  nationalFitness
//
//  Created by joe on 2018/1/25.
//  Copyright © 2018年 chenglong. All rights reserved.
//

#import "SocketRequest.h"

@implementation SocketRequest{
    
    SocketModel *socketModel;
    
}

+(instancetype)share
{
    static dispatch_once_t onceToken;
    static SocketRequest * instance=nil;
    dispatch_once(&onceToken,^{
        instance=[[self alloc]init];
    });
    return instance;
}

#pragma mark - 请求好友列表
-(void)getFriendList{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"action"] = @"getFriendList";
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}


#pragma mark - 删除好友请求
-(void)deleteFriendRequest:(NSString *)friendId{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"delFriend";
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"friendId"] = friendId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
    }
}

#pragma mark - 申请列表请求 为了显示 是否有添加好友请求
-(void)getIsExistUnReadApply{
    socketModel = [SocketModel share];
//    [SVProgressHUD show];
    //请求人列表获取
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"getFriendRequestUnread";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 请求申请列表
-(void)getAddFriendList{
    socketModel = [SocketModel share];
//    [SVProgressHUD show];
    //请求人列表获取
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"getFriendRequest";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 获取会话列表请求
-(void)getConversationList{
    socketModel = [SocketModel share];
    //    [SVProgressHUD show];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"getConversationListNew";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 请求已收到 单聊 群聊根据ret区分
-(void)haveReceived:(NSString *)messageId otherPartyId:(NSString *)otherId isSingle:(BOOL)ret{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"typing"] = @"";
    if (ret) {
        self.parms[@"action"] = @"setMessageReceived";
    }else{
        self.parms[@"action"] = @"setMessageReceived";
    }
    self.parms[@"receiveId"] = otherId;
    self.parms[@"messageId"] = messageId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 请求已读群聊
-(void)readedRequest:(NSString *)messageId GroupId:(NSString *)groupId{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"setGroupMsgRead";
    self.parms[@"lastGroupMsgId"] = messageId;
    self.parms[@"groupId"] = groupId;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected] && messageId) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 请求已读单聊 【左滑删除】
-(void)readedRequest:(NSString *)messageId receiveName:(NSString *)receiveName{
//    [SVProgressHUD show];
    socketModel = [SocketModel share];
    __weak typeof(self)weakSelf=self;
    [weakSelf.parms removeAllObjects];
    weakSelf.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    weakSelf.parms[@"action"] = @"setMessageRead";
    weakSelf.parms[@"messageId"] = messageId;
    weakSelf.parms[@"receiveName"] = receiveName;
    NSString *Json = [JsonModel convertToJsonData:weakSelf.parms];
    [socketModel ping];
    if ([socketModel isConnected] && messageId) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 请求某人的个人信息 【自己的话就穿自己的id】
-(void)requestPersonalInfoWithID:(NSString *)friendId{//SecretLetterType_PersonalInfoDetail
//    [SVProgressHUD show];
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"getUserInfo";
    self.parms[@"friendId"] = friendId;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 请求撤回
-(void)drowRequest:(UUMessage *)message{
    [SVProgressHUD show];
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"userOperationMsg";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"operation"] = @"user_cancel";
    self.parms[@"msgId"] = message.chatId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
        
    }
}

#pragma mark - 请求撤回 群聊
-(void)drowGroupRequest:(UUMessage *)message{
    [SVProgressHUD show];
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"userOperationGroupMsg";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"operation"] = @"user_cancel";
    self.parms[@"groupMsgId"] = message.chatId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
        
    }
}

#pragma mark - 请求正在输入
-(void)enteringRequesst:(ZJContact *)contact{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"friendTyping";
    self.parms[@"typing"] = @"1";
    self.parms[@"receiveId"] = contact.friend_userid;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"receiveName"] = contact.friend_username;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
        //由于请求正在输入没有返回 所以这时候不设置超时计算
        [NFUserEntity shareInstance].timeOutCountBegin = NO;
    }else{
    }
}

#pragma mark - 请求结束正在输入
-(void)enteringEndRequest:(ZJContact *)contact{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"friendTyping";
    self.parms[@"typing"] = @"0";
    self.parms[@"receiveId"] = contact.friend_userid;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"receiveName"] = contact.friend_username;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
        //由于请求正在输入没有返回 所以这时候不设置超时计算
        [NFUserEntity shareInstance].timeOutCountBegin = NO;
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}


#pragma mark - 请求所有单聊历史消息
-(void)getAllDataOfSingleChatWithFriendId:(NSString *)friendId FriendName:(NSString *)friendName{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"friendUserId"] = friendId;
    self.parms[@"friendUserName"] = friendName;
    self.parms[@"action"] = @"getAllMessageList";
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if (socketModel.isConnected) {
        [socketModel sendMsg:Json];
    }else{
    }
}

#pragma mark - 请求所有单聊历史消息
-(void)getAllDataOfSingleChatWithFriendId:(NSString *)friendId FriendName:(NSString *)friendName LastMessageId:(NSString *)messageId{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"getAllMessageList";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"friendUserId"] = friendId;
    self.parms[@"friendUserName"] = friendName;
    self.parms[@"lastMsgId"] = messageId?messageId:@"0";
    self.parms[@"limit"] = limitCount;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if (socketModel.isConnected) {
        [socketModel sendMsg:Json];
    }else{
    }
}

#pragma mark - 请求单聊历史消息
-(void)getSingleChatDataWithFriendEntity:(ZJContact *)contact LastChatEntity:(MessageChatEntity *)chatEntity{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"getMessageList";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"conversationUserId"] = contact.friend_userid;
    self.parms[@"conversationUserName"] = contact.friend_username;
    if ([chatEntity.isSelf isEqualToString:@"0"]) {
        //当最后一条数据有时间、chatid并且不是自己发的消息 则设置参数进行请求【当为自己发送的 则可能为自己转发的消息 如果根据这条消息来请求历史消息 那么转发消息时间之前的历史消息会丢失】
        self.parms[@"lastTime"] = @"0";
        self.parms[@"lastId"] = @"0";
        if(chatEntity.localReceiveTimeString.length > 0){
            self.parms[@"lastTime"] = chatEntity.localReceiveTimeString;
        }
        if(chatEntity.chatId.length > 0){
            self.parms[@"lastId"] = chatEntity.chatId;
        }
    }else{
        self.parms[@"lastTime"] = chatEntity.localReceiveTimeString.length > 0?chatEntity.localReceiveTimeString:@"0";
        self.parms[@"lastId"] = chatEntity.chatId.length > 0?chatEntity.chatId:@"0";
    }
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 请求所有群聊历史消息
-(void)getAllDataOfGroupChatWithGroupId:(NSString *)friendId GroupName:(NSString *)friendName{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"groupId"] = friendId;
    self.parms[@"groupName"] = friendName;
    self.parms[@"action"] = @"getAllGroupMsgList";
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if (socketModel.isConnected) {
        [socketModel sendMsg:Json];
    }else{
    }
}

#pragma mark - 请求所有群聊历史消息
-(void)getAllDataOfGroupChatWithGroupId:(NSString *)friendId GroupName:(NSString *)friendName LastMessageId:(NSString *)messageId{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"groupId"] = friendId;
    self.parms[@"groupName"] = friendName;
    self.parms[@"action"] = @"getAllGroupMsgList";
    self.parms[@"lastMsgId"] = messageId?messageId:@"0";
    self.parms[@"limit"] = limitCount;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if (socketModel.isConnected) {
        [socketModel sendMsg:Json];
    }else{
    }
}

#pragma mark - 请求群聊历史消息 GroupCreateSuccessEntity 5012
-(void)getGroupChatData:(GroupCreateSuccessEntity *)groupCreateSEntity AndChatEntity:(MessageChatEntity *)chatEntity{
//    [SVProgressHUD show];
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"getGroupMsgList";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"groupId"] = groupCreateSEntity.groupId;
//    self.parms[@"groupName"] = groupCreateSEntity.groupName;
    if (chatEntity.localReceiveTimeString && chatEntity.chatId && ![chatEntity.isSelf isEqualToString:@"0"]) {//当最后一条数据有时间、chatid并且不是自己发的消息 则设置参数进行请求【当为自己发送的 则可能为自己转发的消息 如果根据这条消息来请求历史消息 那么转发消息时间之前的历史消息会丢失】
        self.parms[@"lastMsgTime"] = chatEntity.localReceiveTimeString;
        self.parms[@"lastMsgId"] = chatEntity.chatId;
    }else{
        self.parms[@"lastMsgTime"] = @"0";
        self.parms[@"lastMsgId"] = @"0";
        if(chatEntity.localReceiveTimeString.length > 0){
            self.parms[@"lastMsgTime"] = chatEntity.localReceiveTimeString;
        }
        if(chatEntity.chatId.length > 0){
            self.parms[@"lastMsgId"] = chatEntity.chatId;
        }
        
    }
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
                [SVProgressHUD showInfoWithStatus:@"重连时 socket断了"];
    }
}

#pragma mark - 单聊详情 暂无接口
-(void)getSingleDetail:(ZJContact *)contact{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"friendId"] = contact.friend_userid;
    self.parms[@"action"] = @"getFriendShip";
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    if (socketModel.isConnected) {
        [socketModel ping];
        if (socketModel.isConnected) {
                        [socketModel sendMsg:Json];
        }else{
        }
    }else{
    }
}

#pragma mark - 请求拉黑或者取消拉黑
-(void)pullBlackType:(BOOL)type FriendId:(NSString *)friendid{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"friendId"] = friendid;
    if (type) {
        //1 拉黑
        self.parms[@"action"] = @"blackFriend";
    }else{
        //2 取消拉黑
        self.parms[@"action"] = @"removeBlackFriend";
    }
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    if (socketModel.isConnected) {
        [socketModel ping];
        if (socketModel.isConnected) {
                        [socketModel sendMsg:Json];
        }else{
        }
    }else{
    }
}

#pragma mark - 请求屏蔽朋友圈
-(void)limitDynamicType:(BOOL)type{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    if (type) {
        //1 屏蔽
        self.parms[@"pullBlackType"] = @"1";
    }else{
        //2 取消屏蔽
        self.parms[@"pullBlackType"] = @"2";
    }
    self.parms[@"action"] = @"pullBlack";
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    if (socketModel.isConnected) {
        [socketModel ping];
        if (socketModel.isConnected) {
            //            [socketModel sendMsg:Json];
        }else{
        }
    }else{
    }
}

#pragma mark - 创建群组请求 request
-(void)createGroupRequest:(NSArray *)memberArr{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"createGroup";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSDate *currentDate = [NSDate date];
    NSTimeInterval interval = [currentDate timeIntervalSince1970];
    NSInteger time = interval;
    self.parms[@"createTime"] = [NSString stringWithFormat:@"%ld",time];
    ZJContact *contant = [memberArr firstObject];
    NSString *titleName = [NSString stringWithFormat:@"和%@等人的聊天",contant.friend_nickname];
    self.parms[@"groupName"] = titleName;
    NSMutableArray *arr = [NSMutableArray new];
    for (ZJContact *contact in memberArr) {
        NSMutableDictionary *dict = [NSMutableDictionary new];
        [dict setValue:contact.friend_username forKey:@"userName"];
        [dict setValue:contact.friend_userid forKey:@"userId"];
        [arr addObject:dict];
    }
    self.parms[@"groupUser"] = arr;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
    }
}

#pragma mark - 群组详情请求
-(void)getGroupDetail:(NSString *)groupId{
    socketModel = [SocketModel share];
//    [SVProgressHUD show];
    [self.parms removeAllObjects];
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"groupId"] = groupId;
    self.parms[@"action"] = @"getGroupDetail";
    self.parms[@"page"] = @"1";
    self.parms[@"pagesize"] = @"15";
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    if (socketModel.isConnected) {
        [socketModel ping];
        if (socketModel.isConnected) {
            [socketModel sendMsg:Json];
        }else{
            //            [SVProgressHUD showInfoWithStatus:kWrongMessage];
        }
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 群组详情请求 分页
-(void)getGroupDetail:(NSString *)groupId AndPage:(NSString *)page{
    socketModel = [SocketModel share];
//    [SVProgressHUD show];
    [self.parms removeAllObjects];
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"groupId"] = groupId;
    self.parms[@"action"] = @"getGroupDetail";
    self.parms[@"page"] = page;
    self.parms[@"pagesize"] = @"15";
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    if (socketModel.isConnected) {
        [socketModel ping];
        if (socketModel.isConnected) {
            [socketModel sendMsg:Json];
        }else{
            //            [SVProgressHUD showInfoWithStatus:kWrongMessage];
        }
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 设置群组信息
-(void)setGroupInfoWithDict:(NSDictionary *)infoDict WithGroupId:(NSString *)groupId{
    socketModel = [SocketModel share];
    [SVProgressHUD show];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"setGroupInfo";
    self.parms[@"data"] = infoDict;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    if (groupId.length > 0) {
        self.parms[@"groupId"] = groupId;
    }else{
        self.parms[@"groupId"] = @"";
    }
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    if ([socketModel isConnected]) {
        [socketModel ping];
    }
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 退出群组请求
-(void)requestExitGroup:(NSString *)groupId{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"userExitGroup";
    self.parms[@"exitTime"] = [NFMyManage getCurrentTimeStamp];
    self.parms[@"groupId"] = groupId;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 解散群组请求
-(void)requestGroupDissolute:(NSString *)groupId{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"adminInvalidGroup";
    self.parms[@"invalidTime"] = [NFMyManage getCurrentTimeStamp];
    self.parms[@"groupId"] = groupId;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 根据群成员id数组，请求群成员信息
-(void)getUserInGroupDetail:(NSString *)groupId AndGroupuserArr:(NSArray *)arr{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"getUserInGroupDetail";
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"groupId"] = groupId;
    self.parms[@"groupUser"] = arr;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma 编辑修改我的本群昵称
-(void)requestEditLocalGroupNickName:(NSString *)newName GroupId:(NSString *)groupId{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"releaseGroup";
    self.parms[@"groupId"] = groupId;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"nickName"] = newName;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
//        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma 保存、取消群聊到列表
-(void)saveGroupToList:(NSString *)type GroupId:(NSString *)groupId{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"userSaveGroup";
    self.parms[@"groupId"] = groupId;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"type"] = type;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if (![ClearManager getNetStatus]) {
        //        [SVProgressHUD showInfoWithStatus:kWrongNetMissing];
        return;
    }
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma 设置群管理
-(void)manageGroup:(BOOL)ret GroupId:(NSString *)groupId AndContact:(ZJContact *)contact{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = ret?@"setGroupAdmin":@"delGroupAdmin";
    self.parms[@"groupId"] = groupId;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"groupUserArr"] = @[@{@"userId":contact.friend_userid,@"userName":contact.friend_username}];
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if (![ClearManager getNetStatus]) {
        //        [SVProgressHUD showInfoWithStatus:kWrongNetMissing];
        return;
    }
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma 设置群隐私
-(void)manageGroupSectet:(BOOL)ret GroupId:(NSString *)groupId{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = ret?@"setGroupSecret":@"delGroupSecret";
    self.parms[@"groupId"] = groupId;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if (![ClearManager getNetStatus]) {
        //        [SVProgressHUD showInfoWithStatus:kWrongNetMissing];
        return;
    }
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma 设置群验证
-(void)manageGroupEnterCheck:(BOOL)ret GroupId:(NSString *)groupId{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = ret?@"setJoinGroupNeedAllow":@"delJoinGroupNeedAllow";
    self.parms[@"groupId"] = groupId;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if (![ClearManager getNetStatus]) {
        //        [SVProgressHUD showInfoWithStatus:kWrongNetMissing];
        return;
    }
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma 设置群免打扰
-(void)manageGroupnotpush:(BOOL)ret GroupId:(NSString *)groupId{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = ret?@"setGroupNotPush":@"setGroupAllowPush";
    self.parms[@"groupId"] = groupId;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if (![ClearManager getNetStatus]) {
        //        [SVProgressHUD showInfoWithStatus:kWrongNetMissing];
        return;
    }
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma 设置好友备注
-(void)setFriendMark:(NSString *)markname FriendId:(NSString *)friendId{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"setFriendCommentName";
    self.parms[@"friendId"] = friendId;
    self.parms[@"FriendCommentName"] = markname;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if (![ClearManager getNetStatus]) {
        //        [SVProgressHUD showInfoWithStatus:kWrongNetMissing];
        return;
    }
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma 设置群禁言
-(void)forbiddenGroup:(BOOL)ret GroupId:(NSString *)groupId{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = ret?@"setGroupMsgForbidden":@"delGroupMsgForbidden";
    self.parms[@"groupId"] = groupId;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if (![ClearManager getNetStatus]) {
        //        [SVProgressHUD showInfoWithStatus:kWrongNetMissing];
        return;
    }
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma 设置群内昵称
-(void)setInGroup:(NSString *)markname groupId:(NSString *)groupId{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"modifyInGroupName";
    self.parms[@"groupId"] = groupId;
    self.parms[@"inGroupName"] = markname;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if (![ClearManager getNetStatus]) {
        //        [SVProgressHUD showInfoWithStatus:kWrongNetMissing];
        return;
    }
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma 转让群主
-(void)groupZhuanrang:(NSString *)memberid groupId:(NSString *)groupId{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"groupCreatorToOther";
    self.parms[@"groupId"] = groupId;
    self.parms[@"memberId"] = memberid;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if (![ClearManager getNetStatus]) {
        //        [SVProgressHUD showInfoWithStatus:kWrongNetMissing];
        return;
    }
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma 举报
-(void)jubaoWithuserid:(NSString *)userid groupId:(NSString *)groupId Content:(NSString *)content PicArr:(NSArray *)arr{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"postGroupComplain";
    self.parms[@"complainUserId"] = userid;
    self.parms[@"complainGroupId"] = groupId;
    self.parms[@"content"] = content;
    self.parms[@"pic"] = arr;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if (![ClearManager getNetStatus]) {
        //        [SVProgressHUD showInfoWithStatus:kWrongNetMissing];
        return;
    }
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}


#pragma mark - 创建群组请求
-(void)createGroupRequest:(NSArray *)memberArr GroupCreateSuccessEntity:(GroupCreateSuccessEntity *)createSuccessE{
    [SVProgressHUD show];
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    NSMutableArray *arr = [NSMutableArray new];
    //如果已存在群组 则就是拉人进群
    if (createSuccessE) {
        self.parms[@"action"] = @"inviteJoinGroup";
        self.parms[@"groupId"] = createSuccessE.groupId;
        self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
        self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
        self.parms[@"userNickname"] = createSuccessE.in_group_name;
        for (ZJContact *contact in memberArr) {
            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setValue:contact.friend_username forKey:@"friendName"];
            [dict setValue:contact.friend_userid forKey:@"friendId"];
            [dict setValue:contact.friend_nickname forKey:@"friendNickname"];
            [arr addObject:dict];
        }
        self.parms[@"groupUser"] = arr;
        NSString *Json = [JsonModel convertToJsonData:self.parms];
        [socketModel ping];
        if ([socketModel isConnected]) {
            [socketModel sendMsg:Json];
        }else{
            //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
        }
    }else{
        //否则就是创建新群组
        [self createGroupRequest:memberArr];
    }
}

#pragma mark - 群主踢人
-(void)groupOwnerOutMember:(NSArray *)memberArr GroupId:(NSString *)groupId{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"adminOutGroupUser";
    self.parms[@"groupId"] = groupId;
    NSMutableArray *dropArr = [NSMutableArray new];
    id obj = [memberArr firstObject];
    if([obj isKindOfClass:[ZJContact class]]){
        for (ZJContact *contact in memberArr) {
            [dropArr addObject:@{@"dropId":contact.friend_userid,@"dropName":contact.friend_username}];
        }
    }else if([obj isKindOfClass:[NSDictionary class]]){
        dropArr = [NSMutableArray arrayWithArray:memberArr];
    }
    
    self.parms[@"groupUserArr"] = dropArr;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    if ([socketModel isConnected]) {
        [socketModel ping];
    }
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 同意添加好友请求
-(void)acceptFriendAddRequest:(FriendAddListEntity *)entity{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"receiveUserName"] = entity.send_user_name;
    self.parms[@"action"] = @"responseFriendRequest";
    self.parms[@"responseAction"] = @"accept";
    self.parms[@"responseId"] = entity.addId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [SVProgressHUD show];
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 同意进群
-(void)acceptGroupJoinAddRequest:(FriendAddListEntity *)entity{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"action"] = @"responseGroupRequest";
    self.parms[@"responseAction"] = @"accept";
    self.parms[@"responseId"] = entity.addId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [SVProgressHUD show];
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 请求已读申请列表
-(void)haveReadApplyListRequest{
    //请求人列表获取
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"readFriendRequest";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }
}

#pragma mark - 删除、忽略该申请
-(void)ignoreApply:(FriendAddListEntity *)addEntity{
    [SVProgressHUD show];
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"ignoreFriendAdd";
    self.parms[@"friendAddId"] = addEntity.addId;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 删除、忽略 群组成员加入申请
-(void)ignoreGroupApply:(FriendAddListEntity *)addEntity{
    [SVProgressHUD show];
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"receiveUserName"] = addEntity.send_user_name;
    self.parms[@"action"] = @"responseGroupRequest";
    self.parms[@"responseAction"] = @"ignore";
    self.parms[@"responseId"] = addEntity.addId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}


#pragma mark - 发送好友请求
-(void)sendFriendAddRequest:(NSString *)friendName{
    [SVProgressHUD show];
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"addFriend";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"addTime"] = [NFMyManage getCurrentTimeStamp];
    self.parms[@"addUserName"] = friendName;
    if ([friendName isEqualToString:[NFUserEntity shareInstance].userName]) {
        [SVProgressHUD showInfoWithStatus:@"不可以添加自己喔"];
        return;
    }
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    if (socketModel.isConnected) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 请求群组
-(void)requestGroupArr{
    [SVProgressHUD show];
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"getSaveGroupList";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 请求所有群组
-(void)requestAllGroupArr{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"getUserAllGroupList";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 搜索好友请求
-(void)searchFriendRequest:(NSString *)keyString{
    [self.parms removeAllObjects];
    socketModel = [SocketModel share];
    self.parms[@"action"] = @"searchFriend";
    self.parms[@"friendName"] = keyString;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 设置头像请求
-(void)setHeadPicthWithUr:(NSString *)picPath{
    [NFUserEntity shareInstance].IsUploadingPicture = YES;
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"setUserInfo";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"data"] = @{@"photo":picPath};
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 退出登录 不需要收到退出消息
-(void)quitSocketRequest{
    //[SVProgressHUD show];
    socketModel = [SocketModel share];
    //请求人列表获取
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"userLogout";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 用户绑定极光id
-(void)setJPUSHServiceId{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"setUserInfo";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"data"] = @{@"reg_id":[JPUSHService registrationID]};
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 用户清空极光id
-(void)clearJPUSHServiceId{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"setUserInfo";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"data"] = @{@"reg_id":@""};
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
    
}


#pragma mark - 账号密码登录
-(void)loginWithDefaultTypeWithName:(NSString *)userName AndPassWord:(NSString *)password{
    [NFUserEntity shareInstance].userType = NFUserGeneral;
    //调用获取ui中的值 需要在主线程中执行并且为strongself 不能为weakself。
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"userLogin";
    self.parms[@"username"] = userName;
    if (userName.length == 0) {
        return;
    }
    
    NSString *pwd = [Data_MD5 MD5ForUpper32Bate:password];
    if (password.length == 0) {
        return;
    }
    //idfv IDFV Vindor标示符
    NSString *adId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    self.parms[@"password"] = pwd;
    self.parms[@"adCode"] = [SystemInfo shareSystemInfo].deviceId; //广告码 IDFA 广告标示符
    self.parms[@"phoneType"] = [self getDeviceVersion];//设备类型
    self.parms[@"osVersion"] = [SystemInfo shareSystemInfo].OSVersion;//系统版本
//    self.parms[@"loginIp"] = [SystemInfo shareSystemInfo].DeviceIPAddresses;//ip地址
    self.parms[@"loginIp"] = [NFUserEntity shareInstance].netIP.length > 0?[NFUserEntity shareInstance].netIP:[SystemInfo shareSystemInfo].DeviceIPAddresses;//ip地址
    self.parms[@"apns_production"] = APNSEnvironmental;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    if (socketModel.isConnected) {
        //        [SVProgressHUD showInfoWithStatus:@"连接成功!"];
        [socketModel sendMsg:Json];
    }
}



#pragma mark - 微信登录请求
-(void)weixinLoginRequest:(NSDictionary *)userInfo{
    socketModel = [SocketModel share];
    [NFUserEntity shareInstance].userType = NFUserWX;
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"wxLogin";
    self.parms[@"headimgurl"] = [userInfo objectForKey:@"headimgurl"];
    self.parms[@"nickname"] = [userInfo objectForKey:@"nickname"];
    //    self.parms[@"headimgurl"] = [NFUserEntity shareInstance].WXHeadPicpath;
    //    self.parms[@"nickname"] = [NFUserEntity shareInstance].WXNickName;
    self.parms[@"openid"] = [userInfo objectForKey:@"openid"];
    self.parms[@"adCode"] = [SystemInfo shareSystemInfo].deviceId; //广告码
    self.parms[@"phoneType"] = [self getDeviceVersion];//设备类型
    self.parms[@"osVersion"] = [SystemInfo shareSystemInfo].OSVersion;//系统版本
//    self.parms[@"loginIp"] = [SystemInfo shareSystemInfo].DeviceIPAddresses;//ip地址
    self.parms[@"loginIp"] = [NFUserEntity shareInstance].netIP.length > 0?[NFUserEntity shareInstance].netIP:[SystemInfo shareSystemInfo].DeviceIPAddresses;//ip地址
    
    self.parms[@"apns_production"] = APNSEnvironmental;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel sendMsg:Json];
}

#pragma mark - 扫码登录
-(void)QRCodeLoginWithWebClientId:(NSString *)ClientId{
//    [NFUserEntity shareInstance].userType = NFUserGeneral;
    //调用获取ui中的值 需要在主线程中执行并且为strongself 不能为weakself。
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"scanLogin";
    
    NSString *password = [KeepAppBox checkValueForkey:kLoginPassWord];
    NSString *pwd = [Data_MD5 MD5ForUpper32Bate:password];
    if (password.length == 0) {
        pwd = @"";
    }
    NSString *weixinId = [KeepAppBox checkValueForkey:kLoginWeixinUserName];
    if (weixinId.length > 0 && [NFUserEntity shareInstance].isBang) {//有微信id并且绑定了多信账号 则传空
        
    }else if (weixinId.length > 0 && ![NFUserEntity shareInstance].isBang){//有微信id。但是没有绑定多信账号
        [SVProgressHUD showInfoWithStatus:@"请先绑定多信账号"];
        return;
    }
    self.parms[@"password"] = pwd;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"webClientId"] = ClientId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    if (socketModel.isConnected) {
        //        [SVProgressHUD showInfoWithStatus:@"连接成功!"];
        [socketModel sendMsg:Json];
    }
}


#pragma mark - 测试 action
-(void)testActionaaa{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"scanCodeJoinGroup";
    self.parms[@"groupId"] = @"44";
    
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userNickname"] = [NFUserEntity shareInstance].nickName;
    
    
    self.parms[@"friendId"] = @"3";
    self.parms[@"friendName"] = @"a111111";
    self.parms[@"friendNickname"] = @"heigou";
    
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}



#pragma mark - 红包



#pragma mark - 充值
-(void)rechargeWithGroupId:(NSString *)groupid rechargeUserId:(NSString *)memberId amount:(NSString *)amount{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"rechargeGroup";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"groupId"] = groupid;
    self.parms[@"rechargeUserId"] = memberId;
    self.parms[@"amount"] = amount;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}



#pragma mark - 查看用户余额。用来查看是否设置过支付密码
-(void)checkuserAccountWithGroupId:(NSString *)groupid{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"newGetBalanceInfo";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
//    self.parms[@"groupId"] = groupid;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}



#pragma mark - 设置支付密码
-(void)setpasswordWirhPassword:(NSString *)password{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"setPayPassword";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"pay_password"] = password;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 修改支付密码
-(void)setpasswordWirhPassword:(NSString *)password AndCode:(NSString *)code{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"forgetPayPwd_3";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"pwd"] = password;
    self.parms[@"sms_code"] = code;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 修改支付密码 不用验证码 【设置免密后使用】
-(void)setpasswordWithPassword:(NSString *)password{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"forgetPayPwd";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"pwd"] = password;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 发红包 第一步
-(void)sendredPacketFirst:(NSDictionary *)dic{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"sendRedPacket_1";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"isGroup"] = [dic objectForKey:@"isGroup"];
    self.parms[@"toGroupId"] = [dic objectForKey:@"toGroupId"];
    self.parms[@"toUserId"] = [dic objectForKey:@"toUserId"];
    self.parms[@"title"] = [dic objectForKey:@"title"];
    self.parms[@"type"] = [dic objectForKey:@"type"];
    self.parms[@"count"] = [dic objectForKey:@"count"];
    self.parms[@"singleMoney"] = [dic objectForKey:@"singleMoney"];
    self.parms[@"totalMoney"] = [dic objectForKey:@"totalMoney"];
    self.parms[@"content"] = [dic objectForKey:@"content"];
    self.parms[@"payPassword"] = [dic objectForKey:@"payPassword"];
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 发红包 第二步
-(void)sendredPacket:(NSDictionary *)dic{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"sendRedPacket_2";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"isGroup"] = [dic objectForKey:@"isGroup"];
    self.parms[@"toGroupId"] = [dic objectForKey:@"toGroupId"];
    self.parms[@"toUserId"] = [dic objectForKey:@"toUserId"];
    self.parms[@"title"] = [dic objectForKey:@"title"];
    self.parms[@"type"] = [dic objectForKey:@"type"];
    self.parms[@"count"] = [dic objectForKey:@"count"];
    self.parms[@"singleMoney"] = [dic objectForKey:@"singleMoney"];
    self.parms[@"totalMoney"] = [dic objectForKey:@"totalMoney"];
    self.parms[@"content"] = [dic objectForKey:@"content"];
    self.parms[@"payPassword"] = [dic objectForKey:@"payPassword"];
    self.parms[@"redpacketId"] = [dic objectForKey:@"redpacketId"];
    self.parms[@"dev_info_json"] = [dic objectForKey:@"device"];
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
    
}

#pragma mark - 发红包 新生 一步完成
-(void)sendredPacketNew:(NSDictionary *)dic{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"newSendRedPacket";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"isGroup"] = [dic objectForKey:@"isGroup"];
    self.parms[@"toGroupId"] = [dic objectForKey:@"toGroupId"];
    self.parms[@"toUserId"] = [dic objectForKey:@"toUserId"];
    self.parms[@"title"] = [dic objectForKey:@"title"];
    self.parms[@"type"] = [dic objectForKey:@"type"];
    self.parms[@"count"] = [dic objectForKey:@"count"];
    self.parms[@"singleMoney"] = [dic objectForKey:@"singleMoney"];
    self.parms[@"totalMoney"] = [dic objectForKey:@"totalMoney"];
    self.parms[@"content"] = [dic objectForKey:@"content"];
    self.parms[@"payPassword"] = [dic objectForKey:@"payPassword"];
    self.parms[@"appMsgId"] = [dic objectForKey:@"appMsgId"];
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}




#pragma mark - 转账 第一步
-(void)transferFirst:(NSDictionary *)dic{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"sendRedPacket_1";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"isGroup"] = [dic objectForKey:@"isGroup"];
    self.parms[@"toGroupId"] = [dic objectForKey:@"toGroupId"];
    self.parms[@"toUserId"] = [dic objectForKey:@"toUserId"];
    self.parms[@"title"] = [dic objectForKey:@"title"];
    self.parms[@"type"] = [dic objectForKey:@"type"];
    self.parms[@"count"] = [dic objectForKey:@"count"];
    self.parms[@"singleMoney"] = [dic objectForKey:@"singleMoney"];
    self.parms[@"totalMoney"] = [dic objectForKey:@"totalMoney"];
    self.parms[@"content"] = [dic objectForKey:@"content"];
    self.parms[@"payPassword"] = [dic objectForKey:@"payPassword"];
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 转账 第二步
-(void)transferPacketSec:(NSDictionary *)dic{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"sendRedPacket_2";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"isGroup"] = [dic objectForKey:@"isGroup"];
    self.parms[@"toGroupId"] = [dic objectForKey:@"toGroupId"];
    self.parms[@"toUserId"] = [dic objectForKey:@"toUserId"];
    self.parms[@"title"] = [dic objectForKey:@"title"];
    self.parms[@"type"] = [dic objectForKey:@"type"];
    self.parms[@"count"] = [dic objectForKey:@"count"];
    self.parms[@"singleMoney"] = [dic objectForKey:@"singleMoney"];
    self.parms[@"totalMoney"] = [dic objectForKey:@"totalMoney"];
    self.parms[@"content"] = [dic objectForKey:@"content"];
    self.parms[@"payPassword"] = [dic objectForKey:@"payPassword"];
    self.parms[@"redpacketId"] = [dic objectForKey:@"redpacketId"];
    self.parms[@"dev_info_json"] = [dic objectForKey:@"device"];
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 转账 新生 一步完成
-(void)transferFirstNew:(NSDictionary *)dic{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"newSendRedPacket";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"isGroup"] = [dic objectForKey:@"isGroup"];
    self.parms[@"toGroupId"] = [dic objectForKey:@"toGroupId"];
    self.parms[@"toUserId"] = [dic objectForKey:@"toUserId"];
    self.parms[@"title"] = [dic objectForKey:@"title"];
    self.parms[@"type"] = [dic objectForKey:@"type"];
    self.parms[@"count"] = [dic objectForKey:@"count"];
    self.parms[@"singleMoney"] = [dic objectForKey:@"singleMoney"];
    self.parms[@"totalMoney"] = [dic objectForKey:@"totalMoney"];
    self.parms[@"content"] = [dic objectForKey:@"content"];
    self.parms[@"payPassword"] = [dic objectForKey:@"payPassword"];
    self.parms[@"appMsgId"] = [dic objectForKey:@"appMsgId"];
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 检查check红包
-(void)checkRedPacket:(NSDictionary *)dic{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"getRedPacketInfo";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"groupId"] = [dic objectForKey:@"groupId"];
    self.parms[@"redpacketId"] = [dic objectForKey:@"redpacketId"];
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}



#pragma mark - 拆红包 新生
-(void)pickRedPacket:(NSDictionary *)dic{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"newGetRedPacket";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"groupId"] = [dic objectForKey:@"groupId"];
    self.parms[@"redpacketId"] = [dic objectForKey:@"redpacketId"];
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 红包详情
-(void)RedPacketDetail:(NSDictionary *)dic{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"getRedPacketInfo";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"groupId"] = [dic objectForKey:@"groupId"];
    self.parms[@"redpacketId"] = [dic objectForKey:@"redpacketId"];
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}



#pragma mark - 充值
-(void)recharge:(NSDictionary *)dict{
    
    
    
}




//
#pragma mark - 充值 获取 value
-(void)SignsRequest:(NSDictionary *)Info{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"huifuPay";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"trans_amt"] = [Info objectForKey:@"trans_amt"];
    self.parms[@"dev_info_json"] = [Info objectForKey:@"dev_info_json"];
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 开子账户 获取
-(void)SubAccountRequest:(NSDictionary *)Info{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"addAcctId";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"acct_name"] = [Info objectForKey:@"acct_name"];
//    self.parms[@"dev_info_json"] = [Info objectForKey:@"dev_info_json"];
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 提现 获取 value 新生提现
-(void)cashOut:(NSDictionary *)dict{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"hnapayCash";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"tranAmt"] = [dict objectForKey:@"tranAmt"];
    self.parms[@"cardId"] = [dict objectForKey:@"cardId"];
    self.parms[@"payPassword"] = [dict objectForKey:@"payPassword"];
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 授权免密支付 获取 value
-(void)shouquanOut:(NSDictionary *)dict{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"setNoPwdPay";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}
//1300 * 80 =
#pragma mark - 支付密码
-(void)cashPassword{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"huifuPwd";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 提现记录 新生
-(void)recordMonryWithPage:(NSString *)page{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"cashOutRecord";
    self.parms[@"page"] = page;
    self.parms[@"page_size"] = @"15";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 充值记录 新生
-(void)chongzhiRecordWithPage:(NSString *)page{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"newRechargeRecord";
    self.parms[@"offset"] = page;
    self.parms[@"limit"] = @"15";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 余额查询 新生
-(void)accountDetail{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"newGetBalanceInfo";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

//11040.14
#pragma mark - 红包退款 定时检查
-(void)checkTuikuanWithinfo:(NSDictionary *)info{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"redPacketBack";
    self.parms[@"dev_info_json"] = [info objectForKey:@"devicee"];
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
    
    
    
}

#pragma mark - 提现密码设置 检查 //多信密码
-(void)tixianPwdCheck{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"isSetHuifuPwd";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 免密支付设置 检查  免密的开关
-(void)mianmiPayCheck{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"getNoPwdPayStatus";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 修改支付密码 发送验证码
-(void)forgetPayPasswordSendCode:(NSString *)phone{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"forgetPayPwd_1";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 验证短信 请求
-(void)changePayPasswordSendCode:(NSDictionary *)dic{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"forgetPayPwd_2";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
//    self.parms[@"phone"] = [dic objectForKey:@"phone"];
    self.parms[@"sms_code"] = [dic objectForKey:@"sms_code"];
//    self.parms[@"pwd"] = [dic objectForKey:@"pwd"];
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 免密授权   发送验证码
-(void)noPasswordSendCode:(NSDictionary *)dic{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"setNoPwdPay_1";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 免密授权 open验证
-(void)noPasswordOpenCode:(NSDictionary *)dic{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"setNoPwdPay_2";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"sms_code"] = [dic objectForKey:@"sms_code"];
    self.parms[@"order_id"] = [dic objectForKey:@"order_id"];
    
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 免密授权 取消 验证
-(void)noPasswordCloseCode:(NSDictionary *)dic{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"closeNoPwdPay";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
//    self.parms[@"sms_code"] = [dic objectForKey:@"sms_code"];
//    self.parms[@"order_id"] = [dic objectForKey:@"order_id"];
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 红包记录
-(void)redRecordListReqquest:(NSDictionary *)dic{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"queryUserRedPacket";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"recordType"] = [dic objectForKey:@"recordType"];
    self.parms[@"offset"] = [dic objectForKey:@"offset"];
    self.parms[@"limit"] = [dic objectForKey:@"limit"];
    self.parms[@"groupId"] = [dic objectForKey:@"groupId"];
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}


#pragma mark - 银行卡列表 【新生】
-(void)getBankCardList{
    socketModel = [SocketModel share]; 
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"newCardList";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    //    self.parms[@"sms_code"] = [dic objectForKey:@"sms_code"];
    //    self.parms[@"order_id"] = [dic objectForKey:@"order_id"];
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
    
}

#pragma mark -    发送验证码 充值 【新生】
-(void)chargeMoneySendCode:(NSDictionary *)dic{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"hnapay_1";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"tranAmt"] = [dic objectForKey:@"tranAmt"];
    self.parms[@"bizProtocolNo"] = [dic objectForKey:@"bizProtocolNo"];
    self.parms[@"payProtocolNo"] = [dic objectForKey:@"payProtocolNo"];
    self.parms[@"merUserIp"] = [dic objectForKey:@"merUserIp"];
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark -   验证短信  充值 【新生】
-(void)chargeMoneyCheckCodeAndBind:(NSDictionary *)dic{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"hnapay_2";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"merOrderId"] = [dic objectForKey:@"merOrderId"];
    self.parms[@"hnapayOrderId"] = [dic objectForKey:@"hnapayOrderId"];
    self.parms[@"smsCode"] = [dic objectForKey:@"smsCode"];
    self.parms[@"merUserIp"] = [dic objectForKey:@"merUserIp"];
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark -    发送验证码 绑卡 【新生】
-(void)bindCardSendCode:(NSDictionary *)dic{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"newBindCard_1";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"holderName"] = [dic objectForKey:@"holderName"];
    self.parms[@"mobileNo"] = [dic objectForKey:@"mobileNo"];
    self.parms[@"cardNo"] = [dic objectForKey:@"cardNo"];
    self.parms[@"identityCode"] = [dic objectForKey:@"identityCode"];
    self.parms[@"merUserIp"] = [dic objectForKey:@"merUserIp"];
    self.parms[@"bankName"] = [dic objectForKey:@"bankName"];
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark -  绑卡  验证短信 并绑卡 【新生】
-(void)bindCardCheckCodeAndBind:(NSDictionary *)dic{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"newBindCard_2";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"hnapayOrderId"] = [dic objectForKey:@"hnapayOrderId"];
//    self.parms[@"order_date"] = [dic objectForKey:@"order_date"];
    self.parms[@"smsCode"] = [dic objectForKey:@"smsCode"];
    self.parms[@"merUserIp"] = [dic objectForKey:@"merUserIp"];
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark -  解绑卡 新生
-(void)catBindCard:(NSString *)cardid{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"newUnbindCard";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"cardId"] = cardid;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark -  账单
-(void)BillListWithPage:(NSString *)page IsSystem:(BOOL)ret{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"billList";
    self.parms[@"offset"] = page;
    self.parms[@"limit"] = @"15";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    if (ret) {
        self.parms[@"type"] = @"2";
    }else{
//        self.parms[@"type"] = @"1";
    }
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}


#pragma mark -开户 接口版
-(void)OpenAccountRequest:(NSDictionary *)Info{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"openAccount_2";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"user_name"] = [Info objectForKey:@"user_name"];
    self.parms[@"id_card"] = [Info objectForKey:@"id_card"];
    self.parms[@"user_mobile"] = [Info objectForKey:@"user_mobile"];
    self.parms[@"code"] = [Info objectForKey:@"code"];
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 子账户查询接口
-(void)SubAccountLookRequest{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"huifuAcctInfo";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 验证支付密码
-(void)checkPayPasswordWithPassword:(NSString *)password{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"huifuAcctInfo";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"password"] = password;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 拉黑列表
-(void)getBlackList{
    socketModel = [SocketModel share];
//    [SVProgressHUD show];
    //请求人列表获取
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"getBlackList";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 收藏表情
-(void)collectEmoji:(NSDictionary *)Info{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"addEmoji";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"file_id"] = [Info objectForKey:@"file_id"];
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 删除收藏表情
-(void)deleteCollectEmoji:(NSDictionary *)Info{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"delEmoji";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"file_id"] = [Info objectForKey:@"file_id"];
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 请求收藏表情
-(void)requestCollectEmoji{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"getEmoji";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 管理员同意进群
-(void)requestAcceptJoinGroupWithInfo:(NSString *)addId{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"responseGroupRequest";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"responseAction"] = @"accept";
    self.parms[@"responseId"] = addId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 管理员拒绝进群
-(void)requestRefuseJoinGroupWithInfo:(NSString *)addId{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"responseGroupRequest";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"responseAction"] = @"reject";
    self.parms[@"responseId"] = addId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 实名认证发送验证码
-(void)shimingSendCode:(NSString *)code{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"openAccount_1";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"user_mobile"] = code;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 请求所有群成员id
-(void)requestGroupAllMemberIdWithGroup:(NSString *)groupId{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"getGroupAllUser";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"groupId"] = groupId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark -  多信助手 消息列表
-(void)helperMessageList{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"getSysMessage";
//    self.parms[@"limit"] = @"15";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark -  注销多信
-(void)logoffDuoxinRequest{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"cancelAccount";
//    self.parms[@"limit"] = @"15";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark -  会话已读
-(void)allReadRequest{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"setAllMessageRead";
//    self.parms[@"limit"] = @"15";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark -  朋友圈 评论列表
-(void)PointListRequestWithPage:(NSString *)page{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"billList";
    self.parms[@"offset"] = page;
    self.parms[@"limit"] = @"15";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark -  朋友圈评论相关
-(void)getCircleMsg{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"getCircleMsg";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark -  朋友圈评列表
-(void)getCircleUnreadMsg{
    socketModel = [SocketModel share];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"getCircleUnreadMsg";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    //if ([socketModel isConnected] && [JPUSHService registrationID]) {
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}




- (NSString *)getDeviceVersion{
    // 需要#import "sys/utsname.h"
#warning 题主呕心沥血总结！！最全面！亲测！全网独此一份！！
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    // 日行两款手机型号均为日本独占，可能使用索尼FeliCa支付方案而不是苹果支付
    if ([deviceString isEqualToString:@"iPhone9,1"] || [deviceString isEqualToString:@"iPhone9,3"]) {
        return @"iPhone 7";
    }
    if ([deviceString isEqualToString:@"iPhone9,2"] || [deviceString isEqualToString:@"iPhone9,4"]) {
        return @"iPhone 7 Plus";
    }
    if ([deviceString isEqualToString:@"iPhone10,1"] || [deviceString isEqualToString:@"iPhone10,4"]) {
        return @"iPhone 8";
    }
    if ([deviceString isEqualToString:@"iPhone10,2"] || [deviceString isEqualToString:@"iPhone10,5"]) {
        return @"iPhone 8 Plus";
    }
    if ([deviceString isEqualToString:@"iPhone10,3"] || [deviceString isEqualToString:@"iPhone10,6"]) {
        return @"iPhone X";
    }
    if ([deviceString isEqualToString:@"iPhone9,1"])    return @"国行、日版、港行iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,2"])    return @"港行、国行iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone9,3"])    return @"美版、台版iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,4"])    return @"美版、台版iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone10,1"])   return @"国行(A1863)、日行(A1906)iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,4"])   return @"美版(Global/A1905)iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,2"])   return @"国行(A1864)、日行(A1898)iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,5"])   return @"美版(Global/A1897)iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,3"])   return @"国行(A1865)、日行(A1902)iPhone X";
    if ([deviceString isEqualToString:@"iPhone10,6"])   return @"美版(Global/A1901)iPhone X";
    
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([deviceString isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([deviceString isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([deviceString isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    if ([deviceString isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (LTE)";
    if ([deviceString isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9";
    if ([deviceString isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9";
    if ([deviceString isEqualToString:@"iPad6,11"])    return @"iPad 5 (WiFi)";
    if ([deviceString isEqualToString:@"iPad6,12"])    return @"iPad 5 (Cellular)";
    if ([deviceString isEqualToString:@"iPad7,1"])     return @"iPad Pro 12.9 inch 2nd gen (WiFi)";
    if ([deviceString isEqualToString:@"iPad7,2"])     return @"iPad Pro 12.9 inch 2nd gen (Cellular)";
    if ([deviceString isEqualToString:@"iPad7,3"])     return @"iPad Pro 10.5 inch (WiFi)";
    if ([deviceString isEqualToString:@"iPad7,4"])     return @"iPad Pro 10.5 inch (Cellular)";
    
    if ([deviceString isEqualToString:@"AppleTV2,1"])    return @"Apple TV 2";
    if ([deviceString isEqualToString:@"AppleTV3,1"])    return @"Apple TV 3";
    if ([deviceString isEqualToString:@"AppleTV3,2"])    return @"Apple TV 3";
    if ([deviceString isEqualToString:@"AppleTV5,3"])    return @"Apple TV 4";
    
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    
    return deviceString;
}

//懒加载
-(NSMutableDictionary *)parms{
    if (!_parms) {
        _parms = [[NSMutableDictionary alloc] init];
    }
    return _parms;
}

@end


