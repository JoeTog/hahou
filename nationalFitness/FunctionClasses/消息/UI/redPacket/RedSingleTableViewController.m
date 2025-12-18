


//
//  RedSingleTableViewController.m
//  nationalFitness
//
//  Created by joe on 2017/12/6.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "RedSingleTableViewController.h"

@interface RedSingleTableViewController ()<UITextFieldDelegate,UIGestureRecognizerDelegate>

@end

@implementation RedSingleTableViewController{
    
    //红包金额
    __weak IBOutlet UITextField *redAmountTextF;
    
    
    //附加文字
    
    __weak IBOutlet UITextField *textF;
    
    //确定按钮
    
    __weak IBOutlet UIButton *commitBtn;
    
    //金额text
    
    __weak IBOutlet UILabel *priceLabel;
    
    
    
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"表头底图"]
                                                 forBarPosition:UIBarPositionAny
                                                     barMetrics:UIBarMetricsDefault];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //设置导航栏颜色
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0xcd3c52)]
                                                 forBarPosition:UIBarPositionAny
                                                     barMetrics:UIBarMetricsDefault];
    
    self.title = @"发红包";
    
    [self initUI];
    
}



#pragma mark - 确定点击

- (IBAction)commitClick:(id)sender {
    RedEntity *entity = [RedEntity new];
    entity.redType = @"1";
    entity.redPacketCount = @"1";
    entity.redPacketTotalPrice = redAmountTextF.text;
    entity.redPacketText = textF.text.length > 0?textF.text:@"恭喜发财";
    if (self.delegate) {
        [self.delegate RedTableViewSingle:self SendRed:entity];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField.tag == 1) {
        if (textField.text.length + string.length - range.length > 0) {
            [commitBtn setBackgroundColor:UIColorFromRGB(0xcd3c52)];
            commitBtn.userInteractionEnabled = YES;
        }else{
            [commitBtn setBackgroundColor:[UIColor colorRedPacketUnableColor]];
            commitBtn.userInteractionEnabled = NO;
        }
    }else{
        if (redAmountTextF.text.length > 0) {
            [commitBtn setBackgroundColor:UIColorFromRGB(0xcd3c52)];
            commitBtn.userInteractionEnabled = YES;
        }else{
            [commitBtn setBackgroundColor:[UIColor colorRedPacketUnableColor]];
            commitBtn.userInteractionEnabled = NO;
        }
    }
    return YES;
}

-(void)initUI{
    self.view.backgroundColor = [UIColor colorRedPacketBackColor];
    ViewRadius(commitBtn, 3);
    
    redAmountTextF.keyboardType = UIKeyboardTypeNumberPad;
    priceLabel.font = [UIFont boldSystemFontOfSize:17];
    
    redAmountTextF.placeholder = @"请输入积分";
    textF.placeholder = @"恭喜发财";
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesturedDetected:)]; // 手势类型随你喜欢。
    tapGesture.delegate = self;
    [self.tableView addGestureRecognizer:tapGesture];
}

- (void)tapGesturedDetected:(UITapGestureRecognizer *)recognizer
{
    // do something
    [self.view endEditing:YES];
}



//头高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return 20;
    }
    return 5;
    
}


//设置headview 颜色
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];
    [headerView setBackgroundColor:[UIColor colorRedPacketBackColor]];
    return headerView;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}











- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
