//
//  LookViewController.m
//  Starucan
//
//  Created by vgool on 16/1/17.
//  Copyright © 2016年 vgool. All rights reserved.
//

#import "LookViewController.h"

@interface LookViewController ()<UITableViewDataSource,UITabBarDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic,strong)NSArray *dataArray;

@end

@implementation LookViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.title = @"谁都可以看";
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0, YTHScreenWidth, YTHScreenHeight) style:UITableViewStylePlain];
    
    _tableView.delegate = self;
    
    _tableView.dataSource = self;
    
    [self.view addSubview:_tableView];
    
    _dataArray=@[@"所有人可见",@"仅自己可见",@"我关注的人可见",@"我的粉丝可见",@"跟我同校的校友可见"];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 44.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //避免出现没有内容的cell 
    _tableView.height = 60.0f*_dataArray.count;
    
    UITableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:@"id"];
    
    if (!cell) {
        
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"id"];
    }
    
    cell.textLabel.text =_dataArray[indexPath.row];
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([self.delegate respondsToSelector:@selector(looksomeView:didClickTitle:)]) {
        
        [self.delegate looksomeView:self didClickTitle:cell.textLabel.text];
    }

    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
