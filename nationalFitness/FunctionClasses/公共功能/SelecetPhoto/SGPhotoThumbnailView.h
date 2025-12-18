//
//  SGPhotoThumbnailView.h
//  SmartCity
//  collectionview 选照片的cell 【主要用于展示图片 和 图片选中后的变更】
//  Created by sea on 14-4-16.
//  Copyright (c) 2014年 sea. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - 右上角圆圈
#define selectedImageCountFontSize 15 //选中图片右上角字体size


@interface SGPhotoThumbnailView : UIView

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionView *selectedCollectionView;

//@property (nonatomic, strong) UIButton         *confirmButton;

@end




@interface SGPhotoPreviewViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, assign) NSInteger picCount;

- (void)setCellSelected:(BOOL)selected;

@end


@interface SGPhotoSelectedViewCell : UICollectionViewCell

@property (nonatomic, strong)UIImageView *imageView;

@end
