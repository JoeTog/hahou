//
//  RPFOpenPacketViewController.m
//  NIM
//
//  Created by King on 2019/2/18.
//  Copyright © 2019年 Netease. All rights reserved.
//

#import "RPFOpenPacketViewController.h"
#import "UIImageView+WebCache.h"
#import "MKNetworkManager.h"
#import "UIView+Toast.h"
#import "NSArray+DLog.h"
#import "NSDictionary+DLog.h"
#import "RPFRedpacketDetailVC.h"


@interface RPFOpenPacketViewController ()<ChatHandlerDelegate>
@property(nonatomic,strong)NSDictionary * dataDic;
@end

@implementation RPFOpenPacketViewController{
    
    SocketModel * socketModel;
    SocketRequest *socketRequest;
    
    
    
}

//

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [SVProgressHUD dismiss];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (socketModel.delegate != self) {
        socketModel.delegate = self;
    }
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setHidden:YES];
    
    self.nameBtnNone.hidden = YES;
    
    ViewRadius(self.headImgView, self.headImgView.frame.size.height/2);
    
    [self initScoket];
    
    
    //[self checkResult];
    
    
    //[self buildView];
    
    //
    
}

#pragma mark - 初始化scoket
-(void)initScoket{
    //获取单例
    socketRequest = [SocketRequest share];
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    
    
    [SVProgressHUD show];
    //检查红包
    [socketRequest checkRedPacket:@{@"groupId":self.groupId,@"redpacketId":self.redpacketId}];
    
    //[self buildView];
    
}

#pragma mark - 收到服务器消息
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    if (messageType == SecretLetterType_packetCheck) {
        //红包检查
        //拆过 跳转到详情
        NSDictionary *checkRedDict = chatModel;
        if ([[[checkRedDict objectForKey:@"status"] description] isEqualToString:@"1"]) {
            [SVProgressHUD dismiss];
            //拆红包界面
            [self buildView];
            
        }else if ([[[checkRedDict objectForKey:@"status"] description] isEqualToString:@"0"]){
            //直接跳转到红包明细
            RPFRedpacketDetailVC * vc = [[RPFRedpacketDetailVC alloc] init];
            //vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            
            vc.thirdToken = self.thirdToken;
            vc.userId = self.userId;
            vc.redpacketId = self.redpacketId;
            vc.appkey = self.appkey;
            vc.groupId = self.groupId;
            if (@available(iOS 13.0, *)) {
                UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
                NSArray *viewcontrollers=currentVC.navigationController.viewControllers;
                if (viewcontrollers.count > 1) {
                    NSLog(@"");
                } else {
                        //present方式
                        vc.modalPresentationStyle = UIModalPresentationFullScreen;  // 修改默认值
                }
            }
            [self presentViewController:vc animated:YES completion:^{
                NSLog(@"in--RPFRedpacketDetailVC");
                
            }];
            
            [self dismissViewControllerAnimated:NO completion:^{
                
            }];
            
        }else if([[[checkRedDict objectForKey:@"status"] description] isEqualToString:@"2"]){
            //抢红包的时候 红包已经抢完
            //RPFNoneViewController
//            RPFNoneViewController * detailVC = [[RPFNoneViewController alloc] initWithNibName:@"RPFNoneViewController" bundle:nil];
            
            [self refreshData];
            
        }
        
    }else if(messageType == SecretLetterType_packetCheck){
        [SVProgressHUD dismiss];
        //抢红包成功 跳转到领取
        RPFRedpacketDetailVC * vc = [[RPFRedpacketDetailVC alloc] init];
        //vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        
        vc.thirdToken = self.thirdToken;
        vc.userId = self.userId;
        vc.redpacketId = self.redpacketId;
        vc.appkey = self.appkey;
        vc.groupId = self.groupId;
        if (@available(iOS 13.0, *)) {
            UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
            NSArray *viewcontrollers=currentVC.navigationController.viewControllers;
            if (viewcontrollers.count > 1) {
                NSLog(@"");
            } else {
                    //present方式
                    vc.modalPresentationStyle = UIModalPresentationFullScreen;  // 修改默认值
            }
        }
        [self presentViewController:vc animated:YES completion:^{
            NSLog(@"in--RPFRedpacketDetailVC");
            
        }];
        [self dismissViewControllerAnimated:NO completion:^{
            
        }];
        
    }else if(messageType == SecretLetterType_openPacketSuccess){
        //
        [SVProgressHUD dismiss];
        //抢红包成功 跳转到领取
        RPFRedpacketDetailVC * vc = [[RPFRedpacketDetailVC alloc] init];
        //vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        
//        vc.thirdToken = self.thirdToken;
//        vc.userId = self.userId;
//        vc.appkey = self.appkey;
        vc.redpacketId = self.redpacketId;
        vc.groupId = self.groupId;
        if (@available(iOS 13.0, *)) {
            UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
            NSArray *viewcontrollers=currentVC.navigationController.viewControllers;
            if (viewcontrollers.count > 1) {
                NSLog(@"");
            } else {
                    //present方式
                    vc.modalPresentationStyle = UIModalPresentationFullScreen;  // 修改默认值
            }
        }
        [self presentViewController:vc animated:YES completion:^{
            NSLog(@"in--RPFRedpacketDetailVC");
            
        }];
        [self dismissViewControllerAnimated:NO completion:^{
            
        }];
    }else if(messageType == SecretLetterType_SocketRequestFailed){
        [SVProgressHUD dismiss];
        [self dismissViewControllerAnimated:NO completion:^{
            
        }];
    }else if(messageType == SecretLetterType_lookPacket){
        //红包详情
        [SVProgressHUD dismiss];
        //抢红包成功 跳转到领取
        RPFRedpacketDetailVC * vc = [[RPFRedpacketDetailVC alloc] init];
        //vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        
        //        vc.thirdToken = self.thirdToken;
        //        vc.userId = self.userId;
        //        vc.appkey = self.appkey;
        vc.redpacketId = self.redpacketId;
        vc.groupId = self.groupId;
        vc.redDetailDict = chatModel;
        if (@available(iOS 13.0, *)) {
            UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
            NSArray *viewcontrollers=currentVC.navigationController.viewControllers;
            if (viewcontrollers.count > 1) {
                NSLog(@"");
            } else {
                    //present方式
                    vc.modalPresentationStyle = UIModalPresentationFullScreen;  // 修改默认值
            }
        }
        [self presentViewController:vc animated:YES completion:^{
            NSLog(@"in--RPFRedpacketDetailVC");
            
        }];
        [self dismissViewControllerAnimated:NO completion:^{
            
        }];
    }else if(messageType == SecretLetterType_RedOverdue){
        //红包过期 直接跳转到红包明细
        RPFRedpacketDetailVC * vc = [[RPFRedpacketDetailVC alloc] init];
        //vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        
        vc.thirdToken = self.thirdToken;
        vc.userId = self.userId;
        vc.redpacketId = self.redpacketId;
        vc.appkey = self.appkey;
        vc.groupId = self.groupId;
        vc.redDetailDict = chatModel;
        vc.isOverDue = YES;
        if (@available(iOS 13.0, *)) {
            UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
            NSArray *viewcontrollers=currentVC.navigationController.viewControllers;
            if (viewcontrollers.count > 1) {
                NSLog(@"");
            } else {
                    //present方式
                    vc.modalPresentationStyle = UIModalPresentationFullScreen;  // 修改默认值
            }
        }
        [self presentViewController:vc animated:YES completion:^{
            NSLog(@"in--RPFRedpacketDetailVC");
            
        }];
        
        [self dismissViewControllerAnimated:NO completion:^{
            
        }];
        
    }
    
    
        
}

