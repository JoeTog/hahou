//
//  GroupDetailHeadTableViewCell.m
//  nationalFitness
//
//  Created by Joe on 2017/7/13.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "GroupDetailHeadTableViewCell.h"

@implementation GroupDetailHeadTableViewCell{
    
    __weak IBOutlet UICollectionView *GroupChatDetailTableV;
    
    
    
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    GroupChatDetailTableV.scrollEnabled = NO;
    UINib * nib = [UINib nibWithNibName:@"GroupMemberCollectionViewCell" bundle:[NSBundle mainBundle]];
    [GroupChatDetailTableV registerNib:nib forCellWithReuseIdentifier:@"GroupMemberCollectionViewCell"];
    
    UINib * nibb = [UINib nibWithNibName:@"GroupEditCollectionViewCell" bundle:[NSBundle mainBundle]];
    [GroupChatDetailTableV registerNib:nibb forCellWithReuseIdentifier:@"GroupEditCollectionViewCell"];
    
    GroupChatDetailTableV.backgroundColor = [UIColor clearColor];
    
}

-(void)returnMemberGroupClick:(memberGroupClick)block{
    if (self.groupClick != block) {
        self.groupClick = block;
    }
}

#pragma mark - collectionview
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
//    if (SCREEN_WIDTH == 320) {
//        if (self.memberArr.count >= 3) {
//            return 4;
//        }
//    }else if (SCREEN_WIDTH == 375){
//        if (self.memberArr.count >= 4) {
//            return 5;
//        }
//    }else if (SCREEN_WIDTH >= 400){
//        if (self.memberArr.count >= 5) {
//            return 6;
//        }
//    }
    NSInteger a = 0;
    if ([self.groupCreateSEntity.is_creator isEqualToString:@"1"] || [self.groupCreateSEntity.is_admin                                                                             isEqualToString:@"1"]) {
        a = self.memberArr.count+2;
    }else{
        a = self.memberArr.count+1;
    }
    return a;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"indexPath = %ld",indexPath.item);
    if (indexPath.item < self.memberArr.count) {
        GroupMemberCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GroupMemberCollectionViewCell" forIndexPath:indexPath];
//        [cell.headImageV ShowHeadImageWithUrlStr:@"" withUerId:@"" completion:^(BOOL success, UIImage *image) {
//        }];
        ZJContact *contact = self.memberArr[indexPath.item];
//        if ([contact.iconUrl containsString:@"head_man"]) {
//            cell.headImageV.image = [UIImage imageNamed:contact.iconUrl];
//        }else{
            [cell.headImageV sd_setImageWithURL:[NSURL URLWithString:contact.iconUrl] placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
//        }
        ViewRadius(cell.headImageV, 3);
        cell.headImageV.userInteractionEnabled= NO;
        cell.nickNamelabel.text = contact.in_group_name;
        cell.badgeimageV.hidden = YES;
        if ([contact.is_creator isEqualToString:@"1"]) {
            cell.badgeimageV.hidden = NO;
            cell.badgeimageV.image = [UIImage imageNamed:@"qunzhuBage"];
        }else if([contact.is_admin isEqualToString:@"1"]){
            cell.badgeimageV.hidden = NO;
        }
        return cell;
    }
    GroupEditCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GroupEditCollectionViewCell" forIndexPath:indexPath];
    cell.addOrReduceBtn.userInteractionEnabled = NO;
    if (indexPath.item == self.memberArr.count) {
        //add 拉人
        [cell.addOrReduceBtn setBackgroundImage:[UIImage imageNamed:@"group_participant_addHL"] forState:(UIControlStateNormal)];
    }else if (indexPath.item == self.memberArr.count + 1){
        //reduce 踢人
        [cell.addOrReduceBtn setBackgroundImage:[UIImage imageNamed:@"group_participant_Reduce"] forState:(UIControlStateNormal)];
    }
//    CGRect cellRect = [GroupChatDetailTableV convertRect:cell.frame toView:GroupChatDetailTableV];
//    NSLog(@"987654321- %f - %f # %f - %f",cellRect.origin.x,cellRect.origin.y,cellRect.size.width,cellRect.size.height);
//    CGRect rect2 = [GroupChatDetailTableV convertRect:cellRect toView:self];
//    NSLog(@"987654321- %f - %f # %f - %f",rect2.origin.x,rect2.origin.y,rect2.size.width,rect2.size.height);
    return cell;
    
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(8, 8, 8, 8);
}

