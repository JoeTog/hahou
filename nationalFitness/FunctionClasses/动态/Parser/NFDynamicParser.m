//
//  NFDynamicParser.m
//  nationalFitness
//
//  Created by liumac on 16/1/4.
//  Copyright © 2016年 chenglong. All rights reserved.
//

#import "NFDynamicParser.h"
#import "NFDynamicEntity.h"
#import "NFBaseEntity.h"

@implementation NFDynamicParser

// 发布动态
+ (id)publishNoteParser:(NSData *)data
{
    NSDictionary *bodyDic = [self gotDataParser:data];
    
    if (bodyDic)
    {
        return bodyDic;
    }
    
    return nil;
}

// 关联的活动和社团
+ (id)connectNoteParser:(NSData *)data
{
    NSDictionary *bodyDic = [self gotDataParser:data];
    if (bodyDic)
    {
        if ([bodyDic objectForKey:kWrongDlog])
        {
            return bodyDic;
        }
        NSMutableDictionary *dict = [@{} mutableCopy];
        NSMutableArray *exeArr = [@[] mutableCopy];
        NSMutableArray *clubArr = [@[] mutableCopy];
        NSMutableArray *pubArr = [@[] mutableCopy];
        for (NSDictionary *dic in [bodyDic objectForKey:@"exerList"])
        {
            ExericiseEntity *entity = [[ExericiseEntity alloc]init];
            entity.actName = [[dic objectForKey:@"actName"] description];
            entity.startDate = [[dic objectForKey:@"startDate"] description];
            entity.actId = [[dic objectForKey:@"actId"] description];
            entity.smllPicPath = [[dic objectForKey:@"smallPicPath"] description];
            entity.bigPicPath = [[dic objectForKey:@"bigPicPath"] description];
            entity.sportType = [[dic objectForKey:@"sportType"] description];
            [exeArr addObject:entity];
        }
        for (NSDictionary *dic in [bodyDic objectForKey:@"clubList"])
        {
            ClubEntity *entity = [[ClubEntity alloc] init];
            entity.clubId = [[dic objectForKey:@"clubId"] description];
            entity.clubName = [[dic objectForKey:@"clubName"] description];
            entity.smallPicPath = [[dic objectForKey:@"smallPicPath"] description];
            entity.bigPicPath = [[dic objectForKey:@"bigPicPath"] description];
            [clubArr addObject:entity];
        }
        for (NSDictionary *dic in [bodyDic objectForKey:@"publicNoList"])
        {
            PublicNoEntity *entity = [[PublicNoEntity alloc] init];
            entity.pubNoId = [[dic objectForKey:@"pubNoId"] description];
            entity.smllPicPath = [[dic objectForKey:@"smallPicPath"] description];
            entity.bigPicPath = [[dic objectForKey:@"bigPicPath"] description];
            entity.nickName = [[dic objectForKey:@"nickName"] description];
            [pubArr addObject:entity];
        }
        [dict setObject:exeArr forKey:@"exerList"];
        [dict setObject:clubArr forKey:@"clubList"];
        [dict setObject:pubArr forKey:@"publicNoList"];
        return dict;
    }
    return nil;
}

