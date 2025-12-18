//
//  GQImageView.m
//  GQImageVideoViewer
//
//  Created by 高旗 on 16/9/8.
//  Copyright © 2016年 gaoqi. All rights reserved.
//

#import "GQImageView.h"
#import "GQImageViewerConst.h"

@interface GQImageView()

@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@end

@implementation GQImageView

#pragma mark -- life cycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupInit];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupInit];
    }
    return self;
}

- (void)setupInit {
    [self configureImageView];
    self.showLoadingView = YES;
    self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
}

#pragma mark -- public method

- (void)setProgress:(CGFloat)progress {
    [self willChangeValueForKey:@"progress"];
    _progress = progress;
    [self didChangeValueForKey:@"progress"];
}

- (void)configureImageView {
    
}

-(void)showLoading
{
    if (!self.showLoadingView) {
        return;
    }
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicator.center = CGPointMake(self.bounds.origin.x+(self.bounds.size.width/2), self.bounds.origin.y+(self.bounds.size.height/2));
        [_indicator setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin];
    }
    if (!_indicator.isAnimating||_indicator.hidden) {
        _indicator.hidden = NO;
        if(!_indicator.superview){
            [self addSubview:_indicator];
        }
        [_indicator startAnimating];
    }
}

-(void)hideLoading
{
    if (!self.showLoadingView) {
        return;
    }
    if (_indicator) {
        [_indicator stopAnimating];
        _indicator.hidden = YES;
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





@end

