//
//  MessageTableViewCell.m
//  nationalFitness
//
//  Created by Joe on 2017/6/28.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "MessageTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "UUImageAvatarBrowser.h"
#import "NFShowImageView.h"

@implementation MessageTableViewCell{
    //时间 头时间
    __weak IBOutlet UILabel *messageTimeLabel;
    
    
    //对方消息
    __weak IBOutlet UUMessageContentButton *otherContantBtn;
    //你的名字
    __weak IBOutlet UILabel *youNameLabel;
    //对方消息 高度 宽度约束
    
    //我的的消息 头像去除
    __weak IBOutlet UIImageView *mineImageView;
    __weak IBOutlet UUMessageContentButton *mineContantBtn;
    //我的名字 去除
    __weak IBOutlet UILabel *mineNameLabel;
    
    //你的消息时间
    __weak IBOutlet UILabel *youMessageTimeLabel;
    //我消息的时间
    __weak IBOutlet UILabel *myMessageTimeLabel;
    //重发消息按钮 距离消息约束 默认为25【有时间的情况下】
    __weak IBOutlet NSLayoutConstraint *reSendConstaint;
    
    UUAVAudioPlayer *audio;
    AVAudioPlayer *player;
    NSString *voiceURL;//语音网址
    NSData *songData;
    
    UIView *headImageBackView;
    
    //是否正在编辑菜单【拷贝、转发等】
    BOOL IsEditMenu;
    
    JQFMDB *jqFmdb;
    //加载动画
    GYHSectorProgressView *progressV;
//    bottomEditMenuView *bottomEditView;
    //秒 倒计时五秒显示未发送
    int secTime_;
    
    SocketRequest *socketRequest;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    //如果需要时间 则设置隐藏为no
    
//    messageTimeLabel.hidden = YES;
    
    // 4、创建内容
//    self.btnContent = [UUMessageContentButton buttonWithType:UIButtonTypeCustom];
//    [self.btnContent setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    self.btnContent.titleLabel.font = ChatContentFont;
//    self.btnContent.titleLabel.numberOfLines = 0;
//    [self.btnContent addTarget:self action:@selector(btnContentClick)  forControlEvents:UIControlEventTouchUpInside];
//    
//    [otherContantBtn addSubview:self.btnContent];
//    [mineContantBtn addSubview:self.btnContent];
    
    otherContantBtn.titleLabel.numberOfLines = 0;
    otherContantBtn.titleLabel.font = ChatContentFont;
    //otherContantBtn.titleLabel.textColor = UIColorFromRGB(0x435a8e);
    otherContantBtn.backgroundColor = [UIColor clearColor];
    
    mineContantBtn.titleLabel.numberOfLines = 0;
    mineContantBtn.titleLabel.font = ChatContentFont;
    //mineContantBtn.titleLabel.textColor = UIColorFromRGB(0x435a8e);
    mineContantBtn.backgroundColor = [UIColor clearColor];
    
//    ViewRadius(youImageView, youImageView.frame.size.width/2);
//    otherContantBtn = [UUMessageContentButton buttonWithType:UIButtonTypeCustom];
//    [otherContantBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    otherContantBtn.titleLabel.font = ChatContentFont;
//    otherContantBtn.titleLabel.numberOfLines = 0;
//    
//    mineContantBtn = [UUMessageContentButton buttonWithType:UIButtonTypeCustom];
//    [mineContantBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    mineContantBtn.titleLabel.font = ChatContentFont;
//    mineContantBtn.titleLabel.numberOfLines = 0;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(UUAVAudioPlayerDidFinishPlay) name:@"VoicePlayHasInterrupt" object:nil];
    //设置头像
//    NSLog(@"----\n%@\n-----",self.headPicpath);
    
    //otherContantBtn
//    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTap:)];
//    longTap.minimumPressDuration = 0.3;
//    [mineContantBtn addGestureRecognizer:longTap];
//    [mineContantBtn addTarget:self action:@selector(preventFlicker:) forControlEvents:UIControlEventAllTouchEvents];
//
//    UILongPressGestureRecognizer *longTap2 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTap:)];
//    longTap2.minimumPressDuration = 0.3;
//    [otherContantBtn addGestureRecognizer:longTap2];
//    [otherContantBtn addTarget:self action:@selector(preventFlicker:) forControlEvents:UIControlEventAllTouchEvents];
    
    //UIMenuControllerWillHideMenuNotification
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(menuHiden) name:UIMenuControllerWillHideMenuNotification object:nil];
    
    //youMessageTimeLabel.textColor = UIColorFromRGB(0x435a8e);
    
}

-(void)menuHiden{
    if (IsEditMenu) {
        IsEditMenu = NO;
        if (self.messageFrame.message.type == UUMessageTypePicture) {
            return;
        }
        if (self.messageFrame.message.from == UUMessageFromMe) {
            UIImage *normalSelected = [UIImage imageNamed:@"chatMyMessage_Normal"];
            normalSelected = [UIImage SDResizeWithIma:normalSelected];
            [mineContantBtn setBackgroundImage:normalSelected forState:UIControlStateNormal];
        }else if (self.messageFrame.message.from == UUMessageFromOther){
            UIImage *normalSelected = [UIImage imageNamed:@"chatSickMessage_Normal"];
            normalSelected = [UIImage SDResizeWithIma:normalSelected];
            [otherContantBtn setBackgroundImage:normalSelected forState:UIControlStateNormal];
        }
        
    }
}

- (void)preventFlicker:(UIButton *)button {
    if (button.highlighted) {
        button.highlighted = NO;
    }
}

-(void)returnEdit:(ReturnEditBlock)block{
    if (self.returnEditBlock != block) {
        self.returnEditBlock = block;
    }
}

-(void)returnCancel:(ReturnCancelBlock)block{
    if (self.returnCancelBlock != block) {
        self.returnCancelBlock = block;
    }
}
//
-(void)returnDelete:(ReturnDeleteBlock)block{
    if (self.returnDeleteBlock != block) {
        self.returnDeleteBlock = block;
    }
}

-(void)returnDrow:(ReturnDrowBlock)block{
    if (self.returnDrowBlock != block) {
        self.returnDrowBlock = block;
    }
}

-(void)returnLongTap:(ReturnLongTapBlock)block{
    if (self.returnLongTapBlock != block) {
        self.returnLongTapBlock = block;
    }
}

-(void)returnRegisterResponder:(ReturnRegisterResponderBlock)block{
    if (self.returnRegisterResponderBlock != block) {
        self.returnRegisterResponderBlock = block;
    }
}

#pragma mark - 图片、语音 点击手势
-(void)tapBackgroundClick{
    [[UIMenuController sharedMenuController] setMenuVisible:NO];
    if (self.messageFrame.message.type == UUMessageTypePicture && self.messageFrame.message.pictureUrl.length <= [NFUserEntity shareInstance].HeadPicpathAppendingString.length) {
        [SVProgressHUD showInfoWithStatus:@"图片加载失败"];
        return;
    }
    if (self.messageFrame.message.from == UUMessageFromMe) {
        if (self.messageFrame.message.type == UUMessageTypeVoice) {
            audio = [UUAVAudioPlayer sharedInstance];
            audio.delegate = self;
//                    [audio playSongWithUrl:voiceURL];//播放语音网址语音
            [audio playSongWithData:songData];
        }else{
            if (mineContantBtn.backImageView) {
//                [UUImageAvatarBrowser showImage:mineContantBtn.backImageView];
                //查看聊天记录所有图片
                [self lookSingleCachePictureArrWithFriendId:self.chatMemberId IsSelf:YES];
                
                //让键盘放弃第一响应者
                if (self.returnRegisterResponderBlock) {
                    self.returnRegisterResponderBlock();
                }
            }else{
                [SVProgressHUD showInfoWithStatus:@"图片不存在"];
            }
        }
    }else if(self.messageFrame.message.from == UUMessageFromOther){
        if (self.messageFrame.message.type == UUMessageTypeVoice) {
            audio = [UUAVAudioPlayer sharedInstance];
            audio.delegate = self;
//                    [audio playSongWithUrl:voiceURL];
            [audio playSongWithData:songData];
        }else{
            if (otherContantBtn.backImageView) {
//                [UUImageAvatarBrowser showImage:otherContantBtn.backImageView];
                //查看聊天记录所有图片
                [self lookSingleCachePictureArrWithFriendId:self.chatMemberId IsSelf:NO];
                if (self.returnRegisterResponderBlock) {
                    self.returnRegisterResponderBlock();
                }
            }else{
                [SVProgressHUD showInfoWithStatus:@"图片不存在"];
            }
        }
    }
}

