//
//  NFAdvertScrollView.m
//  nationalFitness
//
//  Created by 程long on 14-11-5.
//  Copyright (c) 2014年 chenglong. All rights reserved.
//

#import "NFAdvertScrollView.h"
#import "NFShowImageView.h"

#define kscrollTime 3.0

@implementation NFAdvertScrollView
{
    NSInteger picCount;
    NSTimer *advertTimer_;
    NSInteger nowPage_;
}

-(void)setImageArr:(NSArray *)picUrlArr
{
    picCount = picUrlArr.count;
    
    for (id view in self.subviews)
    {
        if ([view isKindOfClass:[NFShowImageView class]])
        {
            [view removeFromSuperview];
        }
    }
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    NSMutableArray *picMuArr = [[NSMutableArray alloc] initWithArray:picUrlArr];
    if (picCount > 1)
    {
//        img 5,  img1,  img2, img3, img 4 ,img 5 ,img1
        [picMuArr insertObject:[picUrlArr lastObject] atIndex:0];
        [picMuArr addObject:[picUrlArr firstObject]];
    }

    [self setContentSize:CGSizeMake(width * picMuArr.count, height)];
    self.bounces = NO;
    self.showsHorizontalScrollIndicator = FALSE;
    self.showsVerticalScrollIndicator = FALSE;
    self.pagingEnabled = YES;
    
    //创建图片层
    for (NSInteger index = 0; index < picMuArr.count; index ++)
    {
        CGRect picFrame = CGRectMake(index * width, 0, width, height);
        NFShowImageView *advertView = [[NFShowImageView alloc] initWithFrame:picFrame];
        advertView.contentMode = UIViewContentModeScaleAspectFill;
        
        [advertView ShowImageWithUrlStr:[picMuArr objectAtIndex:index] completion:nil];
        
        [self addSubview:advertView];
    }
    
    self.delegate = self;
    
    
    if (picCount > 1)
    {
        [self beginTimeClick];
        [self scrollToIndex:1 animation:NO];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollToIndex:(NSInteger)index animation:(BOOL)animation
{
    CGFloat pageWidth = self.frame.size.width;
    CGFloat pageHeigth = self.frame.size.height;
    [self scrollRectToVisible:CGRectMake(pageWidth * index, 0, pageWidth, pageHeigth) animated:animation];
    nowPage_ = index;
    
    if (picCount > 1)
    {
        if (nowPage_ == 0)
        {
            _currentPage = picCount - 1;
        }
        else if(nowPage_ <= picCount)
        {
            _currentPage = nowPage_ - 1;
        }
        else
        {
            _currentPage = 0;
        }
    }
    
    if (_myDelegate && [_myDelegate respondsToSelector:@selector(showLabelWith:)]) {
        [_myDelegate showLabelWith:_currentPage];
    }
    
    if (nowPage_ == 0 || nowPage_ == picCount + 1)
    {
        [self performSelector:@selector(animatToLast) withObject:nil afterDelay:0.35f];
    }
}

- (void)animatToLast
{
    if (nowPage_ == 0)
    {
        [self scrollToIndex:picCount animation:NO];
    }
    else if(nowPage_ == picCount + 1)
    {
        [self scrollToIndex:1 animation:NO];
    }
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.frame.size.width;
    CGFloat pageHeigth = self.frame.size.height;
    NSInteger currentPage = floor((self.contentOffset.x - pageWidth / 2 ) / pageWidth ) +1;
    
    if (currentPage == 0)
    {
        [self scrollRectToVisible:CGRectMake(pageWidth * picCount, 0, pageWidth, pageHeigth) animated:NO];
    }
    else if(currentPage == picCount + 1)
    {
        [self scrollRectToVisible:CGRectMake(pageWidth, 0, pageWidth, pageHeigth) animated:NO];
    }
    
    nowPage_ = currentPage;

    if (picCount > 1)
    {
        if (nowPage_ == 0)
        {
            _currentPage = picCount - 1;
        }
        else if(nowPage_ <= picCount)
        {
            _currentPage = nowPage_ - 1;
        }
        else
        {
            _currentPage = 0;
        }
    }
    else
    {
        _currentPage = nowPage_;
    }
    
    if (_myDelegate && [_myDelegate respondsToSelector:@selector(showLabelWith:)]) {
        [_myDelegate showLabelWith:_currentPage];
    }
    
    [self beginTimeClick];
}

- (void)beginTimeClick
{
    if (advertTimer_)
    {
        [advertTimer_ invalidate];
        advertTimer_ = nil;
    }
    
    advertTimer_ = [NSTimer scheduledTimerWithTimeInterval:kscrollTime
                                                        target:self
                                                      selector:@selector(gotoNextPic)
                                                      userInfo:nil
                                                       repeats:YES];
}

- (void)gotoNextPic
{
    //last
    nowPage_ ++;
    [self scrollToIndex:nowPage_ animation:YES];
}

- (void)dealloc
{
    [advertTimer_ invalidate];
    advertTimer_ = nil;
}

@end
