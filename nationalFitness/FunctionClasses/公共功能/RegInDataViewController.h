//
//  RegInDataViewController.h
//  nationalFitness
//  填写年月
//  Created by 程long on 14-10-24.
//  Copyright (c) 2014年 chenglong. All rights reserved.
//

#import "NFbaseViewController.h"

@protocol RegInDataViewControllerDelegate <NSObject>

-(void)sendDateValue:(NSString *)value;

@end

@interface RegInDataViewController : NFbaseViewController

/**
 *  是否来着设置界面，默认为否
 */
@property (nonatomic) BOOL isFromSet;

// 0 来自培训信息界面
@property(nonatomic,assign)int fromType;


@property(weak,nonatomic)id<RegInDataViewControllerDelegate> delegate;

@end
