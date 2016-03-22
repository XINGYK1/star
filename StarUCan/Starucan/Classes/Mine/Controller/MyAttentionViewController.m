//
//  MyAttentionViewController.m
//  Starucan
//
//  Created by vgool on 16/1/26.
//  Copyright © 2016年 vgool. All rights reserved.
//

#import "MyAttentionViewController.h"
#import "MyFanTableViewCell.h"
#import "AFHTTPRequestOperationManager.h"
#import "NSData+AES256.h"
#import "MBProgressHUD+NJ.h"
#import "ShowDetailModel.h"
#import "AppDelegate.h"
@interface MyAttentionViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    AppDelegate *myDelegate;
}
@property (nonatomic,retain)UITableView * tableView;
@property (nonatomic,retain)NSMutableArray * sourceArray;
@end

@implementation MyAttentionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我的关注";
    if (!myDelegate) {
        myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    //初始化uitableview
    [self _initTable];
    
    //请求数据
    [self requestData];
    
}
#pragma mark-请求数据
-(void)requestData
{
    NSString *userUuid =[myDelegate.userInfo objectForKey:@"user_uuid"];
    NSString *url1 = [NSString stringWithFormat:@"v1/user/%@/ follows",userUuid];
    NSString *text = [NSData AES256EncryptWithPlainText:url1 passtext:myDelegate.accessToken];
    YTHLog(@"登录密码=%@",myDelegate.accessToken);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setAuthorizationHeaderFieldWithToken:text];
    [manager.requestSerializer setValue:myDelegate.account forHTTPHeaderField:@"account"];
    
    NSString *uS = Url;
    NSString *urlStr = [NSString stringWithFormat:@"%@v1/user/%@/follows",uS,[myDelegate.userInfo objectForKey:@"uuid"]];
    YTHLog(@"拼接之后%@",urlStr);
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YTHLog(@"粉丝 %ld",(long)[operation.response statusCode]);
        _sourceArray = [[NSMutableArray alloc]init];
        
        
        if ([operation.response statusCode]/100==2)
        {
            YTHLog(@"粉丝%@",responseObject);
            NSArray *usersArray = [responseObject objectForKey:@"users"];
            for (NSDictionary *dict in usersArray) {
                ShowDetailModel *model = [[ShowDetailModel alloc]initContentWithDic:dict];
                [self.sourceArray addObject:model];
            }
            
        }
        [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YTHLog(@"粉丝错误 %ld",(long)[operation.response statusCode]);
        
    }];
    
}

-(void)_initTable
{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, YTHScreenWidth, YTHScreenHeight) style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_tableView];
    UIButton *addFriendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addFriendBtn.frame = CGRectMake(0, 0, YTHScreenWidth, 44);
    [addFriendBtn setTitle:@"添加好友" forState:UIControlStateNormal];
    [addFriendBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.tableView.tableHeaderView = addFriendBtn;
    
    
}
#pragma mark-UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sourceArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"kIdentifier";
    MyFanTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil) {
        cell = [[MyFanTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    cell.flag = YES;
    cell.showModel = _sourceArray[indexPath.row];
    
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
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
