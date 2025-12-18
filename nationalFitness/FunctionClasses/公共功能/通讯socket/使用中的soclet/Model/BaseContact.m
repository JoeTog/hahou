//
//  BaseContact.m
//  WebSocket
//
//  Created by King on 2017/7/1.
//  Copyright © 2017年 King. All rights reserved.
//

#import "BaseContact.h"

@implementation BaseContact

-(instancetype)initData:(NSDictionary *)dic
{
    if (self = [super init]) {
        self.m_nsUsrName = dic[@"m_nsUsrName"];
        self.m_nsNickName = dic[@"m_nsNickName"];
        self.m_nsRemark = dic[@"m_nsRemark"];
        self.m_nsSex = [dic[@"m_nsSex"] intValue];
    }
    
    return self;
    
}

@end









