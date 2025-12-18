//
//  KeepAppBox.m
//  qmjs
//
//  Created by 程龙 on 14-5-7.
//  Copyright (c) 2014年 sea. All rights reserved.
//

#import "KeepAppBox.h"
#import "PublicDefine.h"

@implementation KeepAppBox

//增加值
+ (void)keepVale:(id)value forKey:(NSString *)key
{
    NSUserDefaults *appBox = [NSUserDefaults standardUserDefaults];
    [appBox setValue:value forKey:key];
    [appBox synchronize];
}

//减少值
+ (void)deleteValueForkey:(NSString *)key
{
    NSUserDefaults *appBox = [NSUserDefaults standardUserDefaults];
    if ([appBox objectForKey:key])
    {
        [appBox removeObjectForKey:key];
        [appBox synchronize];
    }
}

//根据KEY查找对应的值
+ (id)checkValueForkey:(NSString *)key
{
    NSUserDefaults *appBox = [NSUserDefaults standardUserDefaults];
    if ([appBox objectForKey:key])
    {
        NSString *value = [appBox objectForKey:key];
        return value;
    }
    else
    {
        return nil;
    }
}

//爱好只能由中文、字母组成
+ (BOOL)isValidateHobby:(NSString *)nickname
{
    NSString *realnameRegex = @"[a-zA-Z\u4e00-\u9fa5]+";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",realnameRegex];
    return [passWordPredicate evaluateWithObject:nickname];
}

//昵称，个性签名只能由中文、字母或数字组成
+ (BOOL)isValidateNick:(NSString *)nickname
{
    NSString *realnameRegex = @"[a-zA-Z\u4e00-\u9fa5][a-zA-Z0-9\u4e00-\u9fa5]+";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",realnameRegex];
    return [passWordPredicate evaluateWithObject:nickname];
}

//验证真实姓名
+ (BOOL)isValidateRealname:(NSString *)realname
{
    NSString *realnameRegex = @"^[\u4e00-\u9fa5]{2,3}$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",realnameRegex];
    return [passWordPredicate evaluateWithObject:realname];
}

//验证账号是不是纯英文 或者 英文加数字
+ (BOOL)isValidateNickname:(NSString *)Nickname
{
    NSString *nameRegex = @"^(?!\\d+$)[a-zA-Z0-9]{1,}$";
    NSPredicate *nameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",nameRegex];
    return [nameTest evaluateWithObject:Nickname];
}

//验证邮箱格式
+ (BOOL)isValidateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailRegex];
    return [emailTest evaluateWithObject:email];
}

//验证电话格式
+ (BOOL)isValidatePhone:(NSString *)phone
{
    NSString *phoneRegex = @"^((17[0-9])|(19[0-9])|(14[0-9])|(13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@", phoneRegex];
    return [phoneTest evaluateWithObject:phone];
}

//验证身份证格式
+ (BOOL)isIdNumberValid:(NSString*)idNum
{
    NSString *idNumRegex = @"(^[1-9]\\d{5}(18|19|([23]\\d))\\d{2}((0[1-9])|(10|11|12))(([0-2][1-9])|10|20|30|31)\\d{3}[0-9Xx]$)|(^[1-9]\\d{5}\\d{2}((0[1-9])|(10|11|12))(([0-2][1-9])|10|20|30|31)\\d{3}$)";
    NSPredicate *idNumTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@", idNumRegex];
    return [idNumTest evaluateWithObject:idNum];
}

