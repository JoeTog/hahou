//
//  CCXMethods.h
//  CCXPushAndPop01
//
//  Created by Chuanxi.Chen on 16/2/29.
//  Copyright © 2016年 Chuanxi.Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

@interface CCXMethods : NSObject

/**计算未来某一时刻到当前的时间差
 *time：表示未来某一时刻
 *dateFormatter:时间格式(yyyy-MM-dd hh:mm:ss.SS)
 */
+(NSString *)getRestTimeWithString:(NSString *)time dataFormatter:(NSString *)dateFormatter;

/**校验字典中键值对是否存在，存在则返回该字段，不存在则返回空
 *
 */
+(id)getValueWithKey:(id )key;



#pragma mark --读取文件URL
+(NSURL *)getURLWithName:(NSString *)name;

#pragma mark --播放短音频
+(void)playShortSoundWithName:(NSString *)soundName;

@end
#pragma mark -- 跳转页面时候的效果动画
/**＊＊＊＊＊＊使用步骤＊＊＊＊＊＊＊＊＊＊*/
/***1.添加QuartzCore.framework  ***/
/***2.导入头文件#import <QuartzCore/QuartzCore.h>***/

typedef enum
{
    CCXTransitionAnimationTypeCameraIris,
    //相机
    CCXTransitionAnimationTypeCube,
    //立方体
    CCXTransitionAnimationTypeFade,
    //淡入
    CCXTransitionAnimationTypeMoveIn,
    //移入
    CCXTransitionAnimationTypeOglFilp,
    //翻转
    CCXTransitionAnimationTypePageCurl,
    //翻去一页
    CCXTransitionAnimationTypePageUnCurl,
    //添上一页
    CCXTransitionAnimationTypePush,
    //平移
    CCXTransitionAnimationTypeReveal,
    //移走
    CCXTransitionAnimationTypeRippleEffect,
    CCXTransitionAnimationTypeSuckEffect
}CCXTransitionAnimationType;

/**动画方向*/
typedef enum
{
    CCXTransitionAnimationTowardFromLeft,
    CCXTransitionAnimationTowardFromRight,
    CCXTransitionAnimationTowardFromTop,
    CCXTransitionAnimationTowardFromBottom
}CCXTransitionAnimationToward;

@interface UIView (CCXTransitionAnimation)

//为当前视图添加切换的动画效果
//参数是动画类型和方向
//如果要切换两个视图，应将动画添加到父视图
- (void)setTransitionAnimationType:(CCXTransitionAnimationType)transtionAnimationType toward:(CCXTransitionAnimationToward)transitionAnimationToward duration:(NSTimeInterval)duration;

@end
