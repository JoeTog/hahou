//
//  FileHandle.m
//  SuperZhaQun
//
//  Created by King on 2017/1/13.
//
//

#import "FileHandle.h"
//#import "GTMBase64.h"


@implementation FileHandle

//读取文件内容
+(NSString *)readTxt_withFileName:(NSString *)name andPath:(NSString *)path{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //在这里获取应用程序Documents文件夹里的文件及文件夹列表
    NSString *documentDir = [path stringByAppendingPathComponent:name];
    NSError *error = nil;
    //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    
    
    if([fileManager fileExistsAtPath:documentDir]){
        //NSLog(@"文件存在");
        //读取文件
        NSString *textFileContents = [NSString stringWithContentsOfFile:documentDir encoding:NSUTF8StringEncoding error:&error];
        
        if(textFileContents==nil){
            textFileContents = [NSString stringWithContentsOfFile:documentDir encoding:NSUTF16StringEncoding error:&error];
        }
        if(textFileContents==nil){
            textFileContents = [NSString stringWithContentsOfFile:documentDir encoding:NSUTF32StringEncoding error:&error];
        }
        if(textFileContents==nil){
            textFileContents = [NSString stringWithContentsOfFile:documentDir encoding:NSASCIIStringEncoding error:&error];
        }
        
        //NSLog(@"内容=%@",textFileContents);
        //NSLog(@"错误信息=%@",error);
        
        if(textFileContents){
            return textFileContents;
        }
        
    }
    
    //NSLog(@"文件不存在");
    return nil;
    
}




//获取 文件名 列表
+(NSArray *)receiveAllFileName_withPath:path{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //在这里获取应用程序Documents文件夹里的文件及文件夹列表
    NSString *documentDir = path;
    NSError *error = nil;
    NSArray *fileList = [[NSArray alloc] init];
    //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    fileList = [fileManager contentsOfDirectoryAtPath:documentDir error:&error];
    
    NSMutableArray * resultArray = [[NSMutableArray alloc] init];
    
    for(NSString * str in fileList){
        if(str){
            ////NSLog(@"文件名-------%@",str);
            [resultArray addObject:str];
            
        }
    }
    
    return resultArray;
}



//写内容
+(BOOL)writeFile_withPath:(NSString *)iOSPath andContent:(NSString *)content{
    
    BOOL isSuccess = [content writeToFile:iOSPath atomically:NO encoding:NSUTF8StringEncoding error:nil];
    
    if (isSuccess) {
        //NSLog(@"write success");
    } else {
        //NSLog(@"write fail");
    }
    return isSuccess;
}


//删除文件
+(BOOL)deleteFile_withPath:(NSString *)iOSPath{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isSuccess = [fileManager removeItemAtPath:iOSPath error:nil];
    //    if (isSuccess) {
    //        //NSLog(@"删除成功");
    //    }else{
    //        //NSLog(@"删除失败");
    //    }
    return isSuccess;
}

//把字典 写入本地plist文件
+(void)writeDict_withPath:(NSString *)path andDictionary:(NSDictionary *)dict
{
    //NSLog(@"写入字典---");
    
    [dict writeToFile:path atomically:NO];
}


+(NSDictionary *)readDictionary_withPath:(NSString *)path
{
    //读取到一个NSDictionary
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    return dictionary;
}

//创建 文件夹
+(BOOL)createDirectory_withPath:(NSString *)path{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isSuccess = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    
    return isSuccess;
}


//写 字符串
+(void)writeString_withPath:(NSString *)path andContent:(NSString *)dict
{
    //NSLog(@"写入字典---");
    //写入文件
    [dict writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:nil];
    
}

//读 字符串
+(NSString *)readString_withPath:(NSString *)path
{
    //读入文件
    NSString * content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    return content;
}
//保存数组 到本地
+(void)writeArray_withPath:(NSString *)path andArray:(NSArray *)array
{
    
    [array writeToFile:path atomically:NO];
    
}
//读取数组
+(NSArray *)readArray_withPath:(NSString *)path
{
    
    NSArray *resultArray = [NSArray arrayWithContentsOfFile:path];
    return resultArray;
}






/*
 
 2月
 17。 20  。 23 。25  。28 。
 3月
 3.6.9.15.20 25  30
 
 晚上5－7点
 
 */


+(void)httpByUrl:(NSString *)urlStr
         success:(void (^)(id responseObject))success
         failure:(void(^)(NSError *error))failure {
    
    //网址加密解密
    //加密
    //    NSString * slsl=[GTMBase64 base64StringFromText:@"http://ol9aklity.bkt.clouddn.com/sync.html?v=" withKey:[NSString stringWithFormat:@"%s",ROCKET_PWD]];
    //
    //    //NSLog(@"网址加密后:%@",slsl);
    
    
    NSString *URL = urlStr;//[NSString stringWithFormat:@"%@%@",llll,strRandom];
    //以免有中文进行UTF编码
    NSString *UTFPathURL = [URL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //请求路径
    NSURL *url = [NSURL URLWithString:UTFPathURL];
    //创建请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //设置请求超时
    request.timeoutInterval = 3;
    //创建session配置对象
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    //创建session对象
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    //添加网络任务
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        ////NSLog(@"网络请求开始->");
        
        
        if (error)
        {
            ////NSLog(@"请求失败...");
            
        }
        else
        {
            
            NSString * result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            success(result);
            
            
        }
    }];
    //开始任务
    [task resume];
}


////加密
//+(NSString *)encryptData:(NSString *)strData
//{
//    return [GTMBase64 base64StringFromText:strData withKey:[NSString stringWithFormat:@"%s",ROCKET_PWD]];
//}
//
////解密
//+(NSString *)decryptData:(NSString *)strData
//{
//    return [GTMBase64 textFromBase64String:strData withKey:[NSString stringWithFormat:@"%s",ROCKET_PWD]];
//}


//判断目录是否存在
+(BOOL)judgeExistFileDirectories_withPath:(NSString *)path
{
    // 判断存放音频、视频的文件夹是否存在,不存在则创建对应文件夹
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = YES;
    BOOL isDirExist = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    
    if(!(isDirExist))
    {
        NSLog(@"不存在-路径=%@ ",path);
    }
    else{
        NSLog(@"存在-路径=%@ ",path);

    }
    
    return isDirExist;
    
}



@end
