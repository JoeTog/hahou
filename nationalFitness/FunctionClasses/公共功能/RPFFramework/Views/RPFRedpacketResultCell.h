//
//  RPFRedpacketResultCell.h
//  NIM
//
//  Created by King on 2019/2/8.
//  Copyright © 2019年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface RPFRedpacketResultCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImgView;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *time;

@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;

@property (weak, nonatomic) IBOutlet UIButton *bestLuckBtn;

@property(nonatomic, copy) NSString * userId;
@property(nonatomic, copy) NSString * redpacketId;


+(instancetype)xibTableViewCell;
-(void)refreshData:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
