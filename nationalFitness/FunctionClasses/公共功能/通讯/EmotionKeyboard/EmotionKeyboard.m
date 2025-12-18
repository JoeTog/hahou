//
//  EmotionKeyboard.m
//  emoji
//
//  Created by jianghong on 16/1/14.
//  Copyright © 2016年 jianghong. All rights reserved.
//

#import "EmotionKeyboard.h"
#import "UIView+Extension.h"
#import "UIButton+RemoveHighlightEffect.h"



#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]




#pragma mark - EmotionButton
@class EmotionModel;

@interface EmotionButton : UIButton

//当前button显示的emotion
@property (nonatomic, strong) EmotionModel *emotion;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, copy)NSString *imageUrl;

@property (nonatomic, assign, getter=isCollectEmotionBtn) BOOL CollectEmotionBtn;

@property (nonatomic, strong) UIButton *deleteButton;

/**
 *  是否为默认表情
 */
@property (nonatomic, assign, getter=isDefaultEmotionBtn) BOOL DefaultEmotionBtn;

//删除收藏 block
@property(nonatomic,copy)deleteCollectePicture deleteCollectepicture;



@end

@implementation EmotionButton

-(void)deleteCollectePictureBlock:(deleteCollectePicture)block{
    if (self.deleteCollectepicture != block) {
        self.deleteCollectepicture = block;
    }
}


/**
 *  如果从xib加载控件,是不会执行这个代码
 *
 *  @param frame <#frame description#>
 *
 *  @return <#return value description#>
 */
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //        [self setup];
        UIButton *deleteBtn = [[UIButton alloc] init];
        
        //设置图片
//        [deleteBtn setImage:[UIImage imageNamed:@"compose_photo_close"] forState:UIControlStateNormal];
        [deleteBtn setImage:[EmotionTool emotionImageWithName:@"compose_photo_close"] forState:UIControlStateNormal];
        //设置大小
        deleteBtn.size = [deleteBtn currentImage].size;
        
        deleteBtn.hidden = YES;
        
        [deleteBtn addTarget:self action:@selector(deleteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [self addSubview:deleteBtn];
        self.deleteButton = deleteBtn;
    }
    return self;
}

- (void)deleteBtnClick:(UIButton *)button{
    
    
    NSArray *arr = [self.imageUrl componentsSeparatedByString:@"CollectImage/"];
    NSString *picpath = [NSString new];
//    NSString *pictureScale = [NSString new];
    NSString *fileID = [NSString new];
    if (arr.count == 2) {
        picpath = [arr lastObject];
        //1.2#2020-03-20@5e7456505e5be.jpeg
        NSArray *ARR = [picpath componentsSeparatedByString:@"#"];
        if(ARR.count == 3){
//            pictureScale = [ARR firstObject];
            fileID = ARR[1];
            picpath = [ARR lastObject];
        }
//        picpath = [ARR lastObject];
//        fileID = [ARR firstObject];
        if(ARR.count != 3){
//            pictureScale = @"1";
            fileID = @"";
        }
//        picpath = [picpath stringByReplacingOccurrencesOfString:@"@" withString:@"/"];
//        picpath = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,picpath];
    }
    
                //从服务器删除收藏
    //            SocketRequest *socketRequest = [SocketRequest share];
//            if ([self.delegate respondsToSelector:@selector(emoticonDeleteCollectedPictureID:)]) {
//                [self.delegate emoticonDeleteCollectedPictureID:@""];
//            }
    if (self.deleteCollectepicture) {
        self.deleteCollectepicture(fileID);
    }

    
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0.0;
        [EmotionTool delectCollectImage:self.imageUrl];
        
        
    } completion:^(BOOL finished) {
        //动画执行完毕,移除
        [self removeFromSuperview];
        
    }];
}


/**
 *  做一些当前控件的初始化操作
 */
- (void)setup{
    self.removeHighlightEffect = YES;
    self.titleLabel.font = [UIFont systemFontOfSize:35];
    self.backgroundColor = [UIColor greenColor];
}

- (void)setEmotion:(EmotionModel *)emotion{
    _emotion = emotion;
    if (!emotion.isEmoji) {
        //设置表情图片
        UIImage *image = [UIImage imageNamed:emotion.fullPath];
        [self setImage:image forState:UIControlStateNormal];
    }else{
        [self setTitle:[emotion.code emoji] forState:UIControlStateNormal];
    }
}