#pragma mark - 点击的消息中有网址 进行跳转
-(void)tapURLClick{
    //让键盘放弃第一响应者
    if (self.returnRegisterResponderBlock) {
        self.returnRegisterResponderBlock();
    }
    if (self.searchedURLArr.count == 1) {
        NSString *jumpURL = [self.searchedURLArr firstObject];
        if ([jumpURL containsString:@"http"] || [jumpURL containsString:@"Http"]) {
        }else{
            jumpURL = [NSString stringWithFormat:@"http://%@",jumpURL];
        }
//        jumpURL = @"http://www.cscscs.cc";
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:jumpURL]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:jumpURL] options:@{} completionHandler:nil];
        }else{
            NSLog(@"");
        }
    }else{
        //一个消息中有多个网址
        PopView *popCostTableV = [[PopView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 50, SCREEN_WIDTH/3*2) message:@"选择跳转网址" CellArrar:self.searchedURLArr isSureBlock:^(BOOL sureBlock, NSInteger index) {
            if (sureBlock) {
                NSString *jumpURL = self.searchedURLArr[index];
                if ([jumpURL containsString:@"http"] || [jumpURL containsString:@"Http"]) {
                }else{
                    jumpURL = [NSString stringWithFormat:@"http://%@",jumpURL];
                }
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:jumpURL] options:@{} completionHandler:nil];
            }
        } ClickCellBlock:^(NSInteger index) {//
        }];
        popCostTableV.isOnlyOne = YES;//只能单选
        [popCostTableV setTableviewHeadBackLabelColor:[UIColor colorThemeColor]];//head背景
        [popCostTableV setTableviewSureBtnColor:[UIColor colorThemeColor]];//确定按钮颜色
        [[KeepAppBox viewController:self].view addSubview:popCostTableV];
    }
}

#pragma mark - 长按手势
- (void)longTap:(UILongPressGestureRecognizer *)recognizer {
    if (!IsEditMenu) {
        IsEditMenu = YES;
        self.returnLongTapBlock();
    }else{
        return;
    }
    UUMessage *message = _messageFrame.message;
    //play audio
    int a = 1;
    if (self.messageFrame.message.type == UUMessageTypeVoice && a == 0) {
        
        audio = [UUAVAudioPlayer sharedInstance];
        audio.delegate = self;
        //        [audio playSongWithUrl:voiceURL];
        [audio playSongWithData:songData];
    }
    //show the picture
    else if (self.messageFrame.message.type == UUMessageTypePicture && a == 0)
    {
        if (message.from == UUMessageFromMe) {
            if (mineContantBtn.backImageView) {
                [UUImageAvatarBrowser showImage:mineContantBtn.backImageView];
            }else{
                [SVProgressHUD showInfoWithStatus:@"图片不存在"];
            }
        }else if(message.from == UUMessageFromOther){
            if (otherContantBtn.backImageView) {
                [UUImageAvatarBrowser showImage:otherContantBtn.backImageView];
            }else{
                [SVProgressHUD showInfoWithStatus:@"图片不存在"];
            }
        }
    }
    // show text and gonna copy that
    else if (self.messageFrame.message.type == UUMessageTypeText || YES)
    {
        if (message.from == UUMessageFromMe) {
            [mineContantBtn becomeFirstResponder];
            UIMenuController *menu = [UIMenuController sharedMenuController];
            UIMenuItem * item1 = [[UIMenuItem alloc]initWithTitle:@"拷贝" action:@selector(myCopy:)];
            UIMenuItem * item2 = [[UIMenuItem alloc]initWithTitle:@"转发" action:@selector(myForward:)];
            UIMenuItem * item3 = [[UIMenuItem alloc]initWithTitle:@"删除" action:@selector(myDelete:)];
            UIMenuItem * item4 = [[UIMenuItem alloc]initWithTitle:@"撤回" action:@selector(myWithDrow:)];
            UIMenuItem * item5 = [[UIMenuItem alloc]initWithTitle:@"更多" action:@selector(moreEdit:)];
            UIMenuItem * item6 = [[UIMenuItem alloc]initWithTitle:@"收藏" action:@selector(savePic:)];
            BOOL ret = [ClearManager IsAllowDraw:self.messageFrame.message.localReceiveTime];
            if (ret) {
                if (_messageFrame.message.type == UUMessageTypeVoice) {
                    [menu setMenuItems:@[item3,item4,item5]];
                }else if (_messageFrame.message.type == UUMessageTypePicture){
                    [menu setMenuItems:@[item2,item3,item4,item5,item6]];
                }else{
                    [menu setMenuItems:@[item1,item2,item3,item4,item5]];
                }
            }else{
                if (_messageFrame.message.type == UUMessageTypeVoice) {
                    [menu setMenuItems:@[item3,item5]];
                }else if (_messageFrame.message.type == UUMessageTypePicture){
                    [menu setMenuItems:@[item2,item3,item4,item5,item6]];
                }else{
                    [menu setMenuItems:@[item1,item2,item3,item5]];
                }
            }
            [menu setTargetRect:mineContantBtn.frame inView:mineContantBtn.superview];
            [menu setMenuVisible:YES animated:YES];
            
            //改变背景图片为高亮
            UIImage *normalSelected = [UIImage imageNamed:@"chatMyMessage_Highlighted"];
            normalSelected = [UIImage SDResizeWithIma:normalSelected];
            if (message.type != UUMessageTypePicture) {
                [mineContantBtn setBackgroundImage:normalSelected forState:UIControlStateNormal];
            }
            //收藏
            [mineContantBtn returnSaveBlock:^{
                NSLog(@"");
                [EmotionTool addCollectImage:self.messageFrame.message.pictureUrl AndDic:@{@"fileId":[NSString stringWithFormat:@"%@",self.messageFrame.message.fileId],@"scale":[NSString stringWithFormat:@"%.2f",self.messageFrame.message.pictureScale]}];

                socketRequest = [SocketRequest share];
                if(self.messageFrame.message.fileId && self.messageFrame.message.fileId.length > 0){

                    [socketRequest collectEmoji:@{@"file_id":self.messageFrame.message.fileId}];
                }
                
            }];
            
            //转发
            [mineContantBtn returnForwardBlock:^{
                //转发 MessageChatListViewController
                UIStoryboard * sb = [UIStoryboard storyboardWithName:@"NewHomeStoryboard" bundle:nil];
                MessageChatListViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"MessageChatListViewController"];
                UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
                toCtrol.fromType = YES;
                toCtrol.forwardContent = mineContantBtn.titleLabel.text;
                toCtrol.contentType = @"0";//转发消息类型 0文字 1图片 2语音
                if (self.messageFrame.message.type == UUMessageTypePicture) {
                    toCtrol.forwardContent = @"图片";
                    toCtrol.contentType = @"1";
                    if (_messageFrame.message.picture) {
                        [NFUserEntity shareInstance].forwardImage = _messageFrame.message.picture;
                    }else{
                        [NFUserEntity shareInstance].forwardImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:message.cachePicPath];
                    }
                }else if (self.messageFrame.message.type == UUMessageTypeVoice){
                    toCtrol.forwardContent = @"语音";
                    toCtrol.contentType = @"2";
                }
                toCtrol.chatingName = self.otherName;
                toCtrol.forwardUUMessageFrame = self.messageFrame;
                [currentVC.navigationController pushViewController:toCtrol animated:YES];
                
            }];
            
            [mineContantBtn returnCopyBlock:^{
                //拷贝
                
            }];
            [mineContantBtn returnDeleteBlock:^{
                //删除
                [self showBottomView];
            }];
            [mineContantBtn returnmyWithDrowBlock:^{
                //撤回
                [self showBottomViewDrow];
            }];
            //returnMoreEditBlock
            [mineContantBtn returnMoreEditBlock:^{
                //更多
                
                [self.singleTableV setEditing:YES animated:YES];
                //隐藏右侧按钮
                if (self.returnEditBlock) {
                    self.returnEditBlock();
                }
                //bottomEditView
                
            }];
        }else if(message.from == UUMessageFromOther){
            [otherContantBtn becomeFirstResponder];
            UIMenuController *menu = [UIMenuController sharedMenuController];
            UIMenuItem * item1 = [[UIMenuItem alloc]initWithTitle:@"拷贝" action:@selector(myCopy:)];
            UIMenuItem * item2 = [[UIMenuItem alloc]initWithTitle:@"转发" action:@selector(myForward:)];
            UIMenuItem * item3 = [[UIMenuItem alloc]initWithTitle:@"删除" action:@selector(myDelete:)];
            UIMenuItem * item4 = [[UIMenuItem alloc]initWithTitle:@"撤回" action:@selector(myWithDrow:)];
            UIMenuItem * item5 = [[UIMenuItem alloc]initWithTitle:@"更多" action:@selector(moreEdit:)];
            UIMenuItem * item6 = [[UIMenuItem alloc]initWithTitle:@"收藏" action:@selector(savePic:)];
            [menu setMenuItems:@[item1,item2,item3,item4,item5]];
            if (_messageFrame.message.type == UUMessageTypeVoice) {
                [menu setMenuItems:@[item3,item5]];
            }else if (_messageFrame.message.type == UUMessageTypePicture){
                [menu setMenuItems:@[item2,item3,item4,item5,item6]];
            }else{
                [menu setMenuItems:@[item1,item2,item3,item5]];
            }
            [menu setTargetRect:otherContantBtn.frame inView:otherContantBtn.superview];
            [menu setMenuVisible:YES animated:YES];
            //改变背景图片为高亮
            UIImage *normalSelected = [UIImage imageNamed:@"chatSickMessage_Highlighted"];
            normalSelected = [UIImage SDResizeWithIma:normalSelected];
            if (message.type != UUMessageTypePicture) {
                [otherContantBtn setBackgroundImage:normalSelected forState:UIControlStateNormal];
            }
            [otherContantBtn returnSaveBlock:^{
                NSLog(@"");
                [EmotionTool addCollectImage:self.messageFrame.message.pictureUrl AndDic:@{@"fileId":[NSString stringWithFormat:@"%@",self.messageFrame.message.fileId],@"scale":[NSString stringWithFormat:@"%.2f",self.messageFrame.message.pictureScale]}];
                socketRequest = [SocketRequest share];
                if(self.messageFrame.message.fileId && self.messageFrame.message.fileId.length > 0){

                    [socketRequest collectEmoji:@{@"file_id":self.messageFrame.message.fileId}];
                }
                
            }];
            [otherContantBtn returnForwardBlock:^{
                //转发 MessageChatListViewController
                UIStoryboard * sb = [UIStoryboard storyboardWithName:@"NewHomeStoryboard" bundle:nil];
                MessageChatListViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"MessageChatListViewController"];
                UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
                toCtrol.fromType = YES;
                toCtrol.forwardContent = otherContantBtn.titleLabel.text;
                toCtrol.contentType = @"0";//转发消息类型 0文字 1图片 2语音
                if (self.messageFrame.message.type == UUMessageTypePicture) {
                    toCtrol.forwardContent = @"图片";
                    toCtrol.contentType = @"1";
                    if (_messageFrame.message.picture) {
                        [NFUserEntity shareInstance].forwardImage = _messageFrame.message.picture;
                    }else{
                        [NFUserEntity shareInstance].forwardImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:message.cachePicPath];
                    }
                }else if (self.messageFrame.message.type == UUMessageTypeVoice){
                    toCtrol.forwardContent = @"语音";
                    toCtrol.contentType = @"2";
                }
                toCtrol.chatingName = self.otherName;
                toCtrol.forwardUUMessageFrame = self.messageFrame;
                [currentVC.navigationController pushViewController:toCtrol animated:YES];
            }];
            [otherContantBtn returnDeleteBlock:^{
                //删除
                [self showBottomView];
            }];
            [otherContantBtn returnCopyBlock:^{
                //拷贝
            }];
            [otherContantBtn returnmyWithDrowBlock:^{
                //撤回
            }];
            [otherContantBtn returnMoreEditBlock:^{
                //更多
                [self.singleTableV setEditing:YES animated:YES];
                //隐藏右侧按钮
                if (self.returnEditBlock) {
                    self.returnEditBlock();
                }
            }];
        }
    }
}

