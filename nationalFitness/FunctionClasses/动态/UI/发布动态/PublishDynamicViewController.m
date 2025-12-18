//
//  PublishDynamicViewController.m
//  nationalFitness
//
//  Created by Joe on 2017/7/7.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "PublishDynamicViewController.h"
#import "SGPhotoPickerViewController.h"

#import "NFAddImageCell.h"
#import "NFDynamicManager.h"
#import "NFHeadImageView.h"
#import "NFFAddImageCell.h"

@interface PublishDynamicViewController ()<UITextViewDelegate,
UITableViewDataSource,
UITableViewDelegate,
UINavigationControllerDelegate,
SGPhotoPickerDelegate,
UIImagePickerControllerDelegate,
UIActionSheetDelegate,ChatHandlerDelegate>

@end

@implementation PublishDynamicViewController{
    
    __weak IBOutlet UITableView *publishTableView;
    
    
    
    UITextView *textView_;
    
    // 展示文字的cell
    UITableViewCell *showTextCell_;
    // 展示照片的cell
    NFAddImageCell *showImageCell_;
    // 展示位置信息cell
    UITableViewCell *showLocationCell_;
    
    UIButton *publishBtn_; // 发布按钮
    
    // 是否可以发布(有内容就可以发布)
    BOOL textContent ;
    BOOL imageContent;
    
    UILabel *placeloarLab_;
    NSString *albumId_;   // 关联主键
    UIButton *openBtn_;  // 是否公开帖子的按钮
    UIButton *location_; // 是否显示位置信息
    
    UIButton *imageBtn_;
    UIButton *vedioBtn_;
    UIButton *friendBtn_;
    UIButton *faceBtn_;
    UIButton *connectBtn_;
    
    // 关联好友的集合
    NSString *nameStr_;
    NSMutableArray *selectArr_;
    
    NSString *connectId_;   // 关联社团活动主页的ID
    NSString *connectName_; // 关联社团活动主页的名字
    NSString *contnectType_; // 关联的社团或者是活动或者是公共主页的名字2:活动帖子 3:社团帖子
    
    // 如果是编辑状态 需要记录upfkid和图片路径
    NSString *upFkId_;
    NSMutableArray *smallArr_;
    NSMutableArray *bigArr_;
    
    SocketModel * socketModel;
    NSMutableArray *uploadPictureArr;
    NSInteger needUploadCount;
    
    
    SocketRequest *socketRequest;
    
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (socketModel.delegate != self) {
        socketModel.delegate = self;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self initUi];
    [self initScoket];
}


