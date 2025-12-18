//
//  HotPictureZoomableView.m
//

#import "LWPictureZoomableView.h"
#import "NFShowImageView.h"

@interface LWPictureZoomableView () <UIScrollViewDelegate>

@property (nonatomic, strong, readwrite) NFShowImageView *contentView;

@end


@implementation LWPictureZoomableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.delegate = self;
        self.backgroundColor = [UIColor blackColor];
        
        self.contentSize = CGSizeMake(frame.size.width, frame.size.height);
        
        _contentView = [[NFShowImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
//        _contentView = [[NFShowImageView alloc] initWithFrame:CGRectMake(0.0f, 64.0f, frame.size.width, frame.size.height)];
        _contentView.contentMode = UIViewContentModeScaleAspectFit;
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.minimumZoomScale = 1.0f;
        self.maximumZoomScale = 5.0f;
        [self addSubview:_contentView];
    }
    return self;
}

- (void)setupWithUrl:(NSString *)url
{
    if (!url || [url length] == 0) {
        return;
    }
    
    _contentView.notClipsToBounds = YES;
    //小图就显示本来大小，否则缩放靠边
    [_contentView ShowImageWithUrlStr:url completion:^(BOOL success, UIImage *image) {
        if (success)
        {
            CGFloat width = image.size.width;
            CGFloat height = image.size.height;
            if (width < SCREEN_WIDTH && height < SCREEN_HEIGHT)
            {
                _contentView.contentMode = UIViewContentModeCenter;
            }
        }
    }];
}

- (void)setupWithImageData:(UIImage *)image{
    if (![image isKindOfClass:[UIImage class]]) {
        return;
    }
    _contentView.image = image;
    
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    if (width < SCREEN_WIDTH && height < SCREEN_HEIGHT)
    {
        _contentView.contentMode = UIViewContentModeCenter;
    }
}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.contentView;
}

- (void)dealloc
{
    self.delegate = nil;
}

@end