-(void)layoutSubviews
{
    for (UIControl *control in self.subviews){
        if ([control isMemberOfClass:NSClassFromString(@"UITableViewCellEditControl")]){
            for (UIView *view in control.subviews)
            {
                if ([view isKindOfClass: [UIImageView class]]) {
                    UIImageView *image=(UIImageView *)view;
                    if (self.selected) {
                        image.image=[UIImage imageNamed:@"CellButtonSelected"];
                    }else
                    {
                        image.image=[UIImage imageNamed:@"CellButton"];
                    }
                }
            }
        }
    }
    [super layoutSubviews];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    if (editing) {
        mineContantBtn.userInteractionEnabled = NO;
        otherContantBtn.userInteractionEnabled = NO;
//        self.selected = NO;
        
    }else{
        mineContantBtn.userInteractionEnabled = YES;
        otherContantBtn.userInteractionEnabled = YES;
    }
    for (UIControl *control in self.subviews){
        if ([control isMemberOfClass:NSClassFromString(@"UITableViewCellEditControl")]){
            for (UIView *view in control.subviews)
            {
                if ([view isKindOfClass: [UIImageView class]]) {
                    UIImageView *image=(UIImageView *)view;
                    if (!self.selected) {
                        image.image=[UIImage imageNamed:@"CellButton"];
                    }else{
                        image.image=[UIImage imageNamed:@"CellButtonSelected"];
                    }
                }
            }
        }
    }
    if (editing) {
        //当编辑的时候 设置为有选中背景，再设置背景颜色为透明
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    } else {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}

//删除某条消息 在viewcontroller中deleteCommitClick 批量删除
-(void)showBottomView{
    LWWeChatActionSheet *sheet = [[LWWeChatActionSheet alloc] initWithWeChatActionSheetCancelButtonTitle:@"取消" title:@"是否删除该条消息?" otherButtonTitles:[NSArray arrayWithObjects:@"确定", nil] btnClickBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 999) {
            return ;
        }
        if (self.returnDeleteBlock) {
            self.returnDeleteBlock();
        }
        //self.messageFrame
//        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
//        BOOL ret = [jqFmdb jq_deleteTable:self.singleContactEntity.friend_userid whereFormat:[NSString stringWithFormat:@"where chatId = '%@'",self.messageFrame]];
//        [self.dataArr removeObjectAtIndex:self.selectedIndexPath.row];
//        [self.singleTableV   deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:self.selectedIndexPath]withRowAnimation:UITableViewRowAnimationBottom];
//                        [self.singleTableV endUpdates];
    }];
    [sheet show];
}
//撤回sheet
-(void)showBottomViewDrow{
    LWWeChatActionSheet *sheet = [[LWWeChatActionSheet alloc] initWithWeChatActionSheetCancelButtonTitle:@"取消" title:@"是否撤回该条消息?" otherButtonTitles:[NSArray arrayWithObjects:@"确定", nil] btnClickBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 999) {
            return ;
        }
        if (self.returnDrowBlock) {
            self.returnDrowBlock();
        }
    }];
    [sheet show];
}

