//
//  MessageParser.m
//  nationalFitness
//
//  Created by Joe on 2017/7/20.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "MessageParser.h"

@implementation MessageParser

//会话列表 只有单聊会话
+(id)ConvasationListParser:(NSDictionary *)data{
    if (data) {
        NSMutableArray *requestArr = [[NSMutableArray alloc] initWithCapacity:5];
        for (NSDictionary *groupDictt in [data objectForKey:@"groupChat"]) {
            NSDictionary *groupDict = [self nullDic:groupDictt];
            //兼容安卓表情
//            if([[groupDict objectForKey:@"lastMsgContent"] isKindOfClass:[NSString class]] && [NFMyManage validateContainsEmoji:[groupDict objectForKey:@"lastMsgContent"]]){
//                NSString *str = [groupDict objectForKey:@"lastMsgContent"];
//                str = [str stringByReplacingOccurrencesOfString:@"[" withString:@""];
//                str = [str stringByReplacingOccurrencesOfString:@"]" withString:@""];
//                NSMutableDictionary *diccc = [NSMutableDictionary dictionaryWithDictionary:groupDict];
//                [diccc setValue:str forKey:@"lastMsgContent"];
//                groupDict = [NSDictionary dictionaryWithDictionary:diccc];
//            }else if([[groupDict objectForKey:@"lastMsgContent"] isKindOfClass:[NSString class]] && [[groupDict objectForKey:@"lastMsgContent"] length] <= 4 && [[[groupDict objectForKey:@"lastMsgContent"] description] containsString:@"["]&& [[[groupDict objectForKey:@"lastMsgContent"] description] containsString:@"]"]){
//                NSString *str = [groupDict objectForKey:@"lastMsgContent"];
//                str = [str stringByReplacingOccurrencesOfString:@"[" withString:@""];
//                str = [str stringByReplacingOccurrencesOfString:@"]" withString:@""];
//                NSMutableDictionary *diccc = [NSMutableDictionary dictionaryWithDictionary:groupDict];
//                [diccc setValue:str forKey:@"lastMsgContent"];
//                groupDict = [NSDictionary dictionaryWithDictionary:diccc];
//            }else
                if([[groupDict objectForKey:@"lastMsgContent"] isKindOfClass:[NSString class]] && [[[groupDict objectForKey:@"lastMsgContent"] description] containsString:@"["]&& [[[groupDict objectForKey:@"lastMsgContent"] description] containsString:@"]"]){
                NSString *str = [groupDict objectForKey:@"lastMsgContent"];
                str = [str stringByReplacingOccurrencesOfString:@"[" withString:@""];
                str = [str stringByReplacingOccurrencesOfString:@"]" withString:@""];
                NSMutableDictionary *diccc = [NSMutableDictionary dictionaryWithDictionary:groupDict];
                [diccc setValue:str forKey:@"lastMsgContent"];
                groupDict = [NSDictionary dictionaryWithDictionary:diccc];
            }
            
            MessageChatListEntity *entity = [MessageChatListEntity new];
            entity.conversationId = [[groupDict objectForKey:@"groupId"] description];
//            entity.groupTotalNum = [[groupDict objectForKey:@"groupTotalNum"] description];
//            if ([[[groupDict objectForKey:@"groupPhoto"] description] containsString:@"head_man"]) {
//                entity.headPicpath = [[groupDict objectForKey:@"groupPhoto"] description];
//            }else{
                if ([[[groupDict objectForKey:@"groupPhoto"] description] containsString:@"http"] || [[[data objectForKey:@"groupPhoto"] description] containsString:@"wx.qlogo.cn"]) {
                    entity.headPicpath = [[groupDict objectForKey:@"groupPhoto"] description];
                }else{
                    //@"http://121.43.116.159:7999/"
//                    entity.headPicpath = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[[groupDict objectForKey:@"groupPhoto"] description]];
                    entity.headPicpath = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[[groupDict objectForKey:@"groupPhoto"] description]];
                }
//            }
            entity.receive_user_id = [[groupDict objectForKey:@"groupId"] description];//发送人id
            entity.receive_user_name = [[groupDict objectForKey:@"groupName"] description];//收到群组name【即群组】
            entity.nickName = [[groupDict objectForKey:@"groupName"] description];//收到的群组昵称
//            if (entity.nickName.length == 0) {
//                entity.nickName = [[groupDict objectForKey:@"groupName"] description];//昵称
//            }
            entity.last_message_id = [[groupDict objectForKey:@"lastMsgId"] description];//最后一条消息id
            entity.last_send_message = [[groupDict objectForKey:@"lastMsgContent"] description];//最后一条消息内容
//            if (entity.last_send_message.length < 1000 && entity.last_send_message.length > 0 && [[groupDict objectForKey:@"lastMsgContent"] containsString:@"["] && [[groupDict objectForKey:@"lastMsgContent"] containsString:@"]"]) {
//                entity.last_send_message = [EmojiShift stringShiftemoji:[groupDict objectForKey:@"lastMsgContent"]];//表情文字转换成表情
//            }
            if ([[groupDict objectForKey:@"lastMsgType"] isEqualToString:@"image"]) {
                entity.last_send_message = @"[图片]";
            }else if ([[groupDict objectForKey:@"lastMsgType"] isEqualToString:@"audio"]){
                entity.last_send_message = @"[语音]";
            }else if ([[groupDict objectForKey:@"lastMsgType"] isEqualToString:@"RedPacket"]){
                entity.last_send_message = @"[多信红包]恭喜发财，大吉大利";
            }else if ([[groupDict objectForKey:@"lastMsgType"] isEqualToString:@"card"]){
                entity.last_send_message = [NSString stringWithFormat:@"[名片消息]"];
            }
            int a = [[NFMyManage new] checkIsHaveNumAndLetter:[[groupDict objectForKey:@"lastMsgTime"] description]];
            if (a == 1) {
                entity.update_time = [[NFbaseViewController new] timestampSwitchTime:[[groupDict objectForKey:@"lastMsgTime"] integerValue]];
            }else{
                entity.update_time = @"";
            }
            entity.originTimeString = [[groupDict objectForKey:@"lastMsgTime"] description];
            entity.last_send_time = [[groupDict objectForKey:@"lastMsgTime"] description];
            entity.IsSingleChat = NO;
            entity.unread_message_count = [[groupDict objectForKey:@"unreadMsgNum"] description];
            entity.msgType = [[groupDict objectForKey:@"lastMsgType"] description];
            entity.IsDisturb = [[[groupDict objectForKey:@"allow_push"] description] isEqualToString:@"0"]?YES:NO;
            [requestArr addObject:entity];
        }
        for (NSDictionary *singleDictt in [data objectForKey:@"singleChat"]) {
            NSDictionary *singleDict = [self nullDic:singleDictt];
            if ([[singleDict objectForKey:@"friendName"] isKindOfClass:[NSString class]] && [[singleDict objectForKey:@"friendName"] isEqualToString:[NFUserEntity shareInstance].userName]) {
                break;
            }
            
//            if([[singleDict objectForKey:@"lastMsgContent"] isKindOfClass:[NSString class]] && [NFMyManage validateContainsEmoji:[singleDict objectForKey:@"lastMsgContent"]]){
//                NSString *str = [singleDict objectForKey:@"lastMsgContent"];
//                str = [str stringByReplacingOccurrencesOfString:@"[" withString:@""];
//                str = [str stringByReplacingOccurrencesOfString:@"]" withString:@""];
//                NSMutableDictionary *diccc = [NSMutableDictionary dictionaryWithDictionary:singleDict];
//                [diccc setValue:str forKey:@"lastMsgContent"];
//                singleDict = [NSDictionary dictionaryWithDictionary:diccc];
//            }else if([[singleDict objectForKey:@"lastMsgContent"] isKindOfClass:[NSString class]] && [[singleDict objectForKey:@"lastMsgContent"] length] <= 4 && [[[singleDict objectForKey:@"lastMsgContent"] description] containsString:@"["]&& [[[singleDict objectForKey:@"lastMsgContent"] description] containsString:@"]"]){
//                NSString *str = [singleDict objectForKey:@"lastMsgContent"];
//                str = [str stringByReplacingOccurrencesOfString:@"[" withString:@""];
//                str = [str stringByReplacingOccurrencesOfString:@"]" withString:@""];
//                NSMutableDictionary *diccc = [NSMutableDictionary dictionaryWithDictionary:singleDict];
//                [diccc setValue:str forKey:@"lastMsgContent"];
//                singleDict = [NSDictionary dictionaryWithDictionary:diccc];
//            }else
                if([[singleDict objectForKey:@"lastMsgContent"] isKindOfClass:[NSString class]] && [[[singleDict objectForKey:@"lastMsgContent"] description] containsString:@"["]&& [[[singleDict objectForKey:@"lastMsgContent"] description] containsString:@"]"]){
                NSString *str = [singleDict objectForKey:@"lastMsgContent"];
                str = [str stringByReplacingOccurrencesOfString:@"[" withString:@""];
                str = [str stringByReplacingOccurrencesOfString:@"]" withString:@""];
                NSMutableDictionary *diccc = [NSMutableDictionary dictionaryWithDictionary:singleDict];
                [diccc setValue:str forKey:@"lastMsgContent"];
                singleDict = [NSDictionary dictionaryWithDictionary:diccc];
            }
            
            MessageChatListEntity *entity = [MessageChatListEntity new];
            entity.conversationId = [[singleDict objectForKey:@"friendId"] description];
            
//            if ([[[singleDict objectForKey:@"photo"] description] containsString:@"head_man"]) {
//                entity.headPicpath = [[singleDict objectForKey:@"photo"] description];
//            }else{
                if ([[[singleDict objectForKey:@"photo"] description] containsString:@"http"] || [[[data objectForKey:@"photo"] description] containsString:@"wx.qlogo.cn"]) {
                    entity.headPicpath = [[singleDict objectForKey:@"photo"] description];
                }else{
                    entity.headPicpath = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[[singleDict objectForKey:@"photo"] description]];
                }
//            }
            
//            entity.user_id = [[singleDict objectForKey:@"friendId"] description];
//            entity.user_name = [[singleDict objectForKey:@"user_name"] description];
            entity.receive_user_id = [[singleDict objectForKey:@"friendId"] description];
            entity.receive_user_name = [[singleDict objectForKey:@"friendName"] description];
            entity.nickName = [[singleDict objectForKey:@"friend_comment_name"] description];
            if (entity.nickName.length == 0) {
                entity.nickName = [[singleDict objectForKey:@"nickname"] description];
                if (entity.nickName.length == 0) {
                    entity.nickName = [[singleDict objectForKey:@"friendName"] description];
                }
            }
            entity.last_message_id = [[singleDict objectForKey:@"lastMsgId"] description];
            entity.last_send_message = [[singleDict objectForKey:@"lastMsgContent"] description];
//            if (entity.last_send_message.length < 1000 && entity.last_send_message.length > 0 && [[singleDict objectForKey:@"lastMsgContent"] containsString:@"["] && [[singleDict objectForKey:@"lastMsgContent"] containsString:@"]"]) {
//                entity.last_send_message = [EmojiShift stringShiftemoji:[singleDict objectForKey:@"lastMsgContent"]];
//            }
            if ([[singleDict objectForKey:@"lastMsgType"] isEqualToString:@"image"]) {
                entity.last_send_message = @"[图片]";
            }else if ([[singleDict objectForKey:@"lastMsgType"] isEqualToString:@"audio"]){
                entity.last_send_message = @"[语音]";
            }else if ([[singleDict objectForKey:@"lastMsgType"] isEqualToString:@"card"]){
                entity.last_send_message = @"[名片消息]";
            }else if ([[singleDict objectForKey:@"lastMsgType"] isEqualToString:@"RedPacket"]){
                entity.last_send_message = @"[多信红包]恭喜发财，大吉大利";
            }else if ([[singleDict objectForKey:@"lastMsgType"] isEqualToString:@"transfer"]){
                entity.last_send_message = @"[转账]请您确认收款";
            }
            int a = [[NFMyManage new] checkIsHaveNumAndLetter:[[singleDict objectForKey:@"lastMsgTime"] description]];
            if (a == 1) {
                entity.update_time = [[NFbaseViewController new] timestampSwitchTime:[[singleDict objectForKey:@"lastMsgTime"] integerValue]];
            }else{
                entity.update_time = @"";
            }
            entity.originTimeString = [[singleDict objectForKey:@"lastMsgTime"] description];
            entity.last_send_time = [[singleDict objectForKey:@"lastMsgTime"] description];
            entity.IsSingleChat = YES;
            
            entity.unread_message_count = [[singleDict objectForKey:@"unreadMsgNum"] description];
            //msgType
            entity.msgType = [[singleDict objectForKey:@"lastMsgType"] description];
            
            [requestArr addObject:entity];
        }
        
        
        if ([data objectForKey:@"sysChat"]) {
            NSDictionary *sysChat = [data objectForKey:@"sysChat"];
            NSDictionary *lastMsgDict = [sysChat objectForKey:@"lastMsg"];
            if([lastMsgDict isKindOfClass:[NSDictionary class]] ){
                MessageChatListEntity *entity = [MessageChatListEntity new];
                entity.msgType = @"system";
                entity.conversationId = @"0";
                entity.IsSingleChat = YES;
                entity.nickName = @"系统通知";
                //1充值 2取现 3发红包 4收红包 5退款
                if ([[[lastMsgDict objectForKey:@"type"] description] isEqualToString:@"1"]) {
                    entity.last_send_message = @"充值成功";
                }else if ([[[lastMsgDict objectForKey:@"type"] description] isEqualToString:@"2"]){
                    entity.last_send_message = @"余额提现到账";
                }else if ([[[lastMsgDict objectForKey:@"type"] description] isEqualToString:@"5"]){
                    entity.last_send_message = @"红包退款到账";
                }
                if ([lastMsgDict objectForKey:@"time"] && ![[[lastMsgDict objectForKey:@"time"] description] containsString:@"null"]) {
                    entity.update_time = [[NFbaseViewController new] timestampSwitchTime:[[lastMsgDict objectForKey:@"time"] integerValue]];
                    entity.last_send_time = [[lastMsgDict objectForKey:@"time"] description];
                    entity.originTimeString = [[lastMsgDict objectForKey:@"time"] description];
                }else if ([lastMsgDict objectForKey:@"datetime"]){
                    entity.update_time = [[lastMsgDict objectForKey:@"datetime"] description];
                    entity.last_send_time = [[lastMsgDict objectForKey:@"datetime"] description];
                    entity.originTimeString = [[lastMsgDict objectForKey:@"datetime"] description];
                }
                entity.unread_message_count = [[sysChat objectForKey:@"unreadCount"] description];
                entity.receive_user_id = @"0";
                entity.receive_user_name = @"0";
                entity.last_message_id = [[lastMsgDict objectForKey:@"id"] description];;
                [requestArr addObject:entity];
            }
        }
        if ([data objectForKey:@"sysMessage"]) {
            //小助手
            NSDictionary *sysChat = [data objectForKey:@"sysMessage"];
            NSDictionary *lastMsgDict = [sysChat objectForKey:@"lastMsg"];
            if(![lastMsgDict isKindOfClass:[NSDictionary class]]){
//                MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"没有" message:[[data objectForKey:@"sysMessage"] description] sureBtn:@"确认" cancleBtn:nil];
//                alertView.resultIndex = ^(NSInteger index)
//                {
//                    UIPasteboard *pab = [UIPasteboard generalPasteboard];
//                    [pab setString:[data description]];
//                };
//                [alertView showMKPAlertView];
                
                return requestArr;
            }
            
//            MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"有有" message:[[data objectForKey:@"sysMessage"] description] sureBtn:@"确认" cancleBtn:nil];
//            alertView.resultIndex = ^(NSInteger index)
//            {
//                UIPasteboard *pab = [UIPasteboard generalPasteboard];
//                [pab setString:[data description]];
//            };
//            [alertView showMKPAlertView];
            
            MessageChatListEntity *entity = [MessageChatListEntity new];
            entity.msgType = @"system";
            entity.conversationId = @"00";
            entity.IsSingleChat = YES;
            entity.nickName = @"多信小助手";
            //1充值 2取现 3发红包 4收红包 5退款
            
//            if ([[[lastMsgDict objectForKey:@"type"] description] isEqualToString:@"1"]) {
//                entity.last_send_message = @"充值成功";
//            }else if ([[[lastMsgDict objectForKey:@"type"] description] isEqualToString:@"2"]){
//                entity.last_send_message = @"余额提现到账";
//            }else if ([[[lastMsgDict objectForKey:@"type"] description] isEqualToString:@"5"]){
//                entity.last_send_message = @"红包退款到账";
//            }
            if ([lastMsgDict objectForKey:@"time_stamp"] && ![[[lastMsgDict objectForKey:@"time_stamp"] description] containsString:@"null"]) {
                entity.update_time = [[NFbaseViewController new] timestampSwitchTime:[[lastMsgDict objectForKey:@"time_stamp"] integerValue]];
                entity.last_send_time = [[lastMsgDict objectForKey:@"time_stamp"] description];
                entity.originTimeString = [[lastMsgDict objectForKey:@"time_stamp"] description];
            }else if ([lastMsgDict objectForKey:@"datetime"]){
                entity.update_time = [[lastMsgDict objectForKey:@"create_time"] description];
                entity.last_send_time = [[lastMsgDict objectForKey:@"create_time"] description];
                entity.originTimeString = [[lastMsgDict objectForKey:@"create_time"] description];
            }
            entity.unread_message_count = [[sysChat objectForKey:@"unreadCount"] description];
            entity.messageContant = [[lastMsgDict objectForKey:@"content"] description];
            entity.last_send_message = [[lastMsgDict objectForKey:@"content"] description];
            entity.receive_user_id = @"0";
            entity.receive_user_name = @"0";
            entity.last_message_id = [[lastMsgDict objectForKey:@"id"] description];;
            [requestArr addObject:entity];
        }else{
            MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"没有message" message:[[data objectForKey:@"sysMessage"] description] sureBtn:@"确认" cancleBtn:nil];
            alertView.resultIndex = ^(NSInteger index)
            {
                UIPasteboard *pab = [UIPasteboard generalPasteboard];
                [pab setString:[data description]];
            };
            [alertView showMKPAlertView];
        }
        
        
        return requestArr;
    }
    return nil;
}

