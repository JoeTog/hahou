//
//  FindCommentsCell.m
//  newTestUe
//
//  Created by liumac on 15/12/18.
//  Copyright © 2015年 程龙. All rights reserved.
//

#import "FindCommentsCell.h"
#import "NFHeadImageView.h"
#import "FMLinkLabel.h"
//#import "ReplyCommentsViewController.h"
#import "NFDynamicManager.h"

#define ContentCellHeight 50

@implementation FindCommentsCell
{
    __weak IBOutlet NFHeadImageView *replyHeadimage;
    __weak IBOutlet UILabel *repyContent;
    __weak IBOutlet UILabel *replyNickName;
    __weak IBOutlet UIButton *zanBtn;
    __weak IBOutlet UILabel *zanCount;
    
    __weak IBOutlet UILabel *timeLab;
    __weak IBOutlet NFHeadImageView *headIcon;
    __weak IBOutlet UILabel *contentLab;
    
    __weak IBOutlet FMLinkLabel *nickName;
    
    //回复的实体
//    commentEntity *entity_;
    NoteCommentEntity *entity_;
    NSString *fkId_;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setTextStr:(NoteCommentEntity *)entity withFkId:(NSString *)fkId
{
    entity_ = entity;
    
    fkId_ = fkId;
//    zanCount.text = [NSString stringWithFormat:@"%@",entity.praNum];
    timeLab.text = entity.comment_date;
    if (entity.replyToId.length > 0) {
        if (entity.user_name.length == 0) {
            entity.user_name = @" ";
        }
        if (entity.replyToName.length == 0) {
            entity.replyToName = @" ";
        }
        NSString *name = [NSString stringWithFormat:@"%@ 回复 %@",entity.user_nickName,entity.replyToNickName];
        nickName.text = name;
        nickName.textColor = [UIColor colorWithRed:0.17 green:0.55 blue:0.87 alpha:1.00];
        nickName.font = [UIFont boldSystemFontOfSize:13];
        nickName.font = [UIFont systemFontOfSize:15];
        nickName.textAlignment = NSTextAlignmentLeft;
        nickName.textColor = [UIColor blackColor];
        [nickName addClickText:entity_.user_nickName attributeds:@{NSForegroundColorAttributeName : UIColorFromRGB(0x2b5d93)} transmitBody:@"呵呵哒 被点击了" clickItemBlock:^(id transmitBody) {
            NSLog(@"评论人A%@",entity_.user_name);
        }];
        [nickName addClickText:entity_.replyToNickName attributeds:@{NSForegroundColorAttributeName : UIColorFromRGB(0x2b5d93)} transmitBody:@"呵呵哒 被点击了" clickItemBlock:^(id transmitBody) {
            NSLog(@"评论人B%@",entity_.replyToName);
        }];
    }else{
        nickName.text = entity.user_nickName;
        nickName.textColor = [UIColor colorWithRed:0.17 green:0.55 blue:0.87 alpha:1.00];
        nickName.font = [UIFont boldSystemFontOfSize:13];
        nickName.font = [UIFont systemFontOfSize:15];
        nickName.textAlignment = NSTextAlignmentLeft;
        nickName.textColor = [UIColor blackColor];
        [nickName addClickText:[NSString stringWithFormat:@"%@",entity_.user_nickName] attributeds:@{NSForegroundColorAttributeName : UIColorFromRGB(0x2b5d93)} transmitBody:@"呵呵哒 被点击了" clickItemBlock:^(id transmitBody) {
            NSLog(@"评论人A%@",entity_.user_nickName);
        }];
    }
//    replyNickName.text = entity.replyNickName;
    replyNickName.text = entity.replyToNickName;
//    if ([entity.praFlag isEqualToString:@"0"])
//    {
//        zanCount.textColor = [UIColor colorWithRed:215.0/255 green:55.0/255 blue:58.0/255 alpha:1];
//        [zanBtn setImage:[UIImage imageNamed:@"dynaminc-zan"] forState:UIControlStateNormal];
//    }else
//    {
//        zanCount.textColor = [UIColor lightGrayColor];
//        [zanBtn setImage:[UIImage imageNamed:@"dynamic_noZan"] forState:UIControlStateNormal];
//    }
//    if (entity.replyId.length > 0)
//    {
//        repyContent.hidden = NO;
//        replyNickName.hidden = NO;
//        replyHeadimage.hidden = NO;
//        contentLab.text = entity.comment_content;
//        repyContent.text = entity.replyContent;
//        [headIcon ShowHeadImageWithUrlStr:entity.photo withUerId:nil completion:nil];
//        nickName.text = entity.user_name;
//        timeLab.text = entity.comment_date;
//        [replyHeadimage ShowHeadImageWithUrlStr:entity.photo withUerId:nil completion:nil];
////        replyNickName.text = entity.replyNickName;
//        replyNickName.text = entity.replyName;
//        
//    }else
//    {
        contentLab.text = entity.comment_content;
    [contentLab sizeToFit];
        [headIcon ShowHeadImageWithUrlStr:entity.photo withUerId:nil completion:nil];
        repyContent.hidden = YES;
        replyNickName.hidden = YES;
        replyHeadimage.hidden = YES;
//    }
}

//暂时没用到 都是走的上面有回复的 没有回复的就隐藏回复人
- (void)setContentStr:(commentEntity *)entity withFkId:(NSString *)fkId;
{
//    entity_ = entity;
//    fkId_ = fkId;
//    zanCount.text = [NSString stringWithFormat:@"%@",entity.praNum];
//    timeLab.text = entity.commDate;
//    nickName.text = entity.nickName;
//    if ([entity.praFlag isEqualToString:@"0"])
//    {
//        zanCount.textColor = [UIColor colorWithRed:215.0/255 green:55.0/255 blue:58.0/255 alpha:1];
//        [zanBtn setImage:[UIImage imageNamed:@"dynaminc-zan"] forState:UIControlStateNormal];
//    }else
//    {
//        zanCount.textColor = [UIColor lightGrayColor];
//        [zanBtn setImage:[UIImage imageNamed:@"dynamic_noZan"] forState:UIControlStateNormal];
//    }
//    [headIcon ShowHeadImageWithUrlStr:entity.bigPicpath withUerId:entity.commUserId completion:nil];
//    contentLab.text = entity.content;
//    repyContent.hidden = YES;
//    replyNickName.hidden = YES;
//    replyHeadimage.hidden = YES;
}

// 回复
- (IBAction)replyClick:(id)sender
{
    if (fkId_)
    {
        ReplyCommentsViewController *vc = [[ReplyCommentsViewController alloc]init];
        vc.commId = entity_.comment_id;
        vc.noteId = fkId_;
        [[KeepAppBox viewController:self].navigationController pushViewController:vc animated:NO];
    }else
    {
        if (self.input)
        {
            self.input(YES);
        }
    }
}

#pragma mark - 评论点赞
- (IBAction)zanClick:(id)sender
{
    UIButton *btn = (UIButton *)sender;
//    if ([entity_.praFlag isEqualToString:@"1"])
//    {
//        [self praiseNote:entity_];
//        entity_.praFlag = @"0";
//        NSInteger count = [entity_.praNum integerValue] + 1;
//        if (count <= 0)
//        {
//            count = 0;
//        }
//        entity_.praNum = [NSString stringWithFormat:@"%ld",(long)count];
//        zanCount.text = [NSString stringWithFormat:@"%@",entity_.praNum];
//        zanCount.textColor = [UIColor colorWithRed:215.0/255 green:55.0/255 blue:58.0/255 alpha:1];
//        [btn setImage:[UIImage imageNamed:@"dynaminc-zan"] forState:UIControlStateNormal];
//    }else
//    {
//        [self cancelPraiseNote:entity_];
//        entity_.praFlag = @"1";
//        NSInteger count = [entity_.praNum integerValue] - 1;
//        if (count <= 0)
//        {
//            count = 0;
//        }
//        entity_.praNum = [NSString stringWithFormat:@"%ld",(long)count];
//        zanCount.text = [NSString stringWithFormat:@"%@",entity_.praNum];
//        zanCount.textColor = [UIColor lightGrayColor];
//        [btn setImage:[UIImage imageNamed:@"dynamic_noZan"] forState:UIControlStateNormal];
//    }
}

- (void)praiseNote:(commentEntity *)entity
{
    NSMutableDictionary *sendDic = [@{} mutableCopy];
    
    [sendDic setObject:@"4" forKey:@"praiseType"];
    
    [sendDic setObject:entity.commId?entity.commId:@"" forKey:@"fkId"];
    
    [sendDic setObject:@"0" forKey:@"isReturnValue"];
    
    [NFDynamicManager execute:@selector(priseNoteManager) target:self callback:@selector(praiseNoteCallback:) args:sendDic,nil];
}

- (void)cancelPraiseNote:(commentEntity *)entity
{
    NSMutableDictionary *sendDic = [@{} mutableCopy];
    
    [sendDic setObject:@"4" forKey:@"praiseType"];
    
    [sendDic setObject:entity.commId?entity.commId:@"" forKey:@"fkId"];
    
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

#pragma mark - end
//根据文字的长度适配cell的高度
+ (CGFloat)getContentCellHeight:(NoteCommentEntity *)entity
{
//    if (entity.replyId.length > 0)
//    {
//        CGFloat height_1;
//        CGFloat height_2;
//        UILabel *disHeightLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 119.f, 0.0f)];
//        [disHeightLab setNumberOfLines:0];
//        disHeightLab.font = [UIFont systemFontOfSize:15.0];
//            disHeightLab.text = entity.comment_content;
//        [disHeightLab sizeToFit];
//        if (disHeightLab.frame.size.height<=18)
//        {
//            height_1 = 65;
//        }else
//        {
//            height_1 = disHeightLab.frame.size.height + 65 - 18;
//        }
//        
//        UILabel *disHeightLab_1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 134.f, 0.0f)];
//        [disHeightLab_1 setNumberOfLines:0];
//        disHeightLab_1.font = [UIFont systemFontOfSize:15.0];
//        disHeightLab_1.text = entity.replyContent;
//        [disHeightLab_1 sizeToFit];
//        if (disHeightLab_1.frame.size.height <= 18)
//        {
//            height_2 = 50;
//        }else
//        {
//            height_2 = disHeightLab_1.frame.size.height + 50 - 18;
//        }
//        
//        return height_1 + height_2;
//        
//    }else
//    {
    
    
//        UILabel *disHeightLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 119.f, 0.0f)];
//        [disHeightLab setNumberOfLines:0];
//        disHeightLab.font = [UIFont systemFontOfSize:15.0];
//        disHeightLab.text = entity.comment_content;
//        [disHeightLab sizeToFit];
//    if (disHeightLab.frame.size.height <= 18)
//    {
//        return 65;
//    }
//return ContentCellHeight + disHeightLab.frame.size.height;
    
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15]};
        CGFloat height = [entity.comment_content boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 119.f, 2000) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size.height;
        if (height <= 18)
        {
            return 65;
        }
        
        return ContentCellHeight + height + 20;
//    }
}

+ (CGFloat)getContentCellHeightWithOutReply:(NoteCommentEntity *)entity
{
//    UILabel *disHeightLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 119.f, 0.0f)];
//    [disHeightLab setNumberOfLines:0];
//    disHeightLab.font = [UIFont systemFontOfSize:15.0];
//    disHeightLab.text = entity.content;
//    [disHeightLab sizeToFit];
//    if (disHeightLab.frame.size.height <= 18)
//    {
//        return 65;
//    }
//    return ContentCellHeight + disHeightLab.frame.size.height;
    return 0;
}


@end