-(void)setImage:(UIImage *)image{
    _image = image;
    [self setImage:image forState:UIControlStateNormal];
}

-(void)setImageUrl:(NSString *)imageUrl{
    _imageUrl = imageUrl;
    //    NSLog(@"%@",imageUrl);
    if (imageUrl) {
        NSArray *tmp = [imageUrl componentsSeparatedByString:@"/"];
        NSString *magic = [tmp objectAtIndex:tmp.count -2];
//        NSString * a = [NSString stringWithFormat:@"Documents/%@",CollectImageInstead];
//        NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",CollectImageInstead]];
NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/CollectImage",[NFUserEntity shareInstance].userName]];
//        NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/CollectImage"];
        
        if ([magic isEqualToString:@"MagicEmotions"]) {
            path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/MagicEmotions"];
            path = [[path stringByAppendingPathComponent:imageUrl.lastPathComponent] stringByReplacingOccurrencesOfString:@".gif" withString:@".jpg"];
        }
        else{
            path = [path stringByAppendingPathComponent:imageUrl.lastPathComponent];
        }
        //            [self setImageWithURL:[NSURL fileURLWithPath:path] forState:UIControlStateNormal];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:path]];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self setImage:image forState:UIControlStateNormal];
                
            });
        });
        
        
    }
    
}

- (void)setDefaultEmotionBtn:(BOOL)DefaultEmotionBtn{
    _DefaultEmotionBtn = DefaultEmotionBtn;
    if (!DefaultEmotionBtn) {
        self.imageEdgeInsets =  UIEdgeInsetsMake(5,5,5,5);
    }
}

- (void)setCollectEmotionBtn:(BOOL)CollectEmotionBtn{
    _CollectEmotionBtn = CollectEmotionBtn;
    if (CollectEmotionBtn) {
        //添加长按手势
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longTap:)];
        longPress.minimumPressDuration = 0.5;//最小点按时间
        //        longPress.allowableMovement = 50;//允许点击的误差范围
        [self addGestureRecognizer:longPress];
        
    }
}
-(void)longTap:(UILongPressGestureRecognizer *)longRecognizer

{
    NSLog(@"长按");
    self.deleteButton.hidden = NO;
    
}


@end

#pragma mark - EmotionToolBar
@class EmotionToolBar;

@protocol EmotionToolBarDelegate <NSObject>
- (void)emotionToolbar:(EmotionToolBar *)toolBar buttonClickWithType:(EmotionToolBarButtonType)type;

@end

@interface EmotionToolBar : UIView

@property (nonatomic, weak) id<EmotionToolBarDelegate> delegate;
/**
 *  是否为默认键盘,默认只有默认表情和emoji,聊吧和消息界面有魔法和收藏
 */
@property (nonatomic, assign, getter=isDefault) BOOL Default;


@end


@interface EmotionToolBar()

/**
 *  当前选中的button
 */
@property (nonatomic, weak) UIButton *currentSelectedBtn;
@property (nonatomic, weak) UIButton *MagicBtn;
@property (nonatomic, weak) UIButton *CollectBtn;

@end

@implementation EmotionToolBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        //        self.backgroundColor = RGBCOLOR(235, 236, 238);
        
        
        //添加4个按钮
        
//        self.CollectBtn = [self addChildBtnWithTitle:@"收藏" bgImageName:@"mid" type:EmotionToolBarButtonTypeDefault];
        self.CollectBtn = [self addChildBtnWithTitle:@"收藏" bgImageName:@"mid" type:EmotionToolBarButtonTypeCollect];
//        [self addChildBtnWithTitle:@"默认" bgImageName:@"mid" type:EmotionToolBarButtonTypeDefault];
        [self addChildBtnWithTitle:@"😁" bgImageName:@"mid" type:EmotionToolBarButtonTypeEmoji];
//        self.MagicBtn = [self addChildBtnWithTitle:@"魔法" bgImageName:@"mid" type:EmotionToolBarButtonTypeMagic];
        
//                self.currentSelectedBtn = self.CollectBtn;
        
        //[self.delegate emotionToolbar:self buttonClickWithType:EmotionToolBarButtonTypeCollect];
