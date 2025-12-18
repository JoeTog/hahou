//
//  AliyunOSSUpload.m
//  nationalFitness
//
//  Created by joe on 2020/10/28.
//  Copyright © 2020 chenglong. All rights reserved.
//

#import "AliyunOSSUpload.h"

/// 在使用 initWithAuthServerUrl 这种方式初始化阿里云的时候, 传入的 url 是自己家的url.
/// 但是! 一般自己家的url在做请求的时候, 往往在请求头(HTTPHeaderField)里面需要加入参数, 比如自己家用户登录的时候拿到的 token, 需要在后续所有请求头里加上这个token,
/// 再就是加入一些其他请求头参数, 比如, 哪个端,iOS,Android, 版本号之类.
/// 所以,我们 新建一个类, 继承自 OSSFederationCredentialProvider, 然后把 阿 里 云 代 码 直 接 拷 贝 过 来 改写.
@interface ISAuthCredentialProvider : OSSFederationCredentialProvider
@property (nonatomic, copy) NSString * authServerUrl;
@property (nonatomic, copy) NSData * (^responseDecoder)(NSData *);
- (instancetype)initWithAuthServerUrl:(NSString *)authServerUrl;
- (instancetype)initWithAuthServerUrl:(NSString *)authServerUrl responseDecoder:(nullable OSSResponseDecoderBlock)decoder;
@end

@implementation ISAuthCredentialProvider

- (instancetype)initWithAuthServerUrl:(NSString *)authServerUrl {
    return [self initWithAuthServerUrl:authServerUrl responseDecoder:nil];
}

- (instancetype)initWithAuthServerUrl:(NSString *)authServerUrl responseDecoder:(nullable OSSResponseDecoderBlock)decoder {
    
    self = [super initWithFederationTokenGetter:^OSSFederationToken * {
        
        NSURL * url = [NSURL URLWithString:authServerUrl];
        
        //把原来的 NSURLRequest 改成 NSMutableURLRequest, 这样可以加入新的请求头参数, 就加入这么点东西,其余的代码不改.
        NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
        
//        [request setValue:@"用户登录时候拿到的 token" forHTTPHeaderField:@"你们定义好的 token key"];
//        [request setValue:@"其他需要放进来的参数" forHTTPHeaderField:@"其他的参数 key"];
        
        OSSTaskCompletionSource * tcs = [OSSTaskCompletionSource taskCompletionSource];
        NSURLSession * session = [NSURLSession sharedSession];
        NSURLSessionTask * sessionTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                [tcs setError:error];
                return;
            }
            [tcs setResult:data];
        }];
        
        [sessionTask resume];
        [tcs.task waitUntilFinished];
        if (tcs.task.error) {
            return nil;
        } else {
            NSData* data = tcs.task.result;
            if(decoder){
                data = decoder(data);
            }
            NSDictionary * object = [NSJSONSerialization JSONObjectWithData:data
                                                                    options:kNilOptions
                                                                      error:nil];
            int statusCode = [[object objectForKey:@"StatusCode"] intValue];
            if (statusCode == 200) {
                OSSFederationToken * token = [OSSFederationToken new];
                // All the entries below are mandatory.
                
                token.tAccessKey = [object objectForKey:@"AccessKeyId"];
                token.tSecretKey = [object objectForKey:@"AccessKeySecret"];
                token.tToken = [object objectForKey:@"SecurityToken"];
                token.expirationTimeInGMTFormat = [object objectForKey:@"Expiration"];
                
//                token.tAccessKey = @"STS.NUtCvCCa2kwvqWjQQRVg4k95j";
//                token.tSecretKey = @"GuxC27vQCkHhkMUVFGwT5A17FEQPvzvcHW8D8WTfa1kG";
//                token.tToken = @"CAIS5QJ1q6Ft5B2yfSjIr5bBCMz3rr4T3LWdc3HbtVEHWugYhPyeiDz2IH9PdXRpBO0Zt/kxnWpS7fodlqp6U4cdus5tuXo2vPpt6gqET9frYqXXhOV2S/THdEGXDxnkpvewB8zyUNLafNq0dlnAjVUd6LDmdDKkLQzHVJqSksxDb88LZgCicSEkYdBNPVlatdM9P3ncPurPQhnxmTj5Bk1ypi9hjX9+8a2l3vCE7h3XgCfCqIkvqp/2P4KvYuR1IZ57SK3V5uFtcbfb2yMit3o1/axt3qtf4mWF7JPPD0RW8xSAK+rT7toNXQZyffo9ALUW7qq+x/FlvfzSkZz3zApKeqN3K32CHNDxnpCbR7/4Z49gKOjBVi6TgozVBP7cqBg5ZH8XDgROduc6J2V4YR5WEW6Be/L+pQ2VO1r9EvLfi/1py+l8y1T54NyNPEOTRLaU1ykVPJImZl8vLQQR2WHxrlHIlbSozDkagAEo5LhwvUl4u/fr12korq7lXtwsj6sSQvR2RYc4XsFcywusvcqSDP58Xggciemvy5UuW8SGYilwnzscKwOjkSs4uc2jlCIEEoLGOAIyVcQztyC6hZBb52g/Uw3yU68QjMTjag0FOYNIBD1j+WqJvvg6Y4EIhYohCXwADvvcf/DnhQ==";
//                token.expirationTimeInGMTFormat = @"2020-11-05T08:40:28Z";
                
                OSSLogDebug(@"token: %@ %@ %@ %@", token.tAccessKey, token.tSecretKey, token.tToken, [object objectForKey:@"Expiration"]);
                return token;
            }else{
                return nil;
            }
            
        }
    }];
    if(self){
        self.authServerUrl = authServerUrl;
    }
    return self;
}

