//
//  TalkViewController.m
//  星优客
//
//  Created by vgool on 15/12/30.
//  Copyright © 2015年 vgool. All rights reserved.
//

#import "TalkViewController.h"
#import "CustomBarItem.h"
#import "UINavigationItem+CustomItem.h"
#import "SearchViewController.h"

@interface TalkViewController ()

@end

@implementation TalkViewController

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden=NO;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"话题";
    [self _initNation];
}

#pragma mark 搜索
-(void)_initNation{
    
    // 右边的搜索按钮
    UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [searchButton setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    CustomBarItem *rightUtem = [self.navigationItem setItemWithCustomView:searchButton itemType:right];
    [searchButton addTarget:self action:@selector(pushToSearchViewControll) forControlEvents:UIControlEventTouchUpInside];
    [rightUtem setOffset:18];
}
-(void)pushToSearchViewControll
{
    //点击进入搜索页面
    SearchViewController *searchVC = [[SearchViewController alloc]init];
    [self.navigationController pushViewController:searchVC animated:YES];
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
