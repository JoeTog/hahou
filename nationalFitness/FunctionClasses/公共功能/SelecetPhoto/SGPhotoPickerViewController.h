//
//  SGPhotoPickerViewController.h
//  SmartCity
//  tableview cell样式 选择照片
//  Created by sea on 14-4-15.
//  Copyright (c) 2014年 sea. All rights reserved.
//

#import "NFbaseViewController.h"

#import "SGPhotoThumbnailViewController.h"

@class SGPhotoPickerView;


@protocol SGPhotoPickerDelegate <NSObject>

@optional

- (void)photoPickerFinishSelected:(NSArray *)selectedArray;

@end


@interface SGPhotoPickerViewController :  NFbaseViewController{
    
    SGPhotoPickerView           *_photoPickerView;
    NSString *titleName;
}

@property (nonatomic, weak) id <SGPhotoPickerDelegate> pickerDelegate;

//原始选中的图片数组,用于标识哪些图片已经被选中过 note:数组中放置的是SGPhoto对象
@property (nonatomic, strong) NSArray *originalSelectedArray;
@property (nonatomic, strong) NSString *titleName; //标题栏名称

//初始化，需要传入限制图片的个数
-(id)initWithPicCount: (PIC_SELECET_COUNT)picCount;

@end



@interface SGPhoto : NSObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) UIImage *thumbnail;//缩略图
@property (nonatomic, strong) UIImage *fullResolutionImage;//高分辨率图

@end
