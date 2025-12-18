//
//  ApplyViewController.h
//  nationalFitness
//
//  Created by Joe on 2017/6/30.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "NFbaseViewController.h"
#import "ContantTableViewCell.h"
#import "ZJContact.h"
#import "MessageEntity.h"
#import "ApplyViewDetailViewController.h"
#import "SocketModel.h"
#import "SocketRequest.h"
#import "JsonModel.h"
#import "NSDate+RYChat.h"
#import "FMDBService.h"


#import "GroupApplyTableViewCell.h"




@interface ApplyViewController : NFbaseViewController
//懒加载
@property (copy, nonatomic) NSMutableDictionary *parms;    //懒加载


@property (strong, nonatomic) FMDBService *fmdbServicee;



@property(nonatomic,assign)NSInteger addFrientCount;


@end
