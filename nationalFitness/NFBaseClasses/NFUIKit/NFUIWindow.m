//
//  NFUIWindow.m
//  nationalFitness
//
//  Created by Joe on 2017/8/28.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "NFUIWindow.h"

@implementation NFUIWindow






+ (NFUIWindow *)shareInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] initWithFrame:[UIScreen mainScreen].bounds];
    });
    
    return instance;
}







@end
