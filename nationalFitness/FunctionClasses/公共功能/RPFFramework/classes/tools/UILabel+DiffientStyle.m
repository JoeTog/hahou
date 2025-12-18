//
//  UILabel+DiffientStyle.m
//  NIM
//
//  Created by King on 2019/2/22.
//  Copyright © 2019年 Netease. All rights reserved.
//

#import "UILabel+DiffientStyle.h"

@implementation UILabel (DiffientStyle)


- (void)changeSubStrFont:(UIFont *)font currentText:(NSString *)curTxt;
{
    //label  需要操作的Label
    //font   该字符的字号
    NSMutableAttributedString *noteString = [[NSMutableAttributedString alloc] initWithString:self.text];
    
    if([self.text rangeOfString:curTxt].location != NSNotFound)
    {
        NSRange  subRange  = [self.text rangeOfString:curTxt];//该字符串的位置
        [noteString addAttribute:NSFontAttributeName value:font range:subRange];
        [self setAttributedText: noteString];
    }
    
}



@end
