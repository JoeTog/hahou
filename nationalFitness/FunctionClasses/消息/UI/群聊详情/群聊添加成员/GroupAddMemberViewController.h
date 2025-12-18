//
//  GroupAddMemberViewController.h
//  nationalFitness
//  群聊添加成员。 群聊删除成员。  创建群聊、 转发给某人
//  Created by Joe on 2017/7/13.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "NFbaseViewController.h"
#import "addFrienfViewController.h"
#import "SocketModel.h"
#import "SocketRequest.h"
#import "AppDelegate.h"
#import "GroupAddMemberTableViewCell.h"
#import "Masonry.h"
#import "FMDBService.h"
#import "GroupListViewController.h"

#import "MBProgressHUD+NHAdd.h"
#import "FMDBService.h"

#import "ZJContact.h"


typedef void(^FinishAddMember)(NSArray *memberArr);

typedef void(^ReduceMemberSuccess)(BOOL ret);


typedef NS_ENUM(NSInteger){
    SourceTypeFromSingleChat    = 0<<0, //来自单聊 【创建新的群聊】
    SourceTypeFromGroupChatAdd    = 1<<0, //来自群聊 【添加成员】
    SourceTypeFromGroupCreate    = 2<<0, //来自群聊菜单 【创建新的群聊】
    SourceTypeFromChatListRight    = 3<<0, //来自会话列表右下角
    SourceTypeFromGroupChatReduce    = 4<<0, //来自群聊 【删除成员】
    SourceTypeFromGroupChatAite    = 5<<0, //来自群聊 【@群成员】
    SourceTypeFromRecommendCard    = 6<<0, //来自 单聊 发送名片
    SourceTypeFromRecommendGroupCard    = 7<<0, //来自 群聊 发送名片
    
    
}SourceType;



@interface GroupAddMemberViewController : NFbaseViewController

//懒加载
@property (copy, nonatomic) NSMutableDictionary *parms;    //懒加载

@property (nonatomic, strong) FMDBService  *fmdbServicee;


//添加成员代码块
@property(nonatomic,copy)FinishAddMember adddMember;

-(void)finishAddMemberAndReturnL:(FinishAddMember )addmember;

//删除成员代码块
@property(nonatomic,copy)ReduceMemberSuccess redeceMember;

-(void)reduceMemberSuccess:(ReduceMemberSuccess )reducemember;

//type 
@property(nonatomic,assign)SourceType SourceType;

//是否需要加载更多群成员
@property (nonatomic) BOOL IsNeedLoadMore;


//已经存在于 群聊的数组
@property(nonatomic,copy)NSArray *alreadlyExistMemberArr;


//已存在群组实体
@property(nonatomic,strong)GroupCreateSuccessEntity *groupCreateSEntity;

//当为群组添加成员 这里传入一个存在的群组id
@property(nonatomic,copy)NSString *existGroupId;



//yes 来自转发 在这里转发到某些人
@property (nonatomic) BOOL fromType;

//和谁聊天的
@property (strong, nonatomic) NSString *chatingName;
//转发消息类型 0文字 1图片 2语音
@property (nonatomic,strong) NSString *contentType;
//转发内容
@property (strong, nonatomic) NSString *forwardContent;
//转发的消息实体
@property (strong, nonatomic) UUMessageFrame *forwardUUMessageFrame;




//选择联系人 发送名片
//单聊详情
@property (nonatomic, strong) ZJContact *chatContact;

//群聊详情 有了
//@property(nonatomic,strong)GroupCreateSuccessEntity *groupCreateSEntity;





@end
