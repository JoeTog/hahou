//
//  SGPhotoPickerViewController.m
//  SmartCity
//
//  Created by sea on 14-4-15.
//  Copyright (c) 2014年 sea. All rights reserved.
//

#import "SGPhotoPickerViewController.h"

#import "SGPhotoPickerView.h"

#import <AssetsLibrary/AssetsLibrary.h>

@interface SGPhotoPickerViewController () <UITableViewDelegate, UITableViewDataSource,SGPhotoThumbnailDelegate> {
    
    NSArray                 *_photoGroups;
    
    ALAssetsLibrary         *_assetsLibrary;
    
    PIC_SELECET_COUNT       _picCount;
}

@end

@implementation SGPhotoPickerViewController
@synthesize titleName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//初始化，需要传入限制图片的个数
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

    _photoGroups = nil;
    _assetsLibrary = nil;

}

- (void)loadView {
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    _photoPickerView = [[SGPhotoPickerView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    _photoPickerView.photosTableView.delegate = self;
    _photoPickerView.photosTableView.dataSource = self;
    _photoPickerView.photosTableView.tableFooterView = [UIView new];
    self.view = _photoPickerView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    UINavigationBar *bar = [UINavigationBar appearance];
//    bar.barTintColor = [UIColor colorThemeColor];
//    bar.translucent = translucentBOOL;
    
//    NSLog(@"%f",self.navigationController.navigationBar.alpha);
    
    [self getPhotoGroups];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (nil == titleName)
    {
        self.title = @"相册";
    }
    else
    {
        self.title = titleName;
    }
    
    if (!_assetsLibrary) {
        
        _assetsLibrary = [[ALAssetsLibrary alloc]init];//生成整个photolibrary句柄的实例
    }
}



- (void)viewWillDisappear:(BOOL)animated
{
        [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
//    UICollectionView
}

//TODO: 异步获取相册的分组信息
- (void)getPhotoGroups {
    
    NSMutableArray *groups = [[NSMutableArray alloc]init];//存放media的数组
    
//    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                 usingBlock:^(ALAssetsGroup *group, BOOL *stop) {//获取所有group
                                     
                                     if (!group) {
                                         
                                         _photoGroups = groups;
                                         
                                         [_photoPickerView.photosTableView reloadData];
                                         
                                     }
                                     else {
                                         
                                         [groups addObject:group];
                                     }
                                     
                                 } failureBlock:^(NSError *error) {
                                     
                                     NSLog(@"Enumerate the asset groups failed.");
                                 }];

    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _photoGroups.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"PhotoCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    ALAssetsGroup *group = [_photoGroups objectAtIndex:indexPath.row];
    
    cell.imageView.image = [UIImage imageWithCGImage:group.posterImage];
    
    cell.textLabel.text = [group valueForProperty:ALAssetsGroupPropertyName];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SGPhotoThumbnailViewController *thumbnailViewController = [[SGPhotoThumbnailViewController alloc] initWithPicCount:_picCount];
    
    thumbnailViewController.thumbnailDelegate = self;
    thumbnailViewController.originalSelectedArray = self.originalSelectedArray;
    
    ALAssetsGroup *group = [_photoGroups objectAtIndex:indexPath.row];
    
    thumbnailViewController.group = group;
    
    [self.navigationController pushViewController:thumbnailViewController animated:YES];
}


#pragma mark -
#pragma mark SGPhotoThumbnail delegate methods

- (void)thumbnailFinishSelected:(NSArray *)selectedArray {
    
    NSInteger index = [self.navigationController.viewControllers indexOfObject:self];
    
    UIViewController *controller = [self.navigationController.viewControllers objectAtIndex:index - 1];
    
    if ([_pickerDelegate respondsToSelector:@selector(photoPickerFinishSelected:)]) {
        
        [_pickerDelegate photoPickerFinishSelected:selectedArray];
    }
    
    [self.navigationController popToViewController:controller animated:YES];
    //[self dismissViewControllerAnimated:YES completion:nil];
}

@end



@implementation SGPhoto

- (void)dealloc {
    
    self.identifier = nil;
    self.thumbnail = nil;
    self.fullResolutionImage = nil;
}

@end