// 帖子列表
+ (id)noteListParser:(NSArray *)data
{
    NSMutableArray *noteListArrr = [@[] mutableCopy];
    for (NSDictionary *dictt in data) {
        NSDictionary *dict = [self nullDic:dictt];
        NoteListEntity *entity = [NoteListEntity yy_modelWithDictionary:dict];
        entity.praiseCount = [[dict objectForKey:@"totalLikeNum"] description];
        
        int b = [[NFMyManage new] checkIsHaveNumAndLetter:[[dict objectForKey:@"post_time"] description]];
        if (b == 1) {
            entity.post_time = [NFMyManage timestampSwitchTime:[[dict objectForKey:@"post_time"] integerValue]];
        }else{
            entity.post_time = @"";
        }
        entity.createDate = [[dict objectForKey:@"post_time"] description];
        NSDictionary *infoDict = [dict objectForKey:@"user_info"];
        NoteListEntity *secEntity = [NoteListEntity yy_modelWithDictionary:infoDict];
        entity.user_name = secEntity.user_name;
        entity.nickname = secEntity.nickname;
//        if ([secEntity.photo containsString:@"head_man"]) {
//            entity.photo = secEntity.photo;
//        }else{
            if ([secEntity.photo containsString:@"http"] || [secEntity.photo containsString:@"wx.qlogo.cn"]) {
                entity.photo = secEntity.photo;
            }else{
                
                entity.photo = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,secEntity.photo];
            }
            
//        }
        
        NSMutableArray *circleImageArr = [@[] mutableCopy];
        NSArray *circleImage = [dict objectForKey:@"circleImage"];
        for (NSDictionary *photoDict in circleImage) {
            NoteListPhotoEntity *photoEntity = [NoteListPhotoEntity yy_modelWithDictionary:photoDict];
//            if ([photoEntity.image_uri containsString:@"head_man"]) {
//                [circleImageArr addObject:photoEntity.image_uri];
//            }else{
                if ([photoEntity.image_uri containsString:@"http"]) {
                    [circleImageArr addObject:photoEntity.image_uri];
                }else{
                    [circleImageArr addObject:[NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,photoEntity.image_uri]];
                }
                
//            }
        }
        entity.photoList = circleImageArr;
        entity.isPraise = @"0";
        if (entity.currentUserLike.length > 0) {
            entity.isPraise = @"1";
        }
        //评论列表
        NSMutableArray *commentArr = [@[] mutableCopy];
        for (NSDictionary *commentDict in [dict objectForKey:@"comments"]) {
            NoteCommentEntity *commentEntity = [NoteCommentEntity yy_modelWithDictionary:commentDict];
            commentEntity.comment_date = [NFMyManage timestampSwitchTime:[commentEntity.comment_time integerValue]];
            NSDictionary *info = [commentDict objectForKey:@"userInfo"];
//            BOOL ret = [[NFMyManage new] IsMyFriendWithFrienid:[[info objectForKey:@"user_id"] description] WithDatabaseName:@"tongxun.sqlite" tableName:@"lianxirenliebiao"];
//            if (!ret) {
//                continue;
//            }
            commentEntity.user_name = [[info objectForKey:@"user_name"] description];
            commentEntity.user_id = [[info objectForKey:@"user_id"] description];
            commentEntity.user_nickName = [[info objectForKey:@"nickname"] description];
            if (commentEntity.user_nickName.length == 0) {
                commentEntity.user_nickName = [[info objectForKey:@"user_name"] description];
            }
            if (commentEntity.replyToName.length > 0 && commentEntity.replyToNickName.length == 0) {
                commentEntity.replyToNickName = [[info objectForKey:@"replyToName"] description];
            }
//            if ([[[info objectForKey:@"photo"] description] containsString:@"head_man"]) {
//                commentEntity.photo = [[info objectForKey:@"photo"] description];
//            }else{
            
                if ([[[info objectForKey:@"photo"] description] containsString:@"http"] || [[[info objectForKey:@"photo"] description] containsString:@"wx.qlogo.cn"]) {
                    commentEntity.photo = [[info objectForKey:@"photo"] description];
                }else{
                    commentEntity.photo = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[info objectForKey:@"photo"]];
                }
                
//            }
//            commentEntity.replyToId = [[commentDict objectForKey:@"comment_id"] description];
//            commentEntity.replyToName = [[info objectForKey:@"user_name"] description];
            [commentArr addObject:commentEntity];
        }
        entity.commentArr = commentArr;
        entity.commentCount = [NSString stringWithFormat:@"%d",commentArr.count];
        [noteListArrr addObject:entity];
    }
    return noteListArrr;
}

// 帖子详情页
+ (id)detailNoteParser:(NSDictionary *)dict
{
    NoteListEntity *entity = [NoteListEntity yy_modelWithDictionary:dict];
    entity.praiseCount = [[dict objectForKey:@"totalLikeNum"] description];
    int b = [[NFMyManage new] checkIsHaveNumAndLetter:[[dict objectForKey:@"group_msg_time"] description]];
    if (b == 1) {
        entity.post_time = [NFMyManage timestampSwitchTime:[[dict objectForKey:@"post_time"] integerValue]];
    }else{
        entity.post_time = @"";
    }
    entity.createDate = [[dict objectForKey:@"post_time"] description];
    NSDictionary *infoDict = [dict objectForKey:@"user_info"];
    NoteListEntity *secEntity = [NoteListEntity yy_modelWithDictionary:infoDict];
    entity.user_name = secEntity.user_name;
    entity.nickname = secEntity.nickname;
//    if ([secEntity.photo containsString:@"head_man"]) {
//        entity.photo = secEntity.photo;
//    }else{
        if ([secEntity.photo containsString:@"http"] || [secEntity.photo containsString:@"wx.qlogo.cn"]) {
            entity.photo = secEntity.photo;
        }else{
            entity.photo = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,secEntity.photo];
        }
