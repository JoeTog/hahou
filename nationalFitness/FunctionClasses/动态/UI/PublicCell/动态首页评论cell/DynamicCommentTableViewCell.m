//
//  DynamicCommentTableViewCell.m
//  nationalFitness
//
//  Created by Joe on 2017/9/20.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "DynamicCommentTableViewCell.h"

@implementation DynamicCommentTableViewCell{
    
    //评论
    
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    
}

-(void)setModel:(NoteCommentEntity *)model{
    NSString *comment;
    if (model.replyToId.length > 0) {
//        comment = [NSString stringWithFormat:@"%@ 回复 %@:%@",model.user_nickName,model.replyToNickName,model.comment_content];
        comment = [NSString stringWithFormat:@"%@ 回复 %@:%@",model.user_nickName,model.replyToNickName?model.replyToNickName:model.replyToName,model.comment_content];
    }else{
        comment = [NSString stringWithFormat:@"%@:%@",model.user_nickName,model.comment_content];
    }
    self.commentLabel.text = comment;
    
    [self.commentLabel addClickText:model.user_nickName attributeds:@{NSForegroundColorAttributeName : UIColorFromRGB(0x2b5d93)} transmitBody:@"呵呵哒 被点击了" clickItemBlock:^(id transmitBody) {
    }];
    if (model.replyToId.length > 0) {
        [self.commentLabel addClickText:model.replyToName attributeds:@{NSForegroundColorAttributeName : UIColorFromRGB(0x2b5d93)} transmitBody:@"呵呵哒 被点击了" clickItemBlock:^(id transmitBody) {
        }];
    }
    UIView *superView = self.contentView;
    CGFloat margin = 15;
    self.commentLabel.sd_layout
    //    .widthIs(50)
    .topSpaceToView(superView, 3)
    .leftSpaceToView(superView, margin)
    .autoHeightRatio(0);
//    .rightSpaceToView(superView, margin);
    
    [self.commentLabel setSingleLineAutoResizeWithMaxWidth:SCREEN_WIDTH - margin *2];
    [self setupAutoHeightWithBottomView:self.commentLabel bottomMargin:3];
    
}

//根据文字的长度适配cell的高度 暂无用
+ (CGFloat)getContentCellHeight:(NoteCommentEntity  *)commentEntity seeingMore:(BOOL)seeingMore{
    
    UILabel *disHeightLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 10.f, 0.0f)];
    seeingMore = YES;
    if (seeingMore)
    {
        [disHeightLab setNumberOfLines:0];
    }
    else
    {
        [disHeightLab setNumberOfLines:2];
    }
    disHeightLab.font = [UIFont systemFontOfSize:14.0];
    NSString *comment;
    if (commentEntity.replyToId.length > 0) {
        comment = [NSString stringWithFormat:@"%@ 回复 %@:%@",commentEntity.user_name,commentEntity.replyToName,commentEntity.comment_content];
    }else{
        comment = [NSString stringWithFormat:@"%@：%@",commentEntity.user_name,commentEntity.comment_content];
    }
    disHeightLab.text = comment;
    [disHeightLab sizeToFit];
    
    return disHeightLab.frame.size.height + 6.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
