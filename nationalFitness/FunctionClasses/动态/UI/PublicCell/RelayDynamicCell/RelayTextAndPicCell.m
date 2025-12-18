//
//  RelayTextAndPicCell.m
//  nationalFitness
//
//  Created by Joe on 2017/7/11.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "RelayTextAndPicCell.h"
#import "NFHeadImageView.h"
#import "NFShowImageView.h"
#import "NFDynamicEntity.h"
#import "NFDynamicManager.h"
#import "NFShowPictureView.h"
#import "DynamicViewController.h"

#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>


@implementation RelayTextAndPicCell{
   
    __weak IBOutlet NFShowImageView *secHeadImage;
    
    __weak IBOutlet UIButton *secConnectBtn;
    
    __weak IBOutlet UILabel *secNameLab;
    
    __weak IBOutlet UILabel *time;
    
    __weak IBOutlet UILabel *secConnectLab;
    
    __weak IBOutlet UIView *radiusView;
    
    __weak IBOutlet UILabel *zanCountLab;
    
    
    __weak IBOutlet UILabel *commentLabel;//评论条数
    
    
    __weak IBOutlet UILabel *fristConnectLab;
    
    __weak IBOutlet UILabel *timeCityLab;
    
    __weak IBOutlet UIButton *fristConnectBtn;
    
    __weak IBOutlet UILabel *fristName;
    
    __weak IBOutlet NFShowPictureView *picView;
    
    __weak IBOutlet NFHeadImageView *fristHeadImage;
    
    
    __weak IBOutlet NSLayoutConstraint *radiusLayout;
    
    __weak IBOutlet NSLayoutConstraint *secLayout;
    
    // 从列表页传过来
    NoteListEntity *entity_;
    UITableView *tableView_;
    NSMutableArray *dataSouceArr_;
    UIActionSheet *shareSheet_;
    UIActionSheet *editSheet_;
    NFCommentInputView *messageToolView;
    NSIndexPath *indexPath_;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    ViewBorderRadius(radiusView, 3, 1, [UIColor groupTableViewBackgroundColor]);
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.zanBtn setTitleColor:[UIColor colorMainTextColor] forState:(UIControlStateNormal)];
    [self.commentBtn setTitleColor:[UIColor colorMainTextColor] forState:(UIControlStateNormal)];
    [self.shareBtn setTitleColor:[UIColor colorMainTextColor] forState:(UIControlStateNormal)];
    [self.qubaoBtn setTitleColor:[UIColor colorMainTextColor] forState:(UIControlStateNormal)];
}


- (void)showCellWithEntity:(id)entity withDataSource:(NSMutableArray *)dataArr commentView:(NFCommentInputView *)commentView withTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    entity_ = (NoteListEntity *)entity;
    tableView_ = tableView;
    dataSouceArr_ = dataArr;
    messageToolView = commentView;
    indexPath_ = indexPath;
    
    zanCountLab.text = [NSString stringWithFormat:@"%@次赞",entity_.praiseCount];
    commentLabel.text = [NSString stringWithFormat:@"｜%ld条评论",entity_.commentArr.count];
    
    NSMutableArray *arr = [@[] mutableCopy];
    BOOL isFromLocal = NO;
    for (NSDictionary *dic in entity_.noteEntity.photoList)
    {
        if ([[dic objectForKey:@"bigPicPath"]isKindOfClass:[UIImage class]])
        {
            isFromLocal = YES;
        }
        [arr addObject:[dic objectForKey:@"bigPicPath"]];
    }
    [picView setPictureArr:arr isFromLocal:isFromLocal];
    
    
    fristName.text = entity_.nickname;
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
    time.text = [NSString stringWithFormat:@"%@%@%@",entity_.redDate,city,address];
    
    [fristHeadImage ShowHeadImageWithUrlStr:entity_.smallPicPath withUerId:entity_.relUserId completion:nil];
    if (entity_.fkid.length > 0)
    {
        fristConnectBtn.hidden = NO;
        [fristConnectBtn addTarget:self action:@selector(goAct) forControlEvents:UIControlEventTouchUpInside];
        [fristConnectBtn setTitle:entity_.actName forState:UIControlStateNormal];
    }else
    {
        fristConnectBtn.hidden = YES;
    }
    fristConnectLab.text = entity_.noteContent;
    ViewRadius(secHeadImage, CGRectGetHeight(secHeadImage.frame)/2.0);
    [secHeadImage ShowImageWithUrlStr:entity_.noteEntity.userPicPath completion:nil];
    secNameLab.text = entity_.noteEntity.nickName;
    
    if (entity_.noteEntity.fkid.length > 0)
    {
        secConnectBtn.hidden = NO;
        [secConnectBtn setTitle:entity_.noteEntity.actName forState:UIControlStateNormal];
    }else
    {
        secConnectBtn.hidden = YES;
    }
    
    if ([entity_.isFlag isEqualToString:@"0"])
    {
        _editBtn.hidden = NO;
    }else
    {
        _editBtn.hidden = YES;
    }
    
    if ([entity_.isPraise isEqualToString:@"1"])
    {
        [self.zanBtn setTitleColor:[UIColor colorWithRed:215.0/255 green:55.0/255 blue:58.0/255 alpha:1] forState:UIControlStateNormal];
        
        [self.zanBtn setImage:[UIImage imageNamed:@"dynaminc-zan"] forState:UIControlStateNormal];
    }else
    {
        [self.zanBtn setTitleColor:[UIColor colorMainTextColor] forState:UIControlStateNormal];
        [self.zanBtn setImage:[UIImage imageNamed:@"dynamic_noZan"] forState:UIControlStateNormal];
        
    }
    secConnectLab.text = entity_.noteEntity.noteContent;
    //根据bool值判断是否展示全部详情
    if (entity_.isExetend)
    {
        [fristConnectLab setNumberOfLines:0];
        [_showMoreBtn setTitle:@"收起" forState:UIControlStateNormal];
    }
    else
    {
        [fristConnectLab setNumberOfLines:2];
        [_showMoreBtn setTitle:@"展开" forState:UIControlStateNormal];
    }
    [self needShowMoreBtn];
    
    secConnectLab.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goNext)];
    [secConnectLab addGestureRecognizer:tap];
}

