//
//  UUMessageContentButton.m
//  BloodSugarForDoc
//
//  Created by shake on 14-8-27.
//  Copyright (c) 2014年 shake. All rights reserved.
//

#import "UUMessageContentButton.h"
@implementation UUMessageContentButton

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        //图片
//        self.backImageView = [[UIImageView alloc]init];
        self.backImageView = [[NFShowImageView alloc]init];
//        self.backImageView.userInteractionEnabled = YES;
//        self.backImageView.layer.cornerRadius = 5;
        self.backImageView.layer.masksToBounds  = YES;
//        self.backImageView.backgroundColor = [UIColor yellowColor];
        self.backImageView.backgroundColor = UIColorFromRGB(0xebebeb);
        self.backImageView.image = [UIImage imageNamed:@"正在加载图片"];
//        self.backImageView.frame = CGRectMake(5, 5, self.frame.size.width - 10, self.frame.size.height - 10);
        [self addSubview:self.backImageView];
        
        //语音
        self.voiceBackView = [[UIView alloc]init];
        [self addSubview:self.voiceBackView];
        //崩溃
        self.second = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 45, 30)];
        self.second.textAlignment = NSTextAlignmentCenter;
        self.second.font = [UIFont systemFontOfSize:14];
        self.voice = [[UIImageView alloc]initWithFrame:CGRectMake(55, 5, 14, 20)];
        self.voice.image = [UIImage imageNamed:@"chat_animation_white3"];
        self.voice.animationImages = [NSArray arrayWithObjects:
                                      [UIImage imageNamed:@"chat_animation_white1"],
                                      [UIImage imageNamed:@"chat_animation_white2"],
                                      [UIImage imageNamed:@"chat_animation_white3"],nil];
        self.voice.animationDuration = 1;
        self.voice.animationRepeatCount = 0;
        
//        if (self.isMyMessage) {
        //崩溃

        self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//        }else{
//            self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//        }

        self.indicator.center=CGPointMake(80, 15);
        [self.voiceBackView addSubview:self.indicator];
        [self.voiceBackView addSubview:self.voice];
        [self.voiceBackView addSubview:self.second];
        
        self.backImageView.userInteractionEnabled = NO;
        self.voiceBackView.userInteractionEnabled = NO;
        self.second.userInteractionEnabled = NO;
        self.voice.userInteractionEnabled = NO;
        
        self.second.backgroundColor = [UIColor clearColor];
        self.voice.backgroundColor = [UIColor clearColor];
        self.voiceBackView.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //图片
//        self.backImageView = [[UIImageView alloc]init];
        self.backImageView = [[NFShowImageView alloc]init];
//        self.backImageView.userInteractionEnabled = YES;
//        self.backImageView.layer.cornerRadius = 5;
//        self.backImageView.layer.masksToBounds  = YES;
//        self.backImageView.backgroundColor = [UIColor yellowColor];
        self.backImageView.backgroundColor = UIColorFromRGB(0xebebeb);
        self.backImageView.image = [UIImage imageNamed:@"正在加载图片"];
        [self addSubview:self.backImageView];
        
        //语音
        self.voiceBackView = [[UIView alloc]init];
        [self addSubview:self.voiceBackView];
        self.second = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 70, 30)];
        self.second.textAlignment = NSTextAlignmentCenter;
        self.second.font = [UIFont systemFontOfSize:14];
        self.voice = [[UIImageView alloc]initWithFrame:CGRectMake(80, 5, 20, 20)];
        self.voice.image = [UIImage imageNamed:@"chat_animation_white3"];
        self.voice.animationImages = [NSArray arrayWithObjects:
                                      [UIImage imageNamed:@"chat_animation_white1"],
                                      [UIImage imageNamed:@"chat_animation_white2"],
                                      [UIImage imageNamed:@"chat_animation_white3"],nil];
        self.voice.animationDuration = 1;
        self.voice.animationRepeatCount = 0;
        self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.indicator.center=CGPointMake(80, 15);
        [self.voiceBackView addSubview:self.indicator];
        [self.voiceBackView addSubview:self.voice];
        [self.voiceBackView addSubview:self.second];
        
        self.backImageView.userInteractionEnabled = NO;
        self.voiceBackView.userInteractionEnabled = NO;
        self.second.userInteractionEnabled = NO;
        self.voice.userInteractionEnabled = NO;
        
        self.second.backgroundColor = [UIColor clearColor];
        self.voice.backgroundColor = [UIColor clearColor];
        self.voiceBackView.backgroundColor = [UIColor clearColor];
        
        //self.second.textColor = UIColorFromRGB(0x435a8e);
        
        
    }
    return self;
}
- (void)benginLoadVoice
{
    self.voice.hidden = YES;
    [self.indicator startAnimating];
}
- (void)didLoadVoice
{
    self.voice.hidden = NO;
    [self.indicator stopAnimating];
    [self.voice startAnimating];
}
-(void)stopPlay
{
//    if(self.voice.isAnimating){
        [self.voice stopAnimating];
//    }
}

