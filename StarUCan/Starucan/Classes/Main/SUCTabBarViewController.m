//
//  SUCTabBarViewController.m
//  Starucan
//
//  Created by vgool on 16/2/9.
//  Copyright © 2016年 vgool. All rights reserved.
//

#import "SUCTabBarViewController.h"
#import "HomeViewController.h"
#import "NewsViewController.h"
#import "MineViewController.h"
#import "WXNavigationController.h"
#import "TalkViewController.h"
#import "XYTabBar.h"
#import "AppDelegate.h"
#import "LoginFirstViewController.h"
#import "TopicViewController.h"
#import "ShowPhotoViewController.h"
#import "LoginFirstViewController.h"
#import "XZMPublishViewController.h"
@interface SUCTabBarViewController ()<XYTabBarDelegate,UITabBarControllerDelegate,UITabBarDelegate>
{
    AppDelegate *myDelegate;
    
    WXNavigationController *_selectedController;
    
}
@property (nonatomic,strong)UIView * viewGray;

@end

@implementation SUCTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!myDelegate) {
        myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    self.delegate = self;
    // Do any additional setup after loading the view.
    HomeViewController*home = [[HomeViewController alloc] init];
    
    //谁都不选的时候，指向第一个页面
    
    [self createChildVCWithVC:home Title:@"首页" Image:@"icon_home_show" SelectedImage:@"icon_home_show_fill"];
    
    TalkViewController *discover = [[TalkViewController alloc] init];
    
    [self createChildVCWithVC:discover Title:@"话题" Image:@"icon_home_topic" SelectedImage:@"icon_home_topic_fill"];
    
    NewsViewController *message = [[NewsViewController alloc] init];
    [self createChildVCWithVC:message Title:@"消息" Image:@"icon_home_message" SelectedImage:@"icon_home_message_fill"];
    
    MineViewController *profile = [[MineViewController alloc] init];
    [self createChildVCWithVC:profile Title:@"我的" Image:@"icon_home_myself" SelectedImage:@"icon_home_myself_fill"];
    
    
    XYTabBar *tabBar = [[XYTabBar alloc] init];
    
    tabBar.delegate = self;
    
    [[XYTabBar appearance] setShadowImage:[[UIImage alloc] init]];
    
    [self setValue:tabBar forKey:@"tabBar"];
    
    self.tabBar.translucent = NO;
    
    [self.tabBar setBackgroundImage:[[UIImage imageNamed:@"tabbar_bg.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:10]];
    
    //第一次进入tabBar的时候把首页的导航控制器赋值给_selectedController
    _selectedController = (WXNavigationController *)home.navigationController;

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSUInteger count = self.tabBar.subviews.count;
    for (int i = 0; i<count; i++) {
        UIView *child = self.tabBar.subviews[i];
        Class class = NSClassFromString(@"UITabBarButton");
        if ([child isKindOfClass:class]) {
            child.width = self.tabBar.width / count;
        }
    }
}
-(void)createChildVCWithVC:(UIViewController *)childVC Title:(NSString *)title Image:(NSString *)image SelectedImage:(NSString *)selectedimage
{
    //设置子控制器的文字
    childVC.title = title;//同时设置tabbar和navigation的标题
    
    //设置文字的样式
    NSMutableDictionary *textAttrs = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *selectedtextAttrs = [[NSMutableDictionary alloc]init];
    textAttrs[NSForegroundColorAttributeName] = YTHColor(114, 114, 114);
    selectedtextAttrs[NSForegroundColorAttributeName] = YTHColor(255, 69, 82);
    [childVC.tabBarItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    [childVC.tabBarItem setTitleTextAttributes:selectedtextAttrs forState:UIControlStateSelected];
    //设置子控制器的图片
    childVC.tabBarItem.image =[UIImage imageNamed:image];
    childVC.tabBarItem.selectedImage = [[UIImage imageNamed:selectedimage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //这句话的意思是声明这张图片按照原始的样子显示出来，不要自动渲染成其他颜色
    
    //childVC.view.backgroundColor = RandomColor;
    
    //给子控制器包装导航控制器
    WXNavigationController *nav = [[WXNavigationController alloc] initWithRootViewController:childVC];
    
    [self addChildViewController:nav];
}

#pragma mark - tabbar中间大按钮的点击方法
-(void)tabBarDidClickPlusButton:(XYTabBar *)tabBar
{
   
    XZMPublishViewController *showVC = [[XZMPublishViewController alloc]init];

    WXNavigationController *nav = [[WXNavigationController alloc]initWithRootViewController:showVC];
    
    [self presentViewController:nav animated:YES completion:nil];
    
    //[_selectedController pushViewController:showVC animated:NO];
    
}

#pragma mark -UITableBarController的代理方法
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    
    //如果显示的是其他的页面，
    if (![viewController.tabBarItem.title isEqualToString:@"我的"]){
        
        _selectedController=viewController;
        
    }
    

    if ([viewController.tabBarItem.title isEqualToString:@"我的"]) {
        //还有再加一个账号判断
        if (!IsNilOrNull([myDelegate.userInfo objectForKey:@"user_uuid"])&&!myDelegate.account.length==0) {
            
            //登录状态，返回yes，表示可以进入这个页面。
            return YES;
        
        
        }else{
            
            //非登录状态进入登录页面
            LoginFirstViewController *loginVC = [[LoginFirstViewController alloc]init];
        
            [_selectedController pushViewController:loginVC animated:NO];
            
            return NO;
        }
       
    }
      return YES;
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
