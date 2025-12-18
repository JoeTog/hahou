//
//  OnlyTextTableViewCell.m
//  nationalFitness
//
//  Created by Joe on 2017/7/7.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "OnlyTextTableViewCell.h"
#import "NFHeadImageView.h"
#import "NFDynamicEntity.h"
#import "CCXMethods.h"

#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>

#define ONLYTEXTHEIGHT  165



@implementation OnlyTextTableViewCell{
    __weak IBOutlet UILabel *contentLabel; //由于xib的宽度是320 所以在414 上面时 高度显示会偏高
//    __weak IBOutlet NFHeadImageView *headImageView;
    __weak IBOutlet UILabel *nickName;
    __weak IBOutlet UIButton *connectBtn;
    __weak IBOutlet UILabel *timeCityLab;
    __weak IBOutlet UILabel *zanCountLab;
    
    __weak IBOutlet UILabel *commentLabel;
    
    //内容高度约束
    __weak IBOutlet NSLayoutConstraint *contentHeightConstaint;
    
    
    // 从列表页传过来
    NoteListEntity *entity_;
    UITableView *tableView_;
    NSMutableArray *dataSouceArr_;
    UIActionSheet *shareSheet_;
    UIActionSheet *editSheet_;
    NFCommentInputView *messageToolView;
    NSIndexPath *indexPath_;
    
    SocketModel * socketModel;
    //点赞按钮 当点赞后 等服务器返回成功再改变状态
    UIButton *zanBtnn;
    
    JQFMDB *jqFmdb;
    
    CGFloat maxContentLabelHeight; // 根据具体font而定
    NSMutableDictionary *cacheHeightDict_;
    
}

-(void)initSocket{
    
    socketModel = [SocketModel share];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.zanBtn setTitleColor:[UIColor colorMainTextColor] forState:(UIControlStateNormal)];
    [self.commentBtn setTitleColor:[UIColor colorMainTextColor] forState:(UIControlStateNormal)];
    [self.shareBtn setTitleColor:[UIColor colorMainTextColor] forState:(UIControlStateNormal)];
    [self.qubaoBtn setTitleColor:[UIColor colorMainTextColor] forState:(UIControlStateNormal)];
    
    
    
    
}
//文字cell
- (void)showCellWithEntity:(id)entity withDataSource:(NSMutableArray *)dataArr CacheHeightDict:(NSMutableDictionary *)cacheHeightDict commentView:(NFCommentInputView *)commentView withTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    [self initSocket];
    [self setup];
    entity_ = (NoteListEntity *)entity;
    tableView_ = tableView;
    dataSouceArr_ = dataArr;
    messageToolView = commentView;
    messageToolView.commentId = entity_.circle_id;
    indexPath_ = indexPath;
    cacheHeightDict_ = cacheHeightDict;
    [self.headImageView ShowHeadImageWithUrlStr:entity_.photo withUerId:entity_.user_id completion:nil];
    zanCountLab.text = [NSString stringWithFormat:@"%@次赞",entity_.praiseCount];
    commentLabel.text = [NSString stringWithFormat:@"｜%ld条评论",entity_.commentArr.count];
    NSString *address;
    NSString *city;
    if (entity_.relAddress == nil)
    {
        address = @"";
    }else
    {
        address = [NSString stringWithFormat:@"·%@",entity_.relAddress];
    }
    if ([entity_.isUpdate isEqualToString:@"1"])
    {
        city = @"·已编辑";
    }else
    {
        city = @"";
    }
    timeCityLab.text = [NSString stringWithFormat:@"%@%@%@",entity_.post_time,city,address];
    //判断是否隐藏编辑按钮
//    if ([entity_.user_id isEqualToString:[NFUserEntity shareInstance].userId]) {
//        _editBtn.hidden = NO;
//    }else
//    {
//        _editBtn.hidden = YES;
//    }
    
