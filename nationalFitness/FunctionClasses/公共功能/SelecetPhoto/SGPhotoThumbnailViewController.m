//
//  SGPhotoPreviewViewController.m
//  SmartCity
//
//  Created by sea on 14-4-16.
//  Copyright (c) 2014年 sea. All rights reserved.
//

#import "SGPhotoThumbnailViewController.h"

#import "SGPhotoThumbnailView.h"

#import "SGPhotoPreviewViewController.h"

#import "SGPhotoPickerViewController.h"

@interface SGPhotoThumbnailViewController ()<UICollectionViewDataSource, UICollectionViewDelegate> {
    
    NSString            *_cellIdentifier;
    NSString            *_selectedCellIdentifier;
    
    NSMutableArray      *_photoArray;
    
    NSMutableArray      *_selectedArray;//当前分组下选中的图片
    
    NSMutableArray      *_allSelectedArray;//所有分组下选中的图片 note:存放的数据类型为SGPhoto
    
    PIC_SELECET_COUNT   _picCount;//选中图片限制
    
    UIButton *_clickBtn;
    
    NSInteger selectedImage; // 已经选中的图片个数
}

@end

@implementation SGPhotoThumbnailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithPicCount: (PIC_SELECET_COUNT)picCount
{
    self = [super init];
    if (self)
    {
        _picCount = picCount;
    }
    return self;
}

- (void)dealloc {
    
    _selectedArray = nil;
    _allSelectedArray = nil;
    
    [self removeObserver:self forKeyPath:@"_allSelectedArray"];
    
}

