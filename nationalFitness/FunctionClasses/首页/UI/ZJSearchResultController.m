//
//  ZJSearchResultController.m
//  ZJIndexContacts
//
//  Created by ZeroJ on 16/10/11.
//  Copyright © 2016年 ZeroJ. All rights reserved.
//

#import "ZJSearchResultController.h"

@interface ZJSearchResultController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;

@end

@implementation ZJSearchResultController

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.translucent = YES;
    
    //self.tableView.backgroundView=[[NFbaseViewController new] setThemeBackgroundImage];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    
    
}

-(void)SelectContantJumpBlock:(SelectContantJump)block{
    if (self.ContantJumpBlock != block) {
        self.ContantJumpBlock = block;
    }
    
}

- (void)dealloc {
    NSLog(@"ZJSearchResultController ---- dealloc");
}

//cell设置成透明
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor whiteColor];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 60;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const kCellId = @"kCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellId];
    }
    if (((ZJContact *)_data[indexPath.row]).friend_nickname.length > 0) {
        cell.textLabel.text = ((ZJContact *)_data[indexPath.row]).friend_nickname;
    }else{
        cell.textLabel.text = ((ZJContact *)_data[indexPath.row]).friend_username;
    }
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:((ZJContact *)_data[indexPath.row]).iconUrl] placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
    CGSize itemSize = CGSizeMake(40, 40);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    cell.textLabel.textColor = MainTextColor;
    return cell;
}

//选择联系人跳转
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
//    MessageChatViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"MessageChatViewController"];
//    ZJContactViewController *ZJVC = (ZJContactViewController *)[self getCurrentVC];
//    [ZJVC.navigationController pushViewController:toCtrol animated:YES];
    //选中联系人 代码块跳转
    ZJContact *contant = self.data[indexPath.row];
    self.ContantJumpBlock(contant);
    
}


//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

- (void)setData:(NSArray<ZJContact *> *)data {
    _data = data;
    [self.tableView reloadData];
}

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.tableFooterView = [UIView new];
        // 行高度
        tableView.rowHeight = 50.f;
        _tableView = tableView;
    }
    return _tableView;
}








@end
