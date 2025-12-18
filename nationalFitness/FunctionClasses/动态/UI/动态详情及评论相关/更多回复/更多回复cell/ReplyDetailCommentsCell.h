//
//  ReplyDetailCommentsCell.h
//  newTestUe
//
//  Created by liumac on 15/12/18.
//  Copyright © 2015年 程龙. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NFBaseEntity.h"

@interface ReplyDetailCommentsCell : UITableViewCell

- (void)setTextStr:(commentEntity *)entity;

+ (CGFloat)getContentCellHeight:(NSString  *)str;

@end
