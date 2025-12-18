//
//  ChosePhoto.m
//  chosephoto
//
//  Created by 童杰 on 2017/3/2.
//  Copyright © 2017年 童杰. All rights reserved.
//

#import "ChosePhoto.h"
#import "PhotoCollectionViewCell.h"
#import "NFbaseViewController.h"
#import "PhotoLookBigPicViewController.h"


#define SCREEN_WIDTH                    [[UIScreen mainScreen] bounds].size.width

@implementation ChosePhoto{
    
    //记录整体frame
    CGRect rect_;
    //记录item的size
    CGSize size_;
    
    UICollectionView *CollectionV_;
    NSMutableArray *ImageArr;
    
    
    //记录添加的collection tag
    NSInteger tag_;
    
    
    //
    BOOL isClickDelete;
}

-(instancetype)initWithFrame:(CGRect)frame AndItemSize:(CGSize)size AndPhotos:(NSArray *)existImages Target:(id)Controller AndBlock:(void(^)(NSArray *imageArr))imageBlock{
    if (self) {
        self = [super initWithFrame:frame];
        if (_imageBack != imageBlock) {
            _imageBack = nil;
            _imageBack = imageBlock;
        }
        rect_ = frame;
        size_ = size;
        _photoViewDele = Controller;
        self.isCanEdit = YES;
        ImageArr = [NSMutableArray arrayWithArray:existImages];
        self.backgroundColor = [UIColor whiteColor];
        [self costomView];
    }
    return self;
}

-(void)setViewBackColor:(UIColor *)ViewBackColor{
    self.backgroundColor = ViewBackColor;
}

-(void)setCollectionViewBackColor:(UIColor *)CollectionViewBackColor{
    CollectionV_.backgroundColor = CollectionViewBackColor;
}



