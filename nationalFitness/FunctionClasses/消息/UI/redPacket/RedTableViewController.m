



//
//  RedTableViewController.m
//  nationalFitness
//
//  Created by joe on 2017/12/6.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "RedTableViewController.h"

@interface RedTableViewController ()<UITextFieldDelegate,UIGestureRecognizerDelegate>

@end

@implementation RedTableViewController{
    
    //红包个数
    __weak IBOutlet UITextField *redCountTextF;
    
    //总金额
    __weak IBOutlet UITextField *totalAmountTextF;
    
    //附加文字内容
    __weak IBOutlet UITextField *textF;
    
    //确定按钮
    __weak IBOutlet UIButton *commitBtn;
    
    
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

-(void)initUI{
    self.view.backgroundColor = [UIColor colorRedPacketBackColor];
    ViewRadius(commitBtn, 3);
    
    redCountTextF.keyboardType = UIKeyboardTypeNumberPad;
    totalAmountTextF.keyboardType = UIKeyboardTypeNumberPad;
    
    redCountTextF.placeholder = @"本群共x人";
    totalAmountTextF.placeholder = @"输入金额";
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


#pragma mark - 确认按钮
- (IBAction)commitClick:(id)sender {
    RedEntity *entity = [RedEntity new];
    entity.redType = @"1";
    entity.redPacketCount = redCountTextF.text;
    entity.redPacketTotalPrice = totalAmountTextF.text;
    entity.redPacketText = textF.text.length > 0?textF.text:@"恭喜发财";
    if (self.delegate) {
        [self.delegate RedTableViewGroup:self SendRed:entity];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField.tag == 1) {
        if (textField.text.length + string.length - range.length > 0 &&totalAmountTextF.text.length > 0) {
            [commitBtn setBackgroundColor:UIColorFromRGB(0xcd3c52)];
            commitBtn.userInteractionEnabled = YES;
        }else{
            [commitBtn setBackgroundColor:[UIColor colorRedPacketUnableColor]];
            commitBtn.userInteractionEnabled = NO;
        }
    }else if (textField.tag == 2){
        if (textField.text.length + string.length - range.length > 0 &&redCountTextF.text.length > 0) {
            [commitBtn setBackgroundColor:UIColorFromRGB(0xcd3c52)];
            commitBtn.userInteractionEnabled = YES;
        }else{
            [commitBtn setBackgroundColor:[UIColor colorRedPacketUnableColor]];
            commitBtn.userInteractionEnabled = NO;
        }
    }else{
        if (totalAmountTextF.text.length > 0 && redCountTextF.text.length > 0) {
            [commitBtn setBackgroundColor:UIColorFromRGB(0xcd3c52)];
            commitBtn.userInteractionEnabled = YES;
        }else{
            [commitBtn setBackgroundColor:[UIColor colorRedPacketUnableColor]];
            commitBtn.userInteractionEnabled = NO;
        }
    }
    return YES;
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
