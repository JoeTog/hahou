//
//  SGPhotoPreviewViewController.h
//  SmartCity
//
//  Created by sea on 14-4-16.
//  Copyright (c) 2014年 sea. All rights reserved.
//

#import "NFbaseViewController.h"

@class ALAsset;

@class SGPhotoPreviewView;

@interface SGPhotoPreviewViewController : NFbaseViewController {
    
    SGPhotoPreviewView              *_photoPreviewView;
}

@property (nonatomic, weak) ALAsset *asset;
@property (nonatomic, weak) UIImage *image;

@end
