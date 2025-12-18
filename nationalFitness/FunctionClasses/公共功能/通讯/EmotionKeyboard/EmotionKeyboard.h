//
//  EmotionKeyboard.h
//  emoji
//
//  Created by jianghong on 16/1/14.
//  Copyright © 2016年 jianghong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+Emoji.h"
#import "EmotionTool.h"
#import "EmotionModel.h"

//#import "SocketRequest.h"

/**
 *  屏幕宽度
 */
#define ScreenW [UIScreen mainScreen].bounds.size.width
/**
 *  屏幕高度
 */
#define ScreenH [UIScreen mainScreen].bounds.size.height


#define CollectImageInstead [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].userName,@"CollectImage"]




typedef NS_ENUM(NSUInteger, EmotionToolBarButtonType) {
    EmotionToolBarButtonTypeCollect = 1001, //收藏
    EmotionToolBarButtonTypeDefault,//默认
    EmotionToolBarButtonTypeEmoji,//emoji
    EmotionToolBarButtonTypeMagic,//魔法
};


typedef void(^deleteCollectePicture)(NSString *fileId);

typedef void(^PageViewDeleteCollectePicture)(NSString *fileId);


typedef void(^EmotionListViewDeleteCollectePicture)(NSString *fileId);


@protocol EmoticonViewDelegate <NSObject>

@optional
/**
 *  获取图片对应文字
 *
 *  @param text 文字
 */
- (void)emoticonInputDidTapText:(NSString *)text;

/**
 *  获取收藏图片表情对应的url
 *
 *  @param url 图片路径
 */
- (void)emoticonCollectImageDidTapUrl:(NSString *)url;
/**
 *  获取魔法图片表情对应的url
 *
 *  @param url 图片路径
 */
- (void)emoticonMagicEmotionDidTapText:(NSString *)text;

/**
 *  删除表情
 */
- (void)emoticonInputDidTapBackspace;
/**
 *  发送表情
 */
- (void)emoticonInputDidTapSend;

///**
// *  删除收藏图片
// */
- (void)emoticonDeleteCollectedPictureID:(NSString *)fileId;


@end

#pragma mark - EmotionListView

@interface EmotionListView : UIView
/**
 *  当前ListView对应的表情集合
 */
@property (nonatomic, strong) NSArray *emotions;

/**
 *  是否为默认表情
 */
@property (nonatomic, assign, getter=isDefault) BOOL Default;

@property (nonatomic, assign) EmotionToolBarButtonType currentType;

@property(nonatomic,copy)EmotionListViewDeleteCollectePicture EmotionListViewDeleteCollectepicture;

-(void)EmotionListViewDeleteCollectePictureBlock:(EmotionListViewDeleteCollectePicture)block;


@end


@interface EmotionKeyboard : UIView

@property (nonatomic, weak) id<EmoticonViewDelegate> delegate;


+ (instancetype)sharedEmotionKeyboardView;
- (instancetype)initWithDefault;
- (instancetype)init;
- (instancetype)initWithFrame:(CGRect)frame;



/**
 *  最近
 */
@property (nonatomic, strong) EmotionListView *collectListView;

-(void)removeAllOberserrr;


@end
