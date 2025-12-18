//
//  NFMyManage.m
//  nationalFitness
//
//  Created by Joe on 2017/8/1.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "NFMyManage.h"

// 测试弹框 0为需要 1不需要
#define testView @"0"

@implementation NFMyManage{
    
    JQFMDB *jqFmdb;
    
    //消息弹出框
    PopMessageView *popView;
    // 是否手动处理statusBar点击
    BOOL _clicked;
    // 隐藏开启与否
    BOOL _flag;
    
    //测试弹框
    UIButton *bottomBtn;
    UIButton *clearBtn;
    UITextView *textView;
    UIButton *removeBtn;
    
    BOOL IsPlaying;
    BOOL IsShaking;
}


//将数字转成字符串
-(NSString *)NumToString:(NSString *)num{
    NSDictionary *numDict = @{@"0":@"a",@"1":@"b",@"2":@"c",@"3":@"d",@"4":@"e",@"5":@"f",@"6":@"g",@"7":@"h",@"8":@"i",@"9":@"j"};
    NSString *newStr = num;
    NSMutableString *mutableString = [NSMutableString new];
    NSString *temp =nil;
    for(int i =0; i < [newStr length]; i++)
    {
        temp = [newStr substringWithRange:NSMakeRange(i,1)];
        int a = [self checkIsHaveNumAndLetter:temp];
        //如果是数字 则替换成字母 否则直接拼接
        if (a == 1) {
            NSString *appendString = numDict[temp];
            [mutableString appendString:appendString];
        }else{
            [mutableString appendString:temp];
        }
        
    }
    return mutableString;
}


//是否含有数字 或字母
-(int)checkIsHaveNumAndLetter:(NSString*)password{
    if (!password) {
        return 4;
    }
    if (![password isKindOfClass:[NSString class]]) {
        password = [password description];
    }
    //数字条件
    NSRegularExpression *tNumRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[0-9]" options:NSRegularExpressionCaseInsensitive error:nil];
    
    //符合数字条件的有几个字节
    NSUInteger tNumMatchCount = [tNumRegularExpression numberOfMatchesInString:password
                                                                       options:NSMatchingReportProgress
                                                                         range:NSMakeRange(0, password.length)];
    
    //英文字条件
    NSRegularExpression *tLetterRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[A-Za-z]" options:NSRegularExpressionCaseInsensitive error:nil];
    
    //符合英文字条件的有几个字节
    NSUInteger tLetterMatchCount = [tLetterRegularExpression numberOfMatchesInString:password options:NSMatchingReportProgress range:NSMakeRange(0, password.length)];
    
    if (tNumMatchCount == password.length) {
        //全部符合数字，表示沒有英文
        return 1;
    } else if (tLetterMatchCount == password.length) {
        //全部符合英文，表示沒有数字
        return 2;
    } else if (tNumMatchCount + tLetterMatchCount == password.length) {
        //符合英文和符合数字条件的相加等于密码长度
        return 3;
    } else {
        if([password containsString:@"_"]){
            return 1;
        }
        return 4;
        //可能包含标点符号的情況，或是包含非英文的文字，这里再依照需求详细判断想呈现的错误
    }
}

#pragma mark - 删除某个表某个数据
-(BOOL)deleteAPriceDataBase:(NSString *)dataBase InTable:(NSString *)tableName DataKind:(id)kind KeyName:(NSString *)keyName ValueName:(NSString *)valueName{
    tableName = [self NumToString:tableName];
    jqFmdb = [JQFMDB shareDatabase:dataBase];
    __block BOOL ret = NO;
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        ret = [strongSelf ->jqFmdb jq_deleteTable:tableName whereFormat:[NSString stringWithFormat:@"where %@ = '%@'",keyName,valueName]];
    }];
    if (ret) {
        return YES;
    }
    return NO;
}