#pragma mark - 语音相关
- (void)UUAVAudioPlayerBeiginLoadVoice
{
    UUMessage *message = _messageFrame.message;
    if (message.from == UUMessageFromMe) {
        [mineContantBtn benginLoadVoice];
    }else if(message.from == UUMessageFromOther){
        [otherContantBtn benginLoadVoice];
    }
}

- (void)UUAVAudioPlayerBeiginPlay
{
    UUMessage *message = _messageFrame.message;
    if (message.from == UUMessageFromMe) {
        [mineContantBtn didLoadVoice];
    }else if(message.from == UUMessageFromOther){
        [otherContantBtn didLoadVoice];
    }
}

- (void)UUAVAudioPlayerDidFinishPlay
{
    UUMessage *message = _messageFrame.message;
    if (message.from == UUMessageFromMe) {
        [mineContantBtn stopPlay];
        [[UUAVAudioPlayer sharedInstance]stopSound];
    }else if(message.from == UUMessageFromOther){
        [otherContantBtn stopPlay];
        [[UUAVAudioPlayer sharedInstance]stopSound];
    }
}

//头像点击

//s设置头像
-(void)setHeadPicpath:(NSString *)headPicpath{
    [self.youImageView sd_setImageWithURL:[NSURL URLWithString:headPicpath] placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
}

#pragma mark - setMessageFrame
-(void)setMessageFrame:(UUMessageFrame *)messageFrame{
    self.youImageView.hidden = NO;
    BOOL IsExistURL = NO;//是否含有网址字符
    //当该消息没有chatid、自己发送的、消息状态不为已经失败 则进行倒计时
    //且failStatus为nil
    if (messageFrame.message.chatId.length == 0 && messageFrame.message.from == UUMessageFromMe && messageFrame.message.failStatus.length == 0 && messageFrame) {
//        [self.reSendBtn setTitle:@"发送中" forState:(UIControlStateNormal)];
//        [self.reSendBtn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
//        NSLog(@"\nmessageFrame.message.chatId:%@\n",messageFrame.message.chatId);
//        //如果该条消息没有服务器messageid 那么倒计时五秒 五秒后还没有则显示红色未发送
        __weak typeof(self)weakSelf=self;
        weakSelf.timer = [HCDTimer repeatingTimerWithTimeInterval:1 block:^{
            secTime_ ++;
            //超时五秒并且没有服务器返回的chatid。则显示未发送
            if (secTime_ == outTime && messageFrame.message.chatId.length == 0) { NSLog(@"\n%@\n%@",messageFrame.message.chatId,messageFrame.message.strContent);
                self.reSendBtn.hidden = NO;
                messageFrame.message.failStatus = @"1";
                jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
                __block NSArray *existArr = [NSArray new];
                __weak typeof(self)weakSelf=self;
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    existArr = [strongSelf ->jqFmdb jq_lookupTable:strongSelf.singleContactEntity.friend_userid dicOrModel:[MessageChatEntity class] whereFormat:@"where appMsgId = '%@'",messageFrame.message.appMsgId];
                }];
                if (existArr.count == 1) {
                    MessageChatEntity *changeEntity = [existArr lastObject];
                    changeEntity.chatId = @"";
                    changeEntity.failStatus = @"1";
                    [self.myManage changeFMDBData:changeEntity KeyWordKey:@"appMsgId" KeyWordValue:messageFrame.message.appMsgId FMDBID:@"tongxun.sqlite" TableName:self.singleContactEntity.friend_userid];
                }
            }else if (secTime_ > outTime){
                [self.timer invalidate];
            }
        }];
        
    }else{
        //否则 停止计时器
        if (self.timer) {
            [self.timer invalidate];
        }
    }
    
    if ([messageFrame.message.failStatus isEqualToString:@"1"]) {
        self.reSendBtn.hidden = NO;
    }
//    if (messageFrame.message.type == UUMessageTypeVoice) {
//        self.reSendBtn.hidden = NO;
//    }
    
    voiceURL = @"http://otehyz17s.bkt.clouddn.com/audio/lvRecord1.mp3";
    _messageFrame = messageFrame;
    UUMessage *message = messageFrame.message;
    //隐藏之间的时间
//    messageTimeLabel.hidden = YES;
    //默认隐藏自己的消息
    myMessageTimeLabel.hidden = YES;
    mineContantBtn.hidden = YES;
    //设置是否显示时间
    if (messageFrame.showTimeHead) {
        messageTimeLabel.hidden = NO;
    }else{
        //不显示时间的话，将消息距离顶部约束减少
        self.otherContantTopConstaint.constant = 10;
        self.mineContantTopConstaint.constant = 10;
        self.otherIconImageTopConstaint.constant = 10;
        messageTimeLabel.hidden = YES;
    }
    
    if(message.localReceiveTime > 0){
        NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:message.localReceiveTime];
        if (![confromTimesp isThisYear]) {
            message.strTimeHeader = [[NFbaseViewController new] timestampSwitchTime:message.localReceiveTime anddFormatter:@"YYYY年MM月dd日"];
        }else{
            message.strTimeHeader = [[NFbaseViewController new] timestampSwitchTime:message.localReceiveTime anddFormatter:@"MM月dd日"];
        }
    }
    
    // 1、设置时间 头上面的时间
    messageTimeLabel.text = message.strTimeHeader;
    messageTimeLabel.frame = messageFrame.timeF;
    
    // 2、设置头像
    if (message.from == UUMessageFromMe) {
        UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTap:)];
        longTap.minimumPressDuration = 0.3;
        [mineContantBtn addGestureRecognizer:longTap];
        [mineContantBtn addTarget:self action:@selector(preventFlicker:) forControlEvents:UIControlEventAllTouchEvents];
        //        }
        if (message.type == UUMessageTypePicture || message.type == UUMessageTypeVoice){
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackgroundClick)];
            [mineContantBtn addGestureRecognizer:tap];
        }else if (message.type == UUMessageTypeText){
            //检查是否有网址 有的话点击可以传出事件
            IsExistURL = [self urlValidation:messageFrame.message.strContent?messageFrame.message.strContent:@""];
            if (IsExistURL) {//如果存在url 则
                //设置网址字体颜色
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapURLClick)];
                [mineContantBtn addGestureRecognizer:tap];
            }else if(YES){
                
            }
            
        }
        //设置时间隐藏 消息旁边的时间
        youMessageTimeLabel.hidden = YES;
        mineContantBtn.hidden = NO;
        //设置时间 消息旁边的时间
        myMessageTimeLabel.text = message.strTime;
        //设置消息旁边时间
        if (messageFrame.showTime && ![messageFrame.message.failStatus isEqualToString:@"1"]) {
            myMessageTimeLabel.hidden = NO;
            reSendConstaint.constant = 25;
        }else{
            myMessageTimeLabel.hidden = YES;
            reSendConstaint.constant = 0;
        }
        youNameLabel.hidden = YES;
        otherContantBtn.hidden = YES;
        self.youImageView.hidden = YES;
//        mineImageView.hidden = YES;
//        mineNameLabel.hidden = YES;
        mineImageView.frame = messageFrame.iconF;
        mineImageView.frame = CGRectMake(2, 2, ChatIconWH-4, ChatIconWH-4);
        [mineImageView sd_setImageWithURL:[NSURL URLWithString:message.strIcon] placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
    }else if(message.from == UUMessageFromOther){
        UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTap:)];
        longTap.minimumPressDuration = 0.3;
        [otherContantBtn addGestureRecognizer:longTap];
        [otherContantBtn addTarget:self action:@selector(preventFlicker:) forControlEvents:UIControlEventAllTouchEvents];
        //        }
        if (message.type == UUMessageTypePicture || message.type == UUMessageTypeVoice){
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackgroundClick)];
            [otherContantBtn addGestureRecognizer:tap];
        }else if (message.type == UUMessageTypeText){
            //检查是否有网址 有的话点击可以传出事件
            IsExistURL = [self urlValidation:messageFrame.message.strContent?messageFrame.message.strContent:@""];
            if (IsExistURL) {//如果存在url 则
                //设置网址字体颜色
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapURLClick)];
                [otherContantBtn addGestureRecognizer:tap];
            }
        }
        //设置时间
        myMessageTimeLabel.hidden = YES;
        youMessageTimeLabel.hidden = NO;
        youMessageTimeLabel.text = message.strTime;
