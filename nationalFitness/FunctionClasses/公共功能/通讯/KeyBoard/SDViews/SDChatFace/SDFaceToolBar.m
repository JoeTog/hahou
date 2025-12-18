//
//  SDFaceToolBar.m
//  SDChat
//
//  Created by Megatron Joker on 2017/6/1.
//  Copyright © 2017年 SlowDony. All rights reserved.
//

#import "SDFaceToolBar.h"

@interface SDFaceToolBar ()



@end
@implementation SDFaceToolBar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //1.添加发送按钮
        //
        UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        sendBtn.backgroundColor=UIColorFromRGB(0x157efb);
        [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        sendBtn.titleLabel.font =[UIFont systemFontOfSize:15];
        [sendBtn  addTarget:self action:@selector(senderBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview: sendBtn];
        [sendBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateSelected)];
        [sendBtn setBackgroundImage:[UIImage imageWithColor:TheColor_BlueColor] forState:UIControlStateSelected];
        
        [sendBtn setTitleColor:[UIColor lightGrayColor] forState:(UIControlStateNormal)];
        [sendBtn setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        
        self.sendBtn =sendBtn;
        
        //收藏按钮
        UIButton *collectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [collectBtn setTitle:@"收藏" forState:UIControlStateNormal];
        collectBtn.backgroundColor=UIColorFromRGB(0x157efb);
        [collectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        collectBtn.titleLabel.font =[UIFont systemFontOfSize:15];
        [collectBtn  addTarget:self action:@selector(collectClickBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview: collectBtn];
        [collectBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateSelected)];
        [collectBtn setBackgroundImage:[UIImage imageWithColor:TheColor_BlueColor] forState:UIControlStateSelected];
        [collectBtn setTitleColor:[UIColor lightGrayColor] forState:(UIControlStateNormal)];
        [collectBtn setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        self.collectBtn = collectBtn;
        
        //表情按钮
        UIButton *emoilBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [emoilBtn setTitle:@"表情" forState:UIControlStateNormal];
        emoilBtn.backgroundColor=UIColorFromRGB(0x157efb);
        [emoilBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        emoilBtn.titleLabel.font =[UIFont systemFontOfSize:15];
        [emoilBtn  addTarget:self action:@selector(emoilClickBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview: emoilBtn];
        [emoilBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateSelected)];
        [emoilBtn setBackgroundImage:[UIImage imageWithColor:TheColor_BlueColor] forState:UIControlStateSelected];
        [emoilBtn setTitleColor:[UIColor lightGrayColor] forState:(UIControlStateNormal)];
        [emoilBtn setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        self.emoilBtn = emoilBtn;
        
        
        
    }
    return self;
}

-(void)returnSend:(ReturnSendBlock)block{
    
    if (self.returnSendBlock != block) {
        self.returnSendBlock = block;
    }
    
}

-(void)returnCollectBlock:(ReturnCollectBlock)block{
    
    if (self.returnCollectBlock != block) {
        self.returnCollectBlock = block;
    }
    
}

-(void)returnEmoilBlock:(ReturnEmoilBlock)block{
    
    if (self.returnEmoilBlock != block) {
        self.returnEmoilBlock = block;
    }
    
}

-(void)layoutSubviews{
    [super layoutSubviews];
    //发送按钮
    self.sendBtn.width=50;
    self.sendBtn.height=self.height;
    self.sendBtn.x=SDDeviceWidth-50;
    //
    
    self.collectBtn.width=50;
    self.collectBtn.height=self.height;
    self.collectBtn.x=3;
    
    self.emoilBtn.width=50;
    self.emoilBtn.height=self.height;
    self.emoilBtn.x=3 + 50;
    
    
}
-(void)senderBtn:(UIButton *)sender{
    
    self.returnSendBlock();
    SDLog(@"发送");
    [[NSNotificationCenter defaultCenter] postNotificationName:SDFaceDidSendNotification object:nil];
    
}

-(void)collectClickBtn:(UIButton *)sender{
    
    self.returnCollectBlock();
    SDLog(@"收藏");
   // [[NSNotificationCenter defaultCenter] postNotificationName:SDFaceDidSendNotification object:nil];
    
}

-(void)emoilClickBtn:(UIButton *)sender{
    
    self.returnEmoilBlock();
    SDLog(@"表情");
   // [[NSNotificationCenter defaultCenter] postNotificationName:SDFaceDidSendNotification object:nil];
    
}



















@end
