//
//  SDFaceView.h
//  SDChat
//
//  Created by Megatron Joker on 2017/6/1.
//  Copyright © 2017年 SlowDony. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ReturnDeleteBlock)(void);


@interface SDFaceView : UIView
//展示的表情数据源
@property (nonatomic,strong) NSArray *faceArr;//



@property(nonatomic,copy)ReturnDeleteBlock returnSendBlock;


-(void)returnDelete:(ReturnDeleteBlock)block;



@end
