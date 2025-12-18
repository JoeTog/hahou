//
//  SGPhotoThumbnailView.m
//  SmartCity
//
//  Created by sea on 14-4-16.
//  Copyright (c) 2014年 sea. All rights reserved.
//

#import "SGPhotoThumbnailView.h"
#import "PublicDefine.h"

@implementation SGPhotoThumbnailView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor colorWithRed:230.0/255 green:231.0/255 blue:234.0/255 alpha:1.0];
        
        //预览图片栏
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        
        layout.itemSize = CGSizeMake(76, 76);
        layout.minimumInteritemSpacing = 2;
        
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        CGRect rect = self.bounds;
        //设置collectionview 稍微往里面去一点
        rect.origin.y += 2;
        rect.size.height -= 5;
        rect.size.height = rect.size.height;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
        
        [_collectionView setBackgroundColor:[UIColor whiteColor]];
        
        _collectionView.alwaysBounceVertical = YES;
        
        
        //用于分割的黄线
        
        //选中的图片显示的位置
        UICollectionViewFlowLayout *selectedLayout = [[UICollectionViewFlowLayout alloc] init];
        
        selectedLayout.itemSize = CGSizeMake(35, 35);
        selectedLayout.minimumInteritemSpacing = 2;
        selectedLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        CGRect selectedRect = CGRectMake(4, rect.origin.y + rect.size.height + 2, 236, 56);
        
        _selectedCollectionView = [[UICollectionView alloc] initWithFrame:selectedRect collectionViewLayout:selectedLayout];
        
        [_selectedCollectionView setBackgroundColor:[UIColor colorWithRed:230.0/255 green:231.0/255 blue:234.0/255 alpha:1.0]];
        _selectedCollectionView.alwaysBounceHorizontal = YES;
        
        
        
//        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        
//        _confirmButton.layer.masksToBounds = YES;
//        _confirmButton.layer.cornerRadius = 8;
//        
//        _confirmButton.backgroundColor = NFLightGreenColor;
//        
//        _confirmButton.frame = CGRectMake(SCREEN_WIDTH - 80,selectedRect.origin.y + (selectedRect.size.height - 35)/2 , 64, 35);
//        
//        [_confirmButton setTitle:@"确定(0)" forState:UIControlStateNormal];
//        _confirmButton.titleLabel.adjustsFontSizeToFitWidth = YES;
//        [_confirmButton setTitleColor:[UIColor colorWithRed:254.0/255 green:249.0/255 blue:238 alpha:1.0] forState:UIControlStateNormal];
        
    }
    return self;
}

- (void)dealloc {
    
    _collectionView = nil;
    _selectedCollectionView = nil;
    
//    _confirmButton = nil;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    [self addSubview:_collectionView];
    [self addSubview:_selectedCollectionView];
    
//    [self addSubview:_confirmButton];
}

@end



@interface SGPhotoPreviewViewCell () {
    
    UIImageView         *_selectedBackgroundView;//蒙面背景【当选中的时候 会是一个右上角是蓝色圆圈的背景】
    UILabel             *_checkmarkImageView;//选中的第几张图片
}

@end

@implementation SGPhotoPreviewViewCell

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        
        self.backgroundView = _imageView;
    }
    
    return self;
}


- (void)dealloc {
    
    _imageView = nil;
    
    _selectedBackgroundView = nil;
}


- (void)setCellSelected:(BOOL)selected {
    
    if (selected) {
        _selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"发布动态_selectImage"]];
        _selectedBackgroundView.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
        [self.contentView addSubview: _selectedBackgroundView];
        
        _checkmarkImageView = [[UILabel alloc]init];
        #pragma mark - 右上角圆圈
        _checkmarkImageView.font = [UIFont systemFontOfSize:selectedImageCountFontSize];
        _checkmarkImageView.textColor = [UIColor whiteColor];
        _checkmarkImageView.text = [NSString stringWithFormat:@"%ld",(long)self.picCount];
        _checkmarkImageView.textAlignment = NSTextAlignmentCenter;//设置label的文字为居中
#pragma mark - 右上角圆圈
        _checkmarkImageView.frame = CGRectMake(self.contentView.frame.size.width-20, 0, 20, 20);
        [_selectedBackgroundView addSubview:_checkmarkImageView];
        UIView *contentView = _checkmarkImageView;
        CAKeyframeAnimation * animation;
        animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        animation.duration = 0.3;
        animation.removedOnCompletion = YES;
        animation.fillMode = kCAFillModeForwards;
        
        NSMutableArray *values = [NSMutableArray array];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 0.9)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
        animation.values = values;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        [contentView.layer addAnimation:animation forKey:nil];
    }
    else {
        [_selectedBackgroundView removeFromSuperview];
    }
}

@end



@implementation SGPhotoSelectedViewCell

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        
        _imageView.layer.masksToBounds = YES;
        _imageView.layer.cornerRadius = 4;
        
        self.backgroundView = _imageView;
    }
    
    return self;
}


- (void)dealloc {
    
    _imageView = nil;
}

@end