//    if ([entity_.isFlag isEqualToString:@"0"])
//    {
//        _editBtn.hidden = NO;
//    }else
//    {
//        _editBtn.hidden = YES;
//    }
    
    if (entity_.fkid.length == 0)
    {
        connectBtn.hidden = YES;
    }else
    {
        connectBtn.hidden = NO;
        [connectBtn addTarget:self action:@selector(goAct) forControlEvents:UIControlEventTouchUpInside];
        [connectBtn setTitle:entity_.actName forState:UIControlStateNormal];
    }
    
    if ([entity_.isPraise isEqualToString:@"1"])
    {
        [self.zanBtn setTitleColor:TheColor_BlueColor forState:UIControlStateNormal];
        [self.zanBtn setImage:[UIImage imageNamed:@"dynaminc-zan"] forState:UIControlStateNormal];
    }else
    {
        [self.zanBtn setTitleColor:[UIColor colorMainTextColor] forState:UIControlStateNormal];
        
        [self.zanBtn setImage:[UIImage imageNamed:@"dynamic_noZan"] forState:UIControlStateNormal];
        
    }
    if (entity_.nickname.length > 0) {
        nickName.text = entity_.nickname;
    }else{
        nickName.text = entity_.user_name;
    }
    //根据bool值判断是否展示全部详情
    if (entity_.isExetend)
    {
        [contentLabel setNumberOfLines:0];
//        contentLabel.sd_layout.maxHeightIs(MAXFLOAT);
        [_showMoreBtn setTitle:@"收起" forState:UIControlStateNormal];
        
    }
    else
    {
//        [contentLabel setNumberOfLines:2];
        contentLabel.sd_layout.maxHeightIs(maxContentLabelHeight);
        [_showMoreBtn setTitle:@"展开" forState:UIControlStateNormal];
    }
    contentLabel.text = entity_.circle_content;
    [self needShowMoreBtn];
}

//判断是否需要显示展开的按钮
- (void)needShowMoreBtn
{
    UILabel *disHeightLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 10.f, 0.0f)];
    [disHeightLab setNumberOfLines:0];
    disHeightLab.font = [UIFont systemFontOfSize:OnlyTextTableViewCellFontSize];
    disHeightLab.text = entity_.circle_content;
    [disHeightLab sizeToFit];
    if (disHeightLab.frame.size.height > 33)
    {
        _showMoreBtn.hidden = NO;
        
    }
    else
    {
        _showMoreBtn.hidden = YES;
    }
}

//-(void)layoutSubviews{ //这样做没有用 内容的高度依旧是320的高度
//    [super layoutSubviews];
//    [contentLabel layoutIfNeeded];
//    if (entity_.isExetend)
//    {
//        [contentLabel setNumberOfLines:0];
//        [_showMoreBtn setTitle:@"收起" forState:UIControlStateNormal];
//    }
//    else
//    {
//        [contentLabel setNumberOfLines:2];
//        [_showMoreBtn setTitle:@"展开" forState:UIControlStateNormal];
//    }
//    contentLabel.text = entity_.circle_content;
//    NSLog(@"%f",self.frame.size.width);
//}

//根据文字的长度适配cell的高度
+ (CGFloat)getContentCellHeight:(NSString  *)str seeingMore:(BOOL)seeingMore
{
    UILabel *disHeightLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - leadAndTailConstaint, 0.0f)];
    if (seeingMore)
    {
        [disHeightLab setNumberOfLines:0];
    }
    else
    {
        [disHeightLab setNumberOfLines:2];
    }
    disHeightLab.font = [UIFont systemFontOfSize:OnlyTextTableViewCellFontSize];
    disHeightLab.text = str;
    [disHeightLab sizeToFit];
    
    UILabel *Lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - leadAndTailConstaint, 0.0f)];
    [Lab setNumberOfLines:0];
    Lab.font = [UIFont systemFontOfSize:OnlyTextTableViewCellFontSize];
    Lab.text = str;
    [Lab sizeToFit];
    CGFloat height;
    if (Lab.frame.size.height > 33)
    {
        height = 0;
    }
    else
    {
        height = 20;
    }
    if (seeingMore) {
        return ONLYTEXTHEIGHT - 18 +disHeightLab.frame.size.height - height ;
//        return ONLYTEXTHEIGHT - 18 +disHeightLab.frame.size.height - height + 10;
    }
    return ONLYTEXTHEIGHT - 18 +disHeightLab.frame.size.height - height;
}


