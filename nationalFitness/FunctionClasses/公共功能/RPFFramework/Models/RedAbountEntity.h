//
//  RedAbountEntity.h
//  nationalFitness
//
//  Created by joe on 2020/1/19.
//  Copyright © 2020年 chenglong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RedAbountEntity : NSObject



@end

@interface BillListEntity : NSObject

@property(nonatomic,strong)NSString *type;

@property(nonatomic,strong)NSString *headurl;

@property(nonatomic,strong)NSString *detail;

@property(nonatomic,strong)NSString *time;//时间戳
@property(nonatomic,strong)NSString *datetime;//具体日期

@property(nonatomic,strong)NSString *amount;

//read  unread
@property(nonatomic,strong)NSString *status;

//助手消息id
@property(nonatomic,strong)NSString *helpId;

@end









NS_ASSUME_NONNULL_END
