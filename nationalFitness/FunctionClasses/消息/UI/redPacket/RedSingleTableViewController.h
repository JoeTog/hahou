//
//  RedSingleTableViewController.h
//  nationalFitness
//
//  Created by joe on 2017/12/6.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "NFTableViewController.h"

#import "UIImage+FW.h"
#import "MessageEntity.h"


@protocol RedSingleTableViewDelegate <NSObject>

- (void)RedTableViewSingle:(UITableViewController *)funcView SendRed:(RedEntity *)redEntity;


@end


@interface RedSingleTableViewController : NFTableViewController


@property (nonatomic, assign) id<RedSingleTableViewDelegate>delegate;



@end