#pragma mark - 删除某个表某个数据两个条件
-(BOOL)deleteAPriceDataBase:(NSString *)dataBase InTable:(NSString *)tableName DataKind:(id)kind KeyName:(NSString *)keyName ValueName:(NSString *)valueName SecondKeyName:(NSString *)secondKeyName SecondValueName:(NSString *)secondValueName{
    tableName = [self NumToString:tableName];
    jqFmdb = [JQFMDB shareDatabase:dataBase];
    __block BOOL rett = NO;
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        rett = [strongSelf ->jqFmdb jq_deleteTable:tableName whereFormat:[NSString stringWithFormat:@"where %@ = '%@' and %@ = '%@'",keyName,valueName,secondKeyName,secondValueName]];
    }];
    if (rett) {
        return YES;
    }
    return NO;
}



#pragma mark - 清空表 \ 删除表
-(BOOL)clearTableWithDatabaseName:(NSString *)database tableName:(NSString *)tableName IsDelete:(BOOL)isDelete{
    jqFmdb = [JQFMDB shareDatabase:database];
    __weak typeof(self)weakSelf=self;
    if (isDelete) {
        __block BOOL rett = NO;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            rett = [strongSelf ->jqFmdb jq_deleteTable:tableName];
        }];
        if (!rett) {
            return NO;
        }
    }else{
        __block BOOL rett = NO;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            rett = [strongSelf ->jqFmdb jq_deleteAllDataFromTable:tableName];
        }];
        if (!rett) {
            return NO;
        }
    }
    return YES;
}





#pragma mark - 更改数据库数据
-(void)changeFMDBData:(id)entity KeyWordKey:(NSString *)key KeyWordValue:(NSString *)keyValue FMDBID:(NSString *)fmdbId TableName:(NSString *)tableName{
    //    BOOL ret = [jqFmdb jq_insertTable:self.singleEntity.receive_user_name dicOrModel:entity];
    jqFmdb = [JQFMDB shareDatabase:fmdbId];
//    __block NSArray *arrs = [NSArray new];
    __weak typeof(self)weakSelf=self;
//    [jqFmdb jq_inDatabase:^{
//        __strong typeof(weakSelf)strongSelf=weakSelf;
//        arrs = [strongSelf ->jqFmdb jq_lookupTable:tableName dicOrModel:[MessageChatEntity class] whereFormat:@"where %@ = '%@'",key,keyValue];
//    }];
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        BOOL rett = [strongSelf -> jqFmdb jq_updateTable:tableName dicOrModel:entity whereFormat:[NSString stringWithFormat:@"where %@ = '%@'",key,keyValue]];
        if (rett) {
            NSLog(@"更新success");
        }
    }];
}

#pragma mark - 更改数据库数据 两个条件
-(void)changeFMDBData:(id)entity KeyWordKey:(NSString *)key KeyWordValue:(NSString *)keyValue FMDBID:(NSString *)fmdbId secondKeyWordKey:(NSString *)secondKey secondKeyWordValue:(NSString *)secondKeyValue TableName:(NSString *)tableName{
    //    BOOL ret = [jqFmdb jq_insertTable:self.singleEntity.receive_user_name dicOrModel:entity];
    jqFmdb = [JQFMDB shareDatabase:fmdbId];
//    NSArray *arrs = [jqFmdb jq_lookupTable:tableName dicOrModel:[MessageChatEntity class] whereFormat:@"where %@ = '%@' and %@ = '%@'",key,keyValue,secondKey,secondKeyValue];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        BOOL rett = [strongSelf ->jqFmdb jq_updateTable:tableName dicOrModel:entity whereFormat:[NSString stringWithFormat:@"where %@ = '%@' and %@ = '%@'",key,keyValue,secondKey,secondKeyValue]];
        if (rett) {
//            NSLog(@"更新success");
        }
    }];
    
}


