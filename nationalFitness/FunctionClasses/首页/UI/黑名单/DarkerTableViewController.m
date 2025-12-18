//
//  DarkerTableViewController.m
//  nationalFitness
//
//  Created by joe on 2020/4/16.
//  Copyright © 2020 chenglong. All rights reserved.
//

#import "DarkerTableViewController.h"
#import "JQFMDB.h"

@interface DarkerTableViewController ()<ChatHandlerDelegate>





@end

@implementation DarkerTableViewController{
    
    
    SocketModel * socketModel;
    SocketRequest *socketRequest;
    
    JQFMDB *jqFmdb;
    
    
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
    
    self.title = @"黑名单";
    
    self.tableView.tableFooterView = [UIView new];
    
    

    [self initScoket];
    
    
    
}

//socket初始化
-(void)initScoket{
    socketRequest = [SocketRequest share];
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    
    if (socketModel.isConnected) {
        [socketModel ping];
    }
    
    if (socketModel.isConnected) {
        if (socketModel.isConnected) {
            [socketRequest getBlackList];
        }
    }else{
        
    }
}




#pragma mark - 收到服务器消息
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    if (messageType == SecretLetterType_friendBlackList){
        if([chatModel isKindOfClass:[NSArray class]]){
            NSArray *friendArr = chatModel;
            self.dataArr = [NSMutableArray arrayWithArray:friendArr];
            
            [self.tableView reloadData];
            
        }
        
    }else if (messageType == SecretLetterType_CancelPullBlackSuccess){

        [self initScoket];
        
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 20.f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 20)];
    [headerView setBackgroundColor:UIColorFromRGB(0xF2F2F7)];
    return headerView;
}

//返回分区行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count ;
    
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   static NSString* cellIdentifier = @"ContantTableViewCell";
    ContantTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"ContantTableViewCell" owner:nil options:nil]firstObject];
    }
    ZJContact *contact = self.dataArr[indexPath.row];
    if (contact.friend_nickname.length > 0) {
        cell.nameLabel.text = contact.friend_nickname;
    }else{
        cell.nameLabel.text = contact.friend_username;
    }
    if ([cell.headImageView isKindOfClass:[UIImageView class]]) {
        [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:contact.iconUrl] placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
    }else{
        [cell.headImageView ShowImageWithUrlStr:contact.iconUrl placeHoldName:defaultHeadImaghe completion:^(BOOL success, UIImage *image) {
        }];
    }
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"解除";
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle ==UITableViewCellEditingStyleDelete)
    {

        ZJContact *contact = self.dataArr[indexPath.row];
        [socketRequest pullBlackType:NO FriendId:contact.friend_userid];
        
//        [self.dataArr removeObjectAtIndex:indexPath.row]; 8
//        [self.tableView reloadData];
        
//        ZJContact *contact = self.dataArr[indexPath.row];
//        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
//        __block NSArray *contactArr = [NSArray new];
//        __weak typeof(self)weakSelf=self;
//        [jqFmdb jq_inDatabase:^{
//            __strong typeof(weakSelf)strongSelf=weakSelf;
//            contactArr = [strongSelf ->jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact new] whereFormat:@" where friend_userid = '%@'",contact.friend_userid];
//        }];
//
//        if (contactArr.count == 1) {
//            ZJContact *contact = [contactArr firstObject];
//            contact.IsShield = NO;
//            __block BOOL ret;
//            __weak typeof(self)weakSelf=self;
//            [jqFmdb jq_inDatabase:^{
//                __strong typeof(weakSelf)strongSelf=weakSelf;
//                ret = [strongSelf ->jqFmdb jq_updateTable:@"lianxirenliebiao" dicOrModel:contact whereFormat:@" where friend_userid = '%@'",contact.friend_userid];
//                if (ret) {
//                }
//            }];
//        }
    }
}

//懒加载
-(NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [[NSMutableArray alloc] init];
    }
    return _dataArr;
}





@end
