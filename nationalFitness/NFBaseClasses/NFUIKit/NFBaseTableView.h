//
//  NFBaseTableView.h
//  nationalFitness
//
//  Created by liumac on 15/7/4.
//  Copyright (c) 2015年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NFNothingView.h"

#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

@interface NFBaseTableView : UITableView

//是否添加空白界面显示效果， 默认不显示
@property (assign, nonatomic) BOOL isNeed;

// 显示什么都没有
- (void)showNone;
- (void)showNoneWithImage:(NSString *)imageName WithTitle:(NSString *)title;

//蹄片距离上面多少距离
- (void)showNoneWithImage:(NSString *)imageName WithTitle:(NSString *)title AndHeight:(CGFloat)height;
- (void)showNoneWithImage:(NSString *)imageName WithTitle:(NSString *)title TableviewWidth:(CGFloat)width AndHeight:(CGFloat)height;

// 针对特定界面
- (void)showNoneInChatWithImage:(NSString *)imageName WithTitle:(NSString *)title;

// 移除什么都没有
- (void)removeNone;

@end
