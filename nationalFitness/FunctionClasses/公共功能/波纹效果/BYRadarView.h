//
//  BYRadarView.h
//  Animation
//
//  Created by apple on 16/6/24.
//  Copyright © 2016年 Bangyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BYRadarView : UIView<CAAnimationDelegate>

@property (nonatomic, strong)UIColor * color;
@property (nonatomic, strong)UIColor * borderColor;
@property (nonatomic, assign)float  borderWidth;
@property (nonatomic, assign)double pulsingCount;           //雷达上波纹的条数
@property (nonatomic, assign)double duration;              //动画时间
@property (nonatomic, assign)float repeatCount;
@property (nonatomic, strong)CALayer * pulsingLayer;

- (void)animation;

@end
