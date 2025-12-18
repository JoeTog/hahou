//
//  RelayOnlyTextCell.m
//  nationalFitness
//
//  Created by Joe on 2017/7/10.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "RelayOnlyTextCell.h"
#import "NFHeadImageView.h"
#import "NFDynamicEntity.h"

#import "NFDynamicManager.h"
#import "PublishDynamicViewController.h"
#import "DynamicNewDetailViewController.h"
#import "DynamicViewController.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>

#define RelayOnlyTextCellHeight 252

@implementation RelayOnlyTextCell{
    
    __weak IBOutlet NFHeadImageView *fristHeadImage;
    
    __weak IBOutlet UILabel *fristNameLab;
    
    __weak IBOutlet UIButton *fristConnectBtn;
    
    __weak IBOutlet UILabel *fristTimeLab;
    
    __weak IBOutlet UILabel *fristContentLab;
    
    __weak IBOutlet NSLayoutConstraint *secLayout;
    
    __weak IBOutlet UILabel *zanCountLab;
    
    __weak IBOutlet UILabel *commentLabel;//评论条数
    
    
    
    __weak IBOutlet NFHeadImageView *secHeadImage;
    
    __weak IBOutlet UILabel *sceNameLab;
    
    __weak IBOutlet UILabel *secContentLab;
    
    __weak IBOutlet UILabel *secTimeLab;
    
    __weak IBOutlet UIButton *secConnectBtn;
    
    __weak IBOutlet UIButton *goNextBtn;
    
    __weak IBOutlet NSLayoutConstraint *radiusLayout;
    
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
    ViewBorderRadius(goNextBtn, 3, 1, UIColorFromRGB(0xdedede));
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
    fristNameLab.text = entity_.nickname;
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
    fristTimeLab.text = [NSString stringWithFormat:@"%@%@%@",entity_.redDate,city,address];
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
    fristContentLab.text = entity_.noteContent;
    [secHeadImage ShowHeadImageWithUrlStr:entity_.noteEntity.userPicPath withUerId:nil completion:nil];
    sceNameLab.text = entity_.noteEntity.nickName;
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
    secContentLab.text = entity_.noteEntity.noteContent;
    //根据bool值判断是否展示全部详情
    if (entity_.isExetend)
    {
        [fristContentLab setNumberOfLines:0];
        [_showMoreBtn setTitle:@"收起" forState:UIControlStateNormal];
    }
    else
    {
        [fristContentLab setNumberOfLines:2];
        [_showMoreBtn setTitle:@"展开" forState:UIControlStateNormal];
    }
    [self needShowMoreBtn];
    
    secContentLab.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goNext)];
    [secContentLab addGestureRecognizer:tap];
    
    [goNextBtn addTarget:self action:@selector(goNext) forControlEvents:UIControlEventTouchUpInside];
}

- (void)goNext
{
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"DynamicStoryboard" bundle:nil];
    DynamicNewDetailViewController *detailVC = [sb instantiateViewControllerWithIdentifier:@"DynamicNewDetailViewController"];
    detailVC.entityid = entity_.noteEntity.noteId;
    [[KeepAppBox viewController:self].navigationController pushViewController:detailVC animated:YES];
}


//判断是否需要显示展开的按钮
- (void)needShowMoreBtn
{
    UILabel *disHeightLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 10.f, 0.0f)];
    [disHeightLab setNumberOfLines:0];
    disHeightLab.font = [UIFont systemFontOfSize:RelayOnlyTextCellFontSize];
    disHeightLab.text = entity_.noteContent;
    [disHeightLab sizeToFit];
    if (disHeightLab.frame.size.height > 36)
    {
        _showMoreBtn.hidden = NO;
        secLayout.constant = 22;
        radiusLayout.constant = 18;
    }
    else
    {
        _showMoreBtn.hidden = YES;
        secLayout.constant = 7;
        radiusLayout.constant = 4;
    }
}

//根据文字的长度适配cell的高度
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
    disHeightLab.font = [UIFont systemFontOfSize:RelayOnlyTextCellFontSize];
    disHeightLab.text = str;
    [disHeightLab sizeToFit];
    
    UILabel *Lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 10.f, 0.0f)];
    [Lab setNumberOfLines:0];
    Lab.font = [UIFont systemFontOfSize:RelayOnlyTextCellFontSize];
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
//    if (seeingMore) {
//        
//        return RelayOnlyTextCellHeight - 20 +disHeightLab.frame.size.height - height + 10;
//    }
    return RelayOnlyTextCellHeight - 20 +disHeightLab.frame.size.height - height;
}

#pragma mark - 帖子操作相关

-(void)goAct{
    
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
                __weak RelayOnlyTextCell *selfWeak = self;
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
    __weak RelayOnlyTextCell *selfWeak = self;
    if ([[KeepAppBox viewController:self] isKindOfClass:[DynamicViewController class]])
    {
        vc.successBlock = ^(BOOL success){
            DynamicViewController *vcdy = (DynamicViewController *)[KeepAppBox viewController:selfWeak];
            [vcdy getNoteList];
        };
    }
    [[KeepAppBox viewController:self].navigationController pushViewController:vc animated:YES];
    
}

- (IBAction)zanClick:(id)sender {
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
