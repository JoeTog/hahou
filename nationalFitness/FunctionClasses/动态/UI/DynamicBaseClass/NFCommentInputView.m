//
//  NFMessageInputView.m
//  MessageDisplay
//
//  Created by zhoubin@moshi on 14-5-10.
//  Copyright (c) 2014年 Crius_ZB. All rights reserved.
//

#import "NFCommentInputView.h"
#import "NSString+Message.h"
#import "PublicDefine.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "NFDynamicManager.h"
#import "NFbaseViewController.h"
#import "SocketModel.h"


@interface NFCommentInputView()<UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,ChatHandlerDelegate>

@end

@implementation NFCommentInputView{
    SocketModel * socketModel;
    
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
    
    _messageInputTextView.delegate = nil;
    _messageInputTextView = nil;
    _voiceChangeButton = nil;
    _multiMediaSendButton = nil;
    _faceSendButton = nil;
}

#pragma mark - Action
- (void)messageStyleButtonClicked:(UIButton *)sender {
    switch (sender.tag) {
        case 0:
        {
            //0 图片
            _multiMediaSendButton.selected = NO;
            _faceSendButton.selected = NO;
            sender.selected = !sender.selected;
            
            [self sendImage];
            
            if ([_delegate respondsToSelector:@selector(didChangeSendImage:)]) {
                [_delegate didChangeSendImage:!sender.selected];
            }
        }
            break;
        case 1:
        {
            //键盘，表情
            _multiMediaSendButton.selected = NO;
            _voiceChangeButton.selected = YES;
            
            sender.selected = !sender.selected;
            if (sender.selected) {
                NSLog(@"表情被点击");
                [_messageInputTextView resignFirstResponder];
            }else{
                NSLog(@"表情没被点击");
                [_messageInputTextView becomeFirstResponder];
            }
            
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                _messageInputTextView.hidden = NO;
            } completion:^(BOOL finished) {
                
            }];
            
            if ([_delegate respondsToSelector:@selector(didSendFaceAction:)]) {
                [_delegate didSendFaceAction:sender.selected];
            }
        }
            break;
        case 2:
        {
            //添加
            _voiceChangeButton.selected = YES;
            _faceSendButton.selected = NO;
            if (_messageInputTextView.text.length>0)
            {
                [_messageInputTextView resignFirstResponder];
                self.hidden = _isFromHome;
                [self getCOmmentNote];
            }
            else
            {
                [SVProgressHUD showInfoWithStatus:@"请输入评论内容"];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - 点击发布 进行评论
- (void)getCOmmentNote
{
    if (![ClearManager getNetStatus]) {
        [SVProgressHUD showInfoWithStatus:@"请检查网络设置"];
        return;
    }else if ([[NFUserEntity shareInstance].connectStatus isEqualToString:@"1"]){
        [SVProgressHUD showInfoWithStatus:@"未连接到服务器"];
        return;
    }
    NSString*temp = [_messageInputTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([temp length] ==0) {
        [SVProgressHUD showInfoWithStatus:@"不能发送空消息"];
        return;
    }
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"postCircleComment";
    self.parms[@"circleId"] = self.commentId;
    self.parms[@"commentContent"] = _messageInputTextView.text;
    if (self.byCommId) {
        self.parms[@"commentTargetId"] = self.byCommId;
    }else{
        self.parms[@"commentTargetId"] = @"0";
    }
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
    
//    NSMutableDictionary *sendDic = [@{} mutableCopy];
//    NSString *albumId;
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
//    [dateFormatter setDateFormat: @"yyyyMMddhhmmssSS"];
//    albumId = [dateFormatter stringFromDate:[NSDate date]];
//    albumId = [albumId stringByReplacingOccurrencesOfString:@":" withString:@""];
//    self.commId = [albumId stringByReplacingOccurrencesOfString:@"." withString:@""];
//    [sendDic setObject:self.commentType?self.commentType:@"" forKey:@"commType"];
//    [sendDic setObject:self.commentId?self.commentId:@"" forKey:@"fkId"];
//    [sendDic setObject:_messageInputTextView.text forKey:@"content"];
//    [sendDic setObject:self.byCommId?self.byCommId:@"" forKey:@"byCommId"];
//    [sendDic setObject:self.byCommId?@"1":@"0" forKey:@"dateType"];
//    [sendDic setObject:self.commId forKey:@"commId"];
//    [NFDynamicManager execute:@selector(commentNoteManager) target:self callback:@selector(commentNoteCallback:) args:sendDic,nil];
}

#pragma mark - 接收消息代理
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    if (messageType == SecretLetterType_DynamicSuccess) {
        //评论回调
        _messageInputTextView.text = @"";
        if ([_delegate respondsToSelector:@selector(inputTextViewDidChange:)])
        {
            [_delegate inputTextViewDidChange:_messageInputTextView];
        }
        if (_delegate && [_delegate respondsToSelector:@selector(commentSuccess)])
        {
            [_delegate commentSuccess];
        }
//        [SVProgressHUD showSuccessWithStatus:@"评论成功"];
        
    }
}

- (void)commentNoteCallback:(id)data
{
    if (data)
    {
        if ([data objectForKey:kWrongDlog])
        {
            [SVProgressHUD showErrorWithStatus:[data objectForKey:kWrongDlog]];
        }else
        {
            _messageInputTextView.text = @"";
            if ([_delegate respondsToSelector:@selector(inputTextViewDidChange:)])
            {
                [_delegate inputTextViewDidChange:_messageInputTextView];
            }
            if (_delegate && [_delegate respondsToSelector:@selector(commentSuccess)])
            {
                [_delegate commentSuccess];
            }
            [SVProgressHUD showSuccessWithStatus:@"评论成功"];
        }
    }
}


#pragma mark - 添加控件
- (void)setupMessageInputViewBarWithStyle:(NFCommentInputViewStyle )style{
    // 配置输入工具条的样式和布局
    
    // 水平间隔
    CGFloat horizontalPadding = 8;
    
    // 垂直间隔
    CGFloat verticalPadding = 5;
    
    // 按钮长,宽
    CGFloat buttonSize = [NFCommentInputView textViewLineHeight];
    
    // 发送语音
    _voiceChangeButton = [self createButtonWithImage:[UIImage imageNamed:@"动态_详情_拍照"]
                                                 HLImage:nil];
    [_voiceChangeButton setImage:[UIImage imageNamed:@"动态_详情_拍照"]
                            forState:UIControlStateSelected];
    [_voiceChangeButton addTarget:self
                               action:@selector(messageStyleButtonClicked:)
                     forControlEvents:UIControlEventTouchUpInside];
    _voiceChangeButton.tag = 0;
    _voiceChangeButton.selected = YES;
    [self addSubview:_voiceChangeButton];
    _voiceChangeButton.frame = CGRectMake(horizontalPadding,verticalPadding,buttonSize,buttonSize);
    
    
    // 允许发送多媒体消息
    _multiMediaSendButton = [self createButtonWithImage:[UIImage imageNamed:@"动态_详情_发布"]
                                             HLImage:nil];
    [_multiMediaSendButton setImage:[UIImage imageNamed:@"动态_详情_发布"]
                        forState:UIControlStateSelected];
    [_multiMediaSendButton addTarget:self
                                  action:@selector(messageStyleButtonClicked:)
                        forControlEvents:UIControlEventTouchUpInside];
    _multiMediaSendButton.tag = 2;
    [self addSubview:_multiMediaSendButton];
    _multiMediaSendButton.frame = CGRectMake(self.frame.size.width - horizontalPadding - buttonSize,
                                                 verticalPadding,
                                                 buttonSize,
                                                 buttonSize);
    
    // 发送表情
    _faceSendButton = [self createButtonWithImage:[UIImage imageNamed:@"动态_详情_表情"]
                                              HLImage:nil];
    [self.faceSendButton setImage:[UIImage imageNamed:@"动态_详情_表情"]
                         forState:UIControlStateSelected];
    [_faceSendButton addTarget:self
                            action:@selector(messageStyleButtonClicked:)
                  forControlEvents:UIControlEventTouchUpInside];
    _faceSendButton.tag = 1;
    [self addSubview:_faceSendButton];
    _faceSendButton.frame = CGRectMake(self.frame.size.width - 2 * buttonSize - horizontalPadding - 2,verticalPadding,buttonSize,buttonSize);
    
    // 初始化输入框
    ZBMessageTextView *textView = [[ZBMessageTextView alloc] initWithFrame:CGRectZero];
    textView.returnKeyType = UIReturnKeySend;
    textView.enablesReturnKeyAutomatically = YES; // UITextView内部判断send按钮是否可以用
    textView.delegate = self;
    [self addSubview:textView];
	_messageInputTextView = textView;
    
    // 配置不同iOS SDK版本的样式
    
    switch (style)
    {
            
        case NFCommentInputViewStyleQuasiphysical:
        {
            _messageInputTextView.backgroundColor = [UIColor whiteColor];
            _messageInputTextView.frame = CGRectMake(8,
                                                     3.0f,
                                                     CGRectGetWidth(self.bounds) - 16,
                                                     buttonSize);
            
            break;
        }
        case NFCommentInputViewStyleDefault:
        {
            
            _messageInputTextView.backgroundColor = [UIColor clearColor];
            _messageInputTextView.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
            _messageInputTextView.layer.borderWidth = 0.65f;
            _messageInputTextView.layer.cornerRadius = 4.0f;
            _messageInputTextView.frame = CGRectMake(8,
                                                     8.0f,
                                                     CGRectGetWidth(self.bounds) - 16,
                                                     buttonSize - 5.0f);
    
            break;
        }
        default:
            break;
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - layout subViews UI
- (UIButton *)createButtonWithImage:(UIImage *)image HLImage:(UIImage *)hlImage {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, [NFCommentInputView textViewLineHeight], [NFCommentInputView textViewLineHeight])];
    if (nil != image)
        [button setImage:image forState:UIControlStateNormal];
    if (nil != hlImage)
        [button setImage:hlImage forState:UIControlStateHighlighted];
    
    return button;
}

#pragma end

#pragma mark - Message input view

- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight
{
    // 动态改变自身的高度和输入框的高度
    
    if ([_messageInputTextView.text length]>0)
    {
        _multiMediaSendButton.selected = YES;
    }
    else
    {
        _multiMediaSendButton.selected = NO;
    }
    
    
    CGRect prevFrame = _messageInputTextView.frame;
    
    NSUInteger numLines = MAX([_messageInputTextView numberOfLinesOfText],
                              [_messageInputTextView.text numberOfLines]);
    
    _messageInputTextView.frame = CGRectMake(prevFrame.origin.x,prevFrame.origin.y,prevFrame.size.width,
                                             prevFrame.size.height + changeInHeight);
    
    // from iOS 7, the content size will be accurate only if the scrolling is enabled.
    _messageInputTextView.scrollEnabled = YES;
    
    if (numLines >= 1)
    {
        CGPoint bottomOffset = CGPointMake(0.0f, _messageInputTextView.contentSize.height - _messageInputTextView.bounds.size.height);
        [_messageInputTextView setContentOffset:bottomOffset animated:YES];
        [_messageInputTextView scrollRangeToVisible:NSMakeRange(_messageInputTextView.text.length - 2, 1)];
    }
}

+ (CGFloat)textViewLineHeight
{
    return 36.0f ;// 字体大小为16
}

+ (CGFloat)maxHeight
{
    return 80.0f;
}

+ (CGFloat)maxLines{
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? 3.0f : 8.0f;
}
#pragma end

- (void)setup {
    UIView *sepLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    sepLine.backgroundColor = [UIColor colorWithRed:222.0/255 green:222.0/255 blue:222.0/255 alpha:1];
    [self addSubview:sepLine];
    // 配置自适应
    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    self.opaque = YES;
    // 由于继承UIImageView，所以需要这个属性设置
    self.userInteractionEnabled = YES;
    
    if ([[[UIDevice currentDevice]systemVersion]floatValue]>=7 )
    {
        _messageInputViewStyle = NFCommentInputViewStyleDefault;
    }
    else
    {
        _messageInputViewStyle = NFCommentInputViewStyleQuasiphysical;
        
    }
    [self setupMessageInputViewBarWithStyle:_messageInputViewStyle];
    
    
    // 键盘的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardDidChangeFrameNotification object:nil];
    
    // 这个暂时去掉，不要
    _voiceChangeButton.hidden = YES;
    _faceSendButton.hidden = YES;
    _multiMediaSendButton.hidden = YES;
}

#pragma mark - textViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([_delegate respondsToSelector:@selector(inputTextViewWillBeginEditing:)])
    {
        [_delegate inputTextViewWillBeginEditing:_messageInputTextView];
    }
    _faceSendButton.selected = NO;
    _multiMediaSendButton.selected = NO;
   
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if ([_delegate respondsToSelector:@selector(inputTextViewDidChange:)]) {
        [_delegate inputTextViewDidChange:_messageInputTextView];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    [textView becomeFirstResponder];
    
    if ([_delegate respondsToSelector:@selector(inputTextViewDidBeginEditing:)]) {
        [_delegate inputTextViewDidBeginEditing:_messageInputTextView];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (([_messageInputTextView.text  length] == 1
        && [text length]==0)
        
        || [_messageInputTextView.text  length] == 0)
    {
        _multiMediaSendButton.selected = NO;
    }
    
    if ([text length]>0)
    {
        _multiMediaSendButton.selected = YES;
    }
    if ([text isEqualToString:@"\n"])
    {
        if ([_delegate respondsToSelector:@selector(didSendTextAction:)])
        {
            _multiMediaSendButton.selected = YES;
            
            if (_messageInputTextView.text.length>0)
            {
                [_messageInputTextView resignFirstResponder];
                self.hidden = _isFromHome;
                [self getCOmmentNote];
            }
            else
            {
                [SVProgressHUD showInfoWithStatus:@"请输入评论内容"];
            }
            
            [_delegate didSendTextAction:_messageInputTextView];
        }

        return NO;
    }
    return YES;
}
#pragma end

#pragma mark - 发送图片
-(void)sendImage{
    UIActionSheet *myActionSheet = [[UIActionSheet alloc]
                                    initWithTitle:nil
                                    delegate:self
                                    cancelButtonTitle:@"取消"
                                    destructiveButtonTitle:nil
                                    otherButtonTitles: @"从相册选择", @"拍照",nil];
    myActionSheet.tag = 2;
    [myActionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
}

-(void)LocalPhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeImage ,nil];
    picker.delegate = self;
    picker.allowsEditing = YES;
    [[KeepAppBox viewController:self] presentViewController:picker animated:YES completion:nil];
}


-(void)takePhoto
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeImage ,nil];
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [[KeepAppBox viewController:self] presentViewController:picker animated:YES completion:nil];
    }else {
        NSLog(@"该设备无摄像头");
    }
}

