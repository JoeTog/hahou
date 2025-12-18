//
//  RPFQRCode.h
//  NIM
//
//  Created by King on 2019/2/10.
//  Copyright © 2019年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



NS_ASSUME_NONNULL_BEGIN

@interface RPFQRCode : NSObject

- (UIImage *)QRCodeMethod:(NSString *)qrCodeString;

@end

NS_ASSUME_NONNULL_END
