//
//  ReplyCommentsViewController.m
//  newTestUe
//
//  Created by liumac on 15/12/18.
//  Copyright © 2015年 程龙. All rights reserved.
//

#import "ReplyCommentsViewController.h"
#import "NFDynamicManager.h"
#import "NFDynamicEntity.h"

#import "FindCommentsCell.h"
#import "ReplyDetailCommentsCell.h"
#import "NFCommentInputView.h"
#import "NFMessageFaceView.h"

@interface ReplyCommentsViewController ()<UITableViewDataSource,UITableViewDelegate,NFCommentInputViewDelegate,NFMessageFaceViewDelegate>
{
    UITableView *tableView_;
    
    NSMutableArray *dataSource_;
    
    commentEntity *entity_;
    
    //    // 评论界面
    NFCommentInputView *messageToolView;
    NFMessageFaceView *faceView;
    CGFloat _previousTooViewHeight; // 输入框的高度
    CGFloat previousTextViewContentHeight; // textview的高度
    double animationDuration; //动画时间
    CGRect keyboardRect; //键盘尺寸
}

@end

@implementation ReplyCommentsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUi];
    [self getReplyCommentsList];
}

- (void)initUi
{
    self.title = @"回复";
    self.view.backgroundColor = [UIColor whiteColor];
    tableView_ = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 45) style:UITableViewStylePlain];
    tableView_.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView_.delegate = self;
    tableView_.dataSource = self;
    [self.view addSubview:tableView_];
    tableView_.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    // 点击事件
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyBoard)];
    [tableView_ addGestureRecognizer:tap];
}

//-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    [self.view endEditing:YES];
//}

#pragma mark - 获取回复列表
- (void)getReplyCommentsList
{
    NSMutableDictionary *sendDic = [@{} mutableCopy];
    [sendDic setObject:self.commId?self.commId:@"" forKey:@"commId"];
    [NFDynamicManager execute:@selector(commentRelyManager) target:self callback:@selector(commentRelyCallback:) args:sendDic,nil];
}

- (void)commentRelyCallback:(id)data
{
    if (data)
    {
        if ([data objectForKey:kWrongDlog])
        {
            [SVProgressHUD showErrorWithStatus:[data objectForKey:kWrongDlog]];
        }else
        {
            entity_ = [data objectForKey:@"comment"];
            dataSource_ = [data objectForKey:@"replyEntityList"];
            [tableView_ reloadData];
            [self initCommentView];
        }
    }
}

#pragma mark - tabeleViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (dataSource_)
    {
        return dataSource_.count + 1;
    }else if (entity_)
    {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row)
    {
        FindCommentsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FindCommentsCell"];
        if (cell == nil)
        {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"FindCommentsCell" owner:nil options:nil] firstObject];
        }
        cell.input = ^(BOOL comment)
        {
            if (comment)
            {
                [messageToolView.messageInputTextView becomeFirstResponder];
            }
        };
        [cell setContentStr:entity_ withFkId:nil];
        return cell;
    }else
    {
        commentEntity *entity = [dataSource_ objectAtIndex:indexPath.row - 1];
        ReplyDetailCommentsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReplyDetailCommentsCell"];
        if (cell == nil)
        {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"ReplyDetailCommentsCell" owner:nil options:nil] firstObject];
            [cell setTextStr:entity];
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row)
    {
        return 100;
//        return [FindCommentsCell getContentCellHeightWithOutReply:entity_];
    }else
    {
        commentEntity *entity = [dataSource_ objectAtIndex:indexPath.row - 1];
        return [ReplyDetailCommentsCell getContentCellHeight:entity.replyContent];
    }
}

- (void)initCommentView
{
    if (!messageToolView)
    {
        messageToolView = [[NFCommentInputView alloc]initWithFrame:CGRectMake(0,SCREEN_HEIGHT - 45,SCREEN_WIDTH , 45)];
        messageToolView.delegate = self;
        messageToolView.commentType = @"2";
        messageToolView.commentId = _noteId;
        messageToolView.byCommId = entity_.commId;
        messageToolView.isFromHome = NO;
        messageToolView.backgroundColor = [UIColor colorWithRed:254.0/255 green:254.0/255 blue:254.0/255 alpha:1];
        [self.view addSubview:messageToolView];
    }
    if (!faceView)
    {
        faceView = [[NFMessageFaceView alloc]initWithFrame:CGRectMake(0.0f,
                                                                      CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), 196)];
        faceView.delegate = self;
        [self.view addSubview:faceView];
        
    }
    messageToolView.messageInputTextView.placeHolder = [NSString stringWithFormat:@"回复%@:",entity_.nickName];
    [messageToolView.messageInputTextView becomeFirstResponder];
}


