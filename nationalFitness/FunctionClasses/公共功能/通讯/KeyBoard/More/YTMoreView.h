//
//  YTMoreView.h
//  YTChatDemo
//
//  Created by TI on 15/9/1.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVProgressHUD.h"


typedef NS_ENUM(NSInteger, YTMoreViewTypeAction){
    YTMoreViewTypeActionNon = 0, //
    YTMoreViewTypeActionPhoto,  //图片
    YTMoreViewTypeActionCamera, //照相
    YTMoreViewTypeActionRed,     //红包
    YTMoreViewTypeActionTransfer,//转账
    YTMoreViewTypeActionCard,      //名片
    YTMoreViewTypeActionInvite     //邀请
};
@protocol YTMoreViewDelegate <NSObject>

/**moewView包含控件事件，有可能是后期扩展*/
- (void)moreViewType:(YTMoreViewTypeAction)type;
@end

@interface YTMoreView : UIView

@property (nonatomic, strong) id<YTMoreViewDelegate> delegate; //代理

//放功能按钮的scrollview
@property (nonatomic, strong) UIScrollView * scrollView;

//是否是群组
@property (nonatomic, assign) BOOL IsGroup;


- (void)initUI;
    
//-(void)addResourceUpdateisGroup:(BOOL)ret;



@end