#pragma mark - 帖子操作相关
-(void)goAct{
    
}

#pragma mark - 展开更多
- (IBAction)showMoreDis:(id)sender {
    [cacheHeightDict_ removeObjectForKey:[NSString stringWithFormat:@"%ld-%ld", (long)indexPath_.section, (long)indexPath_.row]];
    entity_.isExetend = !entity_.isExetend;
    [tableView_ beginUpdates];
    [tableView_ reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath_.row inSection:indexPath_.section]] withRowAnimation:UITableViewRowAnimationFade];
    [tableView_ endUpdates];
}

#pragma mark -编辑删除帖子sheet设置
- (IBAction)editNote:(id)sender {
    
//    editSheet_ = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"编辑帖子",@"删除帖子", nil];
//    [editSheet_ showInView:[KeepAppBox viewController:self].view];
    if ([entity_.user_id isEqualToString:[NFUserEntity shareInstance].userId]) {
        //自己的可以编辑和删除
        __weak typeof(self)weakSelf=self;
//        [NSArray arrayWithObjects:@"编辑帖子",@"删除帖子", nil]
        LWWeChatActionSheet *sheet = [[LWWeChatActionSheet alloc] initWithWeChatActionSheetCancelButtonTitle:@"取消" title:nil otherButtonTitles:[NSArray arrayWithObjects:@"删除帖子", nil] btnClickBlock:^(NSInteger buttonIndex) {
            if (0 == buttonIndex)
            {
//                // 编辑帖子
//                [weakSelf performSelector:@selector(editNotes:) withObject:entity_ afterDelay:0.5f];
//            }else if (1 == buttonIndex)
//            {
                //点击确认 再次要求确认
                LWWeChatActionSheet *sheetSure = [[LWWeChatActionSheet alloc] initWithWeChatActionSheetCancelButtonTitle:@"取消" title:@"确定删除？" otherButtonTitles:[NSArray arrayWithObjects:@"确定", nil] btnClickBlock:^(NSInteger buttonIndex) {
                    if (buttonIndex == 0) {
                        [weakSelf deleteNote:entity_];
                        [dataSouceArr_ removeObject:entity_];
                        [cacheHeightDict_ removeAllObjects];
                        [tableView_ reloadData];
                    }
                }];
                [sheetSure show];
            }
        }];
        [sheet show];
    }else{
        //别人的可以屏蔽和举报
        LWWeChatActionSheet *sheet = [[LWWeChatActionSheet alloc] initWithWeChatActionSheetCancelButtonTitle:@"取消" title:nil otherButtonTitles:[NSArray arrayWithObjects:@"不看他的动态", nil] btnClickBlock:^(NSInteger buttonIndex) {
            if (0 == buttonIndex)
            {
                LWWeChatActionSheet *sheetSec = [[LWWeChatActionSheet alloc] initWithWeChatActionSheetCancelButtonTitle:@"取消" title:@"确定屏蔽他的动态?" otherButtonTitles:[NSArray arrayWithObjects:@"确定", nil] btnClickBlock:^(NSInteger buttonIndex) {
                    if (buttonIndex == 0) {
                        //不看他的动态
                        //                [self deleteNote:entity_];
#warning 拉黑
                        //修改联系人属性 屏蔽动态
                        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
                        __block NSArray *contactArr = [NSArray new];
                        __weak typeof(self)weakSelf=self;
                        [jqFmdb jq_inDatabase:^{
                            __strong typeof(weakSelf)strongSelf=weakSelf;
                            contactArr = [strongSelf ->jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact new] whereFormat:@" where friend_userid = '%@'",strongSelf ->entity_.user_id];
                        }];
                        if (contactArr.count == 1){
                            ZJContact *contact = [contactArr firstObject];
                            contact.IsShieldDynamic = YES;
                            __block BOOL ret;
                            __weak typeof(self)weakSelf=self;
                            [jqFmdb jq_inDatabase:^{
                                __strong typeof(weakSelf)strongSelf=weakSelf;
                                ret = [strongSelf ->jqFmdb jq_updateTable:@"lianxirenliebiao" dicOrModel:contact whereFormat:@" where friend_userid = '%@'",strongSelf ->entity_.user_id];
                                if (ret) {
                                }
                            }];
                        }
                        //找出需要屏蔽的动态
                        NSMutableArray *needShieldArr = [NSMutableArray new];
                        for (NoteListEntity *dynamic in dataSouceArr_) {
                            if ([dynamic.user_id isEqualToString:entity_.user_id]) {
                                [needShieldArr addObject:dynamic];
                            }
                        }
                        //进行删除界面数据
                        for (NoteListEntity *dynamic in needShieldArr) {
                            [dataSouceArr_ removeObject:dynamic];
                        }
                        [cacheHeightDict_ removeAllObjects];
                        [tableView_ reloadData];
                        //在请求到动态的时候 判断该人是否被屏蔽了动态
                    }
                }];
                [sheetSec show];
            }
        }];
        [sheet show];
    }
}

