


//
//  RedPacketTableViewCell.m
//  nationalFitness
//
//  Created by joe on 2017/12/12.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "RedPacketTableViewCell.h"
#import "LWWeChatActionSheet.h"

@implementation RedPacketTableViewCell{
    
    __weak IBOutlet NSLayoutConstraint *lingquConstantWidth;
    
    
    
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    
    [self.hbbackImageV setHighlightedImage:[UIImage imageNamed:@"bg_from_hongbaoSelected"]];
    
    lingquConstantWidth.constant = 100 + kPLUSIX_SCALE_X(70);
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
    [self.redLongClick addTarget:self action:@selector(clickRedImageLong)];
    
    
    
    
}

-(void)setMessageFrame:(UUMessageFrame *)messageFrame{
    
    if (messageFrame.message.type == UUMessageTypeRed) {
        self.redtitleLabel.text = messageFrame.message.strContent;
        self.timeLabel.hidden = YES;
        if ([messageFrame.message.redIsTouched isEqualToString:@"1"]) {
            self.hbbackImageV.image = [UIImage imageNamed:@"bg_from_hongbaoSelected"];
        }
    }else if (messageFrame.message.type == UUMessageTypeTransfer || (messageFrame.message.redpacketString.length > 0 && messageFrame.message.type == UUMessageTypeRedRobRecord)){
        
        self.redtitleLabel.text = [self removeFloatAllZeroByString:messageFrame.message.priceAccount];
        if(messageFrame.message.strContent.length>0 && ![messageFrame.message.strContent isEqualToString:@"说明"]){
            self.lingquHongBaoLabel.text = messageFrame.message.strContent;
        }else{
            if (messageFrame.message.nickName.length > 6) {
                self.lingquHongBaoLabel.text = [NSString stringWithFormat:@"转账给%@",messageFrame.message.nickName];
            }else{
                self.lingquHongBaoLabel.text = [NSString stringWithFormat:@"转账给%@",messageFrame.message.nickName];
            }
        }
        
        self.duoxinRedLabel.text = @"   多信转账";
        
        if(messageFrame.message.type == UUMessageTypeRedRobRecord){
            self.hbbackImageV.image = [UIImage imageNamed:@"转账图标浅"];
            [self.hbbackImageV setHighlightedImage:[UIImage imageNamed:@"转账图标浅"]];
            self.lingquHongBaoLabel.text = @"已收款";
        }else{
            self.hbbackImageV.image = [UIImage imageNamed:@"转账图标深"];
            [self.hbbackImageV setHighlightedImage:[UIImage imageNamed:@"转账图标浅"]];
            if ([messageFrame.message.redIsTouched isEqualToString:@"1"]) {
                self.hbbackImageV.image = [UIImage imageNamed:@"转账图标浅"];
            }
        }
        
        
    }

    if (messageFrame.showTime) {
        self.timeLabel.hidden = NO;
        self.timeLabel.text = messageFrame.message.strTime;
    }
    
}

- (NSString*)removeFloatAllZeroByString:(NSString *)testNumber{
    NSString * outNumber = [NSString stringWithFormat:@"%@",@(testNumber.floatValue)];
    return outNumber;
}
    
-(void)clickRedImageLong{
    
    [self becomeFirstResponder];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    UIMenuItem * item1 = [[UIMenuItem alloc]initWithTitle:@"删除" action:@selector(myDelete)];
    [menu setMenuItems:@[item1]];
    menu.arrowDirection = UIMenuControllerArrowDefault;
    [menu setTargetRect:self.hbbackImageV.frame inView:self.hbbackImageV.superview];
    [menu setMenuVisible:YES animated:YES];
    
    
    
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


-(void)returnDelete:(ReturnDeleteBlock)block{
    if (self.returnDeleteBlock != block) {
        self.returnDeleteBlock = block;
    }
}





@end
