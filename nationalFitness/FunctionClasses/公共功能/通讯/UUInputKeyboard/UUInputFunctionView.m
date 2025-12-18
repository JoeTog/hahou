//
//  UUInputFunctionView.m
//  UUChatDemoForTextVoicePicture
//
//  Created by shake on 14-8-27.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import "UUInputFunctionView.h"
#import "Mp3Recorder.h"
#import "UUProgressHUD.h"
#import "ACMacros.h"

#define keyboardHeight 50
//#define keyboardHeight 70
#define imageWidth 35
#define textfieldHeight 35
#define textviewInputTail 50

//相机
#define zuobianBtn @"聊天相机"
#define zuobianSelectBtn @"Chat_take_picture"

//语音
//normal
#define youbianBtn @"语音"
//选中
#define youbianSelectBtn @"聊天键盘"

#define bottomViewHeight 205

@interface SwitcherView : UIView

@end

BOOL hasLiked = YES;//是否允许发送消息【用于限制发送频率】

@implementation SwitcherView
#define  DURTAION  0.25f
- (void)addSubview:(UIView *)view{
    // 动画添加子view 并且改控件只包含一个子view
    CGRect rect = self.frame;
    CGRect frame = view.frame;
    rect.size.height = CGRectGetHeight(frame);
    self.frame = rect;
    for (UIView * v in self.subviews) {// 移除前一个view
        [v removeFromSuperview];
    }
    [super addSubview:view];// 添加一个view
    frame.origin.y = CGRectGetHeight(self.frame);
    view.frame = frame;
    frame.origin.y = 0;
    [UIView animateWithDuration:DURTAION animations:^{// 动画显示
        view.frame = frame;
    }];
    
}

@end

@interface UUInputFunctionView ()<Mp3RecorderDelegate,YTMoreViewDelegate,SLGrowingTextViewDelegate,YTEmojiViewDelegate,TZImagePickerControllerDelegate,EmoticonViewDelegate>
{
    BOOL isbeginVoiceRecord;
    Mp3Recorder *MP3;
    NSInteger playTime;
    NSTimer *playTimer;
    
    UILabel *placeHold;
    
    /* topView 一些设置全局参数 */
    CGFloat top_end_h; // textView 隐藏前的高度
    
    /* textView 一些设置全局参数 */
    //CGFloat text_one_hight; // 一行文字高度
    NSUInteger text_location; // 将要插入表情时 记录最后光标位置
    BOOL text_beInsert; // 记录光标位置后 是否允许插入表情
    
    /* keyBoard 一些设置全局参数 */
    BOOL kb_resign; //系统键盘已响应 响应为YES:且每次响应其值仅用一次
    BOOL kb_visiable;
    
    /* audio(音频) 一些设置全局参数 */
    BOOL audio_beTap; //音频状态按钮是否已被点击
    
    
    
}
@property (nonatomic, strong) UIButton *audio; //录音图标
@property (nonatomic, strong) UIButton *emoji; //表情图标
@property (nonatomic, strong) UIButton *more;  //更多图标“+”
@property (nonatomic, strong) NSArray *icons;  //图标集合

//@property (nonatomic, assign) id<YTKeyBoardDelegate> delegate; //代理
//@property (nonatomic, strong) SLGrowingTextView *textView; //输入框
@property (nonatomic, strong) UIButton *audioBt; //音频录制开关
@property (nonatomic, strong) UIView *bottomView; //底部各种切换控件


@property (nonatomic, strong) UIView *audioView; //录音控制器


@property(nonatomic, strong) EmotionKeyboard *emotionKeyboard;
@end

@implementation UUInputFunctionView

- (id)initWithSuperVC:(UIViewController *)superVC
{
    self.superVC = superVC;
    CGFloat VCWidth = Main_Screen_Width;
    CGFloat VCHeight = Main_Screen_Height;
//    CGRect frame = CGRectMake(0, VCHeight-40, VCWidth, 40);
    //如果导航栏设置为不透明 则布局将会从导航栏下面开始计算
//    CGRect frame = CGRectMake(0, VCHeight-keyboardHeight - 64, VCWidth, keyboardHeight);
    NSLog(@"\n%f\n%f",keyboardHeight,kTopHeight);
    CGRect frame = CGRectMake(0, VCHeight-keyboardHeight - kTopHeight - kTabBarHeight, VCWidth, keyboardHeight + bottomViewHeight);
    if (kTabBarHeight > 49) {
           frame = CGRectMake(0, VCHeight-keyboardHeight - kTopHeight - kTabbarMoreHeight, VCWidth, keyboardHeight + bottomViewHeight);
    }else{
           frame = CGRectMake(0, VCHeight-keyboardHeight - kTopHeight, VCWidth, keyboardHeight + bottomViewHeight);
    }
    
    self = [super initWithFrame:frame];
    if (self) {
        
        MP3 = [[Mp3Recorder alloc]initWithDelegate:self];
        self.backgroundColor = [UIColor whiteColor];
        //发送消息
//        self.btnSendMessage = [UIButton buttonWithType:UIButtonTypeCustom];
//        self.btnSendMessage.frame = CGRectMake(VCWidth-40, 5, 30, 30);
//        self.btnSendMessage.frame = CGRectMake(VCWidth-40, (keyboardHeight - imageWidth)/2, imageWidth, imageWidth);
        //设置发送\相机 按钮位置
//        self.btnSendMessage.frame = CGRectMake(5, (keyboardHeight - imageWidth)/2, 35, 35);
        UIButton *sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(VCWidth-imageWidth-ICON_LR/2, (keyboardHeight - imageWidth)/2, 35, 35)];
//        self.btnSendMessage.frame = CGRectMake(VCWidth-imageWidth-ICON_LR/2, (keyboardHeight - imageWidth)/2, 35, 35);
        self.isAbleToSendTextMessage = YES;
//        [self.btnSendMessage setTitle:@"" forState:UIControlStateNormal];
        
        [sendBtn setImage:[UIImage imageNamed:@"btn_more"] forState:UIControlStateNormal];
        [sendBtn setImage:[UIImage imageNamed:@"btn_key"] forState:UIControlStateSelected];
        
//        sendBtn.titleLabel.font = [UIFont systemFontOfSize:12];
//        sendBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [sendBtn addTarget:self action:@selector(takeCameraAbout) forControlEvents:UIControlEventTouchUpInside];
        self.btnSendMessage = sendBtn;
        [self addSubview:self.btnSendMessage];
        
        //改变状态（语音、文字）
        self.btnChangeVoiceState = [UIButton buttonWithType:UIButtonTypeCustom];
//        self.btnChangeVoiceState.frame = CGRectMake(5, (keyboardHeight - imageWidth)/2, 35, 35);
        //设置语音按钮位置 减去1为微调
//        self.btnChangeVoiceState.frame = CGRectMake(VCWidth-textviewInputTail-1, (keyboardHeight - imageWidth)/2, imageWidth + 8, imageWidth);
        self.btnChangeVoiceState.frame = CGRectMake(5 + 5, (keyboardHeight - imageWidth)/2, imageWidth + 8, imageWidth);
        
        isbeginVoiceRecord = NO;
//        [self.btnChangeVoiceState setImage:[UIImage imageNamed:@"chat_voice_record"] forState:UIControlStateNormal];
//        [self.btnChangeVoiceState setBackgroundImage:[UIImage imageNamed:youbianSelectBtn] forState:UIControlStateSelected];
        
        [self.btnChangeVoiceState setImage:[UIImage imageNamed:youbianBtn] forState:UIControlStateNormal];
        [self.btnChangeVoiceState setImage:[UIImage imageNamed:youbianSelectBtn] forState:UIControlStateSelected];
        
        self.btnChangeVoiceState.titleLabel.font = [UIFont systemFontOfSize:12];
        self.btnChangeVoiceState.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.btnChangeVoiceState addTarget:self action:@selector(voiceRecord:) forControlEvents:UIControlEventTouchUpInside];
        //设置小语音按钮圆角
