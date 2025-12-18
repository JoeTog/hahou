//
//  HotPictureShowViewController.h   预览大图
//

#import "NFbaseViewController.h"

#import "SGPhotoPickerViewController.h"


@interface HDPictureShowViewController : NFbaseViewController

// 图片URL列表
@property (nonatomic, strong) NSArray *imageUrlList;
//默认展示第几张
@property (nonatomic,assign) NSInteger mainImageIndex;

//判断是否需要洛阳版本的 点击图片返回功能
@property (nonatomic) BOOL isLuoYang;

//是否需要 navigation
@property (nonatomic) BOOL isNeedNavigation;

@end