- (void)initUi
{
    self.title = @"发布动态";
    if (self.shareType == ShareTypeOffjubao) {
        self.title = @"举报投诉";
        
    }
    [NFUserEntity shareInstance].currentLoName = @"";
    needUploadCount = 0;
    uploadPictureArr = [NSMutableArray new];
    publishTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // 设置 navigation bar 右侧按钮
    publishBtn_ = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 27)];
    publishBtn_.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    [publishBtn_ setImage:[UIImage imageNamed:@"发布动态_publish"] forState:UIControlStateNormal];
    [publishBtn_ setImage:[UIImage imageNamed:@"发布动态_cantpublish"] forState:UIControlStateDisabled];
    
    if (self.shareType == ShareTypeOffjubao) {
        [publishBtn_ setImage:[UIImage imageNamed:@"发布动态_jubao"] forState:UIControlStateNormal];
        [publishBtn_ setImage:[UIImage imageNamed:@"发布动态_cantjubao"] forState:UIControlStateDisabled];
    }
    [publishBtn_ addTarget:self action:@selector(publicImage) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:publishBtn_];
    self.navigationItem.rightBarButtonItem = leftButtonItem;
    
    
    showImageCell_ = [publishTableView dequeueReusableCellWithIdentifier:@"SPAddImageCell"];
    if (showImageCell_ == nil)
    {
        showImageCell_ = [[NFAddImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SPAddImageCell"];
    }
    showImageCell_.height = 90;
    showLocationCell_ = (UITableViewCell *)[publishTableView dequeueReusableCellWithIdentifier:@"cell_location"];
    location_ = (UIButton *)[showLocationCell_ viewWithTag:1];
    [location_ addTarget:self action:@selector(showLocation:) forControlEvents:UIControlEventTouchUpInside];
    [location_ setImage:[UIImage imageNamed:@"发布动态_显示位置"] forState:UIControlStateNormal];
    [location_ setTitle:@"" forState:UIControlStateNormal];
    [location_ setImage:[UIImage imageNamed:@"发布动态_位置标志"] forState:UIControlStateSelected];
    
    showTextCell_ = (UITableViewCell *)[publishTableView dequeueReusableCellWithIdentifier:@"cell_text"];
    NFHeadImageView *headImage = (NFHeadImageView *)[showTextCell_ viewWithTag:1];
    [headImage ShowHeadImageWithUrlStr:[NFUserEntity shareInstance].bigpicpath withUerId:nil completion:nil];
    textView_ = (UITextView *)[showTextCell_ viewWithTag:3];
//    ViewBorderRadius(textView_, 3, 1, [UIColor colorThemeColor]);
    
    [textView_ becomeFirstResponder];
    textView_.delegate = self;
    placeloarLab_ = [showTextCell_ viewWithTag:10];
    //如果是需要编辑的题帖子
    if (self.editEntity)
    {
        textView_.text = self.editEntity.circle_content;
        [textView_ becomeFirstResponder];
        if (self.editEntity.actName.length > 0 && self.editEntity.fkid.length > 0)
        {
            connectName_ = self.editEntity.actName;
            connectId_ = self.editEntity.fkid;
        }
        showImageCell_.picMuArr = [[NSMutableArray alloc] initWithCapacity:9];
        for (NSString *urlString in self.editEntity.photoList)
        {
            SGPhoto *photo = [[SGPhoto alloc]init];
//            photo.thumbnail = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]]];
            UIImageView *imageV = [UIImageView new];
            [imageV sd_setImageWithURL:[NSURL URLWithString:urlString] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            }];
            photo.thumbnail = imageV.image;
//            photo.fullResolutionImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]]];
            photo.fullResolutionImage = imageV.image;
            [showImageCell_.picMuArr addObject:photo];
            imageContent = YES;
        }
        [publishTableView reloadData];
    }
}

-(void)initScoket{
    //获取单例
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    
}

#pragma mark - 发布动态 socket
-(void)sendPublicDynamic{
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"postCircle";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"circleContent"] = textView_.text;
    self.parms[@"circleImages"] = uploadPictureArr;
    self.parms[@"postAddress"] = @"";
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 上传图片到图片服务器 服务器返回一个图片地址 【保存图片地址】
-(void)sendPublicDynamicPicture:(UIImage *)image{
    //上传头像
    NSMutableDictionary *sendDic = [[NSMutableDictionary alloc] initWithCapacity:3];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    
    //    imageData = UIImagePNGRepresentation(image);
    
    NSString *type = [LoginManager typeForImageData:imageData];
    [sendDic setObject:type forKey:@"imgaeType"];
    [LoginManager execute:@selector(changeHeadPicpathManager) target:self callback:@selector(changeHeadPicpathManagerCallBack:) args:sendDic,imageData,nil];
    
}

- (void)changeHeadPicpathManagerCallBack:(id)data
{
    if (data)
    {
        if ([data objectForKey:@"error"]) {
            [SVProgressHUD showInfoWithStatus:[data objectForKey:@"error"]];
            return;
        }else{
            needUploadCount --;
            [uploadPictureArr addObject:[data objectForKey:@"url"]];
            if (needUploadCount == 0) {
                
                if (self.shareType == ShareTypeOffjubao) {
                    //举报
                    socketRequest = [SocketRequest share];
                    [socketRequest jubaoWithuserid:self.friendId.length > 0?self.friendId:@"0"  groupId:self.groupid.length > 0?self.groupid:@"0"  Content:textView_.text.length > 0?textView_.text:@"无" PicArr:uploadPictureArr];
                    
                    
                }else{
                    //进行 发布
                    [self sendPublicDynamic];
                }
                
            }
        }
    }
    else
    {
//        [SVProgressHUD showErrorWithStatus:kWrongMessage];
    }
}