//        self.otherContantTopConstaint.constant = 10;
        
        //设置消息旁边时间
        if (messageFrame.showTime) {
            youMessageTimeLabel.hidden = NO;
        }else{
            youMessageTimeLabel.hidden = YES;
        }
//        mineNameLabel.hidden = YES;
        mineContantBtn.hidden = YES;
//        mineImageView.hidden = YES;
        self.youImageView.frame = messageFrame.iconF;
        self.youImageView.frame = CGRectMake(2, 2, ChatIconWH-4, ChatIconWH-4);
//        [youImageView sd_setImageWithURL:[NSURL URLWithString:message.strIcon] placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];//为什么注释对方头像 因为有专门的地方设置头像
    }
    // 3、设置下标
    if (message.from == UUMessageFromMe) {
        youNameLabel.hidden = YES;
        mineNameLabel.text = message.userName;
        if (message.userName.length == 0) {
            mineNameLabel.text = self.meName;
        }
        mineNameLabel.frame = CGRectMake(messageFrame.nameF.origin.x - 50, messageFrame.nameF.origin.y + 3, 100, messageFrame.nameF.size.height);
        mineNameLabel.textAlignment = NSTextAlignmentRight;
    }else if(message.from == UUMessageFromOther){
        mineNameLabel.hidden = YES;
        youNameLabel.text = message.userName;
        if (message.userName.length == 0) {
            youNameLabel.text = self.otherName;
        }
        youNameLabel.frame = CGRectMake(messageFrame.nameF.origin.x - 50, messageFrame.nameF.origin.y + 3, 100, messageFrame.nameF.size.height);
        youNameLabel.textAlignment = NSTextAlignmentRight;
    }
    // 4、设置内容
    //prepare for reuse
    if (message.from == UUMessageFromMe) {
        otherContantBtn.hidden = YES;
        [mineContantBtn setTitle:@"" forState:UIControlStateNormal];
        mineContantBtn.voiceBackView.hidden = YES;
        mineContantBtn.backImageView.hidden = YES;
        //设置内容尺寸
//        mineContantBtn.frame = messageFrame.contentF;
        self.mineContantWidthConstraint.constant = messageFrame.contentF.size.width + 1;
        self.mineContantHeightConstraint.constant = messageFrame.contentF.size.height+1;
        mineContantBtn.isMyMessage = YES;
//        [mineContantBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal | UIControlStateHighlighted | UIControlStateSelected |UIControlStateDisabled];
        //[mineContantBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [mineContantBtn setTitleColor:UIColorFromRGB(0x435a8e) forState:(UIControlStateNormal)];
        
        mineContantBtn.contentEdgeInsets = UIEdgeInsetsMake(ChatContentTop, ChatContentRight - 12, ChatContentBottom, ChatContentLeft);
        
        switch (message.type) {
            case UUMessageTypeText:{
                [mineContantBtn setTitle:message.strContent forState:UIControlStateNormal];
                if (self.searchedURLArr.count > 0) {//当有网址内容时 设置attribution
                    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc]initWithString:message.strContent];
                    [attributedString addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x435a8e) range:NSMakeRange(0, message.strContent.length)];
                    for (NSString *str in self.searchedURLArr) {
                        NSArray *rangeArr = [self rangeOfSubString:str inString:message.strContent];
                        for (int i = 0; i<rangeArr.count; i++) {
                            NSRange range = [rangeArr[i] rangeValue];
                            //                        [attributedString m80_setTextColor:[UIColor redColor] range:range];
                            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(range.location, range.length)];
                        }
                    }
                    [mineContantBtn setAttributedTitle:attributedString forState:UIControlStateNormal];
                }
            }
                break;
            case UUMessageTypePicture:
            {
                mineContantBtn.backImageView.hidden = NO;
                mineContantBtn.backImageView.frame = CGRectMake(0, 0, messageFrame.contentF.size.width, messageFrame.contentF.size.height);
                //imageOrientation
//                message.picture = [message.picture rotate:UIImageOrientationRight];
//                ViewRadius(mineContantBtn.backImageView, 5);
//#warning messageFrame
                
                progressV = [[GYHSectorProgressView alloc]initWithCenter:CGPointMake(messageFrame.contentF.size.width/2, messageFrame.contentF.size.height/2)];
                progressV.progressColor = UIColorFromRGB(0xAAAAAA);
                [mineContantBtn addSubview:progressV];
//                正在加载图片
                [mineContantBtn.backImageView ShowImageWithUrlStr:message.pictureUrl placeHoldName:message.pictureUrl.length > [NFUserEntity shareInstance].HeadPicpathAppendingString.length?@"图片加载背景":@"图片加载失败" completion:^(BOOL success, UIImage *image) {
                    progressV.hidden = YES;
                } progressBlock:^(CGFloat progress) {
                    progressV.progressValue = progress;
                }];
            }
                break;
            case UUMessageTypeVoice:
            {
                mineContantBtn.voiceBackView.hidden = NO;
                if (message.strVoiceTime.length > 0) {
                    mineContantBtn.second.text = [NSString stringWithFormat:@"%@'s ",message.strVoiceTime];
                }else{
                    mineContantBtn.second.text = @"";
                }
                songData = message.voice;
//                            voiceURL = [NSString stringWithFormat:@"%@%@",RESOURCE_URL_HOST,message.strVoice];
            }
                break;
            default:
                break;
        }
    }else if(message.from == UUMessageFromOther){
        mineContantBtn.hidden = YES;
        [otherContantBtn setTitle:@"" forState:UIControlStateNormal];
        otherContantBtn.voiceBackView.hidden = YES;
        otherContantBtn.backImageView.hidden = YES;
//        otherContantBtn.frame = messageFramre.contentF;
        self.otherContantWidthConstraint.constant = messageFrame.contentF.size.width + 1;
        self.otherContantHeightConstraint.constant = messageFrame.contentF.size.height + 1;
        otherContantBtn.isMyMessage = NO;
        //[otherContantBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [otherContantBtn setTitleColor:UIColorFromRGB(0x435a8e) forState:(UIControlStateNormal)];
        //设置对方消息 内容边缘
        otherContantBtn.contentEdgeInsets = UIEdgeInsetsMake(ChatContentTop, ChatContentLeft, ChatContentBottom, ChatContentRight - 12);
        switch (message.type) {
            case UUMessageTypeText:{
                //NSString *string = [message.strContent stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//                NSString *string = [message.strContent encodeWithCoder:<#(nonnull NSCoder *)#>];
//                string = [message.strContent encodeWithCoder:<#(nonnull NSCoder *)#>];
                
                [otherContantBtn setTitle:message.strContent forState:UIControlStateNormal];
                if (self.searchedURLArr.count > 0) {//当有网址内容时 设置attribution
                    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc]initWithString:message.strContent];
                    [attributedString addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x435a8e) range:NSMakeRange(0, message.strContent.length)];
                    for (NSString *str in self.searchedURLArr) {
                        NSArray *rangeArr = [self rangeOfSubString:str inString:message.strContent];
                        for (int i = 0; i<rangeArr.count; i++) {
                            NSRange range = [rangeArr[i] rangeValue];
                            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor]range:NSMakeRange(range.location, range.length)];
                        }
                    }
                    [otherContantBtn setAttributedTitle:attributedString forState:UIControlStateNormal];
                }
            }
                break;
            case UUMessageTypePicture:
            {
                otherContantBtn.backImageView.hidden = NO;
                otherContantBtn.backImageView.hidden = NO;
                otherContantBtn.backImageView.frame = CGRectMake(0, 0, messageFrame.contentF.size.width, messageFrame.contentF.size.height);
//#warning messageFrame
                
                progressV = [[GYHSectorProgressView alloc]initWithCenter:CGPointMake(messageFrame.contentF.size.width/2, messageFrame.contentF.size.height/2)];
                progressV.progressColor = UIColorFromRGB(0xAAAAAA);
                [otherContantBtn addSubview:progressV];
                
                [otherContantBtn.backImageView ShowImageWithUrlStr:message.pictureUrl placeHoldName:message.pictureUrl.length > [NFUserEntity shareInstance].HeadPicpathAppendingString.length?@"图片加载背景":@"图片加载失败" completion:^(BOOL success, UIImage *image) {
                    progressV.hidden = YES;
                } progressBlock:^(CGFloat progress) {
                    progressV.progressValue = progress;
                }];
            }
                break;
            case UUMessageTypeVoice:
            {
                otherContantBtn.voiceBackView.hidden = NO;
                if (message.strVoiceTime.length > 0) {
                    otherContantBtn.second.text = [NSString stringWithFormat:@"%@'s ",message.strVoiceTime];
                }else{
                    otherContantBtn.second.text = @"";
                }
                songData = message.voice;
                //            voiceURL = [NSString stringWithFormat:@"%@%@",RESOURCE_URL_HOST,message.strVoice];
            }
                break;
            default:
                break;
        }
    }
    if (message.from == UUMessageFromMe) {
        //背景气泡图
        UIImage *normal;
        UIImage *normalSelected;
        if (message.from == UUMessageFromMe) {
            normal = [UIImage imageNamed:@"chatMyMessage_Normal"];
            normal = [UIImage SDResizeWithIma:normal];
            normalSelected = [UIImage imageNamed:@"chatMyMessage_Highlighted"];
            normalSelected = [UIImage SDResizeWithIma:normalSelected];
            //(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right)
//            normal = [normal resizableImageWithCapInsets:UIEdgeInsetsMake(35, 10, 10, 22)];
//            normal = [normal resizableImageWithCapInsets:UIEdgeInsetsMake(35, 10, 10, 22) resizingMode:UIImageResizingModeStretch];
        }
        else{
            normal = [UIImage imageNamed:@"chatSickMessage_Normal"];
            normal = [UIImage SDResizeWithIma:normal];
            normalSelected = [UIImage imageNamed:@"chatSickMessage_Highlighted"];
            normalSelected = [UIImage SDResizeWithIma:normalSelected];
//            normal = [UIImage imageNamed:@"chatfrom_bg_normal"];
//            normal = [normal resizableImageWithCapInsets:UIEdgeInsetsMake(35, 22, 10, 10)];
        }
        if (message.type != UUMessageTypePicture) {
            [mineContantBtn setBackgroundImage:normal forState:UIControlStateNormal];
            [mineContantBtn setBackgroundImage:normalSelected forState:UIControlStateHighlighted];
        }
    }else if(message.from == UUMessageFromOther){
        //背景气泡图
        UIImage *normal;
        UIImage *normalSelected;
        if (message.from == UUMessageFromMe) {
            normal = [UIImage imageNamed:@"chatMyMessage_Normal"];
            normal = [UIImage SDResizeWithIma:normal];
            normalSelected = [UIImage imageNamed:@"chatMyMessage_Highlighted"];
            normalSelected = [UIImage SDResizeWithIma:normalSelected];
//            normal = [UIImage imageNamed:@"chatto_bg_normal"];
//            normal = [normal resizableImageWithCapInsets:UIEdgeInsetsMake(35, 10, 10, 22)];
        }
        else{
            normal = [UIImage imageNamed:@"chatSickMessage_Normal"];
            normal = [UIImage SDResizeWithIma:normal];
            normalSelected = [UIImage imageNamed:@"chatSickMessage_Highlighted"];
            normalSelected = [UIImage SDResizeWithIma:normalSelected];
//            normal = [UIImage imageNamed:@"chatfrom_bg_normal"];
//            normal = [normal resizableImageWithCapInsets:UIEdgeInsetsMake(35, 22, 10, 10)];
        }
        if (message.type != UUMessageTypePicture) {
            [otherContantBtn setBackgroundImage:normal forState:UIControlStateNormal];
            [otherContantBtn setBackgroundImage:normalSelected forState:UIControlStateHighlighted];
        }
    }
}


