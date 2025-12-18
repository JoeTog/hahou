//
//  GroupMessageTableViewCell.m
//  nationalFitness
//
//  Created by Joe on 2017/9/2.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "GroupMessageTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "UUImageAvatarBrowser.h"


@implementation GroupMessageTableViewCell{
    
    
    __weak IBOutlet UILabel *messageTimeLabel;
    
    __weak IBOutlet UUMessageContentButton *otherContantBtn;
    
    //对方名字
    __weak IBOutlet UILabel *youNameLabel;
    
    __weak IBOutlet UUMessageContentButton *mineContantBtn;
    
    __weak IBOutlet UILabel *youMessageTimeLabel;
    
    __weak IBOutlet UILabel *myMessageTimeLabel;
    
    //重发消息按钮 距离消息约束 默认为25【有时间的情况下】
    __weak IBOutlet NSLayoutConstraint *reSendConstaint;
    
    //wuyong
    UIImageView *mineImageView;
    UILabel *mineNameLabel;
    
    UUAVAudioPlayer *audio;
    AVAudioPlayer *player;
    NSString *voiceURL;
    NSData *songData;
    
    UIView *headImageBackView;
    //是否正在编辑菜单【拷贝、转发等】
    BOOL IsEditMenu;
    JQFMDB *jqFmdb;
    GYHSectorProgressView *progressV;
    //编辑名字后 回来还是隐藏navigation和tabbar
    BOOL isFromEditName;
    
    //秒 倒计时五秒显示未发送
    int secTime_;
    
    SocketRequest *socketRequest;
    
    
    
}



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    otherContantBtn.titleLabel.numberOfLines = 0;
    otherContantBtn.titleLabel.font = ChatContentFont;
    otherContantBtn.backgroundColor = [UIColor clearColor];
    
    
    
    mineContantBtn.titleLabel.numberOfLines = 0;
    mineContantBtn.titleLabel.font = ChatContentFont;
    mineContantBtn.backgroundColor = [UIColor clearColor];
    
    //youMessageTimeLabel.textColor = UIColorFromRGB(0x435a8e);
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(UUAVAudioPlayerDidFinishPlay) name:@"VoicePlayHasInterrupt" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(menuHiden) name:UIMenuControllerWillHideMenuNotification object:nil];
    
    
    
}

