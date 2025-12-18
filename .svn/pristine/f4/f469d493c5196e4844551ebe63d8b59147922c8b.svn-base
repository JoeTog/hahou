//
//  RingSleepAnalysisView.m
//  nationalFitness
//
//  Created by 蝴蝶 on 15/4/16.
//  Copyright (c) 2015年 chenglong. All rights reserved.
//

#import "RingSleepAnalysisView.h"
#import "NFUserEntity.h"
#import "PublicDefine.h"

#define kHorizonLineWidth           34

@interface RingSleepAnalysisView () {
    BOOL _isLightPLabelHiden;    // 浅睡眠是否隐藏
    BOOL _isDeepPLabelHiden;     // 深睡眠是否隐藏
    
    CAShapeLayer *_shapeLayer_leftDownLineLayer;  // 左下线
    CAShapeLayer *_shapeLayer_rightUpLineLayer;   // 右上线
}
@property (weak, nonatomic) IBOutlet UILabel *totalSleepRightCornerLabel;

@property (weak, nonatomic) IBOutlet UILabel *totalSleepHourLabel;
@property (weak, nonatomic) IBOutlet UIView *PieChartContainerView;

@property (weak, nonatomic) IBOutlet UIButton *leftBtn;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;
@property (weak, nonatomic) IBOutlet UILabel *lightSleepPLabel;
@property (weak, nonatomic) IBOutlet UILabel *deepSleepPLabel;
@property (weak, nonatomic) IBOutlet UILabel *lightSleepHourLabel;
@property (weak, nonatomic) IBOutlet UILabel *deepSleepHourLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *downDateLabel;
@property (weak, nonatomic) IBOutlet UIView *lightSleepBg;
@property (weak, nonatomic) IBOutlet UIView *deepSleepBg;
@property (weak, nonatomic) IBOutlet UIView *shoppingMaskView;
@property (weak, nonatomic) IBOutlet UIButton *shoppingBtn;

@end

@implementation RingSleepAnalysisView

@synthesize dateString = _dateString;

