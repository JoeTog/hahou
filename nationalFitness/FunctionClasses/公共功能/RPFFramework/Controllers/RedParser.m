//
//  RedParser.m
//  nationalFitness
//
//  Created by joe on 2019/12/10.
//  Copyright © 2019年 chenglong. All rights reserved.
//


#import "RedParser.h"

@implementation RedParser





//零钱记录
+ (id)MoneyRecordManagerParser:(NSDictionary *)data{
    NSMutableArray *backArr = [@[] mutableCopy];
    NSMutableArray *lastBackArr = [@[] mutableCopy];
    if(!data){
        return @[];
    }
    NSArray *arr = [data objectForKey:@"list"];
    for (NSDictionary *dict in arr) {
        RecordMoneyEntity *entity = [RecordMoneyEntity new];
        ////detail time account
        if ([dict objectForKey:@"resp_desc"]) {
            entity.detail = [[dict objectForKey:@"resp_desc"] description];
        }else{
            entity.detail = @"充值成功";
        }
        if([dict objectForKey:@"createtime"]){
            entity.time = [[dict objectForKey:@"createtime"] description];
        }else if ([dict objectForKey:@"datetime"]){
            entity.time = [[dict objectForKey:@"datetime"] description];
        }
        entity.account = [NSString stringWithFormat:@"¥%@",[[dict objectForKey:@"tranAmt"] description]];
        
        [lastBackArr addObject:entity];
    }
    
    return @{@"allCount":[[data objectForKey:@"count"] description],@"arr":lastBackArr};
}

//提现记录
+ (id)tixianRecodManagerParser:(NSDictionary *)data{
    NSMutableArray *backArr = [@[] mutableCopy];
    NSMutableArray *lastBackArr = [@[] mutableCopy];
    if(!data){
        return @[];
    }
    NSArray *arr = [data objectForKey:@"list"];
    for (NSDictionary *dict in arr) {
        RecordMoneyEntity *entity = [RecordMoneyEntity new];
        ////detail time account
        if ([[[dict objectForKey:@"status"] description] isEqualToString:@"0"]) {
            entity.detail = @"等待中";
        }else if([[[dict objectForKey:@"status"] description] isEqualToString:@"1"]){
            entity.detail = @"提现成功";
        }else if([[[dict objectForKey:@"status"] description] isEqualToString:@"2"]){
            entity.detail = @"提现失败，请联系客服";
        }
        if([dict objectForKey:@"createtime"]){
            entity.time = [[dict objectForKey:@"createtime"] description];
        }else if ([dict objectForKey:@"datetime"]){
            entity.time = [[dict objectForKey:@"datetime"] description];
        }
        entity.account = [NSString stringWithFormat:@"¥%@",[[dict objectForKey:@"tranAmt"] description]];
        
        [lastBackArr addObject:entity];
    }
    
    return @{@"allCount":[[data objectForKey:@"count"] description],@"arr":lastBackArr};
}

#pragma mark - 账单明细
+ (id)BillListManagerParser:(NSDictionary *)data{
    NSMutableArray *backArr = [@[] mutableCopy];
    NSMutableArray *lastBackArr = [@[] mutableCopy];
    NSArray *arr = [data objectForKey:@"list"];
    for (NSDictionary *dict in arr) {
        BillListEntity *entity = [BillListEntity new];
        ////detail time account
        if ([dict objectForKey:@"describe"] && [dict objectForKey:@"type"]) {
            entity.type = [[dict objectForKey:@"type"] description];
            if ([[[dict objectForKey:@"type"] description] isEqualToString:@"1"]) {
                entity.detail = [NSString stringWithFormat:@"充值"];
                entity.headurl = @"充值提现";
                if ([dict objectForKey:@"money"]) {
                    entity.amount = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"money"] description]];
                }
                //18852399534
            }else if ([[[dict objectForKey:@"type"] description] isEqualToString:@"2"]){
                entity.detail = [NSString stringWithFormat:@"取现"];
                entity.headurl = @"充值提现";
                if ([dict objectForKey:@"money"]) {
                    entity.amount = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"money"] description]];
                }
            }else if ([[[dict objectForKey:@"type"] description] isEqualToString:@"3"]){
                if([dict objectForKey:@"userInfo"]){
                    entity.detail = [NSString stringWithFormat:@"多信红包-发给%@",[[[dict objectForKey:@"userInfo"] objectForKey:@"nickname"] description]];
                }else if([dict objectForKey:@"groupInfo"]){
                    entity.detail = [NSString stringWithFormat:@"多信红包-发出群红包"];
                }
                
                entity.headurl = @"多信红包";
                if ([dict objectForKey:@"money"]) {
                    entity.amount = [NSString stringWithFormat:@"-%@",[[dict objectForKey:@"money"] description]];
                }
            }else if ([[[dict objectForKey:@"type"] description] isEqualToString:@"4"]){
                NSDictionary *usertInfo =[dict objectForKey:@"userInfo"];
                entity.detail = [NSString stringWithFormat:@"多信红包-来自%@",[[usertInfo objectForKey:@"nickname"] description]];
                entity.headurl = @"多信红包";
                if ([dict objectForKey:@"money"]) {
                    entity.amount = [NSString stringWithFormat:@"+%@",[[dict objectForKey:@"money"] description]];
                }
            }else if ([[[dict objectForKey:@"type"] description] isEqualToString:@"5"]){
                entity.detail = [NSString stringWithFormat:@"多信红包-退款"];
                entity.headurl = @"多信红包";
                if ([dict objectForKey:@"money"]) {
                    entity.amount = [NSString stringWithFormat:@"+%@",[[dict objectForKey:@"money"] description]];
                }
            }else if ([[[dict objectForKey:@"type"] description] isEqualToString:@"6"]){
                entity.detail = [NSString stringWithFormat:@"转账给%@",[[[dict objectForKey:@"userInfo"] objectForKey:@"nickname"] description]];
                entity.headurl = @"转账账单";
                if ([dict objectForKey:@"money"]) {
                    entity.amount = [NSString stringWithFormat:@"+%@",[[dict objectForKey:@"money"] description]];
                }
            }else if ([[[dict objectForKey:@"type"] description] isEqualToString:@"7"]){
                entity.detail = [NSString stringWithFormat:@"收到%@的转账",[[[dict objectForKey:@"userInfo"] objectForKey:@"nickname"] description]];
                entity.headurl = @"转账账单";
                if ([dict objectForKey:@"money"]) {
                    entity.amount = [NSString stringWithFormat:@"+%@",[[dict objectForKey:@"money"] description]];
                }
            }
        }else{
            entity.detail = @"未知明细";
            entity.headurl = @"未知";
            if ([dict objectForKey:@"money"]) {
                entity.amount = [[dict objectForKey:@"money"] description];
            }
        }
        if ([dict objectForKey:@"time"] && ![[[dict objectForKey:@"time"] description] containsString:@"null"]) {
            entity.time = [[dict objectForKey:@"time"] description];
        }else{
            entity.datetime = [[dict objectForKey:@"datetime"] description];
        }
        entity.status = [[dict objectForKey:@"status"] description];
        [lastBackArr addObject:entity];
    }
    
    return @{@"allCount":[[data objectForKey:@"count"] description],@"arr":lastBackArr};
}





@end
