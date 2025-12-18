//
//  YourPacketHandler.h
//  SummaryHoperun
//
//  Created by 程long on 14-7-30.
//  Copyright (c) 2014年 chenglong. All rights reserved.
//

#import "PacketHandler.h"
#import "NSData+Encrypt.h"
#import "SystemInfo.h"

//外网
#define   kServiceIP   "http://ydly.lystyj.gov.cn/qmjs_FEP/"

//周
//#define   kServiceIP   "http://192.168.10.20:8088/qmjs_FEP/"

//李呆逼
//#define   kServiceIP   "http://192.168.0.122:8088/qmjs_FEP/"

//内网
//#define   kServiceIP   "http://192.168.0.104:8080/qmjs_FEP/"

//标示出会被修改的url
#define kServiceReplaceLocation    @"kServiceReplaceLocation"

#define kDefinePassword   @"111111"

#define kHealthReportUrl @"http://weixin.acmeway.com/healthWeb/report/web/getReportList?phoneNum=%@&userCode=160831&pwd=1"

#pragma mark - xmpp host

//头像的路径
#define EMClient_User_Head_Address    @"" kServiceIP"loadpic.jsp?path=/qmjs_files/person/"

//昵称
#define EMClient_User_NickNAME(username) [NSString stringWithFormat:@"user_name_%@",username]

/*********此处存放所有功能的网络请求地址********/
//版本升级服务地址
FOUNDATION_EXPORT                   NSString                *const updateVersionURL;

//自测
FOUNDATION_EXPORT                   NSString                *const selfTestUrl;

//验证码校验
FOUNDATION_EXPORT                   NSString                *const checkVerificationURL;

//忘记密码
FOUNDATION_EXPORT                   NSString                *const findPassWordURL;

//注册信息填写
FOUNDATION_EXPORT                   NSString                *const registerInfoURL;

//用户登录
FOUNDATION_EXPORT                   NSString                *const loginRequestURL;

//第三方登陆
FOUNDATION_EXPORT                   NSString                *const loginThirdURL;

//发布相册之前上传单张照片
FOUNDATION_EXPORT                       NSString                       *const uploadAlbumURL;

//注册
FOUNDATION_EXPORT                       NSString                       *const changePassWordURL;


//相册图片
NSString *const albumPhotoListURL = @"" kServiceReplaceLocation"album/queryAlbumPhotoList.action";

//发布相册
NSString *const createAlbumURL = @"" kServiceReplaceLocation"album/createAlbum.action";

#pragma mark - 联系人
//联系人列表
NSString *const contantListManagerUrl = @"" kServiceReplaceLocation"album/createAlbum.action";

#pragma mark - 开户
NSString *const openAccountManagerUrl = @"http://121.43.116.159:7999/Huifu/huifuCFCA.php?action=pay014";







/*********此处存放所有功能的网络请求地址********/

static NSString *TWITTERFON_FORM_BOUNDARY = @"WebKitFormBoundary152rps24Q3uQvOnF";

static NSString * const FORM_FLE_INPUT = @"image";

static NSString * const AES_KEY = @"www.wowsport.cn";

@interface NFPacketHandler : PacketHandler

//普通
+ (NSData *)appendingPostDataWithBodyDictionary:(NSDictionary *)body;


//图片
+ (NSData *)postFormRequestParams: (NSDictionary *)postParems // IN
                        imageData: (NSData *)data  // IN
                        imageName: (NSString *)picFileName; // IN

//语音
+ (NSData *)postFormRequestParams: (NSDictionary *)postParems // IN
                        audioData: (NSData *)data  // IN
                        audioName: (NSString *)audioFileName; // IN



//NSData转换16进制字符
+ (NSString *)stringWithHexBytes :(NSData *)data;

//16进制字符转换为NSData
+ (NSData *) hexStringToNSData :(NSString *)keyStr;


@end
