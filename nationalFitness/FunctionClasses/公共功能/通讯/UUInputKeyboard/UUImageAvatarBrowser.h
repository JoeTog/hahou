//
//  UUAVAudioPlayer.h
//  BloodSugarForDoc
//
//  Created by shake on 14-9-1.
//  Copyright (c) 2014年 shake. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UUImageAvatarBrowser : NSObject

@property (nonatomic, strong) UIImage *editedImage;
@property (nonatomic, strong) UIImage *gettedImage;

@property (nonatomic, strong) UIImageView *showImgView;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIView *ratioView;

@property (nonatomic) CGRect oldFrame;
@property (nonatomic) CGRect largeFrame;
@property (nonatomic) CGFloat limitRatio;
@property (nonatomic) CGRect latestFrame;
@property (nonatomic) CGRect cropFrame;

//show imageView on the keyWindow
+(void)showImage:(UIImageView*)avatarImageView;

-(void)addGesture:(UIImageView *)imageView;



@end







