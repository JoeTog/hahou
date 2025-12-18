//
//  DynamicNewDetailViewController.m
//  nationalFitness
//
//  Created by Joe on 2017/7/7.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "DynamicNewDetailViewController.h"
#import "EGORefreshTableHeaderView.h"

#import "OnlyTextTableViewCell.h"


@interface DynamicNewDetailViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,NFCommentInputViewDelegate,NFMessageFaceViewDelegate,EGORefreshTableHeaderDelegate, UIGestureRecognizerDelegate,ChatHandlerDelegate>

@end

@implementation DynamicNewDetailViewController{
    
    NFCommentInputView *messageToolView;
    NFMessageFaceView *faceView;
    
    __weak IBOutlet UITableView *dynamicDetailTabeView;
    
    BOOL selectComment_; // 选择的是热门评论 还是普通评论
    
    NSMutableArray *commentArr_; // 普通评论数据
    NSMutableArray *hotCommentArr_; // 热门评论数据
    BOOL isCommentComment_; // 是否评论的是动态
    
    
    CGFloat _previousTooViewHeight; // 输入框的高度
    CGFloat previousTextViewContentHeight; // textview的高度
    double animationDuration; //动画时间
    CGRect keyboardRect; //键盘尺寸
    
    //下滑到最后是否能刷新数据
    BOOL canRefreshLash_;
    //下滑到最后是否正在刷新
    BOOL isRefreshLashing_;
    
    EGORefreshTableHeaderView *refreshHeaderView;
    BOOL    reloading_;
    BOOL    isCoach_;
    
    NSString *createDate_; // 评论时间 用于分页
    
    
    SocketModel * socketModel;
    //记录一下是否评论成功
    BOOL Iscomment;
    //记录选中的indexpath 选中的评论
    NSIndexPath *selectCommentIndexpath;
    //评论输入框 后面的背景
    UIView * backgroundView;
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (socketModel.delegate != self) {
        socketModel.delegate = self;
    }
    [self registerForKeyboardNotifications];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [SVProgressHUD dismiss];
    [self removeForKeyboardNotifications];
    
    // 是否点赞过 0未点赞 1点赞过
    if ([self.noteListEntity.isPraise isEqualToString:@"0"]) {
        if (self.returnPraiseBlock) {
            self.returnPraiseBlock(NO);
        }
    }else if ([self.noteListEntity.isPraise isEqualToString:@"1"]){
        if (self.returnPraiseBlock) {
            self.returnPraiseBlock(YES);
        }
    }
}

-(void)returnDeleteBlock:(ReturnDeleteDynamicBlock)block{
    if (self.ReturnDeleteDynamicBlock != block) {
        self.ReturnDeleteDynamicBlock = block;
    }
}

-(void)returnPraise:(ReturnPraiseBlock)block{
    if (self.returnPraiseBlock != block) {
        self.returnPraiseBlock = block;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"动态详情";
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyBoard)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    [self initScoket];
    // 加载评论界面
    [self initCommentView];
//    [self getCommentList]; //评论在详情里面
    [self getDetailInfo];
    [self downUpdate];
    
}

-(void)initScoket{
    //获取单例
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    //当connect时不一定通的
    
}

