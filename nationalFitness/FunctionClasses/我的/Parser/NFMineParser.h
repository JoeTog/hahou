//
//  NFMineParser.h
//  nationalFitness
//
//  Created by 程long on 14-12-17.
//  Copyright (c) 2014年 chenglong. All rights reserved.
//

#import "NFBaseParser.h"

@interface NFMineParser : NFBaseParser

#pragma mark - 请求个人信息详情 1012
+(id)PersonalInfoDetailParser:(NSDictionary *)data;

//设置个人信息
+(id)PersonalInfoSetParser:(NSDictionary *)data;




@end