#pragma mark - 删除帖子请求
- (void)deleteNote:(NoteListEntity *)entity
{
    [SVProgressHUD show];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"delCircle";
    self.parms[@"circleId"] = entity.circle_id;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
//    NSMutableDictionary *sendDic = [@{} mutableCopy];
//    [sendDic setObject:entity.noteId?entity.noteId:@"" forKey:@"noteId"];
//    [NFDynamicManager execute:@selector(deleteNoteManager) target:self callback:@selector(deleteNoteCallback:) args:sendDic,nil];
}

- (void)deleteNoteCallback:(id)data
{
    // 不做处理
}

#pragma mark - 举报相关
- (IBAction)jubaoClick:(id)sender {
    //意见反馈
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"PublicFunctionStoryboard" bundle:nil];
    OpinionRequestViewController * toCtrol = [sb instantiateViewControllerWithIdentifier:@"OpinionRequestViewController"];
    toCtrol.tousu = YES;
    toCtrol.cycleId = entity_.circle_id;
    toCtrol.cycleEntity = entity_;
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
    [currentVC.navigationController pushViewController:toCtrol animated:YES];
}

#pragma mark - 分享相关 @"编辑帖子",@"删除帖子",
- (IBAction)shareClick:(id)sender {
//    shareSheet_ = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"分享至密聊",@"分享给外部", nil];
//    shareSheet_ = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"分享给外部", nil];
//    [shareSheet_ showInView:[KeepAppBox viewController:self].view];
    if (messageToolView) {
        [messageToolView.messageInputTextView resignFirstResponder];
    }else{
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        DynamicViewController *currentVC = (DynamicViewController *)[NFMyManage getCurrentVCFrom:rootViewController];
        [currentVC.messageToolView.messageInputTextView resignFirstResponder];
    }
    
    
    LWWeChatActionSheet *sheet = [[LWWeChatActionSheet alloc] initWithWeChatActionSheetCancelButtonTitle:@"取消" title:nil otherButtonTitles:[NSArray arrayWithObjects:@"分享到外部", nil] btnClickBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 999) {
            return ;
        }
        [self shareToOut:buttonIndex];
    }];
    [sheet show];
    
    
}

