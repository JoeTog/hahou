//
//  UUMessageContentButton.h
//  BloodSugarForDoc
//
//  Created by shake on 14-8-27.
//  Copyright (c) 2014年 shake. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NFShowImageView.h"

typedef void (^ReturnCopyBlock)(void);
typedef void (^ReturnForwardBlock)(void);
typedef void (^ReturnDeleteBlock)(void);
typedef void (^ReturnmyWithDrowBlock)(void);
//moreEdit
typedef void (^ReturnMoreEditBlock)(void);

typedef void (^ReturnSaveBlock)(void);


@interface UUMessageContentButton : UIButton

//bubble imgae
//@property (nonatomic, retain) UIImageView *backImageView;

//NFShowImageView
@property (nonatomic, retain) NFShowImageView *backImageView;

//audio
@property (nonatomic, retain) UIView *voiceBackView;
@property (nonatomic, retain) UILabel *second;
@property (nonatomic, retain) UIImageView *voice;
@property (nonatomic, retain) UIActivityIndicatorView *indicator;

@property(nonatomic,copy)ReturnForwardBlock forwardBlock;
-(void)returnForwardBlock:(ReturnForwardBlock)block;

@property(nonatomic,copy)ReturnDeleteBlock DeleteBlock;
-(void)returnDeleteBlock:(ReturnDeleteBlock)block;

@property(nonatomic,copy)ReturnmyWithDrowBlock drowBlock;
-(void)returnmyWithDrowBlock:(ReturnmyWithDrowBlock)block;

@property(nonatomic,copy)ReturnCopyBlock copyBlock;
-(void)returnCopyBlock:(ReturnCopyBlock)block;

//ReturnMoreEditBlock
@property(nonatomic,copy)ReturnMoreEditBlock moreBlock;
-(void)returnMoreEditBlock:(ReturnMoreEditBlock)block;

@property(nonatomic,copy)ReturnSaveBlock saveBlock;
-(void)returnSaveBlock:(ReturnSaveBlock)block;


@property (nonatomic, assign) BOOL isMyMessage;


- (void)benginLoadVoice;

- (void)didLoadVoice;

-(void)stopPlay;

@end
