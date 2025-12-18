//
//  SGPhotoPreviewView.m
//  SmartCity
//
//  Created by sea on 14-4-16.
//  Copyright (c) 2014年 sea. All rights reserved.
//

#import "SGPhotoPreviewView.h"

@interface SGPhotoPreviewView () {
    
    UIImageView         *_imageView;
}

@end

@implementation SGPhotoPreviewView

- (void)setImage:(UIImage *)nImage {
    
    if (_image !=nImage) {
        
        _image = nImage;
        
        _imageView.image = _image;
    }
    
    CGFloat width = self.frame.size.width + 1;
    
    CGFloat height = self.frame.size.height + 1;
    
    self.contentSize = CGSizeMake(width, height);
    
    _imageView.frame = CGRectMake(0, 0, width, height);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor whiteColor];
        
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    [self addSubview:_imageView];
}



@end
