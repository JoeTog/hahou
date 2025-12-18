//
//  MKNetworkManager.h
//  TJCaiWu
//
//  Created by King on 2018/9/29.
//

#import <Foundation/Foundation.h>

@interface MKNetworkManager : NSObject

+ (instancetype)sharedInstance;

- (void)requestNetWithParams:(NSDictionary *)params andMethod:(NSString *)method andURL:(NSString *)urlstr andCompleteBlock:(void(^)(NSDictionary * responseDict,NSError * error))cBlock;


@end
