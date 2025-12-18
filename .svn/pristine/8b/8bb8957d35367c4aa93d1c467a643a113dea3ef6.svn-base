//
//  YWMessageVoiceView.m
//  nationalFitness
//
//  Created by liumac on 15/4/29.
//  Copyright (c) 2015年 chenglong. All rights reserved.
//

#import "YWMessageVoiceView.h"
#import "PublicDefine.h"
#import "NFbaseViewController.h"

@implementation YWMessageVoiceView
{
    UIButton *_voiceBtn;
//    UILabel *_timeLab;
    NSTimer *_timer;
    NSInteger _count;
    UILabel *_textLab;
    
    // 波浪条纹
    UIImageView *bolImage_1;
    UIImageView *bolImage_2;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup{
    self.backgroundColor = [UIColor whiteColor];
    _textLab = [[UILabel alloc]initWithFrame:CGRectMake((CGRectGetWidth(self.bounds)-100)/2, 20, 100, 30)];
    _textLab.text = @"按住说话";
    _textLab.font = [UIFont systemFontOfSize:15.f];
    _textLab.textAlignment = NSTextAlignmentCenter;
    _textLab.textColor = [UIColor grayColor];
    [self addSubview:_textLab];
    
    // 录音时的波浪条纹
    bolImage_1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"voice_bolang"]];
    bolImage_1.frame = CGRectMake((CGRectGetWidth(self.bounds)-104)/2, 63, 104, 104);
    ViewRadius(bolImage_1, 52);
    [self addSubview:bolImage_1];
    
    bolImage_2 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"voice_bolang"]];
    bolImage_2.frame = CGRectMake((CGRectGetWidth(self.bounds)-110)/2, 60, 110, 110);
    ViewRadius(bolImage_2, 55);
    [self addSubview:bolImage_2];
    
    // 录音开始之前隐藏
    bolImage_1.hidden = YES;
    bolImage_2.hidden = YES;
    
    // 录音按钮
    _voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _voiceBtn.frame = CGRectMake((CGRectGetWidth(self.bounds)-100)/2, 65, 100, 100);
    ViewRadius(_voiceBtn, 50);
    [_voiceBtn setBackgroundImage:[UIImage imageNamed:@"voice_btn"] forState:UIControlStateNormal];
    [self addSubview:_voiceBtn];
    
    [_voiceBtn addTarget:self action:@selector(holdDownButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [_voiceBtn addTarget:self action:@selector(recordButtonDragOutside) forControlEvents:UIControlEventTouchDragOutside];
//    [_voiceBtn addTarget:self action:@selector(recordButtonDragInside) forControlEvents:UIControlEventTouchDragInside];
    [_voiceBtn addTarget:self action:@selector(holdDownButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [_voiceBtn addTarget:self action:@selector(holdDownButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
}

#pragma mark -语音功能

- (void)holdDownButtonTouchDown {
    
    if ([_delegate respondsToSelector:@selector(didStartRecordingVoiceAction)]) {
        [_delegate didStartRecordingVoiceAction];
    }
    NSLog(@"这里是开始");
    _textLab.text = @"00:00";
    // 启动定时器
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeCount) userInfo:nil repeats:YES];
}

- (void)recordButtonDragOutside {
    
    if ([_delegate respondsToSelector:@selector(willCancelRecordingVoiceAction)]) {
        
        [_delegate willCancelRecordingVoiceAction];
    }
    [self closeTime];
    if ([_delegate respondsToSelector:@selector(timeNotEnableToCancelRecordingVoiceAction)]) {
        [_delegate timeNotEnableToCancelRecordingVoiceAction];
    }
}

//- (void)recordButtonDragInside{
//    
//    if ([_delegate respondsToSelector:@selector(willSendRecordingVoiceAction)]) {
//        
//        [_delegate willSendRecordingVoiceAction];
//    }
//    [self closeTime];
//    if ([_delegate respondsToSelector:@selector(timeNotEnableToCancelRecordingVoiceAction)]) {
//        [_delegate timeNotEnableToCancelRecordingVoiceAction];
//    }
//    
//}

- (void)holdDownButtonTouchUpInside {
    
    if (_count<=0) {
        [SVProgressHUD showInfoWithStatus:@"录音时间太短"];
        _count = 0;
        [self closeTime];
        if ([_delegate respondsToSelector:@selector(timeNotEnableToCancelRecordingVoiceAction)]) {
            [_delegate timeNotEnableToCancelRecordingVoiceAction];
        }
        return;
    }
    if ([_delegate respondsToSelector:@selector(didFinishRecoingVoiceActionWithTime:)]) {
        [_delegate didFinishRecoingVoiceActionWithTime:_count];
    }
    NSLog(@"这里是结束");
    [self closeTime];
}

- (void)closeTime
{
    _textLab.text = @"按住说话";
    _textLab.hidden = NO;
    
    // 关闭定时器
    [_timer invalidate];
    _timer = nil;
    _count = 0;
    bolImage_1.hidden = YES;
    bolImage_2.hidden = YES;
}

- (UIViewController*)topViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

- (void)holdDownButtonTouchUpOutside {

    if ([_delegate respondsToSelector:@selector(didCancelRecordingVoiceAction)]) {
        [_delegate didCancelRecordingVoiceAction];
    }
    NSLog(@"holdDownButtonTouchUpOutside");
}

- (void)timeCount{
    _count ++;
    NSInteger min = _count/60;
    NSInteger sec = _count%60;
    NSString *mins = nil;
    NSString *secs = nil;
    if (min<10) {
        mins = [NSString stringWithFormat:@"0%ld",(long)min];
    }else{
        mins = [NSString stringWithFormat:@"%ld",(long)min];
    }
    
    if (sec<10) {
        secs = [NSString stringWithFormat:@"0%ld",(long)sec];
    }else{
        secs = [NSString stringWithFormat:@"%ld",(long)sec];
    }
    _textLab.text = [NSString stringWithFormat:@"%@:%@",mins,secs];
    // 显示波浪
    if (_count%3 == 1) {
        bolImage_1.hidden = NO;
        bolImage_2.hidden = YES;
    }else if (_count%3 == 2){
        bolImage_1.hidden = YES;
        bolImage_2.hidden = NO;
    }else{
        bolImage_2.hidden = YES;
        bolImage_1.hidden = YES;
    }
}

@end
