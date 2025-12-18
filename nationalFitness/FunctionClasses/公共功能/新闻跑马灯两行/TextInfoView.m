/*********************************************************************************************
 *   __      __   _         _________     _ _     _    _________   __         _         __   *
 *	 \ \    / /  | |        | _______|   | | \   | |  |  ______ |  \ \       / \       / /   *
 *	  \ \  / /   | |        | |          | |\ \  | |  | |     | |   \ \     / \ \     / /    *
 *     \ \/ /    | |        | |______    | | \ \ | |  | |     | |    \ \   / / \ \   / /     *
 *     /\/\/\    | |        |_______ |   | |  \ \| |  | |     | |     \ \ / /   \ \ / /      *
 *    / /  \ \   | |______   ______| |   | |   \ \ |  | |_____| |      \ \ /     \ \ /       *
 *   /_/    \_\  |________| |________|   |_|    \__|  |_________|       \_/       \_/        *
 *                                                                                           *
 *********************************************************************************************/

#import "TextInfoView.h"

#define kFit6PWidth  ([UIScreen mainScreen].bounds.size.width / 414)
#define kFit6PHeight ([UIScreen mainScreen].bounds.size.height / 736)

#define iPhone4s    ([[UIScreen mainScreen] bounds].size.height == 480)
#define iPhone5     ([[UIScreen mainScreen] bounds].size.height == 568)
#define iPhone6     ([[UIScreen mainScreen] bounds].size.height == 667)
#define iPhone6Plus ([[UIScreen mainScreen] bounds].size.height == 736)

@interface TextInfoView ()

@property (nonatomic, strong) UILabel *topLabel;
@property (nonatomic, strong) UILabel *bottomLabel;
@property (nonatomic, strong) UILabel *topTimeLabel;
@property (nonatomic, strong) UILabel *bottomTimeLabel;


@property (nonatomic, strong) UIButton *topButton;
@property (nonatomic, strong) UIButton *bottomButton;



@end

@implementation TextInfoView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self drawUI];
    }
    return self;
}

