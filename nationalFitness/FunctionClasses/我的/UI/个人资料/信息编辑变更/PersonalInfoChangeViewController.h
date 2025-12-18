//
//  PersonalInfoChangeViewController.h
//  nationalFitness
//
//  Created by Joe on 2017/7/14.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "NFbaseViewController.h"
#import "MKPAlertView.h"

typedef NS_ENUM(NSInteger){
    EditNameType    = 0<<0, //编辑昵称
    EditTypeAccount    = 1<<0,//编辑账号
    EditTypePersonalSingature    = 2<<0,//编辑个性签名
    EditTypeBeiZhu      = 3<<0,//编辑备注
    EditTypeGroupName      = 4<<0,//群聊名称修改 //群聊我的昵称修改
    EditTypeInGroupName      = 4<<0,//群聊名称修改 //群聊我的昵称修改
    EditTypeGroupMineName      = 5<<0,
    EditTypeArea      = 6<<0, //地区
    EditTypeSex      = 7<<0 ,//性别
    EditTypeHeadPic      = 8<<0 , //头像
    EditTypeGroupMessage      = 9<<0 //群公告
    
}EditType;
//添加type后 需要更改确定按钮点击事件

typedef void(^returnInfo)(NSString *info ,EditType type);

@interface PersonalInfoChangeViewController : NFbaseViewController

//ChatMessageType
@property(nonatomic,assign)EditType editType;
//当前默认的值
@property(nonatomic,strong)NSString *currentText;

@property(nonatomic,strong)returnInfo backBlock;

-(void)returnInfoBlock:(returnInfo )backBlock ;


//是否来自群聊
@property(nonatomic)BOOL fromType;

//群公告 是否 不允许编辑
@property(nonatomic)BOOL ISNotCanEdit;


@end
