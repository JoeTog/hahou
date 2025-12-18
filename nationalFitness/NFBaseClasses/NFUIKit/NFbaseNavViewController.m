//
//  NFbaseNavViewController.m
//  nationalFitness
//
//  Created by 程long on 14-11-5.
//  Copyright (c) 2014年 chenglong. All rights reserved.
//

#import "NFbaseNavViewController.h"
#import "PublicDefine.h"
#import "UIImage+FW.h"
#import <objc/runtime.h>

@interface NFbaseNavViewController ()<UIGestureRecognizerDelegate>

@end

@implementation NFbaseNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarController.tabBar.tintColor = UIColorFromRGB(0x4f3839);
    NSString *imageName = @"表头底图";
    //imageName = @"上边框";
//    self.navigationBar.shadowImage = [UIImage new];
//    [self.navigationBar setBackgroundImage:[UIImage imageNamed:imageName]
//                            forBarPosition:UIBarPositionAny
//                                barMetrics:UIBarMetricsDefault];
    
    UIImage *backGroundImage = [UIImage imageNamed:@"表头底图"];
    backGroundImage = [backGroundImage resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeStretch];
    [self.navigationBar setBackgroundImage:backGroundImage forBarMetrics:UIBarMetricsDefault];
    
    
    
    //设置文字颜色
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor whiteColor],
                                NSForegroundColorAttributeName, nil];
    [self.navigationBar setTitleTextAttributes:attributes];
    
//    __block id Field;
//    dispatch_async(dispatch_get_main_queue(), ^(void) {
//        Field = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
//    });
//
//   __block  UIView *statusBar;
//    if ([Field isKindOfClass:[UIView class]]) {
//        dispatch_async(dispatch_get_main_queue(), ^(void) {
//            statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
//        });
//    }
    
    NSString *version = [UIDevice currentDevice].systemVersion;
    
    UIView *statusBar;
    if (version.doubleValue >= 13.0) {
        //        UIStatusBarManager *statusBarManager = [UIApplication sharedApplication].keyWindow.windowScene.statusBarManager;
        //        if ([statusBarManager respondsToSelector:@selector(createLocalStatusBar)]) {
        //            UIView *_localStatusBar = [statusBarManager performSelector:@selector(createLocalStatusBar)];
        //            if ([_localStatusBar respondsToSelector:@selector(statusBar)]) {
        //                statusBar = [_localStatusBar performSelector:@selector(statusBar)];
        //            }
        //        }
    }else{
        __block id Field;
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            Field = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
        });
        if ([Field isKindOfClass:[UIView class]]) {
            statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
        }
    }
    
    
    //设置状态栏背景颜色
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = [UIColor clearColor];
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    
//    [self setNavigationBottomLineColor:[UIColor clearColor]];
    
    // Do any additional setup after loading the view.
    
//    // 获取系统自带滑动手势的target对象
//    id target = self.interactivePopGestureRecognizer.delegate;
//    // 创建全屏滑动手势，调用系统自带滑动手势的target的action方法
//    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:target action:@selector(handleNavigationTransition:)];
//    // 设置手势代理，拦截手势触发
//    pan.delegate = self;
//    // 给导航控制器的view添加全屏滑动手势
//    [self.view addGestureRecognizer:pan];
//    // 设置代理，使返回手势生效
    self.interactivePopGestureRecognizer.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"\n\n\n\n\ndidReceiveMemoryWarning\n\n\n\n\n");
    // Dispose of any resources that can be recreated.
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
    if ([currentVC isKindOfClass:[viewController class]]) {
        return;
    }
    
    if (1 == self.viewControllers.count)
    {
        
        self.tabBarController.tabBar.hidden = YES;
    }
    
    [super pushViewController:viewController animated:animated];
}

#pragma mark - <UIGestureRecognizerDelegate>

/**
 * 每当用户触发[返回手势]时都会调用一次这个方法
 * 返回值:返回YES,手势有效; 返回NO,手势失效
 */
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    // 如果当前显示的是第一个子控制器,就应该禁止掉[返回手势]
    return self.viewControllers.count > 1;
}

-(void)setNavigationBottomLineColor:(UIColor *)color{
    //先查看View层次结构
    //    NSLog(@"Navigationbar recursiveDescription:\n%@",[self.navigationBar performSelector:@selector(recursiveDescription)]);
    //打印完后我们发现有个高度为0.5的UIImageView 类型 SuperView type为 _UIBarBackground的视图
    //遍历navigationBar 属性
//    unsigned int outCount = 0;
//    Ivar *ivars = class_copyIvarList([self.navigationBar class], &outCount);
//    for (NSInteger i = 0; i < outCount; ++i) {
//        Ivar ivar = *(ivars + i);
//        NSLog(@"navigationBar Propertys:\n name = %s  \n type = %s", ivar_getName(ivar),ivar_getTypeEncoding(ivar));
//    }
//    free(ivars);
    
    //遍历结果可以发现navigationbar 中的type 为_UIBarBackground 名称为 _barBackgroundView
    //遍历_barBackgroundView 中的属性
    unsigned int viewOutCount = 0;
    UIView *barBackgroundView = nil;
    /*iOS 10.0+为`_barBackgroundView`,小于iOS10.0这个属性名称为`_UIBarBackground`.*/
    
    if (UIDeviceCurrentDevice<10.0) {
        barBackgroundView = [self.navigationBar valueForKey:@"_backgroundView"];
    
    }
    else{
        if ([self.navigationBar valueForKey:@"_barBackgroundView"]) {
            barBackgroundView = [self.navigationBar valueForKey:@"_barBackgroundView"];
        }
    }
    if (barBackgroundView) {
        Ivar *viewivars = class_copyIvarList([barBackgroundView class], &viewOutCount);
        for (NSInteger i = 0; i < viewOutCount; ++i) {
            Ivar ivar = *(viewivars + i);
            NSLog(@"_barBackgroundView Propertys:\n name = %s  \n type = %s", ivar_getName(ivar),ivar_getTypeEncoding(ivar));
        }
        free(viewivars);
    }
    //找到type为 UIImageView 的属性有_shadowView,_backgroundImageView。因为底部线条可以设置shadowImage，所有我们猜测是_shadowView
    id Field = [barBackgroundView valueForKey:@"_shadowView"];
    UIImageView *navigationbarLineView;
    if ([Field isKindOfClass:[UIImageView class]]) {
        navigationbarLineView = [barBackgroundView valueForKey:@"_shadowView"];
    }
    if (navigationbarLineView && [navigationbarLineView isKindOfClass:[UIImageView class]]) {
        UIView *lineView = [[UIView alloc]init];
        lineView.backgroundColor = color;
        lineView.translatesAutoresizingMaskIntoConstraints = NO;
        [navigationbarLineView addSubview:lineView];
        
        //这里我们要用约束不然旋转后有问题
        [navigationbarLineView addConstraint:[NSLayoutConstraint constraintWithItem:lineView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:navigationbarLineView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
        
        [navigationbarLineView addConstraint:[NSLayoutConstraint constraintWithItem:lineView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:navigationbarLineView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
        
        [navigationbarLineView addConstraint:[NSLayoutConstraint constraintWithItem:lineView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:navigationbarLineView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
        
        [navigationbarLineView addConstraint:[NSLayoutConstraint constraintWithItem:lineView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:navigationbarLineView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
    }
}


@end