#pragma mark - 编辑相关【删除 编辑】
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == shareSheet_)
    {
//        if (0 == buttonIndex)
//        {
//            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"DynamicStoryboard" bundle:nil];
//            PublishDynamicViewController *vc = [sb instantiateViewControllerWithIdentifier:@"PublishDynamicViewController"];
//            vc.shareType = ShareTypeOffNote;
//            vc.noteEntity = entity_;
//            __weak OnlyTextTableViewCell *selfWeak = self;
//            if ([[KeepAppBox viewController:self] isKindOfClass:[DynamicViewController class]])
//            {
//                vc.successBlock = ^(BOOL success){
//                    DynamicViewController *vcdy = (DynamicViewController *)[KeepAppBox viewController:selfWeak];
//                    [vcdy getNoteList];
//                };
//            }
//            [[KeepAppBox viewController:self].navigationController pushViewController:vc animated:YES];
//        }
        
    }
    else if (actionSheet == editSheet_)
    {
//        if (0 == buttonIndex)
//        {
//            // 编辑帖子
//            [self performSelector:@selector(editNotes:) withObject:entity_ afterDelay:0.5f];
//        }else if (1 == buttonIndex)
//        {
//            
//            [self deleteNote:entity_];
//            [dataSouceArr_ removeObject:entity_];
//            [tableView_ reloadData];
//        }
    }
}

#pragma mark - 分享
-(void)shareToOut:(NSInteger)buttonIndex{
    if(0 == buttonIndex)
    {
        //1、创建分享参数
        NSArray* imageArray = @[[UIImage imageNamed:@"AppIcon"]];
        //（注意：图片必须要在Xcode左边目录里面，名称必须要传正确，如果要分享网络图片，可以这样传iamge参数 images:@[@"http://mob.com/Assets/images/logo.png?v=20150320"]）
        if (imageArray) {
            NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
            [shareParams SSDKSetupShareParamsByText:entity_.circle_content
                                             images:[UIImage imageNamed:@"AppIcon"]
                                                url:[NSURL URLWithString:@"http://mob.com"]
                                              title:@"多信分享"
                                               type:SSDKContentTypeAuto];
            //2、分享（可以弹出我们的分享菜单和编辑界面）
            [ShareSDK showShareActionSheet:nil //要显示菜单的视图, iPad版中此参数作为弹出菜单的参照视图，只有传这个才可以弹出我们的分享菜单，可以传分享的按钮对象或者自己创建小的view 对象，iPhone可以传nil不会影响
                                     items:nil
                               shareParams:shareParams
                       onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                           switch (state) {
                               case SSDKResponseStateSuccess:
                               {
                                   UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                                       message:nil
                                                                                      delegate:nil
                                                                             cancelButtonTitle:@"确定"
                                                                             otherButtonTitles:nil];
                                   [alertView show];
                                   break;
                               }
                               case SSDKResponseStateFail:
                               {
                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                                   message:[NSString stringWithFormat:@"%@",error]
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"OK"
                                                                         otherButtonTitles:nil, nil];
                                   [alert show];
                                   break;
                               }
                               default:
                                   break;
                           }
                       }
             ];}
    }
}

- (void)editNotes:(NoteListEntity *)entity
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"DynamicStoryboard" bundle:nil];
    PublishDynamicViewController *vc = [sb instantiateViewControllerWithIdentifier:@"PublishDynamicViewController"];
    vc.editEntity = entity;
    __weak OnlyTextTableViewCell *selfWeak = self;
    if ([[KeepAppBox viewController:self] isKindOfClass:[DynamicViewController class]])
    {
        vc.successBlock = ^(BOOL success){
            DynamicViewController *vcdy = (DynamicViewController *)[KeepAppBox viewController:selfWeak];
            [vcdy getNoteList];
        };
    }
//    else if ([[KeepAppBox viewController:self] isKindOfClass:[SunVenuesViewController class]])
//    {
//        vc.successBlock = ^(BOOL success)
//        {
//            SunVenuesViewController *vcdy = (SunVenuesViewController *)[KeepAppBox viewController:selfWeak];
//            [vcdy getNoteList];
//        };
//    }
    [[KeepAppBox viewController:self].navigationController pushViewController:vc animated:YES];
}