//    }
    
    NSMutableArray *circleImageArr = [@[] mutableCopy];
    NSArray *circleImage = [dict objectForKey:@"circleImage"];
    for (NSDictionary *photoDict in circleImage) {
        NoteListPhotoEntity *photoEntity = [NoteListPhotoEntity yy_modelWithDictionary:photoDict];
//        if ([photoEntity.image_uri containsString:@"head_man"]) {
//            [circleImageArr addObject:photoEntity.image_uri];
//        }else{
            if ([photoEntity.image_uri containsString:@"http"]) {
                [circleImageArr addObject:photoEntity.image_uri];
            }else{
                [circleImageArr addObject:[NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,photoEntity.image_uri]];
            }
//        }
        
    }
    entity.photoList = circleImageArr;
    entity.isPraise = @"0";
    if (entity.currentUserLike.length > 0) {
        entity.isPraise = @"1";
    }
    //评论列表
    NSMutableArray *commentArr = [@[] mutableCopy];
    BOOL ret = NO; //是否显示改评论
    for (NSDictionary *commentDict in [dict objectForKey:@"comments"]) {
        ret = NO;
        NoteCommentEntity *commentEntity = [NoteCommentEntity yy_modelWithDictionary:commentDict];
        commentEntity.comment_date = [NFMyManage timestampSwitchTime:[commentEntity.comment_time integerValue]];
        NSDictionary *info = [commentDict objectForKey:@"userInfo"];
        
//        BOOL ret = [[NFMyManage new] IsMyFriendWithFrienid:[[info objectForKey:@"user_id"] description] WithDatabaseName:@"tongxun.sqlite" tableName:@"lianxirenliebiao"];
//        if (!ret && ![[[info objectForKey:@"user_id"] description] isEqualToString:[NFUserEntity shareInstance].userId]) {
//            continue;
//        }
        
//        if([commentDict objectForKey:@"comment_target_id"] && [[commentDict objectForKey:@"comment_target_id"] description].length > 0){
//            //这里说明有人回复了某人，但是不知道被回复的是否是我的好友这里需要判断一下comment_target_id在前面的评论中是否有comment_id一样
//
//            for (NSDictionary *commentDictSec in [dict objectForKey:@"comments"]) {
//                if ([[[commentDictSec objectForKey:@"comment_id"] description] isEqualToString:[[commentDict objectForKey:@"comment_target_id"] description]]) {
//                    ret = YES;
//                }
//            }
//        }
//        if (!ret && [commentDict objectForKey:@"comment_target_id"] && [[[commentDict objectForKey:@"comment_target_id"] description] floatValue] > 0) {
//            break;
//        }
        
        commentEntity.user_name = [[info objectForKey:@"user_name"] description];
        commentEntity.user_nickName = [[info objectForKey:@"nick_name"] description];
        commentEntity.user_id = [[info objectForKey:@"user_id"] description];
        if (commentEntity.replyToNickName.length == 0) {
            commentEntity.replyToNickName = [[info objectForKey:@"replyToName"] description];
        }
//        if ([[[info objectForKey:@"photo"] description] containsString:@"head_man"]) {
//            commentEntity.photo = [[info objectForKey:@"photo"] description];
//        }else{
        
            if ([[[info objectForKey:@"photo"] description] containsString:@"http"] || [[[info objectForKey:@"photo"] description] containsString:@"wx.qlogo.cn"]) {
                commentEntity.photo = [[info objectForKey:@"photo"] description];
            }else{
                commentEntity.photo = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[info objectForKey:@"photo"]];
            }
            
//        }
        
        [commentArr addObject:commentEntity];
    }
    entity.commentArr = commentArr;
    
    return entity;
    