#pragma mark - 要紧的显示
-(void)setMessageFrameUrgent:(UUMessageFrame *)messageFrameUrgent{
    UUMessage *message = messageFrameUrgent.message;
    messageTimeLabel.hidden = YES;
//    youMessageTimeLabel.hidden = YES;
//    myMessageTimeLabel.hidden = YES;
    //不显示时间 所有相对于上面的约束为10
    self.otherContantTopConstaint.constant = 10;
    self.mineContantTopConstaint.constant = 10;
    self.otherIconImageTopConstaint.constant = 10;
    //设置时间
    if (message.from == UUMessageFromMe) {
        self.youImageView.hidden = YES;
        //设置时间隐藏 消息旁边的时间
        youMessageTimeLabel.hidden = YES;
        //设置时间 消息旁边的时间
        myMessageTimeLabel.text = message.strTime;
        //设置消息旁边时间
        if (messageFrameUrgent.showTime && ![messageFrameUrgent.message.failStatus isEqualToString:@"1"]) {
            myMessageTimeLabel.hidden = NO;
            reSendConstaint.constant = 25;
        }else{
            myMessageTimeLabel.hidden = YES;
            reSendConstaint.constant = 0;
        }
    }else if (message.from == UUMessageFromOther){
        //设置时间
        myMessageTimeLabel.hidden = YES;
        youMessageTimeLabel.text = message.strTime;
        //设置消息旁边时间
        if (messageFrameUrgent.showTime) {
            youMessageTimeLabel.hidden = NO;
        }else{
            youMessageTimeLabel.hidden = YES;
        }
    }
    //设置名字
    if (message.from == UUMessageFromMe) {
        youNameLabel.hidden = YES;
        mineNameLabel.text = message.userName;
        if (message.userName.length == 0) {
            mineNameLabel.text = self.meName;
        }
        mineNameLabel.frame = CGRectMake(messageFrameUrgent.nameF.origin.x - 50, messageFrameUrgent.nameF.origin.y + 3, 100, messageFrameUrgent.nameF.size.height);
        mineNameLabel.textAlignment = NSTextAlignmentRight;
    }else if(message.from == UUMessageFromOther){
        mineNameLabel.hidden = YES;
        youNameLabel.text = message.userName;
        if (message.userName.length == 0) {
            youNameLabel.text = self.otherName;
        }
        youNameLabel.frame = CGRectMake(messageFrameUrgent.nameF.origin.x - 50, messageFrameUrgent.nameF.origin.y + 3, 100, messageFrameUrgent.nameF.size.height);
        youNameLabel.textAlignment = NSTextAlignmentRight;
    }
    
    // 4、设置内容
    //prepare for reuse
    if (message.from == UUMessageFromMe) {
        otherContantBtn.hidden = YES;
        [mineContantBtn setTitle:@"" forState:UIControlStateNormal];
        mineContantBtn.voiceBackView.hidden = YES;
        mineContantBtn.backImageView.hidden = YES;
        //设置内容尺寸
        //        mineContantBtn.frame = messageFrame.contentF;
        self.mineContantWidthConstraint.constant = messageFrameUrgent.contentF.size.width + 1;
        self.mineContantHeightConstraint.constant = messageFrameUrgent.contentF.size.height+1;
        mineContantBtn.isMyMessage = YES;
        [mineContantBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        mineContantBtn.contentEdgeInsets = UIEdgeInsetsMake(ChatContentTop, ChatContentRight - 12, ChatContentBottom, ChatContentLeft);
        switch (message.type) {
            case UUMessageTypeText:{
                [mineContantBtn setTitle:message.strContent forState:UIControlStateNormal];
                if (self.searchedURLArr.count > 0) {//当有网址内容时 设置attribution
                    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc]initWithString:message.strContent];
                    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, message.strContent.length)];
                    for (NSString *str in self.searchedURLArr) {
                        NSArray *rangeArr = [self rangeOfSubString:str inString:message.strContent];
                        for (int i = 0; i<rangeArr.count; i++) {
                            NSRange range = [rangeArr[i] rangeValue];
                            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor]range:NSMakeRange(range.location, range.length)];
                        }
                    }
                    [mineContantBtn setAttributedTitle:attributedString forState:UIControlStateNormal];
                }
            }
                break;
            case UUMessageTypePicture:
            {
                mineContantBtn.backImageView.hidden = NO;
                mineContantBtn.backImageView.frame = CGRectMake(0, 0, messageFrameUrgent.contentF.size.width, messageFrameUrgent.contentF.size.height);
                progressV = [[GYHSectorProgressView alloc]initWithCenter:CGPointMake(messageFrameUrgent.contentF.size.width/2, messageFrameUrgent.contentF.size.height/2)];
                progressV.progressColor = UIColorFromRGB(0xAAAAAA);
                [mineContantBtn addSubview:progressV];
                //正在加载图片
                [mineContantBtn.backImageView ShowImageWithUrlStr:message.pictureUrl placeHoldName:message.pictureUrl.length > [NFUserEntity shareInstance].HeadPicpathAppendingString.length?@"图片加载背景":@"图片加载失败" completion:^(BOOL success, UIImage *image) {
                    progressV.hidden = YES;
                } progressBlock:^(CGFloat progress) {
                    progressV.progressValue = progress;
                }];
            }
                break;
            case UUMessageTypeVoice:
            {
                mineContantBtn.voiceBackView.hidden = NO;
                if (message.strVoiceTime.length > 0) {
                    mineContantBtn.second.text = [NSString stringWithFormat:@"%@'s ",message.strVoiceTime];
                }else{
                    mineContantBtn.second.text = @"";
                }
            }
                break;
            default:
                break;
        }
    }else if(message.from == UUMessageFromOther){
        mineContantBtn.hidden = YES;
        [otherContantBtn setTitle:@"" forState:UIControlStateNormal];
        otherContantBtn.voiceBackView.hidden = YES;
        otherContantBtn.backImageView.hidden = YES;
        self.otherContantWidthConstraint.constant = messageFrameUrgent.contentF.size.width + 1;
        self.otherContantHeightConstraint.constant = messageFrameUrgent.contentF.size.height + 1;
        otherContantBtn.isMyMessage = NO;
        [otherContantBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //设置对方消息 内容边缘
        otherContantBtn.contentEdgeInsets = UIEdgeInsetsMake(ChatContentTop, ChatContentLeft, ChatContentBottom, ChatContentRight - 12);
        switch (message.type) {
            case UUMessageTypeText:{
                [otherContantBtn setTitle:message.strContent forState:UIControlStateNormal];
                if (self.searchedURLArr.count > 0) {//当有网址内容时 设置attribution
                    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc]initWithString:message.strContent];
                    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, message.strContent.length)];
                    for (NSString *str in self.searchedURLArr) {
                        NSArray *rangeArr = [self rangeOfSubString:str inString:message.strContent];
                        for (int i = 0; i<rangeArr.count; i++) {
                            NSRange range = [rangeArr[i] rangeValue];
                            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor]range:NSMakeRange(range.location, range.length)];
                        }
                    }
                    [otherContantBtn setAttributedTitle:attributedString forState:UIControlStateNormal];
                }
            }
                break;
            case UUMessageTypePicture:
            {
                otherContantBtn.backImageView.hidden = NO;
                otherContantBtn.backImageView.frame = CGRectMake(0, 0, messageFrameUrgent.contentF.size.width, messageFrameUrgent.contentF.size.height);
                //#warning messageFrame
                progressV = [[GYHSectorProgressView alloc]initWithCenter:CGPointMake(messageFrameUrgent.contentF.size.width/2, messageFrameUrgent.contentF.size.height/2)];
                progressV.progressColor = UIColorFromRGB(0xAAAAAA);
                [otherContantBtn addSubview:progressV];
                [otherContantBtn.backImageView ShowImageWithUrlStr:message.pictureUrl placeHoldName:message.pictureUrl.length > [NFUserEntity shareInstance].HeadPicpathAppendingString.length?@"图片加载背景":@"图片加载失败" completion:^(BOOL success, UIImage *image) {
                    progressV.hidden = YES;
                } progressBlock:^(CGFloat progress) {
                    progressV.progressValue = progress;
                }];
                
            }
                break;
            case UUMessageTypeVoice:
            {
                otherContantBtn.voiceBackView.hidden = NO;
                if (message.strVoiceTime.length > 0) {
                    otherContantBtn.second.text = [NSString stringWithFormat:@"%@'s ",message.strVoiceTime];
                }else{
                    otherContantBtn.second.text = @"";
                }
            }
                break;
            default:
                break;
        }
    }
    if (message.from == UUMessageFromMe) {
        //背景气泡图
        UIImage *normal;
        UIImage *normalSelected;
        if (message.from == UUMessageFromMe) {
            normal = [UIImage imageNamed:@"chatMyMessage_Normal"];
            normal = [UIImage SDResizeWithIma:normal];
            normalSelected = [UIImage imageNamed:@"chatMyMessage_Highlighted"];
            normalSelected = [UIImage SDResizeWithIma:normalSelected];
        }
        else{
            normal = [UIImage imageNamed:@"chatSickMessage_Normal"];
            normal = [UIImage SDResizeWithIma:normal];
            normalSelected = [UIImage imageNamed:@"chatSickMessage_Highlighted"];
            normalSelected = [UIImage SDResizeWithIma:normalSelected];
        }
        if (message.type != UUMessageTypePicture) {
            [mineContantBtn setBackgroundImage:normal forState:UIControlStateNormal];
            [mineContantBtn setBackgroundImage:normalSelected forState:UIControlStateHighlighted];
        }
    }else if(message.from == UUMessageFromOther){
        //背景气泡图
        UIImage *normal;
        UIImage *normalSelected;
        if (message.from == UUMessageFromMe) {
            normal = [UIImage imageNamed:@"chatMyMessage_Normal"];
            normal = [UIImage SDResizeWithIma:normal];
            normalSelected = [UIImage imageNamed:@"chatMyMessage_Highlighted"];
            normalSelected = [UIImage SDResizeWithIma:normalSelected];
        }
        else{
            normal = [UIImage imageNamed:@"chatSickMessage_Normal"];
            normal = [UIImage SDResizeWithIma:normal];
            normalSelected = [UIImage imageNamed:@"chatSickMessage_Highlighted"];
            normalSelected = [UIImage SDResizeWithIma:normalSelected];
        }
        if (message.type != UUMessageTypePicture) {
            [otherContantBtn setBackgroundImage:normal forState:UIControlStateNormal];
            [otherContantBtn setBackgroundImage:normalSelected forState:UIControlStateHighlighted];
        }
    }
}

