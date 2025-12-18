//
//  FileHandle.h
//  SuperZhaQun
//
//  Created by King on 2017/1/13.
//
//

#import <Foundation/Foundation.h>

@interface FileHandle : NSObject


//读取文件内容
+(NSString *)readTxt_withFileName:(NSString *)name andPath:(NSString *)path;
//获取 文件名 列表
+(NSArray *)receiveAllFileName_withPath:path;

//写内容
+(BOOL)writeFile_withPath:(NSString *)iOSPath andContent:(NSString *)content;

//删除文件
+(BOOL)deleteFile_withPath:(NSString *)iOSPath;


//把字典 写入本地plist文件
+(void)writeDict_withPath:(NSString *)path andDictionary:(NSDictionary *)dict;
//读取本地保存的plist文件 作为NSDictionary
+(NSDictionary *)readDictionary_withPath:(NSString *)path;

//创建文件夹
+(BOOL)createDirectory_withPath:(NSString *)path;



+(void)writeString_withPath:(NSString *)path andContent:(NSString *)dict;
+(NSString *)readString_withPath:(NSString *)path;

//保存数组 到本地
+(void)writeArray_withPath:(NSString *)path andArray:(NSArray *)array;
//读取数组
+(NSArray *)readArray_withPath:(NSString *)path;

+(void)httpByUrl:(NSString *)urlStr success:(void (^)(id responseObject))success failure:(void(^)(NSError *error))failure;


//判断目录是否存在
+(BOOL)judgeExistFileDirectories_withPath:(NSString *)path;


+(void)networking1;



@end