//未读历史消息 消息历史 单聊 4003
+(id)ConvasationHistoryChatContantParser:(NSArray *)data{
    NSMutableArray *chatDataArr = [NSMutableArray new];
    for (NSDictionary *chatDataa in data) {
        NSDictionary *chatData = [self nullDic:chatDataa];
        
        //兼容安卓表情
//        if([[chatData objectForKey:@"message_content"] isKindOfClass:[NSString class]] && [NFMyManage validateContainsEmoji:[chatData objectForKey:@"message_content"]]){
//            NSString *str = [chatData objectForKey:@"message_content"];
//            str = [str stringByReplacingOccurrencesOfString:@"[" withString:@""];
//            str = [str stringByReplacingOccurrencesOfString:@"]" withString:@""];
//            NSMutableDictionary *diccc = [NSMutableDictionary dictionaryWithDictionary:chatData];
//            [diccc setValue:str forKey:@"message_content"];
//            chatData = [NSDictionary dictionaryWithDictionary:diccc];
//        }else if([[chatData objectForKey:@"message_content"] isKindOfClass:[NSString class]] &&  [[chatData objectForKey:@"message_content"] length] <= 4 && [[[chatData objectForKey:@"message_content"] description] containsString:@"["]&& [[[chatData objectForKey:@"message_content"] description] containsString:@"]"]){
//            NSString *str = [chatData objectForKey:@"message_content"];
//            str = [str stringByReplacingOccurrencesOfString:@"[" withString:@""];
//            str = [str stringByReplacingOccurrencesOfString:@"]" withString:@""];
//            NSMutableDictionary *diccc = [NSMutableDictionary dictionaryWithDictionary:chatData];
//            [diccc setValue:str forKey:@"message_content"];
//            chatData = [NSDictionary dictionaryWithDictionary:diccc];
//        }else
            if([[chatData objectForKey:@"message_content"] isKindOfClass:[NSString class]] && [[[chatData objectForKey:@"message_content"] description] containsString:@"["]&& [[[chatData objectForKey:@"message_content"] description] containsString:@"]"]){
            NSString *str = [chatData objectForKey:@"message_content"];
            str = [str stringByReplacingOccurrencesOfString:@"[" withString:@""];
            str = [str stringByReplacingOccurrencesOfString:@"]" withString:@""];
            NSMutableDictionary *diccc = [NSMutableDictionary dictionaryWithDictionary:chatData];
            [diccc setValue:str forKey:@"message_content"];
            chatData = [NSDictionary dictionaryWithDictionary:diccc];
        }
        
        if ([[chatData objectForKey:@"msg_type"] isEqualToString:@"RedPacket"] || [[chatData objectForKey:@"msg_type"] isEqualToString:@"transfer"]) {
            //红包消息
            MessageChatEntity *entity = [MessageChatEntity new];
            
            NSDictionary *redDictFirst = [chatData objectForKey:@"message_content"];
            
            entity.type = @"3";
            entity.msgType = @"3";
            if ([[[redDictFirst objectForKey:@"type"] description] isEqualToString:@"2"] && [[chatData objectForKey:@"msg_type"] isEqualToString:@"transfer"]) {
                entity.type = @"6";
                entity.msgType = @"6";
                entity.headPicPath = [NSString stringWithFormat:@"%.2f",[[[redDictFirst objectForKey:@"totalMoney"] description] floatValue]/100];
                entity.message_content = [redDictFirst objectForKey:@"content"];
                
            }
            entity.chatId = [[chatData objectForKey:@"id"] description];
            entity.IsSingleChat = YES;
            entity.user_id = [[chatData objectForKey:@"user_id"] description];
            entity.user_name = [[chatData objectForKey:@"user_name"] description];
            entity.nickName = [[chatData objectForKey:@"nickname"] description];
            if (entity.nickName.length == 0) {
                entity.nickName = [[chatData objectForKey:@"user_name"] description];
            }
            //        entity.receive_user_id = [[chatData objectForKey:@"receive_user_id"] description];
            //        entity.receive_user_name = [[chatData objectForKey:@"receive_user_name"] description];
            
            //entity.message_content = [[chatData objectForKey:@"message_content"] description];
            entity.IsSingleChat = YES;
            NSDictionary *redDict = [chatData objectForKey:@"message_content"];
            if([redDict isKindOfClass:[NSDictionary class]]){
                entity.message_content = [[redDict objectForKey:@"content"] description];//
            }else{
                entity.message_content = @"";
            }
            entity.redpacketString = [[redDict objectForKey:@"redpacketId"] description];
            int b = [[NFMyManage new] checkIsHaveNumAndLetter:[[chatData objectForKey:@"create_time"] description]];
            if (b == 1) {
                NSInteger create_time = [[chatData objectForKey:@"create_time"] integerValue];
                entity.create_time = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"HH:mm"];
                NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:create_time];
                if (![confromTimesp isThisYear]) {
                    entity.create_time_head = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"YYYY年MM月dd日"];
                }else{
                    entity.create_time_head = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"MM月dd日"];
                }
            }else{
                entity.create_time = @"";
                entity.create_time_head = @"";
            }
            if ([entity.user_name isEqualToString:[NFUserEntity shareInstance].userName]) {
                entity.isSelf = @"0";
            }else{
                entity.isSelf = @"1";
            }
            NSDate *currentDate = [NSDate date];//获取当前时间，日期
            //        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            //        [dateFormatter setDateFormat:@"YYYYMMddhhmmssSS"];
            NSTimeInterval interval = [currentDate timeIntervalSince1970];
            //记录已读时间
            entity.localReceiveTime = interval;
            entity.localReceiveTimeString = [[chatData objectForKey:@"group_msg_time"] description];
            
            [chatDataArr addObject:entity];
        }else{
            MessageChatEntity *entity = [MessageChatEntity new];
            entity.chatId = [[chatData objectForKey:@"id"] description];
            entity.IsSingleChat = YES;
            entity.user_id = [[chatData objectForKey:@"user_id"] description];
            entity.user_name = [[chatData objectForKey:@"user_name"] description];
            entity.nickName = [[chatData objectForKey:@"nickname"] description];
            if (entity.nickName.length == 0) {
                entity.nickName = [[chatData objectForKey:@"user_name"] description];
            }
            //        entity.receive_user_id = [[chatData objectForKey:@"receive_user_id"] description];
            //        entity.receive_user_name = [[chatData objectForKey:@"receive_user_name"] description];
            
            entity.message_content = [[chatData objectForKey:@"message_content"] description];
            
            entity.msgType = [[chatData objectForKey:@"msg_type"] description];
            if (entity.msgType.length > 0) {
                if ([[chatData objectForKey:@"msg_type"] isEqualToString:@"normal"]) {
                    entity.type = @"0";
                }else if ([[chatData objectForKey:@"msg_type"] isEqualToString:@"image"]){
                    //为图片
                    entity.message_content = @"";
                    entity.type = @"1";
                    if ([chatData objectForKey:@"fileInfo"]) {
                        NSDictionary *fileInfo = [chatData objectForKey:@"fileInfo"];
                        entity.pictureScale = [[[fileInfo objectForKey:@"imgRatio"] description] floatValue];
                        entity.pictureUrl = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[fileInfo objectForKey:@"filePath"]];
                        entity.fileId = [[fileInfo objectForKey:@"fileId"] description];
                    }else{
                        entity.pictureScale = 1;
                    }
                }else if ([[chatData objectForKey:@"msg_type"] isEqualToString:@"audio"]){
                    //为语音
                    entity.message_content = @"";
                    entity.type = @"2";
                    NSData *voiceData   = [[NSData alloc] initWithBase64Encoding:[[chatData objectForKey:@"message_content"] description]];
                    entity.voiceData = voiceData;
                    entity.strVoiceTime =[[chatData objectForKey:@"audio_time"] description];
                }else if([[chatData objectForKey:@"msg_type"] isEqualToString:@"card"]){
                    //名片
                    NSDictionary *contentDict = [chatData objectForKey:@"message_content"];
                    entity.message_content = [NSString stringWithFormat:@"[个人名片]%@",[[contentDict objectForKey:@"nickname"] description]];
                    entity.type = @"4";
                    entity.fileId = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[[contentDict objectForKey:@"photo"] description]];
                    entity.redpacketString = [[contentDict objectForKey:@"user_id"] description];
                    entity.strVoiceTime = [[contentDict objectForKey:@"user_name"] description];
                    entity.pictureUrl = [[contentDict objectForKey:@"nickname"] description];
                    
                }
            }
            int b = [[NFMyManage new] checkIsHaveNumAndLetter:[[chatData objectForKey:@"create_time"] description]];
            if (b == 1) {
                NSInteger create_time = [[chatData objectForKey:@"create_time"] integerValue];
                entity.create_time = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"HH:mm"];
                NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:create_time];
                if (![confromTimesp isThisYear]) {
                    entity.create_time_head = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"YYYY年MM月dd日"];
                }else{
                    entity.create_time_head = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"MM月dd日"];
                }
                
            }else{
                entity.create_time = @"";
                entity.create_time_head = @"";
            }
            
            //如果发送者名字和本地userid相同，则标记为本人发送 0是 1不是
            if ([entity.user_name isEqualToString:[NFUserEntity shareInstance].userName]) {
                entity.isSelf = @"0";
            }else{
                entity.isSelf = @"1";
            }
            NSDate *currentDate = [NSDate date];//获取当前时间，日期
            //        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            //        [dateFormatter setDateFormat:@"YYYYMMddhhmmssSS"];
            //        NSDate *currentDate = [NSDate date];//获取当前时间，日期
            NSTimeInterval interval = [currentDate timeIntervalSince1970];
            //记录已读时间
            entity.localReceiveTime = interval;
            entity.localReceiveTimeString = [NSString stringWithFormat:@"%ld",entity.localReceiveTime];
