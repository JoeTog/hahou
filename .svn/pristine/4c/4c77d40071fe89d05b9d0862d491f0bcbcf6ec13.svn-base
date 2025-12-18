//
//  YWMessageVoiceView.h
//  nationalFitness
//
//  Created by liumac on 15/4/29.
//  Copyright (c) 2015年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define PI 3.14159265358979323846

@protocol YWMessageVoiceViewDelegate <NSObject>

/**
 *  按下录音按钮开始录音
 */
- (void)didStartRecordingVoiceAction;

/**
 *  将要发送录音
 */
//- (void)willSendRecordingVoiceAction;

/**
 *  将要取消录音
 */
- (void)willCancelRecordingVoiceAction;

/**
 *  时间不够1秒，取消发送录音
 */

- (void)timeNotEnableToCancelRecordingVoiceAction;

/**
 *  手指向上滑动取消录音
 */
- (void)didCancelRecordingVoiceAction;

/**
 *  松开手指完成录音
 */
- (void)didFinishRecoingVoiceActionWithTime:(NSInteger)time;

@end

@interface YWMessageVoiceView : UIView

@property (weak,nonatomic)  id<YWMessageVoiceViewDelegate>  delegate;

@end
