//
//  SGPhotoPickerView.m
//  SmartCity
//
//  Created by sea on 14-4-15.
//  Copyright (c) 2014年 sea. All rights reserved.
//

#import "SGPhotoPickerView.h"

@implementation SGPhotoPickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        CGRect rect = self.bounds;
        rect.origin.y += 5;
        rect.size.height -= 5;
        _photosTableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
//        _photosTableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    [self addSubview:_photosTableView];
}


@end
