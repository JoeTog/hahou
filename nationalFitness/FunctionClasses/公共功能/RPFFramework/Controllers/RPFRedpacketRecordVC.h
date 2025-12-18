//
//  RPFRedpacketRecordVC.h
//  NIM
//
//  Created by King on 2019/2/23.
//  Copyright © 2019年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVProgressHUD.h"

#import "NFHeadImageView.h"

#import "Masonry.h"

#import "RedRecordTableViewCell.h"

#import "NoMoreCellTableViewCell.h"


#import "RPFRedpacketDetailVC.h"



NS_ASSUME_NONNULL_BEGIN

@interface RPFRedpacketRecordVC : UIViewController

@property(nonatomic,strong)UITableView * tableView;

@property(nonatomic,strong)UIImageView * headImgView;

@property(nonatomic,strong)NSMutableArray * dataArray;


//--------------
@property(nonatomic, copy)NSString * userId;
@property(nonatomic, copy)NSString * userName;
@property(nonatomic, copy)NSString * userHeadUrl;
@property(nonatomic, copy)NSString * wishContent;
@property(nonatomic, copy)NSString * redpacketId;
@property(nonatomic, copy)NSString * thirdToken;
@property(nonatomic, assign)BOOL isGroup;
@property(nonatomic, copy)NSString * appkey;
@property(nonatomic, copy)NSString * groupId;

@property(nonatomic,strong) NSDictionary * dataDict;

@end

NS_ASSUME_NONNULL_END