- (void)awakeFromNib {
    _dateLabel.hidden = YES;
    
    UIColor *lightBgColor = [NFUserEntity shareInstance].sex == NFMan ? UIColorFromRGB(0x6ec9f7):UIColorFromRGB(0xf3b1cd);
    UIColor *deepBgColor = [NFUserEntity shareInstance].sex == NFMan ? UIColorFromRGB(0x016aa6):UIColorFromRGB(0xd75991);
    
    _deepSleepPLabel.textColor = deepBgColor;
    _lightSleepPLabel.textColor = lightBgColor;
    ViewRadius(_lightSleepBg, 3);
    ViewRadius(_deepSleepBg, 3);
    
    _isLightPLabelHiden = self.lightSleepPLabel.isHidden;
    _isDeepPLabelHiden = self.deepSleepPLabel.isHidden;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    // 画线
    
    UIColor *lightBgColor = [NFUserEntity shareInstance].sex == NFMan ? UIColorFromRGB(0x6ec9f7):UIColorFromRGB(0xf3b1cd);
    UIColor *deepBgColor = [NFUserEntity shareInstance].sex == NFMan ? UIColorFromRGB(0x016aa6):UIColorFromRGB(0xd75991);
    
    CGPoint leftDownP = CGPointMake(self.pieChartView.frame.origin.x, self.pieChartView.frame.origin.y + self.pieChartView.frame.size.height);
    CGPoint rightUpP = CGPointMake(self.pieChartView.frame.origin.x+self.pieChartView.frame.size.width, self.pieChartView.frame.origin.y);
    
    CGPoint pieChartCenter = self.pieChartView.center;
    
    CGFloat pieRadius = self.pieChartView.frame.size.width > self.pieChartView.frame.size.height ? self.pieChartView.frame.size.height/2:self.pieChartView.frame.size.width/2;
    
    CGFloat dy_leftDown = 0.5*pieRadius+10;
    CGFloat dx_lefDown = 0.5*pieRadius+10;
    
    CGFloat dy_rightUp = 0.5*pieRadius +10;
    CGFloat dx_rightUp = 0.5*pieRadius +10;
    
    CGPoint firstLeftDownP = CGPointMake(pieChartCenter.x - dx_lefDown, pieChartCenter.y + dy_leftDown);
    CGPoint secondLeftDownP = CGPointMake(leftDownP.x - kHorizonLineWidth, leftDownP.y); // 向左移动20个像素
    
    CGPoint firstRightUpP = CGPointMake(pieChartCenter.x + dx_rightUp, pieChartCenter.y - dy_rightUp);
    CGPoint secondRightUpP = CGPointMake(rightUpP.x + kHorizonLineWidth, rightUpP.y);
    
    UIBezierPath *leftDownPath = [[UIBezierPath alloc] init];
    [leftDownPath moveToPoint:firstLeftDownP];
    [leftDownPath addLineToPoint:leftDownP];
    [leftDownPath moveToPoint:leftDownP];
    [leftDownPath addLineToPoint:secondLeftDownP];
    
    UIBezierPath *rightUpPath = [[UIBezierPath alloc] init];
    [rightUpPath moveToPoint:firstRightUpP];
    [rightUpPath addLineToPoint:rightUpP];
    [rightUpPath moveToPoint:rightUpP];
    [rightUpPath addLineToPoint:secondRightUpP];
    
        //design path in layer
    if (!_shapeLayer_leftDownLineLayer) {
        _shapeLayer_leftDownLineLayer = [[CAShapeLayer alloc] init];
        _shapeLayer_leftDownLineLayer.path = leftDownPath.CGPath;
        _shapeLayer_leftDownLineLayer.strokeColor = lightBgColor.CGColor; // 等于浅睡眠的背景色
        _shapeLayer_leftDownLineLayer.lineWidth = 1.0;
    }
    
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 1.0f;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    pathAnimation.autoreverses = NO;
    
    [_shapeLayer_leftDownLineLayer addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
    
    // 画左下角的线 浅睡眠
    
    if (!_isLightPLabelHiden) {
        [self.PieChartContainerView.layer addSublayer:_shapeLayer_leftDownLineLayer];
    } else {
        [_shapeLayer_leftDownLineLayer removeFromSuperlayer];
    }
    
    if (!_shapeLayer_rightUpLineLayer) {
        _shapeLayer_rightUpLineLayer = [[CAShapeLayer alloc] init];
        _shapeLayer_rightUpLineLayer.path = rightUpPath.CGPath;
        _shapeLayer_rightUpLineLayer.strokeColor = deepBgColor.CGColor; // 等于深睡眠的背景色
        _shapeLayer_rightUpLineLayer.lineWidth = 1.0;
    }
    
   
    
    CABasicAnimation *rightpathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    rightpathAnimation.duration = 1.0f;
    rightpathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    rightpathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    rightpathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    rightpathAnimation.autoreverses = NO;
    
    [_shapeLayer_rightUpLineLayer addAnimation:rightpathAnimation forKey:@"strokeEndAnimation"];
    
    // 画右上角的线 深睡眠
    if (!_isDeepPLabelHiden) {
        [self.PieChartContainerView.layer addSublayer:_shapeLayer_rightUpLineLayer];
    } else {
        [_shapeLayer_rightUpLineLayer removeFromSuperlayer];
    }
    
    self.lightSleepBg.backgroundColor = lightBgColor;
    self.deepSleepBg.backgroundColor = deepBgColor;
    
    UIImage *bgImage = [NFUserEntity shareInstance].sex == NFMan ?[UIImage imageNamed:@"ring_man_on.png"]:[UIImage imageNamed:@"ring_woman_on.png"];
    [self.shoppingBtn setBackgroundImage:bgImage forState:UIControlStateNormal];
    
}

- (void)setTotalSleepHour:(NSString *)totalSleepHour {
    _totalSleepHour = [totalSleepHour copy];
    [_totalSleepHourLabel setText:[NSString stringWithFormat:@"%.1fH",[_totalSleepHour floatValue]]];
    [_totalSleepRightCornerLabel setText:[NSString stringWithFormat:@"%.1f",[_totalSleepHour floatValue]]];
}

- (void)setLightSleepHour:(NSString *)lightSleepHour {
    _lightSleepHour = [lightSleepHour copy];
    [_lightSleepHourLabel setText:_lightSleepHour];
}

- (void)setDeepSleepHour:(NSString *)deepSleepHour {
    _deepSleepHour = [deepSleepHour copy];
    [_deepSleepHourLabel setText:_deepSleepHour];
}

- (void)setLightP:(NSString *)lightP {
    _lightP = [lightP copy];
    if (!_lightP || [_lightP isEqualToString:@""] || [_lightP isEqualToString:@"0"]) {
        [_lightSleepPLabel setText:[NSString stringWithFormat:@"0%%"]];
       
        _lightSleepPLabel.hidden = YES;
        _isLightPLabelHiden = YES;
        
         [self setNeedsDisplay];
    } else {
        [_lightSleepPLabel setText:[NSString stringWithFormat:@"%@%%",_lightP]];
        _lightSleepPLabel.hidden = NO;
        _isLightPLabelHiden = NO;
        [self setNeedsDisplay];
    }
}

- (void)setDeepP:(NSString *)deepP {
    _deepP = [deepP copy];
    if (!_deepP || [_deepP isEqualToString:@""] || [_deepP isEqualToString:@"0"]) {
        [_deepSleepPLabel setText:[NSString stringWithFormat:@"0%%"]];
        
        _deepSleepPLabel.hidden = YES;
        _isDeepPLabelHiden = YES;
        
        [self setNeedsDisplay];
    } else {
        [_deepSleepPLabel setText:[NSString stringWithFormat:@"%@%%",_deepP]];
        _deepSleepPLabel.hidden = NO;
        _isDeepPLabelHiden = NO;
        [self setNeedsDisplay];
    }
}

- (void)setDownDate:(NSString *)downDate {
    _downDate = [downDate copy];
    [_downDateLabel setText:_downDate];
}

- (void)setIsBinding:(BOOL)isBinding {
    _isBinding = isBinding;
    
    if (_isBinding) {
        self.shoppingMaskView.hidden = YES;
    } else {
        self.shoppingMaskView.hidden = NO;
    }
}

- (IBAction)leftBtnAction:(id)sender {
    if (_ringSleepBtnDelegate && [_ringSleepBtnDelegate respondsToSelector:@selector(leftBtnTaped)]) {
        [_ringSleepBtnDelegate performSelector:@selector(leftBtnTaped) withObject:nil];
    }
}

- (IBAction)rightBtnAction:(id)sender {
    if (_ringSleepBtnDelegate && [_ringSleepBtnDelegate respondsToSelector:@selector(rightBtnTaped)]) {
        [_ringSleepBtnDelegate performSelector:@selector(rightBtnTaped) withObject:nil];
    }
}

- (IBAction)shoppingBtnAction:(id)sender {
    if (_ringSleepBtnDelegate && [_ringSleepBtnDelegate respondsToSelector:@selector(shoppingBtnTaped)]) {
        [_ringSleepBtnDelegate performSelector:@selector(shoppingBtnTaped) withObject:nil];
    }
}

@end
