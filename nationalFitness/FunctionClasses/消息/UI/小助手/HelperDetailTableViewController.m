//
//  HelperDetailTableViewController.m
//  nationalFitness
//
//  Created by joe on 2020/11/30.
//  Copyright © 2020 chenglong. All rights reserved.
//

#import "HelperDetailTableViewController.h"

@interface HelperDetailTableViewController ()

@end

@implementation HelperDetailTableViewController{
    
    
    __weak IBOutlet UITextView *detailtextVC;
    
    __weak IBOutlet UILabel *timeLabel;
    
    
    CGFloat heightText;
    
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    heightConstaint.constant = SCREEN_HEIGHT - 44 - HitoSafeAreaHeight - 10;
    
    self.title = @"详情";
    
    detailtextVC.text = self.detailText;
//    detailtextVC.scrollEnabled = NO;
    timeLabel.text = self.timeText;
    
    self.tableView.tableFooterView = [UIView new];
    
    
    
}

#pragma mark - Table view data source


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:17]};
    CGFloat height = [self.detailText boundingRectWithSize:CGSizeMake(JOESIZE.width - 30, 2000) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size.height;
    if(height < 300){
        return 300;
    }
    return height + 100;
}




@end
