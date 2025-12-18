//
//  RedDetailViewController.h
//  nationalFitness
//
//  Created by joe on 2017/12/12.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "NFbaseViewController.h"
#import "UUMessageFrame.h"
#import "UUMessage.h"

@interface RedDetailViewController : NFbaseViewController

@property(nonatomic,strong)NSString *nickName;

//RedEntity
@property(nonatomic,strong)RedEntity *redEntity;

@property(nonatomic,strong)UUMessageFrame *redMessage;


@end
