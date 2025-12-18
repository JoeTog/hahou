//
//  SingleChatDetailTableViewController.h
//  nationalFitness
//
//  Created by Joe on 2017/7/13.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupAddMemberViewController.h"
#import "MessageChatViewController.h"
#import "PersonalInfoChangeViewController.h"
#import "Masonry.h"
#import "JQFMDB.h"
#import "UIColor+RYChat.h"
#import "MessageChatManage.h"
#import "NFTableViewController.h"
#import "OpinionRequestViewController.h"
#import "OpinionRequestViewController.h"
#import "VagueSearchViewController.h"

#import "SocketRequest.h"



typedef void (^ReturnSingleNameEditBlock)(NSString *enitedName);
//是否清除了缓存
typedef void (^ReturnIsDeleteBlock)(BOOL IsDelete);

@interface SingleChatDetailTableViewController : NFTableViewController

//懒加载
@property (strong, nonatomic) NFMyManage *myManage;    //懒加载 fmdbServicee
//懒加载
@property (copy, nonatomic) NSMutableDictionary *parms;    //懒加载
@property (nonatomic, strong) FMDBService  *fmdbServicee;


@property (nonatomic) BOOL IsFromCard;    


@property(nonatomic,copy)ReturnSingleNameEditBlock returnSingleNameBlock;

@property(nonatomic,copy)ReturnIsDeleteBlock returnDeleteBlock;

-(void)returnEditedName:(ReturnSingleNameEditBlock)block;

-(void)returnDelete:(ReturnIsDeleteBlock)block;

//一键设置字颜色
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;

@property (weak, nonatomic) IBOutlet UILabel *secLabel;

@property (weak, nonatomic) IBOutlet UILabel *thirdLaberl;


@property (weak, nonatomic) IBOutlet UILabel *forthLabel;

@property (weak, nonatomic) IBOutlet UILabel *fifthLabel;

@property (weak, nonatomic) IBOutlet UILabel *sixthLabel;

@property (weak, nonatomic) IBOutlet UILabel *seventhLabel;

@property (weak, nonatomic) IBOutlet UILabel *eightLabel;

@property (weak, nonatomic) IBOutlet UILabel *nineLabel;


//单人聊天实体 MessageChatListEntity 弃用
//@property (nonatomic, strong) MessageChatListEntity *singleEntity;

//单人聊天实体
@property (nonatomic, strong) ZJContact *singleContactEntity;

//会话id  或 好友id 【从会话列表进来 或 从联系人进来】
@property(nonatomic,strong)NSString *conversationId;






@end
