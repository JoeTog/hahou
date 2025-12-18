//
//  PickerViewChose.h
//  JoeUIPickView01
//
//  Created by 童杰 on 2017/4/13.
//  Copyright © 2017年 tong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Masonry.h"
#import "UIColor+RYChat.h"

@interface PickerViewChose : UIView<UIPickerViewDataSource,UIPickerViewDelegate,UIScrollViewDelegate>

//共给承接下面的代码块
@property(nonatomic,strong)void(^ReturnEveryRowBlock)(BOOL isSure,NSInteger firstRow,NSInteger secondRow,NSInteger thirdRow,NSInteger forthRow);

-(instancetype)initWithFrame:(CGRect)frame FirstCompontArr:(NSArray *)fisrt SecondCompont:(NSArray *)second ThirdCompont:(NSArray *)third forthCompont:(NSArray *)forth rowHeight:(CGFloat)height  ReturnEveryRowBlock:(void(^)(BOOL isSure,NSInteger firstRow,NSInteger secondRow,NSInteger thirdRow,NSInteger forthRow))Block;

//默认为no
@property(nonatomic)BOOL isNeedTitleTool;

//设置背景图片
-(void)setBackImageView:(NSString *)picName;

@end