//        [self.delegate emotionToolbar:self buttonClickWithType:EmotionToolBarButtonTypeEmoji];
        
//        self.CollectBtn.enabled = NO;
//        self.currentSelectedBtn = self.CollectBtn;
//        [self.delegate emotionToolbar:self buttonClickWithType:EmotionToolBarButtonTypeCollect];
//        [self childButtonClick:self.CollectBtn];
        
        
        
        UIButton *sendBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.width / 5 * 4, 0, self.width / 5, self.height)];
        sendBtn.tag = 100;
        [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [sendBtn setBackgroundColor:UIColorFromRGB(0x5D81E0)];
        [sendBtn addTarget:self action:@selector(sendBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:sendBtn];
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 5)];
        line.backgroundColor = [UIColor redColor];

        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(scrollviewLastPage:) name:@"scrollviewLastPage" object:nil];
        
        
    }
    return self;
}






//

-(void)setDefault:(BOOL)Default{
    _Default = Default;
    if (Default) {
        [self.CollectBtn removeFromSuperview];
        [self.MagicBtn removeFromSuperview];
    }
}


- (void)layoutSubviews{
    [super layoutSubviews];
    
    
    //计算出每一个按钮的宽度
    CGFloat childW = self.width / 5;
    
    NSInteger count = self.subviews.count;
    
    
    for (int i=0; i<count; i++) {
        UIView *childView = self.subviews[i];
        
        //设置宽高大小位置
        childView.x = i * childW;
        
        if (childView.tag == 100) {
            childView.x = 4 * childW;
        }
        childView.width = childW;
        childView.height = self.height;
    }
}

- (UIButton *)addChildBtnWithTitle:(NSString *)title bgImageName:(NSString *)bgImageName type:(EmotionToolBarButtonType)type{
    
    UIButton *button = [[UIButton alloc] init];
    //去掉button的按下高亮效果
    //    button.removeHighlightEffect = YES;
    //设置标题
    [button setTitle:title forState:UIControlStateNormal];
    
    button.tag = type;
    
    //设置不同状态下的背景图片
    //    [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"compose_emotion_table_%@_normal",bgImageName]] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor whiteColor]];
    
    //    [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"compose_emotion_table_%@_selected",bgImageName]] forState:UIControlStateDisabled];
    [button setBackgroundImage:[EmotionTool emotionImageWithName:@"emoticon_keyboard_background"] forState:UIControlStateDisabled];
    
    
    
    //设置选中状态字体颜色
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    //设置选中状态字体颜色
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
    //监听点击事件
    [button addTarget:self action:@selector(childButtonClick:) forControlEvents:UIControlEventTouchDown];
    
    [self addSubview:button];
    
    
    return button;
}
- (void)setDelegate:(id<EmotionToolBarDelegate>)delegate{
    _delegate = delegate;
//    [self childButtonClick:(UIButton *)[self viewWithTag:EmotionToolBarButtonTypeDefault]];
    //设置默认选中
    [self childButtonClick:(UIButton *)[self viewWithTag:EmotionToolBarButtonTypeEmoji]];
}

- (void)scrollviewLastPage:(NSNotification *)notify{

    if (!self.MagicBtn && [notify.object intValue] == EmotionToolBarButtonTypeMagic) {
        [self childButtonClick:(UIButton *)[self viewWithTag:EmotionToolBarButtonTypeDefault]];
        return;
    }
    [self childButtonClick:(UIButton *)[self viewWithTag:[notify.object intValue]]];
}


- (void)childButtonClick:(UIButton *)button{
    
    //先移除之前选中的button
    self.currentSelectedBtn.enabled = YES;
    //选中当前
    button.enabled = NO;
    //记录当前选中的按钮
    self.currentSelectedBtn = button;
    
    if ([self.delegate respondsToSelector:@selector(emotionToolbar:buttonClickWithType:)]) {
//        [self.delegate emotionToolbar:self buttonClickWithType:button.tag];
        if(button.tag == 1001){
            [self.delegate emotionToolbar:self buttonClickWithType:EmotionToolBarButtonTypeCollect];
        }else if(button.tag == 1002){
            [self.delegate emotionToolbar:self buttonClickWithType:EmotionToolBarButtonTypeDefault];
        }else if(button.tag == 1003){
            [self.delegate emotionToolbar:self buttonClickWithType:EmotionToolBarButtonTypeEmoji];
        }else if(button.tag == 1004){
            [self.delegate emotionToolbar:self buttonClickWithType:EmotionToolBarButtonTypeMagic];
        }
    }
}