- (void)goNext
{
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"DynamicStoryboard" bundle:nil];
    DynamicNewDetailViewController *detailVC = [sb instantiateViewControllerWithIdentifier:@"DynamicNewDetailViewController"];
    detailVC.entityid = entity_.noteEntity.noteId;
    [[KeepAppBox viewController:self].navigationController pushViewController:detailVC animated:YES];
}

+ (CGFloat)getContentCellHeight:(NSString  *)str seeingMore:(BOOL)seeingMore
{
    UILabel *disHeightLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 10.f, 0.0f)];
    if (seeingMore)
    {
        [disHeightLab setNumberOfLines:0];
    }
    else
    {
        [disHeightLab setNumberOfLines:2];
    }
    disHeightLab.font = [UIFont systemFontOfSize:15.0];
    disHeightLab.text = str;
    [disHeightLab sizeToFit];
    UILabel *Lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 10.f, 0.0f)];
    [Lab setNumberOfLines:0];
    Lab.font = [UIFont systemFontOfSize:15.0];
    Lab.text = str;
    [Lab sizeToFit];
    CGFloat height;
    if (Lab.frame.size.height > 36)
    {
        height = 0;
    }
    else
    {
        height = 20;
    }
//    return RelayTextAndPicCellHeight - 20 +disHeightLab.frame.size.height - height;
    if (seeingMore) {
        NSLog(@"%lf",RelayTextAndPicCellHeight - 20 +disHeightLab.frame.size.height - height + 10);
        return RelayTextAndPicCellHeight - 20 +disHeightLab.frame.size.height - height + 10;
    }
    NSLog(@"%lf",RelayTextAndPicCellHeight - 18 +disHeightLab.frame.size.height - height);
    return RelayTextAndPicCellHeight - 18 +disHeightLab.frame.size.height - height;
}

- (void)needShowMoreBtn
{
    UILabel *disHeightLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 10.f, 0.0f)];
    [disHeightLab setNumberOfLines:0];
    disHeightLab.font = [UIFont systemFontOfSize:15.0];
    disHeightLab.text = entity_.noteContent;
    [disHeightLab sizeToFit];
    if (disHeightLab.frame.size.height >36)
    {
        _showMoreBtn.hidden = NO;
        secLayout.constant = 25;
        radiusLayout.constant = 20.f;
    }
    else
    {
        _showMoreBtn.hidden = YES;
        secLayout.constant = 7;
        radiusLayout.constant = 4.f;
    }
}

#pragma mark - 帖子操作相关
-(void)goAct
{
    
}


- (IBAction)showMoreDis:(id)sender {
    entity_.isExetend = !entity_.isExetend;
    [tableView_ beginUpdates];
    [tableView_ reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath_.row inSection:indexPath_.section]] withRowAnimation:UITableViewRowAnimationFade];
    [tableView_ endUpdates];
}

- (IBAction)editNote:(id)sender {
    editSheet_ = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"编辑帖子",@"删除帖子", nil];
    [editSheet_ showInView:[KeepAppBox viewController:self].view];
}
- (void)deleteNote:(NoteListEntity *)entity
{
    NSMutableDictionary *sendDic = [@{} mutableCopy];
    [sendDic setObject:entity.noteId?entity.noteId:@"" forKey:@"noteId"];
    [NFDynamicManager execute:@selector(deleteNoteManager) target:self callback:@selector(deleteNoteCallback:) args:sendDic,nil];
}

- (void)deleteNoteCallback:(id)data
{
    // 不做处理
}

#pragma mark - 举报相关
- (IBAction)jubaoAbout:(id)sender {
}


