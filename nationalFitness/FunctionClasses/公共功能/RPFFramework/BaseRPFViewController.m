//
//  BaseRPFViewController.m
//  NIM
//
//  Created by King on 2019/2/2.
//  Copyright © 2019年 Netease. All rights reserved.
//

#import "BaseRPFViewController.h"

@interface BaseRPFViewController ()



@end

@implementation BaseRPFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor redColor]];
    self.view.backgroundColor = BGCOLOR_GRAY;
}

+(UIImage *)findImgFromBundle:(NSString *)bundleName andImgName:(NSString *)imgName
{
    NSString *strResourcesBundle = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
    // 找到对应images夹下的图片
    NSBundle * bundle = [NSBundle bundleWithPath:strResourcesBundle];
    
    return [UIImage imageNamed:imgName inBundle:bundle compatibleWithTraitCollection:nil];
    
    
    [[[@{} objectForKey:@""] description] containsString:@""];
    
    
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