#pragma mark - 动态详情请求
-(void)getDetailInfo{
    if (![ClearManager getNetStatus]) {
        [SVProgressHUD showInfoWithStatus:@"请检查网络设置"];
        return;
    }
    if ([[NFUserEntity shareInstance].connectStatus isEqualToString:@"1"]) {
        [SVProgressHUD showInfoWithStatus:@"未连接到服务器"];
        return;
    }
    [SVProgressHUD show];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"getCircleDetail";
    self.parms[@"circleId"] = self.noteListEntity.circle_id;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 点赞请求
- (void)praiseNote:(NoteListEntity *)entity
{
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"postCircleLike";
    self.parms[@"circleId"] = self.noteListEntity.circle_id;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
    
}

#pragma mark - 接收消息代理
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self doneLoadingTableViewData];
    });
    if (messageType == SecretLetterType_DynamicDianzan) {
        //点赞、取消点赞 成功返回
        if ([chatModel isKindOfClass:[NSString class]]) {
            self.noteListEntity.currentUserLike = chatModel;
        }
    }else if (messageType == SecretLetterType_DynamicReturnDict){
        [chatModel isKindOfClass:[NSDictionary class]];
        NSDictionary *resultDict = chatModel;
        if ([[resultDict objectForKey:@"type"] isEqualToString:@"6009"]) {
            [SVProgressHUD showInfoWithStatus:@"操作成功!"];
            //删除动态成功s
            // 删除帖子 删除相关
            [NFUserEntity shareInstance].isNeedDeleteDidselectedPush = YES;
            if (self.ReturnDeleteDynamicBlock) {
                self.ReturnDeleteDynamicBlock();
            }
            // 不能在这里设置 因为在这里设置 pop回去会刷新row 可是row已经删除了 便崩溃
            //        [NFUserEntity shareInstance].isNeedDeleteDidselectedPush = NO;
            [self performSelector:@selector(popToLastController) withObject:nil afterDelay:1];
        }else if ([[resultDict objectForKey:@"type"] isEqualToString:@"6011"]){
            [SVProgressHUD showInfoWithStatus:@"操作成功!"];
            [dynamicDetailTabeView reloadData];
        }
    }else if (messageType == SecretLetterType_DynamicSuccess){
        NSDictionary *dict = [NSDictionary new];
        if ([chatModel isKindOfClass:[NSDictionary class]]) {
            dict = chatModel;
            if ([[dict objectForKey:@"type"] isEqualToString:@"6003"]) {
                //评论成功回调 刷新评论
                
            }
        }
    }else if (messageType == SecretLetterType_DynamicSuccess){
        //评论列表
        
    }else if (messageType == SecretLetterType_DynamicDetail){
        //动态详情
        if (Iscomment) {
            [SVProgressHUD showSuccessWithStatus:@"评论成功"];
            Iscomment = NO;
        }
        if ([chatModel isKindOfClass:[NoteListEntity class]]) {
            //是否点赞过 0未点赞 1点赞过
            self.noteListEntity = chatModel;
            commentArr_ = [NSMutableArray arrayWithArray:self.noteListEntity.commentArr];
            [dynamicDetailTabeView reloadData];
            if (_isFromComment)
            {
                [messageToolView.messageInputTextView becomeFirstResponder];
                _isFromComment = NO;
            }
        }
    }else if (messageType == SecretLetterType_DynamicSuccess){
        NSDictionary *dict = [NSDictionary new];
        if ([chatModel isKindOfClass:[NSDictionary class]]) {
            dict = chatModel;
            if ([[dict objectForKey:@"type"] isEqualToString:@"6017"]) {
                //删除动态成功
                [commentArr_ removeObjectAtIndex:selectCommentIndexpath.row];
                [dynamicDetailTabeView reloadData];
            }
        }
    }else if (messageType == SecretLetterType_DynamicFail){
        NSDictionary *dict = [NSDictionary new];
        if ([chatModel isKindOfClass:[NSDictionary class]]) {
            dict = chatModel;
            if ([[dict objectForKey:@"type"] isEqualToString:@"6018"]) {
                //删除动态失败
                [SVProgressHUD showErrorWithStatus:@"删除失败"];
            }
        }
    }else if (messageType == SecretLetterType_SocketRequestFailed){
        [self doneLoadingTableViewData];
        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}
//pop回去
-(void)popToLastController{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIGestureRecognizerDelegate 让删除评论的选项更快出来

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    [self hideKeyBoard];
    return NO;
}

// 设置下拉刷新
- (void)downUpdate
{
    dynamicDetailTabeView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0 - dynamicDetailTabeView.bounds.size.height, dynamicDetailTabeView.frame.size.width, dynamicDetailTabeView.bounds.size.height)];
    refreshHeaderView.delegate = self;
    [dynamicDetailTabeView addSubview:refreshHeaderView];
    reloading_ = NO;
    [refreshHeaderView refreshLastUpdatedDate];
}

