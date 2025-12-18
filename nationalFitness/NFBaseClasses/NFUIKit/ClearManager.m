//
//  ClearManager.m
//  nationalFitness
//
//  Created by Joe on 2017/9/8.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "ClearManager.h"

@implementation ClearManager

//将数字转成字符串 类方法
+ (NSString *)NumToString:(NSString *)num{
    NSDictionary *numDict = @{@"0":@"a",@"1":@"b",@"2":@"c",@"3":@"d",@"4":@"e",@"5":@"f",@"6":@"g",@"7":@"h",@"8":@"i",@"9":@"j"};
    
    NSString *newStr = [num description];
    NSMutableString *mutableString = [NSMutableString new];
    NSString *temp =nil;
    for(int i =0; i < [newStr length]; i++)
    {
        temp = [newStr substringWithRange:NSMakeRange(i,1)];
        
//        int a = [self checkIsHaveNumAndLetter:temp];
        int a = 0;
        //数字条件
        NSRegularExpression *tNumRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[0-9]" options:NSRegularExpressionCaseInsensitive error:nil];
        
        //符合数字条件的有几个字节
        NSUInteger tNumMatchCount = [tNumRegularExpression numberOfMatchesInString:temp
                                                                           options:NSMatchingReportProgress
                                                                             range:NSMakeRange(0, temp.length)];
        
        //英文字条件
        NSRegularExpression *tLetterRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[A-Za-z]" options:NSRegularExpressionCaseInsensitive error:nil];
        
        //符合英文字条件的有几个字节
        NSUInteger tLetterMatchCount = [tLetterRegularExpression numberOfMatchesInString:temp options:NSMatchingReportProgress range:NSMakeRange(0, temp.length)];
        if (tNumMatchCount == temp.length) {
            //全部符合数字，表示沒有英文
            a =  1;
        } else if (tLetterMatchCount == temp.length) {
            //全部符合英文，表示沒有数字
            a =  2;
        } else if (tNumMatchCount + tLetterMatchCount == temp.length) {
            //符合英文和符合数字条件的相加等于密码长度
            a =  3;
        } else {
            a = 4;
            //可能包含标点符号的情況，或是包含非英文的文字，这里再依照需求详细判断想呈现的错误
        }
        
        //如果是数字 则替换成字母再拼接 否则直接拼接
        if (a == 1) {
            NSString *appendString = numDict[temp];
            [mutableString appendString:appendString];
        }else{
            [mutableString appendString:temp];
        }
        
    }
    return mutableString;
}


//将数字转成字符串
- (NSString *)NumToString:(NSString *)num{
    NSDictionary *numDict = @{@"0":@"a",@"1":@"b",@"2":@"c",@"3":@"d",@"4":@"e",@"5":@"f",@"6":@"g",@"7":@"h",@"8":@"i",@"9":@"j"};
    
    NSString *newStr = [num description];
    NSMutableString *mutableString = [NSMutableString new];
    NSString *temp =nil;
    for(int i =0; i < [newStr length]; i++)
    {
        temp = [newStr substringWithRange:NSMakeRange(i,1)];
        int a = [self checkIsHaveNumAndLetter:temp];
        //如果是数字 则替换成字母 否则直接拼接
        if (a == 1) {
            NSString *appendString = numDict[temp];
            [mutableString appendString:appendString];
        }else{
            [mutableString appendString:temp];
        }
        
    }
    return mutableString;
}

//是否含有数字 或字母
-(int)checkIsHaveNumAndLetter:(NSString*)password{
    //数字条件
    NSRegularExpression *tNumRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[0-9]" options:NSRegularExpressionCaseInsensitive error:nil];
    
    //符合数字条件的有几个字节
    NSUInteger tNumMatchCount = [tNumRegularExpression numberOfMatchesInString:password
                                                                       options:NSMatchingReportProgress
                                                                         range:NSMakeRange(0, password.length)];
    
    //英文字条件
    NSRegularExpression *tLetterRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[A-Za-z]" options:NSRegularExpressionCaseInsensitive error:nil];
    
    //符合英文字条件的有几个字节
    NSUInteger tLetterMatchCount = [tLetterRegularExpression numberOfMatchesInString:password options:NSMatchingReportProgress range:NSMakeRange(0, password.length)];
    
    if (tNumMatchCount == password.length) {
        //全部符合数字，表示沒有英文
        return 1;
    } else if (tLetterMatchCount == password.length) {
        //全部符合英文，表示沒有数字
        return 2;
    } else if (tNumMatchCount + tLetterMatchCount == password.length) {
        //符合英文和符合数字条件的相加等于密码长度
        return 3;
    } else {
        return 4;
        //可能包含标点符号的情況，或是包含非英文的文字，这里再依照需求详细判断想呈现的错误
    }
    
}


