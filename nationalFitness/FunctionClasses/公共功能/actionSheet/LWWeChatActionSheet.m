//
//  LWWeChatActionSheet.m
//  LWProjectFramework
//
//  Created by bhczmacmini on 17/1/11.
//  Copyright © 2017年 LW. All rights reserved.
//

#import "LWWeChatActionSheet.h"
#import "UIColor+RYChat.h"


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@implementation LWWeChatActionSheet

-(UIFont *)cancelBtnTextFont{
    if (!_cancelBtnTextFont) {
        _cancelBtnTextFont = LW_DEFAULT_CANCEL_TEXT_FONT;
    }
    return _cancelBtnTextFont;
}

-(UIColor *)cancelBtnTextColor{
    if (!_cancelBtnTextColor) {
        _cancelBtnTextColor =  UIColorFromRGB(0xa8a5a5);
    }
    return _cancelBtnTextColor;
}

- (UIFont *)otherBtnTextFont{
    if (!_otherBtnTextFont) {
        _otherBtnTextFont = LW_DEFAULT_CONTENT_TEXT_FONT;
    }
    return _otherBtnTextFont;
}

- (UIColor *)otherBtnTextColor{
    if (!_otherBtnTextColor) {
        _otherBtnTextColor = [UIColor colorThemeColor];
//        _otherBtnTextColor = UIColorFromRGB(0x623b3e);
    }
    return _otherBtnTextColor;
}

- (UIColor *)titleTextColor
{
    if (!_titleTextColor) {
        _titleTextColor = UIColorFromRGB(0xb4b2b2);
    }
    return _titleTextColor;
}

- (UIFont *)titleTextFont
{
    if (!_titleTextFont) {
        _titleTextFont = LW_DEFAULT_TITLE_TEXT_FONT;
    }
    if (SCREEN_WIDTH >= 414) {
        return [UIFont systemFontOfSize:15.0f];
    }
    return _titleTextFont;
}

- (UIWindow *)rootWindow
{
    if (_rootWindow == nil) {
        _rootWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _rootWindow.windowLevel       = UIWindowLevelStatusBar;
        _rootWindow.backgroundColor   = [UIColor clearColor];
        _rootWindow.hidden = NO;
    }
    return _rootWindow;
}

- (instancetype)initWithWeChatActionSheetCancelButtonTitle:(NSString *)cancelButtonTitle
                                                     title:(NSString *)title
                                         otherButtonTitles:(NSArray<NSString *> *)otherButtonTitles btnClickBlock:(LWBtnClickBlock)btnClickBlock
{
    if (self = [super init]) {
        self.title = title;
        self.cancelButtonTitle = cancelButtonTitle;
        self.otherButtonTitles = otherButtonTitles;
        self.btnClickBlock = btnClickBlock;
        [self configView];
    }
    return self;
}

- (void)WeChatBtnIndex:(NSInteger)index enabled:(BOOL)enabled
{
    UIButton *btn = [self.topContentView viewWithTag:index+BTN_TAG];
    if (enabled) {
        btn.titleLabel.alpha = 1.0;
    } else {
        btn.titleLabel.alpha = 0.7;
    }
    btn.enabled = enabled;
}

- (void)WeChatBtnNotEnabled
{
    for (int i = 0; i < self.otherButtonTitles.count; i++) {
        UIButton *btn = [self.topContentView viewWithTag:i+BTN_TAG];
        btn.titleLabel.alpha = 0.7;
        btn.enabled = NO;
    }
}

- (void)WeChatBtnCanEnabled
{
    for (int i = 0; i < self.otherButtonTitles.count; i++) {
        UIButton *btn = [self.topContentView viewWithTag:i+BTN_TAG];
        btn.titleLabel.alpha = 1.0;
        btn.enabled = YES;
    }
}