#pragma mark - tableViewDelegate & tableViewDateSource
//返回分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
//返回分区行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0)
    {
        return 1;
    }else if (section == 1)
    {
        return hotCommentArr_.count;
    }else if (section == 2)
    {
        return commentArr_.count;
    }
    return 0;
}
//每一行高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0)
    {
        if (self.noteListEntity.photoList.count == 0)
        {
            return [OnlyTextTableViewCell getContentCellHeight:self.noteListEntity.circle_content seeingMore:self.noteListEntity.isExetend] + 10;
        }else
        {
            return [ContentNewCell getContentCellHeight:self.noteListEntity.circle_content seeingMore:self.noteListEntity.isExetend];
            return 0;
        }
    }
    else if (indexPath.section == 1)
    {
        NoteCommentEntity *hotCommEntity = [hotCommentArr_ objectAtIndex:indexPath.row];
        return [FindCommentsCell getContentCellHeight:hotCommEntity];
    }
    else if (indexPath.section == 2)
    {
//        commentEntity *comment = [commentArr_ objectAtIndex:indexPath.row];
        NoteCommentEntity *comment = [commentArr_ objectAtIndex:indexPath.row];
        return [FindCommentsCell getContentCellHeight:comment];
    }
    return 0;
}

//返回每一行的内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * cellidentifer = nil;
    if (canRefreshLash_ && indexPath.row == commentArr_.count - 1 && 2 == indexPath.section)
    {
        if (NO == isRefreshLashing_)
        {
            [self performSelector:@selector(refreshList) withObject:nil afterDelay:0.2];
        }
    }
    if (indexPath.section == 0) {
        if (self.noteListEntity.photoList.count == 0)
        {
            return [self returnRelayOnlyTextCellIntableView:tableView indexPath:indexPath withEntity:self.noteListEntity];
        }
        else
        {
            return [self returnContentNewCellIntableView:tableView indexPath:indexPath withEntity:self.noteListEntity];
        }
    }
    else if (indexPath.section == 1)
    {
        //热评
        commentEntity *hotCommEntity = [hotCommentArr_ objectAtIndex:indexPath.row];
        cellidentifer = @"FindCommentsCell";
        FindCommentsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifer];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"FindCommentsCell" owner:nil options:nil] firstObject];
        }
//        [cell setTextStr:hotCommEntity withFkId:self.noteListEntity.noteId];
        return cell;
    }
//    else
//    {
//    cellidentifer = @"FindCommentsCell";
//    //ReplyCommentTableViewCell
//    ReplyCommentTableViewCell *replyCell = [tableView dequeueReusableCellWithIdentifier:cellidentifer];
//    if (replyCell == nil) {
//        replyCell = [[[NSBundle mainBundle]loadNibNamed:@"ReplyCommentTableViewCell" owner:nil options:nil] firstObject];
//    }
//    return replyCell;
    
//        commentEntity *comment = [commentArr_ objectAtIndex:indexPath.row];
        NoteCommentEntity *commentEntity = [commentArr_ objectAtIndex:indexPath.row];
        FindCommentsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifer];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"FindCommentsCell" owner:nil options:nil] firstObject];
        }
        [cell setTextStr:commentEntity withFkId:self.noteListEntity.circle_id];
        return cell;