#pragma mark - 时间判定 判断是否add到界面去
            //        BOOL ret = [NFbaseViewController compaTodayDateWithDate:[[chatData objectForKey:@"create_time"] integerValue]];
            //        if (!ret) {
            //            //如果过了期限 则设置字段
            //            entity.yuehouYinCang = @"1";
            //        }
            //entity.redpacketString = @"";
            [chatDataArr addObject:entity];
        }
        }
    
    //当数据多于三条 设置隐藏后面部分暂时
//    if (chatDataArr.count > 3) {
//        [chatDataArr removeObjectsInRange:NSMakeRange(2, chatDataArr.count - 3)];
//    }
    return chatDataArr;
}




//历史消息 群聊5012
+(id)ConvasationGroupHistoryChatContantParser:(NSArray *)data{
    NSMutableArray *chatDataArr = [NSMutableArray new];
    BOOL InNeedAite = NO;
    for (NSDictionary *chatDataa in data) {
        NSDictionary *chatData = [self nullDic:chatDataa];
        if ([[chatData objectForKey:@"group_msg_type"] isEqualToString:@"RedPacket"]) {
            //红包消息
            MessageChatEntity *entity = [MessageChatEntity new];
            
            entity.type = @"3";
            entity.msgType = @"3";
            
            entity.chatId = [[chatData objectForKey:@"group_msg_id"] description];
            
            if ([[[chatData objectForKey:@"senderPhoto"] description] containsString:@"http"] || [[[chatData objectForKey:@"senderPhoto"] description] containsString:@"wx.qlogo.cn"]) {
                entity.headPicPath = [[chatData objectForKey:@"senderPhoto"] description];
            }else{
                entity.headPicPath = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[[chatData objectForKey:@"senderPhoto"] description]];
            }
            entity.IsSingleChat = NO;
            entity.user_id = [[chatData objectForKey:@"group_msg_sender"] description];
            entity.user_name = [[chatData objectForKey:@"group_msg_sender_name"] description];
            entity.nickName = [[chatData objectForKey:@"senderNickName"] description];
            entity.originalNickName = [[chatData[@"group_msg_sender_original_name"] description] length] > 0?[chatData[@"group_msg_sender_original_name"] description]:entity.nickName;
            if (entity.nickName.length == 0) {
                entity.nickName = [[chatData objectForKey:@"group_msg_sender_name"] description];
            }
            
            
            //红包祝福语 group_msg_content为红包信息
            NSDictionary *redDict = [chatData objectForKey:@"group_msg_content"];
            if([redDict isKindOfClass:[NSDictionary class]]){
                entity.message_content = [[redDict objectForKey:@"content"] description];//
            }else{
                entity.message_content = @"";
                continue;
            }
            //红包id
//            entity.fileId = [[chatData objectForKey:@"hongbaoid"] description];//
            entity.redpacketString = [[redDict objectForKey:@"redpacketId"] description];//
            
            int b = [[NFMyManage new] checkIsHaveNumAndLetter:[[chatData objectForKey:@"group_msg_time"] description]];
            if (b == 1) {
                NSInteger create_time = [[chatData objectForKey:@"group_msg_time"] integerValue];
                entity.create_time = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"HH:mm"];
                //entity.message_read_time = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"HH:mm"];
                NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:create_time];
                if (![confromTimesp isThisYear]) {
                    entity.create_time_head = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"YYYY年MM月dd日"];
                }else{
                    entity.create_time_head = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"MM月dd日"];
                }
            }else{
                entity.create_time = @"";
                entity.create_time_head = @"";
            }
            if ([entity.user_name isEqualToString:[NFUserEntity shareInstance].userName]) {
                entity.isSelf = @"0";
            }else{
                entity.isSelf = @"1";
            }
            
            NSDate *currentDate = [NSDate date];//获取当前时间，日期
            //        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            //        [dateFormatter setDateFormat:@"YYYYMMddhhmmssSS"];
            NSTimeInterval interval = [currentDate timeIntervalSince1970];
            //记录已读时间
            entity.localReceiveTime = interval;
            entity.localReceiveTimeString = [[chatData objectForKey:@"group_msg_time"] description];
            [chatDataArr addObject:entity];
            
        }else{
            
            
            //兼容安卓表情
//            if([[chatData objectForKey:@"group_msg_content"] isKindOfClass:[NSString class]] && [NFMyManage validateContainsEmoji:[chatData objectForKey:@"group_msg_content"]]){
//                NSString *str = [chatData objectForKey:@"group_msg_content"];
//                str = [str stringByReplacingOccurrencesOfString:@"[" withString:@""];
//                str = [str stringByReplacingOccurrencesOfString:@"]" withString:@""];
//                NSMutableDictionary *diccc = [NSMutableDictionary dictionaryWithDictionary:chatData];
//                [diccc setValue:str forKey:@"group_msg_content"];
//                chatData = [NSDictionary dictionaryWithDictionary:diccc];
//            }else if([[chatData objectForKey:@"group_msg_content"] isKindOfClass:[NSString class]] && [[chatData objectForKey:@"group_msg_content"] length] <= 4 && [[[chatData objectForKey:@"group_msg_content"] description] containsString:@"["]&& [[[chatData objectForKey:@"group_msg_content"] description] containsString:@"]"]){
//                NSString *str = [chatData objectForKey:@"group_msg_content"];
//                str = [str stringByReplacingOccurrencesOfString:@"[" withString:@""];
//                str = [str stringByReplacingOccurrencesOfString:@"]" withString:@""];
//                NSMutableDictionary *diccc = [NSMutableDictionary dictionaryWithDictionary:chatData];
//                [diccc setValue:str forKey:@"group_msg_content"];
//                chatData = [NSDictionary dictionaryWithDictionary:diccc];
//            }else
                if([[chatData objectForKey:@"group_msg_content"] isKindOfClass:[NSString class]] && [[[chatData objectForKey:@"group_msg_content"] description] containsString:@"["]&& [[[chatData objectForKey:@"group_msg_content"] description] containsString:@"]"]){
                NSString *str = [chatData objectForKey:@"group_msg_content"];
                str = [str stringByReplacingOccurrencesOfString:@"[" withString:@""];
                str = [str stringByReplacingOccurrencesOfString:@"]" withString:@""];
                NSMutableDictionary *diccc = [NSMutableDictionary dictionaryWithDictionary:chatData];
                [diccc setValue:str forKey:@"group_msg_content"];
                chatData = [NSDictionary dictionaryWithDictionary:diccc];
            }
            
            
            MessageChatEntity *entity = [MessageChatEntity new];
            entity.chatId = [[chatData objectForKey:@"group_msg_id"] description];
            if ([[[chatData objectForKey:@"senderPhoto"] description] containsString:@"http"] || [[[chatData objectForKey:@"senderPhoto"] description] containsString:@"wx.qlogo.cn"]) {
                entity.headPicPath = [[chatData objectForKey:@"senderPhoto"] description];
            }else{
                entity.headPicPath = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[[chatData objectForKey:@"senderPhoto"] description]];
            }
            entity.IsSingleChat = NO;
            entity.user_id = [[chatData objectForKey:@"group_msg_sender"] description];
            //        entity.receive_user_id = [[chatData objectForKey:@"group_id"] description];
            //        entity.receive_user_name = [[chatData objectForKey:@"groupName"] description];
            //        entity.user_id = [[chatData objectForKey:@"group_id"] description];
            entity.user_name = [[chatData objectForKey:@"group_msg_sender_name"] description];
            entity.nickName = [chatData objectForKey:@"senderCommentName"];
            if (entity.nickName.length == 0) {
                entity.nickName = [[chatData objectForKey:@"senderNickName"] description];
                if (entity.nickName.length == 0) {
                    entity.nickName = [[chatData objectForKey:@"group_msg_sender_name"] description];
                }
            }
            entity.originalNickName =  [[chatData[@"group_msg_sender_original_name"] description] length] > 0?[chatData[@"group_msg_sender_original_name"] description]:entity.nickName;
            entity.message_content = [[chatData objectForKey:@"group_msg_content"] description];//消息内容
            //检查是否有。艾特的消息
            if(!InNeedAite){
                NSRange rangee = [entity.message_content rangeOfString:@"@"];
                if (rangee.length > 0) {
                    NSRange rangeeee = [entity.message_content rangeOfString:[NFUserEntity shareInstance].nickName];
                    NSRange rangeeeeeee = [entity.message_content rangeOfString:@"所有人"];
                    if ((rangee.location < rangeeee.location || rangee.location < rangeeeeeee.location) && (rangeeee.length > 0 || rangeeeeeee.length > 0)) {
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"qunzuAiteBool%@",[[chatData objectForKey:@"group_id"] description]]];
                        [[NSUserDefaults standardUserDefaults] setInteger:[entity.chatId integerValue] forKey:[NSString stringWithFormat:@"qunzuAite%@",[[chatData objectForKey:@"group_id"] description]]];
                        InNeedAite = YES;
                    }
                }
            }
            
            entity.msgType = [[chatData objectForKey:@"group_msg_type"] description];//消息类型
            if (entity.msgType.length > 0) {
                if ([[chatData objectForKey:@"group_msg_type"] isEqualToString:@"normal"]) {
                    entity.type = @"0";
                }else if ([[chatData objectForKey:@"group_msg_type"] isEqualToString:@"image"]){
                    //为图片
                    entity.message_content = @"";
                    entity.type = @"1";
                    if ([chatData objectForKey:@"fileInfo"]) {
                        NSDictionary *fileInfo = [chatData objectForKey:@"fileInfo"];
                        entity.pictureScale = [[[fileInfo objectForKey:@"imgRatio"] description] floatValue];
                        entity.pictureUrl = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[fileInfo objectForKey:@"filePath"]];
                        entity.fileId = [[fileInfo objectForKey:@"fileId"] description];
                    }else{
                        entity.pictureScale = 1;
                    }
                }else if ([[chatData objectForKey:@"group_msg_type"] isEqualToString:@"audio"]){
                    //为语音
                    entity.message_content = @"";
                    entity.type = @"2";
                    NSData *voiceData   = [[NSData alloc] initWithBase64Encoding:[[chatData objectForKey:@"group_msg_content"] description]];
                    entity.voiceData = voiceData;
                    entity.strVoiceTime =[[chatData objectForKey:@"audio_time"] description];
                }else if([[chatData objectForKey:@"group_msg_type"] isEqualToString:@"card"]){
                    //名片
                    NSDictionary *contentDict = [chatData objectForKey:@"group_msg_content"];
                    entity.message_content = [NSString stringWithFormat:@"[个人名片]%@",[[contentDict objectForKey:@"nickname"] description]];
                    entity.type = @"4";
                    entity.fileId = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[[contentDict objectForKey:@"photo"] description]];
                    entity.redpacketString = [[contentDict objectForKey:@"user_id"] description];
                    entity.strVoiceTime = [[contentDict objectForKey:@"user_name"] description];
                    entity.pictureUrl = [[contentDict objectForKey:@"nickname"] description];
                    
                }
            }else{
                entity.type = @"4";//未知消息类型
            }
            
            int b = [[NFMyManage new] checkIsHaveNumAndLetter:[[chatData objectForKey:@"group_msg_time"] description]];
            if (b == 1) {
                NSInteger create_time = [[chatData objectForKey:@"group_msg_time"] integerValue];
                entity.create_time = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"HH:mm"];
                NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:create_time];
                if (![confromTimesp isThisYear]) {
                    entity.create_time_head = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"YYYY年MM月dd日"];
                }else{
                    entity.create_time_head = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"MM月dd日"];
                }
            }else{
                entity.create_time = @"";
                entity.create_time_head = @"";
            }
            
            //如果发送者名字和本地userid相同，则标记为本人发送 0是 1不是
            if ([entity.user_name isEqualToString:[NFUserEntity shareInstance].userName]) {
                entity.isSelf = @"0";
            }else{
                entity.isSelf = @"1";
            }
            NSDate *currentDate = [NSDate date];//获取当前时间，日期
            //        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            //        [dateFormatter setDateFormat:@"YYYYMMddhhmmssSS"];
            NSTimeInterval interval = [currentDate timeIntervalSince1970];
            //记录已读时间
            entity.localReceiveTime = interval;
            entity.localReceiveTimeString = [NSString stringWithFormat:@"%ld",entity.localReceiveTime];
