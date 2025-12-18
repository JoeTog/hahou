//
//  ZJSearchResultController.h
//  ZJIndexContacts
//
//  Created by ZeroJ on 16/10/11.
//  Copyright © 2016年 ZeroJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageChatViewController.h"
#import "ZJContactViewController.h"
#import "ZJContact.h"

typedef void(^SelectContantJump)(ZJContact *contant);


@class ZJContact;

@interface ZJSearchResultController : UIViewController

@property (strong, nonatomic, readonly) UITableView *tableView;
// 设置数据, 设置内部会自动刷新tableView
@property (strong, nonatomic) NSArray<ZJContact *> *data;


@property(nonatomic,copy)SelectContantJump ContantJumpBlock;

-(void)SelectContantJumpBlock:(SelectContantJump)block;








@end