//    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        //暂无
        commentEntity *hotCommEntity = [hotCommentArr_ objectAtIndex:indexPath.row];
        if ([hotCommEntity.commUserId isEqualToString:[NFUserEntity shareInstance].userId])
        {
            UIActionSheet *editSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"删除评论", nil];
            selectComment_ = NO;
            editSheet.tag = indexPath.row;
            [editSheet showInView:self.view];
            return;
        }
        isCommentComment_ = YES;
        messageToolView.commentType = @"2";
        messageToolView.commentId = _entityid;
        messageToolView.byCommId = hotCommEntity.commId;
        messageToolView.isFromHome = NO;
        messageToolView.messageInputTextView.placeHolder = [NSString stringWithFormat:@"回复%@:",hotCommEntity.nickName];
        [messageToolView.messageInputTextView becomeFirstResponder];
    }
    else if (2 == indexPath.section)
    {
        selectCommentIndexpath = indexPath;
        NoteCommentEntity *comment = [commentArr_ objectAtIndex:indexPath.row];
        if ([comment.user_id isEqualToString:[NFUserEntity shareInstance].userId])
        {
//            UIActionSheet *editSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"删除评论", nil];
//            selectComment_ = YES;
//            editSheet.tag = indexPath.row;
//            [editSheet showInView:self.view];
            LWWeChatActionSheet *sheet = [[LWWeChatActionSheet alloc] initWithWeChatActionSheetCancelButtonTitle:@"取消" title:nil otherButtonTitles:[NSArray arrayWithObjects:@"删除评论", nil] btnClickBlock:^(NSInteger buttonIndex) {
                if (0 == buttonIndex)
                {
                    NoteCommentEntity *comment = [commentArr_ objectAtIndex:indexPath.row];
                    [commentArr_ removeObjectAtIndex:selectCommentIndexpath.row];
                    [self deleteComment:comment];
                }
                //点击取消、点击空白部分 则将选中置空。 因为不像动态页那么复杂 这里的选中cell不需要时刻记录的很精确，每次点击cell都会进行赋值，并且在弹窗消失后 没有使用选中的indexpath。
//                selectCommentIndexpath = nil;
            }];
            [sheet show];
            return;
        }
        isCommentComment_ = NO;
        messageToolView.commentType = @"2";
        messageToolView.commentId = self.noteListEntity.circle_id;
        messageToolView.byCommId = comment.comment_id;
        messageToolView.isFromHome = NO;
        messageToolView.messageInputTextView.placeHolder = [NSString stringWithFormat:@"回复%@:",comment.user_name];
        backgroundView.backgroundColor = [UIColor colorWithHue:0
                                                    saturation:0
                                                    brightness:0 alpha:0.1]; //好看的灰色背景
        UIWindow *win = [[[UIApplication sharedApplication] windows] firstObject];
        backgroundView = [[UIView alloc] initWithFrame:win.bounds];
        [win addSubview:backgroundView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackgroundClickk)];
        [backgroundView addGestureRecognizer:tap];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackgroundClickk)];
        [backgroundView addGestureRecognizer:pan];
        [messageToolView.messageInputTextView becomeFirstResponder];
    }
}

-(void)tapBackgroundClickk{
    [backgroundView removeFromSuperview];
    [self hideKeyBoard];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self hideKeyBoard];
}

#pragma mark - 纯文本cell
- (OnlyTextTableViewCell *)returnRelayOnlyTextCellIntableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath withEntity:(NoteListEntity *)entity
{
    OnlyTextTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"OnlyTextTableViewCell"];
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"OnlyTextTableViewCell" owner:nil options:nil]firstObject];
    }
    cell.editBtn.hidden = YES;
    [cell showCellWithEntity:entity
              withDataSource:nil CacheHeightDict:[NSMutableDictionary new]
                 commentView:messageToolView
               withTableView:tableView
                 atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - 带图片的cell
#pragma mark - 带图片和文字
- (ContentNewCell *)returnContentNewCellIntableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath withEntity:(NoteListEntity *)entity
{
    ContentNewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ContentNewCell"];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"ContentNewCell" owner:nil options:nil]firstObject];
    }
    cell.tag = 1000;
    cell.isVideo = NO;
    cell.editBtn.hidden = YES;
    [cell showCellWithEntity:entity
              withDataSource:nil CacheHeightDict:[NSMutableDictionary new]
                 commentView:messageToolView
               withTableView:tableView
                 atIndexPath:indexPath];
    return cell;
}

#pragma mark - 帖子删除相关 删除评论
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (0 == buttonIndex)
    {
        NoteCommentEntity *comment = [commentArr_ objectAtIndex:actionSheet.tag];
        [commentArr_ removeObjectAtIndex:selectCommentIndexpath.row];
        [self deleteComment:comment];
    }
}


#pragma mark - 加载评论列表
//加载更多
- (void)refreshList
{
}

