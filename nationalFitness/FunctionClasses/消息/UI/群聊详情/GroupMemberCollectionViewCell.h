//
//  GroupMemberCollectionViewCell.h
//  nationalFitness
// 群聊成员collectioncell
//  Created by Joe on 2017/7/13.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NFHeadImageView.h"
@interface GroupMemberCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet NFHeadImageView *headImageV;


@property (weak, nonatomic) IBOutlet UILabel *nickNamelabel;


@property (weak, nonatomic) IBOutlet UIImageView *badgeimageV;







@end
