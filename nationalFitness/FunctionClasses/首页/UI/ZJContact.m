//
//  ZJContact.m
//  ZJIndexContacts
//
//  Created by ZeroJ on 16/10/10.
//  Copyright © 2016年 ZeroJ. All rights reserved.
//

#import "ZJContact.h"
#import "PinYin4Objc.h"
@implementation ZJContact

static BOOL isIncludeChineseInNSString(NSString *string) {
    for (int i=0; i<string.length; i++) {
        unichar ch = [string characterAtIndex:i];
        if (0x4e00 < ch  && ch < 0x9fff) {
            return true;
        }
    }
    return false;
}

+ (NSArray<ZJContact *> *)searchText:(NSString *)searchText inDataArray:(NSArray<ZJContact *> *)dataArray {
    NSMutableArray<ZJContact *> *results = [NSMutableArray array];
    // 参数不合法
    if (searchText.length <= 0 || dataArray.count <= 0) return results;
    
    if (isIncludeChineseInNSString(searchText)) { // 输入了中文-只查询中文
        for (ZJContact *contact in dataArray) {
            NSRange resultRange = [contact.friend_username rangeOfString:searchText options:NSCaseInsensitiveSearch];
            NSRange secResultRange = [contact.friend_nickname rangeOfString:searchText options:NSCaseInsensitiveSearch];
            NSRange thirdResultRange = [contact.friend_comment_name rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (resultRange.length > 0 || secResultRange.length > 0  || thirdResultRange.length > 0) {// 找到了
                [results addObject:contact];
            }
        }
    }
    else {
        for (ZJContact *contact in dataArray) {
            if (isIncludeChineseInNSString(contact.friend_username) || isIncludeChineseInNSString(contact.friend_nickname)) {// 待查询中有中文--转为拼音
                // 设置输入格式
                HanyuPinyinOutputFormat *outputFormat = [[HanyuPinyinOutputFormat alloc] init];
                [outputFormat setToneType:ToneTypeWithoutTone];
                [outputFormat setVCharType:VCharTypeWithV];
                [outputFormat setCaseType:CaseTypeLowercase];
                
                static NSString *const separatorString = @" ";
                // 获取到每个汉字拼音之间有分隔符的拼音
                NSString *completeHasSeparatorPinyin = [PinyinHelper toHanyuPinyinStringWithNSString:contact.friend_username withHanyuPinyinOutputFormat:outputFormat withNSString:separatorString];
                NSString *SeccCompleteHasSeparatorPinyin = [PinyinHelper toHanyuPinyinStringWithNSString:contact.friend_nickname withHanyuPinyinOutputFormat:outputFormat withNSString:separatorString];
                // 处理多音字 -- 这里只处理了 '曾'
                if (([contact.friend_username hasPrefix:@"曾"] || [contact.friend_nickname hasPrefix:@"曾"]) && [completeHasSeparatorPinyin hasPrefix:@"c"]) {
                    completeHasSeparatorPinyin = [completeHasSeparatorPinyin stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"z"];
                }
                // 删除分隔符
                NSString *completeNOSeparatorPinyin = [completeHasSeparatorPinyin stringByReplacingOccurrencesOfString:separatorString withString:@""];
                NSString *SecCompleteNOSeparatorPinyin = [SeccCompleteHasSeparatorPinyin stringByReplacingOccurrencesOfString:separatorString withString:@""];

                // 查询没有分隔符中是否包含 (不能使用有分隔符的拼音来查询, 因为输入的里面可能不会包含分隔符, 导致查询不到)
                NSRange resultRange = [completeNOSeparatorPinyin rangeOfString:searchText options:NSCaseInsensitiveSearch];
                NSRange SecResultRange = [SecCompleteNOSeparatorPinyin rangeOfString:searchText options:NSCaseInsensitiveSearch];
                if (resultRange.length > 0 || SecResultRange.length > 0) {// 找到了
                    [results addObject:contact];
                    continue; // 进入下一次循环, 不再执行下面这段代码
                }
                NSMutableString *headOfPinyin = [NSMutableString string];
                NSMutableString *SecheadOfPinyin = [NSMutableString string];
                
                NSArray *pinyinArray = [completeHasSeparatorPinyin componentsSeparatedByString:separatorString];
                NSArray *SecpinyinArray = [SeccCompleteHasSeparatorPinyin componentsSeparatedByString:separatorString];
                
                for (NSString *singlePinyin in pinyinArray) {
                    if (singlePinyin) { // 取每个拼音的首字母
                        [headOfPinyin appendString:[singlePinyin substringToIndex:1]];
                    }
                }
                for (NSString *singlePinyin in SecpinyinArray) {
                    if (singlePinyin && singlePinyin.length > 0) { // 取每个拼音的首字母
                        [SecheadOfPinyin appendString:[singlePinyin substringToIndex:1]];
                    }
                }
                
                NSRange headResultRange = [headOfPinyin rangeOfString:searchText options:NSCaseInsensitiveSearch];
                NSRange SecheadResultRange = [headOfPinyin rangeOfString:searchText options:NSCaseInsensitiveSearch];
                if (headResultRange.length > 0 || SecheadResultRange.length > 0) {// 找到了
                    [results addObject:contact];
                }
            }
            else { // 姓名是英文的, 那么直接查询英文
                NSRange resultRange = [contact.friend_username rangeOfString:searchText options:NSCaseInsensitiveSearch];
                NSRange secResultRange = [contact.friend_nickname rangeOfString:searchText options:NSCaseInsensitiveSearch];
                if (resultRange.length > 0 || secResultRange.length > 0) {// 找到了
                    [results addObject:contact];
                }
            }
        }
    }
    return results;
}


@end