//列之间最小间距
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 7;
}

//行之间最小间距
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 8;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(50, 70);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.item != self.memberArr.count && indexPath.item != self.memberArr.count+1) {
        //将点击事件传出去
//        ZJContact *contact = self.memberArr[indexPath.row];
//        if ([contact.friend_username isEqualToString:[NFUserEntity shareInstance].userName]) {
//
//        }
        ZJContact *contactTTT = self.memberArr[indexPath.item];
        if ([self.groupCreateSEntity.is_creator isEqualToString:@"1"]) {
            if ([contactTTT.is_creator isEqualToString:@"1"]) {
                self.groupClick(indexPath);
            }else if ([contactTTT.is_admin isEqualToString:@"1"]){
                LWWeChatActionSheet *sheet = [[LWWeChatActionSheet alloc] initWithWeChatActionSheetCancelButtonTitle:@"取消" title:nil otherButtonTitles:[NSArray arrayWithObjects:@"查看资料",@"转让群主",@"取消管理员",@"加好友", nil] btnClickBlock:^(NSInteger buttonIndex) {
                    if (buttonIndex == 999) {
                        return ;
                    }else if(buttonIndex == 0){
                        self.groupClick(indexPath);
                    }else if(buttonIndex == 1){
                        //转让群主

                        //转让群主
                        //groupZhuanrang
                        SocketRequest *socketRequest = [SocketRequest share];
                        [socketRequest groupZhuanrang:contactTTT.friend_userid groupId:self.groupCreateSEntity.groupId];
//                        MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"您确定转让群主么？" sureBtn:@"确认" cancleBtn:@"取消"];
//                        alertView.resultIndex = ^(NSInteger index)
//                        {
//                            if(index == 2){
//
//                                //转让群主
//                                //groupZhuanrang
//                                SocketRequest *socketRequest = [SocketRequest share];
//                                [socketRequest groupZhuanrang:contactTTT.friend_userid groupId:self.groupCreateSEntity.groupId];
//                            }
//                        };
//                        [alertView showMKPAlertView];
                        
                    }else if(buttonIndex == 2){
                        SocketRequest *socketRequest = [SocketRequest share];
                        [socketRequest manageGroup:NO GroupId:self.groupCreateSEntity.groupId AndContact:contactTTT];
                        contactTTT.is_admin = @"0";
                        [GroupChatDetailTableV reloadItemsAtIndexPaths:@[indexPath]];
                    }else if (buttonIndex == 3){
                        //加好友
                        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"ContantStoryboard" bundle:nil];
                        AddFriendOrGroupdetailViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"AddFriendOrGroupdetailViewController"];
                        toCtrol.addFriendId = contactTTT.friend_userid;
                        toCtrol.addFriendName = contactTTT.friend_username;
                        toCtrol.headPicpath = contactTTT.iconUrl;
                        [[KeepAppBox viewController:self].navigationController pushViewController:toCtrol animated:YES];
                    }
                }];
                [sheet show];
            }else{
                LWWeChatActionSheet *sheet = [[LWWeChatActionSheet alloc] initWithWeChatActionSheetCancelButtonTitle:@"取消" title:nil otherButtonTitles:[NSArray arrayWithObjects:@"查看资料",@"转让群主",@"设置管理员",@"加好友", nil] btnClickBlock:^(NSInteger buttonIndex) {
                    if (buttonIndex == 999) {
                        return ;
                    }else if(buttonIndex == 0){
                        self.groupClick(indexPath);
                    }else if(buttonIndex == 1){

                        //转让群主
                        //groupZhuanrang
                        SocketRequest *socketRequest = [SocketRequest share];
                        [socketRequest groupZhuanrang:contactTTT.friend_userid groupId:self.groupCreateSEntity.groupId];
//                        MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"您确定转让群主么？" sureBtn:@"确认" cancleBtn:@"取消"];
//                        alertView.resultIndex = ^(NSInteger index)
//                        {
//                            if(index == 2){
//
//                                //转让群主
//                                //groupZhuanrang
//                                SocketRequest *socketRequest = [SocketRequest share];
//                                [socketRequest groupZhuanrang:contactTTT.friend_userid groupId:self.groupCreateSEntity.groupId];
//                            }
//                        };
//                        [alertView showMKPAlertView];
                        
                        
                        
                    }else if(buttonIndex == 2){
                        SocketRequest *socketRequest = [SocketRequest share];
                        [socketRequest manageGroup:YES GroupId:self.groupCreateSEntity.groupId AndContact:contactTTT];
                        contactTTT.is_admin = @"1";
                        [GroupChatDetailTableV reloadItemsAtIndexPaths:@[indexPath]];
                    }else if (buttonIndex == 3){
                        //加好友
                        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"ContantStoryboard" bundle:nil];
                        AddFriendOrGroupdetailViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"AddFriendOrGroupdetailViewController"];
                        toCtrol.addFriendId = contactTTT.friend_userid;
                        toCtrol.addFriendName = contactTTT.friend_username;
                        toCtrol.headPicpath = contactTTT.iconUrl;
                        [[KeepAppBox viewController:self].navigationController pushViewController:toCtrol animated:YES];
                    }
                }];
                [sheet show];
            }
            //
        }else if ([self.groupCreateSEntity.is_admin isEqualToString:@"1"] || [self.groupCreateSEntity.groupSecret isEqualToString:@"0"] || [contactTTT.is_admin isEqualToString:@"1"]){
            LWWeChatActionSheet *sheet = [[LWWeChatActionSheet alloc] initWithWeChatActionSheetCancelButtonTitle:@"取消" title:nil otherButtonTitles:[NSArray arrayWithObjects:@"查看资料",@"加好友", nil] btnClickBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 999) {
                    return ;
                }else if(buttonIndex == 0){
                    self.groupClick(indexPath);
                }else if(buttonIndex == 1){
                    //加好友
                    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"ContantStoryboard" bundle:nil];
                    AddFriendOrGroupdetailViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"AddFriendOrGroupdetailViewController"];
                    toCtrol.addFriendId = contactTTT.friend_userid;
                    toCtrol.addFriendName = contactTTT.friend_username;
                    toCtrol.headPicpath = contactTTT.iconUrl;
                    [[KeepAppBox viewController:self].navigationController pushViewController:toCtrol animated:YES];
                }
            }];
            [sheet show];
        }
        else{
            
            LWWeChatActionSheet *sheet = [[LWWeChatActionSheet alloc] initWithWeChatActionSheetCancelButtonTitle:@"取消" title:nil otherButtonTitles:[NSArray arrayWithObjects:@"查看资料", nil] btnClickBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 999) {
                    return ;
                }else if(buttonIndex == 0){
                    self.groupClick(indexPath);
                }
                
            }];
            [sheet show];
        }
        
        
    }
    if (indexPath.item == self.memberArr.count) {
        if( self.memberArr.count -1 >= 1500){
            [SVProgressHUD showInfoWithStatus:@"群人数最多1500人"];
            return;
        }
        
        self.addClickMember();
        
    }else if(indexPath.item == self.memberArr.count + 1){
        //reduce
        if( self.memberArr.count  <= 2){
            [SVProgressHUD showInfoWithStatus:@"群人数最少2人"];
            return;
        }
        //删除群成员
        self.reduceClickMember();
        
        
    }
}

