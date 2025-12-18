//
//  ContentNewCell.m
//  nationalFitness
//
//  Created by Joe on 2017/7/8.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "ContentNewCell.h"
#import "NFHeadImageView.h"
#import "NFShowPictureView.h"

#import "DynamicViewController.h"
#import "NFDynamicEntity.h"

#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>

#define ContentNewCellHeight  (kPLUS_SCALE_X(280)+460-280)

//#define ContentNewCellHeightSec  (kPLUS_SCALE_X(197)+460-280 + 10)
#define ContentNewCellHeightSec  (kPLUS_SCALE_X(200)+460-280 + 10)



@implementation ContentNewCell{
    __weak IBOutlet UIButton *playVideoBtn;
    
    
    
    __weak IBOutlet NFShowPictureView *picView;
    
    __weak IBOutlet UILabel *contentLabel;
    
    __weak IBOutlet UILabel *nickNameLab;
    
    __weak IBOutlet UILabel *zanCountLab;
    
    __weak IBOutlet UILabel *commentLabel;
    
    
    
    __weak IBOutlet UILabel *timeCityLab;
    
    __weak IBOutlet UIButton *connectBtn;
    
    SocketModel * socketModel;
    
    // 从列表页传过来
    NoteListEntity *entity_;
    UITableView *tableView_;
    NSMutableArray *dataSouceArr_;
    UIActionSheet *shareSheet_;
    UIActionSheet *editSheet_;
    NFCommentInputView *messageToolView;
    NSIndexPath *indexPath_;
    
    //点赞按钮 当点赞后 等服务器返回成功再改变状态
    UIButton *zanBtnn;
    
    JQFMDB *jqFmdb;
    
    CGFloat maxContentLabelHeight; // 根据具体font而定
    NSMutableDictionary *cacheHeightDict_;
}

-(void)initSocket{
    //获取单例
    socketModel = [SocketModel share];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
//    ViewRadius(self.headImageView, self.headImageView/2);
    
    [self.zanBtn setTitleColor:[UIColor colorMainTextColor] forState:(UIControlStateNormal)];
    [self.commentBtn setTitleColor:[UIColor colorMainTextColor] forState:(UIControlStateNormal)];
    [self.shareBtn setTitleColor:[UIColor colorMainTextColor] forState:(UIControlStateNormal)];
    [self.qubaoBtn setTitleColor:[UIColor colorMainTextColor] forState:(UIControlStateNormal)];
}


//图片文字 cell
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
    NSMutableArray *arr = [@[] mutableCopy];
    BOOL isFromLocal = NO;
    //\当为预览过来时 传过来的是一个字点 里面的健值对的值是image
    if ([[entity_.photoList firstObject] isKindOfClass:[NSDictionary class]]) {
        for (NSDictionary *dic in entity_.photoList)
        {
            if ([[dic objectForKey:@"bigPicPath"]isKindOfClass:[UIImage class]])
            {
                isFromLocal = YES;
            }
            [arr addObject:[dic objectForKey:@"bigPicPath"]];
        }
    }
    
    //当arr 数目大于0 为预览过来的
    if (arr.count > 0) {
        [picView setPictureArr:arr isFromLocal:isFromLocal];
    }else{
        [picView setPictureArr:entity_.photoList isFromLocal:isFromLocal];
    }
    
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
    if (entity_.fkid.length == 0)
    {
        connectBtn.hidden = YES;
    }else
    {
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
    nickNameLab.text = entity_.nickname?entity_.nickname:entity_.user_name;
    
    //根据bool值判断是否展示全部详情
    if (entity_.isExetend)
    {
//        contentLabel.sd_layout.maxHeightIs(MAXFLOAT);
        contentLabel.numberOfLines = 0;
        [_showMoreBtn setTitle:@"收起" forState:UIControlStateNormal];
    }
    else
    {
        contentLabel.sd_layout.maxHeightIs(maxContentLabelHeight);
        [_showMoreBtn setTitle:@"展开" forState:UIControlStateNormal];
    }
    contentLabel.text = entity_.circle_content;
    [self needShowMoreBtn];
}

