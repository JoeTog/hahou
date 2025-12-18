//
//  RPFSendCardVC.m
//  NIM
//
//  Created by King on 2019/3/6.
//  Copyright © 2019年 Netease. All rights reserved.
//

#import "RPFSendCardVC.h"
//#import "NTESSessionUtil.h"
//#import "NTESSessionViewController.h"
//#import "NTESContactUtilItem.h"
//#import "NTESContactDefines.h"
//#import "NTESGroupedContacts.h"
//#import "UIView+Toast.h"
//#import "NTESCustomNotificationDB.h"
//#import "NTESNotificationCenter.h"
//#import "UIActionSheet+NTESBlock.h"
//#import "NTESSearchTeamViewController.h"
//#import "NTESContactAddFriendViewController.h"
//#import "NTESPersonalCardViewController.h"
//#import "UIAlertView+NTESBlock.h"
//#import "SVProgressHUD.h"
//#import "NTESContactUtilCell.h"
//#import "NTESContactDataCell.h"
//#import "NIMContactSelectViewController.h"
//#import "NTESUserUtil.h"
//#import "RPFTool.h"
//#import "NTESContactDataMember.h"


@interface RPFSendCardVC ()

@end

@implementation RPFSendCardVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    id<NTESContactItem> contactItem = (id<NTESContactItem>)[self.contacts memberOfIndex:indexPath];
//    if ([contactItem respondsToSelector:@selector(selName)] && [contactItem selName].length) {
//        SEL sel = NSSelectorFromString([contactItem selName]);
//        SuppressPerformSelectorLeakWarning([self performSelector:sel withObject:nil]);
//    }
//    else if (contactItem.vcName.length) {
//        Class clazz = NSClassFromString(contactItem.vcName);
//        UIViewController * vc = [[clazz alloc] initWithNibName:nil bundle:nil];
//        [self.navigationController pushViewController:vc animated:YES];
//    }else if([contactItem respondsToSelector:@selector(userId)]){
//        NSString * friendId   = contactItem.userId;
//        
//        //发送名片
////        if(_sendcardBlock)
////        {
////            _sendcardBlock(friendId,NO);
////        }
//        if(_delegate)
//        {
//            [_delegate gainCardInfo:friendId isGroup:NO];
//        }
//        
//        [self.navigationController popViewControllerAnimated:YES];
//
//        //[self enterPersonalCard:friendId];
//    }
    
}


@end