#pragma mark - 时间判定 判断是否add到界面去
            //        BOOL ret = [NFbaseViewController compaTodayDateWithDate:[[chatData objectForKey:@"create_time"] integerValue]];
            //        if (!ret) {
            //            //如果过了期限 则设置字段
            //            entity.yuehouYinCang = @"1";
            //        }
            
            [chatDataArr addObject:entity];
        }
        }
        
        
    //当数据多于三条 设置隐藏后面部分暂时
    //    if (chatDataArr.count > 3) {
    //        [chatDataArr removeObjectsInRange:NSMakeRange(2, chatDataArr.count - 3)];
    //    }
    return chatDataArr;
}

//接收到远程消息 4002
+(id)GotNormalMessageContantParser:(NSDictionary *)data{
    UUMessageFrame *messageFrame = [[UUMessageFrame alloc]init];
    UUMessage *messagee = [UUMessage new];
    //生成chatid 日后向服务器索取
//    NSInteger a = arc4random()%899999+100000;
//    NSDate *currentDate = [NSDate date];//获取当前时间，日期
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"YYYYMMddhhmmssSS"];
//    NSString *dateString = [dateFormatter stringFromDate:currentDate];
//    messagee.chatId = [NSString stringWithFormat:@"%@%ld",dateString,a];
    messagee.chatId = [[data objectForKey:@"messageId"] description];
    //获取当前时间设置
//    [dateFormatter setDateFormat:@"YYYY/MM/dd hh:mm:ss SS"];
//    NSString *dateStringg = [dateFormatter stringFromDate:currentDate];
//    messagee.strTime = dateStringg;
    int b = [[NFMyManage new] checkIsHaveNumAndLetter:[[data objectForKey:@"create_time"] description]];
    if (b == 1) {
        NSInteger create_time = [[data objectForKey:@"create_time"] integerValue];
        messagee.strTime = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"HH:mm"];
        NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:create_time];
        if (![confromTimesp isThisYear]) {
            messagee.strTimeHeader = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"YYYY年MM月dd日"];
        }else{
            messagee.strTimeHeader = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"MM月dd日"];
        }
    }else{
        messagee.strTime = @"";
        messagee.strTimeHeader = @"";
    }
    
    //时间设置 需要服务器 给一个时间
//    messagee.strTime = [[NFbaseViewController new] timestampSwitchTime:1500363113];
    
    NSDate *date = [NSDate date];
    NSTimeInterval interval = [date timeIntervalSince1970];
    messagee.strTime = [[NFbaseViewController new] timestampSwitchTime:interval anddFormatter:@"HH:mm"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:interval];
    if (![confromTimesp isThisYear]) {
        messagee.strTimeHeader = [[NFbaseViewController new] timestampSwitchTime:interval anddFormatter:@"YYYY年MM月dd日"];
    }else{
        messagee.strTimeHeader = [[NFbaseViewController new] timestampSwitchTime:interval anddFormatter:@"MM月dd日"];
    }
