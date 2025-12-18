//
//  RPFSearchFriendVC.h
//  NIM
//
//  Created by King on 2019/3/5.
//  Copyright © 2019年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <NIMSDK/NIMSDK.h>

NS_ASSUME_NONNULL_BEGIN

@class NTESGroupedContacts;

@interface RPFSearchFriendVC : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong)NTESGroupedContacts *contacts;
@end

NS_ASSUME_NONNULL_END
