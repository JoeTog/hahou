//
//  NFAddImageCell.m
//  nationalFitness
//
//  Created by 程long on 14-11-22.
//  Copyright (c) 2014年 chenglong. All rights reserved.
//

#import "NFAddImageCell.h"
#import "SGPhotoPickerViewController.h"
#import "UIView+Animation.h"

@implementation NFAddImageCell
{
    
    __weak IBOutlet UICollectionView *photoConView;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    photoConView.delegate = self;
    photoConView.dataSource = self;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellWith:(NSIndexPath *)indexPath withCtrol:(PublishDynamicViewController *)ctrol
{
    [photoConView reloadData];
}

+(CGFloat)heightForCellWithData:(NSArray *)data{
    //一行几个
    //8*2因为左右都间隔8.   宽高为50
    NSLog(@"\n%f\n%f\n",(SCREEN_WIDTH - 15 * 2),(60 + 8*2));
    NSInteger count = (SCREEN_WIDTH - 15 * 2)/(60 + 5*2);
    //计算共多少行 (data.count + 1)因为多一个加号按钮 所以要加一
    NSInteger RowNumber = (data.count + 1)/count;
    //当除以最大容纳数 有余数 则加一行的高度
    if ((data.count + 1)%count > 0) {
        RowNumber++;
    }
    return (75 + 8)*RowNumber;
}

#pragma mark - UICollectionViewDataSource

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
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoCell" forIndexPath:indexPath];
    
    UIImageView *photoImage = (UIImageView *)[cell viewWithTag:1];
    UIButton *delBtn = (UIButton *)[cell viewWithTag:10];
    
    if (_picMuArr.count == kSelecetMax)
    {
        delBtn.hidden = NO;
        SGPhoto *temp = [_picMuArr objectAtIndex:indexPath.row];
        [photoImage setImage:temp.thumbnail];
    }
    else
    {
        if (indexPath.row == _picMuArr.count)
        {
            delBtn.hidden = YES;
            [photoImage setImage:[UIImage imageNamed:@"发布动态_addImage"]];
        }
        else
        {
            delBtn.hidden = NO;
            SGPhoto *temp = [_picMuArr objectAtIndex:indexPath.row];
            [photoImage setImage:temp.thumbnail];
        }
    }
    
    [delBtn addTarget:self action:@selector(deleteClick:event:) forControlEvents:UIControlEventTouchUpInside];
    
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
        if ([[self viewController] isKindOfClass:[NewHomeViewController class]])
        {
//            NewHomeViewController *ctrol = (NewHomeViewController *)[self viewController];
//            [ctrol selectPic];
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
    if ([[self viewController] isKindOfClass:[NewHomeViewController class]])
    {
//        NewHomeViewController *ctrol = (NewHomeViewController *)[self viewController];
        
        NSSet *touches = [event allTouches];
        UITouch *touch = [touches anyObject];
        CGPoint currentTouchPosition = [touch locationInView:photoConView ];
        NSIndexPath *indexPath = [photoConView indexPathForItemAtPoint:currentTouchPosition];
        if (indexPath)
        {
//            [ctrol deleteImageClick:indexPath.row];
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

@end