//        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.btnChangeVoiceState.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(5, 5)];
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.btnChangeVoiceState.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(3, 3)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.btnChangeVoiceState.bounds;
        maskLayer.path = maskPath.CGPath;
        self.btnChangeVoiceState.layer.mask = maskLayer;
        [self addSubview:self.btnChangeVoiceState];
        //语音录入键
        self.btnVoiceRecord = [UIButton buttonWithType:UIButtonTypeCustom];
        
        self.btnVoiceRecord.frame = CGRectMake(textviewInputTail, (keyboardHeight - imageWidth)/2, SCREEN_WIDTH-ICON_WH*3.0f-ICON_TOP*4.0f, textfieldHeight);
        if (SCREEN_WIDTH == 320) {
            self.btnVoiceRecord.frame = CGRectMake(textviewInputTail, (keyboardHeight - imageWidth)/2, SCREEN_WIDTH-ICON_WH*3.0f-ICON_TOP*4.0f, textfieldHeight);
        }
        
//        self.btnVoiceRecord.frame = CGRectMake(70, 5, Main_Screen_Width-70*2, 50);
        self.btnVoiceRecord.hidden = YES;
        [self.btnVoiceRecord setBackgroundImage:[UIImage imageNamed:@"聊天输入框"] forState:UIControlStateNormal];
        [self.btnVoiceRecord setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.btnVoiceRecord setTitleColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        //快速创建 UIColorFromRGB(0x4f4f4e)
        UIImage *cannotClickImage = [UIImage imageWithColor:FirstGray CGSize:CGSizeMake(SCREEN_WIDTH/4*3, 40)];
        [self.btnVoiceRecord setBackgroundImage:cannotClickImage forState:(UIControlStateDisabled)];
        
        [self.btnVoiceRecord setTitle:@"按住说话" forState:UIControlStateNormal];
        [self.btnVoiceRecord setTitle:@"松开发送，上滑取消" forState:UIControlStateHighlighted];
        
        [self.btnVoiceRecord addTarget:self action:@selector(beginRecordVoice:) forControlEvents:UIControlEventTouchDown];
        [self.btnVoiceRecord addTarget:self action:@selector(endRecordVoice:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnVoiceRecord addTarget:self action:@selector(cancelRecordVoice:) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchCancel];
        [self.btnVoiceRecord addTarget:self action:@selector(RemindDragExit:) forControlEvents:UIControlEventTouchDragExit];
        [self.btnVoiceRecord addTarget:self action:@selector(RemindDragEnter:) forControlEvents:UIControlEventTouchDragEnter];
        ViewRadius(self.btnVoiceRecord, 1);
        UIBezierPath *maskPathhh = [UIBezierPath bezierPathWithRoundedRect:self.btnVoiceRecord.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(2, 2)];
        CAShapeLayer *maskLayerrr = [[CAShapeLayer alloc] init];
        maskLayerrr.frame = self.btnVoiceRecord.bounds;
        maskLayerrr.path = maskPathhh.CGPath;
        self.btnVoiceRecord.layer.mask = maskLayerrr;
        [self addSubview:self.btnVoiceRecord];
        
        //输入框
//        self.TextViewInput = [[UITextView alloc]initWithFrame:CGRectMake(textviewInputTail, 5, Main_Screen_Width-2*textviewInputTail, 30)];
//        self.TextViewInput = [[UITextView alloc]initWithFrame:CGRectMake(textviewInputTail, (keyboardHeight - textfieldHeight)/2, Main_Screen_Width-2*textviewInputTail, textfieldHeight + 0.4)];
        SLGrowingTextView * text = [[SLGrowingTextView alloc]init];
        text.delegate = self;
        text.returnKeyType = UIReturnKeySend;
        text.enablesReturnKeyAutomatically = YES;
        text.font = [UIFont systemFontOfSize:16.0f];
        text.minNumberOfLines = 1;
        text.maxNumberOfLines = 5;
        text.backgroundColor = [UIColor whiteColor];
//        text.backgroundColor = [UIColor clearColor];
        
//        [text cornerRadius:5.0f borderColor:[UIColor grayColor] borderWidth:0.5f];
        CGFloat hight = [text sizeThatFits:CGSizeMake(SCREEN_WIDTH-ICON_WH*3.0f-ICON_LR*6.0f, CGFLOAT_MAX)].height;
        //    text.frame = CGRectMake(CGRectGetMaxX(self.audio.frame)+ICON_LR, ICON_TOP, KB_WIDTH-ICON_WH*2.0f-ICON_LR*4.0f, hight);
        text.frame = CGRectMake(CGRectGetMaxX(self.btnChangeVoiceState.frame), ICON_TOP, SCREEN_WIDTH-ICON_WH*3.0f-ICON_LR*4.0f, hight);
        CGFloat insetsTB = (TOP_H - ICON_TOP*2 - hight)*0.5;
        text.contentInset = UIEdgeInsetsMake(insetsTB, 2, insetsTB, 2);
        [text sizeToFit];
        
        UIBezierPath *maskPathh = [UIBezierPath bezierPathWithRoundedRect:text.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(3, 3)];
        CAShapeLayer *maskLayerr = [[CAShapeLayer alloc] init];
        maskLayerr.frame = text.bounds;
        maskLayerr.path = maskPathh.CGPath;
        text.layer.mask = maskLayerr;
        
        self.TextViewInput = text;
        
//        self.TextViewInput.font = [UIFont systemFontOfSize:18];
//        UIBezierPath *maskPathh = [UIBezierPath bezierPathWithRoundedRect:self.TextViewInput.bounds byRoundingCorners:UIRectCornerTopLeft |UIRectCornerBottomLeft  cornerRadii:CGSizeMake(5, 5)];
//        CAShapeLayer *maskLayerr = [[CAShapeLayer alloc] init];
//        maskLayerr.frame = self.TextViewInput.bounds;
//        maskLayerr.path = maskPathh.CGPath;
//        self.TextViewInput.layer.mask = maskLayerr;
//        self.TextViewInput.layer.backgroundColor = [UIColor whiteColor].CGColor;
//        self.TextViewInput.layer.opacity = 1;
//        
//        ViewRadius(self.TextViewInput, 3);
//        //将return改为发送
//        self.TextViewInput.returnKeyType = UIReturnKeySend;
//        self.TextViewInput.delegate = self;
//        self.TextViewInput.layer.borderWidth = 1;
//        self.TextViewInput.layer.borderColor = [[[UIColor lightGrayColor] colorWithAlphaComponent:0.4] CGColor];
//        self.TextViewInput.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.TextViewInput];
        
        //输入框的提示语
//        placeHold = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 200, 30)];
        placeHold = [[UILabel alloc]initWithFrame:CGRectMake(10, 1, 200, textfieldHeight)];
//        placeHold.text = @"请输入文字";
        placeHold.text = @"";
        placeHold.textColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.8];
        [self.TextViewInput addSubview:placeHold];
        
        //表情按钮
//        UIButton *emoji = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-(ICON_LR+ICON_WH)*2.0f, ICON_TOP, ICON_WH, ICON_WH)]; 
        UIButton *emoji = [[UIButton alloc]initWithFrame:CGRectMake(VCWidth-imageWidth * 2 - ICON_LR*1, (keyboardHeight - imageWidth)/2, 35, 35)];
        
//        if (SCREEN_WIDTH >= 414) {
//            [emoji setBackgroundImage:[UIImage imageNamed:@"btn_face"] forState:UIControlStateNormal];
//            [emoji setBackgroundImage:[UIImage imageNamed:@"btn_faceSelect"] forState:UIControlStateSelected];
//        }else{
            [emoji setImage:[UIImage imageNamed:@"btn_face"] forState:UIControlStateNormal];
            [emoji setImage:[UIImage imageNamed:@"btn_faceSelect"] forState:UIControlStateSelected];
//        }
        
//        if (SCREEN_WIDTH >= 375) {
//            [emoji setImage:[UIImage imageNamed:@"btn_face"] forState:UIControlStateNormal];
//            [emoji setImage:[UIImage imageNamed:@"btn_faceSelect"] forState:UIControlStateSelected];
//        }
        [emoji addTarget:self action:@selector(emojiClick) forControlEvents:(UIControlEventTouchUpInside)];
        self.emojiBtn = emoji;
        [self addSubview:self.emojiBtn];
        
        //分割线
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Main_Screen_Width, 1)];
        lineView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
        [self addSubview:lineView];
        
        //添加通知
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDidShowOrHide:) name:UIKeyboardWillChangeFrameNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(faceDidSelected:) name:SDFaceDidSelectNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteBtnClicked) name:SDFaceDidDeleteNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emojiViewSend) name:SDFaceDidSendNotification object:nil];
//        [self emojiViewSend];
        
