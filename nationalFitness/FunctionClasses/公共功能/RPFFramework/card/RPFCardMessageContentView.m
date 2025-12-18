//
//  RPFCardMessageContentView.m
//  NIM
//
//  Created by King on 2019/3/6.
//  Copyright © 2019年 Netease. All rights reserved.
//

#import "RPFCardMessageContentView.h"
#import "RPFCardAttachment.h"
#import "UIImageView+WebCache.h"

NSString *const NIMDemoEventNameOpenCard = @"NIMDemoEventNameOpenCard";


@interface RPFCardMessageContentView()

@property (nonatomic, strong) UIImageView *iconImgView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *userIdLabel;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UITapGestureRecognizer *tap;


@end

@implementation RPFCardMessageContentView

- (instancetype)initSessionMessageContentView{
//    self = [super initSessionMessageContentView];
    if (self) {
        // 内容布局
        _iconImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_iconImgView.layer setCornerRadius:5.0];
        [_iconImgView.layer setMasksToBounds:YES];
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.font = [UIFont systemFontOfSize:18.f];
        
        _userIdLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _userIdLabel.font = [UIFont systemFontOfSize:13.f];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:12.f];
        
        [self addSubview:_iconImgView];
        [self addSubview:_nameLabel];
        [self addSubview:_userIdLabel];
        [self addSubview:_titleLabel];
        
        
    }
    return self;
}


- (void)onTouchUpInside:(id)sender
{
//    if ([self.delegate respondsToSelector:@selector(onCatchEvent:)])
//    {
//        NIMKitEvent *event = [[NIMKitEvent alloc] init];
//        event.eventName = NIMDemoEventNameOpenCard;
//        event.messageModel = self.model;
//        event.data = self;
//        [self.delegate onCatchEvent:event];
//    }
}

#pragma mark - 系统父类方法
//- (void)refresh:(NIMMessageModel*)data{
- (void)refresh:(NSString*)data{
//    [super refresh:data];
    
//    NIMCustomObject *object = data.message.messageObject;
    
//    RPFCardAttachment *attachment = (RPFCardAttachment *)object.attachment;
    RPFCardAttachment *attachment ;
    
    [self.iconImgView sd_setImageWithURL:[[NSURL alloc] initWithString:attachment.iconUrl?attachment.iconUrl:@""] placeholderImage:[UIImage imageNamed:@"avatar_user"]];

    self.nameLabel.text = attachment.name;
    self.nameLabel.textColor    =  [UIColor blackColor];
    [self.nameLabel sizeToFit];
    
    self.userIdLabel.text = attachment.cardId;
    self.userIdLabel.textColor    =  [UIColor lightGrayColor];
    [self.userIdLabel sizeToFit];

    self.titleLabel.text = attachment.title;
    self.titleLabel.textColor    =  [UIColor lightGrayColor];
    [self.titleLabel sizeToFit];
    
    
    CGRect rect = self.titleLabel.frame;
    
    if (CGRectGetMaxX(rect) > self.bounds.size.width)
    {
        rect.size.width = self.bounds.size.width - rect.origin.x - 20;
        self.titleLabel.frame = rect;
    }
    
    //self.subTitleLabel.text = self.model.message.isOutgoingMsg? @"查看红包" : @"领取红包";
}

- (void)layoutSubviews
{
    [super layoutSubviews];
//    BOOL outgoing = self.model.message.isOutgoingMsg;
    float xSpace = 30.0;
    BOOL outgoing;
    if (outgoing)
    {
        self.nameLabel.frame = CGRectMake(xSpace+31.f+12.f, 15.f, 160.f, 24.f);
        self.userIdLabel.frame = CGRectMake(xSpace+31.f+12.f, 39.f, 150.f, 20.f);
        self.titleLabel.frame = CGRectMake(7.0f, 93.f-18.f, 180.f, 21.f);
    }
    else
    {
        self.nameLabel.frame = CGRectMake(xSpace+31.f+12.f, 15.f, 160.f, 24.f);
        self.userIdLabel.frame = CGRectMake(xSpace+31.f+12.f, 39.f, 150.f, 20.f);
        self.titleLabel.frame = CGRectMake(14.f, 93.f-18.f, 180.f, 21.f);
    }
    
    self.iconImgView.frame = CGRectMake(15.0, 15.0, 45.0, 45.0);

}

- (UIImage *)chatBubbleImageForState:(UIControlState)state outgoing:(BOOL)outgoing
{
    NSString *stateString = state == UIControlStateNormal? @"normal" : @"pressed";
    NSString *imageName = @"icon_card_";
    if (outgoing)
    {
        imageName = [imageName stringByAppendingString:@"from_"];
    }
    else
    {
        imageName = [imageName stringByAppendingString:@"to_"];
    }
    imageName = [imageName stringByAppendingString:stateString];
    return [UIImage imageNamed:imageName];
    
}


@end
