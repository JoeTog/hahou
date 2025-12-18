//
//  NFNothingView.h
//  nationalFitness
//
//  Created by liumac on 15/7/4.
//  Copyright (c) 2015年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NFNothingView : UIView

// 定制特定的什么都没有界面
- (id)initWithFrame:(CGRect)frame WithTitle:(NSString *)title WithImageName:(NSString *)imageName;

// 针对特定界面  不用管
- (id)initWithFrame:(CGRect)frame WithTitle:(NSString *)title WithImageNam:(NSString *)imageName;

@end
