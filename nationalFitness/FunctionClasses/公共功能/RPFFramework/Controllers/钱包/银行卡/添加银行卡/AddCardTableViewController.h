//
//  AddCardTableViewController.h
//  nationalFitness
//
//  Created by joe on 2020/1/11.
//  Copyright © 2020年 chenglong. All rights reserved.
//

#import "NFTableViewController.h"

#import "BankShareManager.h"

#import "DataBankCardInfo.h"


NS_ASSUME_NONNULL_BEGIN

@interface AddCardTableViewController : NFTableViewController


@property (weak, nonatomic) IBOutlet UILabel *nameabel;



@property (weak, nonatomic) IBOutlet UILabel *firstLabel;

@property (weak, nonatomic) IBOutlet UILabel *secondLabel;

@property (weak, nonatomic) IBOutlet UILabel *thirdLabel;


@property (weak, nonatomic) IBOutlet UILabel *forthLabel;

@property (weak, nonatomic) IBOutlet UILabel *fifithLabelk;

@property (weak, nonatomic) IBOutlet UILabel *sixthlabel;


@property (nonatomic, strong) DataBankCardInfo *cardBank;






@end

NS_ASSUME_NONNULL_END