//判断是否需要显示展开的按钮
- (void)needShowMoreBtn
{
    UILabel *disHeightLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - leadAndTailConstaint, 0.0f)];
    [disHeightLab setNumberOfLines:0];
    disHeightLab.font = [UIFont systemFontOfSize:ContentNewCellFontSize];
    disHeightLab.text = entity_.circle_content;
    [disHeightLab sizeToFit];
    NSLog(@"%f",disHeightLab.frame.size.height);
    if (disHeightLab.frame.size.height > 33)
    {
        _showMoreBtn.hidden = NO;
    }
    else
    {
        _showMoreBtn.hidden = YES;
    }
}

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
    disHeightLab.font = [UIFont systemFontOfSize:ContentNewCellFontSize];
    disHeightLab.text = str;
    [disHeightLab sizeToFit];
    NSLog(@"%lf",disHeightLab.frame.size.height);
    UILabel *Lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - leadAndTailConstaint, 0.0f)];
    [Lab setNumberOfLines:0];
    Lab.font = [UIFont systemFontOfSize:ContentNewCellFontSize];
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
        return ContentNewCellHeightSec - 18 +disHeightLab.frame.size.height - height + 15;
    }
    
    return ContentNewCellHeightSec - 18 +disHeightLab.frame.size.height - height;
//    return ContentNewCellHeight - 18 +disHeightLab.frame.size.height - height;
    
}

- (IBAction)doSelectClick:(UIButton *)sender
{
    //    UIButton *btn = (UIButton *)sender;
    //    if (self.selectVC == nil) {
    //        self.selectVC = [[ActSelectViewController alloc]init];
    //        self.selectVC.delegate = self;
    //    }
    //    CGRect rect = CGRectMake(btn.frame.origin.x - 113, btn.frame.origin.y + 20 , 145, 95);
    //    [self.selectVC showInView:self withFrame:rect];
    
}


#pragma mark - 帖子操作相关
-(void)goAct
{
    
}

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
    __weak typeof(self)weakSelf=self;
//    [NSArray arrayWithObjects:@"编辑帖子",@"删除帖子", nil]
    if ([entity_.user_id isEqualToString:[NFUserEntity shareInstance].userId]) {
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

#pragma mark - 删除帖子
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
- (IBAction)qubaoClick:(id)sender {
    //意见反馈
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"PublicFunctionStoryboard" bundle:nil];
    OpinionRequestViewController * toCtrol = [sb instantiateViewControllerWithIdentifier:@"OpinionRequestViewController"];
    toCtrol.tousu = YES;
    toCtrol.cycleEntity = entity_;
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
    [currentVC.navigationController pushViewController:toCtrol animated:YES];
}
#pragma mark - 分享相关
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

#pragma mark - 分享
-(void)shareToOut:(NSInteger)buttonIndex{
    if(0 == buttonIndex)
    {
        NSMutableArray *arr = [@[] mutableCopy];
        if ([[entity_.photoList firstObject] isKindOfClass:[NSDictionary class]]) {
            for (NSDictionary *dic in entity_.photoList)
            {
                [arr addObject:[dic objectForKey:@"bigPicPath"]];
            }
        }else if ([[entity_.photoList firstObject] isKindOfClass:[NSString class]]){
            for (NSString *pic in entity_.photoList)
            {
                [arr addObject:pic];
            }
        }
        
        //1、创建分享参数
        NSArray* imageArray = [NSArray arrayWithArray:arr];
        //（注意：图片必须要在Xcode左边目录里面，名称必须要传正确，如果要分享网络图片，可以这样传iamge参数 images:@[@"http://mob.com/Assets/images/logo.png?v=20150320"]）
        if (imageArray) {
            
            NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
            [shareParams SSDKSetupShareParamsByText:@"多信分享"
                                             images:imageArray
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
             ];
        }
    }
}

