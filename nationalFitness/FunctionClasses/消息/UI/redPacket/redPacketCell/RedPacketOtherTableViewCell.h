//
//  RedPacketOtherTableViewCell.h
//  nationalFitness
//
//  Created by joe on 2019/8/23.
//  Copyright © 2019年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NFHeadImageView.h"


#import "UUMessageFrame.h"
#import "UUMessage.h"

#import "LWWeChatActionSheet.h"

#import "UIImageView+WebCache.h"


typedef void (^ReturnDeleteBlock)(void);
typedef void (^ReturnheadViewLongPressBlock)(void);


NS_ASSUME_NONNULL_BEGIN

@interface RedPacketOtherTableViewCell : UITableViewCell


@property (nonatomic, strong) UUMessageFrame *messageFrame;

@property (weak, nonatomic) IBOutlet UILabel *redtitleLanel;


@property (weak, nonatomic) IBOutlet UIImageView *hbbackImageV;


@property (weak, nonatomic) IBOutlet NFHeadImageView *headImageV;



@property (weak, nonatomic) IBOutlet UILongPressGestureRecognizer *redLongPress;



@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UILabel *lingquhongbaoLabel;


@property (weak, nonatomic) IBOutlet UILabel *duoxinRedlabel;



//点击删除
@property(nonatomic,copy)ReturnDeleteBlock returnDeleteBlock;
-(void)returnDelete:(ReturnDeleteBlock)block;

//长按 对方头像 艾特某人
@property(nonatomic,copy)ReturnheadViewLongPressBlock returnLongBlock;
-(void)returnLong:(ReturnheadViewLongPressBlock)block;




@end

NS_ASSUME_NONNULL_END
