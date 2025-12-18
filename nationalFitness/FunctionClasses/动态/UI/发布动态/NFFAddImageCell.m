//
//  NFFAddImageCell.m
//  nationalFitness
//
//  Created by Joe on 2017/7/7.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "NFFAddImageCell.h"

#import "SGPhotoPickerViewController.h"
#import "UIView+Animation.h"

@implementation NFFAddImageCell{
    
    
    __weak IBOutlet UICollectionView *photoConView;
    
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    photoConView.delegate = self;
    photoConView.dataSource = self;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UINib * nib = [UINib nibWithNibName:@"AddImageCollectionViewCell" bundle:[NSBundle mainBundle]];
    [photoConView registerNib:nib forCellWithReuseIdentifier:@"AddImageCollectionViewCell"];
}

- (void)setCellWith:(NSIndexPath *)indexPath SGPhotoImageArr:(NSArray *)imageArr withCtrol:(PublishDynamicViewController *)ctrol
{
    _picMuArr = [NSMutableArray arrayWithArray:imageArr];
    [photoConView reloadData];
}


#pragma mark - UICollectionViewDataSource

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(8, 8, 8, 8);
    
}

//列之间最小间距
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 8;
}

//行之间最小间距
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 8;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(60, 60);
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (_picMuArr.count == kSelecetMax)
    {
        return kSelecetMax;
    }
    
    return _picMuArr.count + 1;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AddImageCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AddImageCollectionViewCell" forIndexPath:indexPath];
    
    if (_picMuArr.count == kSelecetMax)
    {
        cell.delBtn.hidden = NO;
        SGPhoto *temp = [_picMuArr objectAtIndex:indexPath.row];
        [cell.photoImage setImage:temp.thumbnail];
    }
    else
    {
        if (indexPath.row == _picMuArr.count)
        {
            cell.delBtn.hidden = YES;
            [cell.photoImage setImage:[UIImage imageNamed:@"发布动态_addImage"]];
        }
        else
        {
            cell.delBtn.hidden = NO;
            SGPhoto *temp = [_picMuArr objectAtIndex:indexPath.row];
            [cell.photoImage setImage:temp.thumbnail];
        }
    }
    
    [cell.delBtn addTarget:self action:@selector(deleteClick:event:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

//点击照片具体事件
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_picMuArr.count == kSelecetMax)
    {
        if (_picMuArr.count>indexPath.row)
        {
            SGPhoto *temp = [_picMuArr objectAtIndex:indexPath.row];
            [self showImageOnSubview:temp.fullResolutionImage];
        }
        return;
    }
    else if(indexPath.row == _picMuArr.count)
    {
        if ([[self viewController] isKindOfClass:[PublishDynamicViewController class]])
        {
            PublishDynamicViewController *ctrol = (PublishDynamicViewController *)[self viewController];
            [ctrol selectPic];
        }
    }else
    {
        if (_picMuArr.count>indexPath.row)
        {
            SGPhoto *temp = [_picMuArr objectAtIndex:indexPath.row];
            [self showImageOnSubview:temp.fullResolutionImage];
        }
    }
}

#pragma mark - 显示图片的视图－临时-多图需换成scrollview目前是view

-(void)showImageOnSubview :(UIImage *)showImage
{
    CGFloat Times = fabs(showImage.size.width / 320);
    CGFloat width =   showImage.size.width;
    CGFloat height =  showImage.size.height;
    if (Times > 1)
    {
        width = width / Times;
        height = height / Times;
    }
    UIView *showView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - width) / 2, (SCREEN_HEIGHT - height) / 2, width, height)];
    
    UITapGestureRecognizer *hideView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideImageOnSubview)];
    [showView addGestureRecognizer:hideView];
    
    UIImageView *showimageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [showimageView setImage:showImage];
    [showView addSubview:showimageView];
    
    [UIView showView:showView animateType:AnimateTypeOfPopping finalRect:showView.frame];
}

-(void)hideImageOnSubview
{
    [UIView hideView];
}


//删除照片
- (void)deleteClick :(id)sender event:(UIEvent *)event
{
    if ([[self viewController] isKindOfClass:[PublishDynamicViewController class]])
    {
        PublishDynamicViewController *ctrol = (PublishDynamicViewController *)[self viewController];
        
        NSSet *touches = [event allTouches];
        UITouch *touch = [touches anyObject];
        CGPoint currentTouchPosition = [touch locationInView:photoConView ];
        NSIndexPath *indexPath = [photoConView indexPathForItemAtPoint:currentTouchPosition];
        if (indexPath)
        {
                        [ctrol deleteImageClick:indexPath.row];
        }
    }
}

//找到父类
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

- (void)dealloc
{
    photoConView.delegate = nil;
    photoConView.dataSource = nil;
    _picMuArr = nil;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
