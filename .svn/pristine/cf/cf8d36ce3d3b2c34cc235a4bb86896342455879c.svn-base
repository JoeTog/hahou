//
//  ZBFaceView.m
//  MessageDisplay
//
//  Created by zhoubin@moshi on 14-5-13.
//  Copyright (c) 2014年 Crius_ZB. All rights reserved.
//

#import "ZBFaceView.h"

//每行
#define NumPerLine 4
//几行
#define Lines    2
//表情大小
#define FaceSize  50
/*
** 两边边缘间隔
 */
#define EdgeDistance 20
/*
 ** 上下边缘间隔
 */
#define EdgeInterVal 5

@implementation ZBFaceView
{
    //表情文件
    NSDictionary *plistDic;
}

- (id)initWithFrame:(CGRect)frame forIndexPath:(NSInteger)index
{
    self = [super initWithFrame:frame];
    if (self) {
        
        if (!plistDic)
        {
            NSString *plistStr = [[NSBundle mainBundle]pathForResource:@"expression" ofType:@"plist"];
            plistDic = [[NSDictionary  alloc]initWithContentsOfFile:plistStr];
        }
        
        // 水平间隔
        CGFloat horizontalInterval = (CGRectGetWidth(self.bounds)-NumPerLine*FaceSize -2*EdgeDistance)/(NumPerLine-1);
        // 上下垂直间隔
        CGFloat verticalInterval = (CGRectGetHeight(self.bounds)-2*EdgeInterVal -Lines*FaceSize)/(Lines-1) - 1;
        
        NSLog(@"%f,%f",verticalInterval,CGRectGetHeight(self.bounds));
        
        for (int i = 0; i<Lines; i++)
        {
            for (NSInteger x = 0;x<NumPerLine;x++)
            {
                UIButton *expressionButton =[UIButton buttonWithType:UIButtonTypeCustom];
                [expressionButton setFrame:CGRectMake(x*FaceSize+EdgeDistance+x*horizontalInterval,
                                                      i*FaceSize +i*verticalInterval+EdgeInterVal,
                                                      FaceSize,
                                                      FaceSize + 10)];
                expressionButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
                [expressionButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                
//                if (i*7+x+1 == 21) {
//                    [expressionButton setBackgroundImage:[UIImage imageNamed:@"DeleteEmoticonBtn_ios7@2x.png"]
//                                                forState:UIControlStateNormal];
//                    expressionButton.tag = 0;
//        
//                }else{
                    //smiley_0.png 的tag 是1,以此类推
                    
                    NSString *imageStr = [NSString stringWithFormat:@"smiley_%@.png",@(index*8+i*NumPerLine+x)];
                    [expressionButton setImage:[UIImage imageNamed:imageStr] forState:UIControlStateNormal];
                    //8是每页总表情个数
                    expressionButton.tag = 8 * index + i * NumPerLine + x + 1;
                    //设置文字的位置和图片位置
                    for (int j = 0; j<[[plistDic allKeys]count]; j++)
                    {
                        if ([[plistDic objectForKey:[[plistDic allKeys]objectAtIndex:j]]
                             isEqualToString:[NSString stringWithFormat:@"%@",imageStr]])
                        {
                            NSString *nameStr = [[[[plistDic allKeys]objectAtIndex:j] componentsSeparatedByString:@"["] lastObject];
                            [expressionButton setTitle:[[nameStr componentsSeparatedByString:@"]"] firstObject] forState:UIControlStateNormal];
                            NSLog(@"add by yaowen %@",expressionButton.titleLabel.text);
                        }
                    }
                    [expressionButton setImageEdgeInsets:UIEdgeInsetsMake(0, 7, 23, 7)];
                    [expressionButton setTitleEdgeInsets:UIEdgeInsetsMake(40, - 99, 0, 0)];
//                }
                [expressionButton addTarget:self
                                     action:@selector(faceClick:)
                           forControlEvents:UIControlEventTouchUpInside];
                
                [self addSubview:expressionButton];
            }
        }
    }
    return self;
}

- (void)faceClick:(UIButton *)button{
    
    NSString *faceName;
    BOOL isDelete;
    if (button.tag ==0)
    {
        faceName = nil;
        isDelete = YES;
    }else
    {
        NSString *expressstring = [NSString stringWithFormat:@"smiley_%@.png",@(button.tag-1)];
        if (!plistDic)
        {
            NSString *plistStr = [[NSBundle mainBundle]pathForResource:@"expression" ofType:@"plist"];
            plistDic = [[NSDictionary  alloc]initWithContentsOfFile:plistStr];
        }
        
        for (int j = 0; j<[[plistDic allKeys]count]; j++)
        {
            if ([[plistDic objectForKey:[[plistDic allKeys]objectAtIndex:j]]
                 isEqualToString:[NSString stringWithFormat:@"%@",expressstring]])
            {
                NSString *nameStr = [[[[plistDic allKeys]objectAtIndex:j] componentsSeparatedByString:@"["] lastObject];
                faceName = [[nameStr componentsSeparatedByString:@"]"] firstObject];
                break;
            }
        }
        isDelete = NO;
    }
    
    if (nil == faceName
        && !isDelete)
    {
        NSLog(@"没有表情 被点击");
        return;
    }
    
    if (nil == faceName
        && isDelete)
    {
        NSLog(@"删除表情按钮");
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelecteFace:andIsSelecteDelete:)]) {
        [self.delegate didSelecteFace:faceName andIsSelecteDelete:isDelete];
    }
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
