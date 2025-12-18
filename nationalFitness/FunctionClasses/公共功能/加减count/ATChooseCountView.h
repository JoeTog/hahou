//
//  ATChooseCountView.h
//  ATChooseCountView
//
//  Created by Attu on 16/10/12.
//  Copyright © 2016年 Attu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^afterClick)(NSInteger count);

@interface ATChooseCountView : UIView

@property (nonatomic, strong) UIColor *countColor;
@property (nonatomic, assign) BOOL canEdit;

@property (nonatomic, assign) NSInteger minCount;
@property (nonatomic, assign) NSInteger maxCount;

- (NSInteger)getCurrentCount;

@property(nonatomic,copy)afterClick returnCountBlock;

-(void)returnCount:(afterClick)block;


@end