// 点击删除自己发表的评论
- (void)deleteComment:(NoteCommentEntity *)entity
{
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"delCircleComment";
    self.parms[@"commentId"] = entity.comment_id;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 加载评论界面
- (void)initCommentView
{
    messageToolView = [[NFCommentInputView alloc]initWithFrame:CGRectMake(0,SCREEN_HEIGHT - 45,SCREEN_WIDTH , 45)];
    messageToolView.delegate = self;
    messageToolView.backgroundColor = [UIColor colorWithRed:254.0/255 green:254.0/255 blue:254.0/255 alpha:1];
    messageToolView.messageInputTextView.placeHolder = @"评论";
    [self.view addSubview:messageToolView];
    
    if (!faceView)
    {
        faceView = [[NFMessageFaceView alloc]initWithFrame:CGRectMake(0.0f,
                                                                      CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), 196)];
        faceView.delegate = self;
        [self.view addSubview:faceView];
    }
}

//注册键盘弹起隐藏通知
- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}
//移除键盘通知
- (void)removeForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
//键盘将要弹起
- (void)keyboardWillShow:(NSNotification *)aNotification {
    NSDictionary* info = [aNotification userInfo];
    // 注意不要用UIKeyboardFrameBeginUserInfoKey，第三方键盘可能会存在高度不准，相差40高度的问题
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    // 修改滚动天和tableView的contentInset
    dynamicDetailTabeView.contentInset = UIEdgeInsetsMake(0, 0, kbSize.height, 0);
    dynamicDetailTabeView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, kbSize.height, 0);
    
    // 跳转到当前点击的输入框所在的cell
    NSLog(@"\n%d\n%d\n",selectCommentIndexpath.section,selectCommentIndexpath.row);
    __weak typeof(self)weakSelf=self;
    [UIView animateWithDuration:0.2 animations:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        [strongSelf ->dynamicDetailTabeView scrollToRowAtIndexPath:strongSelf ->selectCommentIndexpath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }];
}

- (void)keyboardWillBeHidden:(NSNotification *)aNotification {
    dynamicDetailTabeView.contentInset = UIEdgeInsetsZero;
    dynamicDetailTabeView.scrollIndicatorInsets = UIEdgeInsetsZero;
}

#pragma mark - ZBMessageDelegate
// 键盘将要显示
- (void)keyBoardWillShow:(CGRect)rect animationDuration:(CGFloat)duration
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
    if (![currentVC isKindOfClass:[self class]]) {
        return;
    }
    socketModel.delegate = self;
    //如果说评论的动态
    if (isCommentComment_)
    {
        // 默认评论当前帖子
        messageToolView.commentType = @"2";
        messageToolView.commentId = self.noteListEntity.circle_id;
        messageToolView.byCommId = nil;
        messageToolView.isFromHome = NO;
        messageToolView.messageInputTextView.placeHolder = [NSString stringWithFormat:@"回复%@:",self.noteListEntity.user_name];
    }else{
        //评论其他人
        //在 tableview didselected中已经赋值
    }
    keyboardRect = rect;
    animationDuration = duration;
    [self messageViewAnimationWithMessageRect:rect withMessageInputViewRect:messageToolView.frame andDuration:duration andState:ZBMessageViewStateShowNone];
}

// 评论成功
- (void)commentSuccess
{
    // 评论成功 重新获取评论列表
//    [SVProgressHUD showSuccessWithStatus:@"评论成功"];
    //记录一下评论成功
    Iscomment = YES;
    socketModel.delegate = self;
    //请求详情
    [self getDetailInfo];
    
}

// 键盘将要消失
- (void)keyBoardWillHidden:(CGRect)rect animationDuration:(CGFloat)duration
{
    isCommentComment_ = NO;
    keyboardRect = rect;
    animationDuration = duration;
    [self hideKeyBoard];
}

// 键盘已经弹出
- (void)keyBoardChange:(CGRect)rect animationDuration:(CGFloat)duration
{
    
}