- (void)setIsMyMessage:(BOOL)isMyMessage
{
    _isMyMessage = isMyMessage;
    if (isMyMessage) {
        //图片
        //崩溃
        self.backImageView.frame = CGRectMake(5, 5, 210, 207);
//        self.backImageView.frame = CGRectMake(0, 0, 220, 217);
        //崩溃
        //语音背景
        self.voiceBackView.frame = CGRectMake(15, 5, 85, 35);
        //语音文字
        //self.second.textColor = [UIColor whiteColor];
        self.second.textColor = UIColorFromRGB(0x435a8e);
        
        self.voice.image = [UIImage imageNamed:@"语音向左深灰色"];
        self.voice.animationImages = [NSArray arrayWithObjects:
                                      [UIImage imageNamed:@"语音向左浅灰色1"],
                                      [UIImage imageNamed:@"语音向左浅灰色2"],
                                      [UIImage imageNamed:@"语音向左浅灰色3"],nil];
        
    }else{
        //图片
        self.backImageView.frame = CGRectMake(10, 5, 210, 207);
//        self.backImageView.frame = CGRectMake(6, 0, 220, 217);
//        self.backImageView.frame = CGRectMake(0, 0, 205, 207);
        
//        self.voiceBackView.frame = CGRectMake(15, 10, 130, 35);
        self.voiceBackView.frame = CGRectMake(20, 5, 85, 35);
        //self.second.textColor = [UIColor grayColor];
        self.second.textColor = UIColorFromRGB(0x435a8e);
        
        
        self.voice.image = [UIImage imageNamed:@"语音向右深灰色"];
        self.voice.animationImages = [NSArray arrayWithObjects:
                                      [UIImage imageNamed:@"语音向右浅灰色1"],
                                      [UIImage imageNamed:@"语音向右浅灰色2"],
                                      [UIImage imageNamed:@"语音向右浅灰色3"],nil];
        
    }
    
}

//添加
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (action == @selector(myCopy:) || action == @selector(myForward:) || action == @selector(myDelete:) || action == @selector(myWithDrow:) || action == @selector(moreEdit:) || action == @selector(savePic:)) {
        return YES;
    }
    return NO;
    return (action == @selector(copy:));
}
//系统的不用
-(void)copy:(id)sender{
    if (!self.titleLabel.text) return;
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = self.titleLabel.text;
}

-(void)myCopy:(id)sender{
    if (!self.titleLabel.text) return;
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = self.titleLabel.text;
    
    
    
}
-(void)myForward:(id)sender{
    if (self.forwardBlock) {
        self.forwardBlock();
    }
    
}

-(void)myDelete:(id)sender{
    if (self.DeleteBlock) {
        self.DeleteBlock();
    }
}
-(void)myWithDrow:(id)sender{
    if (self.drowBlock) {
        self.drowBlock();
    }
    
}
//moreEdit
-(void)moreEdit:(id)sender{
    if (self.moreBlock) {
        self.moreBlock();
    }
    
}

-(void)savePic:(id)sender{
    if (self.saveBlock) {
        self.saveBlock();
    }
    
}


-(void)returnSaveBlock:(ReturnSaveBlock)block{
    if (self.saveBlock != block) {
        self.saveBlock = block;
    }
}

-(void)returnDeleteBlock:(ReturnDeleteBlock)block{
    if (self.DeleteBlock != block) {
        self.DeleteBlock = block;
    }
}
-(void)returnForwardBlock:(ReturnForwardBlock)block{
    if (self.forwardBlock != block) {
        self.forwardBlock = block;
    }
}
-(void)returnmyWithDrowBlock:(ReturnmyWithDrowBlock)block{
    if (self.drowBlock != block) {
        self.drowBlock = block;
    }
}

-(void)returnCopyBlock:(ReturnCopyBlock)block{
    if (self.copyBlock != block) {
        self.copyBlock = block;
    }
}

-(void)returnMoreEditBlock:(ReturnMoreEditBlock)block{
    if (self.moreBlock != block) {
        self.moreBlock = block;
    }
}



@end