#pragma mark - 提取字符串中的某字符串的range
- (NSArray*)rangeOfSubString:(NSString*)subStr inString:(NSString*)string {
    NSMutableArray *rangeArray = [NSMutableArray array];
    NSString*string1 = [string stringByAppendingString:subStr];
    NSString *temp;
    for(int i =0; i < string.length; i ++) {
        temp = [string1 substringWithRange:NSMakeRange(i, subStr.length)];
        if ([temp isEqualToString:subStr]) {
            NSRange range = {(NSUInteger)i,subStr.length};
            [rangeArray addObject: [NSValue valueWithRange:range]];
        }
    }
    return rangeArray;
}

#pragma mark - 查看聊天记录所有图片
-(void)lookSingleCachePictureArrWithFriendId:(NSString *)friendId IsSelf:(BOOL)ret{
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __weak typeof(self)weakSelf=self;
    __block NSArray *imageChatEntityArr = [NSArray new];
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        imageChatEntityArr = [strongSelf ->jqFmdb jq_lookupTable:friendId dicOrModel:[MessageChatEntity class] whereFormat:@"where type = '%@'",@"1"];
    }];
    
    NSMutableArray *urlArr = [NSMutableArray new];
    NSInteger selectedIndex = 0;
    BOOL IsSearched = NO;
    for (MessageChatEntity *picEntity in imageChatEntityArr) {
        if (picEntity.pictureUrl.length > [NFUserEntity shareInstance].HeadPicpathAppendingString.length && ![picEntity.yuehouYinCang isEqualToString:@"1"]) {
            [urlArr addObject:picEntity.pictureUrl];
            if (!IsSearched && [picEntity.chatId isEqualToString:self.messageFrame.message.chatId]) {
                selectedIndex = urlArr.count -1;
                IsSearched = YES;
            }
        }
    }
    GQWeakify(self);
    //链式调用
    [GQImageViewer sharedInstance]
    .configureChain(^(GQImageViewrConfigure *configure) {
        [configure configureWithImageViewBgColor:[UIColor blackColor]
                                 textViewBgColor:nil
                                       textColor:[UIColor whiteColor]
                                        textFont:[UIFont systemFontOfSize:12]
                                   maxTextHeight:100
                                  textEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)
                                       scaleType:GQImageViewerScaleTypeEqualWidth
                                 launchDirection:GQLaunchDirectionFromRect];
        //        [configure setRequestClassName:@"GQImageViewrBaseURLRequest"];
        [configure setNeedPanGesture:NO];//设置是否需要滑动消失手势
        configure.usePageControl = NO;
        if (ret) {
            configure.launchFromView = mineContantBtn;
        }else{
            configure.launchFromView = otherContantBtn;
        }
        configure.textViewBgColor = [UIColor clearColor];//底部view颜色【显示pagecontrol或pageLabel的】
        [configure setNeedTapAutoHiddenTopBottomView:YES];//设置是否需要自动隐藏顶部和底部视图
    })
    //    .dataSouceArrayChain(imageArray,textArray)//如果仅需要图片浏览就只需要传图片即可，无需传文字数组
    .dataSouceArrayChain(urlArr,nil)//如果仅需要图片浏览就只需要传图片即可，无需传文字数组
    //    .selectIndexChain(index)//设置选中的索引
    .topViewConfigureChain(^(UIView *configureView) {
        //        configureView.height = 80;
        //        configureView.backgroundColor = [UIColor cyanColor];
        //        [weak_self topViewAddLabelText:@"手动管理生命周期" withTopView:configureView];
        //        UIButton *button = [weak_self creatButtonWithTitle:@"点击消失" withSEL:@selector(dissMissImageViewer:)];
        //        button.frame = CGRectMake(10, (configureView.height - 30) / 2, 100, 30);
        //        [configureView addSubview:button];
    })
    .bottomViewConfigureChain(^(UIView *configureView) {
        //        configureView.height = 50;
        //        configureView.backgroundColor = [UIColor yellowColor];
    })
    .achieveSelectIndexChain(^(NSInteger selectIndex){//获取当前选中的图片索引
        NSLog(@"滑动到某一张事件");
    })
    .longTapIndexChain(^(UIImage *image , NSInteger selectIndex){//长按手势回调
        NSLog(@"长按事件");
        LWWeChatActionSheet *sheet = [[LWWeChatActionSheet alloc] initWithWeChatActionSheetCancelButtonTitle:@"取消" title:nil otherButtonTitles:[NSArray arrayWithObjects:@"保存图片", nil] btnClickBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                NSLog(@"保存图片");
                UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
            }
        }];
        [sheet show];
    })
    .dissMissChain(^(){
        NSLog(@"dissMiss");
    })
    .singleTapChain(^(NSInteger selectIndex){
        NSLog(@"单击事件");
        [[GQImageViewer sharedInstance] dissMissWithAnimation:YES];
    })
    .showInViewChain([KeepAppBox viewController:self].view.window,YES);//显示GQImageViewer到指定view上
    //setSelectIndex
    [[GQImageViewer sharedInstance] setSelectIndex:selectedIndex];//设置选中的索引
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (!error) {
        [SVProgressHUD showSuccessWithStatus:@"已保存到系统相册"];
    }else{
//        NSDictionary *errorDict = error.userInfo;
//        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@\n%@",[errorDict objectForKey:@"NSLocalizedRecoverySuggestion"],[errorDict objectForKey:@"NSLocalizedDescription"]]];
        
        int author = [ALAssetsLibrary authorizationStatus];
        NSLog(@"author type:%d",author);
        if(author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied) {
            // The user has explicitly denied permission for media capture.
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"无法使用相册" message:@"请在iPhone的\"设置-隐私-照片\"中允许访问照片。" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionCannel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            UIAlertAction *actionSure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alertController addAction:actionSure];
            [alertController addAction:actionCannel];
            [[KeepAppBox topViewController] presentViewController:alertController animated:YES completion:nil];
        }
    }
    NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
    
}




