//
//  NFUserEntity.h
//  SummaryHoperun
//
//  Created by 程long on 14-7-30.
//  Copyright (c) 2014年 chenglong. All rights reserved.
//

#import "NFUserEntity.h"
#import "KeepAppBox.h"
#import "GetUserLoaction.h"

static NFUserEntity *userEntity = nil;

@implementation NFUserEntity
{
    GetUserLoaction *getLoaction_;
}

/*!
 @function
 @abstract      用户对象的实体单例
 
 @note          该对象中的对象属性不可被多线程共享访问修改
 
 @result        返回用户的单例对象
 */
+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        userEntity = [NFUserEntity new];
        
        //定位
//        if (userEntity.locationManager == nil) {
//            userEntity.locationManager = [[CLLocationManager alloc] init];
//        }
//        userEntity.locationManager.delegate = userEntity;
//        userEntity.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//        userEntity.locationManager.activityType = CLActivityTypeFitness;
//        // 让应用始终在后台运行
//        userEntity.locationManager.pausesLocationUpdatesAutomatically = NO;
//
//        // Movement threshold for new events.
//        userEntity.locationManager.distanceFilter = 200; // meters  更新的最小距离
//
//        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)
//        {
//            [userEntity.locationManager requestAlwaysAuthorization];//?在后台也可定位
//        }
//        // 5.iOS9新特性：将允许出现这种场景：同一app中多个location manager：一些只能在前台定位，另一些可在后台定位（并可随时禁止其后台定位）。
//        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9)
//        {
//            userEntity.locationManager.allowsBackgroundLocationUpdates = YES;
//        }
//
//        [userEntity.locationManager startUpdatingLocation];
        
            });
    
    return userEntity;
}

//改变对象
- (void)changeUserDistanceFilter:(CGFloat)distanceFilter andDelagate:(id)delagate
{
//    [userEntity.locationManager stopUpdatingLocation];
//    if (distanceFilter > 0)
//    {
//        userEntity.locationManager.distanceFilter = distanceFilter;
//    }
//    if (delagate)
//    {
//        userEntity.locationManager.delegate = delagate;
//    }
//    [userEntity.locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    CLLocation *firstloc = [locations  lastObject];
//    CLLocationCoordinate2D tranformCoord = firstloc.gcjCoord;

    CLLocationCoordinate2D tranformCoord = firstloc.coordinate;

//    CLLocationCoordinate2D tranformCoord = transform(firstloc.coordinate);
    
    [NFUserEntity shareInstance].userLongitude = tranformCoord.longitude;
    [NFUserEntity shareInstance].userLatitude = tranformCoord.latitude;

    NSLog(@"%@",[NFUserEntity shareInstance].cityName);//打印城市名 淮安市
    NSLog(@"%@",[NFUserEntity shareInstance].currentLoName);//打印具体位置 江苏省淮安市清江浦区乐园步行街
    if ([NFUserEntity shareInstance].currentCityCode.length == 0)
    {
        getLoaction_ = nil;
        getLoaction_ = [[GetUserLoaction alloc] init];
        [getLoaction_ searchReGeocodeWithCoordinate:[NFUserEntity shareInstance].userLongitude userLatitude:[NFUserEntity shareInstance].userLatitude];
        [getLoaction_ returnLocation:^(NSString *locationString) {
            NSLog(@"");
        }];
    }
}
//
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    // 定位失败
    if([NFUserEntity shareInstance].cityName.length == 0)
    {
        [NFUserEntity shareInstance].cityName = [KeepAppBox checkValueForkey:kLoginCityName];
        [NFUserEntity shareInstance].cityCode = [KeepAppBox checkValueForkey:kLoginCityCode];
        [NFUserEntity shareInstance].currentCityName = [KeepAppBox checkValueForkey:kLoginCityName];
        [NFUserEntity shareInstance].currentCityCode = [KeepAppBox checkValueForkey:kLoginCityCode];
        [NFUserEntity shareInstance].currentLoName = [KeepAppBox checkValueForkey:kLoginCityName];
    }
}

#pragma mark - cleardata

