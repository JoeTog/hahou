//
//  PhotoLookBigPicViewController.h
//  nationalFitness
//
//  Created by 童杰 on 2017/3/27.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "NFbaseViewController.h"
#import "NFShowImageView.h"

@interface PhotoLookBigPicViewController : NFbaseViewController

//记录选中index
@property(nonatomic,assign)NSInteger currentPage;

//exe
//真数据的arr
@property(nonatomic,copy)NSArray *picMapList;

//是否需要 navi title
@property(nonatomic)BOOL isNeedTitle;


@end
