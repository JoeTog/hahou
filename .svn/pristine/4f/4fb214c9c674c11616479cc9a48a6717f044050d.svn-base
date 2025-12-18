//
//  NFAdvertScrollView.h
//  nationalFitness
//
//  Created by 程long on 14-11-5.
//  Copyright (c) 2014年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NFAdvertScrollViewDelegate <NSObject>

@optional

- (void)showLabelWith:(NSInteger)page;

@end


@interface NFAdvertScrollView : UIScrollView<UIScrollViewDelegate>

// 当前页数
@property (nonatomic, readonly) NSUInteger currentPage;

@property (nonatomic, assign)id<NFAdvertScrollViewDelegate>myDelegate;

/**
 *  直接显示多个焦点图
 *
 *  @param picUrlArr 焦点图的URL数组
 */
-(void)setImageArr:(NSArray *)picUrlArr;




@end