-(void)costomView{
    
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    //行之间最小距离
//    flowLayout.minimumLineSpacing = 10;
    //列之间最小距离
    flowLayout.minimumInteritemSpacing = 10;
    flowLayout.itemSize = CGSizeMake(size_.width, size_.height);
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 10);
    CollectionV_ = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, rect_.size.width, rect_.size.height) collectionViewLayout:flowLayout];
    CollectionV_.delegate = self;
    CollectionV_.dataSource = self;
    CollectionV_.backgroundColor = [UIColor whiteColor];
    UINib * nib = [UINib nibWithNibName:@"PhotoCollectionViewCell" bundle:[NSBundle mainBundle]];
    [CollectionV_ registerNib:nib forCellWithReuseIdentifier:@"PhotoCollectionViewCell"];
    CollectionV_.showsHorizontalScrollIndicator = NO;
    
    [self addSubview:CollectionV_];
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (self.isCanEdit) {
        return ImageArr.count + 1;
    }
    return ImageArr.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *ImgArr = [NSArray arrayWithArray:ImageArr];
    PhotoCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCollectionViewCell" forIndexPath:indexPath];
    if (self.isCanEdit) {
        if (indexPath.item == 0) {
            cell.titleImageV.image = [UIImage imageNamed:@"shop6_tj"];
            cell.deleteBtn.hidden = YES;
//            [cell.deleteBtn removeFromSuperview];
            return cell;
        }
        //不仅有框 而且要可编辑图片 才能显示删除按钮
        if (self.isCanTouchPhoto) {
            cell.deleteBtn.hidden = NO;
        }else{
            cell.deleteBtn.hidden = YES;
        }
        //判断是否能够点击添加图片 如果不能添加图片 说明为展示 所以也需要隐藏叉号
        if (!self.isCanTouchPhoto) {
            cell.deleteBtn.hidden = YES;
        }
        //NSLog(@"%ld",(long)indexPath.item);
        [cell.titleImageV sd_setImageWithURL:[NSURL URLWithString:ImgArr[indexPath.item - 1]] placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
//        [cell.titleImageV setImage:ImgArr[indexPath.item - 1]];
        cell.deleteBtn.tag = 100+indexPath.item;
        [cell.deleteBtn addTarget:self action:@selector(deleteBtnClick:) forControlEvents:UIControlEventTouchDown];
    }else{
        
        [cell.titleImageV sd_setImageWithURL:[NSURL URLWithString:ImgArr[indexPath.item]] placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
        cell.deleteBtn.hidden = YES;
//        cell.deleteBtn.tag = 100+indexPath.item;
//        [cell.deleteBtn addTarget:self action:@selector(deleteBtnClick:) forControlEvents:UIControlEventTouchDown];
    }
    return cell;
    
}

-(void)deleteBtnClick:(UIButton *)sender{
    isClickDelete = YES;
    NSInteger index = sender.tag%100;
    if (ImageArr.count >= index) {
        [ImageArr removeObjectAtIndex:index - 1];
        NSString *deleteIndex = [NSString stringWithFormat:@"%ld",index - 1];
        self.imageBack(@[@{@"deleteIndex":deleteIndex}]);
        [CollectionV_ reloadData];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    if (!self.isCanEdit) {
//        return;
//    }
    //当isCanTouchPhoto为NO 不给添加图片 isCanEdit为NO 不显示加号框 为YES显示加号框
    if (!self.isCanTouchPhoto && indexPath.item == 0 && self.isCanEdit) {
        self.imageBack(@[@"PopView"]);
        return;
    }
    
    if (indexPath.item == 0 && self.isCanEdit) {
        //如果有最大张数限制 当上传张数到限制时候不给上传
        if (self.MaxCount != 0 && ImageArr.count>=self.MaxCount) {
            self.imageBack(@[@{@"maxCount":@"yes"}]);
            return;
        }
//        tag_ = collectionView.tag;
        UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil
                                                            delegate:self
                                                   cancelButtonTitle:@"取消"
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:@"拍照",@"从手机相册取", nil];
        
        action.actionSheetStyle = UIActionSheetStyleDefault;
        
        [action showInView:self];
    }else{
//        PhotoLookBigPicViewController *toCtrol = [[PhotoLookBigPicViewController alloc] init];
//        NSMutableArray *bigPicArr = [NSMutableArray new];
//        for (NSMutableString *pic in ImageArr) {
//            NSString *picPath = [pic stringByReplacingOccurrencesOfString:@"_small" withString:@""];
//            [bigPicArr addObject:picPath];
//        }
//        toCtrol.picMapList = bigPicArr;
//        if (self.isCanEdit) {
//            toCtrol.currentPage = indexPath.item - 1;
//        }else{
//            toCtrol.currentPage = indexPath.item;
//        }
//        toCtrol.currentPage = 1;
        //    [self.view.superview setTransitionAnimationType:(CCXTransitionAnimationTypeCube) toward:(CCXTransitionAnimationTowardFromRight) duration:0.5];
//        [[KeepAppBox viewController:self].navigationController pushViewController:toCtrol animated:YES];
        
        
        HDPictureShowViewController *showImageViewCtrol = [[HDPictureShowViewController alloc] init];
        showImageViewCtrol.imageUrlList = ImageArr;
        if (self.isCanEdit) {
            showImageViewCtrol.mainImageIndex = indexPath.item - 1;
        }else{
            showImageViewCtrol.mainImageIndex = indexPath.item;
        }
        showImageViewCtrol.isLuoYang = YES;
        showImageViewCtrol.isNeedNavigation = YES;
        [[KeepAppBox viewController:self].navigationController pushViewController:showImageViewCtrol animated:YES];
        
    }
    
}

- (UIViewController *)viewController
{
    for (UIView *next = [self superview]; next; next = next.superview)
    {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]])
        {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
        {
            [self takeCameral];
        }
            break;
        case 1:
        {
            [self searchLibrary];
        }
            break;
        default:
            break;
    }
}

#pragma mark - UIActionSheetDelegate
- (void)takeCameral
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        [imagePicker setAllowsEditing:NO];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        if (@available(iOS 13.0, *)) {
            imagePicker.modalPresentationStyle =UIModalPresentationFullScreen;
        }
        [_photoViewDele presentViewController:imagePicker animated:YES completion:nil];
    }else{
//        [SVProgressHUD showInfoWithStatus:@"相机不可用"];
    }
}

- (void)searchLibrary
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        [imagePicker setAllowsEditing:NO];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        if (@available(iOS 13.0, *)) {
            imagePicker.modalPresentationStyle =UIModalPresentationFullScreen;
        }
        [_photoViewDele presentViewController:imagePicker animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [self imageByScalingToMaxSize:portraitImg];
        //将选择的照片储存起来，用于后面的点击查看详情
//        [ImageArr addObject:portraitImg];
//        [CollectionV_ reloadData];
        NSArray *imgArr = @[portraitImg];
        self.imageBack(imgArr);
    }];
}

#pragma mark - Image Scale Utility

- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage
{
    if (sourceImage.size.width < SCREEN_WIDTH * 2) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = SCREEN_WIDTH * 2;
        btWidth = sourceImage.size.width * (SCREEN_WIDTH * 2 / sourceImage.size.height);
    } else {
        btWidth = SCREEN_WIDTH * 2;
        btHeight = sourceImage.size.height * (SCREEN_WIDTH * 2 / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}




@end