/*
 *  输入框的相关代理方法
 */
// 键盘将要显示
- (void)keyBoardWillShow:(CGRect)rect animationDuration:(CGFloat)duration
{
    keyboardRect = rect;
    animationDuration = duration;
    [self messageViewAnimationWithMessageRect:rect withMessageInputViewRect:messageToolView.frame andDuration:duration andState:2];
}

// 键盘将要消失
- (void)keyBoardWillHidden:(CGRect)rect animationDuration:(CGFloat)duration
{
    [self hideKeyBoard];
}

// 键盘已经弹出
- (void)keyBoardChange:(CGRect)rect animationDuration:(CGFloat)duration
{
    
}

// 开始编辑
- (void)inputTextViewDidBeginEditing:(ZBMessageTextView *)messageInputTextView
{
    [self messageViewAnimationWithMessageRect:keyboardRect
                     withMessageInputViewRect:messageToolView.frame
                                  andDuration:animationDuration
                                     andState:2];
    
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
                             
                             CGRect inputViewFrame = strongSelf ->messageToolView.frame;
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
                                             andState:0];
        }
        else{
            [self messageViewAnimationWithMessageRect:faceView.frame
                             withMessageInputViewRect:CGRectMake(messageToolView.bounds.origin.x, messageToolView.bounds.origin.y, messageToolView.bounds.size.width, previousTextViewContentHeight+8)
                                          andDuration:animationDuration
                                             andState:0];
        }
        
    }
    else
    {
        [self messageViewAnimationWithMessageRect:keyboardRect
                         withMessageInputViewRect:messageToolView.frame
                                      andDuration:animationDuration
                                         andState:2];
    }
    
}

// 点击表情
- (void)SendTheFaceStr:(NSString *)faceStr isDelete:(BOOL)dele;
{
    
}

- (void)messageViewAnimationWithMessageRect:(CGRect)rect  withMessageInputViewRect:(CGRect)inputViewRect andDuration:(double)duration andState:(NSInteger)state{
    __weak typeof(self)weakSelf=self;
    [UIView animateWithDuration:duration animations:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        strongSelf ->messageToolView.frame = CGRectMake(0.0f,CGRectGetHeight(strongSelf.view.frame)-CGRectGetHeight(rect)-CGRectGetHeight(inputViewRect),CGRectGetWidth(strongSelf.view.frame),CGRectGetHeight(inputViewRect));
        
        switch (state)
        {
            case 0:
            {
                strongSelf ->faceView.frame = CGRectMake(0.0f,CGRectGetHeight(strongSelf.view.frame)-CGRectGetHeight(rect),CGRectGetWidth(strongSelf.view.frame),CGRectGetHeight(rect));
            }
                break;
            case 1:
            {
                strongSelf ->faceView.frame = CGRectMake(0.0f,CGRectGetHeight(strongSelf.view.frame),CGRectGetWidth(strongSelf.view.frame),CGRectGetHeight(strongSelf ->faceView.frame));
            }
                break;
            case 2:
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
                
                strongSelf ->faceView.frame = CGRectMake(0.0f,CGRectGetHeight(weakSelf.view.frame),CGRectGetWidth(strongSelf.view.frame),CGRectGetHeight(strongSelf ->faceView.frame));
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
    [messageToolView.messageInputTextView resignFirstResponder];
    CGFloat inputViewHeight;
    
    if (UIDeviceCurrentDevice >= 7)
    {
        inputViewHeight = 45.0f;
    }
    else{
        inputViewHeight = 40.0f;
    }
    
    messageToolView.frame = CGRectMake(0.0f,self.view.frame.size.height - messageToolView.frame.size.height,self.view.frame.size.width,45);
    
    faceView.frame = CGRectMake(0.0f,
                                CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), 196);
    
}

- (void)commentSuccess
{
    // 评论成功 重新刷新
    [self getReplyCommentsList];
}


#pragma mark - end


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"\n\n\n\n\ndidReceiveMemoryWarning\n\n\n\n\n");
}

@end
