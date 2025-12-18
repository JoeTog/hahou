//
//  UUMessage.m
//  UUChatDemoForTextVoicePicture
//
//  Created by shake on 14-8-26.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import "UUMessage.h"
#import "NSDate+Utils.h"

#define showTimeInterval 3*60

@implementation UUMessage
- (void)setWithDict:(NSDictionary *)dict{
    
    self.strIcon = dict[@"strIcon"];
    self.userName = dict[@"userName"];
    self.nickName = dict[@"userNickName"];
    self.originalNickName = [[dict[@"group_msg_sender_original_name"] description] length] > 0?[dict[@"group_msg_sender_original_name"] description]:[dict[@"userNickName"] description];
    if(dict[@"strTime"]){
        self.strTime = [self changeTheDateString:dict[@"strTime"]];
    }
    self.appMsgId = dict[@"appMsgId"];
    
    if ([dict[@"from"] intValue]==1) {
        self.from = UUMessageFromMe;
        if ([dict[@"IsServer"] isEqualToString:@"1"]) {
            self.failStatus = @"0";
        }
    }else{
        self.from = UUMessageFromOther;
    }
    
    switch ([dict[@"type"] integerValue]) {
        case 0:
            self.type = UUMessageTypeText;
            self.strContent = dict[@"strContent"];
            break;
        
        case 1:
            self.type = UUMessageTypePicture;
//            self.picture = dict[@"picture"];
            self.pictureUrl = dict[@"picture"];
            self.pictureScale = [[dict[@"imgRatio"] description] floatValue];
            self.fileId = dict[@"fileId"];
            //当为转发 已经存在path 则赋值
            if ([dict objectForKey:@"filePath"]) {
                self.pictureUrl = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,dict[@"filePath"]];
            }
            break;
        
        case 2:
            self.type = UUMessageTypeVoice;
            self.voice = dict[@"voice"];
            self.strVoiceTime = dict[@"strVoiceTime"];
            break;
            //
        case 3:
            self.type = UUMessageTypeRed;
            self.strContent = dict[@"strContent"];
            if (dict[@"singleRed"]) {
                self.priceAccount = dict[@"singleRed"];
            }else if (dict[@"groupRed"]){
                self.priceAccount = dict[@"groupRed"];
                self.redCount = dict[@"groupRedCount"];
            }
            break;
        case 4:
            self.type = UUMessageTypeRecommendCard;
            self.strId = dict[@"strId"]; //名片人的id
            self.strVoiceTime = dict[@"strVoiceTime"];//名片的username
            self.pictureUrl = dict[@"pictureUrl"];//名片信息的昵称
            self.fileId = [dict[@"fileId"] description];//名片人的头像
            self.cachePicPath = dict[@"fileId"];//名片人的头像
            self.strContent = [NSString stringWithFormat:@"[个人名片]%@",self.pictureUrl];
            
            break;
        case 6:
            //到不了这里，因为红包 只有 0 1 2和上面重复
            self.type = UUMessageTypeTransfer;
            self.strContent = dict[@"strContent"];
            
            break;
        default:
            break;
    }
}

//"08-10 晚上08:09:41.0" ->
//"昨天 上午10:09"或者"2012-08-10 凌晨07:09"
- (NSString *)changeTheDateString:(NSString *)Str
{
    NSString *subString = [Str substringWithRange:NSMakeRange(0, 19)];
    NSDate *lastDate = [NSDate dateFromString:subString withFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *dateStr;  //年月日
    NSString *period;   //时间段
    NSString *hour;     //时
    
    if ([lastDate year]==[[NSDate date] year]) {
        NSInteger days = [NSDate daysOffsetBetweenStartDate:lastDate endDate:[NSDate date]];
        if (days <= 2) {
            dateStr = [lastDate stringYearMonthDayCompareToday];
        }else{
            dateStr = [lastDate stringMonthDay];
        }
    }else{
        dateStr = [lastDate stringYearMonthDay];
    }
    
    
    if ([lastDate hour]>=5 && [lastDate hour]<12) {
        period = @"AM";
        hour = [NSString stringWithFormat:@"%02d",(int)[lastDate hour]];
    }else if ([lastDate hour]>=12 && [lastDate hour]<=18){
        period = @"PM";
        hour = [NSString stringWithFormat:@"%02d",(int)[lastDate hour]-12];
    }else if ([lastDate hour]>18 && [lastDate hour]<=23){
        period = @"Night";
        hour = [NSString stringWithFormat:@"%02d",(int)[lastDate hour]-12];
    }else{
        period = @"Dawn";
        hour = [NSString stringWithFormat:@"%02d",(int)[lastDate hour]];
    }
    return [NSString stringWithFormat:@"%@ %@ %@:%02d",dateStr,period,hour,(int)[lastDate minute]];
}

- (void)minuteOffSetStart:(NSString *)start end:(NSString *)end
{
    if (!start) {
        self.showDateLabel = YES;
        return;
    }
    
    NSString *subStart = [start substringWithRange:NSMakeRange(0, 19)];
    NSDate *startDate = [NSDate dateFromString:subStart withFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *subEnd = [end substringWithRange:NSMakeRange(0, 19)];
    NSDate *endDate = [NSDate dateFromString:subEnd withFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    //这个是相隔的秒数
    NSTimeInterval timeInterval = [startDate timeIntervalSinceDate:endDate];
    
    //相距5分钟显示时间Label 
    if (fabs (timeInterval) > showTimeInterval) {
        self.showDateLabel = YES;
    }else{
        self.showDateLabel = NO;
    }
    
}
@end