- (void)show
{
    self.rootWindow.hidden = NO;
    [self addSubview:self.contentView];
    [self.rootWindow addSubview:self];
    
    [UIView animateWithDuration:LW_DEFAULT_ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissBefore)];
        
        [self.shadowView setUserInteractionEnabled:YES];
        [self.shadowView addGestureRecognizer:singleTap];
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        
        CGRect frame = self.contentView.frame;
        frame.origin.y -= frame.size.height;
        [self.contentView setFrame:frame];
        
    } completion:nil];
}

//基本UI配置
- (void)configView
{
    [self setFrame:(CGRect){0, 0, SCREEN_SIZE}];
    
    self.shadowView = [[UIView alloc] init];
    self.shadowView.alpha = 0.3;
    [self.shadowView setUserInteractionEnabled:NO];
    [self.shadowView setFrame:(CGRect){0, 0, SCREEN_SIZE}];
    [self.shadowView setBackgroundColor:[UIColor grayColor]];
    [self addSubview:self.shadowView];

    // 弹出框部分的view
    self.contentView = [[UIView alloc] init];
    [self.contentView setBackgroundColor:UIColorFromRGB(0xfafafb)];
    
    //弹出框除去取消按钮的部分
    UIView *topView = [[UIView alloc] init];
    [topView setBackgroundColor:LWColor(192, 192, 193)];
    self.topContentView = topView;
    [self.contentView addSubview:self.topContentView];
    
    //标题
    if (self.title) {
        //标题视图
        self.titleView = [[UIView alloc] init];
        self.titleView.backgroundColor = [UIColor whiteColor];
        [self.topContentView addSubview:self.titleView];
        
        CGFloat titleLabelWidth = SCREEN_SIZE.width-40;
//        CGSize contentSize = [self.title boundingRectWithSize:CGSizeMake(titleLabelWidth, MAXFLOAT)
//                          options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
//                       attributes:@{NSFontAttributeName : self.titleTextFont}
//                          context:nil].size;
        
        CGSize contentSize = [self.title boundingRectWithSize:CGSizeMake(titleLabelWidth, MAXFLOAT)
                                                      options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                   attributes:@{NSFontAttributeName : self.titleTextFont}
                                                      context:nil].size;
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_SIZE.width-titleLabelWidth)/2, LW_Title_top_H, titleLabelWidth, contentSize.height)];
        self.titleLabel.text = self.title;
        [self.titleLabel setBackgroundColor:[UIColor whiteColor]];
        self.titleLabel.textColor = self.titleTextColor;
        self.titleLabel.font = self.titleTextFont;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.numberOfLines = 0;
        [self.titleView addSubview:self.titleLabel];
        
        self.titleView.frame = CGRectMake(0, 0, SCREEN_SIZE.width, LW_Title_top_H * 2 + contentSize.height);
    }
    
    NSString *bundlePath = [[NSBundle bundleForClass:self.class] pathForResource:@"LWWeChatActionSheet" ofType:@"bundle"];
    //按钮显示
    if (self.otherButtonTitles) {
        for (int i = 0; i < self.otherButtonTitles.count; i++) {
            UIButton *btn = [[UIButton alloc] init];
            [btn setTag:i+BTN_TAG];
            [btn setBackgroundColor:[UIColor whiteColor]];
            [btn setTitle:self.otherButtonTitles[i] forState:UIControlStateNormal];
            [[btn titleLabel] setFont:self.otherBtnTextFont];
            [btn setTitleColor:self.otherBtnTextColor forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            
            NSString *linePath = [bundlePath stringByAppendingPathComponent:@"bgImage_HL@2x.png"];
            UIImage *bgImage = [UIImage imageWithContentsOfFile:linePath];
            
            [btn setBackgroundImage:bgImage forState:UIControlStateHighlighted];
            [btn addTarget:self action:@selector(didClick:) forControlEvents:UIControlEventTouchUpInside];
            
            CGFloat y;
            if (self.title) {
                y = LW_BUTTON_H * i + self.titleView.frame.size.height;
            } else {
                y = LW_BUTTON_H * i;
            }
            [btn setFrame:CGRectMake(0, y, SCREEN_SIZE.width, LW_BUTTON_H)];
            [self.topContentView addSubview:btn];
        }
        for (int i = 0; i < self.otherButtonTitles.count; i++) {
            NSString *linePath = [bundlePath stringByAppendingPathComponent:@"cellLine@2x.png"];
            UIImage *lineImage = [UIImage imageWithContentsOfFile:linePath];
            // 功能按钮的分割线条
            UIImageView *line = [[UIImageView alloc] init];
            [line setImage:lineImage];
            [line setContentMode:UIViewContentModeTop];
            CGFloat y;
            if (self.title) {
                y = LW_BUTTON_H * i + self.titleView.frame.size.height;
            } else {
                y = LW_BUTTON_H * i;
            }
            if (i == 0) {
                line.hidden = YES;
            }
            [line setFrame:CGRectMake(0, y, SCREEN_SIZE.width, 1.0f)];
            [self.topContentView addSubview:line];
        }
    }
    CGFloat bottomH;
    if (self.title) {
        bottomH = LW_BUTTON_H * self.otherButtonTitles.count + self.titleView.frame.size.height;
    } else {
        bottomH = LW_BUTTON_H * self.otherButtonTitles.count;
    }
    [self.topContentView setFrame:CGRectMake(0, 0, SCREEN_SIZE.width, bottomH)];
    // 取消按钮的背景
    NSString *linePath = [bundlePath stringByAppendingPathComponent:@"bgImage_HL@2x.png"];
    UIImage *bgImage = [UIImage imageWithContentsOfFile:linePath];
    // 取消按钮
    self.cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(0 , self.topContentView.frame.size.height+5, self.topContentView.frame.size.width,LW_BUTTON_H)];
    [self.cancelBtn setTag:-100];
    [self.cancelBtn setTitle:self.cancelButtonTitle forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:self.cancelBtnTextColor forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.cancelBtn setBackgroundColor:[UIColor whiteColor]];
    [self.cancelBtn setBackgroundImage:bgImage forState:UIControlStateHighlighted];
    [self.cancelBtn addTarget:self action:@selector(didClick:) forControlEvents:UIControlEventTouchUpInside];
    [[self.cancelBtn titleLabel] setFont:self.cancelBtnTextFont];
    [self.contentView addSubview: self.cancelBtn];
    [self.contentView setFrame:CGRectMake(0, SCREEN_SIZE.height, SCREEN_SIZE.width, CGRectGetMaxY(self.cancelBtn.frame))];
    if (self.title) {
        UILabel *lineLab = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame)+10, SCREEN_SIZE.width, 1)];
        lineLab.backgroundColor = UIColorFromRGB(0xe7e6eb);
        [self.contentView addSubview:lineLab];
    }
}

-(void)didClick:(UIButton*)btn {
    [self dismiss:nil];
    //取消按钮
    if (btn && btn.tag == -100) {
        if (self.btnClickBlock) {
            self.btnClickBlock(999);
        }
        return;
    }
    if (self.btnClickBlock) {
        self.btnClickBlock(btn.tag-BTN_TAG);
    }
}

//点击空白背景 弹窗消失 消失前通知界面移除选中的indexpath 和点击取消一样的逻辑
-(void)dismissBefore{
    if (self.btnClickBlock) {
        self.btnClickBlock(999);
    }
    [self dismiss:nil];
}

//退出弹框
- (void)dismiss:(UITapGestureRecognizer *)tap
{
    [UIView animateWithDuration:LW_DEFAULT_ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.shadowView setAlpha:0];
        [self.shadowView setUserInteractionEnabled:NO];
        CGRect frame = self.contentView.frame;
        frame.origin.y += frame.size.height;
        [self.contentView setFrame:frame];
    } completion:^(BOOL finished){
        [self removeFromSuperview];
        self.rootWindow.hidden = YES;
    }];
}



@end


