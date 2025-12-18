//
//  PassWordChangeTableViewController.m
//  nationalFitness
//
//  Created by Joe on 2017/7/14.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "PassWordChangeTableViewController.h"

@interface PassWordChangeTableViewController ()<UITextFieldDelegate>

@end

@implementation PassWordChangeTableViewController{
    
    //旧密码
    __weak IBOutlet UITextField *OldPassWordTextF;
    
    //新密码
    __weak IBOutlet UITextField *firstNewTextF;
    
    //再次新密码
    __weak IBOutlet UITextField *secNewTextFG;
    
    __weak IBOutlet UIButton *commitBtn;
    
    
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    //self.tableView.backgroundView=[[NFbaseViewController new] setThemeBackgroundImage];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"修改密码";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self initUI];
    [self initColor];
    
}

-(void)initUI{
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 34)];
    [backBtn setImage:[UIImage imageNamed:@"everyday1_return"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    self.tableView.tableFooterView = [UIView new];
    
//    ViewBorderRadius(commitBtn, 3, 1, [UIColor blueColor]);
    ViewRadius(commitBtn, 3);
    
    OldPassWordTextF.textColor = [UIColor whiteColor];
    firstNewTextF.textColor = [UIColor whiteColor];
    secNewTextFG.textColor = [UIColor whiteColor];
    
    [OldPassWordTextF setValue:UIColorFromRGB(0xd2d2d2) forKeyPath:@"_placeholderLabel.textColor"];
    [firstNewTextF setValue:UIColorFromRGB(0xd2d2d2) forKeyPath:@"_placeholderLabel.textColor"];
    [secNewTextFG setValue:UIColorFromRGB(0xd2d2d2) forKeyPath:@"_placeholderLabel.textColor"];
    
    [commitBtn setTitleColor:[UIColor colorThemeTintColor] forState:(UIControlStateNormal)];
    [commitBtn setBackgroundColor:[UIColor colorSectionHeader]];
}

- (void)backClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 当编辑的时候
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField.tag == 1) {
        if (firstNewTextF.text.length && secNewTextFG.text.length && textField.text.length + string.length - range.length >0) {
            [commitBtn setTitleColor:[UIColor colorThemeTintColor] forState:(UIControlStateNormal)];
            [commitBtn setBackgroundColor:[UIColor colorThemeColor]];
            return YES;
        }
    }else if (textField.tag == 2){
        if (OldPassWordTextF.text.length && secNewTextFG.text.length && textField.text.length + string.length - range.length >0) {
            [commitBtn setTitleColor:[UIColor colorThemeTintColor] forState:(UIControlStateNormal)];
            [commitBtn setBackgroundColor:[UIColor colorThemeColor]];
            return YES;
        }
    }else if (textField.tag == 3){
        if (OldPassWordTextF.text.length && firstNewTextF.text.length && textField.text.length + string.length - range.length >0) {
            [commitBtn setTitleColor:[UIColor colorThemeTintColor] forState:(UIControlStateNormal)];
            [commitBtn setBackgroundColor:[UIColor colorThemeColor]];
            return YES;
        }
    }
    [commitBtn setTitleColor:[UIColor colorThemeTintColor] forState:(UIControlStateNormal)];
    [commitBtn setBackgroundColor:[UIColor colorSectionHeader]];
    return YES;
}

//-(void)textFieldDidEndEditing:(UITextField *)textField{
//    if (OldPassWordTextF.text.length > 0 && firstNewTextF.text.length && secNewTextFG.text.length) {
//        [commitBtn setTitleColor:[UIColor colorThemeTintColor] forState:(UIControlStateNormal)];
//        [commitBtn setBackgroundColor:[UIColor colorThemeColor]];
//    }else{
//        [commitBtn setTitleColor:[UIColor colorThemeTintColor] forState:(UIControlStateNormal)];
//        [commitBtn setBackgroundColor:[UIColor colorSectionHeader]];
//    }
//}


#pragma mark - 确定按钮
- (IBAction)commitBtnClick:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
    
}

//头高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}
//设置headview 颜色
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];
    //    [headerView setBackgroundColor:UIColorFromRGB(0xebebf1)];
    [headerView setBackgroundColor:[UIColor colorSectionHeader]];
    return headerView;
}

//cell设置成透明
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor whiteColor];
}

-(void)initColor{
    OldPassWordTextF.textColor = [UIColor colorMainTextColor];
    firstNewTextF.textColor = [UIColor colorMainTextColor];
    secNewTextFG.textColor = [UIColor colorMainTextColor];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
