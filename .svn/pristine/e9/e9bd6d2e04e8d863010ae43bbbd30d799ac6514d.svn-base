//
//  ZBMessageInputView.m
//  MessageDisplay
//
//  Created by zhoubin@moshi on 14-5-10.
//  Copyright (c) 2014年 Crius_ZB. All rights reserved.
//

#import "ZBMessageInputView.h"
#import "NSString+Message.h"
#import "PublicDefine.h"

@interface ZBMessageInputView()<UITextViewDelegate>

@end

@implementation ZBMessageInputView

- (void)dealloc
{
    _messageInputTextView.delegate = nil;
    _messageInputTextView = nil;
    
    _voiceChangeButton = nil;
    _multiMediaSendButton = nil;
    _faceSendButton = nil;
    _holdDownButton = nil;
}

#pragma mark - Action

- (void)messageStyleButtonClicked:(UIButton *)sender {
    switch (sender.tag) {
        case 0:
        {
            //0 声音
            _multiMediaSendButton.selected = NO;
            _faceSendButton.selected = NO;
            sender.selected = !sender.selected;
            
            if (sender.selected){
                NSLog(@"声音被点击的");
                [_messageInputTextView becomeFirstResponder];
                
            }else{
                NSLog(@"声音被点击结束");
                [_messageInputTextView resignFirstResponder];
            }
            
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                _holdDownButton.hidden = sender.selected;
                _messageInputTextView.hidden = !sender.selected;
            } completion:^(BOOL finished) {
                
            }];
            
            if ([_delegate respondsToSelector:@selector(didChangeSendVoiceAction:)]) {
                [_delegate didChangeSendVoiceAction:!sender.selected];
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
                _holdDownButton.hidden = YES;
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
            
            if ([_messageInputTextView.text length]==0)
            {
                
                [_messageInputTextView resignFirstResponder];
//                [sender setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    _holdDownButton.hidden = YES;
                    _messageInputTextView.hidden = NO;
                } completion:^(BOOL finished) {
                    
                }];
                
                if ([_delegate respondsToSelector:@selector(didSelectedMultipleMediaAction:)]) {
                    [_delegate didSelectedMultipleMediaAction:YES];
                }
            }
            else{
                NSLog(@"..发送 按钮 ....");

//                [sender setImage:[UIImage imageNamed:@"chat_send"] forState:UIControlStateNormal];
                
                if ([_delegate respondsToSelector:@selector(inputTextViewDidChange:)]) {
                    [_delegate inputTextViewDidChange:_messageInputTextView];
                }


                if ([_delegate respondsToSelector:@selector(didSelectedMultipleMediaAction:)]) {
                    [_delegate didSelectedMultipleMediaAction:NO];
                }
            }
        }
            break;
        default:
            break;
    }
}