//    NSDictionary *bodyDic = [self gotDataParser:data];
    NSDictionary *bodyDic = [self gotDataNoKeyParser:[NSData new]];
    NSArray *picData = @[@"http://ydly.lystyj.gov.cn/qmjs_FEP/loadpic.jsp?path=/qmjs_files/note/23952020814103893/tempPic25657219484488686.jpg",@"http://ydly.lystyj.gov.cn/qmjs_FEP/loadpic.jsp?path=/qmjs_files/note/23952020814103893/tempPic25657219259530731_small.jpg",@"http://ydly.lystyj.gov.cn/qmjs_FEP/loadpic.jsp?path=/qmjs_files/note/23952020814103893/tempPic25657219259530731.jpg",@"http://ydly.lystyj.gov.cn/qmjs_FEP/loadpic.jsp?path=/qmjs_files/note/23952020814103893/tempPic24180656057271671_small.jpg",@"http://ydly.lystyj.gov.cn/qmjs_FEP/loadpic.jsp?path=/qmjs_files/note/23952020814103893/tempPic24180656057271671.jpg",@"http://ydly.lystyj.gov.cn/qmjs_FEP/loadpic.jsp?path=/qmjs_files/note/23952020814103893/tempPic25657216508009138_small.jpg",@"http://ydly.lystyj.gov.cn/qmjs_FEP/loadpic.jsp?path=/qmjs_files/note/23952020814103893/tempPic25657216508009138.jpg",@"http://ydly.lystyj.gov.cn/qmjs_FEP/loadpic.jsp?path=/qmjs_files/note/23952020814103893/tempPic25657219709453462_small.jpg",@"http://ydly.lystyj.gov.cn/qmjs_FEP/loadpic.jsp?path=/qmjs_files/note/23952020814103893/tempPic25657219709453462.jpg",@"http://ydly.lystyj.gov.cn/qmjs_FEP/loadpic.jsp?path=/qmjs_files/note/23952020814103893/tempPic25657219318141276_small.jpg",@"http://ydly.lystyj.gov.cn/qmjs_FEP/loadpic.jsp?path=/qmjs_files/note/23952020814103893/tempPic25657219318141276.jpg"];
    if ([NFUserEntity shareInstance].isPicImageDynamic) {
        bodyDic = @{@"noteEntitys":@{@"noteId":@"123",@"fkId":@"123",@"relAddress":@"淮安市",@"redDate":@"07-06",@"isFlag":@"0",@"isPraise":@"0",@"nickName":@"比尔",@"noteContent":@"中国天气网讯 今明天（5-6日），湖南、江西等江南地区迎来强降雨休整期，雨势普遍较弱。强降雨转移至四川盆地、黄淮等地，局地暴雨或大暴雨。同时，京津冀局地将再迎暴雨，公众需注意防范。",@"praiseCount":@"2",@"photoList":@[@{@"bigPicPath":picData[0]},@{@"bigPicPath":picData[1]},@{@"bigPicPath":picData[2]}]}};
    }else{
        bodyDic = @{@"noteEntitys":@{@"noteId":@"123",@"fkId":@"123",@"relAddress":@"淮安市",@"redDate":@"07-06",@"isFlag":@"0",@"isPraise":@"0",@"nickName":@"比尔",@"noteContent":@"中国天气网讯 今明天（5-6日），湖南、江西等江南地区迎来强降雨休整期，雨势普遍较弱。强降雨转移至四川盆地、黄淮等地，局地暴雨或大暴雨。同时，京津冀局地将再迎暴雨，公众需注意防范。",@"praiseCount":@"2"}};
    }
    if (bodyDic)
    {
        if ([bodyDic objectForKey:kWrongDlog])
        {
            return bodyDic;
        }
        NoteListEntity *entity = [[NoteListEntity alloc]init];
        NSMutableDictionary *dict = [bodyDic objectForKey:@"noteEntitys"];
        entity.noteId = [[dict objectForKey:@"noteId"] description];
        entity.noteContent = [[dict objectForKey:@"noteContent"] description];
        entity.redDate = [[dict objectForKey:@"redDate"] description];
        entity.createDate = [[dict objectForKey:@"createDate"] description];
        entity.range = [[dict objectForKey:@"range"] description];
        entity.relUserId = [[dict objectForKey:@"relUserId"] description];
        entity.isUpdate = [dict objectForKey:@"isUpdate"];
        entity.relAddress = [[dict objectForKey:@"relAddress"] description];
        entity.fkid = [[dict objectForKey:@"fkId"] description];
//        entity.nickName = [[dict objectForKey:@"nickName"] description];
        entity.smallPicPath = [[dict objectForKey:@"smallPicPath"] description];
        entity.noteSource = [[dict objectForKey:@"noteSource"] description];
        entity.shareType = [[dict objectForKey:@"shareType"] description];
        entity.sportType = [[dict objectForKey:@"sportType"] description];
        entity.commentCount = [[dict objectForKey:@"commentCount"] description];
        entity.praiseCount = [[dict objectForKey:@"praiseCount"] description];
        entity.actName = [[dict objectForKey:@"actName"] description];
        entity.isFlag = [[dict objectForKey:@"isFlag"] description];
        entity.isPraise = [[dict objectForKey:@"isPraise"] description];
        entity.isExtenSion = [[dict objectForKey:@"isExtenSion"] description];
        entity.extensionType = [[dict objectForKey:@"extensionType"] description];
        entity.photoList = [dict objectForKey:@"photoList"];
        entity.sportList = [dict objectForKey:@"sportList"];
        entity.clubList = [dict objectForKey:@"clubList"];
        entity.exerciseList = [dict objectForKey:@"exerciseList"];
        entity.venueList = [dict objectForKey:@"venueList"];
        entity.homeFocusList = [dict objectForKey:@"homeFocusList"];
        
        // 帖子中包含的帖子
//        NoteContentEntity *contentEntity = [[NoteContentEntity alloc] init];
//        NSDictionary *contentDic = [dict objectForKey:@"noteEntity"];
//        if (![contentDic isKindOfClass:[NSNull class]])
//        {
//            contentEntity.noteId = [[contentDic objectForKey:@"noteId"] description];
//            contentEntity.noteContent = [[contentDic objectForKey:@"noteContent"] description];
//            contentEntity.createDate = [[contentDic objectForKey:@"relDate"] description];
//            contentEntity.range = [[contentDic objectForKey:@"range"] description];
//            contentEntity.isUpdate = [[contentDic objectForKey:@"isUpdate"] description];
//            contentEntity.fkid = [[contentDic objectForKey:@"fkId"] description];
//            contentEntity.nickName = [[contentDic objectForKey:@"nickName"] description];
//            contentEntity.userPicPath = [[contentDic objectForKey:@"userPicPath"] description];
//            contentEntity.noteSource = [[contentDic objectForKey:@"noteSource"] description];
//            contentEntity.actName = [[contentDic objectForKey:@"actName"] description];
//            contentEntity.proName = [[contentDic objectForKey:@"proName"] description];
//            contentEntity.bigPicPath = [[contentDic objectForKey:@"bigPicPath"] description];
//            contentEntity.smallPicPath = [[contentDic objectForKey:@"smallPicPath"] description];
//            entity.isExtenSion = [[dict objectForKey:@"isExtenSion"] description];
//            contentEntity.month = [[contentDic objectForKey:@"month"] description];
//            contentEntity.day = [[contentDic objectForKey:@"day"] description];
//            contentEntity.times = [[contentDic objectForKey:@"times"] description];
//            contentEntity.startDate = [[contentDic objectForKey:@"startDate"] description];
//            contentEntity.endDate = [[contentDic objectForKey:@"endDate"] description];
//            contentEntity.relAddress = [[contentDic objectForKey:@"relAddress"] description];
//            contentEntity.lowPrice = [[contentDic objectForKey:@"lowPrice"] description];
//            contentEntity.highPrice = [[contentDic objectForKey:@"highPrice"] description];
//            contentEntity.perPrice = [[contentDic objectForKey:@"perPrice"] description];
//            contentEntity.clubType = [[contentDic objectForKey:@"clubType"] description];
//            contentEntity.logoPath = [[contentDic objectForKey:@"logoPath"] description];
//            contentEntity.photoList = [contentDic objectForKey:@"photoList"];
//            entity.noteEntity = contentEntity;
//            
//        }
        return entity;
    }
    
    return nil;
}

