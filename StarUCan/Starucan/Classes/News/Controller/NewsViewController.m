//
//  NewsViewController.m
//  星优客
//
//  Created by vgool on 15/12/30.
//  Copyright © 2015年 vgool. All rights reserved.
//

#import "NewsViewController.h"
#import "CustomBarItem.h"
#import "UINavigationItem+CustomItem.h"
#include "MessageViewCell.h"

@interface NewsViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    
    NSArray *_titleArray;
    
    NSArray *_imageNameArray;
    
    
}
@property(nonatomic,strong)UIButton *messageButton;
@property(nonatomic,strong) UIButton *chatButton;

@property(nonatomic,strong)UIView *chatView;
@property(nonatomic,strong)UIView *messageView;
@property(nonatomic,strong)UITableView *messageTableView;


@end

@implementation NewsViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden=NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"消息";
    
    [self navigationBarSetting];
    
    [self createData];
    
}

-(void)navigationBarSetting{
    
    self.navigationController.navigationBar.translucent = NO;
    
    //设置标题视图
    UIView *viewbg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, YTHScreenWidth-280, 44)];
    [self.navigationItem setItemWithCustomView:viewbg itemType:center];
    
    NSArray *titleArray = @[@"聊天",@"信息"];
    //聊天
    UIButton *chatButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat width = viewbg.frame.size.width/2;
    [chatButton setFrame:CGRectMake(0, 7, width, 30)];
    [chatButton setTitle:titleArray[0] forState:UIControlStateNormal];
    [chatButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [chatButton addTarget:self action:@selector(chatButton:) forControlEvents:UIControlEventTouchUpInside];
    self.chatButton = chatButton;
    [viewbg addSubview:chatButton];
    
    
    //信息
    UIButton *messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [messageButton setFrame:CGRectMake(width, 7, width, 30)];
    [messageButton setTitle:titleArray[1] forState:UIControlStateNormal];
    [messageButton setTitleColor:YTHColor(255, 159, 164) forState:UIControlStateNormal];
    [messageButton addTarget:self action:@selector(messageButton:) forControlEvents:UIControlEventTouchUpInside];
    self.messageButton =messageButton;
    [viewbg addSubview:messageButton];
    
    //
    self.chatButton.transform = CGAffineTransformMakeScale(1.1,1.1);
    self.messageButton.transform = CGAffineTransformMakeScale(0.9,0.9);
    
}



#pragma mark - 聊天按钮点击方法
-(void)chatButton:(UIButton *)btn
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                         btn.transform = CGAffineTransformMakeScale(1.1,1.1);
                         self.messageButton.transform = CGAffineTransformMakeScale(0.9,0.9);

                         [self.messageButton setTitleColor:YTHColor(255, 159, 164) forState:UIControlStateNormal];
                         [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                         
                     }completion:^(BOOL finished) {
                         //隐藏状态栏，iOS7要改info里面的属性
                         
                         
                     }];
    
    
}
#pragma mark - 信息按钮点击方法
-(void)messageButton:(UIButton *)btn
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         btn.transform = CGAffineTransformMakeScale(1.1,1.1);
                         self.chatButton.transform = CGAffineTransformMakeScale(0.9,0.9);
                
                         [self.chatButton setTitleColor:YTHColor(255, 159, 164) forState:UIControlStateNormal];
                         [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                     }
                     completion:^(BOOL finished) {
            
                     }];
    
    [self.chatView removeFromSuperview];
    
    [self createTableView];
}

#pragma mark -创建信息页面tableView
-(void)createTableView{
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, YTHScreenWidth, YTHScreenHeight-110)];
    
    self.messageView = view;
    
    [self.view addSubview:self.messageView];
    
    self.messageTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, YTHScreenWidth, YTHScreenHeight-110)];
    
    self.messageTableView.delegate = self;
    
    self.messageTableView.dataSource = self;
    
    [self.messageView addSubview:self.messageTableView];
    
}

-(void)createData{

    _titleArray = @[@"评论/回复",@"赞",@"通知",@"小秘书"];
    
    _imageNameArray = @[@"pic_comment@3x",@"pic_zan@3x",@"pic_inform@3x",@"pic_secretary@3x"];
    

    
}

#pragma mark -UITableViewDelegate;

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MessageViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"messageCell"];
    
    if (cell == nil)
    {
    
        cell = [[MessageViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"messageCell"];
    }
    
    [cell relodDataWithtitle:_titleArray[indexPath.row] andImage:_imageNameArray[indexPath.row]];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _titleArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 64.0f;

}



- (CustomBarItem *)setItemWithCustomView:(UIView *)customView itemType:(ItemType)type
{
    CustomBarItem *item = [CustomBarItem itemWithCustomeView:customView type:type];
    
    [item setItemWithNavigationItem:self.navigationItem itemType:type];
    
    return item;
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