//返回字符字节长度
+ (NSInteger)convertToInt:(NSString *)strtemp
{
    NSInteger strlength = 0;
    char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (NSInteger i=0 ; i<[strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++)
    {
        if (*p)
        {
            p++;
            strlength++;
        }
        else
        {
            p++;
        }
    }
    return (strlength +1 )/2;
}


//返回当前传入的下层最近的一个UIViewController
+ (UIViewController *)viewController:(id)view
{
    for (UIView *next = [view superview]; next; next = next.superview)
    {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]])
        {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

//最上层viewctrol
+ (UIViewController*)topViewController {
    return [KeepAppBox topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

+ (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

//性别
+ (void)showMemberSex:(UIImageView *)imageView state:(NSString *)state
{
    switch ([state integerValue]) {
            //性别 NFMan：男 NFWoman：女
        case NFMan:
        {
            imageView.image = [UIImage imageNamed:@"Sp_sex_man"];
        }
            break;
        case NFWoman:
        {
            imageView.image = [UIImage imageNamed:@"Sp_sex_women"];
        }
            break;
            
        default:
        {
            imageView.image = [UIImage imageNamed:@"Sp_sex_women"];
        }
            break;
    }
}

//默认男女头像
+ (void)showMemberHead:(UIImageView *)imageView state:(NSInteger)state
{
    switch (state) {
        case 1:
        {
            imageView.image = [UIImage imageNamed:@"RL_Login_youngman"];
        }
            break;
        default:
        {
            imageView.image = [UIImage imageNamed:@"RL_Login_youngwoman"];
        }
            break;
    }
}


//设置订单状态
+ (void)setOrderStatusWith:(NSString *)str withLabel:(UILabel *)label
{
    int statues = [str intValue];
    switch (statues) {
        case 1:
        {
            label.text = @"待付款";
        }
            break;
        case 2:
        {
            label.text = @"已付款";
        }
            break;
        case 3:
        {
            label.text = @"发货完成等待收货确认";
        }
            break;
        case 4:
        {
            label.text = @"交易成功";
        }
            break;
        case 5:
        {
            label.text = @"交易关闭";
        }
            break;
        case 6:
        {
            label.text = @"已退货";
        }
            break;
        case 8:
        {
            label.text = @"线下支付";
        }
            break;
            
        default:
        {
            label.text = @"交易成功";
        }
            break;
    }
}

//用户所在段位
+ (void)setRankLevelWithString:(NSString *)levelStr withLabel:(UILabel *)label
{
    //用户所在队伍的段位 // 所在段位(等级) 1:黄金三阶;2:黄金二阶;3:黄金一阶;4:白银三阶;5:白银二阶;6:白银一阶;7:青铜三阶;8:青铜二阶;9:青铜一阶
    switch ([levelStr integerValue]) {
        case 1:
        {
            label.text = @"黄金三阶";
        }
            break;
        case 2:
        {
            label.text = @"黄金二阶";
        }
            break;
        case 3:
        {
            label.text = @"黄金一阶";
        }
            break;
        case 4:
        {
            label.text = @"白银三阶";
        }
            break;
        case 5:
        {
            label.text = @"白银二阶";
        }
            break;
        case 6:
        {
            label.text = @"白银一阶";
        }
            break;
        case 7:
        {
            label.text = @"青铜三阶";
        }
            break;
        case 8:
        {
            label.text = @"青铜二阶";
        }
            break;
        case 9:
        {
            label.text = @"青铜一阶";
        }
            break;
            
        default:
        {
            label.text = @"";
        }
            break;
    }
}


//设置段位图片
+ (void)setRankImageWithString:(NSString *)str withImage:(UIImageView *)imageView
{
    switch ([str integerValue]) {
            //金色
        case 1: case 2: case 3:
        {
            imageView.image = [UIImage imageNamed:@"勋章_金"];
        }
            break;
            //银色
        case 4: case 5: case 6:
        {
            imageView.image = [UIImage imageNamed:@"勋章_银"];
        }
            break;
            //铜
        case 7: case 8: case 9:
        {
            imageView.image = [UIImage imageNamed:@"勋章_铜"];
        }
            break;
            
        default:
        {
            imageView.image = [UIImage imageNamed:@"勋章_未开放"];
        }
            break;
    }

}

////设置赛事类型

/***
 
 typeStr 赛事类型名字
 str  段位所在段位(等级) 1:黄金三阶;2:黄金二阶;3:黄金一阶;4:白银三阶;5:白银二阶;6:白银一阶;7:青铜三阶;8:青铜二阶;9:青铜一阶
 ***/
+ (void)setRankTypeImageWithStr:(NSString *)typeStr andDWstr:(NSString *)str andImageView:(UIImageView *)imageView
{
    if ([typeStr isEqualToString:@"男单"]) {
        switch ([str integerValue]) {
            case 1: case 2: case 3:
            {
                imageView.image = [UIImage imageNamed:@"勋章_男单_金"];
            }
                break;
                //银色
            case 4: case 5: case 6:
            {
                imageView.image = [UIImage imageNamed:@"勋章_男单_银"];
            }
                break;
                //铜
            case 7: case 8: case 9:
            {
                imageView.image = [UIImage imageNamed:@"勋章_男单_铜"];
            }
                break;
                
            default:
            {
                imageView.image = [UIImage imageNamed:@"勋章_男单_铜"];
            }
                break;
        }
    }
    else if ([typeStr isEqualToString:@"男双"])
    {
        switch ([str integerValue]) {
            case 1: case 2: case 3:
            {
                imageView.image = [UIImage imageNamed:@"勋章_男双_金"];
            }
                break;
                //银色
            case 4: case 5: case 6:
            {
                imageView.image = [UIImage imageNamed:@"勋章_男双_银"];
            }
                break;
                //铜
            case 7: case 8: case 9:
            {
                imageView.image = [UIImage imageNamed:@"勋章_男双_铜"];
            }
                break;
                
            default:
            {
                imageView.image = [UIImage imageNamed:@"勋章_男双_铜"];
            }
                break;
        }
    }
    else if ([typeStr isEqualToString:@"女单"])
    {
        switch ([str integerValue]) {
            case 1: case 2: case 3:
            {
                imageView.image = [UIImage imageNamed:@"勋章_女单_金"];
            }
                break;
                //银色
            case 4: case 5: case 6:
            {
                imageView.image = [UIImage imageNamed:@"勋章_女单_银"];
            }
                break;
                //铜
            case 7: case 8: case 9:
            {
                imageView.image = [UIImage imageNamed:@"勋章_女单_铜"];
            }
                break;
                
            default:
            {
                imageView.image = [UIImage imageNamed:@"勋章_女单_铜"];
            }
                break;
        }
    }
    else if ([typeStr isEqualToString:@"女双"])
    {
        switch ([str integerValue]) {
            case 1: case 2: case 3:
            {
                imageView.image = [UIImage imageNamed:@"勋章_女双_金"];
            }
                break;
                //银色
            case 4: case 5: case 6:
            {
                imageView.image = [UIImage imageNamed:@"勋章_女双_银"];
            }
                break;
                //铜
            case 7: case 8: case 9:
            {
                imageView.image = [UIImage imageNamed:@"勋章_女双_铜"];
            }
                break;
                
            default:
            {
                imageView.image = [UIImage imageNamed:@"勋章_女双_铜"];
            }
                break;
        }
    }
    else if ([typeStr isEqualToString:@"混双"])
    {
        switch ([str integerValue]) {
            case 1: case 2: case 3:
            {
                imageView.image = [UIImage imageNamed:@"勋章_混双_金"];
            }
                break;
                //银色
            case 4: case 5: case 6:
            {
                imageView.image = [UIImage imageNamed:@"勋章_混双_银"];
            }
                break;
                //铜
            case 7: case 8: case 9:
            {
                imageView.image = [UIImage imageNamed:@"勋章_混双_铜"];
            }
                break;
                
            default:
            {
                imageView.image = [UIImage imageNamed:@"勋章_混双_铜"];
            }
                break;
        }
    }
    
    else if ([typeStr isEqualToString:@"双打"])
    {
        switch ([str integerValue]) {
            case 1: case 2: case 3:
            {
                imageView.image = [UIImage imageNamed:@"勋章_双打_金"];
            }
                break;
                //银色
            case 4: case 5: case 6:
            {
                imageView.image = [UIImage imageNamed:@"勋章_双打_银"];
            }
                break;
                //铜
            case 7: case 8: case 9:
            {
                imageView.image = [UIImage imageNamed:@"勋章_双打_铜"];
            }
                break;
                
            default:
            {
                imageView.image = [UIImage imageNamed:@"勋章_双打_铜"];
            }
                break;
        }

    }
    
    else
    {
        imageView.image = nil;
    }
}

//用户所在队伍的段位 // 所在段位(等级) 1:黄金三阶;2:黄金二阶;3:黄金一阶;4:白银三阶;5:白银二阶;6:白银一阶;7:青铜三阶;8:青铜二阶;9:青铜一阶
+ (void)showStarWithLevel:(NSString *)levelStr andImageView:(UIImageView *)imageView
{
    switch ([levelStr integerValue]) {
        case 1: case 4: case 7:
        {
            imageView.image = [UIImage imageNamed:@"勋章_三颗星"];
        }
            break;
        case 2: case 5: case 8:
        {
            imageView.image = [UIImage imageNamed:@"勋章_二颗星"];
        }
            break;
        case 3: case 6: case 9:
        {
            imageView.image = [UIImage imageNamed:@"勋章_一颗星"];
        }
            break;
        default:
        {
            imageView.image = nil;
        }
            break;
    }
}

//根据活动类型返回不同的背景颜色
+ (UIColor *)getActBackColor:(NSString *)typeStr
{
    if ([typeStr isEqualToString:@"篮球"])
    {
        return UIColorFromRGB(0x7bd9be);
    }
    else if ([typeStr isEqualToString:@"足球"])
    {
        return UIColorFromRGB(0xffea49);
    }
    else if ([typeStr isEqualToString:@"排球"])
    {
        return UIColorFromRGB(0xffc433);
    }
    else if ([typeStr isEqualToString:@"瑜伽"])
    {
        return UIColorFromRGB(0xce7171);
    }
    else if ([typeStr isEqualToString:@"跑步"])
    {
        return UIColorFromRGB(0x7d8e2e);
    }
    else if ([typeStr isEqualToString:@"羽毛球"])
    {
        return UIColorFromRGB(0x9375be);
    }
    else if ([typeStr isEqualToString:@"骑车"])
    {
        return UIColorFromRGB(0xff503f);
    }
    else if ([typeStr isEqualToString:@"健身"])
    {
        return UIColorFromRGB(0x67c250);
    }
    else if ([typeStr isEqualToString:@"户外"])
    {
        return UIColorFromRGB(0x45b7b2);
    }
    else if ([typeStr isEqualToString:@"桌球"])
    {
        return UIColorFromRGB(0xfeae88);
    }
    else if ([typeStr isEqualToString:@"游泳"])
    {
        return UIColorFromRGB(0x6ddffe);
    }
    else if ([typeStr isEqualToString:@"乒乓球"])
    {
        return UIColorFromRGB(0x8d7f93);
    }
    else if ([typeStr isEqualToString:@"网球"])
    {
        return UIColorFromRGB(0xfe9fe0);
    }
    else if ([typeStr isEqualToString:@"走跑"])
    {
        return UIColorFromRGB(0x9abb29);
    }
    else if ([typeStr isEqualToString:@"自行车"])
    {
        return UIColorFromRGB(0x7e5089);
    }
    else if ([typeStr isEqualToString:@"操课"])
    {
        return UIColorFromRGB(0x30173a);
    }
    //其他
    return UIColorFromRGB(0x6666ff);
}

@end
