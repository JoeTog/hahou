//
//  NFShowImageView.h
//  nationalFitness
//  放置URL图片
//  Created by 程long on 14-11-5.
//  Copyright (c) 2014年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PublicDefine.h"
#import "UIImageView+WebCache.h"


typedef void (^ReturnProgressBlock)(CGFloat progress);

@interface NFShowImageView : UIImageView<SDWebImageManagerDelegate>


/**
 *  从缓存或者下载图片，带回调，可用可不用
 *
 *  @param URLStr     图片路径
 *  @param completion 带成功BOLL 和 IMAGE结果
 */
- (void)ShowImageWithUrlStr: (NSString *)URLStr completion:(ResultDown)completion;

//带placehold
- (void)ShowImageWithUrlStr: (NSString *)URLStr placeHoldName:(NSString *)placeHold completion:(ResultDown)completion;

- (void)ShowImageWithUrlStr: (NSString *)URLStr placeHoldName:(NSString *)placeHold completion:(ResultDown)completion progressBlock:(ReturnProgressBlock)block;

@property(nonatomic,copy)ReturnProgressBlock returnProgressBlock;


//不需要裁剪?
@property (nonatomic) BOOL notClipsToBounds;

@end
