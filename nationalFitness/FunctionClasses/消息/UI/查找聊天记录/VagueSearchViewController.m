
//
//  VagueSearchViewController.m
//  nationalFitness
//
//  Created by joe on 2018/2/3.
//  Copyright © 2018年 chenglong. All rights reserved.
//

#import "VagueSearchViewController.h"

#import "JQFMDB.h"


@interface VagueSearchViewController ()<UISearchControllerDelegate,UISearchBarDelegate>
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UISearchController *searchController;

@property(nonatomic,strong)NSMutableArray *dataArr;


@end

static CGFloat const kSearchBarHeight = 50.f;

@implementation VagueSearchViewController{
    
    
    __weak IBOutlet NFBaseTableView *VagueSearchTableV;
    
    JQFMDB *jqFmdb;
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    self.navigationController.navigationBar.hidden = NO;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = SecondGray;
    VagueSearchTableV.tableFooterView = [UIView new];
    VagueSearchTableV.tableHeaderView = self.searchBar;
    [self.searchBar becomeFirstResponder];
    [self initSearchBar];
    VagueSearchTableV.isNeed = YES;//
}



#pragma mark - searchBar Delegate
- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [self.view endEditing:YES];
        UIButton *cancelBtn = [searchBar valueForKey:@"cancelButton"]; //首先取出cancelBtn
        cancelBtn.enabled = YES;
        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
        if ([self.fromType isEqualToString:@"1"]) {
            //NSArray *keys = [jqFmdb jq_columnNameArray:self.conversationId];
            //NSArray *arr = [jqFmdb jq_lookupTable:self.conversationId dicOrModel:[MessageChatEntity class] whereFormat:@""];
            NSLog(@"%@",searchBar.text);
            __block NSArray *searchArr = [NSArray new];
            [jqFmdb jq_inDatabase:^{
                searchArr = [jqFmdb jq_SearchTable:self.conversationId dicOrModel:[MessageChatEntity class] Key:@"message_content" Value:searchBar.text];
            }];
            self.dataArr = (NSMutableArray *)searchArr;
        }else{
            //NSArray *keys = [jqFmdb jq_columnNameArray:groupMacroName];
            //NSArray *arr = [jqFmdb jq_lookupTable:groupMacroName dicOrModel:[MessageChatEntity class] whereFormat:@""];
            NSLog(@"%@",searchBar.text);
            __block NSArray *searchArr = [NSArray new];
            [jqFmdb jq_inDatabase:^{
                searchArr = [jqFmdb jq_SearchTable:groupMacroName dicOrModel:[MessageChatEntity class] Key:@"message_content" Value:searchBar.text];
            }];
            self.dataArr = (NSMutableArray *)searchArr;
        }
        if (self.dataArr.count > 0) {
            [VagueSearchTableV reloadData];
            [VagueSearchTableV removeNone];
        }else{
            [VagueSearchTableV reloadData];
            [VagueSearchTableV showNoneWithImage:@"空白页-14-14_03" WithTitle:@"无结果"];
        }
        return YES;
    }
    return YES;
}


-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark - tableViewDelegate & tableViewDateSource
//返回分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
//返回分区行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

//每一行高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

//返回每一行的内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* cellIdentifier = @"VagueSearchTableViewCell";
    VagueSearchTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"VagueSearchTableViewCell" owner:nil options:nil]firstObject];
    }
    MessageChatEntity *entity = self.dataArr.count>indexPath.row?self.dataArr[indexPath.row]:nil;
    cell.chatEntity = entity;
    if ([self.fromType isEqualToString:@"1"]) {
        cell.headPicPath = self.singleContactEntity.iconUrl;
    }else{
        cell.headPicPath = entity.headPicPath.length > 0?entity.headPicPath:[NFUserEntity shareInstance].mineHeadView;//群成员头像 【如果没有 则为自己发出的消息】
    }
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