// 开始编辑
- (void)inputTextViewDidBeginEditing:(ZBMessageTextView *)messageInputTextView
{
//    self.noteListEntity;
    [self messageViewAnimationWithMessageRect:keyboardRect
                     withMessageInputViewRect:messageToolView.frame
                                  andDuration:animationDuration
                                     andState:ZBMessageViewStateShowNone];
    
    if (!previousTextViewContentHeight)
    {
        previousTextViewContentHeight = messageInputTextView.contentSize.height;
    }
}

//将要开始编辑
- (void)inputTextViewWillBeginEditing:(ZBMessageTextView *)messageInputTextView
{
}

// 正在编辑
- (void)inputTextViewDidChange:(ZBMessageTextView *)messageInputTextView
{
    CGFloat maxHeight = [NFCommentInputView maxHeight];
    CGSize size = [messageInputTextView sizeThatFits:CGSizeMake(CGRectGetWidth(messageInputTextView.frame), maxHeight)];
    CGFloat textViewContentHeight = size.height;
    
    // End of textView.contentSize replacement code
    BOOL isShrinking = textViewContentHeight < previousTextViewContentHeight;
    CGFloat changeInHeight = textViewContentHeight - previousTextViewContentHeight;
    if(!isShrinking && previousTextViewContentHeight == maxHeight) {
        changeInHeight = 0;
    }
    else {
        changeInHeight = MIN(changeInHeight, maxHeight - previousTextViewContentHeight);
    }
    if(changeInHeight != 0.0f) {
        __weak typeof(self)weakSelf=self;
        [UIView animateWithDuration:0.01f
                         animations:^{
                             __strong typeof(weakSelf)strongSelf=weakSelf;
                             [messageInputTextView scrollRectToVisible:CGRectMake(0, messageInputTextView.contentSize.height-10, 50, 10) animated:YES];
                             if(isShrinking)
                             {
                                 // if shrinking the view, animate text view frame BEFORE input view frame
                                 [strongSelf ->messageToolView adjustTextViewHeightBy:changeInHeight];
                             }
                             CGRect inputViewFrame = messageToolView.frame;
                             strongSelf ->messageToolView.frame = CGRectMake(0.0f,
                                                                inputViewFrame.origin.y - changeInHeight,
                                                                inputViewFrame.size.width,
                                                                inputViewFrame.size.height + changeInHeight);
                             if(!isShrinking)
                             {
                                 [strongSelf ->messageToolView adjustTextViewHeightBy:changeInHeight];
                             }
                         }
                         completion:^(BOOL finished) {
                             
                         }];
        previousTextViewContentHeight = MIN(textViewContentHeight, maxHeight);
    }
}

// 获取图片(拍照或者是从相册选择的照片)
- (void)getImagePickerController:(UIImagePickerController *)picker withInfo:(NSDictionary *)info
{
}

//点击照片
- (void)didChangeSendImage:(BOOL)changed
{
    [self hideKeyBoard];
}

//发送文本
- (void)didSendTextAction:(ZBMessageTextView *)messageInputTextView
{
    NSLog(@"sendmessage");
}

// 发送表情
- (void)didSendFaceAction:(BOOL)sendFace;
{
    if (previousTextViewContentHeight < 0.001)
    {
        previousTextViewContentHeight = 36;
    }
    if (sendFace) {
        if (messageToolView.messageInputTextView.bounds.size.height<=
            messageToolView.bounds.size.height)
        {
            [self messageViewAnimationWithMessageRect:faceView.frame
                             withMessageInputViewRect:messageToolView.frame
                                          andDuration:animationDuration
                                             andState:ZBMessageViewStateShowFace];
        }
        else{
            [self messageViewAnimationWithMessageRect:faceView.frame
                             withMessageInputViewRect:CGRectMake(messageToolView.bounds.origin.x, messageToolView.bounds.origin.y, messageToolView.bounds.size.width, previousTextViewContentHeight+8)
                                          andDuration:animationDuration
                                             andState:ZBMessageViewStateShowFace];
        }
        
    }
    else
    {
        [self messageViewAnimationWithMessageRect:keyboardRect
                         withMessageInputViewRect:messageToolView.frame
                                      andDuration:animationDuration
                                         andState:ZBMessageViewStateShowNone];
    }
}

