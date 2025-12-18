//
//  RedParser.h
//  nationalFitness
//
//  Created by joe on 2019/12/10.
//  Copyright © 2019年 chenglong. All rights reserved.
//

#import "NFBaseParser.h"
#import "RecordMoneyEntity.h"

#import "ChatModel.h"

#import "RedAbountEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface RedParser : NFBaseParser


//零钱记录
+ (id)MoneyRecordManagerParser:(NSData *)data;

#pragma mark - 账单明细
+ (id)BillListManagerParser:(NSDictionary *)data;

//提现记录
+ (id)tixianRecodManagerParser:(NSDictionary *)data;

@end

NS_ASSUME_NONNULL_END




 