//        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(growingTextViewDidEndEditing:) name:UIKeyboardWillHideNotification object:nil];
        
        //表情 第一次进来设置为隐藏
        self.addFaceView.hidden = YES;
        self.emotionKeyboard.hidden = YES;
        
        //更多
        self.moreView = [[YTMoreView alloc]initWithFrame:CGRectMake(0, keyboardHeight, SCREEN_WIDTH, EMOJI_VIEW_HEIGHT)];
        self.moreView.delegate = self;
        self.moreView.backgroundColor = UIColorFromRGB(0xefefef);
        //默认进来是隐藏功能按钮的 当点击更多时 设置为可见
        self.moreView.scrollView.hidden = YES;
        
        const char *groupClassName = [@"GroupChatViewController" cStringUsingEncoding:NSASCIIStringEncoding];
        // 从一个字串返回一个类
        Class groupClass = objc_getClass(groupClassName);
        const char *singleClassName = [@"MessageChatViewController" cStringUsingEncoding:NSASCIIStringEncoding];
        // 从一个字串返回一个类
        Class singleClass = objc_getClass(singleClassName);
        if ([self.superVC isKindOfClass:[groupClass class]]) {
            //[self.moreView addResourceUpdateisGroup:YES];
            self.moreView.IsGroup = YES;
        }else if ([self.superVC isKindOfClass:[singleClass class]]){
            //[self.moreView addResourceUpdateisGroup:NO];
            self.moreView.IsGroup = NO;
            
        }
        
        [self.moreView initUI];
        
//        SwitcherView * bottom = [[SwitcherView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.TextViewInput.frame), SCREEN_WIDTH, EMOJI_VIEW_HEIGHT)];
        SwitcherView * bottom = [[SwitcherView alloc]initWithFrame:CGRectMake(0, 50, SCREEN_WIDTH, EMOJI_VIEW_HEIGHT)];
//        bottom.backgroundColor = [UIColor whiteColor];
        bottom.backgroundColor = UIColorFromRGB(0xefefef);
        [self addSubview:bottom];
        [bottom mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.mas_bottom);
            make.left.mas_equalTo(self.mas_left);
            make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, EMOJI_VIEW_HEIGHT));
        }];
        self.bottomView = bottom;
    }
    return self;
}



/**
 添加表情view
 */
#pragma mark - 添加表情view
-(SDChatAddFacekeyBoardView *)addFaceView{
    if (!_addFaceView){
        _addFaceView =[SDChatAddFacekeyBoardView faceKeyBoard];
        //        _addFaceView.backgroundColor =[UIColor redColor];
        _addFaceView.width =SDDeviceWidth;
        _addFaceView.height=bottomViewHeight;
    }
    //输入框下方横线
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    line.backgroundColor = UIColorFromRGB(0xd8d8d8);
    
    [_addFaceView addSubview:line];
    return _addFaceView;
}

/**
 添加收藏view
 */







-(void)EditTextview:(beginEditTextView)block{
    __weak typeof(self)weakSelf = self;
    if (weakSelf.textEditBlock != block) {
        weakSelf.textEditBlock = block;
    }
}

-(void)EndEditBlock:(endEditTextView)block{
    if (self.textEndEditBlock != block) {
        self.textEndEditBlock = block;
    }
}

-(void)textEditingBlock:(EditingTextView)block{
    if (self.textEditingBlock != block) {
        self.textEditingBlock = block;
    }
}

-(void)clickRedpacket:(ClickRedpacket)block{
    if (self.clickRedpacket != block) {
        self.clickRedpacket = block;
    }
}

-(void)clickCard:(ClickCard)block{
    if (self.clickCard != block) {
        self.clickCard = block;
    }
}


-(void)clickTransferAccont:(ClickTransferAccont)block{
    if (self.clickTransferAccont != block) {
        self.clickTransferAccont = block;
    }
}

-(void)iinputAiTe:(IInputAiTe)block{
    if (self.inputAiTe != block) {
        self.inputAiTe = block;
    }
}

-(void)deleteCollectPicture:(DeleteCollectPicture)block{
    if (self.DeleteCollectpicture != block) {
        self.DeleteCollectpicture = block;
    }
}

-(void)ClickInvite:(ClickInvite)block{
    if (self.ClickInvite != block) {
        self.ClickInvite = block;
    }
}

-(void)destorySelfClick:(destorySelf)block{
    if (self.destorySelfff != block) {
        self.destorySelfff = block;
    }
}


#pragma mark - 录音touch事件
- (void)beginRecordVoice:(UIButton *)button
{
    [MP3 startRecord];
    playTime = 0;
    playTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countVoiceTime) userInfo:nil repeats:YES];
    [UUProgressHUD show];
}

- (void)endRecordVoice:(UIButton *)button
{
    if (playTimer) {
        [MP3 stopRecord];
        [playTimer invalidate];
        playTimer = nil;
    }
}

- (void)cancelRecordVoice:(UIButton *)button
{
    if (playTimer) {
        [MP3 cancelRecord];
        [playTimer invalidate];
        playTimer = nil;
    }
    [UUProgressHUD dismissWithError:@"取消"];
}

- (void)RemindDragExit:(UIButton *)button
{
    [UUProgressHUD changeSubTitle:@"松开取消"];
}

- (void)RemindDragEnter:(UIButton *)button
{
    [UUProgressHUD changeSubTitle:@"上滑取消"];
}


- (void)countVoiceTime
{
    playTime ++;
    if (playTime>=60) {
        [self endRecordVoice:nil];
    }
}

#pragma mark - Mp3RecorderDelegate

//回调录音资料
- (void)endConvertWithData:(NSData *)voiceData
{
    [self.delegate UUInputFunctionView:self sendVoice:voiceData time:playTime+1];
    [UUProgressHUD dismissWithSuccess:@"发送成功"];
    self.superTableview.userInteractionEnabled = NO;
    //缓冲消失时间 (最好有block回调消失完成)
    self.btnVoiceRecord.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.superTableview.userInteractionEnabled = YES;
        self.btnVoiceRecord.enabled = YES;
    });
}

- (void)failRecord
{
    
    [UUProgressHUD dismissWithSuccess:@"太短了"];
    
    //缓冲消失时间 (最好有block回调消失完成)
    self.btnVoiceRecord.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.btnVoiceRecord.enabled = YES;
    });
}

#pragma mark - Keyboard methods
//跟随键盘高度变化
-(void)keyboardDidShowOrHide:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    CGRect newFrame = self.frame;
//    newFrame.origin.y = keyboardEndFrame.origin.y - newFrame.size.height;
   // NSLog(@" %f",keyboardEndFrame.origin.y);
    if (kTabBarHeight > 49) {
        
        newFrame.origin.y = keyboardEndFrame.origin.y - (newFrame.size.height - bottomViewHeight) - kTopHeight ;
        
//        if (keyboardEndFrame.origin.y < 500) {
//            //当为x 且键盘endframe的y在479时 不需要多减去34
//            newFrame.origin.y = keyboardEndFrame.origin.y - (newFrame.size.height - bottomViewHeight) - kTopHeight ;
//        }else{
//            newFrame.origin.y = keyboardEndFrame.origin.y - (newFrame.size.height - bottomViewHeight) - kTopHeight-kTabbarMoreHeight;
//        }
        
    }else{
        newFrame.origin.y = keyboardEndFrame.origin.y - (newFrame.size.height - bottomViewHeight) - kTopHeight;
    }
    self.frame = newFrame;
    
    [UIView commitAnimations];
}