#pragma mark - 通知appicon角标
+(void)notificateBadge:(NSString *)message infoDict:(NSDictionary *)info{
    //本地推送计数
    UILocalNotification *sendMessage = [[UILocalNotification alloc] init];
    sendMessage.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
    sendMessage.timeZone = [NSTimeZone defaultTimeZone];
    //    sendMessage.alertBody = @"I am the futher of ";
    sendMessage.alertBody = message;
    NSInteger badge = 1;
    if ([NFUserEntity shareInstance].badgeCount && [NFUserEntity shareInstance].badgeCount< 0) {
        [NFUserEntity shareInstance].badgeCount = 0;
    }
    badge += [NFUserEntity shareInstance].badgeCount;
    [UIApplication sharedApplication].applicationIconBadgeNumber = badge;
    sendMessage.soundName = UILocalNotificationDefaultSoundName;
    //可能在这里进行传值 用于在外面点击跳转
    sendMessage.userInfo = info;
    sendMessage.category = kNotificationCategoryIdentifile;
    [[UIApplication sharedApplication] scheduleLocalNotification:sendMessage];
}

#pragma mark - 获取表情个数
+ (NSInteger)stringContainsEmojiCount:(NSString *)string
{
    __block BOOL returnValue = NO;
    __block NSRange emojiRange;
    __block NSInteger emojiCount = 0;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar hs = [substring characterAtIndex:0];
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    if (substring.length > 1) {
                                        const unichar ls = [substring characterAtIndex:1];
                                        const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f77f) {
                                            returnValue = YES;
                                            emojiRange = substringRange;
                                            emojiCount++;
                                        }
                                    }
                                } else if (substring.length > 1) {
                                    const unichar ls = [substring characterAtIndex:1];
                                    if (ls == 0x20e3) {
                                        returnValue = YES;
                                        emojiRange = substringRange;
                                        emojiCount++;
                                    }
                                } else {
                                    if (0x2100 <= hs && hs <= 0x27ff) {
                                        returnValue = YES;
                                        emojiRange = substringRange;
                                        emojiCount++;
                                    } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                        returnValue = YES;
                                        emojiRange = substringRange;
                                        emojiCount++;
                                    } else if (0x2934 <= hs && hs <= 0x2935) {
                                        returnValue = YES;
                                        emojiRange = substringRange;
                                        emojiCount++;
                                    } else if (0x3297 <= hs && hs <= 0x3299) {
                                        returnValue = YES;
                                        emojiRange = substringRange;
                                        emojiCount++;
                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                        returnValue = YES;
                                        emojiRange = substringRange;
                                        emojiCount++;
                                    }
                                }
                            }];
    return emojiCount;
    //    return emojiRange;
    //    return returnValue;
}

#pragma mark - 是否含有表情
+ (BOOL)stringContainsEmoji:(NSString *)string
{
    __block BOOL returnValue = NO;
    __block NSRange emojiRange;
    __block NSInteger emojiCount = 0;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar hs = [substring characterAtIndex:0];
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    if (substring.length > 1) {
                                        const unichar ls = [substring characterAtIndex:1];
                                        const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f77f) {
                                            returnValue = YES;
                                            emojiRange = substringRange;
                                            emojiCount++;
                                        }
                                    }
                                } else if (substring.length > 1) {
                                    const unichar ls = [substring characterAtIndex:1];
                                    if (ls == 0x20e3) {
                                        returnValue = YES;
                                        emojiRange = substringRange;
                                        emojiCount++;
                                    }
                                } else {
                                    if (0x2100 <= hs && hs <= 0x27ff) {
                                        returnValue = YES;
                                        emojiRange = substringRange;
                                        emojiCount++;
                                    } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                        returnValue = YES;
                                        emojiRange = substringRange;
                                        emojiCount++;
                                    } else if (0x2934 <= hs && hs <= 0x2935) {
                                        returnValue = YES;
                                        emojiRange = substringRange;
                                        emojiCount++;
                                    } else if (0x3297 <= hs && hs <= 0x3299) {
                                        returnValue = YES;
                                        emojiRange = substringRange;
                                        emojiCount++;
                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                        returnValue = YES;
                                        emojiRange = substringRange;
                                        emojiCount++;
                                    }
                                }
                            }];