//红包抢完了
-(void)refreshData{
    
    self.headImgView.hidden = YES;
    self.nameBtn.hidden = YES;
    self.wishContentLabel.text = @"来晚一步，已被领完～";
    self.openBtn.hidden = YES;
    self.nameBtnNone.hidden = NO;
    [self.nameBtnNone setTitle:[NSString stringWithFormat:@"%@的红包",self.userName] forState:(UIControlStateNormal)];
    self.faleyigehongbaoLabel.hidden = YES;
    
    self.checkResultBtn.hidden = NO;
    
}

-(void)buildView
{
    [self.view setHidden:NO];
    
    [self.bgImgView setImage:[BaseRPFViewController findImgFromBundle:@"JResource" andImgName:@"pck_openBG"]];
    [self.bgImgView.layer setCornerRadius:5.0];
    [self.bgImgView.layer setMasksToBounds:YES];
    
    
    [self.openBtn setBackgroundImage:[BaseRPFViewController findImgFromBundle:@"JResource" andImgName:@"pck_openBtn"] forState:UIControlStateNormal];
    
    //[self.openBtn setImage:[BaseRPFViewController findImgFromBundle:@"JResource" andImgName:@"pck_openBtn"] forState:UIControlStateNormal];
    
    self.openBtn.backgroundColor = [UIColor clearColor];
    
    [self.closeBtn setImage:[BaseRPFViewController findImgFromBundle:@"JResource" andImgName:@"pck_openExit"] forState:UIControlStateNormal];
    
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    
    if(self.userHeadUrl==nil)
        self.userHeadUrl = @"";
    [self.headImgView sd_setImageWithURL:[[NSURL alloc] initWithString:self.userHeadUrl] placeholderImage:[BaseRPFViewController findImgFromBundle:@"JResource" andImgName:@"avatar_user"]];
    
    [self.nameBtn setTitle:self.userName forState:UIControlStateNormal];
    //[self.nameBtn setImage:[BaseRPFViewController findImgFromBundle:@"JResource" andImgName:@"ic_pin"] forState:UIControlStateNormal];
    [self.nameBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -self.nameBtn.imageView.bounds.size.width, 0, self.nameBtn.imageView.bounds.size.width)];
    [self.nameBtn setImageEdgeInsets:UIEdgeInsetsMake(0, self.nameBtn.titleLabel.bounds.size.width, 0, -self.nameBtn.titleLabel.bounds.size.width)];
    self.wishContentLabel.text = self.wishContent;
    
    //查看红包详情
    self.checkResultBtn.hidden = YES;
    
}