#pragma mark - 添加控件
- (void)setupMessageInputViewBarWithStyle:(ZBMessageInputViewStyle )style{
    // 配置输入工具条的样式和布局
    
    // 水平间隔
    CGFloat horizontalPadding = 8;
    
    // 垂直间隔
    CGFloat verticalPadding = 5;
    
    // 按钮长,宽
    CGFloat buttonSize = [ZBMessageInputView textViewLineHeight];
    
    // 发送语音
    _voiceChangeButton = [self createButtonWithImage:[UIImage imageNamed:@"key"]
                                                 HLImage:nil];
    [_voiceChangeButton setImage:[UIImage imageNamed:@"chat_voices"]
                            forState:UIControlStateSelected];
    [_voiceChangeButton addTarget:self
                               action:@selector(messageStyleButtonClicked:)
                     forControlEvents:UIControlEventTouchUpInside];
    _voiceChangeButton.tag = 0;
    _voiceChangeButton.selected = YES;
    [self addSubview:_voiceChangeButton];
    _voiceChangeButton.frame = CGRectMake(horizontalPadding,verticalPadding,buttonSize,buttonSize);
    
    
    // 允许发送多媒体消息
    _multiMediaSendButton = [self createButtonWithImage:[UIImage imageNamed:@"add"]
                                                    HLImage:nil];
    [_multiMediaSendButton setImage:[UIImage imageNamed:@"chat_send"]
                            forState:UIControlStateSelected];
    [_multiMediaSendButton addTarget:self
                                  action:@selector(messageStyleButtonClicked:)
                        forControlEvents:UIControlEventTouchUpInside];
    _multiMediaSendButton.tag = 2;
    [self addSubview:_multiMediaSendButton];
    _multiMediaSendButton.frame = CGRectMake(self.frame.size.width - horizontalPadding - buttonSize,
                                                 verticalPadding,
                                                 buttonSize,
                                                 buttonSize);//self.frame.size.width - horizontalPadding - buttonSize
    
    // 发送表情
    _faceSendButton = [self createButtonWithImage:[UIImage imageNamed:@"face"]
                                              HLImage:nil];
    [self.faceSendButton setImage:[UIImage imageNamed:@"key"]
                         forState:UIControlStateSelected];
    [_faceSendButton addTarget:self
                            action:@selector(messageStyleButtonClicked:)
                  forControlEvents:UIControlEventTouchUpInside];
    _faceSendButton.tag = 1;
    [self addSubview:_faceSendButton];
    _faceSendButton.frame = CGRectMake(self.frame.size.width - 2 * buttonSize - horizontalPadding - 2,verticalPadding,buttonSize,buttonSize);
    
    // 如果是可以发送语言的，那就需要一个按钮录音的按钮，事件可以在外部添加
    _holdDownButton = [self createButtonWithImage:[UIImage imageNamed:@"chat_luyin"] HLImage:nil];
    _holdDownButton.hidden = YES;
    
    [_holdDownButton addTarget:self action:@selector(hiddenShowRecord) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_holdDownButton];
    
    // 初始化输入框
    ZBMessageTextView *textView = [[ZBMessageTextView alloc] initWithFrame:CGRectZero];
    textView.returnKeyType = UIReturnKeySend;
//    [textView becomeFirstResponder];// add by yaowen 这个是为了暂时解决 发送表情时的bug
    textView.enablesReturnKeyAutomatically = YES; // UITextView内部判断send按钮是否可以用
    textView.delegate = self;
    [self addSubview:textView];
	_messageInputTextView = textView;
    
    // 配置不同iOS SDK版本的样式
    
    _holdDownButton.frame = CGRectMake((CGRectGetWidth(self.bounds)-CGRectGetHeight(self.bounds)+10)/2,5,CGRectGetHeight(self.bounds),CGRectGetHeight(self.bounds)-10);
    switch (style)
    {
            
        case ZBMessageInputViewStyleQuasiphysical:
        {
//            _holdDownButton.frame = CGRectMake(horizontalPadding + buttonSize + 2,
//                                                     3.0f,
//                                                     CGRectGetWidth(self.bounds)- 3*buttonSize -2*horizontalPadding- 15.0f,
//                                                     buttonSize);
            _messageInputTextView.backgroundColor = [UIColor whiteColor];
            _messageInputTextView.frame = CGRectMake(horizontalPadding + buttonSize + 2,
                                                     3.0f,
                                                     CGRectGetWidth(self.bounds)- 3*buttonSize -2*horizontalPadding- 15.0f,
                                                     buttonSize);
            
            break;
        }
        case ZBMessageInputViewStyleDefault:
        {
            
            _messageInputTextView.backgroundColor = [UIColor clearColor];
            _messageInputTextView.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
            _messageInputTextView.layer.borderWidth = 0.65f;
            _messageInputTextView.layer.cornerRadius = 4.0f;
            _messageInputTextView.frame = CGRectMake(horizontalPadding + buttonSize + 5.0f + 2,8.0f,CGRectGetWidth(self.bounds)- 3*buttonSize -2*horizontalPadding- 15.0f,buttonSize - 5.0f);
    
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
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, [ZBMessageInputView textViewLineHeight], [ZBMessageInputView textViewLineHeight])];
    if (nil != image)
        [button setImage:image forState:UIControlStateNormal];
    if (nil != hlImage)
        [button setImage:hlImage forState:UIControlStateHighlighted];
    
    return button;
}

#pragma end

-(void)resetMultiButtonImage:(BOOL)force
{
    if (!force)
    {
        //发送的小飞机图片
        if ([_messageInputTextView.text length] > 0)
        {
            _multiMediaSendButton.selected = YES;
        }
        else
        {
            //添加 图片
            _multiMediaSendButton.selected = NO;
        }
    }
    else
    {
        //录语音时，强制显示加号,
        _multiMediaSendButton.selected = NO;
    }
}

// 控制录音界面的展示与隐藏
- (void)hiddenShowRecord
{
    NSLog(@"当前的是不是在底部啊%f  %f",self.frame.size.height,568-self.frame.origin.y);
    if ([_delegate respondsToSelector:@selector(didSelectedRecordAction:)]) {
        if (self.frame.size.height < SCREEN_HEIGHT-self.frame.origin.y) {
            // 隐藏录音界面
            [_delegate didSelectedRecordAction:NO];
        }else{
            // 展示录音界面
            [_delegate didSelectedRecordAction:YES];
        }
    }
    
}

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
    
//    _messageInputTextView.contentInset = UIEdgeInsetsMake((numLines >= 6 ? 4.0f : 0.0f),
//                                                       0.0f,
//                                                       (numLines >= 6 ? 4.0f : 0.0f),
//                                                       0.0f);
    
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
        _messageInputViewStyle = ZBMessageInputViewStyleDefault;
    }
    else
    {
        _messageInputViewStyle = ZBMessageInputViewStyleQuasiphysical;
        
    }
    [self setupMessageInputViewBarWithStyle:_messageInputViewStyle];
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
//    NSLog(@"*** %@,%@ ,range:%d",_messageInputTextView.text, text,range.location);
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
            [_delegate didSendTextAction:_messageInputTextView];
        }

        return NO;
    }
    return YES;
}
#pragma end

-(void)hideKeyBoard
{
    [self messageStyleButtonClicked:_voiceChangeButton];
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
