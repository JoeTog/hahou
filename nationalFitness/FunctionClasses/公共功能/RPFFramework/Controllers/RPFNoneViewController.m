//
//  RPFNoneViewController.m
//  nationalFitness
//
//  Created by joe on 2019/11/28.
//  Copyright © 2019年 chenglong. All rights reserved.
//

#import "RPFNoneViewController.h"

@interface RPFNoneViewController ()

@end

@implementation RPFNoneViewController{
    
    
    __weak IBOutlet UIButton *titleContentBtn;
    
    
    
    __weak IBOutlet UIButton *sendnameBtn;
    
    
    __weak IBOutlet UIButton *lookDetailBtn;
    
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    
    [titleContentBtn setTitle:[self.redDetailDict objectForKey:@"content"] forState:(UIControlStateNormal)];
    
    NSDictionary *senderInfoDict = [self.redDetailDict objectForKey:@"senderInfoDict"];
    [sendnameBtn setTitle:[senderInfoDict objectForKey:@"sendername"] forState:(UIControlStateNormal)];
    
    
    
    
    
}







- (IBAction)lookDetailClick:(UIButton *)sender {
    
    
    
    
}


- (IBAction)closeClick:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}






@end
