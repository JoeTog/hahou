//
//  RecordMoneyEntity.h
//  nationalFitness
//
//  Created by joe on 2019/12/10.
//  Copyright © 2019年 chenglong. All rights reserved.
//

#import "NFBaseEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface RecordMoneyEntity : NFBaseEntity


@property(nonatomic,strong)NSString *redId;

@property(nonatomic,strong)NSString *groupId;

@property(nonatomic,strong)NSString *titleDsc;

@property(nonatomic,strong)NSString *time;


@property(nonatomic)BOOL IsPin;//是否是拼手气

@property(nonatomic,strong)NSString *account;


@property(nonatomic,strong)NSString *detail;


@end

NS_ASSUME_NONNULL_END
