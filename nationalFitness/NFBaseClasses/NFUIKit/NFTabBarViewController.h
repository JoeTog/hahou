//
//  NFTabBarViewController.h
//  nationalFitness
//
//  Created by 程long on 14-11-4.
//  Copyright (c) 2014年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NFTabBarViewController : UITabBarController


#pragma mark 显示自定义角标
/**
 *  在自定义UITabBarButton角标,必须在viewDidAppear:方法中调用,让其和系统的角标的中心重合.
 *
 *  @param itemNum 要把角标显示在第几个控制器上面
 *  @param width   角标的直径,默认为5.0
 */
//- (void)showBadgeInController:(NSInteger)itemNum width:(CGFloat)width;
    
#pragma mark 移除自定义角标
/**
 *  移除自定义UITabBarButton角标.
 *
 *  @param itemNum 要把第几个控制器上面的角标移除
 */
//- (void)removeBadgeInController:(NSInteger)itemNum;

@end
