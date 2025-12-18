//
//  MKNetworkManager.m
//  TJCaiWu
//
//  Created by King on 2018/9/29.
//

#import "MKNetworkManager.h"
#import "AFNetworking.h"


@interface MKNetworkManager()



@end


static const NSString * HttpPath = @"http://47.98.32.244";


@implementation MKNetworkManager

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}




- (void)requestNetWithParams:(NSDictionary *)params andMethod:(NSString *)method andURL:(NSString *)urlstr andCompleteBlock:(void(^)(NSDictionary * responseDict,NSError * error))cBlock
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:params];
    
    NSLog(@"afn---params=(%@)",parameters);
    // 設置請求格式
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", nil];

    if(method && [method isEqualToString:@"POST"])
    {
        [manager POST:urlstr parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            NSLog(@"afn---responseObject=(%@);type=(%@)", responseObject,[responseObject class]);
            
            if(cBlock && [responseObject isKindOfClass:[NSDictionary class]])
            {
                NSLog(@"net---response---doBlock");
                cBlock(responseObject,nil);
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            if (error)
            {
                NSLog(@"afn---Error: %@", error);
                if(cBlock)
                {
                    cBlock(@{},error);
                }
            }
        }];
    }
    else if(method && [method isEqualToString:@"GET"])
    {
        [manager GET:urlstr parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
        }];

    }
    
    
    
    
    
}



@end