//    messagee.strIcon = @"http://img0.bdstatic.com/img/image/shouye/xinshouye/mingxing16.jpg";
    messagee.strIcon = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[data objectForKey:@"fromPhoto"]];
    messagee.userName = [data objectForKey:@"fromName"];
    messagee.nickName = [[data objectForKey:@"fromNickName"] description];
    if (messagee.nickName.length == 0) {
        messagee.userName = [data objectForKey:@"fromName"];
    }
    messagee.strContent = [data objectForKey:@"content"];
    if (![[data objectForKey:@"msgType"] isKindOfClass:[NSString class]] || [[data objectForKey:@"msgType"] isEqualToString:@"normal"]) {
        //为消息
        messagee.strContent = [[data objectForKey:@"content"] description];
//        if (messagee.strContent.length > 0 && messagee.strContent.length < 100 && [messagee.strContent containsString:@"["] && [messagee.strContent containsString:@"]"]) {
//            messagee.strContent = [EmojiShift stringShiftemoji:messagee.strContent];
//        }
    }else if ([[data objectForKey:@"msgType"] isEqualToString:@"image"]){
        //为图片
        messagee.strContent = @"";
        messagee.type = UUMessageTypePicture;
//        messagee.picture = [ClearManager Base64StringToImage:[data objectForKey:@"content"]];
        messagee.pictureUrl = [[data objectForKey:@"content"] description];
        if ([data objectForKey:@"fileInfo"]) {
            NSDictionary *fileInfo = [data objectForKey:@"fileInfo"];
            messagee.pictureScale = [[[fileInfo objectForKey:@"imgRatio"] description] floatValue];
            messagee.pictureUrl = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[fileInfo objectForKey:@"filePath"]];
            messagee.fileId = [[fileInfo objectForKey:@"fileId"] description];
        }else{
            messagee.pictureScale = 1;
        }
    }else if ([[data objectForKey:@"msgType"] isEqualToString:@"audio"]){
        //为语音
        messagee.strContent = @"";
        messagee.type = UUMessageTypeVoice;
        NSData *voiceData   = [[NSData alloc] initWithBase64Encoding:[data objectForKey:@"content"]];
        //        NSData *voiceData = [messagee.strContent dataUsingEncoding:NSUTF8StringEncoding];
        messagee.voice = voiceData;
        messagee.strVoiceTime = [[data objectForKey:@"audioTime"] description];
    }else if([[data objectForKey:@"msgType"] isEqualToString:@"card"]){
        NSDictionary *personDict = [data objectForKey:@"content"];
        messagee.strContent = [NSString stringWithFormat:@"[个人名片]%@",[[personDict objectForKey:@"nickname"] description]];
        messagee.type = UUMessageTypeRecommendCard;
        messagee.fileId = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[[personDict objectForKey:@"photo"] description]];
        
        messagee.strId = [[personDict objectForKey:@"user_id"] description];
        messagee.strVoiceTime = [[personDict objectForKey:@"user_name"] description];
        messagee.pictureUrl = [[personDict objectForKey:@"nickname"] description];
    }
    
    messagee.from = UUMessageFromOther;
    
    //记录已读时间
    messagee.localReceiveTime = interval;
    messagee.localReceiveTimeString = [NSString stringWithFormat:@"%ld",messagee.localReceiveTime];
//    BOOL ret = [NFbaseViewController compaTodayDateWithDate:[[data objectForKey:@"create_time"] integerValue]];
//    //如果不是yes 则是过期消息
//    if (!ret) {
//        messagee.yuehouYinCang = @"1";
//    }
    messagee.redpacketString = @"";
    [messageFrame setMessage:messagee];
    return messageFrame;
    
}

//接收到单聊红包消息
+(id)GotNormalRedPacketMessageContantParser:(NSDictionary *)data{
    UUMessageFrame *messageFrame = [[UUMessageFrame alloc]init];
    UUMessage *messagee = [UUMessage new];
    messagee.chatId = [[data objectForKey:@"messageId"] description];
    int b = [[NFMyManage new] checkIsHaveNumAndLetter:[[data objectForKey:@"create_time"] description]];
    if (b == 1) {
        NSInteger create_time = [[data objectForKey:@"create_time"] integerValue];
        messagee.strTime = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"HH:mm"];
        NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:create_time];
        if (![confromTimesp isThisYear]) {
            messagee.strTimeHeader = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"YYYY年MM月dd日"];
        }else{
            messagee.strTimeHeader = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"MM月dd日"];
        }
    }else{
        messagee.strTime = @"";
        messagee.strTimeHeader = @"";
    }
    //时间设置 需要服务器 给一个时间
    //    messagee.strTime = [[NFbaseViewController new] timestampSwitchTime:1500363113];
    
    NSDate *date = [NSDate date];
    NSTimeInterval interval = [date timeIntervalSince1970];
    messagee.strTime = [[NFbaseViewController new] timestampSwitchTime:interval anddFormatter:@"HH:mm"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:interval];
    if (![confromTimesp isThisYear]) {
        messagee.strTimeHeader = [[NFbaseViewController new] timestampSwitchTime:interval anddFormatter:@"YYYY年MM月dd日"];
    }else{
        messagee.strTimeHeader = [[NFbaseViewController new] timestampSwitchTime:interval anddFormatter:@"MM月dd日"];
    }
    //    messagee.strIcon = @"http://img0.bdstatic.com/img/image/shouye/xinshouye/mingxing16.jpg";
    messagee.strIcon = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[data objectForKey:@"fromPhoto"]];
    messagee.userName = [data objectForKey:@"fromName"];
    messagee.nickName = [[data objectForKey:@"fromNickName"] description];
    if (messagee.nickName.length == 0) {
        messagee.userName = [data objectForKey:@"fromName"];
    }
    messagee.strContent = [data objectForKey:@"content"];
    NSDictionary *redContentD = [data objectForKey:@"group_msg_content"];
    messagee.redpacketString = [redContentD objectForKey:@"redpacketId"];
    messagee.type = UUMessageTypeRed;
    if ([messagee.userName isEqualToString:[NFUserEntity shareInstance].userName]) {
        //如果是本人
        messagee.from = UUMessageFromMe;
    }else{
        messagee.from = UUMessageFromOther;
    }
    //记录已读时间
    messagee.localReceiveTime = interval;
    messagee.localReceiveTimeString = [NSString stringWithFormat:@"%ld",messagee.localReceiveTime];
    //    BOOL ret = [NFbaseViewController compaTodayDateWithDate:[[data objectForKey:@"create_time"] integerValue]];
    //    //如果不是yes 则是过期消息
    //    if (!ret) {
    //        messagee.yuehouYinCang = @"1";
    //    }
    messagee.redpacketString = @"";
    [messageFrame setMessage:messagee];
    return messageFrame;
}




//请求群组列表 GroupListEntity
+(id)groupListManagerParserr:(NSArray *)data{
    NSMutableArray *backArr = [@[] mutableCopy];
    NSMutableArray *lastBackArr = [@[] mutableCopy];
    
    for (NSDictionary *dict in data) {
        GroupListEntity *entity = [GroupListEntity yy_modelWithDictionary:dict];
        entity.groupPhoto = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[[dict objectForKey:@"groupPhoto"] description]];
        [lastBackArr addObject:entity];
    }
    
    return lastBackArr;
}

//创建群组成功返回
+(id)groupCreateSuccessManagerParserr:(NSDictionary *)data{
    
    GroupCreateSuccessEntity *entity = [GroupCreateSuccessEntity yy_modelWithJSON:data];
    NSDictionary *creatorDict = [data objectForKey:@"creator"];
    entity.creatorName = [[creatorDict objectForKey:@"user_name"] description];
    entity.createTime = [[creatorDict objectForKey:@"createTime"] description];
    //群组头像 刚创建好。还没有头像【服务器说拼接】
    if ([[[data objectForKey:@"groupPhoto"] description] containsString:@"http"]) {
        entity.groupHeadPic = [[data objectForKey:@"groupPhoto"] description];
    }else{
        entity.groupHeadPic = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[[data objectForKey:@"groupPhoto"] description]];
    }
    
    NSMutableArray *backArr = [NSMutableArray new];
    for (NSDictionary *dict in [data objectForKey:@"groupUser"]?[data objectForKey:@"groupUser"]:[data objectForKey:@"groupAllUser"]) {
        ZJContact *entityy = [ZJContact yy_modelWithJSON:dict];
        entityy.friend_userid = [[dict objectForKey:@"user_id"] description];
        entityy.friend_username = [[dict objectForKey:@"user_name"] description];
        if ([dict objectForKey:@"photo"]) {
//            if ([[[dict objectForKey:@"photo"] description] containsString:@"head_man"]) {
//                entityy.iconUrl = [[dict objectForKey:@"photo"] description];
//            }else{
                if ([[[dict objectForKey:@"photo"] description] length] == 0) {
                    entityy.iconUrl = @"";
                }else{
                    if ([[[dict objectForKey:@"photo"] description] containsString:@"http"] || [[[dict objectForKey:@"photo"] description] containsString:@"wx.qlogo.cn"]) {
                        entityy.iconUrl = [[dict objectForKey:@"photo"] description];
                    }else{
                        entityy.iconUrl = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[[dict objectForKey:@"photo"] description]];
                    }
                }
//            }
        }else{
            NSDictionary *info =[dict objectForKey:@"user_info"];
            entityy.friend_nickname = [[info objectForKey:@"nickname"] description];
            if (entityy.friend_nickname.length == 0) {
                entityy.friend_nickname = [[info objectForKey:@"user_name"] description];
            }
//            if ([[[info objectForKey:@"photo"] description] containsString:@"head_man"]) {
//                entityy.iconUrl = [[info objectForKey:@"photo"] description];
//            }else{
                if ([[[info objectForKey:@"photo"] description] length] == 0) {
                    entityy.iconUrl = @"";
                }else{
                    if ([[[info objectForKey:@"photo"] description] containsString:@"http"] || [[[info objectForKey:@"photo"] description] containsString:@"wx.qlogo.cn"]) {
                        entityy.iconUrl = [[info objectForKey:@"photo"] description];
                    }else{
                        entityy.iconUrl = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[[info objectForKey:@"photo"] description]];
                    }
                }
//            }
        }
        [backArr addObject:entityy];
    }
    NSDictionary *perator = [data objectForKey:@"creator"];
    entity.exit_group = [[perator objectForKey:@"exit_group"] description];
    entity.exit_time = [[perator objectForKey:@"exit_time"] description];
    entity.in_group_name = [[perator objectForKey:@"in_group_name"] description];
    entity.is_admin = [[perator objectForKey:@"is_admin"] description];
    entity.is_creator = [[perator objectForKey:@"is_creator"] description];
    entity.join_time = [[perator objectForKey:@"join_time"] description];
    entity.user_id = [[perator objectForKey:@"user_id"] description];
    entity.user_name = [[perator objectForKey:@"user_name"] description];
    entity.groupAllUser = backArr;
    return entity;
}