+(CGFloat)heightForCellWithData:(NSArray *)data IsCreator:(BOOL)ret{
    //一行几个
    //8*2因为左右都间隔8.
    NSLog(@"\n%f\n%f\n",(SCREEN_WIDTH - 15 * 2),(50 + 8*2));
    NSInteger count = (SCREEN_WIDTH - 15 * 2)/(50 + 5*2);
    //计算共多少行 (data.count + 1)因为多一个加号按钮 所以要加一
    int a = 0;
    if (ret) {
        a = 2;
    }else{
        a = 1;
    }
    NSInteger RowNumber = (data.count + a)/count;
    //当除以最大容纳数 有余数 则加一行的高度
    if ((data.count + a)%count > 0) {
        RowNumber++;
    }
    return (70 + 8)*RowNumber;
}

#pragma mark - 删除成员成功 传出代码块
-(void)reduceMemberSuccess:(ReduceMemberSuccessCell )reducemember{
    if (self.redeceMember != reducemember) {
        self.redeceMember = reducemember;
    }
}


-(void)ReturnClickAddMemberBlock:(ReturnClickAddMemberBlock )addClickMember{
    if (self.addClickMember != addClickMember) {
        self.addClickMember = addClickMember;
    }
}

-(void)ReturnClickReduceMemberBlock:(ReturnClickReduceMemberBlock )reduceClickMember{
if (self.reduceClickMember != reduceClickMember) {
        self.reduceClickMember = reduceClickMember;
    }
}




- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}




@end
