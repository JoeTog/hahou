//
//  GroupChatAllMemberCollectionViewController.h
//  nationalFitness
//全体成员劣币噢啊
//  Created by Joe on 2017/8/12.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupMemberCollectionViewCell.h"
#import "GroupEditCollectionViewCell.h"
#import "GroupAddMemberViewController.h"
#import "ZJContact.h"
#import "headCollectionReusableView.h"
#import "LWWeChatActionSheet.h"
#import "SocketRequest.h"
#import "AddFriendOrGroupdetailViewController.h"

#import "SocketModel.h"
#import "FMDBService.h"
#import "JQFMDB.h"


@interface GroupChatAllMemberCollectionViewController : UICollectionViewController

//群组聊天 联系人数组
@property(nonatomic,copy)NSArray *memberArr;


@property(nonatomic,strong)GroupCreateSuccessEntity *groupCreateSEntity;

@property (nonatomic, strong) FMDBService  *fmdbServicee;




@end