#pragma mark - 收到服务器消息
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    if (messageType == SecretLetterType_DynamicSuccess){
        [SVProgressHUD showSuccessWithStatus:@"发布成功"];
//        if (self.successBlock)
//        {
//            self.successBlock(YES);
//        }
        [NFUserEntity shareInstance].IsRequestNearestDynamic = YES;
        [self performSelector:@selector(backToList) withObject:self afterDelay:1];
    }else if (messageType == SecretLetterType_jubao){
        if (self.shareType == ShareTypeOffjubao) {
            [SVProgressHUD showSuccessWithStatus:@"提交成功"];
            [self performSelector:@selector(backToList) withObject:self afterDelay:1];
        }
    }else{
        //发布失败 设置发布可点
        publishBtn_.userInteractionEnabled = YES;
    }
}

#pragma mark - 发布按钮颜色
- (void)canSend
{
    if (imageContent || textContent)
    {
        publishBtn_.enabled = YES;
    }
    else
    {
        publishBtn_.enabled = NO;
    }
}

// 展示位置信息
- (void)showLocation:(UIButton *)btn
{
    btn.selected = !btn.selected;
    if (btn.selected)
    {
        [[NFUserEntity shareInstance]changeUserDistanceFilter:100 andDelagate:self];
        [SVProgressHUD show];
    }
}

// 是否公开帖子
- (void)openNote:(UIButton *)btn
{
    btn.selected = !btn.selected;
}

- (void)registerTextView
{
    [textView_ resignFirstResponder];
}


- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (self.editEntity)
    {
        textView.text = self.editEntity.noteContent;
        [placeloarLab_ removeFromSuperview];
        placeloarLab_ = nil;
    }
    //    else
    //    {
    //        textView.text = @"";
    //    }
    textView.textColor = [UIColor blackColor];
    [self canPublish:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self canPublish:textView];
}

- (void)textViewDidChange:(UITextView *)textView
{
    [placeloarLab_ removeFromSuperview];
    placeloarLab_ = nil;
    [self canPublish:textView];
}

- (void)canPublish:(UITextView *)textView
{
    if (textView.text.length>0)
    {
        textContent = YES;
        [faceBtn_ setImage:[UIImage imageNamed:@"发布动态_face_2"] forState:UIControlStateNormal];
    }else if (imageContent)
    {
        [faceBtn_ setImage:[UIImage imageNamed:@"发布动态_face_2"] forState:UIControlStateNormal];
    }
    else
    {
        textContent = NO;
        [faceBtn_ setImage:[UIImage imageNamed:@"发布动态_face_1"] forState:UIControlStateNormal];
    }
    [self canSend];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self registerTextView];
}


