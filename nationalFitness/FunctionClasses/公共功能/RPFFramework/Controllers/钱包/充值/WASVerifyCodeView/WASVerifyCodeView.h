//
//  WASVerifyCodeView.h
//  WASVerifyCodeView
//
//  Created by luofeiyu on 2016/12/9.
//  Copyright © 2016年 wangshuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef void(^VerifyCodeBlock)(NSString* code);

@interface WASVerifyCodeView : NSObject
- (void)layoutContentViewsOnSuperview:(UIView *)view;
+ (void)showVerifyCodeViewOnView:(UIView *)view accountId:(NSString *)accountId verifyCodeBlock:(VerifyCodeBlock)block;
+ (void)dismissVerifyCodeViewOnView;
+ (void)refreshVerifyCode;

@end
