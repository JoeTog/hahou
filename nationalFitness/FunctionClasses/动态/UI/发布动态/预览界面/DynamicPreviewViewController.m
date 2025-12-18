//
//  DynamicPreviewViewController.m
//  nationalFitness
//
//  Created by Joe on 2017/7/8.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "DynamicPreviewViewController.h"
#import "OnlyTextTableViewCell.h"


@interface DynamicPreviewViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation DynamicPreviewViewController{
    
    __weak IBOutlet UITableView *tableView_;
    
    BOOL seeingMore_;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self initUi];
    
    
}

- (void)initUi
{
    
    tableView_.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (_entity.photoList.count == 0)
    {
        //circle_content
        return [OnlyTextTableViewCell getContentCellHeight:_entity.circle_content seeingMore:_entity.isExetend];
    }else
    {
        return [ContentNewCell getContentCellHeight:_entity.circle_content seeingMore:_entity.isExetend];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_entity.photoList.count == 0)
    {
        return [self returnOnlyTextCellIntableView:tableView indexPath:indexPath withEntity:_entity];
    }else
    {
        return [self returnContentNewCellIntableView:tableView indexPath:indexPath withEntity:_entity];
    }
    
}

#pragma mark - 纯文本cell
- (OnlyTextTableViewCell *)returnOnlyTextCellIntableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath withEntity:(NoteListEntity *)entity
{
    OnlyTextTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"OnlyTextTableViewCell"];
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"OnlyTextTableViewCell" owner:nil options:nil]firstObject];
    }
    cell.editBtn.hidden = YES;
    [cell showCellWithEntity:entity
              withDataSource:nil  CacheHeightDict:[NSMutableDictionary new]
                 commentView:nil
               withTableView:tableView
                 atIndexPath:indexPath];
    cell.commentBtn.userInteractionEnabled = NO;
    cell.zanBtn.userInteractionEnabled = NO;
    cell.shareBtn.userInteractionEnabled = NO;
    cell.qubaoBtn.userInteractionEnabled = NO;
    cell.editBtn.userInteractionEnabled = NO;
    return cell;
}
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
                 commentView:nil
               withTableView:tableView
                 atIndexPath:indexPath];
    cell.commentBtn.userInteractionEnabled = NO;
    cell.zanBtn.userInteractionEnabled = NO;
    cell.shareBtn.userInteractionEnabled = NO;
    cell.qubaoBtn.userInteractionEnabled = NO;
    cell.editBtn.userInteractionEnabled = NO;
    return cell;
}

#pragma mark - 返回
- (IBAction)backClick:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