#pragma mark - 改变输入与录音状态
- (void)voiceRecord:(UIButton *)sender
{
    self.btnChangeVoiceState.selected = !self.btnChangeVoiceState.selected;
    [self clickSmallVoice];
}

#pragma mark - 当点击了小语音按钮
-(void)clickSmallVoice{
    if (self.btnChangeVoiceState.selected) {
        //选中yes 为语音输入状态
        //将输入框改变
        //输入框放弃第一响应
        [self.TextViewInput resignFirstResponder];
        self.btnVoiceRecord.hidden = NO;
        self.TextViewInput.hidden = YES;
        self.emojiBtn.selected = NO;
        //移除表情界面
        self.addFaceView.hidden = YES;
        self.emotionKeyboard.hidden = YES;
        
        //收起 键盘 或 功能菜单
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:AnimationTime];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        CGRect newFrame = self.frame;
        if (kTabBarHeight > 49) {
            newFrame.origin.y = SCREEN_HEIGHT - keyboardHeight - kTopHeight - kTabbarMoreHeight;
        }else{
            newFrame.origin.y = SCREEN_HEIGHT - keyboardHeight - kTopHeight;
        }
        self.frame = newFrame;
        [UIView commitAnimations];
        
        NSNotification* notification = [NSNotification notificationWithName:UIKeyboardWillHideNotification object:nil];
        if ([self.superVC respondsToSelector:@selector(keyboardChange:)]) {
            [self.superVC performSelector:@selector(keyboardChange:) withObject:notification afterDelay:0];
            
        }
        
        //隐藏功能按钮
        self.moreView.scrollView.hidden = YES;
        //将更多按钮设置为normal
        self.btnSendMessage.selected = NO;
        
        
    }else{
        //选中no 为键盘输入
        //输入框改变
        self.btnVoiceRecord.hidden = YES;
        self.TextViewInput.hidden = NO;
        //输入框成为第一响应
        [self.TextViewInput becomeFirstResponder];
        //将更多按钮设置为normal
        self.btnSendMessage.selected = NO;
        
    }
    
}

-(void)keyboardChange:(UIButton *)sender{
}
-(void)tableViewScrollToBottomOffSetUseByMoreView{
}



#pragma mark - 当点击了更多按钮
-(void)clickMoreBtn{
    if (self.btnSendMessage.selected) {
        BOOL IsFromEmoil = NO;//是否从点击了表情过来的
//        CGRect frame;
//        frame = self.bottomView.frame;
//        frame.origin.y = CGRectGetHeight(self.bounds);
//        self.bottomView.frame = frame;
        
        //当点击状态为yes 弹出功能菜单状态
        //改变输入框状态
        self.btnVoiceRecord.hidden = YES;
        self.TextViewInput.hidden = NO;
        //输入框放弃响应
        [self.TextViewInput resignFirstResponder];
        if(self.emojiBtn.selected){
            IsFromEmoil = YES;
        }
        //设置小语音按钮为普通状态
        self.btnChangeVoiceState.selected = NO;
        //设置白清按钮为普通状态
        self.emojiBtn.selected = NO;
        self.addFaceView.hidden = YES;
        self.emotionKeyboard.hidden = YES;
        //弹起功能菜单
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:AnimationTime];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        CGRect newFrame = self.frame;
        if (kTabBarHeight > 49) {
            newFrame.origin.y = SCREEN_HEIGHT - EMOJI_VIEW_HEIGHT - kTopHeight - keyboardHeight -kTabbarMoreHeight;
        }else{
            newFrame.origin.y = SCREEN_HEIGHT - EMOJI_VIEW_HEIGHT - kTopHeight - keyboardHeight;
        }
        self.frame = newFrame;
        [UIView commitAnimations];
        self.moreView.scrollView.hidden = NO;
//        if ([NSStringFromClass(self.superTableview) isEqualToString:@"chatTableView"]) {
//        }
        [self.bottomView addSubview:self.moreView];
        
        self.moreView.delegate = self;
        
        if ([self.superVC respondsToSelector:@selector(tableViewScrollToBottomOffSetUseByMoreView)]) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self.superVC performSelector:@selector(tableViewScrollToBottomOffSetUseByMoreView) withObject:nil afterDelay:0];
            });
        }
        
    }else{
        //通知界面收起
        CGRect frame = self.superTableview.frame;
        frame.origin.y = 0;
        [UIView animateWithDuration:AnimationTime animations:^{
            self.superTableview.frame = frame;
        } completion:^(BOOL finished) {
        }];
        [self hidenMoreBtn];
    }
}

//发送消息（文字图片）
#pragma mark - 发送消息
- (void)sendMessage
{
    if (![self.TextViewInput hasText]&&(self.TextViewInput.text.length==0)) {
        [SVProgressHUD showInfoWithStatus:@"不能发送空消息"];
        return;
    }
    NSString *plainText = self.TextViewInput.internalTextView.clearText;
    //空格处理
    plainText = [plainText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString*temp = [plainText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([temp length] ==0) {
        [SVProgressHUD showInfoWithStatus:@"不能发送空消息"];
        return;
    }
    if (!hasLiked) {//如果为NO 则提示频率过快
        [SVProgressHUD showInfoWithStatus:@"发送频率过快!"];
        return;
    }
    hasLiked = NO;//发送后 设置为NO 。
    //hasLiked
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        hasLiked = YES; //弹框完成后延时0.5秒在设置
    });
//    NSString *resultStr = [self.TextViewInput.text stringByReplacingOccurrencesOfString:@"   " withString:@""];
    [self.delegate UUInputFunctionView:self sendMessage:plainText];
    
}



#pragma mark  - 更多按钮 点击
-(void)takeCameraAbout{
    self.btnSendMessage.selected = !self.btnSendMessage.selected;
    [self clickMoreBtn];
}

#pragma mark - 收起表情
-(void)hidenEmoji{
    self.emojiBtn.selected = NO;
    [UIView animateWithDuration:AnimationTime animations:^{
        CGRect newFrame = self.frame;
        if(kTopHeight > 69){
            newFrame.origin.y = SCREEN_HEIGHT - keyboardHeight - kTopHeight - kTabbarMoreHeight;
        }else{
            newFrame.origin.y = SCREEN_HEIGHT - keyboardHeight - kTopHeight;
        }
        self.frame = newFrame;
        
    } completion:^(BOOL finished) {
        self.btnVoiceRecord.hidden = YES;
        self.TextViewInput.hidden = NO;
        //移除表情界面
        self.addFaceView.hidden = YES;
        self.emotionKeyboard.hidden = YES;
    }];
    
    if ([self.superVC respondsToSelector:@selector(tableViewScrollToBottomOffSetUseByMoreView)]) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.superVC performSelector:@selector(tableViewScrollToBottomOffSetUseByMoreView) withObject:nil afterDelay:0];
        });
    }
}

#pragma mark - 收起更多按钮
-(void)hidenMoreBtn{
    
    self.btnSendMessage.selected = NO;
    [UIView animateWithDuration:AnimationTime animations:^{
        CGRect newFrame = self.frame;
        if(kTopHeight > 69){
            newFrame.origin.y = SCREEN_HEIGHT - keyboardHeight - kTopHeight - kTabbarMoreHeight;
        }else{
            newFrame.origin.y = SCREEN_HEIGHT - keyboardHeight - kTopHeight;
        }
        self.frame = newFrame;
        
        
    } completion:^(BOOL finished) {
        self.btnVoiceRecord.hidden = YES;
        self.TextViewInput.hidden = NO;
        //收起隐藏功能菜单
        self.moreView.scrollView.hidden = YES;
    }];
    
    if ([self.superVC respondsToSelector:@selector(tableViewScrollToBottomOffSetUseByMoreView)]) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.superVC performSelector:@selector(tableViewScrollToBottomOffSetUseByMoreView) withObject:nil afterDelay:0];
        });
    }
    
}