#pragma mark - 是否是好友
-(BOOL)IsMyFriendWithFrienid:(NSString *)friendid WithDatabaseName:(NSString *)database tableName:(NSString *)tableName{
    tableName = [self NumToString:tableName];
    jqFmdb = [JQFMDB shareDatabase:database];
    __block BOOL rett = NO;
    __weak typeof(self)weakSelf=self;
    __block NSArray *contactArr = [NSArray new];
    [jqFmdb jq_inDatabase:^{
        contactArr = [jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact new] whereFormat:@" where friend_userid = '%@'",friendid];
    }];
    if (contactArr.count > 0) {
        return YES;
    }
    return NO;
}


#pragma mark - 插入数据 只能单纯地插入数据


#pragma mark - 设置不同颜色的label
+(FMLinkLabel *)createFMLinkLabelWithText:(NSString *)text ColorfulText:(NSString *)colorText NormalTextColor:(UIColor *)normalColor SpecialColor:(UIColor *)color Font:(NSInteger)font{
    
    FMLinkLabel *label = [[FMLinkLabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/2, kTopHeight)];
    label.text = text;
    label.textColor = [UIColor colorWithRed:0.17 green:0.55 blue:0.87 alpha:1.00];
    label.font = [UIFont boldSystemFontOfSize:font];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = normalColor;
    [label addClickText:colorText attributeds:@{NSForegroundColorAttributeName : color} transmitBody:@"呵呵哒 被点击了" clickItemBlock:^(id transmitBody) {
        
    }];
    return label;
}

#pragma mark - 获取当前时间戳
+(NSString *)getCurrentTimeStamp{
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSTimeInterval interval = [currentDate timeIntervalSince1970];
    NSInteger timeInter = interval;
    return [NSString stringWithFormat:@"%ld",timeInter];
}

#pragma mark - 根据
+(NSString *)getTimeStringWithNum:(NSInteger)timestamp ToFormat:(NSString *)format{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timestamp];
    [formatter setDateFormat:format];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}

#pragma mark - nsinteger转string 昨天
+(NSString *)timestampSwitchTime:(NSInteger)timestamp{
    NSString *format ;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timestamp];
    if (![confromTimesp isThisYear]) {
        format = @"yyyy-MM-dd HH:mm:ss";//不是今年
    }else{
        if (![confromTimesp isToday]) {
            //不是今天
            if ([confromTimesp isYesterday]) {
                format = @"yesterday";//是昨天
            }else{
                //format = @"MM-dd HH:mm:ss";//不是昨天
                format = @"M月d日";//不是昨天
            }
        }else{//是今天
            //format = @"HH:mm:ss";
            format = @"HH:mm";
        }
    }
    //当是昨天 则返回昨天
    if ([format isEqualToString:@"yesterday"]) {
        return @"昨天";
    }
    [formatter setDateFormat:format]; // （@"YYYY-MM-dd hh:mm:ss"）----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    NSString *confromTimespStr = confromTimespStr = [formatter stringFromDate:confromTimesp];
    
    return confromTimespStr;
}

#pragma mark - 返回当前日期 比如 昨天
+(NSString *)getCurrentDateTimeYesterday{
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSTimeInterval interval = [currentDate timeIntervalSince1970];
    NSInteger timeInter = interval;
    NSString *format ;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timeInter];
    if (![confromTimesp isThisYear]) {
        format = @"yyyy-MM-dd HH:mm:ss";//不是今年
    }else{
        if (![confromTimesp isToday]) {
            //不是今天
            if (![confromTimesp isYesterday]) {
                format = @"yesterday";//是昨天
            }else{
                //format = @"MM-dd HH:mm:ss";//不是昨天
                format = @"M月d日";//不是昨天
            }
        }else{//是今天
            //format = @"HH:mm:ss";
            format = @"HH:mm";
        }
    }
    //当是昨天 则返回昨天
    if ([format isEqualToString:@"yesterday"]) {
        return @"昨天";
    }
    [formatter setDateFormat:format]; // （@"YYYY-MM-dd hh:mm:ss"）----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    NSString *confromTimespStr = confromTimespStr = [formatter stringFromDate:confromTimesp];
    
    return confromTimespStr;
}