- (void)clearUserData
{
    userEntity.userId                         = nil;
    userEntity.mobile                       = nil;
    userEntity.accessToken                  = nil;
    userEntity.loginName                    = nil;
    userEntity.password                     = nil;
    userEntity.hobby                        = nil;
    userEntity.signaTure                    = nil;
    userEntity.dynamicNew                   = nil;
    userEntity.currentArea                  = nil;
    userEntity.roleType                 = nil;
    userEntity.smallpicpath                   = nil;
    userEntity.bigpicpath                   = nil;
    userEntity.matrixPicUrl                 = nil;
    userEntity.sex                           = NFUnknow;
    userEntity.idNumber                     = nil;
    userEntity.nickName                       = nil;
    userEntity.remark                       = nil;
    userEntity.realName                     = nil;
    userEntity.proName                      = nil;
    userEntity.nickNameChanged              =   0;
    userEntity.userType                   = NFUserGeneral;
    userEntity.isUserMynj                     = NO;
    userEntity.orepationType                = OT_LoginDefault;
    userEntity.userHeight                   = nil;
    userEntity.userWeight                   = nil;
    userEntity.birthDay                      = nil;
    userEntity.hdnumber                      = nil;
    userEntity.userAge                      = nil;
    userEntity.healthStatus                 = nil;
    userEntity.conStell                     = nil;
    userEntity.sexUality                    = nil;
    userEntity.orgCode                      = nil;
    userEntity.sysCode                      = nil;
    userEntity.currentArea                  = nil;
    userEntity.inviteCode                   = nil;
    getLoaction_                           =  nil;
    userEntity.leftTime                     = 100;
    userEntity.clientId                     = nil;
    userEntity.userName                     = nil;
    userEntity.isPicImageDynamic            = NO;
    userEntity.IsApplyAndNotify             = NO;
    userEntity.currentChatId            = nil;
    userEntity.yuehouYincang            = 0;
    userEntity.guanjiQingkong            = 0;
    userEntity.badgeCount            = 0;
    userEntity.isGuanjiClear        = NO;
    userEntity.timeOutCountBegin      = NO;
    userEntity.backgroundImage      = nil;
    userEntity.backgroundIndex     = NULL;
    userEntity.KeepBoxEntity    = nil;
    userEntity.mineHeadView   = nil;
    userEntity.mineHeadViewImage   = nil;
    userEntity.isNeedRefreshFriendList   = NO;
    userEntity.isNeedRefreshChatList   = NO;
    userEntity.selectedTheme            = NULL;
    userEntity.PushQRCode   = nil;
    userEntity.isNeedRefreshChatData   = NO;
    userEntity.IsNotNeedTestView   = NO;
    userEntity.isNeedRefreshLocalChatList   = NO;
    userEntity.isSingleChat   = nil;
    userEntity.IsUploadingPicture  = NO;
    userEntity.IsRequestNearestDynamic  = NO;
    userEntity.isNeedDeleteDidselectedPush  = NO;
    userEntity.showHidenMessage  = NO;
    userEntity.MineQRCodeImage  = nil;
    userEntity.isNeedRefreshSingleChatHistory  = NO;
    userEntity.showPrompt  = NO;
    userEntity.forwardImage  = nil;
    userEntity.appStatus  = NO;
    userEntity.IsNeedRefreshApply  = NO;
    userEntity.signText  = nil;
    userEntity.friendAddDetailEntity  = nil;
    userEntity.contactBadgeCount  = 0;
    userEntity.ServerIsClosed  = NO;
    userEntity.isNeedRefreshGroupChatHistory  = NO;
    userEntity.connectStatus  = nil;
    userEntity.groupMatrixPicUrl  = nil;
    userEntity.WXHeadPicpath  = nil;
    userEntity.WXNickName  = nil;
    userEntity.userIsConncected  = NO;
    userEntity.netIP  = nil;
    userEntity.JPushId  = nil;
    userEntity.reconnectTimeInterval            = 0;
    userEntity.IsCloseJPush  = NO;
    userEntity.IsRecovering  = NO;
    
    userEntity.IsAutoBack  = NO;
    
    userEntity.isTiXianPassWord  = NO;
    userEntity.isShouquanCancelPwd  = NO;
    
    userEntity.phoneNum  = @"";
    
    userEntity.currentController  = nil;
    userEntity.dynamicBadgeCount  = 0;
    
    
    
}

@end
