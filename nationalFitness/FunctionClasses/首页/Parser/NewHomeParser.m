//
//  NewHomeParser.m
//  nationalFitness
//
//  Created by 童杰 on 2017/2/25.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "NewHomeParser.h"

@implementation NewHomeParser

//联系人列表
//+(id)contantListManagerParser:(NSData *)data{
//    NSDictionary *bodyDic = [self gotDataNoKeyParser:data];
//    if (bodyDic)
//    {
//        if ([bodyDic objectForKey:kWrongDlog])
//        {
//            return bodyDic;
//        }
//        NSArray *entityListArr = [bodyDic objectForKey:@"homeFocusList"];
//        NSMutableArray *retMuarr = [[NSMutableArray alloc] initWithCapacity:10];
//        NSMutableDictionary *retDict = [NSMutableDictionary new];
//        for (NSDictionary *entityDic in entityListArr)
//        {
//            ZJContact *entity = [[ZJContact alloc] init];
//            
//            entity.name = [self NSStringWithKey:@"name" fromDict:entityDic MethodName:@"contantListManagerParser:" parameterString:@"name"];
//            NSString *imagePath = [self NSStringWithKey:@"picContent" fromDict:entityDic MethodName:@"contantListManagerParser:" parameterString:@"picContent"];
//            UIImageView *imagev = [UIImageView new];
//            [imagev sd_setImageWithURL:[NSURL URLWithString:imagePath] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                entity.icon = imagev.image;
//            }];
//            entity.chatId= [self NSStringWithKey:@"chatId" fromDict:entityDic MethodName:@"contantListManagerParser:" parameterString:@"chatId"];
//            [retMuarr addObject:entity];
//        }
//        [retDict setObject:retMuarr forKey:@"retMuarr"];
//        return retDict;
//    }
//    return nil;
//}

+(id)contantListManagerParserr:(NSArray *)data{
    //联系人
    NSMutableArray *backArr = [NSMutableArray new];
    for (NSDictionary *contantDictt in data) {
        NSDictionary *contantDict = [self nullDic:contantDictt];
        FriendListEntity *entity = [FriendListEntity yy_modelWithDictionary:contantDict];
//        if ([[[contantDict objectForKey:@"photo"] description] containsString:@"head_man"]) {
//            entity.headImage = [[contantDict objectForKey:@"photo"] description];
//        }else{
            if ([[[contantDict objectForKey:@"photo"] description] length] == 0) {
                entity.headImage = @"";
            }else{
                if ([[[contantDict objectForKey:@"photo"] description] containsString:@"http"] || [[[contantDict objectForKey:@"photo"] description] containsString:@"wx.qlogo.cn"]) {
                    entity.headImage = [[contantDict objectForKey:@"photo"] description];
                }else{
                    entity.headImage = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[[contantDict objectForKey:@"photo"] description]];
                }
            }
//        }
//        entity.friend_userid =  [contantDict objectForKey:@"friend_userid"];
//        
//        entity.user_id = [[contantDict objectForKey:@"user_id"] description];
//        entity.friend_username = [contantDict objectForKey:@"friend_username"];
//        entity.updatetime = [contantDict objectForKey:@"updatetime"];
//        entity.createtime = [contantDict objectForKey:@"createtime"];
        ZJContact *contact= [ZJContact new];
        contact.friend_username = [[contantDict objectForKey:@"friend_username"] description];
        contact.friend_userid = [[contantDict objectForKey:@"friend_userid"] description];
        contact.friend_comment_name = [[contantDict objectForKey:@"friend_comment_name"] description];
        contact.friend_nickname = [[contantDict objectForKey:@"friend_comment_name"] description];
        contact.friend_originalnickname = [[contantDict objectForKey:@"nickname"] description];
        if (contact.friend_nickname.length == 0) {
            contact.friend_nickname = [[contantDict objectForKey:@"nickname"] description];
            if(contact.friend_nickname.length == 0){
                contact.friend_nickname = [[contantDict objectForKey:@"friend_username"] description];
            }
        }
        contact.iconUrl = entity.headImage;
        
        [backArr addObject:contact];
        
    }
    return backArr;
}