#pragma mark - 收起输入框
-(void)hideninputView{
    [UIView animateWithDuration:AnimationTime animations:^{
        CGRect newFrame = self.frame;
        if(kTopHeight > 69){
            newFrame.origin.y = SCREEN_HEIGHT - keyboardHeight - kTopHeight - kTabbarMoreHeight;
        }else{
            newFrame.origin.y = SCREEN_HEIGHT - keyboardHeight - kTopHeight;
        }
        self.frame = newFrame;
    } completion:^(BOOL finished) {
        self.btnSendMessage.selected = NO;
        self.btnVoiceRecord.hidden = YES;
        self.TextViewInput.hidden = NO;
        //收起隐藏功能菜单
        self.moreView.scrollView.hidden = YES;
    }];
    
    if ([self.superVC respondsToSelector:@selector(tableViewScrollToBottomOffSetUseByMoreView)]) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.superVC performSelector:@selector(tableViewScrollToBottomOffSetUseByMoreView) withObject:nil afterDelay:0];
        });
    }
    
}

-(void)removeEmotionKeyboardOberser{
    
    if(self.emotionKeyboard){
        [self.emotionKeyboard removeAllOberserrr];
    }
    [self.TextViewInput removeAllOberserrr];
    
}

#pragma mark - 表情按钮点击
-(void)emojiClick{
    self.emojiBtn.selected = !self.emojiBtn.selected;
    if (self.emojiBtn.selected) {
        BOOL IsFromMore = NO;//是否从点击了更多过来的
        
//        if ([self.superVC respondsToSelector:@selector(tapTableView)] && [self.TextViewInput isFirstResponder]) {
//            [self.superVC performSelector:@selector(tapTableView) withObject:nil afterDelay:0];
//        }
        
        self.addFaceView.faceToolBar.sendBtn.selected = self.TextViewInput.text.length > 0;
        //当点击状态为yes 弹出表情菜单
        //改变输入框状态
        self.btnVoiceRecord.hidden = YES;
        self.TextViewInput.hidden = NO;
        //输入框放弃响应
        [self.TextViewInput resignFirstResponder];
        //设置小语音按钮为普通状态
        if(self.btnSendMessage.selected){
            IsFromMore = YES;
        }
        self.btnChangeVoiceState.selected = NO;
        //设置更多按钮为普通状态
        self.btnSendMessage.selected = NO;
        //有功能菜单收起来
        self.moreView.scrollView.hidden = YES;
        //弹起功能菜单
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:AnimationTime];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        CGRect newFrame = self.frame;
        if (kTabBarHeight > 49) {
            newFrame.origin.y = SCREEN_HEIGHT - EMOJI_VIEW_HEIGHT - kTopHeight - keyboardHeight  -kTabbarMoreHeight;;
        }else{
            newFrame.origin.y = SCREEN_HEIGHT - EMOJI_VIEW_HEIGHT - kTopHeight - keyboardHeight;
        }
        self.frame = newFrame;
        [UIView commitAnimations];
        
        //表情
        self.addFaceView.hidden = NO;//这里如果注释 则消息发送后 界面显示会异常
        [self.addFaceView.faceToolBar returnSend:^{
            [self emojiViewSend];
        }];
        
        //self.addFaceView.faceListView.hidden = YES;
        //显示表情
        //self.addFaceView.hidden = YES;
        
        //删除 注释
//        const char *groupClassName = [@"GroupChatViewController" cStringUsingEncoding:NSASCIIStringEncoding];
//        // 从一个字串返回一个类
//        Class groupClass = objc_getClass(groupClassName);
//        if([self.superVC isKindOfClass:[groupClass class]]){
//            self.addFaceView.hidden = NO;
//        }else{
            if (!self.emotionKeyboard) {
                self.emotionKeyboard = [[EmotionKeyboard alloc] initWithFrame:CGRectMake(0, keyboardHeight, SCREEN_WIDTH, EMOJI_VIEW_HEIGHT)];
                //            [self.bottomView addSubview:self.emotionKeyboard];
                
                [self addSubview:self.emotionKeyboard];
            }else{
                            self.emotionKeyboard.frame = CGRectMake(0, keyboardHeight, SCREEN_WIDTH, EMOJI_VIEW_HEIGHT);
                self.emotionKeyboard.collectListView;//为了刷新收藏的数据
                self.emotionKeyboard.hidden = NO;
                NSLog(@"self.emotionKeyboard.frame = %@",self.emotionKeyboard.frame);
            }
            NSLog(@"self.emotionKeyboard frame = %@",self.emotionKeyboard.frame);
            //在这里设置默认选中的 地方
            self.emotionKeyboard.delegate = self;

            __weak typeof(self)weakSelf=self;
            [self.emotionKeyboard.collectListView EmotionListViewDeleteCollectePictureBlock:^(NSString *fileId) {
                NSLog(@"fileId = %@",fileId);
                weakSelf.DeleteCollectpicture(fileId);
            }];
        
        
//        }
        
        
        
        
        [self.addFaceView.faceToolBar returnCollectBlock:^{
            
            //点击了收藏
            self.addFaceView.faceListView.hidden = YES;
//            self.emotionKeyboard = [EmotionKeyboard sharedEmotionKeyboardView];
            
            self.emotionKeyboard = [[EmotionKeyboard alloc] initWithFrame:CGRectMake(0, keyboardHeight, SCREEN_WIDTH, EMOJI_VIEW_HEIGHT)];
            self.emotionKeyboard.delegate = self;
            //[self addSubview:self.emotionKeyboard];
            
//            self.emotionKeyboard.collectListView = [[EmotionListView alloc] init];
//            self.emotionKeyboard.collectListView.Default = NO;
//            self.emotionKeyboard.collectListView.currentType = EmotionToolBarButtonTypeCollect;
//            self.emotionKeyboard.collectListView.emotions = [EmotionTool CollectImages];
//            [self addSubview:self.emotionKeyboard.collectListView];
            
        }];
        
        [self.addFaceView.faceToolBar returnEmoilBlock:^{
            //点击了表情
            self.addFaceView.faceListView.hidden = NO;
            
        }];
        
        //删除 注释
//        if([self.superVC isKindOfClass:[groupClass class]]){
//            [self.bottomView addSubview:self.addFaceView];
//        }
//        [self.bottomView addSubview:self.addFaceView];
        
        
        if ([self.superVC respondsToSelector:@selector(tableViewScrollToBottomOffSetUseByMoreView)]) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self.superVC performSelector:@selector(tableViewScrollToBottomOffSetUseByMoreView) withObject:nil afterDelay:0];
            });
        }
        
    }else{
        //通知界面收起 superTableview
//        CGRect frame = self.superTableview.frame;
//        frame.origin.y = 0;
//        [UIView animateWithDuration:AnimationTime animations:^{
//            self.superTableview.frame = frame;
//        } completion:^(BOOL finished) {
//        }];
        [self hidenEmoji];
        
    }
}

