//
//  RPFRedpacketRecordCell.h
//  NIM
//
//  Created by King on 2019/2/23.
//  Copyright © 2019年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RPFRedpacketRecordCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *userNameBtn;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;

@property(nonatomic,copy) NSString * userId;
@property(nonatomic,copy) NSString * redpacketId;


+(instancetype)xibTableViewCell;

-(void)refreshData:(NSDictionary *)dic type:(BOOL)type;

@end

NS_ASSUME_NONNULL_END
