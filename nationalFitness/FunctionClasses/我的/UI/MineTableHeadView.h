//
//  MineTableHeadView.h
//  nationalFitness
//
//  Created by Joe on 2017/8/26.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NFHeadImageView.h"


@interface MineTableHeadView : UIView

//头像
@property (weak, nonatomic) IBOutlet NFHeadImageView *headImageView;


//昵称
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
//昵称宽度约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nickNameWidthConstaint;

//个性签名
@property (weak, nonatomic) IBOutlet UILabel *signLabel;
//个性签名 宽度约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signWidthConstaint;



//点击手势
@property (weak, nonatomic) IBOutlet UITapGestureRecognizer *tapGestureClick;

//波浪view
@property (weak, nonatomic) IBOutlet UIView *waveView;






@end