#pragma mark - 点赞相关
- (IBAction)zanClick:(UIButton *)sender forEvent:(UIEvent *)event {
    socketModel.delegate = self;
    zanBtnn = sender;
//    [self animation:sender];
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
    if ([entity_.isPraise isEqualToString:@"1"])
    {
        [self cancelPraiseNote:entity_];
        //取消点赞
        entity_.isPraise = @"0";
        //NSLog(@"%ld",dataSouceArr_.count);
        NoteListEntity *entity = [dataSouceArr_ firstObject];
        NSInteger count = [entity_.praiseCount integerValue] - 1;
        if (count <= 0)
        {
            count = 0;
        }
        entity_.praiseCount = [NSString stringWithFormat:@"%ld",(long)count];
        [zanBtnn setTitleColor:[UIColor colorMainTextColor] forState:UIControlStateNormal];
        [zanBtnn setImage:[UIImage imageNamed:@"dynamic_noZan"] forState:UIControlStateNormal];
        
    }else
    {
        //将点击的cell的indexpath 赋值给动态列表controller界面
        [self praiseNote:entity_];
        entity_.isPraise = @"1";
        //NSLog(@"%ld",dataSouceArr_.count);
        NSInteger count = [entity_.praiseCount integerValue] + 1;
        if (count <= 0)
        {
            count = 0;
        }
        entity_.praiseCount = [NSString stringWithFormat:@"%ld",(long)count];
        [zanBtnn setTitleColor:[UIColor colorWithRed:215.0/255 green:55.0/255 blue:58.0/255 alpha:1] forState:UIControlStateNormal];
        [zanBtnn setImage:[UIImage imageNamed:@"dynaminc-zan"] forState:UIControlStateNormal];
    }
    [tableView_ reloadData];
}

#pragma mark - 点赞动画
- (void)animation:(UIButton *)btn {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.values = @[@1.4, @1.0];
    animation.duration = 0.3;
    animation.calculationMode = kCAAnimationCubic;
    [btn.layer addAnimation:animation forKey:@"transform.scale"];
    
}

#pragma mark - 评论相关
- (IBAction)commentClick:(id)sender {
    if (messageToolView)
    {
        //能够进这里的 就是详情动态了
        messageToolView.hidden = NO;
        messageToolView.commentType = @"2";
        //需要的entity_里面参数在最上面传。这里传过去为nil
        messageToolView.commentId = entity_.circle_id;
        messageToolView.byCommId = nil;
//        messageToolView.messageInputTextView.placeHolder = [NSString stringWithFormat:@"回复%@:",entity_.user_name];
        messageToolView.messageInputTextView.placeHolder = @"评论";
        [messageToolView.messageInputTextView becomeFirstResponder];
    }else
    {
        //在外部controller中跳转 【下面五行暂时无效 必须走这里 走外面捕捉不到动态的实体】
//        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"DynamicStoryboard" bundle:nil];
//        DynamicNewDetailViewController *detailVC = [sb instantiateViewControllerWithIdentifier:@"DynamicNewDetailViewController"];
//        detailVC.entityid = entity_.noteId;
//        detailVC.isFromComment = YES;
//        //后加的 以后需要请求详情
//        detailVC.noteListEntity = entity_;
//        [NFUserEntity shareInstance].isPicImageDynamic = NO;
        
//        [[KeepAppBox viewController:self].view.superview setTransitionAnimationType:(CCXTransitionAnimationTypeCube) toward:(CCXTransitionAnimationTowardFromRight) duration:0.5];
        
        //
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        DynamicViewController *currentVC = (DynamicViewController *)[NFMyManage getCurrentVCFrom:rootViewController];
//        currentVC.messageToolView.commentType = @"2";
//        currentVC.messageToolView.commentId = entity_.circle_id;
//        //评论动态 回复id为nil
//        currentVC.messageToolView.byCommId = @"";
//        currentVC.messageToolView.isFromHome = NO;
//        currentVC.messageToolView.messageInputTextView.placeHolder = [NSString stringWithFormat:@"回复%@:",entity_.user_name];
        
        NSLog(@"%@",self.parms[@"action"]);
        currentVC.selectCommentIndexpath = indexPath_;
        [currentVC.messageToolView.messageInputTextView becomeFirstResponder];
//        [[KeepAppBox viewController:self].navigationController pushViewController:detailVC animated:NO];
        
        
    }
}


