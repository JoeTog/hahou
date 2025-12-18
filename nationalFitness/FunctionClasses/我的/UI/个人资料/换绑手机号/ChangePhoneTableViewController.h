//
//  ChangePhoneTableViewController.h
//  nationalFitness
//
//  Created by joe on 2020/4/6.
//  Copyright © 2020 chenglong. All rights reserved.
//

#import "NFTableViewController.h"


#import "SocketModel.h"
#import "MBSliderView.h"
#import "HCDTimer.h"


NS_ASSUME_NONNULL_BEGIN

@interface ChangePhoneTableViewController : NFTableViewController


@property (copy, nonatomic) NSMutableDictionary *parms;    //懒加载
@property (strong, nonatomic) NFMyManage *myManage;    //懒加载 fmdbServicee




@property (strong, nonatomic) MBSliderView *MBSlider;//滑块带边框




@end

NS_ASSUME_NONNULL_END
