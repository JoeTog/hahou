//
//  RPFRedpacketRecordCell.m
//  NIM
//
//  Created by King on 2019/2/23.
//  Copyright © 2019年 Netease. All rights reserved.
//

#import "RPFRedpacketRecordCell.h"
#import "RPFTool.h"


@implementation RPFRedpacketRecordCell

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
    RPFRedpacketRecordCell * theCelll = (RPFRedpacketRecordCell *)[[[NSBundle mainBundle] loadNibNamed:@"RPFRedpacketRecordCell" owner:nil options:nil] lastObject];
    
    return theCelll;
}


-(void)refreshData:(NSDictionary *)dic type:(BOOL)type
{
    /*
     "getuserId": "test22",
     "redpacketId": "20190214d667723f31ee7a2fe58e0004b1210615",
     "userName": "测试",
     "userHeadUrl": "",
     "isGroup": "",
     "gettimes": 1550133360,
     "money": 39276,
     "isBestLuck": 1
     */
    
    if(type)
    {
        [self.userNameBtn setTitle:dic[@"userName"]?dic[@"userName"]:@"" forState:UIControlStateNormal];
        self.timeLabel.text = [RPFTool ConvertStrToTime:[NSString stringWithFormat:@"%@",dic[@"gettimes"]]];
        self.moneyLabel.text = [NSString stringWithFormat:@"%.2f元 ",[dic[@"money"] intValue]*0.01];
        self.userId = dic[@"getuserId"];
        self.redpacketId = dic[@"redpacketId"];
    }
    else
    {
        /*
         {
         isend : 1,
         sendtimes : 1552221501,
         count : 2,
         totalMoney : 300,
         isGroup : 1,
         type : 0,
         title : 红包,
         singleMoney : 0,
         sessionId : 1608885771,
         redpacketId : 10299,
         toGroupId : 1608885771,
         senduserId : 10086,
         content : 恭喜发财，大吉大利
         }
         */
        [self.userNameBtn setTitle:@"我" forState:UIControlStateNormal];
        self.timeLabel.text = [RPFTool ConvertStrToTime:[NSString stringWithFormat:@"%@",dic[@"sendtimes"]]];
        self.moneyLabel.text = [NSString stringWithFormat:@"%.2f元 ",[dic[@"totalMoney"] intValue]*0.01];
        self.userId = dic[@"senduserId"];
        self.redpacketId = dic[@"redpacketId"];
    }
    
}

@end
