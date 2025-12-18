//
//  OpinionRequestViewController.h
//  nationalFitness
//
//  Created by 童杰 on 2016/12/22.
//  Copyright © 2016年 chenglong. All rights reserved.
//

#import "NFbaseViewController.h"
#import "PopView.h"
#import "MKPAlertView.h"
#import "NFDynamicEntity.h"
#import "ZJContact.h"



@interface OpinionRequestViewController : NFbaseViewController

@property (copy, nonatomic) NSMutableDictionary *parms;    //懒加载


//是否为投诉举报
@property (nonatomic) BOOL tousu;

//cycleId
@property(nonatomic,strong)NSString *cycleId;

//举报动态
@property(nonatomic,strong)NoteListEntity *cycleEntity;

//举报群组
@property(nonatomic,strong)GroupCreateSuccessEntity *groupCreateSEntity;


//举报联系人
@property (nonatomic, strong) ZJContact *contactEntity;




@end
