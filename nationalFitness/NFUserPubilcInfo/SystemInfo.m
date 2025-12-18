//
//  SystemInfo.h
//  SummaryHoperun
//
//  Created by 程long on 14-7-30.
//  Copyright (c) 2014年 chenglong. All rights reserved.
//

#import "SystemInfo.h"
#import "KeychainItemWrapper.h"
#import <objc/runtime.h>

static SystemInfo *systemInfo = nil;

NSString *const kSystemNetworkChangedNotification = @"kNetworkReachabilityChangedNotification";

@interface SystemInfo ()
{
    Class               _originalClass; //用于检测代理有效性
}

@end


@implementation SystemInfo

@synthesize appId;
@synthesize appVersion;
@synthesize deviceId;
@synthesize deviceType;
@synthesize OSVersion;


- (NSString *)appId
{
    if (!appId)
    {
        appId = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey];
    }
    
    return appId;
}

- (NSString *)appVersion
{
    if (!appVersion)
    {
        appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    }
    
    return appVersion;
}

-(NSString *)DeviceIPAddresses
{
    int sockfd = socket(AF_INET,SOCK_DGRAM, 0);
    // if (sockfd <</span> 0) return nil; //这句报错，由于转载的，不太懂，注释掉无影响，懂的大神欢迎指导
    NSMutableArray *ips = [NSMutableArray array];
    
    int BUFFERSIZE =4096;
    
    struct ifconf ifc;
    
    char buffer[BUFFERSIZE], *ptr, lastname[IFNAMSIZ], *cptr;
    
    struct ifreq *ifr, ifrcopy;
    
    ifc.ifc_len = BUFFERSIZE;
    
    ifc.ifc_buf = buffer;
    
    if (ioctl(sockfd,SIOCGIFCONF, &ifc) >= 0){
        
        for (ptr = buffer; ptr < buffer + ifc.ifc_len; ){
            
            ifr = (struct ifreq *)ptr;
            
            int len =sizeof(struct sockaddr);
            
            if (ifr->ifr_addr.sa_len > len) {
                len = ifr->ifr_addr.sa_len;
            }
            
            ptr += sizeof(ifr->ifr_name) + len;
            
            if (ifr->ifr_addr.sa_family !=AF_INET) continue;
            
            if ((cptr = (char *)strchr(ifr->ifr_name,':')) != NULL) *cptr =0;
            
            if (strncmp(lastname, ifr->ifr_name,IFNAMSIZ) == 0)continue;
            
            memcpy(lastname, ifr->ifr_name,IFNAMSIZ);
            
            ifrcopy = *ifr;
            
            ioctl(sockfd,SIOCGIFFLAGS, &ifrcopy);
            
            if ((ifrcopy.ifr_flags &IFF_UP) == 0)continue;
            
            NSString *ip = [NSString stringWithFormat:@"%s",inet_ntoa(((struct sockaddr_in *)&ifr->ifr_addr)->sin_addr)];
            [ips addObject:ip];
        }
    }
    close(sockfd);
    
    NSString *deviceIP =@"";
    
    for (int i=0; i < ips.count; i++){
        if (ips.count >0){
            deviceIP = [NSString stringWithFormat:@"%@",ips.lastObject];
        }
    }
    
    return deviceIP;
}

- (NSString *)deviceId
{
    if (!deviceId)
    {
        NSString *result;
        NSUserDefaults *appBox = [NSUserDefaults standardUserDefaults];
        if ([appBox objectForKey:@"appDeviceId"])
        {
            result = [appBox objectForKey:@"appDeviceId"];
        }
        else
        {
            CFUUIDRef unique = CFUUIDCreate(kCFAllocatorDefault);
            result = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, unique));
            CFRelease(unique);
        }
        
        //存储在keychina上面
        NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
        KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:identifier accessGroup:nil];
        //从keychain里取出设备号
        NSString *cfuuid = [keychain objectForKey:(id)kSecAttrAccount];
        
        if (cfuuid.length > 0)
        {
            NSString *value = cfuuid;
            deviceId = value;
        }
        else
        {
            deviceId = result;
            [keychain setObject:result forKey:(id)kSecAttrAccount];
        }
    }
    
    return deviceId;
}


- (NSString *)deviceType
{
    if (!deviceType)
    {
        deviceType = [[UIDevice currentDevice] model];
    }
    
    return deviceType;
}


- (NSString *)OSVersion
{
    if (!OSVersion)
    {
        OSVersion = [[UIDevice currentDevice] systemVersion];
    }
    
    return OSVersion;
}


+ (SystemInfo *)shareSystemInfo
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        systemInfo = [SystemInfo new];
        
    });
    
    return systemInfo;
}


- (id)init
{
    self = [super init];
    
    if (self)
    {
        
        [self registerNetWorkMonitor];
    }
    
    return self;
}

- (void)registerNetWorkMonitor
{
//    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
//    internetReach_ = [Reachability reachabilityForInternetConnection];
//    
//	[internetReach_ startNotifier];
//	[self updateInterfaceWithReachability: internetReach_];
}


//- (void)updateInterfaceWithReachability: (Reachability*) curReach
//{
//    NetworkStatus netStatus = [curReach currentReachabilityStatus];
//    
//    if (netStatus !=NotReachable)
//    {
//        [self uploadTrackData];
//    }
//    
//    switch (netStatus)
//    {
//        case NotReachable:
//        {
//            break;
//        }
//            
//        case ReachableViaWWAN:
//        {
//            break;
//        }
//        case ReachableViaWiFi:
//        {
//            break;
//        }
//    }
//}

// 上传缓存的轨迹数据
- (void)uploadTrackData
{
//    NSMutableArray *dataArr = [[NFGpsStepManager shareManager] getlocationGpsData];
//    if (dataArr.count == 0)
//    {
//        // 没有需要上传的数据
//    }else
//    {
//        // 上传轨迹数据
//        [[NFGpsStepManager shareManager] uploadTrackDataToServerOfData:dataArr WithBlock:NULL];
//    }
}



//Called by Reachability whenever status changes.
//- (void)reachabilityChanged: (NSNotification* )note
//{
//	Reachability* curReach = [note object];
//	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
//	[self updateInterfaceWithReachability: curReach];
//}
//
//
- (NetworkStatus)currentNetworkStatus
{
    NetworkStatus netStatus = [internetReach_ currentReachabilityStatus];
    
    return netStatus;
}

@end