- (void)sendBtnClick:(UIButton *)btn{
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"EmotionSendBtnSelectedNoti" object:nil];
}
@end



#pragma mark - EmotionPageView

@interface EmotionPageView : UIView
/**
 *  当前一页对应的表情集合
 */
@property (nonatomic, strong) NSArray *emotions;

/**
 *  是否为默认表情
 */
@property (nonatomic, assign, getter=isDefault) BOOL Default;

@end

#define MARGIN 10

@interface EmotionPageView()

@property (nonatomic, weak) UIButton *deleteButton;

/**
 *  表情按钮对应的集合,记录表情按钮,以便在调整位置的时候用到
 */
@property (nonatomic, strong) NSMutableArray *emotionButtons;

//

@property(nonatomic,copy)PageViewDeleteCollectePicture PageViewDeleteCollectepicture;


-(void)PageViewDeleteCollectePictureBlock:(PageViewDeleteCollectePicture)block;

@end

@implementation EmotionPageView{
    NSInteger  _Page_max_col;
    NSInteger  _Page_max_row;
    
    
}

-(void)PageViewDeleteCollectePictureBlock:(PageViewDeleteCollectePicture)block{
    if (self.PageViewDeleteCollectepicture != block) {
        self.PageViewDeleteCollectepicture = block;
    }
}

- (NSMutableArray *)emotionButtons{
    if (!_emotionButtons) {
        _emotionButtons = [NSMutableArray array];
    }
    return _emotionButtons;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //删除按钮
        UIButton *deleteButton = [[UIButton alloc] init];
        //设置不同状态的图片
        [deleteButton setImage:[EmotionTool emotionImageWithName:@"compose_emotion_delete_highlighted"] forState:UIControlStateHighlighted];
        [deleteButton setImage:[EmotionTool emotionImageWithName:@"compose_emotion_delete"] forState:UIControlStateNormal];
        //添加删除按钮点击事件
        [deleteButton addTarget:self action:@selector(deleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:deleteButton];
        self.deleteButton = deleteButton;
        
    }
    return self;
}



