//
//  AppDelegate.h
//  nationalFitness
//
//  Created by 程long on 14-10-22.
//  Copyright (c) 2014年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <HealthKit/HealthKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreData/CoreData.h>
#import "QRCodeScanViewController.h"
#import "NFTabBarViewController.h"
#import "ZJContactViewController.h"
#import "NFbaseNavViewController.h"
#import "JQFMDB.h"
#import "MessageEntity.h"
#import "SocketModel.h"
#import "ZJContact.h"
#import "NewHomeEntity.h"

//controller
#import "MessageChatViewController.h"
#import "GroupChatViewController.h"

#import "CCAppManager.h"

#import "SocketRequest.h"





//测试环境appkey    a3c5639f2ff8a44f0f3f8f2d
//开发环境appkey    69718a0b8a8f90f5fc0a6585
#define JPushAPPKey @"69718a0b8a8f90f5fc0a6585"
//#define JPushAPPKey @"a3c5639f2ff8a44f0f3f8f2d"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    NSURL               *_updateURL;
    
    UIAlertView         *_updateAlertView;
    
    UIView *tView;
}
//懒加载
@property (strong, nonatomic) NFMyManage *myManage;

@property (strong, nonatomic) UIWindow *window;


//@property (nonatomic, readwrite) HKHealthStore *healthStore;

@property (strong,nonatomic)NSUserDefaults *userDefault;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;


- (NSURL *)applicationDocumentsDirectory;
- (void)saveContext;

- (UIViewController *)topController;

@end

