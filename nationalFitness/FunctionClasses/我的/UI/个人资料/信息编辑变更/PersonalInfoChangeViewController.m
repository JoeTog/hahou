//
//  PersonalInfoChangeViewController.m
//  nationalFitness
//
//  Created by Joe on 2017/7/14.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "PersonalInfoChangeViewController.h"

@interface PersonalInfoChangeViewController ()<UITextViewDelegate>

@end

@implementation PersonalInfoChangeViewController{
    
    
    __weak IBOutlet UIImageView *PersonalInfoChangeTableV;
    
    //头上的title
    __weak IBOutlet UILabel *topTitleLabel;
    
    //信息变更填写框
    __weak IBOutlet UITextField *editTextField;
    
    
    // 个性签名时约束为10 其他隐藏
    __weak IBOutlet UITextView *editTextView;
    
    
    __weak IBOutlet NSLayoutConstraint *textViewConstraint;
    
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = NO;
    
    //设置背景
    CacheKeepBoxEntity *entityy = [[NFbaseViewController new] getAllCacheDataEntity];
    NSString *backGroundImageName = [NSString new];
    if (entityy.themeSelectedIndex == 0) {
        backGroundImageName = @"底";
    }else if (entityy.themeSelectedIndex == 1){
        backGroundImageName = @"";
    }
    PersonalInfoChangeTableV.image = [UIImage imageNamed:backGroundImageName];
    
    [self initColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initUI];
    
    
}

-(void)returnInfoBlock:(returnInfo )backBlock{
    if (self.backBlock != backBlock) {
        self.backBlock = backBlock;
    }
}


-(void)initUI{
    //textfield
    ViewBorderRadius(editTextField, 2, 1, UIColorFromRGB(0xe7e7e7));
    //textview
    ViewBorderRadius(editTextView, 2, 1, UIColorFromRGB(0xe7e7e7));
    
    topTitleLabel.textColor = UIColorFromRGB(0x918687);
    self.view.backgroundColor = UIColorFromRGB(0xf4f4f4);
    editTextView.text = self.currentText;
    editTextField.text = self.currentText;
    if (self.editType == EditNameType) {
        //名字
        self.title = @"编辑昵称";
        editTextView.hidden = YES;
        topTitleLabel.text = @"请输入您的昵称";
        
    }else if (self.editType == EditTypeAccount){
        //账号
        self.title = @"编辑账号";
        editTextView.hidden = YES;
        topTitleLabel.text = @"请输入您的账号";
    }else if (self.editType == EditTypePersonalSingature){
        //个性签名
        self.title = @"个性签名";
        editTextField.hidden = YES;
        textViewConstraint.constant = 10;
        topTitleLabel.text = @"请输入您的个性签名";
    }
    else if (self.editType == EditTypeBeiZhu){
        //备注
        self.title = @"备注";
        editTextView.hidden = YES;
        topTitleLabel.text = @"请输入您的备注信息";
    }else if (self.editType == EditTypeGroupName){
        //备注群组
        self.title = @"群组备注";
        editTextView.hidden = YES;
        topTitleLabel.text = @"请输入群组备注信息";
    }else if (self.editType == EditTypeGroupMineName){
        //备注群组
        self.title = @"我的本群昵称";
        editTextView.hidden = YES;
        topTitleLabel.text = @"请输入您的本群昵称";
    }else if (self.editType == EditTypeGroupMessage){
        self.title = @"群公告";
        editTextField.hidden = YES;
        textViewConstraint.constant = 10;
        topTitleLabel.text = @"请输入您想要发的群公告";
    }
    
    if(!self.ISNotCanEdit){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 50, 30);
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button setTitle:@"确定" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        [button addTarget:self action:@selector(sureButtonClick) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView: button];
        self.navigationItem.rightBarButtonItem = item;
        editTextView.userInteractionEnabled = YES;
    }else{
        editTextView.userInteractionEnabled = NO;
    }
    
    
    
    
    
}

-(void)initColor{
    editTextField.textColor = [UIColor colorMainTextColor];
    editTextView.textColor = [UIColor colorMainTextColor];
    
}



#pragma mark - 设置UIBarButtonItem 右侧确定
-(void)sureButtonClick{
    
    if (self.editType == EditNameType && ([editTextField.text containsString:@"多信"] || [editTextField.text containsString:@"客服"])) {
        [SVProgressHUD showInfoWithStatus:@"昵称中不允许含有官方字眼"];
        return;
    }else if(editTextField.text.length > 20){
        [SVProgressHUD showInfoWithStatus:@"昵称不能超过20个字符"];
        return;
    }
    
    //编辑判断是否为空
    if (self.editType == EditNameType || self.editType == EditTypeAccount|| self.editType == EditTypeBeiZhu|| self.editType == EditTypeGroupName) {
        if (editTextField.text.length == 0 && self.editType != EditTypeBeiZhu) {
            [SVProgressHUD showInfoWithStatus:@"请输入合法字符"];
            return;
        }
        NSString*temp = [editTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (temp.length == 0 && self.editType != EditTypeBeiZhu) {
            [SVProgressHUD showInfoWithStatus:@"不可为空"];
            return;
        }
        
    }
    //编辑个性签名是否为空
//    if (self.editType == EditTypePersonalSingature) {
//        if (editTextView.text.length == 0) {
//            [SVProgressHUD showInfoWithStatus:@"请输入合法字符"];
//            return;
//        }
//    }
    
    if (self.editType == EditNameType || self.editType == EditTypeAccount || self.editType == EditTypeBeiZhu || self.editType == EditTypeGroupName|| self.editType == EditTypeGroupMineName) {
        
        self.backBlock(editTextField.text, self.editType);
        
        [self.navigationController popViewControllerAnimated:YES];
    }else if (self.editType == EditTypePersonalSingature){
        self.backBlock(editTextView.text, EditTypePersonalSingature);
        [self.navigationController popViewControllerAnimated:YES];
    }else if (self.editType == EditTypeGroupMessage){
        [self.view endEditing:YES];
        MKPAlertView *alertView = [[MKPAlertView alloc] initWithTitle:@"" message:@"该公告会通知全部群成员，是否发布" sureBtn:@"确认" cancleBtn:@"取消"];
        alertView.resultIndex = ^(NSInteger index)
        {
            if (index == 2) {
                
                self.backBlock(editTextView.text, EditTypeGroupMessage);
                [self.navigationController popViewControllerAnimated:YES];
            }
        };
        [alertView showMKPAlertView];
        
        
    }
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (textView.text.length + text.length - range.length > 140) {
        [SVProgressHUD showInfoWithStatus:@"最多输入140字"];
        return NO;
    }
    return YES;
}










- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
