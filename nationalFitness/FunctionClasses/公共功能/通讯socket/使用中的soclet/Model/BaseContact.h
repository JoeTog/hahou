//
//  BaseContact.h
//  WebSocket
//
//  Created by King on 2017/7/1.
//  Copyright © 2017年 King. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseContact : NSObject

//用户ID
@property (nonatomic, strong) NSString *m_nsUsrName;

//用户名(昵称)
@property (nonatomic, strong) NSString *m_nsNickName;

//用户备注名
@property (nonatomic, strong) NSString *m_nsRemark;

//用户性别
@property (nonatomic, assign) int m_nsSex;

//用户头像
@property (nonatomic, strong) NSString *m_nsHeadImgUrl;

-(instancetype)initData:(NSDictionary *)dic;

@end