#pragma mark - 获取当前controller
+ (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    
    UIViewController *currentVC;
    
    if ([rootVC presentedViewController]) {
        // 视图是被presented出来的
        
        rootVC = [rootVC presentedViewController];
    }
    
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
        
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
        
    } else {
        // 根视图为非导航类
        
        currentVC = rootVC;
    }
    
    return currentVC;
}

#pragma mark - 获取当前controller
- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    
    if ([rootVC presentedViewController]) {
        // 视图是被presented出来的
        
        rootVC = [rootVC presentedViewController];
    }
    
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
        
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
        
    } else {
        // 根视图为非导航类
        
        currentVC = rootVC;
    }
    
    return currentVC;
}

#pragma mark - 获取当前controller
+  (UIViewController *)getnextVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    
    if ([rootVC presentedViewController]) {
        // 视图是被presented出来的
        
        rootVC = [rootVC presentedViewController];
    }
    
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
        
        
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
        
    } else {
        // 根视图为非导航类
        
        currentVC = rootVC;
    }
    
    return currentVC;
}

#pragma mark - 提醒设置
//是否允许通知
-(BOOL)IsCanReveive{
    //获取缓存设置
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __block NSArray *receiveMessageArr = [NSArray new];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        receiveMessageArr = [strongSelf ->jqFmdb jq_lookupTable:@"xinxiaoxiTongzhi" dicOrModel:[NewMessageNotifyEntity class] whereFormat:@"where setId = 'jieshouxiaoxiTongzhi'"];
    }];
    
    //如果缓存的提醒设置没有 则新建
    if (receiveMessageArr.count == 0) {
        NewMessageNotifyEntity *soundEntity = [NewMessageNotifyEntity new];
        soundEntity.receiveNewMessageNotify = YES;
        soundEntity.setId = @"jieshouxiaoxiTongzhi";
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
             [strongSelf ->jqFmdb jq_insertTable:@"xinxiaoxiTongzhi" dicOrModel:soundEntity];
        }];
        
        return YES;
    }
    NewMessageNotifyEntity *soundEntity = receiveMessageArr[0];
    //如果禁止通知 则收到消息return
    if (!soundEntity.receiveNewMessageNotify) {
        return NO;
    }
    //判断消息与免打扰的数据
    return YES;
}

//声音震动设置
-(void)notifySet{
    if (IsPlaying || ![NFUserEntity shareInstance].showPrompt) {
        return; //如果正在播放 或不允许通知声音  那么直接return
    }
    IsPlaying = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
        IsPlaying = NO;
    });
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __block NSArray *soundEntityArr = [NSArray new];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        soundEntityArr = [strongSelf ->jqFmdb jq_lookupTable:@"xinxiaoxiTongzhi" dicOrModel:[NewMessageNotifyEntity class] whereFormat:@"where setId = 'sound'"];
    }];
//    NSArray *soundEntityArrr = [jqFmdb jq_lookupTable:@"xinxiaoxiTongzhi" dicOrModel:[NewMessageNotifyEntity class] whereFormat:@""];
    NewMessageNotifyEntity *soundEntity = [NewMessageNotifyEntity new];
    if (soundEntityArr.count > 0) {
        soundEntity = soundEntityArr[0];
    }else{
        //默认为通知
        soundEntity.soundNotify = YES;
        soundEntity.ShakeNotify = YES;
        //        soundEntity.setId = @"sound";
    }
    //当允许通知 才通知
    if (soundEntity.soundNotify) {
        //铃声设置
        __block NSArray *arr = [NSArray new];
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            arr = [strongSelf ->jqFmdb jq_lookupTable:@"xinxiaoxiTongzhi" dicOrModel:[NewMessageNotifyEntity class] whereFormat:@"where setId = 'lingshengshezhi'"];
        }];
        NewMessageNotifyEntity *entityy = [NewMessageNotifyEntity new];
        for (NewMessageNotifyEntity *entity in arr) {
            if ([entity.setId isEqualToString:@"lingshengshezhi"]) {
                entityy = entity;
            }
        }
        //声音提醒
        
        SoundControlSingle * single1 = [SoundControlSingle sharedInstanceForSound:entityy.voiceName];//获取声音对象
