//
//  GroupDetailHeadTableViewCell.h
//  nationalFitness
//  群聊详情中的 成员 collectionview
//  Created by Joe on 2017/7/13.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupMemberCollectionViewCell.h"
#import "GroupEditCollectionViewCell.h"
#import "GroupAddMemberViewController.h"
#import "ZJContact.h"
#import "socketRequest.h"

#import "AddFriendOrGroupdetailViewController.h"

typedef void(^memberGroupClick)(NSIndexPath *index);

//删除成员成功代码块
typedef void(^ReduceMemberSuccessCell)(BOOL ret);
//
typedef void (^ReturnClickAddMemberBlock)(void);

typedef void (^ReturnClickReduceMemberBlock)(void);


@interface GroupDetailHeadTableViewCell : UITableViewCell<UICollectionViewDataSource,UICollectionViewDelegate>

//群组聊天 联系人数组
@property(nonatomic,copy)NSArray *memberArr;

//通讯录中 有谁在这个群里面 挑出来
@property(nonatomic,copy)NSArray *existMemberArr;


//已存在群组实体
@property(nonatomic,strong)GroupCreateSuccessEntity *groupCreateSEntity;

//ret 是否为admin。管理员可以踢人
+(CGFloat)heightForCellWithData:(NSArray *)data IsCreator:(BOOL)ret;

//返回点击某个群组成员
@property(nonatomic,copy)memberGroupClick groupClick;
-(void)returnMemberGroupClick:(memberGroupClick)block;

//删除成员 成功后代码块
@property(nonatomic,copy)ReduceMemberSuccessCell redeceMember;
-(void)reduceMemberSuccess:(ReduceMemberSuccessCell )reducemember;


//添加 add成员代码块
@property(nonatomic,copy)ReturnClickAddMemberBlock addClickMember;
-(void)ReturnClickAddMemberBlock:(ReturnClickAddMemberBlock )addClickMember;


//删除成员代码块
@property(nonatomic,copy)ReturnClickReduceMemberBlock reduceClickMember;
-(void)ReturnClickReduceMemberBlock:(ReturnClickReduceMemberBlock )reduceClickMember;

@end
