//
//  HotPictureShowViewController.m
//

#import "HDPictureShowViewController.h"
#import "LWPictureZoomableView.h"

#define hotPicShowTagForTitle           11

@interface HDPictureShowViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;

@property (nonatomic, strong) UIView *navigationBarView;

// scroll view 上当前显示的页数
@property (nonatomic) NSUInteger currentPage;
// scroll view 上显示的总页数
@property (nonatomic) NSUInteger totalPages;
// scroll view 上每页显示的内容
@property (nonatomic, strong) NSMutableArray *contentViews;

// navigation bar 当前状态
@property (nonatomic) BOOL expanded;

@end


@implementation HDPictureShowViewController

-(void)showNavigationTitle{
    CGRect navBarFrame = self.navigationBarView.frame;
    navBarFrame.origin.y = SCREEN_HEIGHT - navBarFrame.size.height - 10;
    
    [UIView animateWithDuration:0.8 delay:0.1 usingSpringWithDamping:0.7 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.navigationBarView.frame = navBarFrame;
    } completion:^(BOOL finished) {
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.view addSubview:self.scrollView];
    
    // Do any additional setup after loading the view.
    
    //隐藏 返回按钮
    [self setupNavigationBarView];
    //进来就显示 navigation joe修改
    if (self.isLuoYang) {
        [self showNavigationTitle];
    }
    
    self.expanded = NO;
    self.view.backgroundColor = [UIColor blackColor];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSTapGesture:)];
    [self.view addGestureRecognizer:tapGesture];

    // 设置 scroll view
    self.totalPages = [self.imageUrlList count];
    NSMutableArray *views = [NSMutableArray array];
    for (NSUInteger i = 0; i < self.totalPages; i++) {
        [views addObject:[NSNull null]];
    }
    self.contentViews = views;
     
    CGFloat contentWidth = self.totalPages * self.scrollView.frame.size.width;
    //568改称SCREEN_HEIGHT，3.5屏幕适配－cl－7.29
    CGFloat expectedHeight = self.scrollView.frame.size.height - (SCREEN_HEIGHT - self.view.frame.size.height);
    self.scrollView.contentSize = CGSizeMake(contentWidth, expectedHeight);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    
    self.currentPage = _mainImageIndex;
    [self loadScrollViewWithPage:_mainImageIndex];
    CGPoint point = CGPointMake(_mainImageIndex * self.scrollView.frame.size.width, 0);
    [self.scrollView setContentOffset:point animated:NO];
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)setupNavigationBarView
{
//    self.navigationBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, -44.0f, SCREEN_WIDTH, 44.0f)];
    self.navigationBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, SCREEN_HEIGHT + 44.0f, SCREEN_WIDTH, 44.0f)];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setImage:[UIImage imageNamed:@"返回-左"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(handleLeftBtn) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(10.0f, 7.0f, 42.0f, 34.0f);
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 149)/2, 11.0f, 149.0f, 21.0f)];
    titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.tag = hotPicShowTagForTitle;
    //是否隐藏返回按钮
    if (!self.isLuoYang) {
        [self.navigationBarView addSubview:leftButton];
    }
    [self.navigationBarView addSubview:titleLabel];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handleDummyAction:)];
    [self.navigationBarView addGestureRecognizer:tapGesture];
    
    self.navigationBarView.backgroundColor = [[UIColor colorThemeColor] colorWithAlphaComponent:0.0];
    if (self.isNeedNavigation) {
        [self.view addSubview:self.navigationBarView];
    }
}

- (void)loadScrollViewWithPage:(NSUInteger)page
{
    if (page >= self.totalPages) return;
    
    LWPictureZoomableView *view = [self.contentViews objectAtIndex:page];
    if ((NSNull *)view == [NSNull null]) {
        CGRect frame = self.scrollView.frame;
        frame.origin.x = CGRectGetWidth(frame) * page;
        frame.origin.y = 0;
        //568改称SCREEN_HEIGHT，3.5屏幕适配－cl－7.29
        frame.size.height = self.scrollView.frame.size.height - (SCREEN_HEIGHT - self.view.frame.size.height);
        view = [[LWPictureZoomableView alloc] initWithFrame:frame];
        if ([self.imageUrlList[page] isKindOfClass:[NSString class]]) {
            [view setupWithUrl:self.imageUrlList[page]];
        }else if ([self.imageUrlList[page] isKindOfClass:[SGPhoto class]]){
            SGPhoto *photo = self.imageUrlList[page];
            [view setupWithImageData:photo.fullResolutionImage];
        }
        
        [self.contentViews replaceObjectAtIndex:page withObject:view];
        [self.scrollView addSubview:view];
    }
    
    if (page == self.currentPage) {
        UILabel *titleLabel = (UILabel *)[self.navigationBarView viewWithTag:hotPicShowTagForTitle];
        titleLabel.text = [NSString stringWithFormat:@"%@/%@", @(page+1), @(self.totalPages)];
    } else if (view.zoomScale != 1.0f) {
        view.zoomScale = 1.0f;
    }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
    NSUInteger page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    self.currentPage = page;
    
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
}


#pragma  mark - UIGestureRecognizer

- (void)handleSTapGesture:(UITapGestureRecognizer*)recognizer
{
    if (self.isLuoYang) {
        //点击返回 joe修改
        [self.navigationController popViewControllerAnimated:YES];
    }else{
            self.expanded = !self.expanded;
            if (self.expanded) {
                // 显示 navigation bar, tool bar,并上移 info view
                CGRect navBarFrame = self.navigationBarView.frame;
                navBarFrame.origin.y = 20.0f;
        
                [UIView animateWithDuration:0.8 delay:0.1 usingSpringWithDamping:0.7 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.navigationBarView.frame = navBarFrame;
                } completion:^(BOOL finished) {
                }];
            } else {
                // 隐藏 navigation bar, tool bar,并下移 info view
                CGRect navBarFrame = self.navigationBarView.frame;
                navBarFrame.origin.y = - navBarFrame.size.height;
        
                [UIView animateWithDuration:0.8 delay:0.1 usingSpringWithDamping:0.7 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.navigationBarView.frame = navBarFrame;
                } completion:^(BOOL finished) {
                }];
            }

    }
    
}

- (void)handleDummyAction:(UITapGestureRecognizer*)recognizer
{
    // nothing to do ...
}

#pragma mark - Action Message

- (void)handleLeftBtn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    self.scrollView.delegate = nil;
}

@end
