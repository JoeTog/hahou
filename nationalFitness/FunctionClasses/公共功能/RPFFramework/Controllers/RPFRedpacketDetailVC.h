//
//  RPFRedpacketDetailVC.h
//  NIM
//
//  Created by King on 2019/2/8.
//  Copyright © 2019年 Netease. All rights reserved.
//

#import "BaseRPFViewController.h"



#import "SocketModel.h"
#import "SocketRequest.h"




NS_ASSUME_NONNULL_BEGIN

typedef void(^CheckRedPacketResultBlock)();


@interface RPFRedpacketDetailVC : BaseRPFViewController

@property(nonatomic,strong)UITableView * tableView;

@property(nonatomic,strong)UIImageView * headImgView;

@property(nonatomic,strong)NSMutableArray * dataArray;


//--------------
@property(nonatomic, copy)NSString * userId;
@property(nonatomic, copy)NSString * userName;
@property(nonatomic, copy)NSString * userHeadUrl;
@property(nonatomic, copy)NSString * wishContent;
@property(nonatomic, copy)NSString * redpacketId;
@property(nonatomic, copy)NSString * thirdToken;
@property(nonatomic, assign)BOOL isGroup;
@property(nonatomic, copy)NSString * appkey;
@property(nonatomic, copy)NSString * groupId;

@property(nonatomic, copy)NSDictionary * redDetailDict;


@property(nonatomic, assign)BOOL isSingleMe;//是否是单聊q并且是我发的红包 

@property(nonatomic, assign)BOOL isOverDue;//是否过期


@end

NS_ASSUME_NONNULL_END
