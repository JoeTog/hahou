//
//  PayParser.h
//  nationalFitness
//
//  Created by joe on 2019/11/15.
//  Copyright © 2019年 chenglong. All rights reserved.
//

#import "NFBaseParser.h"

NS_ASSUME_NONNULL_BEGIN

@interface PayParser : NFBaseParser


#pragma mark - 开户
+(id)openAccountManagerParser:(NSData *)data;





@end

NS_ASSUME_NONNULL_END
