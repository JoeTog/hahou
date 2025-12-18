//
//  PopView.h
//  nationalFitness
//
//  Created by 童杰 on 2016/12/19.
//  Copyright © 2016年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeFuncButtonView.h"
#import "NFbaseViewController.h"

#import "KaiNuoPopView.h"


// View 圆角
#define ViewRadius(View, Radius)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES]

//the status bar of the window after removing highly when equipment vertical screen
#define SCREEN_HEIGHT                   [[UIScreen mainScreen] bounds].size.height
//width of window when equipment vertical screen
#define SCREEN_WIDTH                    [[UIScreen mainScreen] bounds].size.width

//适配的宽度跟xib宽带的比例
#define kPLUS_SCALE_X(x)                 (x * (SCREEN_WIDTH/320))

//适配的宽度跟xib高带的比例
#define kPLUS_SCALE_Y(y)                 (y * (SCREEN_HEIGHT/568))

//typedef void(^ClickbackView)(BOOL ret);

@interface PopView : UIView<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>


//
@property(nonatomic,strong)void(^sure)(BOOL);

//
@property(nonatomic,strong)void(^sureSec)(BOOL);

//带tableview
@property(nonatomic,strong)void(^choseSure)(BOOL,NSInteger);

@property(nonatomic,strong)void(^clickCell)(NSInteger);


//带textfield
@property(nonatomic,strong)void(^inputText)(NSString *);

//首页功能按钮
@property(nonatomic,strong)void(^functionButtonindex)(NSInteger );



//点击背景灰色
//@property(nonatomic,strong)ClickbackView retureClickBackView;
//
//-(void)ClickBackViewEvent:(ClickbackView)retureEvent;

//带图片
//@property(nonatomic,retain)UIColor *messageColor;
//
//@property(nonatomic,retain)UIColor *sureColor;
//
//@property(nonatomic,retain)UIColor *cancelColor;
//
////不带图片
//@property(nonatomic,retain)UIColor *messageSecColor;
//
//@property(nonatomic,retain)UIColor *sureSecColor;
//
//@property(nonatomic,retain)UIColor *cancelSecColor;

#pragma mark - 带图片 属性设置
-(void)setMessageColor:(UIColor *)messageColor;

-(void)setSureColor:(UIColor *)sureColor;

-(void)setCancelColor:(UIColor *)cancelColor;

#pragma mark - 不带图片 属性设置
/**不带图片
 *设置标题颜色
 */
-(void)setSecTitleColor:(UIColor *)titleColor;
/**不带图片
 *设置标题字体位置
 */
-(void)setSecTitleAlient:(NSTextAlignment)titleAlignment;
/**不带图片
 *设置message颜色
 */
-(void)setSecMessageColor:(UIColor *)messageColor;
/**不带图片
 *设置确认按钮背景颜色
 */
-(void)setSecSureColor:(UIColor *)sureColor;
/**不带图片
 *设置确认按钮文字
 */
-(void)setSecSureBtnText:(NSString *)title;

/**不带图片
 *设置确认头背景颜色
 */
-(void)setSecTitleBackColor:(UIColor *)sureColor;
/**不带图片
 *设置message 居左中右  默认为左，0位居中 1为居右
 */
-(void)setSecMessageLabelTextAlignment:(NSString *)type;

/**不带图片
 *设置取消背景颜色
 */
-(void)setSecCancelColor:(UIColor *)cancelColor;
/**不带图片
 *设置弹出框高度 默认为2/3屏幕宽度
 */
-(void)setSecAlertViewHeight:(CGFloat)SecAlertViewHeight;
/**不带图片
 *设置取消按钮的边框颜色
 */
-(void)setCancelBoldColor:(UIColor *)color;

-(void)setSecCancelTextColor:(UIColor *)cancelColor;

//设置背景色 透明度
-(void)setBackValpha:(CGFloat)alpha;

    
#pragma mark - 带tableview
/**实现单选
 *
 */
@property(nonatomic)BOOL isOnlyOne;

/**设置tableview确认按钮颜色
 *
 */
-(void)setTableviewSureBtnColor:(UIColor *)color;

/**设置tableview取消按钮颜色
 *
 */
-(void)setTableviewCancelBtnColor:(UIColor *)color;

/**设置tableview头上背景label颜色
 *
 */
-(void)setTableviewHeadBackLabelColor:(UIColor *)color;

/**带图片
*
 */
-(instancetype)initWithFrame:(CGRect)frame imageName:(NSString *)name message:(NSString *)message isNeedCancel:(BOOL)isNeedCancel sureBlock:(void(^)(BOOL sureBlock))sureBlock;

/**不带图片
 *
 */
-(instancetype)initWithFrame:(CGRect)frame title:(NSString *)title message:(NSString *)message isNeedCancel:(BOOL)isNeedCancel isSureBlock:(void(^)(BOOL sureBlock))sureBlock;

/**带tableview 的选择弹窗
 *
 */
-(instancetype)initWithFrame:(CGRect)frame message:(NSString *)message CellArrar:(NSArray *)CellArr isSureBlock:(void(^)(BOOL sureBlock,NSInteger index))sureBlock ClickCellBlock:(void(^)(NSInteger index))clickCellBlock;

/**带textfield 的选择弹窗
 *
 */
-(instancetype)initWithFrame:(CGRect)frame message:(NSString *)message isSureBlock:(void(^)(NSString *textBlock))textBlock;


/**首页功能图标点击弹出更多选择
 *
 */
-(instancetype)initWithFrame:(CGRect)frame PicPathArr:(NSArray *)picArr titleArr:(NSArray *)titleArr clickBlock:(void(^)(NSInteger index))clickIndex;

/**凯诺弹出框
 *
 */
-(instancetype)initWithFrame:(CGRect)frame backgroundImageName:(NSString *)name message:(NSString *)message isNeedCancel:(BOOL)isNeedCancel sureBlock:(void(^)(BOOL sureBlock))sureBlock;


@end
