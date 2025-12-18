//
//  SGPhotoPreviewViewController.m
//  SmartCity
//
//  Created by sea on 14-4-16.
//  Copyright (c) 2014年 sea. All rights reserved.
//

#import "SGPhotoPreviewViewController.h"

#import "SGPhotoPreviewView.h"

#import <AssetsLibrary/AssetsLibrary.h>

@interface SGPhotoPreviewViewController ()

@end

@implementation SGPhotoPreviewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView {
    
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    
    _photoPreviewView = [[SGPhotoPreviewView alloc] initWithFrame:frame];
    
    self.view = _photoPreviewView;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"预览";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self loadImageView];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)loadImageView {
    
    if (_asset) {
        
        UIImage *image = [UIImage imageWithCGImage:[[_asset defaultRepresentation] fullScreenImage]];
        
        _photoPreviewView.image = image;
        
        return;
    }
    
    if (_image) {
        
        _photoPreviewView.image = _image;
        
        return;
    }
}

@end