// 相册代理方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(getImagePickerController:withInfo:)])
    {
        [self.delegate getImagePickerController:picker withInfo:info];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[KeepAppBox viewController:self] dismissViewControllerAnimated:YES completion:NULL];
}

// 床单代理方法
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self performSelector:@selector(getImage:) withObject:[NSString stringWithFormat:@"%ld",(long)buttonIndex] afterDelay:0.5f];
}

- (void)getImage:(id)data
{
    if ([data isEqualToString:@"1"])
    {
        [self takePhoto];
    }
    else if ([data isEqualToString:@"0"])
    {
        [self LocalPhoto];
    }
}


#pragma mark - keyboard

- (void)keyboardWillHide:(NSNotification *)notification
{
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat animationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    if (self.delegate && [self.delegate respondsToSelector:@selector(keyBoardWillHidden:animationDuration:)])
    {
        [self.delegate keyBoardWillHidden:keyboardRect animationDuration:animationDuration];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat animationDuration= [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    if (self.delegate && [self.delegate respondsToSelector:@selector(keyBoardWillShow:animationDuration:)])
    {
        [self.delegate keyBoardWillShow:keyboardRect animationDuration:animationDuration];
    }
}

- (void)keyboardChange:(NSNotification *)notification
{
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat animationDuration= [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    if (self.delegate && [self.delegate respondsToSelector:@selector(keyboardChange:)])
    {
        [self.delegate keyBoardChange:keyboardRect animationDuration:animationDuration];
    }
}


-(void)hideKeyBoard
{
    [self messageStyleButtonClicked:_voiceChangeButton];
}

//懒加载
-(NSMutableDictionary *)parms{
    if (!_parms) {
        _parms = [[NSMutableDictionary alloc] init];
    }
    return _parms;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