- (void)setEmotions:(NSArray *)emotions{
    _emotions = emotions;
    
    //添加表情按钮
    NSInteger count = emotions.count;
    
    for (int i=0; i<count; i++) {
        
        EmotionButton *button = [[EmotionButton alloc] init];
        if ([emotions[i] isKindOfClass:[EmotionModel class]]) {
            //取出对应的表情模型
            EmotionModel *emotion = emotions[i];
            button.removeHighlightEffect = YES;
            button.titleLabel.font = [UIFont systemFontOfSize:35];
            button.emotion = emotion;
        }else{//不是表情
            //            button.image = emotions[i];
            button.imageUrl = emotions[i];
            button.DefaultEmotionBtn = NO;
            __weak typeof(self)weakSelf=self;
            [button deleteCollectePictureBlock:^(NSString *fileId) {
                weakSelf.PageViewDeleteCollectepicture(fileId);
            }];
            NSArray *tmp = [emotions[i] componentsSeparatedByString:@"/"];
            NSString *collect = [tmp objectAtIndex:tmp.count -2];
           
            if ([collect isEqualToString:@"CollectImage"]) {
                
                button.CollectEmotionBtn = YES;

            }

        }
        //按钮点击监听
        [button addTarget:self action:@selector(emotionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [self addSubview:button];
        
        [self.emotionButtons addObject:button];
    }
    
}



/**
 *  删除按钮点击
 *
 *  @param button <#button description#>
 */
- (void)deleteButtonClick:(UIButton *)button{
    
    //发送一个删除按钮点击的通知
    [[NSNotificationCenter defaultCenter]postNotificationName:@"EmotionDeleteBtnSelectedNoti" object:nil];
}

/**
 *  表情点击
 *
 *  @param button <#button description#>
 */
- (void)emotionButtonClick:(EmotionButton *)button{
    
    //发出表情点击了的通知
    [[NSNotificationCenter defaultCenter]postNotificationName:@"EmotionDidSelectedNoti" object:button];
}

- (void)setDefault:(BOOL)Default{
    _Default = Default;
    if (Default) {
        _Page_max_col = 7;
        _Page_max_row = 3;
    }else{
        _Page_max_col = 4;
        _Page_max_row = 2;
        [self.deleteButton removeFromSuperview];
        
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    //取出子控件的个数
    NSInteger count = self.emotionButtons.count;
    
    
    CGFloat childW = (self.width - MARGIN * 2) / _Page_max_col;
    CGFloat childH = (self.height - MARGIN) / _Page_max_row;
    
    
    for (int i=0; i<count; i++) {
        UIView *view = self.emotionButtons[i];
        
        view.size = CGSizeMake(childW, childH);
        
        //求出当前在第几列第几行
        NSInteger col = i % _Page_max_col;
        NSInteger row = i / _Page_max_col;
        
        //设置位置
        view.x = col * childW + MARGIN;
        view.y = row * childH + MARGIN;
    }
    
    self.deleteButton.size = CGSizeMake(childW, childH);
    
    self.deleteButton.x = self.width - childW - MARGIN;
    self.deleteButton.y = self.height - childH;
    
    
}
@end



@interface EmotionListView()<UIScrollViewDelegate>

@property (nonatomic, weak) UIPageControl *pageControl;

@property (nonatomic, weak) UIScrollView *scrollView;

/**
 *  记录scrollView的用户自己添加的子控件,因为直接调用 scrollView.subViews会出现问题(因为滚动条也算scrollView的子控件)
 */
@property (nonatomic, strong) NSMutableArray *scrollsubViews;

//




@end

@implementation EmotionListView{
    NSInteger _PageMaxEmotionCount;
}

-(void)EmotionListViewDeleteCollectePictureBlock:(EmotionListViewDeleteCollectePicture)block{
    if (self.EmotionListViewDeleteCollectepicture != block) {
        self.EmotionListViewDeleteCollectepicture = block;
    }
}

- (NSMutableArray *)scrollsubViews{
    if (!_scrollsubViews) {
        _scrollsubViews = [NSMutableArray array];
    }
    return _scrollsubViews;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //添加uipageControl
        UIPageControl *control = [[UIPageControl alloc] init];
        
        //使用kvc直接赋值当前选中的图标
        //        [control setValue:[UIImage imageNamed:@"compose_keyboard_dot_selected"] forKeyPath:@"_currentPageImage"];
        //        [control setValue:[UIImage imageNamed:@"compose_keyboard_dot_normal"] forKeyPath:@"_pageImage"];
        
        [control setCurrentPageIndicatorTintColor:RGBCOLOR(134, 134, 134)];
        [control setPageIndicatorTintColor:RGBCOLOR(180, 180, 180)];
        
        [self addSubview:control];
        self.pageControl = control;
        
        
        //添加scrollView
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        //隐藏水平方向的滚动条
        scrollView.showsHorizontalScrollIndicator = false;
        scrollView.showsVerticalScrollIndicator = false;
        //开启分页
        scrollView.pagingEnabled = YES;
        
        //设置代理
        scrollView.delegate = self;
        
        [self addSubview:scrollView];
        
        self.scrollView = scrollView;
        
        
    }
    
    return self;
}


- (void)layoutSubviews{
    [super layoutSubviews];
    
    //设置pageControl
    self.pageControl.width = self.width;
    self.pageControl.height = 30;
    
    self.pageControl.y = self.height - self.pageControl.height;
    
    
    //设置scrollView
    self.scrollView.width = self.width;
    self.scrollView.height = self.pageControl.y;
    
    
    //设置scrollView里面子控件的大小
    
    for (int i=0; i<self.scrollsubViews.count; i++) {
        UIView *view = self.scrollsubViews[i];
        
        view.size = self.scrollView.size;
        view.x = i * self.scrollView.width;
    }
    
    //根据添加的子控件的个数计算内容大小
    self.scrollView.contentSize = CGSizeMake(self.scrollView.width * self.scrollsubViews.count, self.scrollView.height);
}

- (void)setDefault:(BOOL)Default{
    _Default = Default;
    if (_Default) {
        _PageMaxEmotionCount = 20;
    }else{
        _PageMaxEmotionCount = 8;
    }
    
    
}
- (void)setEmotions:(NSArray *)emotions{
    _emotions = emotions;
    
    [self.scrollView scrollsToTop];
    
    //在第二次执行这个方法的时候,就需要把之前已经添加的pageView给移除
    [self.scrollsubViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.scrollsubViews removeAllObjects];
    
    //根据个数计算出多少页

    
    //(总数+每一页的个数-1)/每一页的个数
    NSInteger page = (emotions.count + _PageMaxEmotionCount - 1 )/ _PageMaxEmotionCount ;
    
    
    //设置页数
    self.pageControl.numberOfPages = page;
    
    for (int i=0; i<page; i++) {
        EmotionPageView *view = [[EmotionPageView alloc] init];
        view.Default = _Default;
        
        //切割每一页的表情集合
        NSRange range;
        
        range.location = i * _PageMaxEmotionCount;
        range.length = _PageMaxEmotionCount;
        
        //如果表情只有99个,那么最后一页就不满20个,所以需要加一个判断
        NSInteger lastPageCount = emotions.count - range.location;
        if (lastPageCount < _PageMaxEmotionCount) {
            range.length = lastPageCount;
        }
        
        
        //截取出来是每一页对应的表情
        NSArray *childEmotions = [emotions subarrayWithRange:range];
        //设置每一页的表情集合
        view.emotions = childEmotions;

        __weak typeof(self)weakSelf=self;
        [view PageViewDeleteCollectePictureBlock:^(NSString *fileId) {
            weakSelf.EmotionListViewDeleteCollectepicture(fileId);
        }];
        [self.scrollView addSubview:view];
        [self.scrollsubViews addObject:view];
    }
    
    
    //告诉当前控件,去重新布局一下
    [self setNeedsLayout];
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //计算页数-->小数-->四舍五入

    
    CGFloat page = scrollView.contentOffset.x / scrollView.width;
    self.pageControl.currentPage = (int)(page + 0.5);
    //    NSLog(@"%f%f%f",page,scrollView.contentOffset.x,scrollView.contentSize.width);
    if (scrollView.contentSize.width < scrollView.contentOffset.x + scrollView.width) {
        NSLog(@"最后一页了");
        if (_currentType == EmotionToolBarButtonTypeMagic) {
//            _currentType = 1000;
            _currentType = EmotionToolBarButtonTypeCollect;
            
        }
        [scrollView scrollRectToVisible:CGRectMake(0, 0, scrollView.width, scrollView.height) animated:NO];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"scrollviewLastPage" object:[NSString stringWithFormat:@"%lu", _currentType + 1]];
        
    }
    
}


@end




#pragma mark - EmotionKeyboard

@interface EmotionKeyboard()<EmotionToolBarDelegate>

@property (nonatomic, weak) EmotionToolBar *toolBar;

@property (nonatomic, weak) EmotionListView *currentListView;


/**
 *  默认
 */
@property (nonatomic, strong) EmotionListView *defaultListView;

/**
 *  emoji
 */
@property (nonatomic, strong) EmotionListView *emojiListView;


/**
 *  magic
 */
@property (nonatomic, strong) EmotionListView *magicListView;





@end

@implementation EmotionKeyboard

+ (instancetype)sharedEmotionKeyboardView {
    static EmotionKeyboard *view;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        view = [self new];
    });
    return view;
}


