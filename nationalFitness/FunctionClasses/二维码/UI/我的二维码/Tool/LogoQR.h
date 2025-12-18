//
//  LogoQR.h
//  iOS二维码详细生成代码
//
//  Created by 金钱象 on 16/11/1.
//  Copyright © 2016年 zhonghuatianchuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface LogoQR : NSObject

-(UIImage *)QRurl:(NSString *)url messages:(NSString *)message;

@end
