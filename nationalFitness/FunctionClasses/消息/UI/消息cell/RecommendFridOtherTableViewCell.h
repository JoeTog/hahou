//
//  RecommendFridOtherTableViewCell.h
//  nationalFitness
//
//  Created by joe on 2019/12/30.
//  Copyright © 2019年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NFHeadImageView.h"


#import "LWWeChatActionSheet.h"


//#import "UIImageView+WebCache.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^ReturnheadViewLongPressBlock)(void);
typedef void (^ReturnDeleteBlock)(void);


@interface RecommendFridOtherTableViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet NFHeadImageView *headImageV;



@property (weak, nonatomic) IBOutlet NFHeadImageView *recommendHeadImageV;



@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;


@property (weak, nonatomic) IBOutlet UIImageView *backImageV;


@property (weak, nonatomic) IBOutlet UIButton *clickBtn;


@property (weak, nonatomic) IBOutlet UILabel *titleNameLabel;







//点击删除
@property(nonatomic,copy)ReturnDeleteBlock returnDeleteBlock;
-(void)returnDelete:(ReturnDeleteBlock)block;

//长按 对方头像 艾特某人
@property(nonatomic,copy)ReturnheadViewLongPressBlock returnLongBlock;
-(void)returnLong:(ReturnheadViewLongPressBlock)block;





@end

NS_ASSUME_NONNULL_END
