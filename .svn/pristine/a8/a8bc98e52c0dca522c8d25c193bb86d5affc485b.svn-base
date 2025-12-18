//
//  NSString+MD5Encrypt.m
//  MOA
//
//  Created by  on 12-2-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSString+MD5Encrypt.h"

@implementation NSString (md5)

-(NSString *) md5EncryptUsingEncoding:(NSStringEncoding)encoding {
    
    const char *original_str = [self cStringUsingEncoding:encoding];
    
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(original_str, strlen(original_str), result);
    
    NSMutableString *hash = [NSMutableString string];
    
    for (int i = 0; i < 16; i++)
        
        [hash appendFormat:@"%02X", result[i]];
    
    return [hash lowercaseString];
}

@end
