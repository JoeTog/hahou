//
//  QRCodeEntity.h
//  nationalFitness
//
//  Created by 程long on 14-12-25.
//  Copyright (c) 2014年 chenglong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QRCodeEntity : NSObject

@end

@interface TrainAndEventEntity : NSObject

@property (nonatomic, strong)NSString * scanID;

@property (nonatomic, strong)NSString * picPath;

@property (nonatomic, strong)NSString * titleName;




//验门票

@property (nonatomic, strong)NSString * ticketId;

@property (nonatomic, strong)NSString * ticketPicPath;

@property (nonatomic, strong)NSString * beginTime;

@property (nonatomic, strong)NSString * ticketPrice;

@property (nonatomic, strong)NSString * area;

@property (nonatomic, strong)NSString * account;



@end








