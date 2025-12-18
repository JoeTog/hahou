//
//  SendTableViewController.h
//  nationalFitness
//
//  Created by joe on 2020/6/24.
//  Copyright © 2020 chenglong. All rights reserved.
//

#import "NFTableViewController.h"

#import "ZJContact.h"


NS_ASSUME_NONNULL_BEGIN

@interface SendTableViewController : NFTableViewController


@property(nonatomic, copy)NSDictionary * redDetailDict;


@property(nonatomic, copy)NSString * redpacketId;


@property(nonatomic, copy)NSString * type;


@property(nonatomic, assign)BOOL isSingleMe;//是否是单聊q并且是我发的红包

@property(nonatomic, assign)BOOL isOverDue;//是否过期


@property (nonatomic, strong) ZJContact *singleContactEntity;




@end

NS_ASSUME_NONNULL_END