// 活动帖子列表
+ (id)actNoteListParser:(NSData *)data
{
    NSDictionary *bodyDic = [self gotDataParser:data];
    
    if (bodyDic)
    {
        NSMutableArray *noteListArr = [@[] mutableCopy];
        for (NSDictionary *dict in [bodyDic objectForKey:@"noteList"])
        {
            NoteListEntity *entity = [[NoteListEntity alloc]init];
            entity.noteId = [[dict objectForKey:@"noteId"] description];
            entity.noteContent = [[dict objectForKey:@"noteContent"] description];
            entity.redDate = [[dict objectForKey:@"redDate"] description];
            entity.createDate = [[dict objectForKey:@"createDate"] description];
            entity.range = [[dict objectForKey:@"range"] description];
            entity.relUserId = [[dict objectForKey:@"relUserId"] description];
            entity.isUpdate = [dict objectForKey:@"isUpdate"];
            entity.relAddress = [[dict objectForKey:@"relAddress"] description];
            entity.fkid = [[dict objectForKey:@"fkId"] description];
//            entity.nickName = [[dict objectForKey:@"nickName"] description];
            entity.smallPicPath = [[dict objectForKey:@"smallPicPath"] description];
            entity.noteSource = [[dict objectForKey:@"noteSource"] description];
            entity.shareType = [[dict objectForKey:@"shareType"] description];
            entity.sportType = [[dict objectForKey:@"sportType"] description];
            entity.commentCount = [[dict objectForKey:@"commentCount"] description];
            entity.praiseCount = [[dict objectForKey:@"praiseCount"] description];
            entity.actName = [[dict objectForKey:@"actName"] description];
            entity.isFlag = [[dict objectForKey:@"isFlag"] description];
            entity.isPraise = [[dict objectForKey:@"isPraise"] description];
            entity.isExtenSion = [[dict objectForKey:@"isExtenSion"] description];
            entity.extensionType = [[dict objectForKey:@"extensionType"] description];
            entity.photoList = [dict objectForKey:@"photoList"];
            NoteContentEntity *contentEntity = [[NoteContentEntity alloc] init];
            NSDictionary *contentDic = [dict objectForKey:@"noteEntity"];
            if (![contentDic isKindOfClass:[NSNull class]])
            {
                contentEntity.noteId = [[contentDic objectForKey:@"noteId"] description];
                contentEntity.noteContent = [[contentDic objectForKey:@"noteContent"] description];
                contentEntity.createDate = [[contentDic objectForKey:@"redDate"] description];
                contentEntity.range = [[contentDic objectForKey:@"range"] description];
                contentEntity.isUpdate = [[contentDic objectForKey:@"isUpdate"] description];
                contentEntity.fkid = [[contentDic objectForKey:@"fkid"] description];
                contentEntity.nickName = [[contentDic objectForKey:@"nickName"] description];
                contentEntity.userPicPath = [[contentDic objectForKey:@"userPicPath"] description];
                contentEntity.noteSource = [[contentDic objectForKey:@"noteSource"] description];
                contentEntity.actName = [[contentDic objectForKey:@"actName"] description];
                contentEntity.proName = [[contentDic objectForKey:@"proName"] description];
                contentEntity.bigPicPath = [[contentDic objectForKey:@"bigPicPath"] description];
                contentEntity.smallPicPath = [[contentDic objectForKey:@"smallPicPath"] description];
                contentEntity.month = [[contentDic objectForKey:@"month"] description];
                contentEntity.day = [[contentDic objectForKey:@"day"] description];
                contentEntity.times = [[contentDic objectForKey:@"times"] description];
                contentEntity.startDate = [[contentDic objectForKey:@"startDate"] description];
                contentEntity.endDate = [[contentDic objectForKey:@"endDate"] description];
                contentEntity.relAddress = [[contentDic objectForKey:@"relAddress"] description];
                contentEntity.lowPrice = [[contentDic objectForKey:@"lowPrice"] description];
                contentEntity.highPrice = [[contentDic objectForKey:@"highPrice"] description];
                contentEntity.perPrice = [[contentDic objectForKey:@"perPrice"] description];
                contentEntity.clubType = [[contentDic objectForKey:@"clubType"] description];
                contentEntity.logoPath = [[contentDic objectForKey:@"logoPath"] description];
                contentEntity.photoList = [contentDic objectForKey:@"photoList"];
                entity.noteEntity = contentEntity;
                
            }
            
            [noteListArr addObject:entity];
        }
        return noteListArr;
    }
    
    return nil;
}