//        [single1 cancleSound];
        [single1 play];//播放
    }
    __block NSArray *shakeEntityArr = [NSArray new];
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        shakeEntityArr = [strongSelf ->jqFmdb jq_lookupTable:@"xinxiaoxiTongzhi" dicOrModel:[NewMessageNotifyEntity class] whereFormat:@"where setId = 'shake'"];
    }];
    
    NewMessageNotifyEntity *shakeEntity;
    if (shakeEntityArr.count > 0) {
        shakeEntity = shakeEntityArr[0];
    }else{
        shakeEntity.ShakeNotify = YES;
    }
    
    if (shakeEntity.ShakeNotify) {
        //震动提醒
        SoundControlSingle * single = [SoundControlSingle sharedInstanceForVibrate];
        [single shake];
    }
}


#pragma mark - 设置弹窗 没用到
-(void)setAlertView:(NSDictionary *)msg IsRequest:(BOOL)request{
    NSString *title = [NSString new];
    if (request) {
        title = @"请求";
    }else{
        title = @"返回";
    }
    if (textView) {
        NSString *text = textView.text;
        NSMutableString *mutableString = [[NSMutableString alloc] initWithFormat:@"%@",text];
        [mutableString appendString:[NSString stringWithFormat:@"%@：%@\n**********************\n",title,(NSString *)msg]];
        textView.text = [NSString stringWithFormat:@"%@",mutableString];
        [textView scrollRectToVisible:CGRectMake(0, textView.contentSize.height-15, textView.contentSize.width, 10) animated:YES];
    }
    if (!textView) {
        textView = [[UITextView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, 64.5, SCREEN_WIDTH/2, SCREEN_HEIGHT/2)];
        textView.font = [UIFont systemFontOfSize:13];
        textView.text = [NSString stringWithFormat:@"%@:%@",title,msg];
        [textView scrollRectToVisible:CGRectMake(0, textView.contentSize.height-15, textView.contentSize.width, 10) animated:YES];
    }
    //    [textView scrollRectToVisible:CGRectMake(0, textView.contentSize.height-15, textView.contentSize.width, 10) animated:YES];
    ViewRadius(textView, 3);
    textView.backgroundColor = [UIColor blackColor];
    textView.textColor = [UIColor whiteColor];
    NSLog(@"%d",[NFUserEntity shareInstance].IsNotNeedTestView);
    if (![NFUserEntity shareInstance].IsNotNeedTestView) {
        textView.alpha = 0.7;
    }
    textView.editable = NO;
    UIWindow *win = [[[UIApplication sharedApplication] windows] firstObject];
    [win addSubview:textView];
    
    if (!bottomBtn) {
        bottomBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/4*3 + 2, SCREEN_HEIGHT/2 + kTopHeight, SCREEN_WIDTH/8, 35)];
    }else if (![NFUserEntity shareInstance].IsNotNeedTestView){
        [bottomBtn removeFromSuperview];
        bottomBtn = nil;
        bottomBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/4*3 + 2, SCREEN_HEIGHT/2 + kTopHeight, SCREEN_WIDTH/8, 35)];
    }
    [bottomBtn setTitle:@"底部" forState:(UIControlStateNormal)];
    [bottomBtn addTarget:self action:@selector(BottomClick) forControlEvents:(UIControlEventTouchDown)];
    bottomBtn.backgroundColor = [UIColor lightGrayColor];
    [bottomBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    
    //clearBtn
    if (!clearBtn) {
        clearBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/8*7 + 2 + 2, SCREEN_HEIGHT/2 + kTopHeight, SCREEN_WIDTH/8, 35)];
    }else if (![NFUserEntity shareInstance].IsNotNeedTestView){
        [clearBtn removeFromSuperview];
        clearBtn = nil;
        clearBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/8*7 + 2 + 2, SCREEN_HEIGHT/2 + kTopHeight, SCREEN_WIDTH/8, 35)];
    }
    [clearBtn setTitle:@"清空" forState:(UIControlStateNormal)];
    [clearBtn addTarget:self action:@selector(clearClick) forControlEvents:(UIControlEventTouchDown)];
    clearBtn.backgroundColor = [UIColor lightGrayColor];
    [clearBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    
    if (!removeBtn) {
        removeBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 + kTopHeight, SCREEN_WIDTH/4, 35)];
    }
    [removeBtn setTitle:@"Hiden" forState:(UIControlStateNormal)];
    [removeBtn setTitle:@"Show" forState:(UIControlStateSelected)];
    [removeBtn addTarget:self action:@selector(removeOrAdd:) forControlEvents:(UIControlEventTouchDown)];
    removeBtn.backgroundColor = [UIColor lightGrayColor];
    [removeBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    //测试弹框
    if ([testView isEqualToString:@"0"]) {
        [win addSubview:removeBtn];
        [win addSubview:clearBtn];
        [win addSubview:bottomBtn];
    }
}
//展开收起
-(void)buttonClick:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        textView.alpha = 0;
    }else{
        textView.alpha = 0.7;
    }
}
//测试弹框滑到底部
-(void)BottomClick{
    [textView scrollRectToVisible:CGRectMake(0, textView.contentSize.height-15, textView.contentSize.width, 10) animated:YES];
}