-(void)clickControlAction{
    
    [self.groupViewController performSelector:@selector(tableView:didSelectRowAtIndexPath:)];
    
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

-(void)returnLong:(ReturnheadViewLongPressBlock)block{
    if (self.returnLongBlock != block) {
        self.returnLongBlock = block;
    }
}

-(void)returnRegisterResponder:(ReturnRegisterResponderBlock)block{
    if (self.returnRegisterResponderBlock != block) {
        self.returnRegisterResponderBlock = block;
    }
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
            //        [audio playSongWithUrl:voiceURL];
            [audio playSongWithData:songData];
        }else{
            if (mineContantBtn.backImageView) {
//                [UUImageAvatarBrowser showImage:mineContantBtn.backImageView];
                //查看聊天记录所有图片
                [self lookSingleCachePictureArrWithFriendId:self.GroupId IsSelf:YES];
                //判断点击的图片是否为后三个数据 是就让收起键盘 如果不是后三个数据 那么看到之前的数据 键盘肯定已经为收起状态
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
            //        [audio playSongWithUrl:voiceURL];
            [audio playSongWithData:songData];
        }else{
            if (otherContantBtn.backImageView) {
//                [UUImageAvatarBrowser showImage:otherContantBtn.backImageView];
                [self lookSingleCachePictureArrWithFriendId:self.GroupId IsSelf:NO];
                //判断点击的图片是否为后三个数据 是就让收起键盘 如果不是后三个数据 那么看到之前的数据 键盘肯定已经为收起状态
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
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:jumpURL] options:@{} completionHandler:nil];
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

#pragma mark - 长按 对方头像手势
- (void)longPressClick:(UILongPressGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            if (self.returnLongBlock) {
                self.returnLongBlock();
            }
            break;
        case UIGestureRecognizerStateChanged:
            break;
        case UIGestureRecognizerStateEnded:
            break;
        default:
            break;
    }
}

#pragma mark - 长按 文字 手势
- (void)longTap:(UILongPressGestureRecognizer *)recognizer {
    if (!IsEditMenu) {
        IsEditMenu = YES;
    }else{
        return;
    }
    UUMessage *message = _messageFrame.message;
    //play audio
    if (self.messageFrame.message.type == UUMessageTypeVoice && self.messageFrame.message.type == UUMessageTypePicture) {
        
        audio = [UUAVAudioPlayer sharedInstance];
        audio.delegate = self;
        //        [audio playSongWithUrl:voiceURL];
        [audio playSongWithData:songData];
    }
    //show the picture
    else if (self.messageFrame.message.type == UUMessageTypePicture && self.messageFrame.message.type == UUMessageTypeVoice)
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
    else if (self.messageFrame.message.type == UUMessageTypeText || self.messageFrame.message.type == UUMessageTypePicture|| self.messageFrame.message.type == UUMessageTypeVoice)
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
            BOOL ret = [self IsAllowDraw:self.messageFrame.message.localReceiveTime];
            if (ret) {
                if (_messageFrame.message.type == UUMessageTypeVoice) {
//                    [menu setMenuItems:@[item3,item4,item5]];
                    [menu setMenuItems:@[item3,item5]];
                }else if (_messageFrame.message.type == UUMessageTypePicture){
                    [menu setMenuItems:@[item2,item3,item4,item5,item6]];
//                    [menu setMenuItems:@[item2,item3,item5]];
                }else if (_messageFrame.message.type == UUMessageTypeRed){
                    [menu setMenuItems:@[item3,item5]];
                }else{
                    [menu setMenuItems:@[item1,item2,item3,item4,item5]];
//                    [menu setMenuItems:@[item1,item2,item3,item5]];
                }
            }else{
                if (_messageFrame.message.type == UUMessageTypeVoice) {
                    [menu setMenuItems:@[item3,item5]];
                }else if (_messageFrame.message.type == UUMessageTypePicture){
//                    [menu setMenuItems:@[item2,item3,item4,item5]];
                    [menu setMenuItems:@[item2,item3,item5,item6]];
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
            [mineContantBtn returnDeleteBlock:^{
                //删除
                
                [self showBottomView];
            }];
            [mineContantBtn returnCopyBlock:^{
                //拷贝
                
            }];
            [mineContantBtn returnmyWithDrowBlock:^{
                //撤回
                [self showBottomViewDrow];
            }];
            [mineContantBtn returnMoreEditBlock:^{
                //更多
                [self.groupTableV setEditing:YES animated:YES];
                //隐藏右侧按钮 self.singleViewController.navigationItem.rightBarButtonItem.customView.hidden =YES;
                //singleViewController
//                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//                button.frame = CGRectMake(0, 0, 40, 30);
//                button.titleLabel.font = [UIFont systemFontOfSize:15];
//                [button setTitle:@"取消" forState:UIControlStateNormal];
//                [button setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
//                [button addTarget:self action:@selector(cancelEditClick) forControlEvents:UIControlEventTouchUpInside];
//                UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView: button]; self.singleViewController.navigationItem.leftBarButtonItem = item;
//
//                self.singleViewController.navigationItem.leftBarButtonItem = item;
//                //底部展示功能按钮
//                if ([self.singleViewController isKindOfClass:[GroupChatViewController class]]) {
//                    GroupChatViewController *singleTableV = (GroupChatViewController *)self.singleViewController;
//                    singleTableV.IFView_.hidden = YES;
//                }
                
                
                if (self.returnEditBlock) {
                    self.returnEditBlock();
                }
            }];
        }else if(message.from == UUMessageFromOther){
            [otherContantBtn becomeFirstResponder];
            UIMenuController *menu = [UIMenuController sharedMenuController];
            UIMenuItem * item1 = [[UIMenuItem alloc]initWithTitle:@"拷贝" action:@selector(myCopy:)];
            UIMenuItem * item2 = [[UIMenuItem alloc]initWithTitle:@"转发" action:@selector(myForward:)];
            UIMenuItem * item3 = [[UIMenuItem alloc]initWithTitle:@"删除" action:@selector(myDelete:)];
//            UIMenuItem * item4 = [[UIMenuItem alloc]initWithTitle:@"撤回" action:@selector(myWithDrow:)];//他人消息 没有权利撤回
            UIMenuItem * item5 = [[UIMenuItem alloc]initWithTitle:@"更多" action:@selector(moreEdit:)];
            UIMenuItem * item6 = [[UIMenuItem alloc]initWithTitle:@"收藏" action:@selector(savePic:)];
//            [menu setMenuItems:@[item1,item2,item3,item4,item5]];
            if (_messageFrame.message.type == UUMessageTypeVoice) {
                [menu setMenuItems:@[item3,item5]];
            }else if(_messageFrame.message.type == UUMessageTypePicture){
                [menu setMenuItems:@[item2,item3,item5,item6]];
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
            //收藏
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
                //撤回 【对方消息不可自己手动撤回】
            }];
            //returnMoreEditBlock
            [otherContantBtn returnMoreEditBlock:^{
                //更多
                [self.groupTableV setEditing:YES animated:YES];
                //隐藏右侧按钮 self.singleViewController.navigationItem.rightBarButtonItem.customView.hidden =YES;
                //singleViewController
//                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//                button.frame = CGRectMake(0, 0, 40, 30);
//                button.titleLabel.font = [UIFont systemFontOfSize:15];
//                [button setTitle:@"取消" forState:UIControlStateNormal];
//                [button setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
//                [button addTarget:self action:@selector(cancelEditClick) forControlEvents:UIControlEventTouchUpInside];
//                UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView: button]; self.singleViewController.navigationItem.leftBarButtonItem = item;
//                
//                self.singleViewController.navigationItem.leftBarButtonItem = item;
//                //底部展示功能按钮
//                if ([self.singleViewController isKindOfClass:[GroupChatViewController class]]) {
//                    GroupChatViewController *singleTableV = (GroupChatViewController *)self.singleViewController;
//                    singleTableV.IFView_.hidden = YES;
//                }
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
                    }
                    else
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
    //设置tableview 编辑状态
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

//当发第一条消息没问题，当发第二条消息 会刷新第一个cell 这时候会出现问题 近了判断 导致第一条消息为断线，看看发完第二条消息后 第一条消息的failstatus呢
-(void)setMessageFrame:(UUMessageFrame *)messageFrame{
    BOOL IsExistURL = NO;//是否含有网址字符
    if (messageFrame.message.chatId.length == 0 && messageFrame.message.from == UUMessageFromMe && messageFrame.message.failStatus.length == 0 && messageFrame) {
        //如果该条消息没有服务器messageid 那么倒计时五秒 五秒后还没有则显示红色未发送
        __weak typeof(self)weakSelf=self;
        //当为第一次显示的时候 计时失败
//        if ( [messageFrame.message.failStatus isEqualToString:@"1"]) {
            self.timer = [HCDTimer repeatingTimerWithTimeInterval:1 block:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                strongSelf ->secTime_ ++;
                if (strongSelf ->secTime_ == outTime && messageFrame.message.chatId.length == 0 ) {
                    strongSelf.reSendBtn.hidden = NO;
                    messageFrame.message.failStatus = @"1";
                    strongSelf ->jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
                    __block NSArray *existArr = [NSArray new];
                    [strongSelf ->jqFmdb jq_inDatabase:^{
                        __strong typeof(weakSelf)strongSelf=weakSelf;
                        existArr = [strongSelf ->jqFmdb jq_lookupTable:strongSelf.groupChatTableName dicOrModel:[MessageChatEntity class] whereFormat:@"where appMsgId = '%@'",messageFrame.message.appMsgId];
                    }];
                    if (existArr.count == 1) {
                        MessageChatEntity *changeEntity = [existArr lastObject];
                        changeEntity.chatId = @"";
                        changeEntity.failStatus = @"1";
                        [strongSelf.myManage changeFMDBData:changeEntity KeyWordKey:@"appMsgId" KeyWordValue:messageFrame.message.appMsgId FMDBID:@"tongxun.sqlite" TableName:self.groupChatTableName];
                    }
                }else if (strongSelf ->secTime_>outTime){
                    [strongSelf.timer invalidate];
                }
            }];
//        }
    }else{
        //否则 停止计时器
        if (self.timer) {
            [self.timer invalidate];
        }
//        self.failSendImageV.hidden = YES;
    }
    if ([messageFrame.message.failStatus isEqualToString:@"1"]) {
        self.reSendBtn.hidden = NO;
    }
//    if (messageFrame.message.type == UUMessageTypePicture) {
//        self.reSendBtn.hidden = NO;
//    }
    
//        __weak typeof(self)weakSelf=self;
//        if (messageFrame.message.chatId.length == 0) {
//            self.timer = [HCDTimer repeatingTimerWithTimeInterval:1 block:^{
//                secTime_ ++;
//                if (secTime_ == 5 && messageFrame.message.chatId.length == 0 ) {
//                    weakSelf.failSendImageV.hidden = NO;
//                }else if (secTime_>5){
//                    [weakSelf.timer invalidate];
//                }
//            }];
//        }
    
    
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
        self.otherContanttTopConstaint.constant = 27;
        self.mineContantTopConstaint.constant = 10;
        self.otherIconImageTopConstaint.constant = 10;
        messageTimeLabel.hidden = YES;
    }
    _messageFrame = messageFrame;
    UUMessage *message = messageFrame.message;
    
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
    
    //崩溃
    if(messageFrame.timeF.size.width>0){
        messageTimeLabel.frame = messageFrame.timeF;
    }
    // 2、设置头像
    if (message.from == UUMessageFromMe) {
        //设置文字长按手势
//        if (message.type == UUMessageTypeText || message.type == UUMessageTypePicture) {
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
            }
        }
        
        //设置时间隐藏 消息旁边的时间
        youMessageTimeLabel.hidden = YES;
        mineContantBtn.hidden = NO;
        //设置时间 消息旁边的时间
        myMessageTimeLabel.text = message.strTime;
        //设置消息旁边时间
        if (messageFrame.showTime  && ![messageFrame.message.failStatus isEqualToString:@"1"]) {
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
        //设置文字长按手势
//        if (message.type == UUMessageTypeText || message.type == UUMessageTypePicture) {
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
//        ViewRadius(youImageView, youImageView.frame.size.width/2);
//        message.strIcon = @"http://116.62.6.189:7999/web_file/Public/uploads/2017-09-13/59b8c062d01e5.png";
        [self.youImageView sd_setImageWithURL:[NSURL URLWithString:message.strIcon] placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressClick:)];
        longPress.minimumPressDuration= 0.5;
        [self.youImageView addGestureRecognizer:longPress];
        
        
        
    }
    // 3、设置下标
    if (message.from == UUMessageFromMe) {
        youNameLabel.hidden = YES;
        mineNameLabel.hidden = NO;
        mineNameLabel.text = message.userName;
        if (message.userName.length == 0) {
            mineNameLabel.text = self.meName;
        }
        mineNameLabel.frame = CGRectMake(messageFrame.nameF.origin.x - 50, messageFrame.nameF.origin.y + 3, 100, messageFrame.nameF.size.height);
        mineNameLabel.textAlignment = NSTextAlignmentRight;
        
    }else if(message.from == UUMessageFromOther){
        mineNameLabel.hidden = YES;
        youNameLabel.hidden = NO;
        
        if (message.nickName.length > 0) {
            youNameLabel.text = message.nickName;
        }else{
            youNameLabel.text = message.userName;
            if (message.userName.length == 0) {
                youNameLabel.text = self.otherName;
            }
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
        self.mineContanttWidthConstraint.constant = messageFrame.contentF.size.width + 1;
        self.mineContanttHeightConstraint.constant = messageFrame.contentF.size.height+1;
        mineContantBtn.isMyMessage = YES;
        //[mineContantBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [mineContantBtn setTitleColor:UIColorFromRGB(0x435a8e) forState:(UIControlStateNormal)];
        
        mineContantBtn.contentEdgeInsets = UIEdgeInsetsMake(ChatContentTop, ChatContentRight - 12, ChatContentBottom, ChatContentLeft);
        //        mineContantBtn.contentEdgeInsets = UIEdgeInsetsMake(-50, ChatContentRight, -50, ChatContentLeft);
        
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
                            //                        [attributedString m80_setTextColor:[UIColor redColor] range:range];
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
                mineContantBtn.backImageView.frame = CGRectMake(0, 0, messageFrame.contentF.size.width, messageFrame.contentF.size.height);
                progressV = [[GYHSectorProgressView alloc]initWithCenter:CGPointMake(messageFrame.contentF.size.width/2, messageFrame.contentF.size.height/2)];
                progressV.progressColor = UIColorFromRGB(0xAAAAAA);
                [mineContantBtn addSubview:progressV];
                [mineContantBtn.backImageView ShowImageWithUrlStr:message.pictureUrl placeHoldName:message.pictureUrl.length > [NFUserEntity shareInstance].HeadPicpathAppendingString.length?@"图片加载背景":@"图片加载失败" completion:^(BOOL success, UIImage *image) {
                    progressV.hidden = YES;
                } progressBlock:^(CGFloat progress) {
                    progressV.progressValue = progress;
                }];
                
//                if (message.picture) {
//                    mineContantBtn.backImageView.image = message.picture;
//                }else{
//                    __weak typeof(self)weakSelf=self;
//                    [[SDImageCache sharedImageCache] diskImageExistsWithKey:message.cachePicPath completion:^(BOOL isInCache) {
//                        message.picture = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:message.cachePicPath];
//                        if (message.picture) {
//                            [messageFrame setMessage:message];
//                            [weakSelf setMessageFrame:messageFrame];
//                        }
//                    }];
//                }
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
                //            voiceURL = [NSString stringWithFormat:@"%@%@",RESOURCE_URL_HOST,message.strVoice];
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
        self.otherContanttWidthConstraint.constant = messageFrame.contentF.size.width + 1;
        self.otherContanttHeightConstraint.constant = messageFrame.contentF.size.height + 1;
        otherContantBtn.isMyMessage = NO;
        //[otherContantBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [otherContantBtn setTitleColor:UIColorFromRGB(0x435a8e) forState:(UIControlStateNormal)];
        
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
                otherContantBtn.backImageView.frame = CGRectMake(0, 0, messageFrame.contentF.size.width, messageFrame.contentF.size.height);
                progressV = [[GYHSectorProgressView alloc]initWithCenter:CGPointMake(messageFrame.contentF.size.width/2, messageFrame.contentF.size.height/2)];
                progressV.progressColor = UIColorFromRGB(0xAAAAAA);
                [otherContantBtn addSubview:progressV];
                [otherContantBtn.backImageView ShowImageWithUrlStr:message.pictureUrl placeHoldName:message.pictureUrl.length > [NFUserEntity shareInstance].HeadPicpathAppendingString.length?@"图片加载背景":@"图片加载失败" completion:^(BOOL success, UIImage *image) {
                    progressV.hidden = YES;
                    
                } progressBlock:^(CGFloat progress) {
                    progressV.progressValue = progress;
                }];
                
//                if (message.picture) {
//                    otherContantBtn.backImageView.image = message.picture;
//                }else{
//                    __weak typeof(self)weakSelf=self;
//                    [[SDImageCache sharedImageCache] diskImageExistsWithKey:message.cachePicPath completion:^(BOOL isInCache) {
//                        message.picture = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:message.cachePicPath];
//                        if (message.picture) {
//                            [messageFrame setMessage:message];
//                            //这里很危险 如果用户数据库没有picture字段 那么便会进入死循环,上面加个判断当取到picture 确定不会进入死循环 再进行调用self
//                            [weakSelf setMessageFrame:messageFrame];
//                        }
//                    }];
//                }
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
        if (message.from == UUMessageFromMe) {
            normal = [UIImage imageNamed:@"chatMyMessage_Normal"];
            normal = [UIImage SDResizeWithIma:normal];
            
//            normal = [UIImage imageNamed:@"chatto_bg_normal"];
            //(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right)
            //            normal = [normal resizableImageWithCapInsets:UIEdgeInsetsMake(35, 10, 10, 22)];
//            normal = [normal resizableImageWithCapInsets:UIEdgeInsetsMake(35, 10, 10, 22) resizingMode:UIImageResizingModeStretch];
            
        }
        else{
            normal = [UIImage imageNamed:@"chatSickMessage_Normal"];
            normal = [UIImage SDResizeWithIma:normal];
//            normal = [UIImage imageNamed:@"chatfrom_bg_normal"];
//            normal = [normal resizableImageWithCapInsets:UIEdgeInsetsMake(35, 22, 10, 10)];
        }
        if (message.type != UUMessageTypePicture) {
            [mineContantBtn setBackgroundImage:normal forState:UIControlStateNormal];
            [mineContantBtn setBackgroundImage:normal forState:UIControlStateHighlighted];
        }
    }else if(message.from == UUMessageFromOther){
        //背景气泡图
        UIImage *normal;
        if (message.from == UUMessageFromMe) {
            normal = [UIImage imageNamed:@"chatMyMessage_Normal"];
            normal = [UIImage SDResizeWithIma:normal];
//            normal = [UIImage imageNamed:@"chatto_bg_normal"];
//            normal = [normal resizableImageWithCapInsets:UIEdgeInsetsMake(35, 10, 10, 22)];
        }
        else{
            normal = [UIImage imageNamed:@"chatSickMessage_Normal"];
            normal = [UIImage SDResizeWithIma:normal];
//            normal = [UIImage imageNamed:@"chatSickMessage_Normal"];
//            normal = [normal resizableImageWithCapInsets:UIEdgeInsetsMake(35, 22, 10, 10)];
            
        }
        if (message.type != UUMessageTypePicture) {
            [otherContantBtn setBackgroundImage:normal forState:UIControlStateNormal];
            [otherContantBtn setBackgroundImage:normal forState:UIControlStateHighlighted];
        }
        
    }
    
}

#pragma mark - 是否允许撤回
-(BOOL)IsAllowDraw:(NSInteger)receiveTime{
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:receiveTime];
    NSTimeInterval time = [currentDate timeIntervalSinceDate:confromTimesp];
    NSInteger timme = time;
    if (timme <= 180) {
        return YES;
    }
    return NO;
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
    __block NSArray *imageChatEntityArr = [NSArray new];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        imageChatEntityArr = [strongSelf ->jqFmdb jq_lookupTable:friendId dicOrModel:[MessageChatEntity class] whereFormat:@"where type = '%@'",@"1"];
    }];
    NSMutableArray *urlArr = [NSMutableArray new];
    NSInteger selectedIndex = 0;
    BOOL IsSearched = NO;
    for (MessageChatEntity *picEntity in imageChatEntityArr) {
        //当图片为完整地址 并且不是隐藏状态 则add到展示数组里面去
        if (picEntity.pictureUrl.length > [NFUserEntity shareInstance].HeadPicpathAppendingString.length  && ![picEntity.yuehouYinCang isEqualToString:@"1"]) {
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
    if (!string) {
        string = @"";
    }
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
        [self.searchedURLArr addObject:substringForMatch];//将网址add到数组中去【有几个网址add 几个】
    }
    if (self.searchedURLArr.count > 0) {
        return YES;
    }
    return NO;
}


