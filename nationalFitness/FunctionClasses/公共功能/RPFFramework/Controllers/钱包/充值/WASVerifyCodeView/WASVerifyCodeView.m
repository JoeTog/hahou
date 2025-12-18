//
//  WASVerifyCodeView.m
//  WASVerifyCodeView
//
//  Created by luofeiyu on 2016/12/9.
//  Copyright © 2016年 wangshuo. All rights reserved.
//

#import "WASVerifyCodeView.h"
#import "Masonry.h"
@interface  WASVerifyCodeView ()

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *codeImageView;
@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, strong) NSString *accountId;
@property (nonatomic, copy) VerifyCodeBlock verifyCodeBlock;

@end

@implementation WASVerifyCodeView

+ (instancetype)shareView {
    static dispatch_once_t onceToken;
    static WASVerifyCodeView *instance;
    dispatch_once(&onceToken, ^{
        instance = [[WASVerifyCodeView alloc] init];
    });
    return instance;
}

+ (void)showVerifyCodeViewOnView:(UIView*)view accountId:(NSString *)accountId verifyCodeBlock:(VerifyCodeBlock)block {
    [WASVerifyCodeView shareView].accountId = accountId;
    [WASVerifyCodeView shareView].verifyCodeBlock = block;
    if ([WASVerifyCodeView shareView].backView) {
        [[WASVerifyCodeView shareView].backView removeFromSuperview];
        [WASVerifyCodeView shareView].backView = nil;
    }
    if ([WASVerifyCodeView shareView].contentView) {
        [[WASVerifyCodeView shareView].contentView removeFromSuperview];
        [WASVerifyCodeView shareView].contentView = nil;
    }
    [view addSubview:[WASVerifyCodeView shareView].backView];
    [[WASVerifyCodeView shareView].backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    [[WASVerifyCodeView shareView] layoutContentViewsOnSuperview:view];
    [[WASVerifyCodeView shareView] showAnimated];
    [[WASVerifyCodeView shareView] reloadCodeImageView];
}

+ (void)dismissVerifyCodeViewOnView {
    [[WASVerifyCodeView shareView] dismiss];
}

+ (void)refreshVerifyCode {
    [[WASVerifyCodeView shareView] reloadCodeImageView];
}

- (void)showAnimated {
    _backView.alpha = 0;
    _contentView.transform = CGAffineTransformMakeScale(1.2, 1.2);
    _contentView.alpha = 0.0f;
    [UIView animateWithDuration:0.6
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _backView.alpha = 0.7;
                         _contentView.transform = CGAffineTransformMakeScale(1, 1);
                         _contentView.alpha = 1.0f;
                     }
                     completion:nil
     ];
}

- (void)dismiss
{
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         _backView.alpha = 0;
                         _contentView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         [_backView removeFromSuperview];
                         [_contentView removeFromSuperview];
                         _backView = nil;
                         _contentView = nil;
                         _accountId  = nil;
                         _verifyCodeBlock = nil;
                     }
     ];
}

- (void)submitBtnClick {
    if (self.verifyCodeBlock) {
        self.verifyCodeBlock(self.textField.text);
    }
    [self dismiss];
}

- (void)reloadCodeImageView {
    __weak typeof(self) weakSelf = self;
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://verifycode.helijia.com/get?account_id=13812345678"]]
                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError* error) {
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         weakSelf.codeImageView.image = [UIImage imageWithData:data];
                                     });
                                 }] resume];
}


