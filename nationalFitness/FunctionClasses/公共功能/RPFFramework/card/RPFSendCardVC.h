//
//  RPFSendCardVC.h
//  NIM
//
//  Created by King on 2019/3/6.
//  Copyright © 2019年 Netease. All rights reserved.
//

#import "RPFSearchFriendVC.h"
//#import <NIMSDK/NIMSDK.h>

typedef void (^sendCardBblock)(NSString * cardId,BOOL isGroup);

NS_ASSUME_NONNULL_BEGIN

@protocol RPFSendCardDelegate <NSObject>

-(void)gainCardInfo:(NSString *) cardId isGroup:(BOOL) isGroup;


@end

@interface RPFSendCardVC : RPFSearchFriendVC<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,copy)sendCardBblock sendcardBlock;

@property (nonatomic, assign) id <RPFSendCardDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
