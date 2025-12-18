//
//  EGORefreshTableHeaderView.m
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "EGORefreshTableHeaderView.h"
#import "PublicDefine.h"


#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f


@interface EGORefreshTableHeaderView (Private)
- (void)setState:(EGOPullRefreshState)aState;
@end

@implementation EGORefreshTableHeaderView

//@synthesize delegate=_delegate;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = UIColorFromRGB(0xeff4f5);
        self.backgroundColor = [UIColor blackColor];
        self.backgroundColor = [UIColor whiteColor];
        self.backgroundColor = UIColorFromRGB(0xededf3);
        //设置动画图片位置
        HUDImageView_ = [[UIImageView alloc] initWithFrame:CGRectMake(0, frame.size.height - 70.0f, SCREEN_WIDTH, 60.0f)];
        HUDImageView_.contentMode = UIViewContentModeCenter;
        UIImage *imageA = [UIImage imageNamed:@"1"];
        UIImage *imageB = [UIImage imageNamed:@"2"];
        UIImage *imageC = [UIImage imageNamed:@"3"];
        UIImage *imageD = [UIImage imageNamed:@"3"];
        UIImage *imageE = [UIImage imageNamed:@"4"];
        UIImage *imageF = [UIImage imageNamed:@"5"];
        UIImage *imageG = [UIImage imageNamed:@"6"];
        HUDImageView_.image = imageA;
        [HUDImageView_ setAnimationImages:@[imageA,imageB,imageC,imageD,imageE,imageF,imageG]];
//        [self addSubview:HUDImageView_];
        HUDImageView_.animationDuration = 0.88f;
        HUDImageView_.animationRepeatCount = 0;
		[self setState:EGOOPullRefreshNormal];
        
    }
	
    return self;
}


#pragma mark -
#pragma mark Setters
- (void)refreshLastUpdatedDate {
	
	//if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceLastUpdated:)]) {
    if (_delegate) {
		
//		NSDate *date = [_delegate egoRefreshTableHeaderDataSourceLastUpdated:self];
		
	} else {
		
	}
}

- (void)setLogo{
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.frame.size.height)];
    imageV.image = [UIImage imageNamed:@"下拉主图"];
    [self addSubview:imageV];
}

- (void)setState:(EGOPullRefreshState)aState{
	
	switch (aState) {
		case EGOOPullRefreshPulling:
			
			//_statusLabel.text = NSLocalizedString(@"Release to refresh...", @"Release to refresh status");
//            _statusLabel.text = @"松手刷新";
            
            [HUDImageView_ startAnimating];
            
			break;
		case EGOOPullRefreshNormal:
			
			if (_state == EGOOPullRefreshPulling) {
                
                [HUDImageView_ stopAnimating];
			}
			
//            _statusLabel.text = @"下拉刷新";
            
            [HUDImageView_ stopAnimating];
            
			[self refreshLastUpdatedDate];
			
			break;
		case EGOOPullRefreshLoading:
            
			//_statusLabel.text = NSLocalizedString(@"Loading...", @"Loading Status");
//            _statusLabel.text = @"刷新中";
            
            [HUDImageView_ startAnimating];
            
			break;
		default:
			break;
	}
	
	_state = aState;
}


#pragma mark -
#pragma mark ScrollView Methods

- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView {	
	
    if (scrollView.contentOffset.y >= -65.0f)
    {
    }
    
	if (_state == EGOOPullRefreshLoading) {
		
		CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
		offset = MIN(offset, 60);
		scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
		
	} else if (scrollView.isDragging) {
		
		BOOL _loading = NO;
//		if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
//			_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
//		}
        if (_delegate) {
            _loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
		}
		
		if (_state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !_loading) {
			[self setState:EGOOPullRefreshNormal];
		} else if (_state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -65.0f && !_loading) {
			[self setState:EGOOPullRefreshPulling];
		}
		
		if (scrollView.contentInset.top != 0) {
			scrollView.contentInset = UIEdgeInsetsZero;
		}
		
	}
	
}

- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
	
	BOOL _loading = NO;
//	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
//		_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
//	}
    if (_delegate) {
		_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
	}
	if (scrollView.contentOffset.y <= - 65.0f && !_loading) {
		
//		if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:)]) {
//			[_delegate egoRefreshTableHeaderDidTriggerRefresh:self];
//		}
        if (_delegate) {
			[_delegate egoRefreshTableHeaderDidTriggerRefresh:self];
		}
		
		[self setState:EGOOPullRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		scrollView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
		
	}
	
}

- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {	
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	
	[self setState:EGOOPullRefreshNormal];

}

- (void)setStatus:(NSString*)status {
  
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
    HUDImageView_ = nil;
}


@end