#pragma mark - tableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row)
    {
        return 150.f;
    }else if (1 == indexPath.row)
    {
        if (!imageContent)
        {
            return 0;
        }
//        return showImageCell_.height;
        return [NFAddImageCell heightForCellWithData:showImageCell_.picMuArr];
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row)
    {
        if (openBtn_ == nil)
        {
            openBtn_ = [showTextCell_ viewWithTag:2];
            [openBtn_ addTarget:self action:@selector(openNote:) forControlEvents:UIControlEventTouchUpInside];
        }
        [openBtn_ setImage:[UIImage imageNamed:@"发布动态_open"] forState:UIControlStateNormal];
        [openBtn_ setImage:[UIImage imageNamed:@"发布动态_dontopen"] forState:UIControlStateSelected];
        //        [openBtn_ setImage:[UIImage imageNamed:@"发布动态_dontopen"] forState:UIControlStateSelected];
        return showTextCell_;
    }
    else if (1 == indexPath.row)
    {
//        [showImageCell_ setCellWith:indexPath withCtrol:self];
//        return showImageCell_;
        static NSString* cellIdentifier = @"NFFAddImageCell";
        NFFAddImageCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"NFFAddImageCell" owner:nil options:nil]firstObject];
        }
        NSArray *imageArr = [NSArray arrayWithArray:showImageCell_.picMuArr];
        [cell setCellWith:indexPath SGPhotoImageArr:imageArr withCtrol:self];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else
    {
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell_select"];
        
        UIButton *previewBtn = [cell viewWithTag:6];
        ViewBorderRadius(previewBtn, 4, 1, TheColor_BlueColor);
        [previewBtn addTarget:self action:@selector(gotoPreview) forControlEvents:UIControlEventTouchUpInside];
        if (self.shareType == ShareTypeOffjubao) {
            previewBtn.hidden = YES;
            placeloarLab_.text = @"请输入举报内容...";
        }
        imageBtn_ = [cell viewWithTag:1];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

// 有图片上传图片先上传图片
#pragma mark - 发布按钮点击
- (void)publicImage
{
    [SVProgressHUD show];
    publishBtn_.userInteractionEnabled = NO;
    [self.view endEditing:YES];
    
    if (!imageContent && !textContent)
    {
        if (self.shareType == ShareTypeOffjubao) {
            [SVProgressHUD showInfoWithStatus:@"请输入举报内容"];
        }else{
            [SVProgressHUD showInfoWithStatus:@"请输入发布内容"];
        }
        return;
    }
    if (showImageCell_.picMuArr.count == 0)
    {
        if (self.shareType == ShareTypeOffjubao) {
            //举报
            socketRequest = [SocketRequest share];
            [socketRequest jubaoWithuserid:self.friendId.length > 0?self.friendId:@"0"  groupId:self.groupid.length > 0?self.groupid:@"0"  Content:textView_.text.length > 0?textView_.text:@"无" PicArr:uploadPictureArr];
        }else{
            // 直接发布文字内容
            [self sendPublicDynamic];
        }
        return;
    }else{
        
        //先上传图片
        //记录需要上传的图片个数
        //needUploadCount = showImageCell_.picMuArr.count;
        NSMutableArray *uploadArr = [NSMutableArray new];
        for ( SGPhoto *photo in showImageCell_.picMuArr){
            NSData * imageData = [ClearManager imageDataScale:photo.fullResolutionImage scale:1];
            [uploadArr addObject:[UIImage imageWithData:imageData]];
        }
        
        [[AliyunOSSUpload aliyunInit] uploadImage:[NSArray arrayWithArray:uploadArr] success:^(NSArray<NSString *> * _Nonnull nameArray) {
            if(nameArray.count != showImageCell_.picMuArr.count){
                [SVProgressHUD showErrorWithStatus:@"图片上传失败"];
                return;
            }
            for (NSString *url in nameArray) {
                [uploadPictureArr addObject:[NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,url]];
            }
            if (self.shareType == ShareTypeOffjubao) {
                //举报
                socketRequest = [SocketRequest share];
                [socketRequest jubaoWithuserid:self.friendId.length > 0?self.friendId:@"0"  groupId:self.groupid.length > 0?self.groupid:@"0"  Content:textView_.text.length > 0?textView_.text:@"无" PicArr:uploadPictureArr];
            }else{
                //进行 发布
                [self sendPublicDynamic];
            }
            
        }];
        
        
        return;
        for ( SGPhoto *photo in showImageCell_.picMuArr){
            [self sendPublicDynamicPicture:photo.fullResolutionImage];
        }
        
        
        
    }
//    [self uploadPic]; 上传图片结束再[self publishNote];
    
}

#pragma mark - 发布动态
- (void)publishNote{
    NSMutableDictionary *sendDic = [@{} mutableCopy];
    [sendDic setObject:smallArr_?smallArr_:@"" forKey:@"smallPicPath"];
    if (albumId_)
    {
        [sendDic setObject:albumId_ forKey:@"noteId"];
    }else
    {
        [sendDic setObject:@"" forKey:@"noteId"];
    }
    //内容
    [sendDic setObject:textView_.text forKey:@"noteContent"];
    
    [NFDynamicManager execute:@selector(publishNoteManager) target:self callback:@selector(publishNoteCallBack:) args:sendDic,nil];
    
}

- (void)publishNoteCallBack:(id)data
{
    if (data)
    {
        //将data中错误清除
        data = @{};
        if ([data objectForKey:kWrongDlog])
        {
            [SVProgressHUD showErrorWithStatus:[data objectForKey:kWrongDlog]];
            //没用到
            if (self.successBlock)
            {
                self.successBlock(NO);
            }
        }else
        {
            if (self.shareType == ShareTypeOffjubao) {
                [SVProgressHUD showSuccessWithStatus:@"提交成功"];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"发布成功"];
            }
            //没用到
            if (self.successBlock)
            {
                self.successBlock(YES);
            }
            [self performSelector:@selector(backToList) withObject:self afterDelay:1];
        }
    }else
    {
        [SVProgressHUD dismiss];
        if (self.successBlock)
        {
            self.successBlock(NO);
        }
    }
}

