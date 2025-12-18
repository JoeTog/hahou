//
//  RPFRedpacketResultCell.m
//  NIM
//
//  Created by King on 2019/2/8.
//  Copyright © 2019年 Netease. All rights reserved.
//

#import "RPFRedpacketResultCell.h"
#import "UIImageView+WebCache.h"
#import "RPFTool.h"

@implementation RPFRedpacketResultCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


+(instancetype)xibTableViewCell{
    NSLog(@"%s",__func__);
    RPFRedpacketResultCell * theCelll = (RPFRedpacketResultCell *)[[[NSBundle mainBundle] loadNibNamed:@"RPFRedpacketResultCell" owner:nil options:nil] lastObject];
    [theCelll.headImgView.layer setCornerRadius:HEAD_IMG_CornerRadius];
    [theCelll.headImgView.layer setMasksToBounds:YES];
    
    return theCelll;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        //初始化子类
        NSLog(@"%s",__func__);
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    return self;
}


-(void)refreshData:(NSDictionary *)dic
{
    /*
     {
     "getuserId": "19951533619",
     "redpacketId": "20190214d667723f31ee7a2fe58e0004b1210615",
     "userName": "2019",
     "userHeadUrl": "",
     "isGroup": "",
     "gettimes": 1550133289,
     "money": 6573,
     "isBestLuck": 0
     }
     */
    
    self.name.text = dic[@"userName"]?dic[@"userName"]:@"";

    //[self.headImgView nim_setImageWithURL:[NSURL URLWithString:dic[@"userHeadUrl"]?dic[@"userHeadUrl"]:@""] placeholderImage:[UIImage imageNamed:@"avatar_user"]];
    NSString *urlS = @"";
    if([[dic[@"userHeadUrl"] description] containsString:@"http"]){
        urlS = dic[@"userHeadUrl"]?dic[@"userHeadUrl"]:@"";
    }else{
        urlS = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,dic[@"userHeadUrl"]?dic[@"userHeadUrl"]:@""];
    }
    
    
    [self.headImgView sd_setImageWithURL:[[NSURL alloc] initWithString:urlS] placeholderImage:[UIImage imageNamed:@"avatar_user"]];
    [self.bestLuckBtn.imageView setImage:[UIImage imageNamed:@"ic_crown"]];
    //[self.bestLuckBtn setImage:[UIImage imageNamed:@"ic_crown"] forState:UIControlStateNormal];
    
    if([dic[@"isBestLuck"] intValue]==1)
    {
        self.bestLuckBtn.hidden = NO;
    }
    else
    {
        self.bestLuckBtn.hidden = YES;
    }
    
    self.time.text = [RPFTool ConvertStrToTime:[NSString stringWithFormat:@"%@",dic[@"gettimes"]]];
    self.moneyLabel.text = [NSString stringWithFormat:@"%.2f元 ",[dic[@"money"] intValue]*0.01];
    
    self.userId = dic[@"getuserId"];
    self.redpacketId = dic[@"redpacketId"];

    
    
}



@end
