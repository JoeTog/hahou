//
//  DES3Util.h
//  SeTest
//
//  Created by nevercry on 10/9/14.
//  Copyright (c) 2014 nevercry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DES3Util : NSObject


// 加密方法
+ (NSString*)encrypt:(NSString*)plainText;

// 解密方法
+ (NSString*)decrypt:(NSString*)encryptText;

@end