- (EmotionListView *)collectListView{
    if (!_collectListView) {
        _collectListView = [[EmotionListView alloc] init];
        _collectListView.Default = NO;
        _collectListView.currentType = EmotionToolBarButtonTypeCollect;
        
    }
    _collectListView.emotions = [EmotionTool CollectImages];
    return _collectListView;
}



- (EmotionListView *)defaultListView{
    if (!_defaultListView) {
        _defaultListView = [[EmotionListView alloc] init];
        
        _defaultListView.Default = YES;
        _defaultListView.currentType = EmotionToolBarButtonTypeDefault;
        _defaultListView.emotions = [EmotionTool defaultEmotions];
        
    }
    return _defaultListView;
}
- (EmotionListView *)emojiListView{
    if (!_emojiListView) {
        _emojiListView = [[EmotionListView alloc] init];
        
        _emojiListView.Default = YES;
        _emojiListView.currentType = EmotionToolBarButtonTypeEmoji;
        _emojiListView.emotions = [EmotionTool emojiEmotions];
    }
    return _emojiListView;
}


- (EmotionListView *)magicListView{
    if (!_magicListView) {
        _magicListView = [[EmotionListView alloc]init];
        _magicListView.Default = NO;
        _magicListView.currentType = EmotionToolBarButtonTypeMagic;
        _magicListView.emotions = [EmotionTool magicEmotions];
    }
    return _magicListView;
}