// 删除帖子
+ (id)deleteNoteParser:(NSData *)data
{
    NSDictionary *bodyDic = [self gotDataParser:data];
    
    if (bodyDic)
    {
        return bodyDic;
    }
    
    return nil;
}

// 评论列表
+ (id)noteCommentListParser:(NSData *)data
{
    
//    NSMutableArray *noteListArrr = [@[] mutableCopy];
//    for (NSDictionary *dic in data) {
//        commentEntity *entity = [[commentEntity alloc]init];
//        entity.commId = [[dic objectForKey:@"commId"] description];
//        entity.commType = [[dic objectForKey:@"commType"] description];
//        entity.commUserId = [[dic objectForKey:@"commUserId"] description];
//        entity.nickName = [[dic objectForKey:@"nickName"] description];
//        entity.bigPicpath = [[dic objectForKey:@"bigPicPath"] description];
//        entity.replyContent = [[dic objectForKey:@"replyContent"] description];
//        
//        
//        
//        [noteListArrr addObject:entity];
//    }
//    return noteListArrr;



//    NSDictionary *bodyDic = [self gotDataParser:data];
    NSDictionary *bodyDic = @{@"commentList":@[@{@"nickName":@"黑色",@"content":@"新人报道",@"commDate":@"07月03日",@"replyId":@"",@"replyUserId":@"",@"replyNickName":@"",@"replyContent":@"",@"praFlag":@"1",@"praNum":@"5",@"praFlag":@"1"},@{@"nickName":@"白色",@"content":@"欢迎欢迎",@"commDate":@"07月03日",@"replyId":@"123",@"replyUserId":@"123",@"replyNickName":@"年华",@"replyContent":@"热烈欢迎",@"praFlag":@"1",@"praNum":@"3",@"praFlag":@"1"}]};
    if (bodyDic)
    {
        if ([bodyDic objectForKey:kWrongDlog])
        {
            return bodyDic;
        }else
        {
            NSMutableDictionary *dict = [@{} mutableCopy];
            NSMutableArray *hotArr = [@[] mutableCopy];
            NSMutableArray *commArr = [@[] mutableCopy];
            for (NSDictionary *dic in [bodyDic objectForKey:@"hotCommentList"])
            {
                commentEntity *entity = [[commentEntity alloc]init];
                entity.commId = [[dic objectForKey:@"commId"] description];
                entity.commType = [[dic objectForKey:@"commType"] description];
                entity.commUserId = [[dic objectForKey:@"commUserId"] description];
                entity.nickName = [[dic objectForKey:@"nickName"] description];
                entity.bigPicpath = [[dic objectForKey:@"bigPicPath"] description];
                entity.smallPicpath = [[dic objectForKey:@"smallPicPath"] description];
                entity.content = [[dic objectForKey:@"content"] description];
                entity.commDate = [[dic objectForKey:@"commDate"] description];
                entity.pageCommDate = [[dic objectForKey:@"pageCommDate"] description];
                entity.replyId = [dic objectForKey:@"replyId"];
                entity.replyUserId = [[dic objectForKey:@"replyUserId"] description];
                entity.replyNickName = [[dic objectForKey:@"replyNickName"] description];
                entity.replyBigPicPath = [[dic objectForKey:@"replyBigPicPath"] description];
                entity.replySmallPicPath = [[dic objectForKey:@"replySmallPicPath"] description];
                entity.replyContent = [[dic objectForKey:@"replyContent"] description];
                entity.praNum = [[dic objectForKey:@"praNum"] description];
                entity.praFlag = [[dic objectForKey:@"praFlag"] description];
                
                [hotArr addObject:entity];
            }
            [dict setObject:hotArr forKey:@"hotCommentList"];
            
            for (NSDictionary *dic in [bodyDic objectForKey:@"commentList"])
            {
                commentEntity *entity = [[commentEntity alloc]init];
                entity.commId = [[dic objectForKey:@"commId"] description];
                entity.commType = [[dic objectForKey:@"commType"] description];
                entity.commUserId = [[dic objectForKey:@"commUserId"] description];
                entity.nickName = [[dic objectForKey:@"nickName"] description];
                entity.bigPicpath = [[dic objectForKey:@"bigPicPath"] description];
                entity.smallPicpath = [[dic objectForKey:@"smallPicPath"] description];
                entity.content = [[dic objectForKey:@"content"] description];
                entity.commDate = [[dic objectForKey:@"commDate"] description];
                entity.pageCommDate = [[dic objectForKey:@"pageCommDate"] description];
                entity.replyId = [dic objectForKey:@"replyId"];
                entity.replyUserId = [[dic objectForKey:@"replyUserId"] description];
                entity.replyNickName = [[dic objectForKey:@"replyNickName"] description];
                entity.replyBigPicPath = [[dic objectForKey:@"replyBigPicPath"] description];
                entity.replySmallPicPath = [[dic objectForKey:@"replySmallPicPath"] description];
                entity.replyContent = [[dic objectForKey:@"replyContent"] description];
                entity.praNum = [[dic objectForKey:@"praNum"] description];
                entity.praFlag = [[dic objectForKey:@"praFlag"] description];

                [commArr addObject:entity];
            }
            [dict setObject:commArr forKey:@"commentList"];
            return dict;
        }
    }
    
    return nil;
}