//群组成员详情数组 解析
+(id)groupmemberManagerParserr:(NSArray *)dataArr{
    NSMutableArray *memeberArr = [NSMutableArray new];
        for (NSDictionary *dict in dataArr) {
            ZJContact *entityy = [ZJContact yy_modelWithJSON:dict];
            entityy.friend_userid = [[dict objectForKey:@"userId"] description];
            if(!entityy.friend_userid || entityy.friend_userid.length == 0){
                entityy.friend_userid = [[dict objectForKey:@"user_id"] description];
            }
            entityy.friend_username = [[dict objectForKey:@"user_name"] description];
            entityy.friend_nickname = [[dict objectForKey:@"nickname"] description];
            if (entityy.friend_nickname.length == 0) {
                entityy.friend_nickname = [[dict objectForKey:@"user_name"] description];
                entityy.in_group_name = [[dict objectForKey:@"user_name"] description];
            }
            entityy.friend_originalnickname = [[dict objectForKey:@"nickname"] description];
            if ([[[dict objectForKey:@"photo"] description] containsString:@"http"] || [[[dict objectForKey:@"photo"] description] containsString:@"wx.qlogo.cn"]) {
                entityy.iconUrl = [[dict objectForKey:@"photo"] description];
            }else{
                entityy.iconUrl = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[[dict objectForKey:@"photo"] description]];
            }
            [memeberArr addObject:entityy];
        }
    return memeberArr;
}

//群组详情
+(id)groupDetailManagerParserr:(NSDictionary *)data{
    GroupCreateSuccessEntity *entity = [GroupCreateSuccessEntity yy_modelWithJSON:data];
    entity.groupHeadPic = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[data objectForKey:@"groupPhoto"]];
    //上面设置了
    //entity.isMsgForbidden = [[data objectForKey:@"isMsgForbidden"] description];
    NSDictionary *creatorDict;
    if ([data objectForKey:@"creator"]) {
        creatorDict = [data objectForKey:@"creator"];
        
    }else{
        creatorDict = @{};
    }
    if ([creatorDict isKindOfClass:[NSDictionary class]]) {
        entity.creatorName = [[creatorDict objectForKey:@"user_name"] description];
        entity.createTime = [[creatorDict objectForKey:@"createTime"] description];
    }
    
    
    NSMutableArray *backArr = [NSMutableArray new];
    NSMutableArray *adminArr = [NSMutableArray new];
    NSMutableArray *createArr = [NSMutableArray new];
    for (NSDictionary *dict in [data objectForKey:@"groupUser"]) {
        ZJContact *entityy = [ZJContact yy_modelWithJSON:dict];
        entityy.friend_userid = [[dict objectForKey:@"user_id"] description];
        entityy.friend_username = [[dict objectForKey:@"user_name"] description];
        entityy.friend_nickname = [[dict objectForKey:@"in_group_name"] description];
        if (entityy.friend_nickname.length == 0) {
            entityy.friend_nickname = [[dict objectForKey:@"user_name"] description];
            entityy.in_group_name = [[dict objectForKey:@"user_name"] description];
        }
        NSDictionary *info = [dict objectForKey:@"user_info"];
        entityy.friend_originalnickname = [[dict objectForKey:@"nickname"] description];
//        if ([[[info objectForKey:@"photo"] description] containsString:@"head_man"]) {
//            entityy.iconUrl = [[info objectForKey:@"photo"] description];
//        }else{
            if ([[[info objectForKey:@"photo"] description] containsString:@"http"] || [[[info objectForKey:@"photo"] description] containsString:@"wx.qlogo.cn"]) {
                entityy.iconUrl = [[info objectForKey:@"photo"] description];
            }else{
                entityy.iconUrl = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[[info objectForKey:@"photo"] description]];
            }
//        }
//        entityy.iconUrl = [[info objectForKey:@"photo"] description];
        //in_group_name 等等在yy_modelWithJSON中进行自动赋值的
        if ([entityy.is_creator isEqualToString:@"1"]) {
            [createArr addObject:entityy];
        }else if([entityy.is_admin isEqualToString:@"1"]) {
            [adminArr addObject:entityy];
        }else{
            [backArr addObject:entityy];
        }
    }
    if (adminArr.count > 0) {
        [backArr insertObjects:adminArr atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [adminArr count])]];
    }
    if (createArr.count > 0) {
        [backArr insertObjects:createArr atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [createArr count])]];
    }
    //操作人信息
    NSDictionary *perator;
    if (![[data objectForKey:@"currentUser"] isKindOfClass:[NSNull class]]) {
        perator = [data objectForKey:@"currentUser"];
    }
    //
    entity.allow_push = [[perator objectForKey:@"allow_push"] description];
    entity.exit_group = [[perator objectForKey:@"exit_group"] description];
    entity.exit_time = [[perator objectForKey:@"exit_time"] description];
    entity.in_group_name = [[perator objectForKey:@"in_group_name"] description];
    entity.is_admin = [[perator objectForKey:@"is_admin"] description];
    entity.is_creator = [[perator objectForKey:@"is_creator"] description];
    entity.join_time = [[perator objectForKey:@"join_time"] description];
    entity.user_id = [[perator objectForKey:@"user_id"] description];
    entity.user_name = [[perator objectForKey:@"user_name"] description];
    entity.save_group = [[perator objectForKey:@"save_group"] description];
    
    entity.needAllow = [[data objectForKey:@"needAllow"] description];
    entity.notice = [data objectForKey:@"notice"]?[[perator objectForKey:@"notice"] description]:@"";
    //entity.groupTotalNum = [[data objectForKey:@"groupTotalNum"] description];
    entity.groupAllUser = backArr;
    //
    
    return entity;
}

//接收到群组远程消息 5003
+(id)GotGroupNormalMessageContantParser:(NSDictionary *)data{
    data = [self nullDic:data];
    UUMessageFrame *messageFrame = [[UUMessageFrame alloc]init];
    UUMessage *messagee = [UUMessage new];
    //生成chatid 日后向服务器索取
//    NSInteger a = arc4random()%899999+100000;
//    NSDate *currentDate = [NSDate date];//获取当前时间，日期
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"YYYYMMddhhmmssSS"];
//    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    if ([[data objectForKey:@"group_msg_client"] isEqualToString:@"web"]) {
        messagee.IsFromWeb = YES;
    }
    messagee.chatId = [[data objectForKey:@"group_msg_id"] description];
    messagee.appMsgId = [[data objectForKey:@"appMsgId"] description];
    if ([[[data objectForKey:@"group_msg_sender_photo"] description] containsString:@"http"] || [[[data objectForKey:@"group_msg_sender_photo"] description] containsString:@"wx.qlogo.cn"]) {
        messagee.strIcon = [[data objectForKey:@"group_msg_sender_photo"] description];
    }else{
        messagee.strIcon = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[data objectForKey:@"group_msg_sender_photo"]];
    }
    //获取当前时间设置
    //    [dateFormatter setDateFormat:@"YYYY/MM/dd hh:mm:ss SS"];
    //    NSString *dateStringg = [dateFormatter stringFromDate:currentDate];
    //    messagee.strTime = dateStringg;
    NSDate *date = [NSDate date];
    NSTimeInterval interval = [date timeIntervalSince1970];
    int b = [[NFMyManage new] checkIsHaveNumAndLetter:[[data objectForKey:@"group_msg_time"] description]];
    if (b == 1) {
        NSInteger create_time = [[data objectForKey:@"group_msg_time"] integerValue];
        NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:create_time];
        if (![confromTimesp isThisYear]) {
            messagee.strTimeHeader = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"YYYY年MM月dd日"];
        }else{
            messagee.strTimeHeader = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"MM月dd日"];
        }
        messagee.strTime = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"HH:mm"];
    }else{
        messagee.strTimeHeader = @"";
        messagee.strTime = @"";
    }
//    messagee.userName = [data objectForKey:@"group_msg_sender_name"];
//    messagee.nickName = [data objectForKey:@"group_msg_sender_nick_name"];
    messagee.strContent = [data objectForKey:@"group_msg_content"];
//    if (messagee.strContent.length < 1000 && messagee.strContent.length > 0 && [messagee.strContent containsString:@"["] && [messagee.strContent containsString:@"]"]) {
//        messagee.strContent = [EmojiShift stringShiftemoji:messagee.strContent];
//    }
    messagee.strId = [data objectForKey:@"group_msg_id"];
    messagee.userId = [data objectForKey:@"group_msg_sender"];
    messagee.userName = [data objectForKey:@"group_msg_sender_name"];
    messagee.nickName = [data objectForKey:@"group_msg_sender_nick_name"];
    messagee.originalNickName = [data objectForKey:@"group_msg_sender_original_name"];
    if (messagee.nickName.length == 0) {
        messagee.nickName = [data objectForKey:@"group_msg_sender_name"];
    }
    //groupId 没取
    
    if ([[data objectForKey:@"group_msg_type"] isEqualToString:@"normal"]) {
        //为普通文字消息
        messagee.type = UUMessageTypeText;
        messagee.strContent = [data objectForKey:@"group_msg_content"];
//        if (messagee.strContent.length < 1000 && messagee.strContent.length > 0 && [messagee.strContent containsString:@"["] && [messagee.strContent containsString:@"]"]) {
//            messagee.strContent = [EmojiShift stringShiftemoji:messagee.strContent];
//        }
    }else if ([[data objectForKey:@"group_msg_type"] isEqualToString:@"image"]){
        //为图片
        messagee.strContent = @"";
        messagee.type = UUMessageTypePicture;
        if ([data objectForKey:@"fileInfo"]) {
            NSDictionary *fileInfo = [data objectForKey:@"fileInfo"];
            messagee.pictureScale = [[[fileInfo objectForKey:@"imgRatio"] description] floatValue];
            messagee.pictureUrl = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[fileInfo objectForKey:@"filePath"]];
            messagee.fileId = [[fileInfo objectForKey:@"fileId"] description];
        }else{
            messagee.pictureScale = 1;
        }
//        messagee.pictureUrl = [[data objectForKey:@"group_msg_content"] description];
        
