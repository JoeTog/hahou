//
//  areaObject.h
//  地址选择代码块封装
//
//  Created by 童杰 on 2016/12/16.
//  Copyright © 2016年 童杰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface areaObject : NSObject
//区域
@property (copy, nonatomic) NSString *region;
//省名
@property (copy, nonatomic) NSString *province;
//城市名
@property (copy, nonatomic) NSString *city;
//区县名
@property (copy, nonatomic) NSString *area;
@end
