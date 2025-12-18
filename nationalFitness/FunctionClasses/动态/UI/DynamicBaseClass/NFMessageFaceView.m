//
//  NFMessageFaceView.m
//  newTestUe
//
//  Created by liumac on 15/12/21.
//  Copyright © 2015年 程龙. All rights reserved.
//

#import "NFMessageFaceView.h"
#import "ZBExpressionSectionBar.h"

#define FaceSectionBarHeight  36   // 表情下面控件
#define FacePageControlHeight 30  // 表情pagecontrol

//表情的页数
#define Pages 7

@implementation NFMessageFaceView
{
    UIPageControl *pageControl;
    
    // 如果当前页面的表情已经加载了 就不再alloc
    BOOL setFace[7];
    
    // 当前页数
    NSInteger currentPage;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)dealloc
{
    
}

- (void)setup{
    
    self.backgroundColor = [UIColor whiteColor];
    currentPage = 1;
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0.0f,0.0f,CGRectGetWidth(self.bounds),CGRectGetHeight(self.bounds)-FacePageControlHeight-FaceSectionBarHeight)];
    scrollView.delegate = self;
    [self addSubview:scrollView];
    [scrollView setPagingEnabled:YES];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setContentSize:CGSizeMake(CGRectGetWidth(scrollView.frame)*Pages,CGRectGetHeight(scrollView.frame))];
    
    // 先加载两页
    for (NSInteger i= 0;i<2;i++)
    {
        ZBFaceView *faceView = [[ZBFaceView alloc]initWithFrame:CGRectMake(i*CGRectGetWidth(self.bounds),0.0f,CGRectGetWidth(self.bounds),CGRectGetHeight(scrollView.bounds)) forIndexPath:i];
        [scrollView addSubview:faceView];
        faceView.delegate = self;
    }
    
    pageControl = [[UIPageControl alloc]init];
    [pageControl setFrame:CGRectMake(0,CGRectGetMaxY(scrollView.frame),CGRectGetWidth(self.bounds),FacePageControlHeight)];
    [self addSubview:pageControl];
    [pageControl setPageIndicatorTintColor:[UIColor lightGrayColor]];
    [pageControl setCurrentPageIndicatorTintColor:[UIColor grayColor]];
    pageControl.numberOfPages = Pages;
    pageControl.currentPage   = 0;
    
    
    ZBExpressionSectionBar *sectionBar = [[ZBExpressionSectionBar alloc]initWithFrame:CGRectMake(0.0f,CGRectGetMaxY(pageControl.frame),CGRectGetWidth(self.bounds), FaceSectionBarHeight)];
    [self addSubview:sectionBar];
}

#pragma mark  scrollView Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger page = scrollView.contentOffset.x/320;
    pageControl.currentPage = page;
    
    // 一次只加载一页 这样就避免界面卡顿
    if (page == currentPage)
    {
        if (setFace[currentPage] && currentPage > 5)
        {
            // 如果当前界面已经加载了 就不重复创建
            return;
        }
        for (NSInteger i= currentPage + 1;i<currentPage + 2;i++)
        {
            ZBFaceView *faceView = [[ZBFaceView alloc]initWithFrame:CGRectMake(i*CGRectGetWidth(self.bounds),0.0f,CGRectGetWidth(self.bounds),CGRectGetHeight(scrollView.bounds)) forIndexPath:i];
            [scrollView addSubview:faceView];
            faceView.delegate = self;
        }
        currentPage ++;
        setFace[currentPage] = YES;
    }
}

#pragma mark ZBFaceView Delegate
- (void)didSelecteFace:(NSString *)faceName andIsSelecteDelete:(BOOL)del{
    if ([self.delegate respondsToSelector:@selector(SendTheFaceStr:isDelete:) ]) {
        [self.delegate SendTheFaceStr:faceName isDelete:del];
    }
}

@end