/**moewView包含控件事件，有可能是后期扩展*/
#pragma mark - 更多按钮菜单 相册、照相 红包
- (void)moreViewType:(YTMoreViewTypeAction)type{
    if (type == YTMoreViewTypeActionPhoto) {
//        [self openPicLibrary];
        [self pushTZImagePickerController];
    }else if (type == YTMoreViewTypeActionCamera){
        [self addCarema];
    }else if (type == YTMoreViewTypeActionRed){
        //跳转到红包  MessageChatViewController GroupChatViewController
        const char *groupClassName = [@"GroupChatViewController" cStringUsingEncoding:NSASCIIStringEncoding];
        // 从一个字串返回一个类
        Class groupClass = objc_getClass(groupClassName);
        const char *singleClassName = [@"MessageChatViewController" cStringUsingEncoding:NSASCIIStringEncoding];
        // 从一个字串返回一个类
        Class singleClass = objc_getClass(singleClassName);
        if ([self.superVC isKindOfClass:[groupClass class]]) {
            //服务器 版
            if (self.clickRedpacket) {
                self.clickRedpacket();
            }
            //本地版
//            RedEntity *redEntity = [RedEntity new];
//            redEntity.redType = @"1";
//            redEntity.redPacketCount = @"10";
//            redEntity.redPacketTotalPrice = @"1";
//            redEntity.redPacketText = @"一个红包";
//            if (self.delegate) {
//                [self.delegate UUInputFunctionView:self sendRed:redEntity];
//            }
            //群组红包
//            UIStoryboard *st = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
//            RedTableViewController *vc = [st instantiateViewControllerWithIdentifier:@"RedTableViewController"];
//            vc.delegate = self;
//            [[KeepAppBox viewController:self].navigationController pushViewController:vc animated:YES];
        }else if ([self.superVC isKindOfClass:[singleClass class]]){
            
            //服务器 版
            if (self.clickRedpacket) {
                self.clickRedpacket();
            }
            
            //本地版
//            RedEntity *redEntity = [RedEntity new];
//            redEntity.redType = @"1";
//            redEntity.redPacketCount = @"10";
//            redEntity.redPacketTotalPrice = @"1";
//            redEntity.redPacketText = @"一个红包";
//            if (self.delegate) {
//                [self.delegate UUInputFunctionView:self sendRed:redEntity];
//            }
            
            
            //单聊红包
//            UIStoryboard *st = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
//            RedSingleTableViewController *vc = [st instantiateViewControllerWithIdentifier:@"RedSingleTableViewController"];
//            vc.delegate = self;
//            [[KeepAppBox viewController:self].navigationController pushViewController:vc animated:YES];
        }
    }else if (type == YTMoreViewTypeActionTransfer){
        if (self.clickTransferAccont) {
            self.clickTransferAccont();
        }
    }else if (type == YTMoreViewTypeActionCard){
        //跳转到红包  MessageChatViewController GroupChatViewController
        const char *groupClassName = [@"GroupChatViewController" cStringUsingEncoding:NSASCIIStringEncoding];
        // 从一个字串返回一个类
        Class groupClass = objc_getClass(groupClassName);
        const char *singleClassName = [@"MessageChatViewController" cStringUsingEncoding:NSASCIIStringEncoding];
        // 从一个字串返回一个类
        Class singleClass = objc_getClass(singleClassName);
        if ([self.superVC isKindOfClass:[groupClass class]]) {
            if (self.clickCard) {
                self.clickCard();
            }
        }else if ([self.superVC isKindOfClass:[singleClass class]]){
            if (self.clickCard) {
                self.clickCard();
            }
        }
        
    }else if (type == YTMoreViewTypeActionInvite){
        if (self.ClickInvite) {
            self.ClickInvite();
        }
    }
    
}

#pragma mark - 红包代理群聊
- (void)RedTableViewGroup:(UITableViewController *)funcView SendRed:(RedEntity *)redEntity{
    NSLog(@"将参数带到群聊天界面");
    if (self.delegate) {
        [self.delegate UUInputFunctionView:self sendRed:redEntity];
    }
}

#pragma mark - 红包代理单聊
- (void)RedTableViewSingle:(UITableViewController *)funcView SendRed:(RedEntity *)redEntity{
    NSLog(@"将参数带到单聊聊天界面");
    if (self.delegate) {
        [self.delegate UUInputFunctionView:self sendRed:redEntity];
    }
}


#pragma mark - 移除更多view 相机 拍照等
-(void)RemoveMoreViewFromSubview{
    [self.moreView removeFromSuperview];
}

#pragma mark - TextViewDelegate
//- (void)textViewDidBeginEditing:(UITextView *)textView
//{
//    //当点击输入框时候
//    //更多按钮选中为no
//    self.btnSendMessage.selected = NO;
//    //有功能菜单收起来
//    self.moreView.scrollView.hidden = YES;
//    //更多按钮设置为no
//    self.btnSendMessage.selected = NO;
//    //传出编辑事件
//    if (self.textEditBlock) {
//        self.textEditBlock(); //需要穿一个type
//    }
//    if (self.TextViewInput.text.length>0)
//        placeHold.hidden = YES;
//    else
//        placeHold.hidden = NO;
//}

//- (void)textViewDidChange:(UITextView *)textView
//{
//    //当输入文字后 不让其改变味发送按钮
////    [self changeSendBtnWithPhoto:textView.text.length>0?NO:YES];
//    placeHold.hidden = textView.text.length>0;
//    if (self.textEditingBlock && self.isNeedBlock) {
//        self.textEditingBlock();
//    }
//}

- (void)changeSendBtnWithPhoto:(BOOL)isPhoto
{
//    self.isAbleToSendTextMessage = !isPhoto;
//    [self.btnSendMessage setTitle:isPhoto?@"":@"send" forState:UIControlStateNormal];
//    self.btnSendMessage.frame = RECT_CHANGE_width(self.btnSendMessage, isPhoto?35:35);
//    UIImage *image = [UIImage imageNamed:isPhoto?@"Chat_take_picture":@"chat_send_message"];
//    [self.btnSendMessage setImage:image forState:UIControlStateNormal];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (self.textEndEditBlock && self.isNeedBlock) {
        self.textEndEditBlock();
    }
    if (self.TextViewInput.text.length>0)
        placeHold.hidden = YES;
    else
        placeHold.hidden = NO;
}

//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
//    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
//        [self performSelector:@selector(sendMessage)];
//        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
//    }
//    return YES;
//}

#pragma mark - text View Delegate
- (BOOL)growingTextView:(SLGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    placeHold.hidden = growingTextView.text.length + text.length >0;
    if (self.textEditingBlock && self.isNeedBlock) {
        self.textEditingBlock();
    }
    if([text isEqualToString:@"@"]){
        //通知跳转到 @界面
        if (self.inputAiTe) {
            self.inputAiTe();
        }
        
    }
    if(![growingTextView hasText] && [text isEqualToString:@""]) {
        return NO;
    }
    //当不是选择的表情时
    if (!self.emojiBtn.selected) {
        if ([text isEqualToString:@"\n"]) {
            [self sendMessage];
            return NO;
        }
    }
    return YES;
}

- (void)growingTextView:(SLGrowingTextView *)growingTextView shouldChangeHeight:(CGFloat)height{
    CGRect frame = self.TextViewInput.frame;
    //
    frame.size.height = height;
    [UIView animateWithDuration:DURTAION animations:^{
        self.TextViewInput.frame = frame;
//        [self topLayoutSubiewWithH:(frame.size.height+ICON_TOP*2)];
        [self topLayoutSubViewWithH:(frame.size.height+ICON_TOP*2 + bottomViewHeight)];
        
        if (height > 40) {
            //对变化后的TextViewInput进行重新裁剪
            UIBezierPath *maskPathh = [UIBezierPath bezierPathWithRoundedRect:self.TextViewInput.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight| UIRectCornerBottomLeft cornerRadii:CGSizeMake(3, 3)];
            CAShapeLayer *maskLayerr = [[CAShapeLayer alloc] init];
            maskLayerr.frame = self.TextViewInput.bounds;
            maskLayerr.path = maskPathh.CGPath;
            self.TextViewInput.layer.mask = maskLayerr;
        }else{
            UIBezierPath *maskPathh = [UIBezierPath bezierPathWithRoundedRect:self.TextViewInput.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(3, 3)];
            CAShapeLayer *maskLayerr = [[CAShapeLayer alloc] init];
            maskLayerr.frame = self.TextViewInput.bounds;
            maskLayerr.path = maskPathh.CGPath;
            self.TextViewInput.layer.mask = maskLayerr;
        }
    }];
}