//        messagee.picture = [ClearManager Base64StringToImage:[data objectForKey:@"group_msg_content"]];
//        //缓存图片
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
//        [dateFormatter setDateFormat: @"yyyyMMddhhmmssSS"];
//        NSString *identifier = [dateFormatter stringFromDate:[NSDate date]];
//        messagee.cachePicPath = [NSString stringWithFormat:@"%@%@",identifier,[NFUserEntity shareInstance].userId];
//        [[SDImageCache sharedImageCache] diskImageExistsWithKey:messagee.cachePicPath completion:^(BOOL isInCache) {
//            if (!isInCache) {
//                [[SDImageCache sharedImageCache] storeImage:messagee.picture forKey:messagee.cachePicPath toDisk:YES];
//            }
//        }];
    }else if ([[data objectForKey:@"group_msg_type"] isEqualToString:@"audio"]){
        //为语音
        messagee.strContent = @"";
        messagee.type = UUMessageTypeVoice;
        NSData *voiceData   = [[NSData alloc] initWithBase64Encoding:[data objectForKey:@"group_msg_content"]];
        //        NSData *voiceData = [messagee.strContent dataUsingEncoding:NSUTF8StringEncoding];
        messagee.voice = voiceData;
        NSString *voiceTimew = [[data objectForKey:@"audio_time"] description];
        if (voiceTimew.length > 0) {
            messagee.strVoiceTime = voiceTimew;
        }
    }else if([[data objectForKey:@"group_msg_type"] isEqualToString:@"card"]){
        NSDictionary *personDict = [data objectForKey:@"msgContent"];
        messagee.strContent = [NSString stringWithFormat:@"[个人名片]%@",[[personDict objectForKey:@"nickname"] description]];
        messagee.type = UUMessageTypeRecommendCard;
        messagee.fileId = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[[personDict objectForKey:@"photo"] description]];
        
        messagee.strId = [[personDict objectForKey:@"user_id"] description];
        messagee.strVoiceTime = [[personDict objectForKey:@"user_name"] description];
        messagee.pictureUrl = [[personDict objectForKey:@"nickname"] description];
    }
    
    if ([messagee.userName isEqualToString:[NFUserEntity shareInstance].userName]) {
        //如果是本人
        messagee.from = UUMessageFromMe;
    }else{
        messagee.from = UUMessageFromOther;
    }
    //记录已读时间
    messagee.localReceiveTime = interval;
    messagee.localReceiveTimeString = [NSString stringWithFormat:@"%ld",messagee.localReceiveTime];
    //    BOOL ret = [NFbaseViewController compaTodayDateWithDate:[[data objectForKey:@"create_time"] integerValue]];
    //    //如果不是yes 则是过期消息
    //    if (!ret) {
    //        messagee.yuehouYinCang = @"1";
    //    }
    [messageFrame setMessage:messagee];
    return messageFrame;
    
}

//接收到红包消息 群组
+(id)GotGroupRedpacketMessageContantParser:(NSDictionary *)data{
    data = [self nullDic:data];
    UUMessageFrame *messageFrame = [[UUMessageFrame alloc]init];
    UUMessage *messagee = [UUMessage new];
    messagee.IsFromWeb = NO;
    messagee.chatId = [[data objectForKey:@"group_msg_id"] description];
    messagee.appMsgId = [[data objectForKey:@"appMsgId"] description];
    if ([[[data objectForKey:@"group_msg_sender_photo"] description] containsString:@"http"] || [[[data objectForKey:@"group_msg_sender_photo"] description] containsString:@"wx.qlogo.cn"]) {
        messagee.strIcon = [[data objectForKey:@"group_msg_sender_photo"] description];
    }else{
        messagee.strIcon = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[data objectForKey:@"group_msg_sender_photo"]];
    }
    //获取当前时间设置
    NSDate *date = [NSDate date];
    NSTimeInterval interval = [date timeIntervalSince1970];
    int b = [[NFMyManage new] checkIsHaveNumAndLetter:[[data objectForKey:@"group_msg_time"] description]];
    if (b == 1) {
        NSInteger create_time = [[data objectForKey:@"group_msg_time"] integerValue];
        NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:create_time];
        if (![confromTimesp isThisYear]) {
            messagee.strTimeHeader = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"YYYY年MM月dd日"];
        }else{
            messagee.strTimeHeader = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"MM月dd日"];
        }
        messagee.strTime = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"HH:mm"];
    }else{
        messagee.strTimeHeader = @"";
        messagee.strTime = @"";
    }
    //祝福语
    NSDictionary *redContentD = [data objectForKey:@"group_msg_content"];
    messagee.strContent = [redContentD objectForKey:@"content"];
    
    messagee.redpacketString = [redContentD objectForKey:@"redpacketId"];
    messagee.strId = [data objectForKey:@"group_msg_id"];
    messagee.userId = [data objectForKey:@"group_msg_sender"];
    messagee.userName = [data objectForKey:@"group_msg_sender_name"];
    messagee.nickName = [data objectForKey:@"group_msg_sender_nick_name"];
    messagee.originalNickName = [[data[@"group_msg_sender_original_name"] description] length] > 0?[data[@"group_msg_sender_original_name"] description]:messagee.nickName;
    if (messagee.nickName.length == 0) {
        messagee.nickName = [data objectForKey:@"group_msg_sender_name"];
    }
    messagee.type = UUMessageTypeRed;
    if ([messagee.userName isEqualToString:[NFUserEntity shareInstance].userName]) {
        //如果是本人
        messagee.from = UUMessageFromMe;
    }else{
        messagee.from = UUMessageFromOther;
    }
    //记录已读时间
    messagee.localReceiveTime = interval;
    messagee.localReceiveTimeString = [NSString stringWithFormat:@"%ld",messagee.localReceiveTime];
    [messageFrame setMessage:messagee];
    return messageFrame;
}




//拉人解析
+(id)PullUserParser:(NSDictionary *)data{
    UUMessageFrame *messageFrame = [[UUMessageFrame alloc]init];
    UUMessage *messagee = [UUMessage new];
    
    NSString *createTime = [NFMyManage getCurrentTimeStamp];//用于取加群时间
    
    NSDictionary *invitorDict = [data objectForKey:@"inviter"];
    messagee.invitor = [[invitorDict objectForKey:@"userNickName"] description];//邀请人昵称
    id pulledArr = [data objectForKey:@"invitedUser"];
    NSMutableString *pulledPerson = [NSMutableString new];
    if ([pulledArr isKindOfClass:[NSArray class]]) {
        pulledArr = (NSArray *)pulledArr;
        NSArray *pullArrArr = pulledArr;
        for (int i = 0; i<pullArrArr.count; i++) {
            for (NSDictionary *pulledDict in pullArrArr) {
                [pulledPerson appendString:[NSString stringWithFormat:@"\"%@\"",[[pulledDict objectForKey:@"friendNickName"] description]]];
                createTime = [[pulledDict objectForKey:@"joinTime"] description];
                if (i==1) {
                    [pulledPerson appendString:@"等人"];
                    break;
                }
            }
        }
    }else if ([pulledArr isKindOfClass:[NSDictionary class]]){
        NSDictionary *pulledDict = pulledArr;
        [pulledPerson appendString:[NSString stringWithFormat:@"\"%@\"",[pulledDict objectForKey:@"friendNickName"]]];//被邀请人昵称
    }
    messagee.pulledMemberString = pulledPerson;
    messagee.type = UUMessageTypeText;
    messagee.from = UUMessageFromInvite;
    messagee.pullType = @"0";//0为拉人进群 1为二维码扫描 //默认为0.二维码5020那边会设置为1
    
    NSDate *date = [NSDate date];
    NSTimeInterval interval = [date timeIntervalSince1970];
    //    messagee.strTime = [[NFbaseViewController new] timestampSwitchTime:interval anddFormatter:@"hh:mm"];
    //    int b = [[NFMyManage new] checkIsHaveNumAndLetter:[[data objectForKey:@"createTime"] description]];
    
    int b = [[NFMyManage new] checkIsHaveNumAndLetter:createTime];//没有时间 先去当前时间
    if (b == 1) {
        NSInteger create_time = [createTime integerValue];
        NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:create_time];
        if (![confromTimesp isThisYear]) {
            messagee.strTimeHeader = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"YYYY年MM月dd日"];
        }else{
            messagee.strTimeHeader = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"MM月dd日"];
        }
        messagee.strTime = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"HH:mm"];
    }else{
        messagee.strTimeHeader = @"";
        messagee.strTime = @"";
    }
    //记录已读时间
    messagee.localReceiveTime = interval;
    messagee.localReceiveTimeString = [NSString stringWithFormat:@"%ld",messagee.localReceiveTime];
    
    [messageFrame setMessage:messagee];
    return messageFrame;
    
}


//拉人解析 【管理收到申请】
+(id)PullUserManageParser:(NSDictionary *)data{
    UUMessageFrame *messageFrame = [[UUMessageFrame alloc]init];
    UUMessage *messagee = [UUMessage new];
    
    NSString *createTime = [NFMyManage getCurrentTimeStamp];//用于取加群时间
    
    NSDictionary *invitorDict = [data objectForKey:@"inviter"];
    messagee.invitor = [[data objectForKey:@"who_invite_user_nickname"] description];//邀请人昵称
    id pulledArr = [data objectForKey:@"invitedUser"];
    NSMutableString *pulledPerson = [NSMutableString new];
    [pulledPerson appendString:[NSString stringWithFormat:@"\"%@\"",[data objectForKey:@"user_nickname"]]];//被邀请人昵称
    messagee.pulledMemberString = pulledPerson;
    messagee.type = UUMessageTypeText;
    messagee.from = UUMessageFromInvite;
    messagee.pullType = @"3";//0为拉人进群 1为二维码扫描
    messagee.fileId = [[data objectForKey:@"id"] description];
    
    NSDate *date = [NSDate date];
    NSTimeInterval interval = [date timeIntervalSince1970];
    //    messagee.strTime = [[NFbaseViewController new] timestampSwitchTime:interval anddFormatter:@"hh:mm"];
    //    int b = [[NFMyManage new] checkIsHaveNumAndLetter:[[data objectForKey:@"createTime"] description]];
    
    int b = [[NFMyManage new] checkIsHaveNumAndLetter:createTime];//没有时间 先去当前时间
    if (b == 1) {
        NSInteger create_time = [createTime integerValue];
        NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:create_time];
        if (![confromTimesp isThisYear]) {
            messagee.strTimeHeader = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"YYYY年MM月dd日"];
        }else{
            messagee.strTimeHeader = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"MM月dd日"];
        }
        messagee.strTime = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"HH:mm"];
    }else{
        messagee.strTimeHeader = @"";
        messagee.strTime = @"";
    }
    //记录已读时间
    messagee.localReceiveTime = interval;
    messagee.localReceiveTimeString = [NSString stringWithFormat:@"%ld",messagee.localReceiveTime];
    
    [messageFrame setMessage:messagee];
    return messageFrame;
    
}

//{
//    result =     {
//        groupId = 9;
//        redpacketId = 695;
//        time = 1579141783;
//        userName = "\U590f\U5915\U4eba";
//    };
//    status = 9035;
//}

