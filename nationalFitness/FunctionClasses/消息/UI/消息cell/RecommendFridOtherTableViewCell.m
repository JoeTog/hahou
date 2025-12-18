//
//  RecommendFridOtherTableViewCell.m
//  nationalFitness
//
//  Created by joe on 2019/12/30.
//  Copyright © 2019年 chenglong. All rights reserved.
//

#import "RecommendFridOtherTableViewCell.h"




@implementation RecommendFridOtherTableViewCell{
    
    
    
    
    __weak IBOutlet NSLayoutConstraint *backBackConstant;
    
    
    
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    
    backBackConstant.constant = SCREEN_WIDTH/5;
    
    
    
    
    
    
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressClick:)];
    longPress.minimumPressDuration= 0.5;
    [self.headImageV addGestureRecognizer:longPress];
    
   // [self.longPressRecommend addTarget:self action:@selector(clickRecommendImageLong)];
    
    
    UILongPressGestureRecognizer *longPressRecommend = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(clickRecommendImageLong)];
    longPressRecommend.minimumPressDuration= 1;
    [self.backImageV addGestureRecognizer:longPressRecommend];
    
}


-(void)clickRecommendImageLong{
    
    [self becomeFirstResponder];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    UIMenuItem * item1 = [[UIMenuItem alloc]initWithTitle:@"删除" action:@selector(myDelete)];
    [menu setMenuItems:@[item1]];
    menu.arrowDirection = UIMenuControllerArrowDefault;
    [menu setTargetRect:self.backImageV.frame inView:self.backImageV.superview];
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