- (instancetype)initWithDefault{
    
    self = [super initWithFrame:CGRectMake(0, ScreenH - 216, ScreenW, 216)];
    if (self) {

        self.backgroundColor = [UIColor colorWithPatternImage:[EmotionTool emotionImageWithName:@"emoticon_keyboard_background"]];
//                self.backgroundColor = RGBCOLOR(235, 236, 238);
        
        
        
        
        EmotionToolBar *toolBar = [[EmotionToolBar alloc] init];
        //        toolBar.Default = self.Default;
        toolBar.Default = YES;
        toolBar.height = 37;
        toolBar.delegate = self;
        
        //注释工具栏
        [self addSubview:toolBar];
        self.toolBar = toolBar;
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, self.height - toolBar.height, self.width , 0.6)];
        line.backgroundColor = RGBCOLOR(225, 225, 225);
        
        [self addSubview:line];
        
        
        //接收表情点击通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emotionDidSelected:) name:@"EmotionDidSelectedNoti" object:nil];
        
        //删除按钮点击通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emotionDeleteBtnSelected) name:@"EmotionDeleteBtnSelectedNoti" object:nil];
        //发送按钮点击
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(emotionSendBtnSelected) name:@"EmotionSendBtnSelectedNoti" object:nil];
        
         [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(delectCollectImage) name:@"delectCollectImage" object:nil];
        
        
    }
    return self;
    
}



- (instancetype)init{
    
    self = [super initWithFrame:CGRectMake(0, ScreenH - 226, ScreenW, 226)];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithPatternImage:[EmotionTool emotionImageWithName:@"emoticon_keyboard_background"]];
        
        EmotionToolBar *toolBar = [[EmotionToolBar alloc] init];
//        toolBar.Default = YES;
        toolBar.height = 37;
        toolBar.delegate = self;
        [self addSubview:toolBar];
        self.toolBar = toolBar;
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, self.height - toolBar.height, self.width , 0.6)];
        line.backgroundColor = RGBCOLOR(225, 225, 225);
        
        [self addSubview:line];
        
        //接收表情点击通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emotionDidSelected:) name:@"EmotionDidSelectedNoti" object:nil];
        
        //删除按钮点击通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emotionDeleteBtnSelected) name:@"EmotionDeleteBtnSelectedNoti" object:nil];
        //发送按钮点击
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(emotionSendBtnSelected) name:@"EmotionSendBtnSelectedNoti" object:nil];
        
         [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(delectCollectImage) name:@"delectCollectImage" object:nil];
        
        
    }
    return self;
    
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithPatternImage:[EmotionTool emotionImageWithName:@"emoticon_keyboard_background"]];
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, 1)];
        line.backgroundColor = [UIColor lightGrayColor];
        
        //        [self addSubview:line];
        
        EmotionToolBar *toolBar = [[EmotionToolBar alloc] init];
        toolBar.height = 37;
        toolBar.delegate = self;
//        toolBar.alpha = 0.2;
        //注释工具栏
        [self addSubview:toolBar];
        self.toolBar = toolBar;
        
        
        //接收表情点击通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emotionDidSelected:) name:@"EmotionDidSelectedNoti" object:nil];
        
        //删除按钮点击通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emotionDeleteBtnSelected) name:@"EmotionDeleteBtnSelectedNoti" object:nil];
        //发送按钮点击
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(emotionSendBtnSelected) name:@"EmotionSendBtnSelectedNoti" object:nil];
        
        
    }
    return self;
}