#pragma mark -编辑删除帖子sheet设置
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (actionSheet == shareSheet_)
//    {
//        if(0 == buttonIndex)
//        {
//            NSMutableArray *arr = [@[] mutableCopy];
//            if ([[entity_.photoList firstObject] isKindOfClass:[NSDictionary class]]) {
//                for (NSDictionary *dic in entity_.photoList)
//                {
//                    [arr addObject:[dic objectForKey:@"bigPicPath"]];
//                }
//            }else if ([[entity_.photoList firstObject] isKindOfClass:[NSString class]]){
//                for (NSString *pic in entity_.photoList)
//                {
//                    [arr addObject:pic];
//                }
//            }
//
//            //1、创建分享参数
//            NSArray* imageArray = [NSArray arrayWithArray:arr];
//            //（注意：图片必须要在Xcode左边目录里面，名称必须要传正确，如果要分享网络图片，可以这样传iamge参数 images:@[@"http://mob.com/Assets/images/logo.png?v=20150320"]）
//            if (imageArray) {
//
//                NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
//                [shareParams SSDKSetupShareParamsByText:@"通讯聊天的分享text"
//                                                 images:imageArray
//                                                    url:[NSURL URLWithString:@"http://mob.com"]
//                                                  title:@"通讯聊天的分享"
//                                                   type:SSDKContentTypeAuto];
//                //2、分享（可以弹出我们的分享菜单和编辑界面）
//                [ShareSDK showShareActionSheet:nil //要显示菜单的视图, iPad版中此参数作为弹出菜单的参照视图，只有传这个才可以弹出我们的分享菜单，可以传分享的按钮对象或者自己创建小的view 对象，iPhone可以传nil不会影响
//                                         items:nil
//                                   shareParams:shareParams
//                           onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
//
//                               switch (state) {
//                                   case SSDKResponseStateSuccess:
//                                   {
//                                       UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
//                                                                                           message:nil
//                                                                                          delegate:nil
//                                                                                 cancelButtonTitle:@"确定"
//                                                                                 otherButtonTitles:nil];
//                                       [alertView show];
//                                       break;
//                                   }
//                                   case SSDKResponseStateFail:
//                                   {
//                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
//                                                                                       message:[NSString stringWithFormat:@"%@",error]
//                                                                                      delegate:nil
//                                                                             cancelButtonTitle:@"OK"
//                                                                             otherButtonTitles:nil, nil];
//                                       [alert show];
//                                       break;
//                                   }
//                                   default:
//                                       break;
//                               }
//                           }
//                 ];
//            }
//        }
//    }
//    else if (actionSheet == editSheet_)
//    {
//        if (0 == buttonIndex)
//        {
//            // 编辑帖子
//            [self performSelector:@selector(editNotes:) withObject:entity_ afterDelay:0.5f];
//        }else if (1 == buttonIndex)
//        {
//
//            // 删除帖子
//            [self deleteNote:entity_];
//            [dataSouceArr_ removeObject:entity_];
//            [tableView_ reloadData];
//        }
//    }
//}

