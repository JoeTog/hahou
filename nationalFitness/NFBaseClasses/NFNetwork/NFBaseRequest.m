//
//  NFBaseRequest.m
//  nationalFitness
//
//  Created by 程long on 14-10-28.
//  Copyright (c) 2014年 chenglong. All rights reserved.
//

#import "NFBaseRequest.h"


#define neiwang @"http://192.168.0.113:8080/api/";

//域名在h文件中
//#define kainuo @"http://47.98.105.33:7999/"
//#define kainuo @"http://47.97.230.179:7999/"

#define rongyu @"http://rongyu.chxjon.cn/index.php?ctl=user&act="

//是否加密 0加密 1不加密
#define isUseKey @"1"

static NSString* NSStringFromQueryParameters(NSDictionary* queryParameters)
{
    NSMutableArray* parts = [NSMutableArray array];
    [queryParameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        NSString *part = [NSString stringWithFormat: @"%@=%@",
                          [key stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding],
                          [value stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]
                          ];
        [parts addObject:part];
    }];
    return [parts componentsJoinedByString: @"&"];
}
//static NSURL* NSURLByAppendingQueryParameters(NSURL* URL, NSDictionary* queryParameters)
//{
//    NSString* URLString = [NSString stringWithFormat:@"%@?%@",
//                           [URL absoluteString],
//                           NSStringFromQueryParameters(queryParameters)
//                           ];
//    return [NSURL URLWithString:URLString];
//}

@implementation NFBaseRequest


+ (NSURLRequest *) gotRequest:(NSDictionary *)info andURL:(NSString *)url
{
    NSMutableURLRequest *request;
    //包含这个字断并且有orgcode
    if ([url rangeOfString:kServiceReplaceLocation].length > 0)
    {
        NSString *baseUrl = [NSString stringWithString:url];
        [NFUserEntity shareInstance].urlStr = rongyu;
        NSString *newbaseUrl = [baseUrl stringByReplacingOccurrencesOfString:kServiceReplaceLocation withString:[NFUserEntity shareInstance].urlStr];
        request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:newbaseUrl]];
    }
    else
    {
        request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    }
    
    [request setTimeoutInterval:kRequestTimeout];
    
    [request setHTTPMethod:@"POST"];
    //拼接一个userid
//    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:info];
//    [NFUserEntity shareInstance].userId = @"123";
//    [mutableDict setObject:[NFUserEntity shareInstance].userId forKey:@"userId"];
    //info = [NSDictionary dictionaryWithDictionary:mutableDict];
    
    NSData *postBody;
    
    if ([isUseKey isEqualToString:@"0"]) {
        postBody = [NFPacketHandler appendingPostDataWithBodyDictionary:info];
    }else if ([isUseKey isEqualToString:@"1"]){
//        if ([info objectForKey:@"param"]) {
//            NSString *asd = NSStringFromQueryParameters(@{@"param":NSStringFromQueryParameters([info objectForKey:@"param"])});
//            postBody =  [asd dataUsingEncoding:NSUTF8StringEncoding];
//        }else{
            postBody =  [NSStringFromQueryParameters(info) dataUsingEncoding:NSUTF8StringEncoding];
//        }
    }
    
    //postBody = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:nil];
    
    [request setHTTPBody:postBody];
    return request;
    
}



// 上传图片
+ (NSURLRequest *)uploadPicRequestWithParams:(NSDictionary*)params imageData:(NSData*)imageData
{
    NSMutableURLRequest *request;
//    if ([[params objectForKey:@"pictype"] isEqual:@"0"])
//    {
        NSString *baseUrl = [NSString stringWithString:uploadAlbumURL];
        NSString *newbaseUrl = [baseUrl stringByReplacingOccurrencesOfString:kServiceReplaceLocation withString:kainuo];
        request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:newbaseUrl]];
//    }
//    else
//    {
//        NSString *baseUrl = [NSString stringWithString:uploadAlbumURL];
//        NSString *newbaseUrl = [baseUrl stringByReplacingOccurrencesOfString:kServiceReplaceLocation withString:kainuo];
//        request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:newbaseUrl]];
//    }
    
    
    [request setTimeoutInterval:kRequestTimeout * 2];
    
    // 设置HTTPHeader中Content-Type的值
    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