- (void)loadView {
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    
    ////kStatusBarHeight kNavBarHeight
    NSLog(@"self.navigationController.navigationBar.frame.size.height =%f",self.navigationController.navigationBar.frame.size.height);
    
    //kTabBarHeight
    //HitoSafeAreaHeight
    frame.size.height = frame.size.height - kStatusBarHeight - kNavBarHeight;
    
    _photoThumbnailView = [[SGPhotoThumbnailView alloc] initWithFrame:frame];
    
    self.view = _photoThumbnailView;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = [_group valueForProperty:ALAssetsGroupPropertyName];
    
    _cellIdentifier = @"photoCellIdentifier";
    
    _photoThumbnailView.collectionView.delegate = self;
    _photoThumbnailView.collectionView.dataSource = self;
    
    [_photoThumbnailView.collectionView registerClass:[SGPhotoPreviewViewCell class] forCellWithReuseIdentifier:_cellIdentifier];
    
    //默认使用多选模式
    _photoThumbnailView.collectionView.allowsMultipleSelection = YES;
    
    
    _selectedCellIdentifier = @"photoSelectedCellIdentifier";
    
    
    _photoThumbnailView.selectedCollectionView.dataSource = self;
    
    [_photoThumbnailView.selectedCollectionView registerClass:[SGPhotoSelectedViewCell class] forCellWithReuseIdentifier:_selectedCellIdentifier];
    
    if (!_photoArray) {
        
        _photoArray = [[NSMutableArray alloc] init];
    }
    
    if (!_selectedArray) {
        
        _selectedArray = [[NSMutableArray alloc] init];
    }
    
    if (!_allSelectedArray) {
        
        _allSelectedArray = [[NSMutableArray alloc] initWithArray:self.originalSelectedArray];
        
        [self addObserver:self forKeyPath:@"_allSelectedArray" options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    [self createControlInNavigationBar];
    
    
    [self getPhotosAtGroup];
    
    //由于在getPhotosAtGroup方法中已经将_selectedArray的值初始化,因此在此处将确定按钮上的数字也重新初始化
    [_clickBtn setTitle:[NSString stringWithFormat:@"完成(%@/%@)",@(_allSelectedArray.count),@(_picCount)] forState:UIControlStateNormal];
    selectedImage = _allSelectedArray.count;
}


//TODO: 创建NavigationBar上的控件
- (void)createControlInNavigationBar {
    
    // 设置 navigation bar 右侧按钮
    _clickBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 65, 27)];
    _clickBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [_clickBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_clickBtn addTarget:self action:@selector(confirmButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    _clickBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    ViewRadius(_clickBtn, 2);
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_clickBtn];
    self.navigationItem.rightBarButtonItem = leftButtonItem;

    
   /* 
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    rightButton.frame = CGRectMake(0, 0, 40, 40);
    
    [rightButton addTarget:self action:@selector(rightButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.titleLabel.font  = [UIFont boldSystemFontOfSize:16.0f];
    [rightButton setTitle:@"预览" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor colorWithRed:95/255.0 green:94/255.0 blue:95/255.0 alpha:1.0] forState:UIControlStateNormal];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [_allSelectedArray removeAllObjects];
    [_selectedArray removeAllObjects];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

//TODO: 确定按钮点击事件
- (void)confirmButtonClicked:(UIButton *)button {
    
    if ([_thumbnailDelegate respondsToSelector:@selector(thumbnailFinishSelected:)]) {
        
        [_thumbnailDelegate thumbnailFinishSelected:_allSelectedArray];
    }
}

- (void)rightButtonClicked:(UIButton *)button {
    
    //如果是多选模式,取消多选模式,用户可点击缩略图放大图片
    if (_photoThumbnailView.collectionView.allowsMultipleSelection) {
        
        _photoThumbnailView.collectionView.allowsMultipleSelection = NO;
        
        [button setTitle:@"取消" forState:UIControlStateNormal];
        
        [_photoThumbnailView.collectionView reloadData];
    }
    else {//如果是非“选择模式”,则开启选择模式,之前用户选择的图片不丢失
        
        [button setTitle:@"预览" forState:UIControlStateNormal];
        _photoThumbnailView.collectionView.allowsMultipleSelection = YES;
       
        NSMutableArray *indexArray = [[NSMutableArray alloc] initWithCapacity:_selectedArray.count];
        
        //将选中已经选中过的图片重新恢复选中状态
        for (ALAsset *asset in _selectedArray) {
            
            NSUInteger row = [_photoArray indexOfObject:asset];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:row inSection:0];
            
            [indexArray addObject:indexPath];
            
            [_photoThumbnailView.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        }

        [_photoThumbnailView.collectionView reloadItemsAtIndexPaths:indexArray];
        
    }
}

//TODO: 获取分组下的照片数组,并在枚举过程中,标记已经被选中的图片
- (void)getPhotosAtGroup {
    
    [_photoArray removeAllObjects];
    
    [_group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {//从group里面
        
        
        if (!result) {
        
            [_photoThumbnailView.collectionView reloadData];
            
            if ([_photoArray count]>0)
            {
                [_photoThumbnailView.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:(_photoArray.count -1) inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
            }
        }
        else {
            
            NSString* assetType = [result valueForProperty:ALAssetPropertyType];
            
            if ([assetType isEqualToString:ALAssetTypePhoto]) {
                
                [_photoArray addObject:result];
                
                //比较枚举出的图片是否已经在被选中的原始数组中
                NSString *identifier = [result valueForProperty:ALAssetPropertyAssetURL];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.identifier == %@",identifier];
                
                NSArray *results = [self.originalSelectedArray filteredArrayUsingPredicate:predicate];
                
                if (results.count == 1) {
                    
                    //如果存在,则将枚举出的照片asset放置到_selectedArray中
                    if (![_selectedArray containsObject:result]) {
                        
                        [_selectedArray addObject:result];
                    }
                }
            }
        }
    }];
}



- (void)addSGPhotoInAllSelectedArray:(ALAsset *)asset {
    
    //比较枚举出的图片是否已经在被选中的数组中
    NSString *identifier = [asset valueForProperty:ALAssetPropertyAssetURL];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.identifier == %@",identifier];
    
    NSArray *results = [_allSelectedArray filteredArrayUsingPredicate:predicate];
    
    if (results.count == 0) {//如果为新增图片
        
        SGPhoto *photo = [[SGPhoto alloc] init];
        
        photo.identifier = [asset valueForProperty:ALAssetPropertyAssetURL];
        photo.thumbnail = [UIImage imageWithCGImage:[asset thumbnail]];
        photo.fullResolutionImage = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
        
        //将新增的图片放置到存放所有选中图片的数组中
        if (![_allSelectedArray containsObject:photo]) {
            
            [self willChangeValueForKey:@"_allSelectedArray"];
            
            [_allSelectedArray addObject:photo];
            
            [self didChangeValueForKey:@"_allSelectedArray"];
        }
        
        //如果存在,则将枚举出的照片asset放置到当前分组选中图片的数组中
        if (![_selectedArray containsObject:asset]) {
            
            [_selectedArray addObject:asset];
        }
    }
}


- (void)removeSGPhotoInAllSelectedArray:(ALAsset *)asset {
    
    //比较枚举出的图片是否已经在被选中的数组中
    NSString *identifier = [asset valueForProperty:ALAssetPropertyAssetURL];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.identifier == %@",identifier];
    
    NSArray *results = [_allSelectedArray filteredArrayUsingPredicate:predicate];
    
    if (results.count == 1) {
        
        SGPhoto *photo = [results firstObject];
        
        if ([_allSelectedArray containsObject:photo]) {
            
            [self willChangeValueForKey:@"_allSelectedArray"];
            
            [_allSelectedArray removeObject:photo];
            
            [self didChangeValueForKey:@"_allSelectedArray"];
        }
        
        //如果存在,则将枚举出的照片asset放置到_selectedArray中
        if ([_selectedArray containsObject:asset]) {
            
            [_selectedArray removeObject:asset];
        }
    }
}

#pragma mark -
#pragma mark KVO Delegate Methods
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
        
    if ([keyPath isEqualToString:@"_allSelectedArray"]) {//当存放选中的数组发生变化时,更新下方的视图
        
        [_clickBtn setTitle:[NSString stringWithFormat:@"完成(%@/%@)",@(_allSelectedArray.count + selectedImage),@(_picCount)] forState:UIControlStateNormal];
        [_photoThumbnailView.selectedCollectionView reloadData];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (collectionView == _photoThumbnailView.collectionView) {
        
        return _photoArray.count;
    }
    else if (collectionView == _photoThumbnailView.selectedCollectionView) {
        
        return _allSelectedArray.count;
    }
    
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == _photoThumbnailView.collectionView) {
        
        SGPhotoPreviewViewCell *cell = (SGPhotoPreviewViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:_cellIdentifier forIndexPath:indexPath];
        
        ALAsset *asset =  [_photoArray objectAtIndex:indexPath.row];
        
        //判断照片是否被选中
        if (collectionView.allowsMultipleSelection && [_selectedArray containsObject:asset]) {
            
            [cell setCellSelected:YES];
            
            [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        }
        else {
            
            [cell setCellSelected:NO];
            
            [collectionView deselectItemAtIndexPath:indexPath animated:NO];
        }
        
        UIImage *thumbnail = [UIImage imageWithCGImage:[asset thumbnail]];
        
        cell.imageView.image = thumbnail;
        
        return cell;
    }
    else if (collectionView == _photoThumbnailView.selectedCollectionView) {
        
        SGPhotoSelectedViewCell *cell = (SGPhotoSelectedViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:_selectedCellIdentifier forIndexPath:indexPath];
        
        SGPhoto *photo = [_allSelectedArray objectAtIndex:indexPath.row];
        
        cell.imageView.image = photo.thumbnail;
        
        return cell;
    }
  
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == _photoThumbnailView.collectionView) {
        
        ALAsset *asset = [_photoArray objectAtIndex:indexPath.row];
        
        if (collectionView.allowsMultipleSelection) {//如果允许多选,则此时是进行选择操作
            
            //限制选择照片的张数
            if(_allSelectedArray.count == _picCount)
            {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"最多只能选择%@张照片",@(_picCount)] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"我知道了", nil];
                [alertView show];
                return;
            }
            
            if (![_selectedArray containsObject:asset]) {
                
                [self addSGPhotoInAllSelectedArray:asset];
                
                SGPhotoPreviewViewCell *cell = (SGPhotoPreviewViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
                cell.picCount = _allSelectedArray.count + selectedImage;
                [cell setCellSelected:YES];
            }
        }
        else {//如果不允许多选,则此时点击缩略图,打开原图进行查看
            
            SGPhotoPreviewViewController *previewViewController = [[SGPhotoPreviewViewController alloc] init];
            
            previewViewController.asset = asset;
            
            [self.navigationController pushViewController:previewViewController animated:YES];
        }
    }
}


- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {

    ALAsset *asset = [_photoArray objectAtIndex:indexPath.row];
    
    if ([_selectedArray containsObject:asset]) {
        
        [self removeSGPhotoInAllSelectedArray:asset];
        
        SGPhotoPreviewViewCell *cell = (SGPhotoPreviewViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        [cell setCellSelected:NO];
    }
}

@end
