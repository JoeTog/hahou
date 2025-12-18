//
//  ZJContactDetailTableViewController.h
//  nationalFitness
//  点击联系人 详情界面 查看头像、聊天
//  Created by Joe on 2017/8/8.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NFShowPictureView.h"
#import "HDPictureShowViewController.h"
#import "ZJContact.h"
#import "NFHeadImageView.h"
#import "NFTableViewController.h"




typedef void(^clickPopOrCameraOrShoucang)(int index);

@interface ZJContactDetailTableViewController : NFTableViewController


//备注或者原始昵称
@property (weak, nonatomic) IBOutlet UIButton *nameEditBtn;


//用户名，如果有备注 则加上(原始昵称)
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;



//聊天按钮
@property (weak, nonatomic) IBOutlet UIButton *freeChatBtn;
//聊天文字
@property (weak, nonatomic) IBOutlet UILabel *freeChatTextLabel;


//0返回、1相册、2收藏
@property(nonatomic,copy)clickPopOrCameraOrShoucang clickWhich;

-(void)clickWhichIndex:(clickPopOrCameraOrShoucang)block;

//头像 在 ZJContactViewController 和 GroupChatAllMemberCollectionViewController
@property(nonatomic,strong)NFHeadImageView *nfHeadImageV;


@property(nonatomic,strong)ZJContact *contant;

//来自哪里 联系人 还是 群聊  0联系人 1群聊 2单聊
@property(nonatomic,strong)NSString *SourceFrom;


//群组中 查看成员详情n 右上角菜单按钮，管理员有权限进行操作
@property(nonatomic,strong)GroupCreateSuccessEntity *groupCreateSEntity;
//ZJContact *contant; ,对传入的成员进行判断



@end