//    NSString *content= @"multipart/form-data; boundary=----WebKitFormBoundary152rps24Q3uQvOnF";
    
    // 设置HTTPHeader
    NSData *postData;
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    if ([params objectForKey:@"imgaeType"]) {
        postData = [NFPacketHandler postFormRequestParams:params imageData:imageData imageName: [NSString stringWithFormat:@"photo.%@",[params objectForKey:@"imgaeType"]]];
    }else{
        postData = [NFPacketHandler postFormRequestParams:params imageData:imageData imageName:@"photo.png"];
    }
    
//    postData = [@"" dataUsingEncoding:NSUTF8StringEncoding];
    
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%@", @([postData length])] forHTTPHeaderField:@"Content-Length"];
    
    //设置http body
    [request setHTTPBody:postData];
    
    //http method
    [request setHTTPMethod:@"POST"];
    
    return request;
    
}

//上传相册
+ (NSURLRequest *)uploadAlbumWithParams:(NSDictionary*)params imageData:(NSData*)imageData
{
    NSMutableURLRequest *request;
    NSString *baseUrl = [NSString stringWithString:uploadAlbumURL];
    NSString *newbaseUrl = [baseUrl stringByReplacingOccurrencesOfString:kServiceReplaceLocation withString:[NFUserEntity shareInstance].urlStr];
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:newbaseUrl]];
    [request setTimeoutInterval:kRequestTimeout * 4];
    
    // 设置HTTPHeader中Content-Type的值
    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
    
    // 设置HTTPHeader
    NSData *postData;
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    postData = [NFPacketHandler postFormRequestParams:params imageData:imageData imageName:@"image.png"];
    
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%@", @([postData length])] forHTTPHeaderField:@"Content-Length"];
    
    //设置http body
    [request setHTTPBody:postData];
    
    //http method
    [request setHTTPMethod:@"POST"];
    
    return request;
}

//上传徽章
+ (NSURLRequest *)uploadBadgeWithParams:(NSDictionary*)params imageData:(NSData*)imageData
{
    NSMutableURLRequest *request;
    NSString *baseUrl = [NSString stringWithString:uploadAlbumURL];
    NSString *newbaseUrl = [baseUrl stringByReplacingOccurrencesOfString:kServiceReplaceLocation withString:[NFUserEntity shareInstance].urlStr];
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:newbaseUrl]];
    [request setTimeoutInterval:kRequestTimeout * 4];
    
    // 设置HTTPHeader中Content-Type的值
    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
    
    // 设置HTTPHeader
    NSData *postData;
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    postData = [NFPacketHandler postFormRequestParams:params imageData:imageData imageName:@"image.png"];
    
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%@", @([postData length])] forHTTPHeaderField:@"Content-Length"];
    
    //设置http body
    [request setHTTPBody:postData];
    
    //http method
    [request setHTTPMethod:@"POST"];
    
    return request;
}

//上传举报图片
+ (NSURLRequest *)uploadReportWithParams:(NSDictionary*)params imageData:(NSData*)imageData
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:uploadAlbumURL]];
    [request setTimeoutInterval:kRequestTimeout * 4];
    
    // 设置HTTPHeader中Content-Type的值
    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
    
    // 设置HTTPHeader
    NSData *postData;
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    postData = [NFPacketHandler postFormRequestParams:params imageData:imageData imageName:@"image.png"];
    
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%@", @([postData length])] forHTTPHeaderField:@"Content-Length"];
    
    //设置http body
    [request setHTTPBody:postData];
    
    //http method
    [request setHTTPMethod:@"POST"];
    
    return request;
}

//上传语音
+ (NSURLRequest *)uploadAudioWithParams:(NSDictionary*)params audioData:(NSData*)audioData
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:uploadAlbumURL]];
    [request setTimeoutInterval:kRequestTimeout * 4];
    
    // 设置HTTPHeader中Content-Type的值
    NSString *content=[[NSString alloc]initWithFormat:@"audio/x-caf; boundary=%@",TWITTERFON_FORM_BOUNDARY];
    
    // 设置HTTPHeader
    NSData *postData;
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    postData = [NFPacketHandler postFormRequestParams:params audioData:audioData audioName:@"image.png"];
    
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%@", @([postData length])] forHTTPHeaderField:@"Content-Length"];
    
    //设置http body
    [request setHTTPBody:postData];
    
    //http method
    [request setHTTPMethod:@"POST"];
    
    return request;
}






@end
