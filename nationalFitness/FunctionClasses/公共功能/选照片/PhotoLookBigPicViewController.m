//
//  PhotoLookBigPicViewController.m
//  nationalFitness
//
//  Created by 童杰 on 2017/3/27.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "PhotoLookBigPicViewController.h"

@interface PhotoLookBigPicViewController ()<UIScrollViewDelegate>

@end

@implementation PhotoLookBigPicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createScrollView];
    if (self.isNeedTitle) {
        [self createNaviGationbarItemWithTitle:[NSString stringWithFormat:@"%ld of %lu",(long)self.currentPage,(unsigned long)self.picMapList.count]];
        [self createNaviGationbarItemWithTitleImage:@"buttonbar_action" andTitleText:@"完成" andTag:1 isLeft:NO];
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.hidesBackButton = YES;
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:(UIBarMetricsDefault)];
}


-(void)barButtonClick:(UIButton *)sender{
    if (sender.tag ==1) {
        [self.navigationController popViewControllerAnimated:YES];
        //        [self.view.superview setTransitionAnimationType:(CCXTransitionAnimationTypePageUnCurl) toward:(CCXTransitionAnimationTowardFromRight) duration:0.5];
        
    }
}

-(void)createScrollView{
    UIScrollView *scrollV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, JOESIZE.width, JOESIZE.height)];
    scrollV.contentSize = CGSizeMake(JOESIZE.width*self.picMapList.count, JOESIZE.height-64);
    int i=0;
    if (self.picMapList.count > 0) {
        for (NSString *pic in self.picMapList) {
            NSString *picPath = [pic stringByReplacingOccurrencesOfString:@"_small" withString:@""];
            NFShowImageView *imageV = [[NFShowImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*i, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
            [imageV ShowImageWithUrlStr:picPath completion:nil];
            
            imageV.contentMode = UIViewContentModeScaleAspectFit;
            
            imageV.userInteractionEnabled = YES;
            //在imagev上面添加 按钮
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, imageV.frame.size.width, imageV.frame.size.height)];
            [btn addTarget:self action:@selector(JoeImageClick:) forControlEvents:(UIControlEventTouchDown)];
            [imageV addSubview:btn];
            [scrollV addSubview:imageV];
            i++;
        }
    }
    
    scrollV.bounces = NO;
    scrollV.contentOffset = CGPointMake(JOESIZE.width*self.currentPage, 0);
    scrollV.pagingEnabled = YES;
    //    scrollV.userInteractionEnabled = YES;
    [self.view addSubview:scrollV];
    scrollV.delegate = self;
}

//点击图片上的按钮 显示导航栏
-(void)JoeImageClick:(UIButton *)sender{
    if (!self.isNeedTitle) {
        //点击图片返回 适用于一张图片【即当isNeedTitle 为no】
//        [self.navigationController popViewControllerAnimated:YES];
        self.navigationController.navigationBar.hidden =  NO;
    }else{
        self.navigationController.navigationBar.hidden =  NO;
    }
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    self.navigationController.navigationBar.hidden = YES;
    if (self.isNeedTitle) {
        [self createNaviGationbarItemWithTitle:[NSString stringWithFormat:@"%.0f of %lu",(int)scrollView.contentOffset.x/SCREEN_WIDTH+1,(unsigned long)self.picMapList.count]];
    }
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
