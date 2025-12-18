//
//  NFTabBarViewController.m
//  nationalFitness
//
//  Created by 程long on 14-11-4.
//  Copyright (c) 2014年 chenglong. All rights reserved.
//

#import "NFTabBarViewController.h"
#import "PublicDefine.h"
#import "NFbaseNavViewController.h"
//#import "NFMineData.h"
#import "UITabBarItem+Badge.h"

@interface NFTabBarViewController ()

@end

@implementation NFTabBarViewController

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //活动支付成功
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotoRootHome:)
                                                 name:kGoto_Home_afterActSuccess
                                               object:nil];
    
    //消息通知注册
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refurbishSystemMessage:)
                                                 name:kRefurbish_System_Message
                                               object:nil];
    
    [self refurbishSystemMessage:nil];
    //选中tabbar图片颜色为蓝色
//    self.tabBar.tintColor = NFNavBackColor;
    if (self.tabBar.items.count > 0) {
        self.selectedIndex = 0;
    }
    
    [self.tabBar setShadowImage:[self imageWithColor:[UIColor clearColor] size:CGSizeMake(self.view.frame.size.width, .5)]];
    
    //当tabbar只有图片的时候 让图片剧中
//    CGFloat offset = 9.0;
//    for (UITabBarItem *item in self.tabBar.items) {
//        item.imageInsets = UIEdgeInsetsMake(offset, 0, -offset, 0);
//    }
    
    //tabbar背景图片
    [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"下边框"]];
    
//    [[UITabBar appearance] setBackgroundColor:UIColorFromRGB(0x4f3839)];
    [[UITabBar appearance] setBackgroundColor:[UIColor whiteColor]];
    
//    [UITabBar appearance].translucent = translucentBOOL;
    
    //设置选中背景颜色 tintColor这里设置貌似没用
//    self.tabBarController.tabBar.barTintColor = [UIColor whiteColor];
    self.tabBarController.tabBar.tintColor = UIColorFromRGB(0x4f3839);
    
    
    
    //设置tabbar选中的背景颜色
//    CGSize indicatorImageSize = CGSizeMake(self.tabBar.bounds.size.width / self.tabBar.items.count, self.tabBar.bounds.size.height);
//    self.tabBar.selectionIndicatorImage = [self drawTabBarItemBackgroundImageWithSize:indicatorImageSize];
    
    // Do any additional setup after loading the view.
}

//根据颜色创建图片
- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    if (!color || size.width <= 0 || size.height <= 0) return nil;
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"\n\n\n\n\ndidReceiveMemoryWarning\n\n\n\n\n");
    // Dispose of any resources that can be recreated.
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    
//    [item removeBadgeView];
}

//活动支付成功之后跳转到我的界面
- (void)gotoRootHome:(NSNotification *)notification
{
    UIViewController *showCtrol = self.selectedViewController;
    if ([showCtrol isKindOfClass:[NFbaseNavViewController class]])
    {
        NFbaseNavViewController *baseNav = (NFbaseNavViewController *)showCtrol;
        if (baseNav.viewControllers.count > 2)
        {
            NSArray *viewArr = [[NSArray alloc] initWithObjects:baseNav.viewControllers.firstObject, [baseNav.viewControllers objectAtIndex:1], nil];
            [baseNav setViewControllers:viewArr animated:YES];
        }
    }
}

//设置tabbar选中时的背景颜色
- (UIImage *)drawTabBarItemBackgroundImageWithSize:(CGSize)size
{
    // 准备绘图环境
    UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBFillColor(ctx, 124.0 / 255, 124.0 / 255, 151.0 / 255, 1);
    CGContextFillRect(ctx, CGRectMake(0, 0, size.width, size.height));
    
    // 获取该绘图中的图片
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    //结束绘图
    UIGraphicsEndImageContext();
    
    /*
     // 获取当前应用路径中Documents目录下指定文件名对应的文件路径
     NSString *path = [[NSHomeDirectory() stringByAppendingString:@"/Documents"] stringByAppendingString:@"/tabBarBackgroundImage.png"];
     NSLog(@"path:%@", path);
     // 保存PNG图片
     [UIImagePNGRepresentation(img) writeToFile:path atomically:YES];
     */
    return img;
}

//刷新界面-系统消息-需要改变点的状态
- (void)refurbishSystemMessage:(NSNotification *)notification
{
    //显示未读消息数量
//    NSString *messaegStr = [NFMineData selectUnreadSystemNumber];
//    UITabBarItem *item = [self.tabBar.items objectAtIndex:4];
//    if (0 == messaegStr.length || ([messaegStr isEqualToString:@"0"]))
//    {
//        [item setBadgeValue:nil];
//    }
//    else
//    {
//        [item setBadgeValue:messaegStr];
//    }
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kGoto_Home_afterActSuccess object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kRefurbish_System_Message object:nil];
}

@end
