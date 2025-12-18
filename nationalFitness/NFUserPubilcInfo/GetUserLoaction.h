//
//  GetUserLoaction.h
//  nationalFitness
//
//  Created by 程龙 on 15/9/9.
//  Copyright (c) 2015年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <AMapSearchKit/AMapSearchAPI.h>
//#import <MAMapKit/MAMapServices.h>
#import "PublicDefine.h"


typedef void (^ReturnLocation)(NSString *locationString);



//<AMapSearchDelegate>
@interface GetUserLoaction : NSObject

@property(nonatomic,copy)ReturnLocation returnLocation;

-(void)returnLocation:(ReturnLocation)block;



- (void)searchReGeocodeWithCoordinate:(CGFloat)Longitude userLatitude:(CGFloat)Latitude;





@end
