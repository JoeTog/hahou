//
//  UUMessageFrame.m
//  UUChatDemoForTextVoicePicture
//
//  Created by shake on 14-8-26.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import "UUMessageFrame.h"
#import "UUMessage.h"
#import "SDImageCache.h"



@implementation UUMessageFrame

- (void)setMessage:(UUMessage *)message{
    //收到消息 会走两次这里，不走这里两次可能会导致赋值无效，这里进行了懒运算 不会消耗很多时间
    _message = message;
    
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    
    // 1、计算时间的位置 _showTimeHead
    if (_showTimeHead){
        CGFloat timeY = ChatMargin;
        CGSize timeSize = [_message.strTime sizeWithFont:ChatTimeFont constrainedToSize:CGSizeMake(300, 100) lineBreakMode:NSLineBreakByWordWrapping];
        
        CGFloat timeX = (screenW - timeSize.width) / 2;
        _timeF = CGRectMake(timeX, timeY, timeSize.width + ChatTimeMarginW, timeSize.height + ChatTimeMarginH);
    }
    // 2、计算头像位置
    CGFloat iconX = ChatMargin;
    if (_message.from == UUMessageFromMe) {
        iconX = screenW - ChatMargin - ChatIconWH;
    }
    CGFloat iconY = CGRectGetMaxY(_timeF) + ChatMargin;
    _iconF = CGRectMake(iconX, iconY, ChatIconWH, ChatIconWH);
    
    // 3、计算ID位置
    _nameF = CGRectMake(iconX, iconY+ChatIconWH, ChatIconWH, 20);
    
    // 4、计算内容位置
    CGFloat contentX = CGRectGetMaxX(_iconF)+ChatMargin;
    CGFloat contentY = iconY;
    contentY = 37;
   
    //根据种类分
    CGSize contentSize;
    switch (_message.type) {
        case UUMessageTypeText:
//            contentSize = CGSizeMake(ChatContentW, [_message.strContent boundingRectWithSize:CGSizeMake(ChatContentW, 2000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size.height);
            //这里font就是14 代码设置的14。xib中是11
            if (_message.from == UUMessageFromOther && SCREEN_WIDTH == 320) {
                contentSize = [_message.strContent boundingRectWithSize:CGSizeMake(ChatContentW - 28, 20000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:ChatContentFont} context:nil].size;
            }else{
                contentSize = [_message.strContent boundingRectWithSize:CGSizeMake(ChatContentW, 20000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:ChatContentFont} context:nil].size;
            }
            
//            contentSize = [_message.strContent sizeWithFont:ChatContentFont  constrainedToSize:CGSizeMake(ChatContentW, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
            break;
        case UUMessageTypePicture:{
            //_message
            CGFloat itemW = 0;
            CGFloat itemH = 0;
            //当单聊请求历史记录时，这里的pictureScale才有值，其他的走正常逻辑【因为请求单聊历史到这里时 还没有将图片根据picpath缓存成功 需要根据获取到的image设置pictureScale 这里才能计算出图片的具体宽高，进这里的if虽然看起来没什么代码，其实在之前讲data转成image已经消耗了大量的资源】
            if (_message.pictureScale > 0) {
                //
                if (_message.pictureScale > 0 && _message.pictureScale < 1) {
                    itemW = ChatPicWH * _message.pictureScale;
                }else if (_message.pictureScale > 1){
                    itemH = ChatPicWH / _message.pictureScale;
                }else{
                    //宽高都为0 显示正方形 一般不会到这里
                }
            }else{
                if (_message.picture) {
                    //当有image
                    if (_message.picture.size.height > _message.picture.size.width) {
                        itemW = _message.picture.size.width / _message.picture.size.height * ChatPicWH;
                    }else{
                        itemH = _message.picture.size.height / _message.picture.size.width * ChatPicWH;
                    }
                }else{
                    //没有image的时候，根据picpath从数据库取
                    _message.picture = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:_message.cachePicPath];
                    if (_message.picture) {
                        //取到了
                        if (_message.picture.size.height > _message.picture.size.width) {
                            itemW = _message.picture.size.width / _message.picture.size.height * ChatPicWH;
                        }else{
                            itemH = _message.picture.size.height / _message.picture.size.width * ChatPicWH;
                        }
                    }else{
                        //宽高都为0 显示正方形 一般不会到这里
                    }
                }
            }
            contentSize = CGSizeMake(itemW == 0?ChatPicWH:itemW, itemH == 0?ChatPicWH:itemH);
            break;
        }
        case UUMessageTypeVoice:
            contentSize = CGSizeMake(80, 20);
            break;
        case UUMessageTypeRedRobRecord:
            //            contentSize = CGSizeMake(ChatContentW, [_message.strContent boundingRectWithSize:CGSizeMake(ChatContentW, 2000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size.height);
            //这里font就是14 代码设置的14。xib中是11
            if (_message.from == UUMessageFromOther && SCREEN_WIDTH == 320) {
                contentSize = [_message.strContent boundingRectWithSize:CGSizeMake(ChatContentW - 28, 20000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:ChatContentFont} context:nil].size;
            }else{
                contentSize = [_message.strContent boundingRectWithSize:CGSizeMake(ChatContentW, 20000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:ChatContentFont} context:nil].size;
            }
            
            //            contentSize = [_message.strContent sizeWithFont:ChatContentFont  constrainedToSize:CGSizeMake(ChatContentW, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
            break;
        default:
            break;
    }
    
    if (_message.from == UUMessageFromMe) {
        contentX = iconX - contentSize.width - ChatContentLeft - ChatContentRight - ChatMargin;
    }
    _contentF = CGRectMake(contentX, 0, contentSize.width + ChatContentLeft + ChatContentRight, contentSize.height + ChatContentTop + ChatContentBottom);
    if (_showTimeHead) {
//        NSLog(@"%f&%f",CGRectGetMaxY(_contentF)+ contentY,CGRectGetMaxY(_nameF));
        _cellHeight = MAX(CGRectGetMaxY(_contentF) + contentY, CGRectGetMaxY(_nameF))  + ChatMargin;
        _cellHeight = CGRectGetMaxY(_contentF) + contentY;
    }else{
        //contentY距离上面距离为37。 文本内容与按钮上下边缘间隔共30
//        NSLog(@"%f&%f",CGRectGetMaxY(_contentF)+ contentY,CGRectGetMaxY(_nameF));
        _cellHeight = MAX(CGRectGetMaxY(_contentF)+ contentY - 20, CGRectGetMaxY(_nameF))  + ChatMargin ;
        _cellHeight = CGRectGetMaxY(_contentF)+ contentY - 20;
        
    }
}




@end
