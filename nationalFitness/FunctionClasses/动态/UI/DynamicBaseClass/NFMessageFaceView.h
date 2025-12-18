//
//  NFMessageFaceView.h
//  newTestUe
//
//  Created by liumac on 15/12/21.
//  Copyright © 2015年 程龙. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBFaceView.h"

@protocol NFMessageFaceViewDelegate <NSObject>
@optional

/*
 * 点击表情代理
 * @param faceName 表情对应的名称
 * @param del      是否点击删除
 *
 */
- (void)SendTheFaceStr:(NSString *)faceStr isDelete:(BOOL)dele;

@end

@interface NFMessageFaceView : UIView<UIScrollViewDelegate,ZBFaceViewDelegate>

@property (nonatomic,weak)id<NFMessageFaceViewDelegate>delegate;

@end
