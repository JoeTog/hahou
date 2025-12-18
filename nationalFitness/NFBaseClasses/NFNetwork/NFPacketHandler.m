//
//  YourPacketHandler.m
//  SummaryHoperun
//
//  Created by 程long on 14-7-30.
//  Copyright (c) 2014年 chenglong. All rights reserved.
//

#import "NFPacketHandler.h"
#import "NFUserEntity.h"
#import "KeepAppBox.h"

/*********此处存放所有功能的网络请求地址********/

#pragma mark - 登陆和注册接口

//广告
NSString *const adsListURL = @"" kServiceIP"home/queryAdsList.action";

//版本升级服务地址
NSString *const updateVersionURL = @"" kServiceReplaceLocation"ticketSale/queryMembershipCardList.action";



//上传图片
NSString *const uploadPicURL = @"" kServiceReplaceLocation"commons/uploadPhoto.action";



//获取验证码
NSString *const gotVerificationURL = @"http://211.142.203.122:9001/qmjs_FEP/commons/sendMessage.action";

//验证码校验
NSString *const checkVerificationURL = @"" kServiceReplaceLocation"user/checkVailCode.action";

//忘记密码
NSString *const findPassWordURL = @"" kServiceReplaceLocation"user/createRegisterUser.action";

//注册信息填写
NSString *const registerInfoURL = @"" kServiceReplaceLocation"user/registerUserAndLogin.action";

//用户登录
NSString *const loginRequestURL = @"" kServiceReplaceLocation"do_login";

//注册
NSString *const changePassWordURL = @"" kServiceReplaceLocation"do_register";

//getIPManagerManagerURL
//NSString *const getIPManagerManagerURL = @"" kServiceReplaceLocation"do_register";


//第三方登陆
NSString *const loginThirdURL = @"" kServiceReplaceLocation"user/thirdPartyLoginInfo.action";

//发布相册之前上传单张照片  to do for yaowen
NSString *const uploadAlbumURL = @"" kServiceReplaceLocation"web_file/index.php?s=/Home/Index/upload";

//相册图片
FOUNDATION_EXPORT                   NSString                        *const albumPhotoListURL;

//发布相册
FOUNDATION_EXPORT                     NSString                        *const createAlbumURL;

#pragma mark - 联系人
//联系人列表
FOUNDATION_EXPORT                     NSString                        *const contantListManagerUrl;



#pragma mark - 开户
FOUNDATION_EXPORT                     NSString                        *const openAccountManagerUrl;






/*********此处存放所有功能的网络请求地址********/


@implementation NFPacketHandler

