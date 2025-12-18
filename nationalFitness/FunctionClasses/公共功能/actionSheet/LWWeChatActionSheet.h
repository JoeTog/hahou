//
//  LWWeChatActionSheet.h
//  LWProjectFramework
//
//  Created by bhczmacmini on 17/1/11.
//  Copyright © 2017年 LW. All rights reserved.
//

#define SCREEN_SIZE [UIScreen mainScreen].bounds.size

//btnTag
#define BTN_TAG 999

// 按钮高度
#define LW_BUTTON_H kPLUS_SCALE_X(44)

//标题label 距上多少
#define LW_Title_top_H 10.0f

// 颜色
#define LWColor(r, g, b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1.0f]
// 阴影透明度
#define LW_DEFAULT_BACKGROUND_OPACITY 0.3f
// 动画时长
#define LW_DEFAULT_ANIMATION_DURATION 0.3f
// 标题字体大小
#define LW_DEFAULT_TITLE_TEXT_FONT  [UIFont systemFontOfSize:13.0f]
// 其他字体大小
#define LW_DEFAULT_CONTENT_TEXT_FONT  [UIFont systemFontOfSize:16.0f]
// 取消按钮字体大小
#define LW_DEFAULT_CANCEL_TEXT_FONT  [UIFont systemFontOfSize:16.0f]

#import <UIKit/UIKit.h>

typedef void(^LWBtnClickBlock) (NSInteger buttonIndex);

@interface LWWeChatActionSheet : UIView

@property(nonatomic,strong)NSString *title;//标题
@property(nonatomic,strong)NSString *cancelButtonTitle;//取消按钮标题
@property(nonatomic,strong)NSArray *otherButtonTitles;//其他标题
@property(nonatomic,strong)LWBtnClickBlock btnClickBlock;//点击回调 //传出999代表弹框消失

@property (nonatomic,strong)UIWindow *rootWindow;//弹出框的窗口
@property (nonatomic,strong)UIView *shadowView;//弹出框阴影部分视图
@property (nonatomic,strong)UIView *contentView;//弹出框的全部视图
@property (nonatomic,strong)UIView *topContentView;//弹出框除去取消按钮的内容部分
@property (nonatomic,strong)UIView *titleView;//放置标题的view
@property (nonatomic,strong)UIButton *cancelBtn;//取消按钮控件
@property (nonatomic,strong)UILabel *titleLabel;//标题控件

@property (nonatomic, strong)UIColor *cancelBtnTextColor;//取消按钮字的颜色，默认红色
@property (nonatomic, strong)UIFont *cancelBtnTextFont;//取消按钮字体大小，默认16
@property (nonatomic, strong)UIColor *otherBtnTextColor;//选项按钮字的颜色，默认灰色
@property (nonatomic, strong)UIFont *otherBtnTextFont;//选项按钮字体大小，默认15
@property (nonatomic, strong)UIColor *titleTextColor;//标题字的颜色，默认灰色
@property (nonatomic, strong)UIFont *titleTextFont;//标题字体大小，默认13

//初始化
- (instancetype)initWithWeChatActionSheetCancelButtonTitle:(NSString *)cancelButtonTitle
                                                     title:(NSString *)title
                                         otherButtonTitles:(NSArray<NSString *> *)otherButtonTitles btnClickBlock:(LWBtnClickBlock)btnClickBlock;

//设置按钮能否点击
- (void)WeChatBtnIndex:(NSInteger)index enabled:(BOOL)enabled;
//设置按钮全不能点击
- (void)WeChatBtnNotEnabled;
//设置按钮都能点击
- (void)WeChatBtnCanEnabled;

//展示窗口
- (void)show;

@end
