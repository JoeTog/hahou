//
//  YinDaoViewController.m
//  nationalFitness
//
//  Created by 程龙 on 15/7/25.
//  Copyright (c) 2015年 chenglong. All rights reserved.
//

#import "YinDaoViewController.h"

@interface YinDaoViewController ()
{
    __weak IBOutlet UIImageView *yindaoImage;
}

@end

@implementation YinDaoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [yindaoImage setImage:[UIImage imageNamed:_typeStr]];
    
    self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"\n\n\n\n\ndidReceiveMemoryWarning\n\n\n\n\n");
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [KeepAppBox keepVale:@"NO" forKey:_typeStr];
    [self.view removeFromSuperview];
}

@end
