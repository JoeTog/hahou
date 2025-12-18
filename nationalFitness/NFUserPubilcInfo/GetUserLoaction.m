//
//  GetUserLoaction.m
//  nationalFitness
//
//  Created by 程龙 on 15/9/9.
//  Copyright (c) 2015年 chenglong. All rights reserved.
//

#import "GetUserLoaction.h"
#import "NFUserEntity.h"

@implementation GetUserLoaction
{
//    AMapSearchAPI *search_;
}

//- (void)searchReGeocodeWithCoordinate:(CGFloat)Longitude userLatitude:(CGFloat)Latitude
//{
//    if (!search_)
//    {
//        search_ = [[AMapSearchAPI alloc] initWithSearchKey:[MAMapServices sharedServices].apiKey Delegate:self];
//
//        AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
//        regeo.location = [AMapGeoPoint locationWithLatitude:Latitude longitude:Longitude];
//
//        regeo.requireExtension = NO;
//
//        [search_ AMapReGoecodeSearch:regeo];
//    }
//}
//
//- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
//{
//    if (response.regeocode.addressComponent.city.length > 0 && response.regeocode.addressComponent.adcode.length > 0)
//    {
//        [NFUserEntity shareInstance].cityName = response.regeocode.addressComponent.city;
//        NSRange range = NSMakeRange(0, 4);
//        NSString *codeStr = [response.regeocode.addressComponent.adcode substringWithRange:range];
//        [NFUserEntity shareInstance].cityCode = [NSString stringWithFormat:@"%@00", codeStr];
//        DLog(@"%@-%@",[NFUserEntity shareInstance].cityName, [NFUserEntity shareInstance].cityCode);
//        [KeepAppBox keepVale:[NFUserEntity shareInstance].cityName forKey:kLoginCityName];
//        [KeepAppBox keepVale:[NFUserEntity shareInstance].cityCode forKey:kLoginCityCode];
//        [NFUserEntity shareInstance].currentCityCode = [NSString stringWithFormat:@"%@00", codeStr];
//        [NFUserEntity shareInstance].currentCityName = response.regeocode.addressComponent.city;
//        [NFUserEntity shareInstance].currentLoName = response.regeocode.formattedAddress;
//        if (self.returnLocation) {
//            self.returnLocation(response.regeocode.formattedAddress);
//        }
//    }
//    else
//    {
//        DLog(@"地理逆编码失败－读取旧地址");
//        [NFUserEntity shareInstance].cityName = [KeepAppBox checkValueForkey:kLoginCityName];
//        [NFUserEntity shareInstance].cityCode = [KeepAppBox checkValueForkey:kLoginCityCode];
//        [NFUserEntity shareInstance].currentCityName = [KeepAppBox checkValueForkey:kLoginCityName];
//        [NFUserEntity shareInstance].currentCityCode = [KeepAppBox checkValueForkey:kLoginCityCode];
//        [NFUserEntity shareInstance].currentLoName = [KeepAppBox checkValueForkey:kLoginCityName];
//    }
//}
//
//-(void)returnLocation:(ReturnLocation)block{
//    if (self.returnLocation != block) {
//        self.returnLocation = block;
//    }
//}
//
//- (void)dealloc
//{
//    search_.delegate = nil;
//    search_ = nil;
//}


@end