- (void)backToList
{
    [self.navigationController popViewControllerAnimated:YES];
}


// 选择图片
- (void)selectPic
{
    [self.view endEditing:YES];
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil
                                                        delegate:self
                                               cancelButtonTitle:@"取消"
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"拍照",@"从手机相册取", nil];
    action.actionSheetStyle = UIActionSheetStyleDefault;
    [action showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
        {
            [self takeCameral];
        }
            break;
        case 1:
        {
            [self searchLibrary];
        }
            break;
        case 2:
        {
            [textView_ becomeFirstResponder];
        }
            break;
        default:
            break;
    }
}

#pragma mark - UIActionSheetDelegate
- (void)takeCameral
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        [imagePicker setAllowsEditing:NO];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;

        if (@available(iOS 13.0, *)) {
            imagePicker.modalPresentationStyle =UIModalPresentationFullScreen;
        }
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)searchLibrary
{
    if (!showImageCell_.picMuArr)
    {
        showImageCell_.picMuArr = [[NSMutableArray alloc] initWithCapacity:9];
    }
    SGPhotoPickerViewController *photoPickerViewController = [[SGPhotoPickerViewController alloc] initWithPicCount:(PIC_SELECET_COUNT)(kSelecetMax - showImageCell_.picMuArr.count)];
    
    photoPickerViewController.pickerDelegate = self;
    //由于走拍照路线-不能重复选择的功能关闭，不传入数组
    photoPickerViewController.originalSelectedArray = showImageCell_.picMuArr;
    [self.navigationController pushViewController:photoPickerViewController animated:YES];
    
}

#pragma mark - 展示照片
//选照片
- (void)photoPickerFinishSelected:(NSArray *)array
{
    //此处的picMuArr 不能正常传递到cell 但是在本界面可以当作全局变量 在returncell中传递到cell
    [showImageCell_.picMuArr addObjectsFromArray:array];
    
    if (showImageCell_.picMuArr.count <= 3)
    {
        showImageCell_.height = 90;
    }
    else if (showImageCell_.picMuArr.count <=7)
    {
        showImageCell_.height = 160;
    }
    else
    {
        showImageCell_.height = 230;
    }
    
    [publishTableView reloadData];
    
    if (showImageCell_.picMuArr.count >0)
    {
        imageContent = YES;
        [imageBtn_ setImage:[UIImage imageNamed:@"发布动态_image_2"] forState:UIControlStateNormal];
    }else if (textContent)
    {
        [imageBtn_ setImage:[UIImage imageNamed:@"发布动态_image_2"] forState:UIControlStateNormal];
    }
    else
    {
        imageContent = NO;
        [imageBtn_ setImage:[UIImage imageNamed:@"发布动态_image_1"] forState:UIControlStateNormal];
    }
    [self canSend];
}

//删除照片
- (void)deleteImageClick: (NSInteger)index
{
    [showImageCell_.picMuArr removeObjectAtIndex:index];
    if (showImageCell_.picMuArr.count <= 3)
    {
        showImageCell_.height = 90;
    }
    else if (showImageCell_.picMuArr.count <=7)
    {
        showImageCell_.height = 160;
    }
    else
    {
        showImageCell_.height = 230;
    }
    [publishTableView reloadData];
    if (showImageCell_.picMuArr.count >0)
    {
        imageContent = YES;
        [imageBtn_ setImage:[UIImage imageNamed:@"发布动态_image_2"] forState:UIControlStateNormal];
    }else if (textContent)
    {
        [imageBtn_ setImage:[UIImage imageNamed:@"发布动态_image_2"] forState:UIControlStateNormal];
    }
    else
    {
        imageContent = NO;
        [imageBtn_ setImage:[UIImage imageNamed:@"发布动态_image_1"] forState:UIControlStateNormal];
    }
    [self canSend];
}