-(void)removeAllOberserrr{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - EmotionKeyboard代理方法
/**
 *  表情选中
 *
 *  @param noti <#noti description#>
 */
- (void)emotionDidSelected:(NSNotification *)noti{
    EmotionButton *button = noti.object;
   
    UIButton *btn = (UIButton *)[self.toolBar viewWithTag:EmotionToolBarButtonTypeCollect];
    
    UIButton *btn1 = (UIButton *)[self.toolBar viewWithTag:EmotionToolBarButtonTypeMagic];
    
    BOOL isMagicEmotion = NO;
    if (!btn.isEnabled && btn) {
//        NSLog(@"收藏图片");
        if (button.imageUrl) {
            NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/CollectImage"];
            path = [path stringByAppendingPathComponent:button.imageUrl.lastPathComponent];
            
            if ([self.delegate respondsToSelector:@selector(emoticonCollectImageDidTapUrl:)]) {
               
                [self.delegate emoticonCollectImageDidTapUrl:path];
            }
  
        }
        
    }else if (!btn1.isEnabled && btn1){
//        NSLog(@"魔法表情");
        isMagicEmotion = YES;
        if (button.emotion) {
            if ([self.delegate respondsToSelector:@selector(emoticonMagicEmotionDidTapText:)]) {
                [self.delegate emoticonMagicEmotionDidTapText:button.emotion.chs];
            }
        }
    }
    
    NSString *text = nil;
    if (button.emotion.isEmoji) {
        text = button.titleLabel.text;
    }else{
        text = button.emotion.chs;
    }
    if (!isMagicEmotion && text && [self.delegate respondsToSelector:@selector(emoticonInputDidTapText:)]) {
        [self.delegate emoticonInputDidTapText:text];
    }
//    isMagicEmotion = NO;
    

}



/**
 *  删除按钮点击
 */
- (void)emotionDeleteBtnSelected{
    
    if ([self.delegate respondsToSelector:@selector(emoticonInputDidTapBackspace)]) {
        [[UIDevice currentDevice] playInputClick];
        [self.delegate emoticonInputDidTapBackspace];
    }
}
/**
 *  发送按钮点击
 */
- (void)emotionSendBtnSelected{
    
    if ([self.delegate respondsToSelector:@selector(emoticonInputDidTapSend)]) {
        [[UIDevice currentDevice] playInputClick];
        [self.delegate emoticonInputDidTapSend];
    }
}

- (void)delectCollectImage{
    
    [self emotionToolbar:nil buttonClickWithType:EmotionToolBarButtonTypeCollect];
}


- (void)layoutSubviews{
    [super layoutSubviews];
    
    
    //设置toolBar宽度与y
    self.toolBar.y = self.height - self.toolBar.height;
    self.toolBar.width = self.width;
    
    
    //调整当前要显示的listView的位置与大小
    self.currentListView.width = self.width;
    self.currentListView.height = self.toolBar.y;
    
}



#pragma mark - EmotionToolBar delegate 方法
- (void)emotionToolbar:(EmotionToolBar *)toolBar buttonClickWithType:(EmotionToolBarButtonType)type{
    
    //先移除原来显示的
    [self.currentListView removeFromSuperview];
    
    switch (type) {
        case EmotionToolBarButtonTypeCollect://收藏
            [self addSubview:self.collectListView];
            
            if (_collectListView.emotions.count == 0) {
                UIView *tempView = [[UIView alloc]initWithFrame:self.bounds];
                               UILabel *label = [[UILabel alloc]init];
                label.text = @"见到喜欢的图片长按,即可添加到收藏...";
                label.width = tempView.width;
                label.height = 20;
                label.centerY = tempView.centerY - 37;
                label.centerX = tempView.centerX;
                
                label.font = [UIFont systemFontOfSize: 14];
                label.textColor = [UIColor grayColor];
                label.textAlignment = NSTextAlignmentCenter;
                
                [tempView addSubview:label];
                
                [self addSubview:tempView];
               
            }
            break;
        case EmotionToolBarButtonTypeDefault://默认
            [self addSubview:self.defaultListView];
            break;
        case EmotionToolBarButtonTypeEmoji://emoji
            [self addSubview:self.emojiListView];
            break;
        case EmotionToolBarButtonTypeMagic://魔法
            [self addSubview:self.magicListView];
            break;
    }
    //再赋值当前显示的listView
    self.currentListView = [self.subviews lastObject];
}


- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];

}

@end
