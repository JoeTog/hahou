//
//  NFMineManager.h
//  nationalFitness
//
//  Created by Joe on 2017/7/14.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "NFBaseManager.h"
#import "NFMineParser.h"
#import "NFMineEntity.h"
#import "NFMineRequest.h"

@interface NFMineManager : NFBaseManager



//意见反馈
-(void)SendAddviseManager;

#pragma mark - http上传图片
-(void)uploadPictureImageManager;



@end
