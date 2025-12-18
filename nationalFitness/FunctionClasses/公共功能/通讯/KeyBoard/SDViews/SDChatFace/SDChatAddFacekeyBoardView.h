//
//  SDChatAddFacekeyBoardView.h
//  SDChat
//
//  Created by Megatron Joker on 2017/5/31.
//  Copyright © 2017年 SlowDony. All rights reserved.
//


#import <UIKit/UIKit.h>

//表情工具栏.(含发送按钮)
#import "SDFaceToolBar.h"


//表情view
#import "SDFaceListView.h"

/**
 添加表情view
 */
@interface SDChatAddFacekeyBoardView : UIView

/**
 表情工具栏(发送按钮)
 */
@property (nonatomic,strong)SDFaceToolBar *faceToolBar;


/**
 表情列表
 */
@property (nonatomic,strong)SDFaceListView *faceListView;


/**
 初始化view

 @return view
 */
+(instancetype)faceKeyBoard;





@end
