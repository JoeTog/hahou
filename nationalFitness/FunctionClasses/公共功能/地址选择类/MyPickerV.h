//
//  MyPickerV.h
//  地址选择代码块封装
//
//  Created by 童杰 on 2016/12/16.
//  Copyright © 2016年 童杰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyPickerV : UIView<UIPickerViewDelegate,UIPickerViewDataSource>


@property(nonatomic,strong)void(^failed)(NSError *);
@property(nonatomic,strong)void(^success)(NSString *);

-(instancetype)initWithFrame:(CGRect)frame firstComponentW:(CGFloat)Weight secondComponentW:(CGFloat)SWeight thirdComponentW:(CGFloat)TWeight cancelBlock:(void (^)(NSError *error))cancelBlock sureBlock:(void(^)(NSString *areaString))sureBlock;





@end