/**
 * 网址正则验证
 *
 *  @param string 要验证的字符串
 *
 *  @return 返回值类型为BOOL
 */
- (BOOL)urlValidation:(NSString *)string {
    NSError *error;
    // 正则表达式
    NSString *regulaStr =@"^(?=^.{3,255}$)(http(s)?:\/\/)?(www\.)?[a-zA-Z0-9][-a-zA-Z0-9]{0,62}(\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+(:\d+)*(\/\w+\.\w+)*([\?&]\w+=\w*)*$";
//    regulaStr =@"\\bhttps?://[a-zA-Z0-9\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?";
    regulaStr =@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    
//    regulaStr = @"((([A-Za-z]{3,9}:(?:\\/\\/)?)(?:[\\-;:&=\\+\\$,\\w]+@)?[A-Za-z0-9\\.\\-]+|(?:www\\.|[\\-;:&=\\+\\$,\\w]+@)[A-Za-z0-9\\.\\-]+)((:[0-9]+)?)((?:\\/[\\+~%\\/\\.\\w\\-]*)?\\??(?:[\\-\\+=&;%@\\.\\w]*)#?(?:[\\.\\!\\/\\\\\\w]*))?)";
    
//    regulaStr = @"";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    
    //rangeOfSubString 找出消息中的所有url 不是第一个s
//    [self rangeOfSubString:@"" inString:@""];
    
    for (NSTextCheckingResult *match in arrayOfAllMatches){
        NSString *substringForMatch = [string substringWithRange:match.range];
        self.urlStr = substringForMatch;//把网址传出去
        [self.searchedURLArr addObject:substringForMatch];//将网址add到数组中去【有几个网址add 几个】
    }
    if (self.searchedURLArr.count > 0) {
        return YES;
    }
    return NO;
}

-(void)myCopy:(UIButton *)sender{
    NSLog(@"");
}
-(void)myForward:(UIButton *)sender{
}
-(void)myDelete:(UIButton *)sender{
}
-(void)myWithDrow:(UIButton *)sender{
}
-(void)moreEdit:(UIButton *)sender{
}
-(void)savePic:(UIButton *)sender{
}

-(NFMyManage *)myManage{
    if (!_myManage) {
        _myManage = [[NFMyManage alloc] init];
    }
    return _myManage;
}

//urlArr
-(NSMutableArray *)searchedURLArr{
    if (!_searchedURLArr) {
        _searchedURLArr = [[NSMutableArray alloc] initWithCapacity:2];
    }
    return _searchedURLArr;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
//    NSArray *subviews = [self subviews];
//    for (id obj in subviews) {
//        if ([obj isKindOfClass:[UIControl class]]) {
//            for (id subview in [obj subviews]) {
//                if ([subview isKindOfClass:[UIImageView class]]) {
//                    UIImageView *imageV = subview;
//                    //                    imageV.backgroundColor = [UIColor yellowColor];
//                    imageV.tintColor = [UIColor clearColor];
//                    //                    cell.selected = !cell.selected;
//                    //                    if (cell.isSelected) {
//                    if (self.messageFrame.message.IsSelected) {
//                        imageV.image=[UIImage imageNamed:@"CellButtonSelected"];
//                    }else{
//                        imageV.image=[UIImage imageNamed:@"CellButton"];
//
//                    }
//                    break;
//                }
//            }
//        }
//    }
    
    
//    NSLog(@"");
    // Configure the view for the selected state
}

@end
