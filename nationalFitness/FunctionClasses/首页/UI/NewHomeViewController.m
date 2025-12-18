//
//  NewHomeViewController.m
//  nationalFitness
//
//  Created by 童杰 on 2017/3/31.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "NewHomeViewController.h"
#import "ZJContactViewController.h"


@interface NewHomeViewController ()

@end

@implementation NewHomeViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = NO;
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.translucent = translucentBOOL;
    
}

-(void)viewWillLayoutSubviews{
    
    [super viewWillLayoutSubviews];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"联系人";
    self.tabBarItem.title = @"联系人";
    
}


- (IBAction)xxxxxx:(id)sender {
    //ZJContactViewController
    ZJContactViewController *vc = [[ZJContactViewController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"\n\n\n\n\ndidReceiveMemoryWarning\n\n\n\n\n");
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