- (IBAction)closeBtnClick:(id)sender {
    if (self.isGroup) {
        [NFUserEntity shareInstance].currentChatId = self.groupId;
        [NFUserEntity shareInstance].isSingleChat = @"2";
    }else{
        [NFUserEntity shareInstance].currentChatId = self.sendUserId;
        [NFUserEntity shareInstance].isSingleChat = @"1";
    }
    
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)openBtnClick:(id)sender {
    
    [SVProgressHUD show];
    
    //拆红包
    if(self.isGroup && self.groupId && self.groupId.length > 0){
        [socketRequest pickRedPacket:@{@"groupId":self.groupId,@"redpacketId":self.redpacketId}];
    }else{
        [socketRequest pickRedPacket:@{@"redpacketId":self.redpacketId}];
    }
    
    
    return;
    
    __weak typeof(self) weakSelf = self;
    
    NSString * urlStr = [NSString stringWithFormat:@"%@/chatapi/getRedPacket",BASE_URL];
    
    NSDictionary * dic = @{@"userId":self.userId,@"thirdToken":self.thirdToken,@"bundleId":[[NSBundle mainBundle]bundleIdentifier],@"appId":self.appkey,@"userName":self.userName,@"userHeadUrl":self.userHeadUrl,@"isGroup":self.isGroup?@"1":@"0",@"redpacketId":self.redpacketId};
    
    NSLog(@"grab--redpacket--dic= %@",dic);
    /*
     userId    是    string    无
     thirdToken    是    string    无
     bundleId    是    string    无
     appId    是    string    无
     userName    是    string    无
     userHeadUrl    是    string    无
     isGroup    是    int    无
     redpacketId    是    string    无
     */
    
    [[MKNetworkManager sharedInstance] requestNetWithParams:dic andMethod:@"POST" andURL:urlStr andCompleteBlock:^(NSDictionary *responseDict, NSError *error) {
        
        [SVProgressHUD dismiss];
        NSLog(@"grabRedpacket--responseDict= %@",responseDict);
        if (error == nil)
        {
            if([responseDict[@"errcode"] intValue]==0)
            {
                /*
                 grabId 为1时，是最后一个红包
                 */
                NSDictionary * dataDic = responseDict[@"data"];
                NSLog(@"grabRedpacket--dataDic= %@",dataDic);
                if(_openRPFinishBlock)
                {
                    BOOL isDone = [dataDic[@"grabId"] intValue]==1?YES:NO;
                    _openRPFinishBlock(isDone);
                }
                
                //跳转到红包详情
                RPFRedpacketDetailVC * vc = [[RPFRedpacketDetailVC alloc] init];
                //vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                
                vc.thirdToken = self.thirdToken;
                vc.userId = self.userId;
                vc.redpacketId = self.redpacketId;
                vc.appkey = self.appkey;
                vc.groupId = self.groupId;
                if (@available(iOS 13.0, *)) {
                    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                    UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
                    NSArray *viewcontrollers=currentVC.navigationController.viewControllers;
                    if (viewcontrollers.count > 1) {
                        NSLog(@"");
                    } else {
                            //present方式
                            vc.modalPresentationStyle = UIModalPresentationFullScreen;  // 修改默认值
                    }
                }
                [self presentViewController:vc animated:YES completion:^{
                    NSLog(@"openBtnClick--in--RPFRedpacketDetailVC");
                    
                }];
                [self dismissViewControllerAnimated:NO completion:^{
                    
                }];
                
            }
            else
            {
                NSString *toast = [NSString stringWithFormat:@"%@",responseDict[@"msg"]];
                //[self.view makeToast:toast duration:2.0 position:CSToastPositionCenter];
                [SVProgressHUD showInfoWithStatus:toast];
                [self dismissViewControllerAnimated:YES completion:^{
                    
                }];
            }
        }
        else
        {
            NSString *toast = [NSString stringWithFormat:@"%@",responseDict[@"msg"]];
            //[self.view makeToast:toast duration:2.0 position:CSToastPositionCenter];
            [SVProgressHUD showInfoWithStatus:toast];
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
        
        
        
    }];
    
}

- (IBAction)checkResultBtnClick:(id)sender {
    
    RPFRedpacketDetailVC * vc = [[RPFRedpacketDetailVC alloc] init];
    //vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    vc.thirdToken = self.thirdToken;
    vc.userId = self.userId;
    vc.redpacketId = self.redpacketId;
    vc.appkey = self.appkey;
    vc.groupId = self.groupId;
    if (@available(iOS 13.0, *)) {
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
        NSArray *viewcontrollers=currentVC.navigationController.viewControllers;
        if (viewcontrollers.count > 1) {
            NSLog(@"");
        } else {
                //present方式
                vc.modalPresentationStyle = UIModalPresentationFullScreen;  // 修改默认值
        }
    }
    [self presentViewController:vc animated:YES completion:^{
        NSLog(@"in--RPFRedpacketDetailVC");
        
    }];
    
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
    
}



- (void)checkResult {
    
    
    
    
    return;
    
    
    [SVProgressHUD show];
    
    __weak typeof(self) weakSelf = self;
    
    NSString * urlStr = [NSString stringWithFormat:@"%@/chatapi/getRedPacketInfo",BASE_URL];
    
    NSDictionary * dic = @{@"userId":self.userId?self.userId:@"1",@"thirdToken":self.thirdToken?self.thirdToken:@"1",@"bundleId":[[NSBundle mainBundle]bundleIdentifier],@"appId":self.appkey?self.appkey:@"1",@"redpacketId":self.redpacketId?self.redpacketId:@"1"};
    
    NSLog(@"checkResult--redpacket--dic= %@",dic);
    /*
     userId    是    string    无
     thirdToken    是    string    无
     bundleId    是    string    无
     appId    是    string    无
     redpacketId    是    string    无
     */
    
    [[MKNetworkManager sharedInstance] requestNetWithParams:dic andMethod:@"POST" andURL:urlStr andCompleteBlock:^(NSDictionary *responseDict, NSError *error) {
        
        NSLog(@"openVC--checkResult--responseDict= %@",responseDict);
        if (error == nil)
        {
            if([responseDict[@"errcode"] intValue]==1)//我还没抢红包
            {
                [SVProgressHUD dismiss];
                
                [self buildView];
            }
            else if([responseDict[@"errcode"] intValue] == 10002)//红包过期
            {
                [SVProgressHUD dismiss];
                
                NSString *toast = [NSString stringWithFormat:@"%@",responseDict[@"msg"]];
                
                //[self.view makeToast:toast duration:2.0 position:CSToastPositionCenter];
                
                [SVProgressHUD showInfoWithStatus:toast];
                [self dismissViewControllerAnimated:NO completion:^{
                    
                }];
            }
            else if([responseDict[@"errcode"] intValue] == 0)
            {
                NSString *toast = [NSString stringWithFormat:@"%@",responseDict[@"msg"]];
                //[self.view makeToast:toast duration:2.0 position:CSToastPositionCenter];
                //直接跳转到红包详情页面
                RPFRedpacketDetailVC * vc = [[RPFRedpacketDetailVC alloc] init];
                //vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                
                vc.thirdToken = self.thirdToken;
                vc.userId = self.userId;
                vc.redpacketId = self.redpacketId;
                vc.appkey = self.appkey;
                vc.groupId = self.groupId;
                if (@available(iOS 13.0, *)) {
                    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                    UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
                    NSArray *viewcontrollers=currentVC.navigationController.viewControllers;
                    if (viewcontrollers.count > 1) {
                        NSLog(@"");
                    } else {
                            //present方式
                            vc.modalPresentationStyle = UIModalPresentationFullScreen;  // 修改默认值
                    }
                }
                [self presentViewController:vc animated:YES completion:^{
                    NSLog(@"in--RPFRedpacketDetailVC");
                    
                }];
                [self dismissViewControllerAnimated:NO completion:^{
                    
                }];
                
            }
            else
            {
                NSString *toast = [NSString stringWithFormat:@"%@",responseDict[@"msg"]];
                //[self.view makeToast:toast duration:2.0 position:CSToastPositionCenter];
                [SVProgressHUD showInfoWithStatus:toast];
                
                [self dismissViewControllerAnimated:YES completion:^{
                    
                }];
            }
        }
        else
        {
            NSString *toast = [NSString stringWithFormat:@"%@",responseDict[@"msg"]];
            //[self.view makeToast:toast duration:2.0 position:CSToastPositionCenter];
            [SVProgressHUD showInfoWithStatus:toast];
            
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
        
        
        
        
    }];
    
}


@end