//    return emojiCount;
    //    return emojiRange;
        return returnValue;
}

#pragma mark - 存字典到userdefault
+(void)saveToArrWithDict:(NSDictionary *)dic UserDefaultName:(NSString *)tablenamwe{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *messageArr = [defaults objectForKey:tablenamwe];
    NSMutableArray *messageMutableArr = [NSMutableArray arrayWithArray:messageArr];
    [messageMutableArr addObject:dic];
    messageArr = [NSArray arrayWithArray:messageMutableArr];
    [defaults setObject:messageArr forKey:tablenamwe];
    
}

#pragma mark - 取字典数组到userdefault
+(NSArray *)getDictArrFromTableName:(NSString *)tablenamwe{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *messageArr = [defaults objectForKey:tablenamwe];
    return messageArr;
}


#pragma mark - 图片  转  base64字符串
+(NSString *)UIImageToBase64Str:(UIImage *) image IsOriginalImage:(BOOL)ret
{
    //    image = [ClearManager imageByScalingAndCroppingForSize:CGSizeMake(1024, 1024)  Image:image];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.99f);
    NSData *data = UIImageJPEGRepresentation(image, 1.0f);
    
    //下面一块代码是对图片的处理 暂时没用到
    CGFloat ChatPicWH = 1000;
    CGFloat itemW = 0;
    CGFloat itemH = 0;
    if (image.size.height > image.size.width) {
        itemW = image.size.width / image.size.height * ChatPicWH;
    }else{
        itemH = image.size.height / image.size.width * ChatPicWH;
    }
    CGSize size = CGSizeMake(itemW == 0?ChatPicWH:itemW, itemH == 0?ChatPicWH:itemH);
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    NSData *dataa = UIImageJPEGRepresentation(scaledImage, 0.7f);
    
//    NSLog(@"%d",data.length);
//    NSLog(@"%d",dataa.length);
    //    UIImageView *first = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    //    first.image = scaledImage;
    //    UIImageView *sec = [[UIImageView alloc] initWithFrame:CGRectMake(0, 220, 200, 200)];
    //    sec.image = [UIImage imageWithData:data];
    //    UIWindow *win = [[[UIApplication sharedApplication] windows] firstObject];
    //    [win addSubview:first];
    //    [win addSubview:sec];
    
    if (data.length < 500000) {
        imageData = data;
    }
    if (imageData.length > 2000000) {
        imageData = UIImageJPEGRepresentation(image, 0.4f);
        if (imageData.length > 500000) {
            imageData = UIImageJPEGRepresentation(image, 0.3f);
        }
        if (imageData.length > 500000) {
            imageData = UIImageJPEGRepresentation(image, 0.2f);
        }
    }else if (imageData.length > 1000000){
        imageData = UIImageJPEGRepresentation(image, 0.5f);
        if (imageData.length > 500000) {
            imageData = UIImageJPEGRepresentation(image, 0.3f);
        }
        if (imageData.length > 500000) {
            imageData = UIImageJPEGRepresentation(image, 0.2f);
        }
    }else{
        if (imageData.length > 500000) {
            imageData = UIImageJPEGRepresentation(image, 0.7f);
        }
        if (imageData.length > 500000) {
            imageData = UIImageJPEGRepresentation(image, 0.5f);
        }
        if (imageData.length > 500000) {
            imageData = UIImageJPEGRepresentation(image, 0.4f);
        }
    }
    if (imageData.length > 700000) {
        imageData = UIImageJPEGRepresentation(image, 0.1f);
    }
    if (ret) {
        //原图
    }else{
        //非原图
        imageData = dataa;
    }
    NSLog(@"\n\n%ld\n\n%ld\n\n",imageData.length,data.length);
    NSString *encodedImageStr = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return encodedImageStr;
}



#pragma mark - base64字符串  转  图片
+(UIImage *)Base64StringToImage:(NSString *) imageString
{
    NSData *_decodedImageData   = [[NSData alloc] initWithBase64Encoding:imageString];
    
    UIImage *_decodedImage      = [UIImage imageWithData:_decodedImageData];
    
//    UIImageView *first = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
//    first.image = _decodedImage;
//    UIImageView *sec = [[UIImageView alloc] initWithFrame:CGRectMake(0, 220, 200, 200)];
//    sec.image = [UIImage imageWithData:_decodedImageData];
//    UIWindow *win = [[[UIApplication sharedApplication] windows] firstObject];
//    [win addSubview:first];
//    [win addSubview:sec];
//
    return _decodedImage;
}