+(id)allGroupListManagerParserr:(NSArray *)data{
    //联系人
    NSMutableArray *backArr = [NSMutableArray new];
    for (NSDictionary *contantDictt in data) {
        NSDictionary *contantDict = [self nullDic:contantDictt];
        ZJContact *contact= [ZJContact new];
        contact.friend_username = [[contantDict objectForKey:@"groupName"] description];
        contact.friend_userid = [[contantDict objectForKey:@"groupId"] description];
        contact.friend_nickname = [[contantDict objectForKey:@"groupName"] description];
        
        [backArr addObject:contact];
        
    }
    return backArr;
}


//c5bdb58d0e1405cb7df7362e5806ff22
//wxc85028718b16d1a3
//FriendAddListEntity
+(id)FriendAddListParser:(NSDictionary *)data{
    if (data) {
        NSArray *friendAddArr = [NSArray arrayWithArray:[data objectForKey:@"friend"]];
        NSMutableArray *requestArr = [[NSMutableArray alloc] initWithCapacity:5];
        for (NSDictionary *addDictt in friendAddArr) {
            NSDictionary *addDict = [self nullDic:addDictt];
            FriendAddListEntity *entity = [FriendAddListEntity yy_modelWithDictionary:addDict];
//            entity.receive_user_name = [[addDict objectForKey:@"receive_user_nickName"] description];
//            entity.send_user_name = [[addDict objectForKey:@"send_nick_name"] description];
//            entity.send_nick_name = [[addDict objectForKey:@"send_nick_name"] description];
//            FriendAddListEntity *entity = [FriendAddListEntity new];
            entity.addId = [[addDict objectForKey:@"id"] description];
            if ([[addDict objectForKey:@"finished_time"] isKindOfClass:[NSNull class]]) {
                entity.finished_time = [[addDict objectForKey:@"send_time"] description];
            }else if ([[[addDict objectForKey:@"finished_time"] description] isEqualToString:@""]){
                entity.finished_time = [[addDict objectForKey:@"send_time"] description];
            }
//            if ([[[addDictt objectForKey:@"photo"] description] containsString:@"head_man"]) {
//                entity.photo = [[addDict objectForKey:@"photo"] description];
//            }else{
                if ([[[addDictt objectForKey:@"photo"] description] containsString:@"http"] || [[[addDictt objectForKey:@"photo"] description] containsString:@"wx.qlogo.cn"]) {
                    entity.photo = [[addDict objectForKey:@"photo"] description];
                }else{
                    entity.photo = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[[addDict objectForKey:@"photo"] description]];
                }
//            }
            entity.IsGroup = @"0";
            [requestArr addObject:entity];
        }
        
        NSArray *groupAddArr = [NSArray arrayWithArray:[data objectForKey:@"group"]];
        for (NSDictionary *addDictt in groupAddArr) {
            FriendAddListEntity *entity = [FriendAddListEntity yy_modelWithDictionary:addDictt];
            entity.addId = [[addDictt objectForKey:@"id"] description];
            entity.photo = [[addDictt objectForKey:@"group_photo"] description];
            entity.photo = [[addDictt objectForKey:@"group_photo"] description];
            entity.isRead = [[[addDictt objectForKey:@"is_read"] isEqualToString:@"unread"]?@"0":@"1" description];
            
            
            [requestArr addObject:entity];
        }
        
        NSSortDescriptor *originTimeString = [NSSortDescriptor sortDescriptorWithKey:@"send_time" ascending:NO];
        requestArr = [requestArr sortedArrayUsingDescriptors:@[originTimeString]];
        
        
        return requestArr;
    }
    return nil;
}


//搜索好友解析
+(id)FriendSearchResultListParser:(NSDictionary *)data{
    if (data) {
        FriendSearchResultEntity *entity = [FriendSearchResultEntity yy_modelWithDictionary:data];
        entity.userAndNickName = [NSString stringWithFormat:@"%@ 昵称:%@",[[data objectForKey:@"user_name"] description],[[data objectForKey:@"nick_name"] description]];
//        if ([[[data objectForKey:@"photo"] description] containsString:@"head_man"]) {
//            entity.photo = [data objectForKey:@"photo"];
//        }else{
            if ([[[data objectForKey:@"photo"] description] containsString:@"http"] || [[[data objectForKey:@"photo"] description] containsString:@"wx.qlogo.cn"]) {
                entity.photo = [[data objectForKey:@"photo"] description];
            }else{
                entity.photo = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[[data objectForKey:@"photo"] description]];
            }
//        }
        entity.friendId = [[data objectForKey:@"user_id"] description];
        return entity;
    }
    return nil;
}





@end