- (void)layoutContentViewsOnSuperview:(UIView*)view {
    [view addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(325);
        make.height.mas_equalTo(215);
        make.left.mas_equalTo(25);
        make.top.mas_equalTo(123);
    }];
    UIView *titleBackView = [UIView new];
    titleBackView.backgroundColor = [self colorWithHexString:@"F7F7F7"];
    [self.contentView addSubview:titleBackView];
    [titleBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.mas_equalTo(self.contentView.mas_top);
        make.height.mas_equalTo(50);
    }];
    UILabel *title = [UILabel new];
    title.text = @"请输入验证码";
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont systemFontOfSize:17];
    title.textColor = [self colorWithHexString:@"#1A1A1A"];
    [self.contentView addSubview:title];
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.mas_equalTo(self.contentView.mas_top);
        make.height.mas_equalTo(50);
    }];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:[UIImage imageNamed:@"icon_close"] forState:UIControlStateNormal];
    [self.contentView addSubview:closeBtn];
    [closeBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(15);
        make.height.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(17);
    }];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.userInteractionEnabled = NO;
    btn.titleLabel.font = [UIFont systemFontOfSize:12];
    [btn setImage:[UIImage imageNamed:@"icon_warry"] forState:UIControlStateNormal];
    [btn setTitle:@"验证码已发送，请输入收到的验证码" forState:UIControlStateNormal];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 0)];
    [btn setTitleColor:[self colorWithHexString:@"#999999"] forState:UIControlStateNormal];
    
    [self.contentView addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(titleBackView.mas_bottom).mas_offset(15);
        make.height.mas_equalTo(18);
    }];
    
    UITextField *textField = [UITextField new];
    textField.leftView = [[UIView alloc] initWithFrame:(CGRect){0,0,14,44}];
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.font = [UIFont systemFontOfSize:14];
    NSMutableParagraphStyle *style = [textField.defaultTextAttributes[NSParagraphStyleAttributeName] mutableCopy];
    
    style.minimumLineHeight = textField.font.lineHeight - (textField.font.lineHeight - [UIFont systemFontOfSize:14.0].lineHeight) / 2.0;
    
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入验证码"
                                                                      attributes:@{ NSFontAttributeName :[UIFont systemFontOfSize:14],
                                                                                    NSForegroundColorAttributeName : [self colorWithHexString:@"#B5B5B9"],
                                                                                    NSParagraphStyleAttributeName : style
                                                                                    }];
    textField.layer.cornerRadius = 2;
    textField.layer.masksToBounds = YES;
    textField.layer.borderWidth = 1;
    textField.layer.borderColor = [self colorWithHexString:@"#DEDEDE"].CGColor;
    textField.keyboardType = UIKeyboardTypeNumberPad;
    [self.contentView addSubview:textField];
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(btn.mas_bottom).mas_offset(15);
        make.height.mas_equalTo(44);
//        make.width.mas_equalTo(250);
        make.right.mas_equalTo(-15);
    }];
    _textField = textField;
    
    _codeImageView = [UIImageView new];
    _codeImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reloadCodeImageView)];
    [_codeImageView addGestureRecognizer:tap];
    [self.contentView addSubview:_codeImageView];
    [_codeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(_textField.mas_centerY);
//        make.height.mas_equalTo(30);
//        make.width.mas_equalTo(100);
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(1);
    }];
    
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    submitBtn.layer.cornerRadius = 2;
    submitBtn.layer.masksToBounds = YES;
    submitBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [submitBtn setTitle:@"确定" forState:UIControlStateNormal];
//    [submitBtn setBackgroundColor:[self colorWithHexString:@"#BD9D62"]];
    [submitBtn setBackgroundColor:[self colorWithHexString:@"#435a8e"]];
    //UIColorFromRGB(0x435a8e)
    
    [submitBtn setTitleColor:[self colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
    [submitBtn addTarget:self action:@selector(submitBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:submitBtn];
    
    [submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.bottom.mas_equalTo(-15);
        make.height.mas_equalTo(44);
    }];
}




- (UIView *)backView {
    if (!_backView) {
        _backView = [UIView new];
        _backView.backgroundColor = [self colorWithHexString:@"#000000"];
        _backView.alpha = 0.7;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        [_backView addGestureRecognizer:tap];
    }
    return _backView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [UIView new];
        _contentView.backgroundColor = [self colorWithHexString:@"#FFFFFF"];
        _contentView.layer.cornerRadius = 2;
        _contentView.layer.masksToBounds = YES;
    }
    return _contentView;
}

- (UIColor *) colorWithHexString: (NSString *) stringToConvert
{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];//字符串处理
    //例子，stringToConvert #ffffff
    if ([cString length] < 6)
        return [UIColor whiteColor];//如果非十六进制，返回白色
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];//去掉头
    if ([cString length] != 6)//去头非十六进制，返回白色
        return [UIColor whiteColor];
    //分别取RGB的值
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    unsigned int r, g, b;
    //NSScanner把扫描出的制定的字符串转换成Int类型
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    //转换为UIColor
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

@end
