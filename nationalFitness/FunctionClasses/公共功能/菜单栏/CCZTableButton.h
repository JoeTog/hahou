//
//  CCZTableButton.h
//  CCZTableButton
//
//  Created by 金峰 on 2016/11/19.
//  Copyright © 2016年 金峰. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void (^AfterDismiss)(BOOL ret);

@interface CCZTableButton : UIView
@property (nonatomic, assign) CGFloat offsetXOfArrow;
@property (nonatomic, assign) BOOL wannaToClickTempToDissmiss;
//用于计算tableview高度
@property (nonatomic, assign) CGFloat topHeight;


//- (instancetype)initWithFrame:(CGRect)frame;

- (instancetype)initWithFrame:(CGRect)frame CellHeight:(CGFloat)height;

- (void)addItems:(NSArray <NSString *> *)itesName;
- (void)addItems:(NSArray <NSString *> *)itemsName exceptItem:(NSString *)itemName;
- (void)selectedAtIndexHandle:(void(^)(NSUInteger index, NSString *itemName))indexHandle;

- (void)show;
- (void)dismiss;
//当点击background 时 返回原界面
@property(nonatomic,copy)AfterDismiss afterDismissBlock;
-(void)AfterClickDismiss:(AfterDismiss)block;


@property(nonatomic,strong)UIColor *CellBackColor;
@property(nonatomic,strong)UIColor *CellTextColor;

@property(nonatomic,strong)NSArray *TitleImageArr;

//-(void)setCellBackColor:(UIColor *)backColor AndTextColor:(UIColor *)textColor;

@end
