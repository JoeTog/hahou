//
//  MKPAlertView.h
//  自定义提示弹出框
//
//  Created by 图合天驷 on 16/12/20.
//  Copyright © 2016年 毛凯平. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AlertResult)(NSInteger index);

@interface MKPAlertView : UIView

/**  */
@property(nonatomic,copy) AlertResult resultIndex;

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message sureBtn:(NSString *)sureTitle cancleBtn:(NSString *)cancleTitle;

-(void)showMKPAlertView;

@end
