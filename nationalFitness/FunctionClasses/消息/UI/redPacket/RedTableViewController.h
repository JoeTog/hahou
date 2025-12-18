//
//  RedTableViewController.h
//  nationalFitness
//  群红包
//  Created by joe on 2017/12/6.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "NFTableViewController.h"
#import "UIImage+FW.h"
#import "MessageEntity.h"

@protocol RedTableViewDelegate <NSObject>

- (void)RedTableViewGroup:(UITableViewController *)funcView SendRed:(RedEntity *)redEntity;


@end

@interface RedTableViewController : NFTableViewController



@property (nonatomic, assign) id<RedTableViewDelegate>delegate;




@end
