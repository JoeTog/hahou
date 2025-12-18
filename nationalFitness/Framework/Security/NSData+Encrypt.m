//
//  NSData+Encrypt.m
//  MIP
//
//  Created by Sea on 13-9-12.
//  Copyright (c) 2013年 Sea. All rights reserved.
//

#import "NSData+Encrypt.h"

@implementation NSData (Encrypt)

/*!
 @function
 @abstract      AES256加密
 
 @param         key                     AES加密的密钥
 @param         encoding                key的编码方式
 
 @result        加密后的NSData
 */
- (NSData *)AES256EncryptWithKey:(NSString *)key keyEncoding:(NSStringEncoding)encoding  //加密
{
    //需要16位的KEY
    if(key.length > 16)
    {
        key = [key substringToIndex:16];
    }
    
    if (key.length < 16)
    {
        for (NSInteger i = key.length; i <= 16; i ++)
        {
            key = [NSString stringWithFormat:@"%@0",key];
        }
    }
    
    char keyPtr[kCCKeySizeAES256+1];
    
    bzero(keyPtr, sizeof(keyPtr));
    
    if (![key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:encoding]) {//如果key转换为char失败,则返回nil
        
        return nil;
    }
    
    NSUInteger dataLength = [self length];//计算需要加密数据的长度
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeAES128,
                                          NULL,
                                          [self bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    
    if (cryptStatus == kCCSuccess) {
        
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
        
    }
    
    free(buffer);
    
    return nil;
}


/*!
 @function
 @abstract      AES256解密
 
 @param         key                     AES解密的密钥
 @param         encoding                key的编码方式
 
 @result        解密后的NSData
 */
- (NSData *)AES256DecryptWithKey:(NSString *)key keyEncoding:(NSStringEncoding)encoding  //解密
{
    //需要16位的KEY
    if(key.length > 16)
    {
        key = [key substringToIndex:16];
    }
    
    if (key.length < 16)
    {
        for (NSInteger i = key.length; i <= 16; i ++)
        {
            key = [NSString stringWithFormat:@"%@0",key];
        }
    }
    
    char keyPtr[kCCKeySizeAES256+1];
    
    bzero(keyPtr, sizeof(keyPtr));
    
    if (![key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:encoding]) {
        
        return nil;
    }
    
    NSUInteger dataLength = [self length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          NULL,
                                          [self bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer);
    
    return nil;
}



/*!
 @function
 @abstract      AES128使用PKCS7Padding填充模式的加密/解密
 
 @param         iv                      AES填充模式采用kCCOptionPKCS7Padding,iv为填充字符串
 @param         ivEncoding              iv的编码方式
 @param         symmetricKey            对称密钥字符串
 @param         keyEncoding             symmetricKey的编码方式
 @param         operation               操作方式,加密还是解密
 
 @result        加密/解密后的NSData
 */
- (NSData *)cipherByAES:(NSString *)iv
             ivEncoding:(NSStringEncoding)ivEncoding
                    key:(NSString *)symmetricKey
            keyEncoding:(NSStringEncoding)keyEncoding
              operation:(CCOperation)operation
{
    CCCryptorStatus ccStatus   = kCCSuccess;
    size_t          cryptBytes = 0;    // Number of bytes moved to buffer.
    
    
    char keyPtr[kCCKeySizeAES128];
    
    bzero(keyPtr, sizeof(keyPtr));
    
    if (![symmetricKey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:keyEncoding]) {
        
        return nil;
    }
    
    
    char ivPtr[kCCBlockSizeAES128+1];
    
    bzero(ivPtr, sizeof(ivPtr));
    
    if (![iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:ivEncoding]) {
        
        return nil;
    }
    
    
    NSUInteger dataLength = [self length];//计算需要加密数据的长度
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    
    void *buffer = malloc(bufferSize);
    
    ccStatus = CCCrypt(operation,
                       kCCAlgorithmAES128,
                       kCCOptionPKCS7Padding,
                       keyPtr,
                       kCCKeySizeAES128,
                       ivPtr,
                       self.bytes,
                       self.length,
                       buffer,
                       bufferSize,
                       &cryptBytes);
    
    if (ccStatus == kCCSuccess) {

        return [NSData dataWithBytesNoCopy:buffer length:cryptBytes];
    }
    
    free(buffer);
    
    return nil;
}

@end