+ (NSData *)appendingPostDataWithBodyDictionary:(NSDictionary *)body
{
    SystemInfo *systemInfo = [SystemInfo shareSystemInfo];
    NFUserEntity *userEntity = [NFUserEntity shareInstance];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    NSMutableDictionary *header = [[NSMutableDictionary alloc] initWithCapacity:11];
    
    [header setObject:@"" forKey:@"retStatus"];
    [header setObject:@"" forKey:@"retMessage"];
    [header setObject:systemInfo.deviceId forKey:@"deviceId"];//设备ID
    [header setObject:@"2" forKey:@"devType"];//设备类型
    [header setObject:systemInfo.deviceType forKey:@"devModuleID"];//用户设备型号
    [header setObject:systemInfo.appId forKey:@"appId"];//appId
    [header setObject:@"" forKey:@"funcId"];//功能ID ********功能未知,暂填空
    [header setObject:systemInfo.appVersion forKey:@"appVersion"];//版本，必填
    [header setObject:systemInfo.OSVersion forKey:@"osVersion"];//osVersion
    [header setObject:@"" forKey:@"interceptTime"];//interceptTime
    
    if (userEntity.userId)
    {
        [header setObject:userEntity.userId forKey:@"userId"];//用户ID     *******需登录后获取
    }
    else
    {
        [header setObject:@"" forKey:@"userId"];
    }
    
    //版本类型verOrgCode 1 - 大众版 2 - 常州 3 - 校园
    [header setObject:@"1" forKey:@"verOrgCode"];
    
    //用户的所选组织的code
    if (userEntity.orgCode.length > 0)
    {
        [header setObject:userEntity.orgCode forKey:@"orgCode"];
    }
    else
    {
        [header setObject:@"" forKey:@"orgCode"];
    }
    
    //系统code
    if (userEntity.sysCode.length > 0)
    {
        [header setObject:userEntity.sysCode forKey:@"sysCode"];
    }
    else
    {
        [header setObject:@"" forKey:@"sysCode"];
    }
    
    //PUSH TOKEN
    NSString *tokenStr = [KeepAppBox checkValueForkey:@"kDeviceTokenKeyForPush"];
    if (0 == tokenStr.length)
    {
        [header setObject:@"" forKey:@"accessToken"];//accessToken
    }
    else
    {
        [header setObject:[KeepAppBox checkValueForkey:@"kDeviceTokenKeyForPush"] forKey:@"accessToken"];//accessToken
    }
    
    //所在城市code
    NSString *lastCity = [KeepAppBox checkValueForkey:@"kLoginCityCode"];
    if (6 == lastCity.length)
    {
        [header setObject:lastCity forKey:@"cityCode"];
    }
    else
    {
        [header setObject:@"410300" forKey:@"cityCode"];
    }
    
    if(userEntity.currentCityCode.length > 0)
    {
        [header setObject:userEntity.currentCityCode forKey:@"currentCityCode"];
    }
    else
    {
        [header setObject:@"" forKey:@"currentCityCode"];
    }
    
    [params setObject:header forKey:@"header"];
    
    /**
     *  给BODY加密
     */
    NSError *parseError = nil;
    NSData  *bodyJson = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:&parseError];
    bodyJson = [bodyJson AES256EncryptWithKey:[NSString stringWithFormat:@"%@%@",AES_KEY,systemInfo.deviceId] keyEncoding:NSUTF8StringEncoding];
    
    NSString *bodyStr = [self stringWithHexBytes: bodyJson];
    
    [params setObject:bodyStr forKey:@"body"];
    
//    [params setObject:body forKey:@"body"];
    
    __autoreleasing NSError *error = nil;
    
    NSData *paramsData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *paramsString = [[NSString alloc] initWithData:paramsData encoding:NSUTF8StringEncoding];
    
    NSString *postString = [NSString stringWithFormat:@"params=%@",paramsString];
    
    postString = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)postString,
                                                                           NULL,
                                                                           (CFStringRef)@"+&",
                                                                           kCFStringEncodingUTF8));
    NSLog(@"======请求 url=====%@",paramsString);
    
    NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding];
    
    if (!error)
    {
        return postData;
    }
    
    return nil;
}

//NSData转换16进制字符
+ (NSString *)stringWithHexBytes :(NSData *)data
{
    NSMutableString *stringBuffer = [NSMutableString
                                     stringWithCapacity:([data length] * 2)];
    const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
    NSInteger i;
    
    for (i = 0; i < [data length]; ++i) {
        [stringBuffer appendFormat:@"%02lX", (unsigned long)dataBuffer[i]];
    }
    return stringBuffer;
}