//领红包 我是发包人 收到红包领取通知【包括自己领取的 都走这里走】
+(id)RobRedPacketParser:(NSDictionary *)data{
    UUMessageFrame *messageFrame = [[UUMessageFrame alloc]init];
    UUMessage *messagee = [UUMessage new];
    
    NSString *createTime = [NFMyManage getCurrentTimeStamp];//用于取加群时间
    
    NSMutableString *pulledPerson = [NSMutableString new];
    pulledPerson = [NSMutableString stringWithFormat:@"%@ 领取了你的红包",[data objectForKey:@"userName"]];
    
    
    messagee.userName = [[data objectForKey:@"userName"] description];
    messagee.userId = [[data objectForKey:@"userId"] description];
    messagee.pulledMemberString = [NSString stringWithFormat:@"  %@  ",pulledPerson];
    messagee.type = UUMessageTypeRedRobRecord;
    NSDate *date = [NSDate date];
    NSTimeInterval interval = [date timeIntervalSince1970];
    //    messagee.strTime = [[NFbaseViewController new] timestampSwitchTime:interval anddFormatter:@"hh:mm"];
    //    int b = [[NFMyManage new] checkIsHaveNumAndLetter:[[data objectForKey:@"createTime"] description]];
    
    int b = [[NFMyManage new] checkIsHaveNumAndLetter:createTime];//没有时间 先去当前时间
    if (b == 1) {
        NSInteger create_time = [createTime integerValue];
        NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:create_time];
        if (![confromTimesp isThisYear]) {
            messagee.strTimeHeader = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"YYYY年MM月dd日"];
        }else{
            messagee.strTimeHeader = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"MM月dd日"];
        }
        messagee.strTime = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"HH:mm"];
    }else{
        messagee.strTimeHeader = @"";
        messagee.strTime = @"";
    }
    //记录已读时间
    messagee.localReceiveTime = interval;
    messagee.localReceiveTimeString = [NSString stringWithFormat:@"%ld",messagee.localReceiveTime];
    
    [messageFrame setMessage:messagee];
    return messageFrame;
    
}

//领红包 我是抢包人 收到红包领取通知【都是自己领取别人的,自己领取自己的不处理】
+(id)RobOtherRedPacketParser:(NSDictionary *)data{
    UUMessageFrame *messageFrame = [[UUMessageFrame alloc]init];
    UUMessage *messagee = [UUMessage new];
    
    NSString *createTime = [NFMyManage getCurrentTimeStamp];//用于取加群时间
    
    NSDictionary *senderInfo = [data objectForKey:@"senderInfo"];
    NSMutableString *pulledPerson = [NSMutableString new];
    if([data objectForKey:@"type"] && [[[data objectForKey:@"type"] description] isEqualToString:@"2"]){
        pulledPerson = [NSMutableString stringWithFormat:@"你确认了对方的转账"];
        messagee.redpacketString = [[data objectForKey:@"redpacketId"] description];
        NSDictionary *dictt = [data objectForKey:@"grabinfo"];
        messagee.priceAccount = [NSString stringWithFormat:@"%.2f",[[[dictt objectForKey:@"money"] description] floatValue]/100];
        messagee.from = UUMessageFromMe;
    }else{
        pulledPerson = [NSMutableString stringWithFormat:@"你领取了%@发的红包",[senderInfo objectForKey:@"nickname"]];
    }
    
    messagee.userName = [senderInfo objectForKey:@"nickname"];
    messagee.userId = [[senderInfo objectForKey:@"user_id"] description];
    messagee.pulledMemberString = [NSString stringWithFormat:@"  %@  ",pulledPerson];
    messagee.type = UUMessageTypeRedRobRecord;
    NSDate *date = [NSDate date];
    NSTimeInterval interval = [date timeIntervalSince1970];
    //    messagee.strTime = [[NFbaseViewController new] timestampSwitchTime:interval anddFormatter:@"hh:mm"];
    //    int b = [[NFMyManage new] checkIsHaveNumAndLetter:[[data objectForKey:@"createTime"] description]];
    
    int b = [[NFMyManage new] checkIsHaveNumAndLetter:createTime];//没有时间 先去当前时间
    if (b == 1) {
        NSInteger create_time = [createTime integerValue];
        NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:create_time];
        if (![confromTimesp isThisYear]) {
            messagee.strTimeHeader = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"YYYY年MM月dd日"];
        }else{
            messagee.strTimeHeader = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"MM月dd日"];
        }
        messagee.strTime = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"HH:mm"];
    }else{
        messagee.strTimeHeader = @"";
        messagee.strTime = @"";
    }
    //记录已读时间
    messagee.localReceiveTime = interval;
    messagee.localReceiveTimeString = [NSString stringWithFormat:@"%ld",messagee.localReceiveTime];
    
    [messageFrame setMessage:messagee];
    return messageFrame;
    
}

// 群系统通知 设置管理员 、踢人等
+(id)GroupNoticeParser:(NSDictionary *)data{
    UUMessageFrame *messageFrame = [[UUMessageFrame alloc]init];
    UUMessage *messagee = [UUMessage new];
    
    NSString *createTime = [NFMyManage getCurrentTimeStamp];//用于取加群时间
    
    NSMutableString *pulledPerson = [NSMutableString new];
    if([[[data objectForKey:@"type"] description] isEqualToString:@"3"]){
        //设置了管理员
        NSDictionary *newAdmin =[data objectForKey:@"newAdmin"];
        pulledPerson = [NSMutableString stringWithFormat:@"  群主设置了%@为管理员  ",[[newAdmin objectForKey:@"nickname"] description]];
    }else if([[[data objectForKey:@"type"] description] isEqualToString:@"1"]){
        //转让群主
        NSDictionary *newCreator =[data objectForKey:@"newCreator"];
        pulledPerson = [NSMutableString stringWithFormat:@"  %@被转让成为新的群主  ",[newCreator objectForKey:@"nickname"]];
    }else if([[[data objectForKey:@"type"] description] isEqualToString:@"2"]){
        //踢人
        NSDictionary *admin =[data objectForKey:@"admin"];
        NSArray *outUserArr =[data objectForKey:@"outUser"];
        NSMutableString *outUserString = [NSMutableString new];
        if (outUserArr.count > 1) {
            NSInteger i = 0;
            for (NSDictionary *dict in outUserArr) {
                if (i == 0) {
                    outUserString = [NSMutableString stringWithString:[[dict objectForKey:@"nickname"] description]];
                }else{
                    [outUserString appendFormat:@",%@",[[dict objectForKey:@"nickname"] description]];
                }
                i++;
            }
        }else{
            NSDictionary *outUserArrD = [NSDictionary new];
            outUserArrD = [outUserArr firstObject];
            outUserString = [NSMutableString stringWithString:[[outUserArrD objectForKey:@"nickname"] description]];
        }
        
        pulledPerson = [NSMutableString stringWithFormat:@"  %@将%@踢出了群聊  ",[admin objectForKey:@"nickname"],outUserString];
        
    }else if([[[data objectForKey:@"type"] description] isEqualToString:@"4"]){
        //设置了管理员
        NSDictionary *newAdmin =[data objectForKey:@"admin"];
        pulledPerson = [NSMutableString stringWithFormat:@"  群主取消了%@的管理员身份  ",[[newAdmin objectForKey:@"nickname"] description]];
    }
    
    messagee.userName = [[data objectForKey:@"userName"] description];
    messagee.userId = [[data objectForKey:@"userId"] description];
    messagee.pulledMemberString = [NSString stringWithFormat:@"  %@  ",pulledPerson];
    messagee.type = UUMessageTypeSystem;
    NSDate *date = [NSDate date];
    NSTimeInterval interval = [date timeIntervalSince1970];
    //    messagee.strTime = [[NFbaseViewController new] timestampSwitchTime:interval anddFormatter:@"hh:mm"];
    //    int b = [[NFMyManage new] checkIsHaveNumAndLetter:[[data objectForKey:@"createTime"] description]];
    
    int b = [[NFMyManage new] checkIsHaveNumAndLetter:createTime];//没有时间 先去当前时间
    if (b == 1) {
        NSInteger create_time = [createTime integerValue];
        NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:create_time];
        if (![confromTimesp isThisYear]) {
            messagee.strTimeHeader = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"YYYY年MM月dd日"];
        }else{
            messagee.strTimeHeader = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"MM月dd日"];
        }
        messagee.strTime = [[NFbaseViewController new] timestampSwitchTime:create_time anddFormatter:@"HH:mm"];
    }else{
        messagee.strTimeHeader = @"";
        messagee.strTime = @"";
    }
    //记录已读时间
    messagee.localReceiveTime = interval;
    messagee.localReceiveTimeString = [NSString stringWithFormat:@"%ld",messagee.localReceiveTime];
    
    [messageFrame setMessage:messagee];
    return messageFrame;
    
}


//重复创建群组
+(id)groupCreateRepeatManagerParserr:(NSDictionary *)data{
    GroupCreateSuccessEntity *entity = [GroupCreateSuccessEntity new];
    entity.createTime = [[data objectForKey:@"createTime"] description];
    entity.groupId = [[data objectForKey:@"groupId"] description];
    entity.groupName = [[data objectForKey:@"groupName"] description];
    entity.groupHeadPic = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[data objectForKey:@"groupPhoto"]];
    //取群成员
    NSMutableArray *backArr = [NSMutableArray new];
    for (NSDictionary *dict in [data objectForKey:@"groupUser"]?[data objectForKey:@"groupUser"]:[data objectForKey:@"groupAllUser"]) {
        ZJContact *entityy = [ZJContact yy_modelWithJSON:dict];
        entityy.friend_userid = [[dict objectForKey:@"user_id"] description];
        entityy.friend_username = [[dict objectForKey:@"user_name"] description];
        NSDictionary *info =[dict objectForKey:@"user_info"];
        entityy.iconUrl =[NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[[dict objectForKey:@"photo"] description]];
        [backArr addObject:entityy];
    }
    NSDictionary *perator = [data objectForKey:@"creator"];
    entity.exit_group = [[perator objectForKey:@"exit_group"] description];
    entity.exit_time = [[perator objectForKey:@"exit_time"] description];
    entity.in_group_name = [[perator objectForKey:@"in_group_name"] description];
    entity.is_admin = [[perator objectForKey:@"is_admin"] description];
    entity.is_creator = [[perator objectForKey:@"is_creator"] description];
    entity.join_time = [[perator objectForKey:@"join_time"] description];
    entity.user_id = [[perator objectForKey:@"user_id"] description];
    entity.user_name = [[perator objectForKey:@"user_name"] description];
    entity.groupAllUser = backArr;
    return entity;
}


// 多信助手 l消息列表
+(id)helperList:(NSArray *)data{
    NSMutableArray *arr = [NSMutableArray new];
    for (NSDictionary *dict in data) {
        BillListEntity *entity = [BillListEntity new];
        entity.detail = [[dict objectForKey:@"content"] description];
        entity.datetime = [[dict objectForKey:@"create_time"] description];
        entity.helpId = [[dict objectForKey:@"id"] description];
        [arr addObject:entity];
    }
    return @{@"allCount":@"0",@"arr":arr};
}







-(NSString *)NumToString:(NSString *)num{
    NSDictionary *numDict = @{@"0":@"a",@"1":@"b",@"2":@"c",@"3":@"d",@"4":@"e",@"5":@"f",@"6":@"g",@"7":@"h",@"8":@"i",@"9":@"j"};
    NSString *newStr = num;
    NSMutableString *mutableString = [NSMutableString new];
    NSString *temp =nil;
    for(int i =0; i < [newStr length]; i++)
    {
        temp = [newStr substringWithRange:NSMakeRange(i,1)];
        NSString *appendString = numDict[temp];
        [mutableString appendString:appendString];
    }
    return mutableString;
}






@end



