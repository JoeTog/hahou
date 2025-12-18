//
//  NFShowPictureView.h
//  newTestUe
//  活动照片墙的展现方式
//  Created by 程龙 on 15/12/15.
//  Copyright © 2015年 程龙. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NFShowPictureView : UIView

//给照片墙上的照片传递值
- (void)setPictureArr:(NSArray *)pictureArr isFromLocal:(BOOL)local;

@end