- (void)growingTextViewDidBeginEditing:(SLGrowingTextView *)growingTextView{
    
//    if (kTabBarHeight > 49) {
//        CGFloat VCWidth = Main_Screen_Width;
//        CGFloat VCHeight = Main_Screen_Height;
//        CGRect frame = CGRectMake(0, VCHeight-keyboardHeight - kTopHeight, VCWidth, keyboardHeight + bottomViewHeight);
//        self.frame = frame;
//    }
    
    //当点击输入框时候
    //更多按钮选中为no
    self.btnSendMessage.selected = NO;
    //表情按钮选中为no
    self.emojiBtn.selected = NO;
    //有功能菜单收起来
    self.moreView.scrollView.hidden = YES;
    //更多按钮设置为no
    self.btnSendMessage.selected = NO;
    //移除表情view
//    [self.emojiView removeFromSuperview];
    self.addFaceView.hidden = YES;
    self.emotionKeyboard.hidden = YES;
    //传出编辑事件
    if (self.textEditBlock) {
        self.textEditBlock(); //需要穿一个type
    }
    if (self.TextViewInput.text.length>0)
        placeHold.hidden = YES;
    else
        placeHold.hidden = NO;
}

- (void)growingTextViewDidEndEditing:(SLGrowingTextView *)growingTextView{
    
//    if (kTabBarHeight > 49) {
//        CGFloat VCWidth = Main_Screen_Width;
//        CGFloat VCHeight = Main_Screen_Height;
//        CGRect frame = CGRectMake(0, VCHeight-keyboardHeight - kTopHeight - kTabbarMoreHeight, VCWidth, keyboardHeight + bottomViewHeight);
//        self.frame = frame;
//    }
    
    if (self.textEndEditBlock && self.isNeedBlock) {
        self.textEndEditBlock();
    }
    if (self.TextViewInput.text.length>0)
        placeHold.hidden = YES;
    else
        placeHold.hidden = NO;
}

#pragma mark - other logic
- (void)topLayoutSubViewWithH:(CGFloat)hight{
    CGRect frame = self.frame;
    CGFloat diff = hight - frame.size.height;
    frame.size.height = hight ;
    self.frame = frame;
    
    frame = self.TextViewInput.frame;
    NSLog(@"%f",CGRectGetHeight(self.bounds));
    //输入框高度减去205
    frame.size.height = CGRectGetHeight(self.bounds) - bottomViewHeight - ICON_TOP*2;
    if (frame.size.height <= 35) {
        frame.size.height = 35;
    }
    self.TextViewInput.frame = frame;
    
    frame = self.frame;
    frame.origin.y = frame.origin.y - diff;
    
    [self duration:DURTAION EndF:frame Options:UIViewAnimationOptionCurveLinear];
}

- (void)duration:(CGFloat)duration EndF:(CGRect)endF Options:(UIViewAnimationOptions)options{
    
    [UIView animateWithDuration:duration delay:0.0f options:options animations:^{
        kb_resign = NO;
        self.frame = endF;
    } completion:^(BOOL finished) {
        
    }];
//    [self changeDuration:duration];
    
}

/**
 表情选择通知
 
 @param notifi notifi
 */
#pragma mark - 表情代理
-(void)faceDidSelected:(NSNotification *)notifi{
    SDFaceModel *faceModel =notifi.userInfo[SDSelectFaceKey];
    [self.TextViewInput.internalTextView insertText:faceModel.emoji];
    self.addFaceView.faceToolBar.sendBtn.selected = self.TextViewInput.text.length>0;
    
    [self.TextViewInput.internalTextView scrollRangeToVisible:NSMakeRange(self.TextViewInput.text.length, 0)];
    placeHold.hidden = self.TextViewInput.text.length>0;
}
/**
 删除表情通知
 
 */
-(void)deleteBtnClicked{
    [self.TextViewInput.internalTextView deleteBackward];
//    placeHold.hidden = self.TextViewInput.text.length>0;
    self.addFaceView.faceToolBar.sendBtn.selected = self.TextViewInput.text.length>0;
}


#pragma mark - 发送表情
- (void)emojiViewSend{
    
    NSLog(@"currentChatId = %@",[NFUserEntity shareInstance].currentChatId);
    NSLog(@"isSingleChat = %@",[NFUserEntity shareInstance].isSingleChat);
    NSLog(@"self.delegate = %@",self.delegate);
    const char *groupClassName = [@"GroupChatViewController" cStringUsingEncoding:NSASCIIStringEncoding];
    // 从一个字串返回一个类
    Class groupClass = objc_getClass(groupClassName);
    const char *singleClassName = [@"MessageChatViewController" cStringUsingEncoding:NSASCIIStringEncoding];
    // 从一个字串返回一个类
    Class singleClass = objc_getClass(singleClassName);
    if([[NFUserEntity shareInstance].isSingleChat isEqualToString:@"2"] && [self.delegate isKindOfClass:[groupClass class]]){
        [self sendMessage];
        //点击发送按钮后 发送按钮为不可点 【因为输入框文字被清空了】
        self.addFaceView.faceToolBar.sendBtn.selected = NO;
    }else if ([[NFUserEntity shareInstance].isSingleChat isEqualToString:@"1"] && [self.delegate isKindOfClass:[singleClass class]]){
        [self sendMessage];
        //点击发送按钮后 发送按钮为不可点 【因为输入框文字被清空了】
        self.addFaceView.faceToolBar.sendBtn.selected = NO;
    }else{
        //self.destorySelfff();
        //self.delegate = nil;
        NSLog(@"self.delegate = %@",self.delegate);
    }
    
}

#pragma mark - Add Picture 废弃
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self addCarema];
    }else if (buttonIndex == 1){
        [self openPicLibrary];
    }
    
}

-(void)addCarema{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        if (@available(iOS 13.0, *)) {
            picker.modalPresentationStyle =UIModalPresentationFullScreen;
        }
        [self.superVC presentViewController:picker animated:YES completion:^{}];
    }else{
        //如果没有提示用户
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tip" message:@"Your device don't have camera" delegate:nil cancelButtonTitle:@"Sure" otherButtonTitles:nil];
        [alert show];
    }
}

//废弃
-(void)openPicLibrary{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        
//        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        if (@available(iOS 13.0, *)) {
            picker.modalPresentationStyle =UIModalPresentationFullScreen;
        }
        [self.superVC presentViewController:picker animated:YES completion:^{
        }];
    }
}


#pragma mark - TZImagePickerController 跳转到相册
- (void)pushTZImagePickerController {
    NSInteger maxCount = 1;
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:maxCount columnNumber:3 delegate:self pushPhotoPickerVc:YES];
    
    imagePickerVc.doneBtnTitleStr = @"完成";
    imagePickerVc.cancelBtnTitleStr = @"取消";
    imagePickerVc.previewBtnTitleStr = @"预览";
    imagePickerVc.fullImageBtnTitleStr = @"原图";
    //    imagePickerVc.settingBtnTitleStr = @"Setting";
    imagePickerVc.processHintStr = @"加载中...";
    
    //是否允许选取原始照片
    imagePickerVc.isSelectOriginalPhoto = NO;
    if (maxCount > 1) {
        // 1.设置目前已经选中的图片数组
//        imagePickerVc.selectedAssets = _selectedAssets; // 目前已经选中的图片数组
    }
    imagePickerVc.allowTakePicture = NO; // 在内部显示拍照按钮
    // imagePickerVc.photoWidth = 1000;
    
    // 2. Set the appearance
    // 2. 在这里设置imagePickerVc的外观
     imagePickerVc.navigationBar.barTintColor = [UIColor colorThemeColor];
     imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
     imagePickerVc.oKButtonTitleColorNormal = [UIColor whiteColor];
     imagePickerVc.navigationBar.translucent = NO;
    
    //    imagePickerVc.allowPickingVideo = self.allowPickingVideoSwitch.isOn;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = YES;
    //    imagePickerVc.allowPickingGif = self.allowPickingGifSwitch.isOn;
    //    imagePickerVc.allowPickingMultipleVideo = self.allowPickingMuitlpleVideoSwitch.isOn; // 是否可以多选视频
    // 4. 照片排列按修改时间升序
    imagePickerVc.sortAscendingByModificationDate = YES;
    
    // imagePickerVc.minImagesCount = 3;
    // imagePickerVc.alwaysEnableDoneBtn = YES;
    // imagePickerVc.minPhotoWidthSelectable = 3000;
    // imagePickerVc.minPhotoHeightSelectable = 2000;
    
    imagePickerVc.showSelectBtn = NO;
    imagePickerVc.allowCrop = NO; //允许裁剪
    imagePickerVc.needCircleCrop = NO; //圆形裁剪框
    // 设置竖屏下的裁剪尺寸
    NSInteger left = 30;
    NSInteger widthHeight = SCREEN_WIDTH - 2 * left;
    NSInteger top = (SCREEN_HEIGHT - widthHeight) / 2;
    imagePickerVc.cropRect = CGRectMake(left, top, widthHeight, widthHeight);
    // 设置横屏下的裁剪尺寸