#pragma mark - 分享相关
- (IBAction)shareClick:(id)sender {
    
    shareSheet_ = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"分享至密聊",@"分享给外部", nil];
    [shareSheet_ showInView:[KeepAppBox viewController:self].view];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == shareSheet_)
    {
        if (0 == buttonIndex)
        {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"DynamicStoryboard" bundle:nil];
            PublishDynamicViewController *vc = [sb instantiateViewControllerWithIdentifier:@"PublishDynamicViewController"];
            vc.shareType = ShareTypeOffNote;
            vc.noteEntity = entity_;
            if ([[KeepAppBox viewController:self] isKindOfClass:[DynamicViewController class]])
            {
                __weak RelayTextAndPicCell *selfWeak = self;
                vc.successBlock = ^(BOOL success){
                    DynamicViewController *vcdy = (DynamicViewController *)[KeepAppBox viewController:selfWeak];
                    [vcdy getNoteList];
                };
            }
            [[KeepAppBox viewController:self].navigationController pushViewController:vc animated:YES];
        }
        else if(1 == buttonIndex)
        {
            //1、创建分享参数
            NSArray* imageArray = @[[UIImage imageNamed:@"图片"]];
            //（注意：图片必须要在Xcode左边目录里面，名称必须要传正确，如果要分享网络图片，可以这样传iamge参数 images:@[@"http://mob.com/Assets/images/logo.png?v=20150320"]）
            if (imageArray) {
                
                NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
                [shareParams SSDKSetupShareParamsByText:@"www.baidu.com"
                                                 images:nil
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
    else if (actionSheet == editSheet_)
    {
        if (0 == buttonIndex)
        {
            // 编辑帖子
            [self performSelector:@selector(editNotes:) withObject:entity_ afterDelay:0.5f];
        }else if (1 == buttonIndex)
        {
            // 删除帖子
            [self deleteNote:entity_];
            [dataSouceArr_ removeObject:entity_];
            [tableView_ reloadData];
        }
    }
    
}

- (void)editNotes:(NoteListEntity *)entity
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"DynamicStoryboard" bundle:nil];
    PublishDynamicViewController *vc = [sb instantiateViewControllerWithIdentifier:@"PublishDynamicViewController"];
    vc.editEntity = entity;
    __weak RelayTextAndPicCell *selfWeak = self;
    if ([[KeepAppBox viewController:self] isKindOfClass:[DynamicViewController class]])
    {
        vc.successBlock = ^(BOOL success){
            DynamicViewController *vcdy = (DynamicViewController *)[KeepAppBox viewController:selfWeak];
            [vcdy getNoteList];
        };
    }
    
    [[KeepAppBox viewController:self].navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - 点赞相关
- (IBAction)zanClick:(id)sender {
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
        [sender setTitleColor:[UIColor colorMainTextColor] forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"dynamic_noZan"] forState:UIControlStateNormal];
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
        [sender setTitleColor:[UIColor colorWithRed:215.0/255 green:55.0/255 blue:58.0/255 alpha:1] forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"dynaminc-zan"] forState:UIControlStateNormal];
    }
    [tableView_ reloadData];
}

- (void)praiseNote:(NoteListEntity *)entity
{
    NSMutableDictionary *sendDic = [@{} mutableCopy];
    
    [sendDic setObject:@"2" forKey:@"praiseType"];
    
    [sendDic setObject:entity.noteId?entity.noteId:@"" forKey:@"fkId"];
    
    [sendDic setObject:@"0" forKey:@"isReturnValue"];
    
    [NFDynamicManager execute:@selector(priseNoteManager) target:self callback:@selector(praiseNoteCallback:) args:sendDic,nil];
}

- (void)cancelPraiseNote:(NoteListEntity *)entity
{
    NSMutableDictionary *sendDic = [@{} mutableCopy];
    
    [sendDic setObject:@"2" forKey:@"praiseType"];
    
    [sendDic setObject:entity.noteId?entity.noteId:@"" forKey:@"fkId"];
    
    [NFDynamicManager execute:@selector(cancelPriseNoteManager) target:self callback:@selector(cancelPraiseNoteCallback:) args:sendDic,nil];
}
- (void)praiseNoteCallback:(id)data
{
    // 不做处理
}

- (void)cancelPraiseNoteCallback:(id)data
{
    // 不做处理
}

#pragma mark - 评论相关
- (IBAction)commentClick:(id)sender {
    if (messageToolView)
    {
        messageToolView.hidden = NO;
        messageToolView.commentType = @"2";
        messageToolView.commentId = entity_.noteId;
        [messageToolView.messageInputTextView becomeFirstResponder];
    }else
    {
        
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"DynamicStoryboard" bundle:nil];
        DynamicNewDetailViewController *detailVC = [sb instantiateViewControllerWithIdentifier:@"DynamicNewDetailViewController"];
        detailVC.entityid = entity_.noteId;
        detailVC.isFromComment = YES;
        [[KeepAppBox viewController:self].navigationController pushViewController:detailVC animated:NO];
        

    }
}







- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
