

//
//  NotDismissAlertView.m
//  nationalFitness
//
//  Created by joe on 2018/3/27.
//  Copyright © 2018年 chenglong. All rights reserved.
//

#import "NotDismissAlertView.h"

@implementation NotDismissAlertView


-(void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
    
    if (_notDisMiss)
        
    {
        
        return;
        
    }
    
    [super dismissWithClickedButtonIndex:buttonIndex animated:animated];
    
}




@end



