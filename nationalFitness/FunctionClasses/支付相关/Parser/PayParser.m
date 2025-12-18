
//
//  PayParser.m
//  nationalFitness
//
//  Created by joe on 2019/11/15.
//  Copyright © 2019年 chenglong. All rights reserved.
//

#import "PayParser.h"

@implementation PayParser


#pragma mark - 开户
+(id)openAccountManagerParser:(NSData *)data{
    NSDictionary * bodyDic = [self gotDataNoKeyParser:data];
    if (bodyDic) {
        
        return bodyDic;
    }
    return nil;
}



@end