//点击cell 不执行，看看是否在tableview上加了手势gesture 手势截取了点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    MessageChatEntity *entity = self.dataArr.count>indexPath.row?self.dataArr[indexPath.row]:nil;
    //根据id 从数据库查找小于等于id的count数 然后传到单聊界面 从数据库搜索出来这么多数 在界面展示
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __block int index = 0;
    __weak typeof(self)weakSelf=self;
    if ([self.fromType isEqualToString:@"1"]) {
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            index = [strongSelf ->jqFmdb jq_tableItemVagueSearchCount:self.conversationId fkid:entity.pkid];
        }];
    }else{
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            index = [strongSelf ->jqFmdb jq_tableItemVagueSearchCount:groupMacroName fkid:entity.pkid];
        }];
    }
    
    
    if ([self.fromType isEqualToString:@"1"]) {
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
        MessageChatViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"MessageChatViewController"];
        toCtrol.titleName = self.singleContactEntity.friend_nickname;
        toCtrol.conversationId = self.singleContactEntity.friend_userid;
        toCtrol.chatType = @"0";
        toCtrol.singleContactEntity = self.singleContactEntity;
        toCtrol.historyIndex = index;
        [self.navigationController pushViewController:toCtrol animated:YES];
    }else{
        GroupCreateSuccessEntity *groupDetailEntity;
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
        GroupChatViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"GroupChatViewController"];
        toCtrol.groupCreateSEntity = self.groupCreateSEntity;
        toCtrol.conversationId = self.groupCreateSEntity.groupId;
        toCtrol.historyIndex = index;
        [self.navigationController pushViewController:toCtrol animated:YES];
        
    }
}

#pragma mark - 设置searchbar相关
-(void)initSearchBar{

    id Field;
    if (@available(iOS 13.0, *)) {
        Field =self.searchBar.searchTextField;
    }else{
        Field = [self.searchBar valueForKey:@"_searchField"];
    }
    UITextField *txfSearchField;
    if (@available(iOS 13.0, *)) {
        txfSearchField = self.searchBar.searchTextField;
    }else{
        if ([Field isKindOfClass:[UITextField class]]) {
            txfSearchField = [self.searchBar valueForKey:@"_searchField"];
            //设置searchbar textfield的placehold字体颜色
            [txfSearchField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
            [txfSearchField setValue:[UIFont boldSystemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
        }
    }
    //设置searchbar textfield的placehold字体颜色
    txfSearchField.backgroundColor = [UIColor colorTextfieldBackground];
    //放大镜
    [self.searchBar setImage:[UIImage imageNamed:@"searbar搜索"]
            forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    for (id searchbuttons in [[self.searchBar subviews][0]subviews]){
        if ([searchbuttons isKindOfClass:[UIButton class]]) {
            UIButton *cancelButton = (UIButton*)searchbuttons;
            // 修改文字颜色
            [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
            [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
            [cancelButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
            [cancelButton setTitleColor:[UIColor greenColor] forState:UIControlStateHighlighted];
        }
    }
    self.searchBar.barTintColor = [UIColor colorNavigationBackground];
    UIView *view = txfSearchField.superview;
//    view.backgroundColor = [UIColor colorTextfieldBackBackground];
    view.backgroundColor = SecondGray;
    for (UIView *view in self.searchBar.subviews) {
        // for later iOS7.0(include)
        if ([view isKindOfClass:NSClassFromString(@"UIView")] && view.subviews.count > 0) {
            if (@available(iOS 13.0, *)) {
                [view.subviews objectAtIndex:0].hidden = YES;
            }else{
                [[view.subviews objectAtIndex:0] removeFromSuperview];
            }
            break;
        }
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (VagueSearchTableV.contentOffset.y > 0 && self.dataArr.count <= 5) {
        [UIView animateWithDuration:0.2 animations:^{
            VagueSearchTableV.contentOffset = CGPointMake(0, 0);
        }];
    }
}


- (UISearchBar *)searchBar {
    if (!_searchBar) {
        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.bounds.size.width, kSearchBarHeight)];
//        searchBar.backgroundColor = SecondGray;
        searchBar.delegate = self;
        searchBar.placeholder = @"搜索";
        searchBar.showsCancelButton = YES;
        
        _searchBar = searchBar;
    }
    return _searchBar;
}

#pragma mark - 懒加载相关
-(NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [[NSMutableArray alloc] init];
    }
    return _dataArr;
}

//懒加载 fmdbServicee
-(FMDBService *)fmdbServicee{
    if (!_fmdbServicee) {
        _fmdbServicee = [[FMDBService alloc] init];
    }
    return _fmdbServicee;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