//16进制字符转换为NSData
+ (NSData *) hexStringToNSData :(NSString *)keyStr
{
    NSMutableData* data = [NSMutableData data];
    NSInteger idx;
    for (idx = 0; idx+2 <= keyStr.length; idx += 2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [keyStr substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        uint intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

+ (NSData *)postFormRequestParams: (NSDictionary *)postParems // IN
                        imageData: (NSData *)data  // IN
                        imageName: (NSString *)picFileName // IN
{
    //分界线 --AaB03x
//    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
    //结束符 AaB03x--
//    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",MPboundary];
    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",MPboundary];
    
    //http body的字符串
    NSMutableString *body=[[NSMutableString alloc]init];
    //参数的集合的所有key的集合
    //NSArray *keys= [postParems allKeys];
    
    //遍历keys
//    for(NSInteger i=0;i<[keys count];i++)
//    {
//        //得到当前key
//        NSString *key=[keys objectAtIndex:i];
//        
//        //添加分界线，换行
////        [body appendFormat:@"%@\r\n",MPboundary];
//        //添加字段名称，换2行
//        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
//        //添加字段的值
//        [body appendFormat:@"%@\r\n",[postParems objectForKey:key]];
//        
//        NSLog(@"添加字段的值==%@",[postParems objectForKey:key]);
//    }
    
    if(data){
        ////添加分界线，换行
        [body appendFormat:@"%@\r\n",MPboundary];
        //声明pic字段，文件名为boris.png
        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",@"photo",picFileName];
//        [body appendFormat:@"name=\"%@\"; filename=\"%@\"\r\n",@"file",picFileName];
//        [body appendFormat:@"Content-Transfer-Encoding: binary\r\n"];
        //声明上传文件的格式
        if ([postParems objectForKey:@"imageType"]) {
            [body appendFormat:[NSString stringWithFormat:@"Content-Type: image/%@\r\n\r\n",[postParems objectForKey:@"imageType"]]];
        }else{
            [body appendFormat:@"Content-Type: image/png\r\n\r\n"];
        }
//        [body appendFormat:@"Content-Type: application/octet-stream\r\n"];
        
    }
    
    //声明结束符：--AaB03x--
    NSString *end=[[NSString alloc]initWithFormat:@"\r\n%@",endMPboundary];
    //声明myRequestData，用来放入http body
    NSMutableData *postData=[NSMutableData data];
    
    //将body字符串转化为UTF8格式的二进制
    [postData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    if(data){
        //将image的data加入
        [postData appendData:data];
    }
    //加入结束符--AaB03x--
    [postData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    return postData;
}

+ (NSData *)postFormRequestParams: (NSDictionary *)postParems // IN
                        audioData: (NSData *)data  // IN
                        audioName: (NSString *)audioFileName // IN
{
    //分界线 --AaB03x
    //    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
    //结束符 AaB03x--
    //    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",MPboundary];
    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",MPboundary];
    
    //http body的字符串
    NSMutableString *body=[[NSMutableString alloc]init];
    //参数的集合的所有key的集合
   // NSArray *keys= [postParems allKeys];
    
    //遍历keys
    //    for(NSInteger i=0;i<[keys count];i++)
    //    {
    //        //得到当前key
    //        NSString *key=[keys objectAtIndex:i];
    //
    //        //添加分界线，换行
    ////        [body appendFormat:@"%@\r\n",MPboundary];
    //        //添加字段名称，换2行
    //        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
    //        //添加字段的值
    //        [body appendFormat:@"%@\r\n",[postParems objectForKey:key]];
    //
    //        NSLog(@"添加字段的值==%@",[postParems objectForKey:key]);
    //    }
    
    if(data){
        ////添加分界线，换行
        [body appendFormat:@"%@\r\n",MPboundary];
        
        //声明pic字段，文件名为boris.png
        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",@"photo",audioFileName];
        //        [body appendFormat:@"name=\"%@\"; filename=\"%@\"\r\n",@"file",picFileName];
        //        [body appendFormat:@"Content-Transfer-Encoding: binary\r\n"];
        //声明上传文件的格式
//        if ([postParems objectForKey:@"imageType"]) {
//            [body appendFormat:[NSString stringWithFormat:@"Content-Type: image/%@\r\n\r\n",[postParems objectForKey:@"imageType"]]];
//        }else{
//            [body appendFormat:@"Content-Type: image/png\r\n\r\n"];
//        }
        [body appendFormat:@"Content-Type: application/octet-stream\r\n"];
        
    }
    
    //声明结束符：--AaB03x--
    NSString *end=[[NSString alloc]initWithFormat:@"\r\n%@",endMPboundary];
    //声明myRequestData，用来放入http body
    NSMutableData *postData=[NSMutableData data];
    
    //将body字符串转化为UTF8格式的二进制
    [postData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    if(data){
        //将image的data加入
        [postData appendData:data];
    }
    //加入结束符--AaB03x--
    [postData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    return postData;
}

@end
