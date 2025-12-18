//
//  ContantTableViewCell.m
//  nationalFitness
//
//  Created by Joe on 2017/6/30.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "ContantTableViewCell.h"
#import "NFMineEntity.h"
#import "NFbaseViewController.h"
#import "UIColor+RYChat.h"
#import "UIFont+RYChat.h"

@implementation ContantTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    ViewRadius(self.badgeCountLabel, 7);
    
    self.badgeCountView.hidden = YES;
    self.timeLabel.hidden = YES;
    
    self.agreeBtn.hidden = YES;
    
//    CacheKeepBoxEntity *entityy = [[NFbaseViewController new] getAllCacheDataEntity];
//    //图片名字
//    NSString *backGroundImageName = [NSString new];
//    if (entityy.themeSelectedIndex == 0) {
//        backGroundImageName = @"底";
//    }else if (entityy.themeSelectedIndex == 1){
//        backGroundImageName = @"";
//    }
    
//        NSURL *icon1URL = [NSURL URLWithString:@"http://upload-images.jianshu.io/upload_images/3816723-e182f6da029b3e7d.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/100"] ;
//        NSURL *icon2URL = [NSURL URLWithString:@"http://upload-images.jianshu.io/upload_images/3816723-023e66be11a2e94b.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/100"];
//        NSURL *icon3URL = [NSURL URLWithString:@"http://upload-images.jianshu.io/upload_images/3816723-d7ece9dba73d4953.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/100"] ;
//        NSURL *icon4URL = [NSURL URLWithString:@"http://upload-images.jianshu.io/upload_images/3816723-e08bf975aadbfdd4.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/100"] ;
//        NSURL *icon5URL = [NSURL URLWithString:@"http://upload-images.jianshu.io/upload_images/3816723-13271b280c0e5fd4.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/100"] ;
//        NSArray *iconItemsArr = @[icon1URL,icon2URL,icon3URL,icon4URL,icon5URL];
//        self.headImageView.image = [UIImage groupIconWithURLArray:iconItemsArr bgColor:[UIColor groupTableViewBackgroundColor]];
    
    self.nameLabel.textColor = [UIColor colorMainTextColor];
    self.statusLabel.textColor = [UIColor colorMainThirdTextColor];
    self.timeLabel.textColor = [UIColor colorMainSecTextColor];
    
    //ViewRadius(self.headImageView, self.headImageView.frame.size.width/2);
//    ViewRadius(self.headImageView, 3);
    self.nameLabel.font = [UIFont fontMainText];
    
}

-(void)layoutSubviews
{
    
    for (UIControl *control in self.subviews){
        if ([control isMemberOfClass:NSClassFromString(@"UITableViewCellEditControl")]){
            for (UIView *view in control.subviews)
            {
                if ([view isKindOfClass: [UIImageView class]]) {
                    UIImageView *image=(UIImageView *)view;
                    if (self.selected) {
                        image.image=[UIImage imageNamed:@"CellButtonSelected"];
                    }
                    else
                    {
                        image.image=[UIImage imageNamed:@"CellButton"];
                    }
                }
            }
        }
    }
    
    [super layoutSubviews];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    for (UIControl *control in self.subviews){
        if ([control isMemberOfClass:NSClassFromString(@"UITableViewCellEditControl")]){
            for (UIView *view in control.subviews)
            {
                if ([view isKindOfClass: [UIImageView class]]) {
                    UIImageView *image=(UIImageView *)view;
                    if (!self.selected) {
                        image.image=[UIImage imageNamed:@"CellButton"];
                    }
                }
            }
        }
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
