//
//  NFShowImageView.m
//  nationalFitness
//
//  Created by 程long on 14-11-5.
//  Copyright (c) 2014年 chenglong. All rights reserved.
//

#import "NFShowImageView.h"
#import "Photo.h"
#import "UIImage+RoundedResize.h"

@implementation NFShowImageView

/**
 *  给自己添加圆角
 */
- (void)awakeFromNib
{
    [super awakeFromNib];
//    self.backgroundColor = [UIColor lightGrayColor];
}

- (void)ShowImageWithUrlStr: (NSString *)URLStr completion:(ResultDown)completion
{
    //居中显示
    if (!_notClipsToBounds)
    {
        if (self.contentMode != UIViewContentModeScaleAspectFill)
        {
            self.contentMode = UIViewContentModeScaleAspectFill;
        }
        if (!self.clipsToBounds)
        {
            self.clipsToBounds = YES;
        }
    }
    else
    {
        //do nothing
    }
    
    self.image = nil;
    
    SDWebImageManager *webImageManager = [SDWebImageManager sharedManager];
    webImageManager.delegate = self;
    NSURL *url = [NSURL URLWithString:URLStr];
    
//    [self sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"hot_send_gray_img"]
//                     options:SDWebImageRetryFailed
//                    progress:nil
//                   completed:nil];
    
    //先选择本地缓存，没有再下载
    UIImage *headImage;
    headImage = [UIImage imageNamed:URLStr];
    if (headImage) {
        [self setImage:headImage];
        //headImage = [UIImage imageNamed:defaultHeadImaghe];
        return;
    }
    if ([URLStr containsString:@"null"] || URLStr.length == 0) {
        headImage = [UIImage imageNamed:defaultHeadImaghe];
        [self setImage:headImage];
        return;
    }
    if ([webImageManager diskImageExistsForURL:url])
    {
        headImage = [webImageManager.imageCache imageFromDiskCacheForKey:[webImageManager cacheKeyForURL:url]];
        
        [self setImage:headImage];
        if (completion)
        {
            completion(YES, headImage);
        }
    }
    else
    {
        [[SDWebImageManager sharedManager] downloadImageWithURL:url
                                                        options:SDWebImageRetryFailed
                                                       progress:nil
                                                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                          if (image)
                                                          {
                                                              if (completion)
                                                              {
                                                                  completion(YES, image);
                                                              }
                                                              self.alpha = 0.0;
                                                              [UIView transitionWithView:self
                                                                                duration:0.6
                                                                                 options:UIViewAnimationOptionTransitionCrossDissolve
                                                                              animations:^{
                                                                                  [self setImage:image];
                                                                                  self.alpha = 1.0;
                                                                              } completion:NULL];
                                                          }
                                                          else
                                                          {
                                                              if (completion)
                                                              {
                                                                  completion(NO, nil);
                                                              }
                                                          }
                                                      }];
    }
}

- (void)ShowImageWithUrlStr: (NSString *)URLStr placeHoldName:(NSString *)placeHold completion:(ResultDown)completion
{
    //居中显示
    if (!_notClipsToBounds)
    {
        if (self.contentMode != UIViewContentModeScaleAspectFill)
        {
            self.contentMode = UIViewContentModeScaleAspectFill;
        }
        if (!self.clipsToBounds)
        {
            self.clipsToBounds = YES;
        }
    }
    else
    {
        //do nothing
    }
    
    self.image = nil;
    SDWebImageManager *webImageManager = [SDWebImageManager sharedManager];
    webImageManager.delegate = self;
    NSURL *url = [NSURL URLWithString:URLStr];
    
    //    [self sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"hot_send_gray_img"]
    //                     options:SDWebImageRetryFailed
    //                    progress:nil
    //                   completed:nil];
    
    //先选择本地缓存，没有再下载
    UIImage *headImage;
    if (URLStr.length < 10) {
        headImage = [UIImage imageNamed:URLStr];
        if (headImage) {
            [self setImage:headImage];
            return;
        }
    }
    //设置placehold
    [self setImage:[UIImage imageNamed:placeHold]];
    
    if ([webImageManager diskImageExistsForURL:url])
    {
        headImage = [webImageManager.imageCache imageFromDiskCacheForKey:[webImageManager cacheKeyForURL:url]];
        
        [self setImage:headImage];
        if (completion)
        {
            completion(YES, headImage);
        }
    }
    else
    {
        
        [[SDWebImageManager sharedManager] downloadImageWithURL:url
                                                        options:SDWebImageRetryFailed
                                                       progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//                                                           NSLog(@"\n\ncompelte:%.2f\n\n",(float)receivedSize/(float)expectedSize);
                                                       }completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                          if (image)
                                                          {
                                                              if (completion)
                                                              {
                                                                  completion(YES, image);
                                                              }
                                                              self.alpha = 0.0;
                                                              [UIView transitionWithView:self
                                                                                duration:0.6
                                                                                 options:UIViewAnimationOptionTransitionCrossDissolve
                                                                              animations:^{
                                                                                  [self setImage:image];
                                                                                  self.alpha = 1.0;
                                                                              } completion:NULL];
                                                          }
                                                          else
                                                          {
                                                              if (completion)
                                                              {
                                                                  completion(NO, nil);
                                                              }
                                                          }
                                                      }];
    }
}