// 评论回复列表
+ (id)commentRelyParser:(NSData *)data
{
    NSDictionary *bodyDic = [self gotDataParser:data];
    bodyDic = @{@"comment":@{@"nickName":@"脑海中的橡皮擦",@"commDate":@"07月08日 12:52",@"praNum":@"191600",@"content":@"今天在家很无聊",@"praFlag":@"1"},@"replyEntityList":@[@{@"replyNickName":@"笔记本",@"commDate":@"9天",@"praNum":@"1900",@"replyContent":@"晚上看球赛么么",@"praFlag":@"1"},@{@"replyNickName":@"小可帮",@"commDate":@"7天",@"praNum":@"89",@"replyContent":@"不去，在家里面呢",@"praFlag":@"1"},@{@"replyNickName":@"救赎",@"commDate":@"5天",@"praNum":@"46",@"replyContent":@"去哪里看球赛，带我一个",@"praFlag":@"1"},@{@"replyNickName":@"漫步天下",@"commDate":@"4天",@"praNum":@"32",@"replyContent":@"我也去，六点在万达门口集合",@"praFlag":@"1"}]};
    if (bodyDic)
    {
        if ([bodyDic objectForKey:kWrongDlog])
        {
            return bodyDic;
        }
        
        NSMutableDictionary *dict = [@{} mutableCopy];
        NSMutableArray *replyArr = [@[] mutableCopy];
        NSMutableDictionary *commentDic = [bodyDic objectForKey:@"comment"];
        commentEntity *entity = [[commentEntity alloc]init];
        entity.commId = [[commentDic objectForKey:@"commId"] description];
        entity.commUserId = [[commentDic objectForKey:@"commUserId"] description];
        entity.nickName = [[commentDic objectForKey:@"nickName"] description];
        entity.bigPicpath = [[commentDic objectForKey:@"bigPicPath"] description];
        entity.smallPicpath = [[commentDic objectForKey:@"smallPicPath"] description];
        entity.content = [[commentDic objectForKey:@"content"] description];
        entity.commDate = [[commentDic objectForKey:@"commDate"] description];
        entity.praNum = [[commentDic objectForKey:@"praNum"] description];
        entity.praFlag = [commentDic objectForKey:@"praFlag"];
        [dict setObject:entity forKey:@"comment"];
        for (NSDictionary *dic in [bodyDic objectForKey:@"replyEntityList"])
        {
            commentEntity *reEntity = [[commentEntity alloc]init];
            reEntity.replyId = [[dic objectForKey:@"replyId"] description];
            reEntity.commType = [[dic objectForKey:@"commType"] description];
            reEntity.commId = [[dic objectForKey:@"commId"] description];
            reEntity.replyUserId = [[dic objectForKey:@"replyUserId"] description];
            reEntity.replyNickName = [[dic objectForKey:@"replyNickName"] description];
            reEntity.replyBigPicPath = [[dic objectForKey:@"replyBigPicPath"] description];
            reEntity.replySmallPicPath = [[dic objectForKey:@"replySmallPicPath"] description];
            reEntity.replyContent = [[dic objectForKey:@"replyContent"] description];
            reEntity.commDate = [[dic objectForKey:@"commDate"] description];
            reEntity.praNum = [[dic objectForKey:@"praNum"] description];
            reEntity.praFlag = [dic objectForKey:@"praFlag"];
            
            [replyArr addObject:reEntity];
        }
        [dict setObject:replyArr forKey:@"replyEntityList"];
        return dict;
    }
    
    return nil;
}

