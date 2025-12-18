//
//  ChosePhoto.h
//  chosephoto
//
//  Created by 童杰 on 2017/3/2.
//  Copyright © 2017年 童杰. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HDPictureShowViewController.h"


@interface ChosePhoto : UIView<UICollectionViewDelegate,UICollectionViewDataSource,UINavigationControllerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UITextViewDelegate>

//-(instancetype)initWithFrame:(CGRect)frame AndItemSize:(CGSize)size;
//imageBlock 中可以传出字段 进行判断特殊操作
-(instancetype)initWithFrame:(CGRect)frame AndItemSize:(CGSize)size AndPhotos:(NSArray *)existImages Target:(id)Controller AndBlock:(void(^)(NSArray *imageArr))imageBlock;

@property(nonatomic,strong)void(^imageBack)(NSArray *);


//必传 传一个ViewController进去 一般传self
@property (nonatomic) id photoViewDele;

//一行显示几个图片
@property (nonatomic) NSInteger showNum;
//图片宽 高
//@property (nonatomic) CGFloat imageWidth;

//@property (nonatomic) CGFloat imageHeight;

@property(nonatomic,retain)UIColor *ViewBackColor;

@property(nonatomic,retain)UIColor *CollectionViewBackColor;

//最多上传照片的个数 默认不限制
@property (nonatomic,assign) NSInteger MaxCount;


//是否能够编辑添加图片 默认为 YES 可编辑【是否显示 添加图片的框框】,当将查看与编辑合并时候 这里就都为YES了
@property(nonatomic)BOOL isCanEdit;

//框框添加图片 是否允许点击弹出 不允许点击提示 yes允许编辑 no 传出字段 提示不给编辑
@property(nonatomic)BOOL isCanTouchPhoto;


@end