//编辑已经存在的帖子
- (void)editNotes:(NoteListEntity *)entity
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"DynamicStoryboard" bundle:nil];
    PublishDynamicViewController *vc = [sb instantiateViewControllerWithIdentifier:@"PublishDynamicViewController"];
    vc.editEntity = entity;
    __weak ContentNewCell *selfWeak = self;
    if ([[KeepAppBox viewController:self] isKindOfClass:[DynamicViewController class]])
    {
        //编辑成功 回调
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
- (IBAction)zanClick:(id)sender {
    
    socketModel.delegate = self;
    zanBtnn = sender;
    //点赞动画
//    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
//    animation.values = @[@1.4, @1.0];
//    animation.duration = 0.3;
//    animation.calculationMode = kCAAnimationCubic;
//    [zanBtn.layer addAnimation:animation forKey:@"transform.scale"];
    
    if ([entity_.isPraise isEqualToString:@"1"])
    {
        [self cancelPraiseNote:entity_];
        entity_.isPraise = @"0";
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
        [self praiseNote:entity_];
        entity_.isPraise = @"1";
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
}

#pragma mark - 评论相关
- (IBAction)commentClick:(id)sender {
    
    if (messageToolView)
    {
        //能够进这里的 就是详情动态了
        messageToolView.hidden = NO;
        messageToolView.commentType = @"2";
        messageToolView.commentId = entity_.circle_id;
        messageToolView.byCommId = nil;
//        messageToolView.messageInputTextView.placeHolder = [NSString stringWithFormat:@"回复%@:",entity_.user_name];
        messageToolView.messageInputTextView.placeHolder = @"评论";
        [messageToolView.messageInputTextView becomeFirstResponder];
    }else
    {
        
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"DynamicStoryboard" bundle:nil];
        DynamicNewDetailViewController *detailVC = [sb instantiateViewControllerWithIdentifier:@"DynamicNewDetailViewController"];
        detailVC.entityid = entity_.noteId;
        detailVC.isFromComment = YES;
        //后加的 以后需要请求详情
        detailVC.noteListEntity = entity_;
        [NFUserEntity shareInstance].isPicImageDynamic = YES;
//        [[KeepAppBox viewController:self].navigationController pushViewController:detailVC animated:NO];
        
        
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        DynamicViewController *currentVC = (DynamicViewController *)[NFMyManage getCurrentVCFrom:rootViewController];
//        currentVC.messageToolView.commentType = @"2";
//        currentVC.messageToolView.commentId = entity_.circle_id;
//        //评论动态 回复id为nil
//        currentVC.messageToolView.byCommId = @"";
//        currentVC.messageToolView.isFromHome = NO;
//        currentVC.messageToolView.messageInputTextView.placeHolder = [NSString stringWithFormat:@"回复%@:",entity_.user_name];
        currentVC.selectCommentIndexpath = indexPath_;
        [currentVC.messageToolView.messageInputTextView becomeFirstResponder];
        
    }
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

//布局相关 主要用于文字高度自适应
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

-(void)setModel:(NoteListEntity *)model{
    //    [self initSocket];
    //    [self setup];
    //    entity_ = model;
    //    messageToolView.commentId = entity_.circle_id;
    //    [headImageView ShowHeadImageWithUrlStr:entity_.photo withUerId:entity_.user_id completion:nil];
    //    zanCountLab.text = [NSString stringWithFormat:@"%@次赞",entity_.praiseCount];
    //    NSMutableArray *arr = [@[] mutableCopy];
    //    BOOL isFromLocal = NO;
    //\当为预览过来时 传过来的是一个字点 里面的健值对的值是image
    //    if ([[entity_.photoList firstObject] isKindOfClass:[NSDictionary class]]) {
    //        for (NSDictionary *dic in entity_.photoList)
    //        {
    //            if ([[dic objectForKey:@"bigPicPath"]isKindOfClass:[UIImage class]])
    //            {
    //                isFromLocal = YES;
    //            }
    //            [arr addObject:[dic objectForKey:@"bigPicPath"]];
    //        }
    //    }
    //当arr 数目大于0 为预览过来的
    //    if (arr.count > 0) {
    //        [picView setPictureArr:arr isFromLocal:isFromLocal];
    //    }else{
    //        [picView setPictureArr:entity_.photoList isFromLocal:isFromLocal];
    //    }
    
    //    NSString *address;
    //    NSString *city;
    //    if (entity_.relAddress == nil)
    //    {
    //        address = @"";
    //    }else
    //    {
    //        address = [NSString stringWithFormat:@"·%@",entity_.relAddress];
    //    }
    //
    //    if ([entity_.isUpdate isEqualToString:@"1"])
    //    {
    //        city = @"·已编辑";
    //    }else
    //    {
    //        city = @"";
    //    }
    //    timeCityLab.text = [NSString stringWithFormat:@"%@%@%@",entity_.post_time,city,address];
    //    //判断是否隐藏编辑按钮
    //    //    if ([entity_.user_id isEqualToString:[NFUserEntity shareInstance].userId]) {
    //    //        _editBtn.hidden = NO;
    //    //    }else
    //    //    {
    //    //        _editBtn.hidden = YES;
    //    //    }
    //    if (entity_.fkid.length == 0)
    //    {
    //        connectBtn.hidden = YES;
    //    }else
    //    {
    //        [connectBtn addTarget:self action:@selector(goAct) forControlEvents:UIControlEventTouchUpInside];
    //        [connectBtn setTitle:entity_.actName forState:UIControlStateNormal];
    //    }
    //    if ([entity_.isPraise isEqualToString:@"1"])
    //    {
    //        [self.zanBtn setTitleColor:TheColor_BlueColor forState:UIControlStateNormal];
    //        [self.zanBtn setImage:[UIImage imageNamed:@"dynaminc-zan"] forState:UIControlStateNormal];
    //    }else
    //    {
    //        [self.zanBtn setTitleColor:[UIColor colorMainTextColor] forState:UIControlStateNormal];
    //        [self.zanBtn setImage:[UIImage imageNamed:@"dynamic_noZan"] forState:UIControlStateNormal];
    //    }
    //    nickNameLab.text = entity_.user_name;
    //    //根据bool值判断是否展示全部详情
    //    if (entity_.isExetend)
    //    {
    //        contentLabel.sd_layout.maxHeightIs(MAXFLOAT);
    //        [_showMoreBtn setTitle:@"收起" forState:UIControlStateNormal];
    //    }
    //    else
    //    {
    //        contentLabel.sd_layout.maxHeightIs(maxContentLabelHeight);
    //        [_showMoreBtn setTitle:@"展开" forState:UIControlStateNormal];
    //    }
    //    contentLabel.text = entity_.circle_content;
    //    [self needShowMoreBtn];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
