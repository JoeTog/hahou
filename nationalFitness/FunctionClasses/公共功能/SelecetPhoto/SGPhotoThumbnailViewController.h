//
//  SGPhotoPreviewViewController.h
//  SmartCity
//  collectionview 样式的选择照片。点击tableviewcell后跳转到这里
//  Created by sea on 14-4-16.
//  Copyright (c) 2014年 sea. All rights reserved.
//

#import "NFbaseViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>

@protocol SGPhotoThumbnailDelegate <NSObject>

- (void)thumbnailFinishSelected:(NSArray *)selectedArray;

@end

@class SGPhotoThumbnailView;


typedef NS_ENUM(NSInteger, PIC_SELECET_COUNT)
{
    PIC_SELECET_NONE                        =  0,
    PIC_SELECET_ONE                         =  1,
    PIC_SELECET_TWO                         =  2,
    PIC_SELECET_THREE                       =  3,
    PIC_SELECET_FOUR                        =  4,
    PIC_SELECET_FIVE                        =  5,
    PIC_SELECET_SIX                         =  6,
    PIC_SELECET_SEVEN                       =  7,
    PIC_SELECET_EIGHT                       =  8,
    PIC_SELECET_NINE                        =  9
};


@interface SGPhotoThumbnailViewController : NFbaseViewController {
    
    SGPhotoThumbnailView              *_photoThumbnailView;
}

@property (nonatomic, weak) id <SGPhotoThumbnailDelegate> thumbnailDelegate;

@property (nonatomic, weak) ALAssetsGroup *group;

//原始选中的图片数组,用于标识哪些图片已经被选中过 note:数组中放置的是SGPhoto对象
@property (nonatomic, strong) NSArray *originalSelectedArray;

-(id)initWithPicCount: (PIC_SELECET_COUNT)picCount;

@end
