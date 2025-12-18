//
//  BaseRPFViewController.h
//  NIM
//
//  Created by King on 2019/2/2.
//  Copyright © 2019年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SVProgressHUD.h"



//#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
//#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
//#define STATUSBAR_HEIGHT [[UIApplication sharedApplication] statusBarFrame].size.height
//#define REDPACKET_COLOR [UIColor colorWithRed:229.0/255 green:65.0/255.0 blue:65.0/255 alpha:1.0]
//#define BASE_GRAY [UIColor grayColor]
//#define BGCOLOR_GRAY [UIColor colorWithRed:241.0/255 green:241.0/255 blue:241.0/255 alpha:1.0]


NS_ASSUME_NONNULL_BEGIN

@interface BaseRPFViewController : UIViewController
@property(nonatomic, assign)float statusBarHeight;

+(UIImage *)findImgFromBundle:(NSString *)bundleName andImgName:(NSString *)imgName;

@end

NS_ASSUME_NONNULL_END
