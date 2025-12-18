

//
//  RedDetailViewController.m
//  nationalFitness
//
//  Created by joe on 2017/12/12.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "RedDetailViewController.h"

@interface RedDetailViewController ()

@end

@implementation RedDetailViewController{
    //昵称
    __weak IBOutlet UILabel *nickNameLabel;
    //金额
    __weak IBOutlet UILabel *earnPriceLabel;
    
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"多信红包";
    
    nickNameLabel.text = [NFUserEntity shareInstance].nickName;
    
    
    earnPriceLabel.text = self.redMessage.message.priceAccount;
    
}








- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