//     imagePickerVc.cropRectLandscape = CGRectMake((self.view.tz_height - widthHeight) / 2, left, widthHeight, widthHeight);
    // 设置竖屏下的裁剪尺寸
    imagePickerVc.cropRectPortrait = CGRectMake((SCREEN_HEIGHT - widthHeight) / 2, left, widthHeight, widthHeight);
    
    //imagePickerVc.allowPreview = NO;
    // 自定义导航栏上的返回按钮
    /*
     [imagePickerVc setNavLeftBarButtonSettingBlock:^(UIButton *leftButton){
     [leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
     [leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 20)];
     }];
     imagePickerVc.delegate = self;
     */
    imagePickerVc.isStatusBarDefault = NO;
    //传出选中图片数组 也可在下面代理中
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        NSLog(@"");
    }];
    if (@available(iOS 13.0, *)) {
        imagePickerVc.modalPresentationStyle =UIModalPresentationFullScreen;
    }
    [self.superVC presentViewController:imagePickerVc animated:YES completion:nil];
    
}


#pragma mark - TZImagePickerControllerDelegate
/// User click cancel button
/// 用户点击了取消
- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    // NSLog(@"cancel");
}

// The picker should dismiss itself; when it dismissed these handle will be called.
// If isOriginalPhoto is YES, user picked the original photo.
// You can get original photo with asset, by the method [[TZImageManager manager] getOriginalPhotoWithAsset:completion:].
// The UIImage Object in photos default width is 828px, you can set it by photoWidth property.
// 这个照片选择器会自己dismiss，当选择器dismiss的时候，会执行下面的代理方法
// 如果isSelectOriginalPhoto为YES，表明用户选择了原图
// 你可以通过一个asset获得原图，通过这个方法：[[TZImageManager manager] getOriginalPhotoWithAsset:completion:]
// photos数组里的UIImage对象，默认是828像素宽，你可以通过设置photoWidth属性的值来改变它
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    BOOL rett = isSelectOriginalPhoto; //是否选中了原图
    UIImage *editImage = [photos firstObject];
    BOOL ret = [SVProgressHUD isVisible];
    if (!ret) {
        [SVProgressHUD showWithStatus:@"发送中..."];
        //NSLog(@"%ld",editImage.imageOrientation);
        [self.delegate UUInputFunctionView:self sendPicture:editImage IsselectedOrginalImage:isSelectOriginalPhoto];
    }
    
    // 1.打印图片名字
    [self printAssetsName:assets];
    // 2.图片位置信息
    //    if (iOS8Later) {
    //        for (PHAsset *phAsset in assets) {
    //            NSLog(@"location:%@",phAsset.location);
    //        }
    //    }
}

//废弃
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *editImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    BOOL ret = [SVProgressHUD isVisible];
    if (!ret) {
        [SVProgressHUD showWithStatus:@"发送中..."];
        [self.superVC dismissViewControllerAnimated:YES completion:^{
            //NSLog(@"%ld",editImage.imageOrientation);
            
            [self.delegate UUInputFunctionView:self sendPicture:editImage IsselectedOrginalImage:NO];
        }];
    }
}

//照相相关代理
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.superVC dismissViewControllerAnimated:YES completion:nil];
}

//- (EmotionKeyboard *)emotionKeyboard{
//    if (!_emotionKeyboard) {
//        _emotionKeyboard = [[EmotionKeyboard alloc]init];
//        _emotionKeyboard.delegate = self;
//    }
//    return _emotionKeyboard;
//}

#pragma mark - 表情相关 delegate
//点击了系统表情
-(void)emoticonInputDidTapText:(NSString *)text{
    [self.TextViewInput.internalTextView insertText:text];
}
//点击了收藏图片
-(void)emoticonCollectImageDidTapUrl:(NSString *)url{
    
    if (!hasLiked) {//如果为NO 则提示频率过快
        [SVProgressHUD showInfoWithStatus:@"发送频率过快!"];
        return;
    }
    hasLiked = NO;//发送后 设置为NO 。
    //hasLiked
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        hasLiked = YES; //弹框完成后延时0.5秒在设置
    });
    
    NSArray *arr = [url componentsSeparatedByString:@"CollectImage/"];
    NSString *picpath = [NSString new];
    NSString *pictureScale = [NSString new];
    NSString *fileID = [NSString new];
    if (arr.count == 2) {
        picpath = [arr lastObject];
        //1.2#2020-03-20@5e7456505e5be.jpeg
        NSArray *ARR = [picpath componentsSeparatedByString:@"#"];
        if(ARR.count == 3){
            pictureScale = [ARR firstObject];
            fileID = ARR[1];
            picpath = [ARR lastObject];
        }
        picpath = [ARR lastObject];
        fileID = [ARR firstObject];
        if(ARR.count != 3){
            pictureScale = @"1";
            fileID = @"";
        }
        picpath = [picpath stringByReplacingOccurrencesOfString:@"@" withString:@"/"];
        picpath = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,picpath];
    }
    if (self.delegate) {
        [self.delegate UUInputFunctionView:self sendPictureDict:@{@"picpath":picpath,@"fileId":fileID,@"scale":pictureScale}];
    }
    
}
//点击了魔法表情
-(void)emoticonMagicEmotionDidTapText:(NSString *)text{
    NSLog(@"");
}
//点击了删除按键
-(void)emoticonInputDidTapBackspace{
    [self.TextViewInput.internalTextView deleteBackward];
}
//点击了发送
-(void)emoticonInputDidTapSend{
    [self emojiViewSend];
}

#pragma mark - Private
/// 打印图片名字
- (void)printAssetsName:(NSArray *)assets {
    NSString *fileName;
    for (id asset in assets) {
        if ([asset isKindOfClass:[PHAsset class]]) {
            PHAsset *phAsset = (PHAsset *)asset;
            fileName = [phAsset valueForKey:@"filename"];
        } else if ([asset isKindOfClass:[ALAsset class]]) {
            ALAsset *alAsset = (ALAsset *)asset;
            fileName = alAsset.defaultRepresentation.filename;;
        }
        NSLog(@"图片名字:%@",fileName);
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SDFaceDidSendNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SDFaceDidDeleteNotification object:nil];
    
    self.moreView.delegate = nil;
    self.emotionKeyboard.delegate = nil;
}

-(void)deallocMySelf{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SDFaceDidSendNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SDFaceDidDeleteNotification object:nil];

    self.moreView.delegate = nil;
    self.emotionKeyboard.delegate = nil;
    
    
    
    
}

-(void)AddNotification{
    //添加通知
    [self deallocMySelf];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDidShowOrHide:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(faceDidSelected:) name:SDFaceDidSelectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteBtnClicked) name:SDFaceDidDeleteNotification object:nil];
}

@end