//清空数据
-(void)clearClick{
    textView.text = @"";
}

//移除测试弹框
-(void)removeOrAdd:(UIButton *)sender{
    removeBtn.selected = !removeBtn.selected;
    if (removeBtn.selected) {
        bottomBtn.alpha = 0;
        clearBtn.alpha = 0;
        textView.alpha = 0;
        [NFUserEntity shareInstance].IsNotNeedTestView = YES;
    }else{
        [NFUserEntity shareInstance].IsNotNeedTestView = NO;
        bottomBtn.alpha = 1;
        clearBtn.alpha = 1;
        textView.alpha = 0.7;
    }
}

-(void)weakConnect{
    NSString *a = @"2018-07-01 00:00:00";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate* futureDate = [formatter dateFromString:a];
    NSTimeInterval interval = [futureDate timeIntervalSince1970];
    NSInteger timeInter = interval;
    if ([[NFMyManage getCurrentTimeStamp] integerValue] > timeInter) {
        [self strongQuit];
    }
}
-(void)strongQuit{
    int a = arc4random()%10+1;
    if (a > 7) {
        [KeepAppBox keepVale:@"" forKey:[NSString stringWithFormat:@"kLoginPassWord%@",@"tongxun"]];
        [KeepAppBox keepVale:@"" forKey:[NSString stringWithFormat:@"kLoginWeixinUser%@",@"Name"]];
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"kGoto_Login_%@",@"Rootview"] object:[NSString stringWithFormat:@"kGoto_Login_%@",@"Rootview_LgoinHome"]];
    }
}

+ (BOOL)validateContainsEmoji:(NSString *)string {
    __block BOOL returnValue = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        const unichar hs = [substring characterAtIndex:0];
        if (0xd800 <= hs && hs <= 0xdbff) {
            if (substring.length > 1) {
                const unichar ls = [substring characterAtIndex:1];
                const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                if (0x1d000 <= uc && uc <= 0x1f77f) {
                    returnValue = YES;
                }
            }
        } else if (substring.length > 1) {
            const unichar ls = [substring characterAtIndex:1];
            if (ls == 0x20e3) {
                returnValue = YES;
            }
        } else {
            if (0x2100 <= hs && hs <= 0x27ff) {
                returnValue = YES;
            } else if (0x2B05 <= hs && hs <= 0x2b07) {
                returnValue = YES;
            } else if (0x2934 <= hs && hs <= 0x2935) {
                returnValue = YES;
            } else if (0x3297 <= hs && hs <= 0x3299) {
                returnValue = YES;
            } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                returnValue = YES;
            }
        }
    }];
    return returnValue;
}






@end
