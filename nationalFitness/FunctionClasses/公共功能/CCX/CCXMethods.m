//
//  CCXMethods.m
//  CCXPushAndPop01
//
//  Created by Chuanxi.Chen on 16/2/29.
//  Copyright © 2016年 Chuanxi.Chen. All rights reserved.
//

#import "CCXMethods.h"


@implementation CCXMethods

#pragma mark --读取文件URL
+(NSURL *)getURLWithName:(NSString *)name{
    NSArray *arr = [name componentsSeparatedByString:@"."];
    NSString *url = [[NSBundle mainBundle]pathForResource:arr[0] ofType:arr[1]];
    return [NSURL URLWithString:url];
}

#pragma mark -- 播放短音频
+(void)playShortSoundWithName:(NSString *)soundName{
    //    声明SoundID
    SystemSoundID soundID;
    //    绑定音频URL和SsoundID
    AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)([self getURLWithName:soundName]), &soundID);
    //    委托系统替我们播放这个音频
    AudioServicesPlayAlertSound(soundID);
}

#pragma mark - 计算时间戳
+(NSString *)getRestTimeWithString:(NSString *)time dataFormatter:(NSString *)dateFormatter{
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = dateFormatter;
    NSDate *date = [formatter dateFromString:time];
    NSDate *newDate = [NSDate date];
    int s = [date timeIntervalSinceDate:newDate];
    int h = s/3600;
    int m = s%3600/60;
    s = s%60;
    
    
    return [NSString stringWithFormat:@"剩余:%.2d:%.2d:%.2d",h,m,s];
}

#pragma mark - 校验字典中键值对是否存在，存在则返回该字段，不存在则返回空
+(id)getValueWithKey:(id)key{
    if (key) {
        return key;
    }
    return nil;
}

@end


#pragma mark -- 跳转页面时候的效果动画
@implementation UIView (CCXTransitionAnimation)

- (void)setTransitionAnimationType:(CCXTransitionAnimationType)transtionAnimationType toward:(CCXTransitionAnimationToward)transitionAnimationToward duration:(NSTimeInterval)duration
{
    CATransition * transition = [CATransition animation];
    transition.duration = duration;
    NSArray * animations = @[@"cameraIris",
                             @"cube",
                             @"fade",
                             @"moveIn",
                             @"oglFilp",
                             @"pageCurl",
                             @"pageUnCurl",
                             @"push",
                             @"reveal",
                             @"rippleEffect",
                             @"suckEffect"];
    NSArray * subTypes = @[@"fromLeft",
                           @"fromRight",
                           @"fromTop",
                           @"fromBottom"];
    transition.type = animations[transtionAnimationType];
    transition.subtype = subTypes[transitionAnimationToward];
    
    [self.layer addAnimation:transition forKey:nil];
}

@end
