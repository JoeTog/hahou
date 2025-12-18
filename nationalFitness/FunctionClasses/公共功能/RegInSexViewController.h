//
//  RegInSexViewController.h
//  nationalFitness
//  填写性别
//  Created by 程long on 14-10-24.
//  Copyright (c) 2014年 chenglong. All rights reserved.
//

#import "NFbaseViewController.h"


@protocol RegInSexViewControllerDelegate <NSObject>

-(void)sendSexValue:(NFSex)value;

@end


@interface RegInSexViewController : NFbaseViewController

/**
 *  是否来着设置界面，默认为否
 */
@property (nonatomic) BOOL isFromSet;

@property(weak,nonatomic)id<RegInSexViewControllerDelegate> delegate;

// 0 来自培训信息界面
@property(nonatomic,assign)int fromType;

@end
