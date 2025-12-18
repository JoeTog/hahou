//
//  RedSocketModel.m
//  nationalFitness
//
//  Created by joe on 2019/8/20.
//  Copyright © 2019年 chenglong. All rights reserved.
//

#import "RedSocketModel.h"

#import "SRWebSocket.h"
#import "JsonModel.h"
#import "JQFMDB.h"


@implementation RedSocketModel


+(instancetype)share
{
    static dispatch_once_t onceToken;
    static RedSocketModel * instance=nil;
    dispatch_once(&onceToken,^{
        instance=[[self alloc]init];
        
    });
    return instance;
}





-(void)aaaccc{
    
    
    
    
    
    
}


@end


