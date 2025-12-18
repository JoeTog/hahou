//
//  ForgetPasswordTableViewController.h
//  nationalFitness
//
//  Created by joe on 2020/1/4.
//  Copyright © 2020年 chenglong. All rights reserved.
//

#import "NFTableViewController.h"
#import "HCDTimer.h"

#import "SocketModel.h"
#import "SocketRequest.h"

#import "DCPaymentView.h"



NS_ASSUME_NONNULL_BEGIN

@interface ForgetPasswordTableViewController : NFTableViewController



@property (weak, nonatomic) IBOutlet UILabel *firstLabel;

@property (weak, nonatomic) IBOutlet UILabel *secondLabel;


@property (weak, nonatomic) IBOutlet UILabel *rhirdLabel;



@property (nonatomic) BOOL IsShowBack;    






@end

NS_ASSUME_NONNULL_END