//图片压缩到指定大小
+ (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize Image:(UIImage *)image
{
    UIImage *sourceImage = image;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth= width * scaleFactor;
        scaledHeight = height * scaleFactor;
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - 是否允许撤回
+(BOOL)IsAllowDraw:(NSInteger)receiveTime{
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:receiveTime];
    NSTimeInterval time = [currentDate timeIntervalSinceDate:confromTimesp];
    NSInteger timme = time;
    if (timme <= 180) {
        return YES;
    }
    return NO;
}

#pragma mark - 获取网络状态
+(BOOL)getNetStatus{
    Reachability *reachability   = [Reachability reachabilityWithHostName:@"www.apple.com"];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus == NotReachable) {
        return NO;
    }
    return YES;
}

#pragma mark - 生成本地唯一APPMsgId
+(NSString *)getAPPMsgId{
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYMMddhhmmssSS"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
//    NSString *AppMessageId = [NSString stringWithFormat:@"%@%@",dateString,[NFUserEntity shareInstance].userName];
    return [NSString stringWithFormat:@"%@%@",dateString,[NFUserEntity shareInstance].userName];;
}

#pragma mark - 获取域名的ip地址
-(void)getServerIP{
//    NSString *hostname = @"apple.com";
//    CFHostRef hostRef = CFHostCreateWithName(kCFAllocatorDefault, (__bridge CFStringRef)hostname);
//    if (hostRef)
//    {
//        Boolean result = CFHostStartInfoResolution(hostRef, kCFHostAddresses, NULL);
//        if (result == TRUE)
//        {
//            NSArray *addresses = (__bridge NSArray*)CFHostGetAddressing(hostRef, &result);
//
//            NSMutableArray *tempDNS = [[NSMutableArray alloc] init];
//            for(int i = 0; i < addresses.count; i++)
//            {
//                struct sockaddr_in* remoteAddr;
//                CFDataRef saData = (CFDataRef)CFArrayGetValueAtIndex((__bridge CFArrayRef)addresses, i);
//                remoteAddr = (struct sockaddr_in*)CFDataGetBytePtr(saData);
//
//                if(remoteAddr != NULL)
//                {
//                    const char *strIP41 = inet_ntoa(remoteAddr->sin_addr);
//                    NSString *strDNS =[NSString stringWithCString:strIP41 encoding:NSASCIIStringEncoding];
//                    NSLog(@"RESOLVED %d:<%@>", i, strDNS);
//                    [tempDNS addObject:strDNS];
//                }
//            }
//        }
//    }
}

#pragma mark - 获取当前时间戳
+(NSString *)getCurrentTimeStamp{
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSTimeInterval interval = [currentDate timeIntervalSince1970];
    NSInteger timeInter = interval;
    return [NSString stringWithFormat:@"%ld",timeInter];
}

#pragma mark - 获取index为index的根视图
-(UIViewController *)getRootViewControllerOfTabbarRootIndex:(NSInteger)index{
    //获取tabbar的index为0的根视图
    UIViewController *currentVCC =  [self getCurrentVCFrom:[UIApplication sharedApplication].keyWindow.rootViewController];
    NSArray *arr = currentVCC.navigationController.tabBarController.viewControllers;
    UINavigationController *NAVC = arr[0];
//    UIViewController *firstTabbarVC = NAVC.viewControllers[0];
    return NAVC.viewControllers[index];
}

#pragma mark - 获取当前controller
- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    
    if ([rootVC presentedViewController]) {
        // 视图是被presented出来的
        rootVC = [rootVC presentedViewController];
    }
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
    } else {
        // 根视图为非导航类
        currentVC = rootVC;
    }
    return currentVC;

}

+ (BOOL)isBlank:(NSString*)str {
    NSRange range = [str rangeOfString:@" "];
    if(range.location!=NSNotFound) {
    //有空格
        return YES;
    
    }else{
    //没有空格
        return NO;
    }
}

//控制图片大小在120字节内
+(NSData *)imageDataScale:(UIImage *)image scale:(CGFloat)scale{
    NSData *imageD = UIImageJPEGRepresentation(image, scale);
    int i = 0;
    do {
        i++;
        scale = imageD.length > 10000?scale/2:1;
        imageD = UIImageJPEGRepresentation(image, scale);
    } while (imageD.length > 10000 && i<6);
//    if (imageD.length > 1200000) {
//    }else{
        return imageD;
//    }
//    return UIImageJPEGRepresentation(image, scale);
}




@end








