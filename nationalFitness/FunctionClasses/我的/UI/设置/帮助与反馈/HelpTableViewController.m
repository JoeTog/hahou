//
//  HelpTableViewController.m
//  nationalFitness
//
//  Created by Joe on 2020/3/13.
//  Copyright © 2020 chenglong. All rights reserved.
//

#import "HelpTableViewController.h"

@interface HelpTableViewController ()

@end

@implementation HelpTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = @"多信智能客服";
    
    
}






-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (@available(iOS 13.0, *)) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell右箭头"]];
    }
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MineStoryboard" bundle:nil];
    HelpDetaillViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"HelpDetaillViewController"];
    //1。多信软件功能介绍
    if (indexPath.section == 0 && indexPath.row == 0) {
        toCtrol.showText = @"  多信是一款注重安全性，完全免费的聊天软件。您可用它来和你认识的新朋友即时聊天，查看他们的个人资料，给他们发送文字、语音、照片、视频。您还可以参加各种好玩有趣的群聊，和群友谈天说地。在使用多信时产生的上网流量费由网络运营商收取，建议配合上网流量套餐使用。";
    }else if (indexPath.section == 0 && indexPath.row == 1){
        toCtrol.showText = @"您好，可以在浏览器中打开多信官网www.duoxin888.com，选择【OS版下载】或者【安卓版下载】。更新您好，安卓设备请在多信内点击，【我】-【设置】-【关于多信】-【检查更新】，或直接下载新版后覆盖旧版本安装苹果设备请在 AppStore内点击【更新】-找到【多信】-【更新】如遇无法下载或更新，可能是不同地区连接网络问题，请多次尝试或重启设备再下载。";
    }else if (indexPath.section == 0 && indexPath.row == 2){
        toCtrol.showText = @"查看当前版本在多信界面点击【我】-【设置】-【关于多信】";
    }else if (indexPath.section == 0 && indexPath.row == 3){
        toCtrol.showText = @"多信官方网站：www.duoxin888.com\n多信官方邮箱：xinxinSport@outlook.com\n多信官方客服：在多信主界面点击【我】-【多信客服】一点击左下角【转人工客服】\n(人工客服在线时间为北京时间09:00-24:00)";
    }else if (indexPath.section == 0 && indexPath.row == 4){
        toCtrol.showText = @"多信举报方式分为3类，分别为联系人举报、群成员举报、好友申请举报联系人举报：请点击【用户头像】右上角【。】-【举报】一选择【举报理由】-选择【聊天证据】-填写【投诉内容】-上传【图片证据】\n群成员举报：\n请点击【群成员头像】右上角【。】-【举报】-选择【举报理由】-选择【聊天证据】一填写【投诉内容】-上传【图片证据】好友申请举报：请点击-【通讯录】\n【新的朋友】-选择需要举报的好友申请-点击【举报】-选择【举报】理由\n目前仅OS1.0.3及以上官方版本多信可使用群成员举报、好友申请举报以及举证功能，安卓用户暂只可通过好友举报进行举报。";
    }
    //2。红包功能说明
    else if (indexPath.section == 1 && indexPath.row == 0){
        toCtrol.showText = @"进入多信-打开需要发送红包的好友或者群对话框,点击右下角【+】选择附件栏【红包】一设置【红包金额】和【数量】点击【塞钱进红包】输入【支付密码】-即可将红包发到该多信好友或者该群聊中。";
    }else if (indexPath.section == 1 && indexPath.row == 1){
        toCtrol.showText = @"直接在群组或好友的对话框中点击收到的【多信红包】-点击【拆红包】，即可领取红包。";
    }else if (indexPath.section == 1 && indexPath.row == 2){
        toCtrol.showText = @"发送零钱红包时，由于网络信号不好，可能会造成红包发送失败，如果未扣款可稍后尝试重新发送，如果已经付款，聊天页面没有显示红包的情况。红包扣款会在24小时内原退回支付方的零钱账户具体查询方式，可参考如下步骤进入【我】-【零钱】-点击【我的红包记录】，即可查看收发红包记录。";
    }else if (indexPath.section == 1 && indexPath.row == 3){
        toCtrol.showText = @"点击右下角【我】-【零钱】-点击【我的红包记录】即可查看收发红包记录注：未被领取的多信红包，将在24小时后退回零钱余额，你可以进入我零钱点击我的红包记录即可查看红包记录";
    }else if (indexPath.section == 1 && indexPath.row == 4){
        toCtrol.showText = @"红包实名认证账号收发红包限额为150000元/日，当日发红包\n超过150000元后，需次日后才可继续发红包。\n单个红包金额最大为200元。\n群内拼手气红包最大总金额则为红包个数*200元(最大可发1000元)";
    }else if (indexPath.section == 1 && indexPath.row == 5){
        toCtrol.showText = @"零钱红包发送未被领取，会发出时间24小时原路退回。";
    }
    //3。绑卡相关问题
    else if (indexPath.section == 2 && indexPath.row == 0){
        toCtrol.showText = @"请点击【我】- 【零钱】- 【我的银行卡】 - 【添加】\n*未实名认证的账号，直接绑定银行卡将会同时认证实名;已实名认证的账号，必须绑定该实名名下的银行卡不得绑定其他人名下卡。";
    }else if (indexPath.section == 2 && indexPath.row == 1){
        toCtrol.showText = @"请点击【我】-【零钱】-【我的银行卡】-选择您需要解绑的银行卡-【解除绑定】";
    }else if (indexPath.section == 2 && indexPath.row == 2){
        toCtrol.showText = @"请确认各项信息输入无误，银行卡、身份证须为同一-人名下。*银行卡预留手机号为办卡开户时预留号码，若不确定办卡时是否预留手机号，请务必向银行方面进行确认。若预留手机号已停用则需到银行办理变更预留手机号业务。如您确认所有信息填写无误，  请点击左下方【转人工】，联系人工客服为您查询处理。";
    }else if (indexPath.section == 2 && indexPath.row == 3){
        toCtrol.showText = @"目前部分银行暂不支持在多信充值或提现，如绑卡后点击充值提示暂无可用银行卡，建议用户绑定以下7家银行发行的借记卡。\n银行名称\n农业银行\n中国银行\n建设银行\n招商银行\n民生银行\n工商银行\n浦发银行";
    }
    //4。充值与提现帮助
    else if (indexPath.section == 3 && indexPath.row == 0){
        toCtrol.showText = @"点击右下角【我】 - 【零钱】-点击【充值】 -选择【充值金额】 -点击【下一步】 -选择支付银行卡- 【去支付】-获取【验证码】 - 【输入验证码】 -点击【确认支付】- 【完成】";
    }else if (indexPath.section == 3 && indexPath.row == 1){
        toCtrol.showText = @"请点击右下角【我】 -点击【零钱】 -点击.  【提现】选择到账银行卡- 【输入提现金额】点击【提现】 -输入【提现密码】 -点击【完成】 即可提现";
    }else if (indexPath.section == 3 && indexPath.row == 2){
        toCtrol.showText = @"充值可能由于网络等原因可能会出现延迟，-般充值未及时到账，如充值半小时还未到账，可联系客服对充值未到账进行核实处理。";
    }else if (indexPath.section == 3 && indexPath.row == 3){
        toCtrol.showText = @"自用户根据不同银行卡以及银联支付限额而定。  单实名单日充值总额不限";
    }else if (indexPath.section == 3 && indexPath.row == 4){
        toCtrol.showText = @"提现限制规则:单笔最低金额1元，最高20000元。单账号单日提现限额无，每日限提无，同一实名下所有账号单日提现无上限。部分规模较小的地方银行,  例如:农村信用合作社、农商银行等，需先在多信充值后，才可进行提现。";
    }else if (indexPath.section == 3 && indexPath.row == 5){
        toCtrol.showText = @"零钱提现正常情况下是即时到账，由于银行差异、地域差异，到账时间会有所不同，如出现银行认为存在风险会进行风险核查，交易状态是提现中，会在第二个工作日协调相关机构进行处理，每日22:00-次日02:00期间的提现申请，到账时间会相对延迟若用户交易存在异常风险,  将进入人工风控审核，工作人员会尽快进行处理。";
    }else if (indexPath.section == 3 && indexPath.row == 6){
        toCtrol.showText = @"银行卡提现收取每笔0.8%的技术服务费，不足2元的按每笔2元收取。用户实际到账金额为扣除技术服务费之后的金额。\n例:\n1、户发起提现100元， 技术服务费按照0.8%计算为0.8元，不足2元按照2元收取，所以用户银行卡实际到账98元。\n2、用户发起提现5000元，技术服务费按照0.8%计算为40元，所以用户银行卡实际到账4960元。\n\n如果用户提现失败，申请提现全部金额将退回多信零钱，不会扣取手续费";
    }else if (indexPath.section == 3 && indexPath.row == 7){
        toCtrol.showText = @" 多信提现发起后无法中止，如提现失败，相关金额会原路退回零钱账户。因浦发、邮储、招商银行入账规则更新，如在60秒内发起两笔相同金额提现订单，其中第二笔订单将被视为重复订单，重复订单会在30分钟之内提现失败并退回零钱。";
    }
    //5。账号资料与实名认证
    else if (indexPath.section == 4 && indexPath.row == 0){
        toCtrol.showText = @"昵称:请点击【我】 - 【自己的昵称]-【自己的昵称】-输入昵称-右上角【保存】*昵称需长度大于1个汉字。用户名/多信号:请点击【我】 - 【自己的昵称】 - 输入用户名/多信号-右上角【保存】*用户名/多信号只可使用英文或数字设置后不可更改或取消。\n头像:请点击- 【我】 - 【自己的昵称】 - 【修改个人头像】";
    }else if (indexPath.section == 4 && indexPath.row == 1){
        toCtrol.showText = @"【昵称】 - 【实名认证】 - 输入正确的姓名、身份证号码、即可认证成功，实名认证时不需要添加银行卡，在认证成功后可领取红包并用零钱发放红包。";
    }else if (indexPath.section == 4 && indexPath.row == 2){
        toCtrol.showText = @"相关法律法规规定，网络帐号必须实名制，多信不支持解除或变更实名认证。";
    }
    //6。如何注销多信账号
    else if (indexPath.section == 5 && indexPath.row == 0){
        toCtrol.showText = @"暂无";
    }
    //7。支付密码与安全锁
    else if (indexPath.section == 6 && indexPath.row == 0){
        toCtrol.showText = @" 在多信主界面点击【我】 - 【零钱】 -选择【修改支付密码】";
    }else if (indexPath.section == 6 && indexPath.row == 1){
        toCtrol.showText = @"在多信主界面点击【我】 - 【零钱】 -选择【忘记支付密码】。如果当日输错支付密码次数已达5次.为保零钱账户安全，支付密码将被锁定至当日24点，重置密码也无法立即解锁。";
    }
    //8。如何设置消息提醒
    else if (indexPath.section == 7 && indexPath.row == 0){
        toCtrol.showText = @"请点击【我】-【设置]-【消息通知/声音】 -所有通知【关闭】\n请在聊天界面点击【用户头像/群头像】- 【消息通知】-【关闭】";
    }
    //9。私聊基本功能
    else if (indexPath.section == 8 && indexPath.row == 0){
        toCtrol.showText = @"撤回消息:\n请在聊天界面长按已发送3分钟内的消息-选择[撤回】*发送时间超过3分钟的消息无法撤回转发消息:转发目前支持:文字、表情、图片、名片、链接等五种类型。\n请长按单条消息后- -选择【转发】 -选择转发对象-点击【确认】 -即可完成转发。";
    }
    //10。聊天记录与缓存相关
    else if (indexPath.section == 9 && indexPath.row == 0){
        toCtrol.showText = @"聊天记录(包括语音、图片和文字)在存储空间充足的情况下可一直保存在本地，如果卸载重装或者更换登入设备，只从服务器获取近7天的聊天记录。\n*由第三方App分享至多信的文字内容与多信聊天记录保存规则相同，由第三方App分享至多信的图片内容只在多信保存7天。";
    }else if (indexPath.section == 9 && indexPath.row == 1){
        toCtrol.showText = @"清空:请在聊天界面点击右上角[联系人/群头像] -右上角【...】 - 【清空聊天记录】 - 【确定】\n删除对话:安卓设备请在多信主界面长按需要删除的【聊天对话】 - 点击【删除对话】\n苹果设备请在多信主界面左滑需要删除的【聊天对话】一点击【删除】 -点击【删除对话】\n删除单条记录:请在聊天口内长按想要删除的消息，弹出提示，点击【删除】\n*群主/群管理员可在群内使用【群内 删除】，群内删除后所有群成员将无法查看到此消息记录。";
    }else if (indexPath.section == 9 && indexPath.row == 2){
        toCtrol.showText = @"官方表情包:请点击【我】 - 【设置】-【表情商店】-右上角【设置图标】 -右上角\n【编辑】 -选择项目【删除】\n自定义表情:请在聊天界面点击右下角【表情图标】 -|星型图标】 -长按并拖拽需\n删除的表情至左下角【垃圾桶图标】 -松开手指点击【删除表情】";
    }else if (indexPath.section == 9 && indexPath.row == 3){
        toCtrol.showText = @"请点击【我】一【设置】 - 【聊天设置】-【清理多信存储空间/清理缓存】【确定】";
    }
    //11。好友相关问题
    else if (indexPath.section == 10 && indexPath.row == 0){
        toCtrol.showText = @"请使用最新版多信点击【联系人/通讯录】 -右上角【+】 -在搜索框输入【手机号/多信号] -点击【搜索】 -或点击【添加多信好友】 / 【手机联系人】向对方发起好友申请后，对方用户同意即可成为好友。如遇搜索不到对方的情况，请确认对方开启了哪几种可被添加好友的方式";
    }else if (indexPath.section == 10 && indexPath.row == 1){
        toCtrol.showText = @"请点击【联系人头像】 -右上角【...】 - 【删除联系人】-【确定】";
    }else if (indexPath.section == 10 && indexPath.row == 2){
        toCtrol.showText = @"请点击【我】 - 【设置】 - 【隐私安全】 - 【添加我的方式】";
    }else if (indexPath.section == 10 && indexPath.row == 3){
        toCtrol.showText = @"加入黑名单:请在聊天界面右.上角【联系人头像】 -右上角【..】 -加入黑名单\n【开启】*与拉黑好友发送消息聊天界面会提示已将该联系人加入黑名单,  你将不再接受对方消息。\n解除黑名单:请点击【我】 - 【设置】 - 【隐私安全】- 【黑名单】 -点击或左滑要解除拉黑的联系人- 【 取消拉黑/删除】";
    }
    //12。群聊基本功能
    else if (indexPath.section == 11 && indexPath.row == 0){
        toCtrol.showText = @"在多信界面点击右下角【+】 -选择[发起群聊]-选择好友后-点击 【下一步】-【完成】";
    }else if (indexPath.section == 11 && indexPath.row == 1){
        toCtrol.showText = @"在群聊界面点击右上角【群头像】 -在群详情界面选择【邀请群成员】 -选择好友后-点击【邀请】";
    }else if (indexPath.section == 11 && indexPath.row == 2){
        toCtrol.showText = @"目前多信群上限人数为1500人";
    }else if (indexPath.section == 11 && indexPath.row == 3){
        toCtrol.showText = @"请在群聊界面长按需要回复的消息-选择【回复】 - 编辑回复内容后发送被回复人会收到@提示。";
    }
    //13。群主管理权限转人
    else if (indexPath.section == 12 && indexPath.row == 0){
        toCtrol.showText = @"群主在聊天对话框输入【@】 →点击【所有人】";
    }else if (indexPath.section == 12 && indexPath.row == 1){
        toCtrol.showText = @"  群主点击群聊天右上角【群头像】 -点击右上角... -点击【删除并退出】 -选择【解散】或点击群成员选择【转让】";
    }else if (indexPath.section == 12 && indexPath.row == 2){
        toCtrol.showText = @"点击群右上角【群头像】 -选择【群管理】 -选择【关闭】或【开启】-【群隐私]\n(此功能默认关闭)";
    }else if (indexPath.section == 12 && indexPath.row == 3){
        toCtrol.showText = @"群主点击群头像- 【群管理】 - 【设置群管理员】 - 【设置群管理员】";
    }else if (indexPath.section == 12 && indexPath.row == 4){
        toCtrol.showText = @"设置群二维码:点击群右上角【群头像】 -选择【群管理】 -选择【关闭】或【开启】 - 【启用群二维码】。\n设置是否允许邀请进群以及进群确认点击群右上角【群头像] -选择【群管理】-选择【关闭】或【开启】 - 【允许群成员邀请联系人入群]及【群聊开启邀请确认】";
    }else if (indexPath.section == 12 && indexPath.row == 5){
        toCtrol.showText = @"全员禁言:群主/群管理员点击右上角群头像- 【群管理】 -全员禁言【开启】";
    }else if (indexPath.section == 12 && indexPath.row == 6){
        toCtrol.showText = @"群主点击群成员头像-右上角... -【移出本群】";
    }
    
    
    
    else if (indexPath.section == 12 && indexPath.row == 0){
        toCtrol.showText = @"";
    }
    
    [self.navigationController pushViewController:toCtrol animated:YES];
    
}













@end