@end



OSSClient * client;

@implementation AliyunOSSUpload

static AliyunOSSUpload *_uploader;

+ (AliyunOSSUpload *)aliyunInit {
    @synchronized(self) {
        if (_uploader == nil) {
            [OSSLog enableLog];
            _uploader = [[AliyunOSSUpload alloc] init];
//            NSString *OSS_STSTOKEN_URL = @"";
            NSString *OSS_STSTOKEN_URL = @"http://121.43.116.159:3000/";
            id<OSSCredentialProvider> credentialProvider = [[ISAuthCredentialProvider alloc] initWithAuthServerUrl:OSS_STSTOKEN_URL];
            OSSClientConfiguration *cfg = [[OSSClientConfiguration alloc] init];
            client = [[OSSClient alloc] initWithEndpoint:OSS_ENDPOINT credentialProvider:credentialProvider clientConfiguration:cfg];
        }
    }
    return _uploader;
    
    
}


- (void)uploadImage:(NSArray <UIImage *>*)imgArray success:(void (^)(NSArray <NSString *> * nameArray))success {
    
    dispatch_group_t group = dispatch_group_create();
    
    //名字数组
    NSMutableArray *nameArray = [NSMutableArray array];
    
    for (int i = 0; i < imgArray.count; i ++) {
        
        dispatch_group_enter(group); //进入组
        //2018-01-27/5a6c1bb4955c2.jpeg
        NSDate *currentDate = [NSDate date];//获取当前时间，日期
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd"];
        NSString *dateString = [dateFormatter stringFromDate:currentDate];
        NSString *s = [NSString stringWithFormat:@"%@/%d_%@.jpg",dateString,i,[NSUUID UUID].UUIDString];
        OSSPutObjectRequest * put = [OSSPutObjectRequest new];
        put.contentType = @"image/jpeg";
        put.bucketName = BucketName;
        put.objectKey = s;
        put.uploadingData = UIImageJPEGRepresentation(imgArray[i], 1);
        put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
            NSLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
        };
        
        OSSTask * putTask = [client putObject:put];
        [putTask continueWithBlock:^id(OSSTask *task) {
            if (!task.error) {
                NSLog(@"图片上传成功!");
                [nameArray addObject:s];
            } else{
                NSLog(@"图片上传失败: %@" , task.error);
            }
            dispatch_group_leave(group);  //不论是成功或者失败,都离开组
            return nil;
        }];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        success(nameArray);
        NSLog(@"任务全部完成,当前线程 %@",[NSThread currentThread]); //收到任务全部完成的通知
    });
}

@end