// 拍照展示的图片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            UIImage *saveImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
            
            UIImageWriteToSavedPhotosAlbum(saveImage,
                                           nil,
                                           nil,
                                           nil);
        }
    }];
    
    UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    //生成相册ID
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormatter setDateFormat: @"yyyyMMddhhmmssSS"];
    NSString *identifier = [dateFormatter stringFromDate:[NSDate date]];
    //选择完照片刷新列表
    SGPhoto *temp = [[SGPhoto alloc] init];
    temp.identifier = identifier;
    temp.thumbnail = portraitImg;
    temp.fullResolutionImage = portraitImg;
    
    if (!showImageCell_.picMuArr)
    {
        showImageCell_.picMuArr = [[NSMutableArray alloc] initWithCapacity:9];
    }
    [showImageCell_.picMuArr addObject:temp];
    
    if (showImageCell_.picMuArr.count <= 3)
    {
        showImageCell_.height = 90;
    }
    else if (showImageCell_.picMuArr.count <=7)
    {
        showImageCell_.height = 160;
    }
    else
    {
        showImageCell_.height = 230;
    }
    imageContent = YES;
    [self canSend];
    [publishTableView reloadData];
}

#pragma mark - 预览界面
- (void)gotoPreview
{
    // 跳转的时候 我们生成一个实体放到预览界面进行展示
    NoteListEntity *preEntity = [[NoteListEntity alloc] init];
//    preEntity.noteContent = textView_.text;
    preEntity.circle_content = textView_.text;
//    preEntity.redDate = @"1月14";
    preEntity.range = @"1";
    preEntity.isUpdate = self.editEntity?@"1":@"0";
//    preEntity.relAddress = @"淮安";
    
    preEntity.isFlag = @"0";
    preEntity.isPraise = @"0";
    preEntity.praiseCount = @"0";
    if ([NFUserEntity shareInstance].nickName) {
        preEntity.nickname = [NFUserEntity shareInstance].nickName;
    }
    if ([NFUserEntity shareInstance].userName) {
        preEntity.user_name = [NFUserEntity shareInstance].userName;
    }
    if ([NFUserEntity shareInstance].smallpicpath) {
        preEntity.smallPicPath = [NFUserEntity shareInstance].smallpicpath;
    }
    preEntity.post_time = [NFMyManage getCurrentDateTimeYesterday];
    NSMutableArray *photoList = [@[] mutableCopy];
    for ( SGPhoto *photo in showImageCell_.picMuArr)
    {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:photo.thumbnail,@"smallPicPath",photo.fullResolutionImage,@"bigPicPath", nil];
        [photoList addObject:dict];
    }
    preEntity.photoList = photoList;
    if (preEntity.circle_content.length == 0 && photoList.count == 0 ) {
        [SVProgressHUD showInfoWithStatus:@"请输入内容!"];
        return;
    }
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"DynamicStoryboard" bundle:nil];
    DynamicPreviewViewController *vc = [sb instantiateViewControllerWithIdentifier:@"DynamicPreviewViewController"];
    vc.entity = preEntity;

    if (@available(iOS 13.0, *)) {
        vc.modalPresentationStyle =UIModalPresentationFullScreen;
    }
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - 下方按钮的各种操作
#pragma mark - 选图片
- (IBAction)showImage:(id)sender {
    
    [textView_ resignFirstResponder];
    [self performSelector:@selector(selectPic) withObject:nil afterDelay:0.5f];
}


//懒加载
-(NSMutableDictionary *)parms{
    if (!_parms) {
        _parms = [[NSMutableDictionary alloc] init];
    }
    return _parms;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"\n\n\n\n\ndidReceiveMemoryWarning\n\n\n\n\n");
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