// 点击表情
- (void)SendTheFaceStr:(NSString *)faceStr isDelete:(BOOL)dele;
{
}

- (void)messageViewAnimationWithMessageRect:(CGRect)rect  withMessageInputViewRect:(CGRect)inputViewRect andDuration:(double)duration andState:(ZBMessageViewState)state{
    __weak typeof(self)weakSelf=self;
    [UIView animateWithDuration:duration animations:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        strongSelf ->messageToolView.frame = CGRectMake(0.0f,CGRectGetHeight(strongSelf.view.frame)-CGRectGetHeight(rect)-CGRectGetHeight(inputViewRect),CGRectGetWidth(strongSelf.view.frame),CGRectGetHeight(inputViewRect));
        switch (state)
        {
            case ZBMessageViewStateShowFace:
            {
                strongSelf ->faceView.frame = CGRectMake(0.0f,CGRectGetHeight(strongSelf.view.frame)-CGRectGetHeight(rect),CGRectGetWidth(strongSelf.view.frame),CGRectGetHeight(rect));
            }
                break;
            case ZBMessageViewStateShowVoice:
            {
                strongSelf ->faceView.frame = CGRectMake(0.0f,CGRectGetHeight(strongSelf.view.frame),CGRectGetWidth(strongSelf.view.frame),CGRectGetHeight(strongSelf ->faceView.frame));
            }
                break;
            case ZBMessageViewStateShowNone:
            {
                if (rect.size.width == 0.0)
                {
                    //收到最底部
                    strongSelf ->messageToolView.frame = CGRectMake(0.0f,CGRectGetHeight(strongSelf.view.frame) - 45,CGRectGetWidth(strongSelf.view.frame),45);
                }
                else
                {
                    if (strongSelf ->_previousTooViewHeight != 0)
                    {
                        //显示在键盘上面
                        strongSelf ->messageToolView.frame = CGRectMake(inputViewRect.origin.x, inputViewRect.origin.y, inputViewRect.size.width, strongSelf ->_previousTooViewHeight);
                        strongSelf ->_previousTooViewHeight = 0.0;
                    }
                }
                strongSelf ->faceView.frame = CGRectMake(0.0f,CGRectGetHeight(strongSelf.view.frame),CGRectGetWidth(strongSelf.view.frame),CGRectGetHeight(strongSelf ->faceView.frame));
            }
                break;
            default:
                break;
        }
        
    } completion:^(BOOL finished) {
    }];
}

-(void)hideKeyBoard
{
    messageToolView.messageInputTextView.placeHolder = @"评论";
    [messageToolView.messageInputTextView resignFirstResponder];
    CGFloat inputViewHeight;
    if (UIDeviceCurrentDevice >= 7)
    {
        inputViewHeight = 45.0f;
    }
    else{
        inputViewHeight = 40.0f;
    }
    messageToolView.frame = CGRectMake(0.0f,self.view.frame.size.height - messageToolView.frame.size.height,self.view.frame.size.width,messageToolView.frame.size.height);
    
    faceView.frame = CGRectMake(0.0f,
                                CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), 196);
}



#pragma mark - Data Source Loading / Reloading Methods
- (void)reloadTableViewDataSource
{
    reloading_ = YES;
}

- (void)doneLoadingTableViewData
{
    //  model should call this when its done loading
    reloading_ = NO;
    [refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:dynamicDetailTabeView];
}

#pragma mark - 滑动刷新

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    socketModel.delegate = self;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - 下拉刷新委托回调
//begin
//end 调用结束刷新和刷新列表
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    [self reloadTableViewDataSource];
//    [self getCommentList];
    
    [socketModel ping];
    if ([socketModel isConnected]&& [ClearManager getNetStatus]) {
        [self getDetailInfo];
    }else{
        //
        dispatch_async(dispatch_get_main_queue(), ^{
            [self doneLoadingTableViewData];
        });
    }
}
- (void)stopRefresh
{
    [self doneLoadingTableViewData];
}

// should return if data source model is reloading
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return reloading_;
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