#pragma mark - 加载图片带placehold和下载进度百分比
- (void)ShowImageWithUrlStr: (NSString *)URLStr placeHoldName:(NSString *)placeHold completion:(ResultDown)completion progressBlock:(ReturnProgressBlock)block{
    if (self.returnProgressBlock != block) {
        self.returnProgressBlock = block;
    }
    //居中显示
    if (!_notClipsToBounds)
    {
        if (self.contentMode != UIViewContentModeScaleAspectFill)
        {
            self.contentMode = UIViewContentModeScaleAspectFill;
        }
        if (!self.clipsToBounds)
        {
            self.clipsToBounds = YES;
        }
    }
    else
    {
        //do nothing
    }
    
    self.image = nil;
    
    SDWebImageManager *webImageManager = [SDWebImageManager sharedManager];
    webImageManager.delegate = self;
    NSURL *url = [NSURL URLWithString:URLStr];
    
    //    [self sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"hot_send_gray_img"]
    //                     options:SDWebImageRetryFailed
    //                    progress:nil
    //                   completed:nil];
    
    //先选择本地缓存，没有再下载
    UIImage *headImage;
    if (URLStr.length < 10) {
        headImage = [UIImage imageNamed:URLStr];
        if (headImage) {
            [self setImage:headImage];
            return;
        }
    }
    //设置placehold
    [self setImage:[UIImage imageNamed:placeHold]];
    
    if ([webImageManager diskImageExistsForURL:url])
    {
        headImage = [webImageManager.imageCache imageFromDiskCacheForKey:[webImageManager cacheKeyForURL:url]];
        
        [self setImage:headImage];
        if (completion)
        {
            completion(YES, headImage);
        }
    }
    else
    {
        
        [[SDWebImageManager sharedManager] downloadImageWithURL:url
                                                        options:SDWebImageRetryFailed
                                                       progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                           NSLog(@"\n\ncompelte:%.2f\n\n",(float)receivedSize/(float)expectedSize); self.returnProgressBlock((float)receivedSize/(float)expectedSize);
                                                       }completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                           if (image)
                                                           {
                                                               if (completion)
                                                               {
                                                                   completion(YES, image);
                                                               }
                                                               self.alpha = 0.0;
                                                               [UIView transitionWithView:self
                                                                                 duration:0.6
                                                                                  options:UIViewAnimationOptionTransitionCrossDissolve
                                                                               animations:^{
                                                                                   [self setImage:image];
                                                                                   self.alpha = 1.0;
                                                                               } completion:NULL];
                                                           }
                                                           else
                                                           {
                                                               if (completion)
                                                               {
                                                                   completion(NO, nil);
                                                               }
                                                           }
                                                       }];
    }
}



- (UIImage *)imageManager:(SDWebImageManager *)imageManager transformDownloadedImage:(UIImage *)image withURL:(NSURL *)imageURL {
    
    CGFloat w_c_640 = image.size.width/640 ;
    CGFloat h_c_1136 = image.size.height/1136;
    
    CGFloat c_width;
    CGFloat c_height;
    
    if (w_c_640 > 1.0) {
        // 宽大
        c_width = 640;
    } else {
        c_width = image.size.width;
    }
    
    if (h_c_1136 > 1.0) {
        // 高也大
        c_height = 1136;
    } else {
        c_height = image.size.height;
    }
    
    if (image.size.width/image.size.height >= 1) {
        // 宽比高 大
        c_height = c_width * (image.size.height/image.size.width);
    } else if (image.size.width/image.size.height < 1) {
        // 高比宽 大
        c_width = c_height *(image.size.width/image.size.height);
    }
    
    
    UIImage *tmpImage = [image imageByScalingAndCroppingForSize:CGSizeMake(c_width, c_height)];
    
    [imageManager saveImageToCache:tmpImage forURL:imageURL];
    
    return tmpImage;
}

- (void)dealloc
{

}

@end
