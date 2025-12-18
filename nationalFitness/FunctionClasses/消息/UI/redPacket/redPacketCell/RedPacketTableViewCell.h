//
//  RedPacketTableViewCell.h
//  nationalFitness
//
//  Created by joe on 2017/12/12.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UUMessageFrame.h"
#import "UUMessage.h"




typedef void (^ReturnDeleteBlock)(void);



@interface RedPacketTableViewCell : UITableViewCell



@property (nonatomic, strong) UUMessageFrame *messageFrame;

//标题 【转账就是金额】
@property (weak, nonatomic) IBOutlet UILabel *redtitleLabel;



//领取红包【转账就是备注】
@property (weak, nonatomic) IBOutlet UILabel *lingquHongBaoLabel;


//手势
@property (weak, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;



@property (weak, nonatomic) IBOutlet UILongPressGestureRecognizer *redLongClick;

@property (weak, nonatomic) IBOutlet UIImageView *hbbackImageV;


@property (weak, nonatomic) IBOutlet UILabel *headTimeLabel;


@property (weak, nonatomic) IBOutlet UILabel *timeLabel;



//多信红包
@property (weak, nonatomic) IBOutlet UILabel *duoxinRedLabel;


//点击删除
@property(nonatomic,copy)ReturnDeleteBlock returnDeleteBlock;
-(void)returnDelete:(ReturnDeleteBlock)block;






@end
