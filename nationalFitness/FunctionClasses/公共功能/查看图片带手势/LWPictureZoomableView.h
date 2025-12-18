//
//  HotPictureZoomableView.h
//  qmjs
//  扩展scroll view来显示秀图片并支持对图片的缩放
//  Copyright (c) 2014年. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWPictureZoomableView : UIScrollView

// 指定图片的url来显示图片内容
- (void)setupWithUrl:(NSString *)url;

// 指定图片的image来显示图片内容
- (void)setupWithImageData:(UIImage *)image;


@end
