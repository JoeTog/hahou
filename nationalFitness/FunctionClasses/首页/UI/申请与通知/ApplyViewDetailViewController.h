//
//  ApplyViewDetailViewController.h
//  nationalFitness
//  申请与通知详情
//  Created by Joe on 2017/6/30.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "NFbaseViewController.h"
#import "MessageEntity.h"
#import "SocketModel.h"
#import "JsonModel.h"
#import "UIColor+RYChat.h"
#import "JQFMDB.h"
#import "FMDBService.h"

typedef void (^ReturnAddFriendBlock)(NSString *addFriend);


@interface ApplyViewDetailViewController : NFbaseViewController

//懒加载
@property (copy, nonatomic) NSMutableDictionary *parms;    //懒加载
@property (strong, nonatomic) FMDBService *fmdbServicee;


@property ( nonatomic) BOOL IsGroup;    //

@property (weak, nonatomic) IBOutlet UILabel *sendNameLabel;

@property(nonatomic,copy)ReturnAddFriendBlock addFriendBlock;

//好友添加 请求者实体
@property (nonatomic, strong) FriendAddListEntity *entity;

//暂时没用到代码块，因为数据是实时更新的 每次回去向服务器请求
-(void)ReturnAddFriendBlockk:(ReturnAddFriendBlock)block;








@end