- (UIViewController *)viewController
{
    for (UIView *next = [self superview]; next; next = next.superview)
    {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]])
        {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

#pragma mark - 取消点赞请求
- (void)cancelPraiseNote:(NoteListEntity *)entity
{
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"delCircleLike";
    self.parms[@"likeId"] = entity_.currentUserLike;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
    
//    NSMutableDictionary *sendDic = [@{} mutableCopy];
//    [sendDic setObject:@"2" forKey:@"praiseType"];
//    [sendDic setObject:entity.noteId?entity.noteId:@"" forKey:@"fkId"];
//    [NFDynamicManager execute:@selector(cancelPriseNoteManager) target:self callback:@selector(cancelPraiseNoteCallback:) args:sendDic,nil];
}
#pragma mark - 点赞请求
- (void)praiseNote:(NoteListEntity *)entity
{
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"postCircleLike";
    self.parms[@"circleId"] = entity_.circle_id;
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
- (void)praiseNoteCallback:(id)data
{
    // 不做处理
}
- (void)cancelPraiseNoteCallback:(id)data
{
    // 不做处理
}

#pragma mark - 接收消息代理
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    if (messageType == SecretLetterType_DynamicDianzan) {
        if ([chatModel isKindOfClass:[NSDictionary class]]) {
            NSDictionary *resultDict = chatModel;
            if ([[resultDict objectForKey:@"type"] isEqualToString:@"6002"]) {
                //点赞成功
                entity_.currentUserLike = [resultDict objectForKey:@"result"];
            }else if ([[resultDict objectForKey:@"type"] isEqualToString:@"6010"]){
                entity_.currentUserLike = @"";
            }else if ([[resultDict objectForKey:@"type"] isEqualToString:@"6006"]){
                //点赞失败 将点赞还原成未点赞
                //取消点赞
//                entity_.isPraise = @"0";
//                NSInteger count = [entity_.praiseCount integerValue] - 1;
//                if (count <= 0)
//                {
//                    count = 0;
//                }
//                entity_.praiseCount = [NSString stringWithFormat:@"%ld",(long)count];
//                [zanBtn setTitleColor:[UIColor colorMainTextColor] forState:UIControlStateNormal];
//                [zanBtn setImage:[UIImage imageNamed:@"dynamic_noZan"] forState:UIControlStateNormal];
            }else if ([[resultDict objectForKey:@"type"] isEqualToString:@"6013"]){
                //取消点赞失败 将点赞还原成已点赞
//                entity_.isPraise = @"1";
//                NSInteger count = [entity_.praiseCount integerValue] + 1;
//                if (count <= 0)
//                {
//                    count = 0;
//                }
//                entity_.praiseCount = [NSString stringWithFormat:@"%ld",(long)count];
//                [zanBtn setTitleColor:[UIColor colorWithRed:215.0/255 green:55.0/255 blue:58.0/255 alpha:1] forState:UIControlStateNormal];
//                [zanBtn setImage:[UIImage imageNamed:@"dynaminc-zan"] forState:UIControlStateNormal];
                
            }
        }
        
    }else if (messageType == SecretLetterType_DynamicDianzan){
        
    }
}

-(void)setup{
    
    if (maxContentLabelHeight == 0) {
        maxContentLabelHeight = contentLabel.font.lineHeight * 2;
    }
    CGFloat margin = 8;
    contentLabel.sd_layout
    .leftEqualToView(self.headImageView)
    .topSpaceToView(self.headImageView, margin)
    .rightSpaceToView(self.contentView, margin)
    .autoHeightRatio(0);
    
    //_showMoreBtn
    _showMoreBtn.sd_layout
    .leftEqualToView(self.headImageView)
    .topSpaceToView(contentLabel, margin - 2)
//    .rightSpaceToView(self.contentView, margin)
    .widthIs(40)
    .heightIs(20);
//    .autoHeightRatio(0);
    
}

//懒加载
-(NSMutableDictionary *)parms{
    if (!_parms) {
        _parms = [[NSMutableDictionary alloc] init];
    }
    return _parms;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
