//
//  headCollectionReusableView.m
//  爱尚电影
//
//  Created by bwfstu on 16/6/7.
//  Copyright © 2016年 Joe. All rights reserved.
//

#import "headCollectionReusableView.h"

@implementation headCollectionReusableView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 10)];
        [self addSubview:_titleLable];
    }
    return self;
}









@end