-(void)myCopy:(UIButton *)sender{
    
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
//    if (!selected) {//不能在这里设置 因为在willappearcell时 selected都是no，过了willappear 才能获取到正确的selected状态
//        self.messageFrame.message.IsSelected = NO;
//    }
//    NSArray *subviews = [self subviews];
//    for (id obj in subviews) {
//        if ([obj isKindOfClass:[UIControl class]]) {
//            UIControl *control = obj;
//            control.userInteractionEnabled = NO;
//            for (id subview in [obj subviews]) {
//                if ([subview isKindOfClass:[UIImageView class]]) {
//                    UIImageView *imageV = subview;
//                    imageV.userInteractionEnabled = YES;
//                    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickControlAction)];
//                    [imageV addGestureRecognizer:singleTap];
//                }
//            }
//        }
//    }
    
//    NSArray *subviews = [self subviews];
//    for (id obj in subviews) {
//        if ([obj isKindOfClass:[UIControl class]]) {
//            UIControl *control = obj;
//            control.userInteractionEnabled = NO;
//            for (id subview in [obj subviews]) {
//                if ([subview isKindOfClass:[UIImageView class]]) {
//                    UIImageView *imageV = subview;
//                    imageV.userInteractionEnabled = NO;
//                }
//            }
//        }
//    }
    // Configure the view for the selected state
}

@end
