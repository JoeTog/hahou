//
//  ReplyDetailCommentsCell.m
//  newTestUe
//
//  Created by liumac on 15/12/18.
//  Copyright © 2015年 程龙. All rights reserved.
//

#import "ReplyDetailCommentsCell.h"
#import "NFHeadImageView.h"
#import "NFDynamicManager.h"

#define ContentCellHeight 50

@implementation ReplyDetailCommentsCell
{
    __weak IBOutlet UIButton *zanBtn;
    __weak IBOutlet UILabel *zanCount;
    __weak IBOutlet UILabel *timeLab;
    __weak IBOutlet NFHeadImageView *headIcon;
    __weak IBOutlet UILabel *contentLab;
    __weak IBOutlet UILabel *nickName;
    
    commentEntity *entity_;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setTextStr:(commentEntity *)entity
{
    entity_ = entity;
    contentLab.text = entity.replyContent;
    nickName.text = entity.replyNickName;
    [headIcon ShowHeadImageWithUrlStr:entity.replyBigPicPath withUerId:entity.replyUserId completion:nil];
    timeLab.text = entity.commDate;
    zanCount.text = [NSString stringWithFormat:@"%@",entity.praNum];
    [zanBtn addTarget:self action:@selector(zanClick:) forControlEvents:UIControlEventTouchUpInside];
    if ([entity.praFlag isEqualToString:@"0"])
    {
        zanCount.textColor = [UIColor colorWithRed:215.0/255 green:55.0/255 blue:58.0/255 alpha:1];
        [zanBtn setImage:[UIImage imageNamed:@"dynaminc-zan"] forState:UIControlStateNormal];
    }else
    {
        zanCount.textColor = [UIColor lightGrayColor];
        [zanBtn setImage:[UIImage imageNamed:@"dynamic_noZan"] forState:UIControlStateNormal];
    }
}
//根据文字的长度适配cell的高度
+ (CGFloat)getContentCellHeight:(NSString  *)str
{
    UILabel *disHeightLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 134.f, 0.0f)];
    [disHeightLab setNumberOfLines:0];
    disHeightLab.font = [UIFont systemFontOfSize:15.0];
    disHeightLab.text = str;
    [disHeightLab sizeToFit];
    if (disHeightLab.frame.size.height <= 18)
    {
        return 65;
    }
    return ContentCellHeight + disHeightLab.frame.size.height;
}

- (void)zanClick:(UIButton *)btn
{
    if ([entity_.praFlag isEqualToString:@"1"])
    {
        [self praiseNote:entity_];
        entity_.praFlag = @"0";
        NSInteger count = [entity_.praNum integerValue] + 1;
        if (count <= 0)
        {
            count = 0;
        }
        entity_.praNum = [NSString stringWithFormat:@"%ld",(long)count];
        zanCount.text = [NSString stringWithFormat:@"%@",entity_.praNum];
        zanCount.textColor = [UIColor colorWithRed:215.0/255 green:55.0/255 blue:58.0/255 alpha:1];
        [btn setImage:[UIImage imageNamed:@"dynaminc-zan"] forState:UIControlStateNormal];
    }else
    {
        [self cancelPraiseNote:entity_];
        entity_.praFlag = @"1";
        NSInteger count = [entity_.praNum integerValue] - 1;
        if (count <= 0)
        {
            count = 0;
        }
        entity_.praNum = [NSString stringWithFormat:@"%ld",(long)count];
        zanCount.text = [NSString stringWithFormat:@"%@",entity_.praNum];
        zanCount.textColor = [UIColor lightGrayColor];
        [btn setImage:[UIImage imageNamed:@"dynamic_noZan"] forState:UIControlStateNormal];
    }
}

- (void)praiseNote:(commentEntity *)entity
{
    NSMutableDictionary *sendDic = [@{} mutableCopy];
    
    [sendDic setObject:@"4" forKey:@"praiseType"];
    
    [sendDic setObject:entity.replyId?entity.replyId:@"" forKey:@"fkId"];
    
    [sendDic setObject:@"0" forKey:@"isReturnValue"];
    
    [NFDynamicManager execute:@selector(priseNoteManager) target:self callback:@selector(praiseNoteCallback:) args:sendDic,nil];
}

- (void)cancelPraiseNote:(commentEntity *)entity
{
    NSMutableDictionary *sendDic = [@{} mutableCopy];
    
    [sendDic setObject:@"4" forKey:@"praiseType"];
    
    [sendDic setObject:entity.replyId?entity.replyId:@"" forKey:@"fkId"];
    
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



@end