// 评论
+ (id)commentNoteParser:(NSData *)data
{
    NSDictionary *bodyDic = [self gotDataParser:data];
    
    if (bodyDic)
    {
        return bodyDic;
    }
    
    return nil;
}

// 点赞
+ (id)priseNoteParser:(NSData *)data
{
    NSDictionary *bodyDic = [self gotDataParser:data];
    
    if (bodyDic)
    {
        return bodyDic;
    }
    
    return nil;
}

// 取消点赞
+ (id)cancelPriseNoteParser:(NSData *)data
{
    NSDictionary *bodyDic = [self gotDataParser:data];
    
    if (bodyDic)
    {
        return bodyDic;
    }
    
    return nil;
}

// 删除评论
+ (id)deleteCommentParser:(NSData *)data
{
    NSDictionary *bodyDic = [self gotDataParser:data];
    
    if (bodyDic)
    {
        return bodyDic;
    }
    
    return nil;
}

// 动态插入
+ (id)recommendParser:(NSData *)data
{
    NSDictionary *bodyDic = [self gotDataParser:data];
    
    if (bodyDic)
    {
        return bodyDic;
    }
    
    return nil;
}

// 可能认识的人
+ (id)mayKnowPeoParser:(NSData *)data
{
    NSDictionary *bodyDic = [self gotDataParser:data];
    
    if (bodyDic)
    {
        return bodyDic;
    }
    
    return nil;
}

//收藏公众号
+ (id)collPublicNoParser:(NSData *)data
{
    NSDictionary *bodyDic = [self gotDataParser:data];
    
    if (bodyDic)
    {
        return bodyDic;
    }
    
    return nil;
}

//取消收藏公众号
+ (id)cancelCollPublicNoParser:(NSData *)data
{
    NSDictionary *bodyDic = [self gotDataParser:data];
    
    if (bodyDic)
    {
        return bodyDic;
    }
    
    return nil;
}

// 动态提醒评论列表
+ (id)dynamicCommentListParser:(NSArray *)data{
    //
    NSMutableArray *backArr = [NSMutableArray new];
    for (NSDictionary *contantDictt in data) {
        NSDictionary *contantDict = [self nullDic:contantDictt];
        commentListEntity *Entity= [commentListEntity new];
        if ([contantDictt objectForKey:@"like_id"] && [[contantDictt objectForKey:@"like_id"] description].length > 0) {
            Entity.IsDianZan = YES;
            Entity.dymicId = [[contantDictt objectForKey:@"circle_id"] description];
            Entity.dymicContent = [[contantDictt objectForKey:@"circle_content"] description];
//            Entity.commentContent = [[contantDictt objectForKey:@"comment_content"] description];
            NSDictionary *friend_info = [contantDictt objectForKey:@"friend_info"];
            Entity.nickname = [[friend_info objectForKey:@"nickname"] description];
            Entity.timeStr = [NFMyManage timestampSwitchTime:[[contantDictt objectForKey:@"time"] integerValue]];
            if ([[[friend_info objectForKey:@"photo"] description] containsString:@"http"]) {
                Entity.headImageUrl = [[friend_info objectForKey:@"photo"] description];
            }else{
                Entity.headImageUrl = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[[friend_info objectForKey:@"photo"] description]];
            }
            Entity.imageTUrl = @"";
        }else{
            Entity.IsDianZan = NO;
            Entity.dymicId = [[contantDictt objectForKey:@"circle_id"] description];
            Entity.dymicContent = [[contantDictt objectForKey:@"circle_content"] description];
            Entity.commentContent = [[contantDictt objectForKey:@"comment_content"] description];
            NSDictionary *friend_info = [contantDictt objectForKey:@"friend_info"];
            Entity.timeStr = [NFMyManage timestampSwitchTime:[[contantDictt objectForKey:@"time"] integerValue]];
            Entity.nickname = [[friend_info objectForKey:@"nickname"] description];
            if ([[[friend_info objectForKey:@"photo"] description] containsString:@"http"]) {
                Entity.headImageUrl = [[friend_info objectForKey:@"photo"] description];
            }else{
                Entity.headImageUrl = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[[friend_info objectForKey:@"photo"] description]];
            }
            Entity.imageTUrl = @"";
        }
        
        [backArr addObject:Entity];
        
    }
    return backArr;
}









@end