- (void)drawUI {
    self.topLabel = [UILabel new];
    [self addSubview:self.topLabel];
    [self.topLabel setFrame:(CGRectMake(10*kFit6PWidth, 10, 35, 25))];
    //对label 高度作出修改
    [self.topLabel setFrame:(CGRectMake(10*kFit6PWidth, 6, 35, 15))];
    self.topLabel.layer.borderWidth = 1;
    self.topLabel.layer.borderColor = [[UIColor colorWithRed:208/255.0 green:17/255.0 blue:27/255.0 alpha:1.0] CGColor];
    self.topLabel.textColor = MainColor;
    self.topLabel.layer.cornerRadius = 5;
    //对圆角作出改变
    self.topLabel.layer.cornerRadius = 3;
    self.topLabel.layer.masksToBounds = YES;
    self.topLabel.textAlignment = NSTextAlignmentCenter;
    self.topLabel.font = [UIFont systemFontOfSize:13];
    
    self.bottomLabel = [UILabel new];
    [self addSubview:self.bottomLabel];
    [self.bottomLabel setFrame:(CGRectMake(10*kFit6PWidth, 40, 35, 25))];
    //对label 高度作出修改
    [self.bottomLabel setFrame:(CGRectMake(10*kFit6PWidth, 29, 35, 15))];
    self.bottomLabel.layer.borderWidth = 1;
    self.bottomLabel.layer.borderColor = [[UIColor colorWithRed:208/255.0 green:17/255.0 blue:27/255.0 alpha:1.0] CGColor];
    self.bottomLabel.textColor = MainColor;
    self.bottomLabel.layer.cornerRadius = 5;
    //对圆角作出改变
    self.bottomLabel.layer.cornerRadius = 3;
    self.bottomLabel.layer.masksToBounds = YES;
    self.bottomLabel.textAlignment = NSTextAlignmentCenter;
    self.bottomLabel.font = [UIFont systemFontOfSize:13];
    
    self.topButton = [UIButton new];
    [self addSubview:self.topButton];
    [self.topButton setFrame:(CGRectMake(64*kFit6PWidth, 5, 330*kFit6PWidth, 21))];
    //对需要点击的button作出改变
    [self.topButton setFrame:(CGRectMake(64*kFit6PWidth, 2.6, 330*kFit6PWidth, 21))];
    [self.topButton addTarget:self action:@selector(topButtonEvent:) forControlEvents:(UIControlEventTouchUpInside)];
    self.topButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    [self.topButton setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    
    self.bottomButton = [UIButton new];
    [self addSubview:self.bottomButton];
    [self.bottomButton setFrame:(CGRectMake(64*kFit6PWidth, 35, 330*kFit6PWidth, 21))];
    //对需要点击的button作出改变
    [self.bottomButton setFrame:(CGRectMake(64*kFit6PWidth, 26.2, 330*kFit6PWidth, 21))];
    [self.bottomButton addTarget:self action:@selector(bottomButtonEvent:) forControlEvents:(UIControlEventTouchUpInside)];
    self.bottomButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    [self.bottomButton setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    
    if (iPhone6Plus) {
        self.topButton.titleLabel.font = [UIFont boldSystemFontOfSize:11];
        self.bottomButton.titleLabel.font = [UIFont boldSystemFontOfSize:11];
    } else if (iPhone6) {
        self.topButton.titleLabel.font = [UIFont boldSystemFontOfSize:11];
        self.bottomButton.titleLabel.font = [UIFont boldSystemFontOfSize:11];
    } else if (iPhone5) {
        self.topButton.titleLabel.font = [UIFont boldSystemFontOfSize:11];
        self.bottomButton.titleLabel.font = [UIFont boldSystemFontOfSize:11];
    } else {
        self.topButton.titleLabel.font = [UIFont boldSystemFontOfSize:11];
        self.bottomButton.titleLabel.font = [UIFont boldSystemFontOfSize:11];
    }
}

- (void)topButtonEvent:(UIButton *)topButton {
    [self.xlsn0wDelegate handleTopEventWithURLString:self.topModel.URLString];
}

- (void)bottomButtonEvent:(UIButton *)bottomButton {
    [self.xlsn0wDelegate handleBottomEventWithURLString:self.bottomModel.URLString];
}

- (void)setTopModel:(DataSourceModel *)topModel {
    _topModel = topModel;
    //  去掉\n
    NSString *title = [NSString stringWithFormat:@"%@", [topModel.title stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"]];
    [self.topButton setTitle:title forState:UIControlStateNormal];
    self.topLabel.text = topModel.type;
    
    //加上尾部的时间label
    if (!_topTimeLabel) {
        _topTimeLabel = [UILabel new];
    }
    _topTimeLabel.text = topModel.time;
    _topTimeLabel.font = [UIFont systemFontOfSize:9];
    [self.topButton addSubview:_topTimeLabel];
    [_topTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.topButton.mas_right);
        make.centerY.mas_equalTo(self.topButton.mas_centerY);
        make.height.mas_equalTo(self.topButton.mas_height);
        make.width.mas_equalTo(110);
    }];
}

- (void)setBottomModel:(DataSourceModel *)bottomModel {
    _bottomModel = bottomModel;
    NSString *title = [NSString stringWithFormat:@"%@", [bottomModel.title stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"]];
    [self.bottomButton setTitle:title forState:UIControlStateNormal];
     self.bottomLabel.text = bottomModel.type;
    
    //加上尾部的时间label
    if (!_bottomTimeLabel) {
        _bottomTimeLabel = [UILabel new];
    }
    _bottomTimeLabel.text = bottomModel.time;
    _bottomTimeLabel.font = [UIFont systemFontOfSize:9];
    [self.bottomButton addSubview:_bottomTimeLabel];
    [_bottomTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bottomButton.mas_right);
        make.centerY.mas_equalTo(self.bottomButton.mas_centerY);
        make.height.mas_equalTo(self.bottomButton.mas_height);
        make.width.mas_equalTo(110);
    }];
    
}

@end
