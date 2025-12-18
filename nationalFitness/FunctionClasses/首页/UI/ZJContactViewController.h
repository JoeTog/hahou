//
//  ViewController.h
//  ZJIndexContacts
//
//  Created by ZeroJ on 16/10/10.
//  Copyright © 2016年 ZeroJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApplyViewController.h"
#import "GroupListViewController.h"
#import "addFrienfViewController.h"
#import "NewHomeManager.h"
#import "MessageEntity.h"
#import "HCDTimer.h"
#import "AppDelegate.h"
//#import "SocketModel.h"
#import "Masonry.h"
#import "UIFont+RYChat.h"
#import "NFTabBarViewController.h"
#import "JQFMDB.h"
#import "UIColor+RYChat.h"
#import "ZJContactDetailTableViewController.h"
#import "FMLinkLabel.h"
#import "FriendSetTableViewController.h"
#import "SDAutoLayout.h"
#import "SocketRequest.h"

#import "DarkerTableViewController.h"



@interface ZJContactViewController : UIViewController

//懒加载
@property (strong, nonatomic) NFMyManage *myManage;    //懒加载 fmdbServicee
//懒加载
@property (copy, nonatomic) NSMutableDictionary *parms;    //懒加载

@property (nonatomic, strong) FMDBService  *fmdbServicee;


//@property (nonatomic) SocketRequest *socketRequest;


#pragma mark - 刷新函数
-(void)refresh;








@end






