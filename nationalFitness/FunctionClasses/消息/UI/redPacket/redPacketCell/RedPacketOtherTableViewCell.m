

//
//  RedPacketOtherTableViewCell.m
//  nationalFitness
//
//  Created by joe on 2019/8/23.
//  Copyright © 2019年 chenglong. All rights reserved.
//

#import "RedPacketOtherTableViewCell.h"

@implementation RedPacketOtherTableViewCell{
    
    __weak IBOutlet NSLayoutConstraint *lingquLeadWidth;
    
    
    
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    
    [self.hbbackImageV setHighlightedImage:[UIImage imageNamed:@"bg_to_hongbaoSeleted"]];
    
    
    
    lingquLeadWidth.constant = 100 + kPLUSIX_SCALE_X(55);
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
    
    [self.redLongPress addTarget:self action:@selector(clickRedImageLong)];
    
    
}


-(void)setMessageFrame:(UUMessageFrame *)messageFrame{
    
    [self.headImageV sd_setImageWithURL:[NSURL URLWithString:messageFrame.message.strIcon] placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
    
    if (messageFrame.message.type == UUMessageTypeRed) {
        self.redtitleLanel.text = messageFrame.message.strContent;
        self.nickNameLabel.text = messageFrame.message.nickName;
        if ([messageFrame.message.redIsTouched isEqualToString:@"1"]) {
            self.hbbackImageV.image = [UIImage imageNamed:@"bg_from_hongbaoSelected"];
        }
    }else if (messageFrame.message.type == UUMessageTypeTransfer || (messageFrame.message.redpacketString.length > 0 && messageFrame.message.type == UUMessageTypeRedRobRecord)){
        self.nickNameLabel.hidden = YES;
        self.redtitleLanel.text = messageFrame.message.priceAccount;
        self.lingquhongbaoLabel.text = messageFrame.message.strContent.length>0 && ![messageFrame.message.strContent isEqualToString:@"说明"]?messageFrame.message.strContent:[NSString stringWithFormat:@"转账给%@",messageFrame.message.nickName];
        self.lingquhongbaoLabel.text = messageFrame.message.strContent.length>0 && ![messageFrame.message.strContent isEqualToString:@"说明"]?messageFrame.message.strContent:@"转账给你";
        self.duoxinRedlabel.text = @"   多信转账";
        if(messageFrame.message.type == UUMessageTypeRedRobRecord){
            self.hbbackImageV.image = [UIImage imageNamed:@"转账图标浅"];
            [self.hbbackImageV setHighlightedImage:[UIImage imageNamed:@"转账图标浅"]];
            self.lingquhongbaoLabel.text = @"已收款";
        }else{
            self.hbbackImageV.image = [UIImage imageNamed:@"转账图标深"];
            [self.hbbackImageV setHighlightedImage:[UIImage imageNamed:@"转账图标浅"]];
            if ([messageFrame.message.redIsTouched isEqualToString:@"1"]) {
                self.hbbackImageV.image = [UIImage imageNamed:@"转账图标浅"];
            }
        }
        
    }
    
    self.timeLabel.hidden = YES;
    if (messageFrame.showTime) {
        self.timeLabel.hidden = NO;
        self.timeLabel.text = messageFrame.message.strTime;
    }
    
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressClick:)];
    longPress.minimumPressDuration= 0.5;
    [self.headImageV addGestureRecognizer:longPress];
    
}

-(void)clickRedImageLong{
    
    [self becomeFirstResponder];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    UIMenuItem * item1 = [[UIMenuItem alloc]initWithTitle:@"删除" action:@selector(myDelete)];
    [menu setMenuItems:@[item1]];
    menu.arrowDirection = UIMenuControllerArrowDefault;
    [menu setTargetRect:self.hbbackImageV.frame inView:self.hbbackImageV.superview];
    [menu setMenuVisible:YES animated:YES];
    //
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    
    if (action == @selector(myDelete)) {
        return YES;
    }
    return NO;//隐藏系统默认的菜单项
    
}


- (BOOL)canBecomeFirstResponse
{
    return YES;
}

- (BOOL)canBecomeFirstResponder {
    
    return YES;
    
}


-(void)myDelete{
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


-(void)returnDelete:(ReturnDeleteBlock)block{
    if (self.returnDeleteBlock != block) {
        self.returnDeleteBlock = block;
    }
}

-(void)returnLong:(ReturnheadViewLongPressBlock)block{
    if (self.returnLongBlock != block) {
        self.returnLongBlock = block;
    }
}




@end
