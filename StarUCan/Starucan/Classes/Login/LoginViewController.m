//
//  LoginViewController.m
//  Starucan
//
//  Created by vgool on 15/12/31.
//  Copyright © 2015年 vgool. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "ForgetPassViewController.h"
#import <ShareSDK/ShareSDK.h>
#import "WXNavigationController.h"
#import "LoginFirstViewController.h"
#import "UnListViewController.h"
#import "RegisterSecondViewController.h"
#import "AddInformationViewController.h"
 
#import <CommonCrypto/CommonDigest.h>
#import "MBProgressHUD.h"
#import "WXApi.h"
#import "UIViewExt.h"
#import "SUCTabBarViewController.h"


@interface LoginViewController ()
{
    
    AppDelegate *myDelegate;

}
@property (weak, nonatomic) UIScrollView *scrollView;
@property(strong,nonatomic)UIView *loginView;
@end

@implementation LoginViewController
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        _scrollView = scrollView;
        [self.view addSubview:_scrollView];
        self.scrollView.translatesAutoresizingMaskIntoConstraints=NO;
        
        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.and.top.equalTo(self.view);     // 左边、右边、顶部 等于 self.View
        }];
       
        // self.scrollView.frame = CGRectMake(0, 0, YTHScreenWidth, YTHScreenHeight);
        
        self.scrollView.backgroundColor = [UIColor yellowColor];
   
    }
    return _scrollView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (!myDelegate) {
        myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }

   
    //创建UI
    [self _initCreat];
    
    
    if ([ShareSDK hasAuthorized:SSDKPlatformTypeWechat]) {
        
        YTHLog(@"第三方登陆授权成功");
    
    }else{
        
        YTHLog(@"第三方登陆授权失败");
    
    }
    
    
    
    // [ShareSDK hasAuthorized:<#(SSDKPlatformType)#>]


    

}

#define marginH (threeInch ||fourInch? 49.0f : 79.0f)
//#define logoV (threeInch ||fourInch? 120:124 )
-(void)_initCreat
{
    self.view.backgroundColor = [UIColor redColor];
    
    UIImageView *backgroundV = [[UIImageView alloc]init];
    
    [self.view addSubview:backgroundV];
    
    [backgroundV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.width.offset(YTHScreenWidth);
        make.height.offset(YTHScreenHeight);     // 左边、右边、顶部 等于 self.View
    }];
    
    backgroundV.image = [UIImage imageNamed:@"background"];
    
    backgroundV.contentMode = UIViewContentModeScaleToFill;
    
    UIImageView *logoImv = [[UIImageView alloc]init];
    
    logoImv.image =[UIImage imageNamed:@"logo"];
    
    [self.view addSubview:logoImv];
    
    logoImv.translatesAutoresizingMaskIntoConstraints = NO;
    
    [logoImv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(YTHAdaptation(124), YTHAdaptation(124))); // 设置大小
       // make.center.equalTo(self.view);// 居中显示
        make.top.equalTo(self.view).offset(marginH);
        make.left.equalTo(self.view).offset(YTHScreenWidth/2-YTHAdaptation(62));
        
    
    }];
    
//    [logoImv.layer setMasksToBounds:YES];
//    [logoImv.layer setCornerRadius:50];
//    logoImv.layer.borderColor = [UIColor orangeColor].CGColor;
//    logoImv.layer.borderWidth = 2;
  
    
       
    //注册
    UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self.view addSubview:registerButton];
    
    if (threeInch) {
        
        [registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(YTHScreenWidth-YTHAdaptation(126), YTHAdaptation(40))); // 设置大小
            make.top.equalTo(logoImv.mas_bottom).offset(49);
            make.left.equalTo(self.view).offset(YTHAdaptation(63));
            
        }];

    }else if (fourInch)
    {
        [registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(YTHScreenWidth-YTHAdaptation(126), YTHAdaptation(40))); // 设置大小
            make.top.equalTo(logoImv.mas_bottom).offset(69);
            make.left.equalTo(self.view).offset(YTHAdaptation(63));
            
        }];

    }else{
        [registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(YTHScreenWidth-YTHAdaptation(126), YTHAdaptation(40))); // 设置大小
            make.top.equalTo(logoImv.mas_bottom).offset(73);
            make.left.equalTo(self.view).offset(YTHAdaptation(63));
            
        }];

    }
    [registerButton.layer setMasksToBounds:YES];
    [registerButton.layer setCornerRadius:5.5];

    ////    loginView.layer.borderWidth = 1;
    [registerButton setTitle:@"注册" forState:UIControlStateNormal];
    [registerButton setBackgroundImage:[UIImage imageNamed:@"btn_tile"] forState:UIControlStateNormal];
       [registerButton addTarget:self action:@selector(regisBuAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //登录
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
     [self.view addSubview:loginButton];
    [loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(YTHScreenWidth-YTHAdaptation(126), YTHAdaptation(40))); // 设置大小
        make.top.equalTo(registerButton.mas_bottom).offset(YTHAdaptation(19));
        make.left.equalTo(self.view).offset(YTHAdaptation(63));
        
    }];
//    loginButton.frame = CGRectMake(YTHAdaptation(63), CGRectGetMaxY(registerButton.frame)+YTHAdaptation(19), YTHScreenWidth-YTHAdaptation(126), YTHAdaptation(40));
    [loginButton setTitle:@"登录" forState:UIControlStateNormal];
    
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [loginButton setBackgroundImage:[UIImage imageNamed:@"button_hollow"] forState:UIControlStateNormal];
    
    [loginButton addTarget:self action:@selector(loginButtonAction:) forControlEvents:UIControlEventTouchUpInside];
   
    //快捷登录
    UILabel *quickLabel = [[UILabel alloc]init];
    [self.view addSubview:quickLabel];
    if (threeInch) {
        [quickLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(YTHScreenWidth, YTHAdaptation(15))); // 设置大小
            make.top.equalTo(loginButton.mas_bottom).offset(YTHAdaptation(85));
            make.left.equalTo(self.view);
            
        }];
    }else if (fourInch)
    {
        [quickLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(YTHScreenWidth, YTHAdaptation(15))); // 设置大小
            make.top.equalTo(loginButton.mas_bottom).offset(YTHAdaptation(135));
            make.left.equalTo(self.view);
            
        }];
 
    }else
    {
        [quickLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(YTHScreenWidth, YTHAdaptation(15))); // 设置大小
            make.top.equalTo(loginButton.mas_bottom).offset(YTHAdaptation(125));
            make.left.equalTo(self.view);
            
        }];
        
    }
   
    quickLabel.text = @"快捷登录";
    quickLabel.textColor = [UIColor blackColor];
    quickLabel.font = [UIFont systemFontOfSize:14];
    quickLabel.textAlignment = NSTextAlignmentCenter;
    
    
    
    UIView *viewbg = [[UIView alloc]init];
                      [self.view addSubview:viewbg];
    [viewbg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(YTHScreenWidth-YTHAdaptation(40),YTHAdaptation(60))); // 设置大小
        make.top.equalTo(quickLabel.mas_bottom).offset(YTHAdaptation(15));
        make.left.equalTo(self.view).offset(YTHAdaptation(20));
        
    }];
    //viewbg.backgroundColor = [UIColor orangeColor];
   
    NSArray *imgArray = @[@"icon_sina",@"icon_wechat",@"icon_qq"];
    for (int i =0; i<imgArray.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat width = (YTHScreenWidth-YTHAdaptation(50))/3;
        [button setFrame:CGRectMake(i*width, 7, width, YTHAdaptation(44))];
        UIImageView *buttonImage  = [[UIImageView alloc]initWithFrame:CGRectMake(width/2-22, 0, YTHAdaptation(44), YTHAdaptation(44))];
        buttonImage.image =[UIImage imageNamed:imgArray[i]];
        [button addSubview:buttonImage];
        //        [button setImage:[UIImage imageNamed:imgArray[i]] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.tag=i;
        [button addTarget:self action:@selector(selectedClick:) forControlEvents:UIControlEventTouchUpInside];
        [viewbg addSubview:button];
        
    }
    
    UIButton *buttonLook = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:buttonLook];
    [buttonLook mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(YTHScreenWidth,YTHAdaptation(30))); // 设置大小
        make.top.equalTo(viewbg.mas_bottom).offset(YTHAdaptation(10));
        make.left.equalTo(self.view);
        
    }];

   // buttonLook.frame = CGRectMake(0, CGRectGetMaxY(viewbg.frame)+YTHAdaptation(10), YTHScreenWidth, YTHAdaptation(30));
    [buttonLook setTitle:@"先看看去" forState:UIControlStateNormal];
    [buttonLook setShowsTouchWhenHighlighted:YES];
    buttonLook.titleLabel.font = [UIFont systemFontOfSize:14];
    [buttonLook setTitleColor:YTHColor(197, 197, 197) forState:UIControlStateNormal];
    [buttonLook addTarget:self action:@selector(buttonLookAction:) forControlEvents:UIControlEventTouchUpInside];


}
#pragma mark-先看看去
-(void)buttonLookAction:(UIButton *)btn
{
   
    SUCTabBarViewController *mainVC = [[SUCTabBarViewController alloc]init];
    [self presentViewController:mainVC animated:NO completion:nil];

//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    
//    NSString *urlString = [NSString stringWithFormat:@"http://192.168.1.120:8080/starucan_app/weixinLoginAction.action?id=1"];
//    
//    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        YTHLog(@"登录信息：%@",responseObject);
//        YTHLog(@"微信状态 code %ld",(long)[operation.response statusCode]);
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//        YTHLog(@"微信状态错误 code %ld",(long)[operation.response statusCode]);
//        
//    }];

}
#pragma mark -注册
-(void)regisBuAction:(UIButton *)btn
{
    YTHLog(@"注册");
    RegisterViewController *regisVC = [[RegisterViewController alloc]init];
  
    WXNavigationController *nav = [[WXNavigationController alloc]initWithRootViewController:regisVC];
    
    [self presentViewController:nav animated:NO completion:nil];
//
    //[self.navigationController pushViewController:regisVC animated:YES];13810361076
}


#pragma mark - 登录
-(void)loginButtonAction:(UIButton *)btn
{
    
    LoginFirstViewController *loginVC = [[LoginFirstViewController alloc]init];
    WXNavigationController *nav = [[WXNavigationController alloc]initWithRootViewController:loginVC];
      [self presentViewController:nav animated:YES completion:nil];
  

}
- (UINavigationController *)navigationControllerV
{
    UIResponder *next = self.nextResponder;
    do {
        if ([next isMemberOfClass:[UINavigationController class]]) {
            return (UINavigationController *)next;
        }
        next = next.nextResponder;
    } while (next != nil);
    
    return nil;
}
#pragma mark -忘记密码
-(void)forPassButton:(UIButton *)btn
{

    ForgetPassViewController *forgetPassVC = [[ForgetPassViewController alloc]init];
    [self.navigationController pushViewController:forgetPassVC animated:YES];
}
#pragma mark-第三方登录
-(void)selectedClick:(UIButton *)btn
{
    switch (btn.tag) {
        case 0:
        {  YTHLog(@"新浪");
            [ShareSDK getUserInfo:SSDKPlatformTypeSinaWeibo onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
                if (state==SSDKResponseStateSuccess) {
                    YTHLog(@"新浪uid=%@",user.uid);
                    YTHLog(@"新浪%@",user.credential);
                    YTHLog(@"新浪token=%@",user.credential.token);
                    YTHLog(@"新浪nickname=%@",user.nickname);
                }{
                    YTHLog(@"新浪%@",error);
                }
                
            }];

        }
            
            break;
        case 1:
            YTHLog(@"微信");
        {
            if (![WXApi isWXAppInstalled]) {
                UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"通知" message:@"您的设备没有安装微信" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                
            };
            
            
            [ShareSDK getUserInfo:SSDKPlatformTypeWechat onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
                if (state==SSDKResponseStateSuccess) {
                    YTHLog(@"微信用户信息%@",user);
                    YTHLog(@"微信openid=%@",user.uid);
                    YTHLog(@"微信%@",user.credential);
                    YTHLog(@"秘钥%@",user.credential.secret);
                    YTHLog(@"微信nickname=%@",user.nickname);
                    YTHLog(@"性别=%lu",(unsigned long)user.gender);
                    YTHLog(@"头像=%@",user.icon);
                    YTHLog(@"原始=%@",user.rawData);
                    NSDictionary *dictwei =user.rawData;
                        YTHLog(@"原始--=%@",dictwei[@"unionid"]);
                    myDelegate.icon =user.icon;
                    myDelegate.uid =user.uid;
                    myDelegate.nickname =user.nickname;
                    myDelegate.gender = [NSString stringWithFormat:@"%lu",(unsigned long)user.gender];
                    //myDelegate.credential =user.credential;
                    
                    NSString *text =user.uid;
                    NSString *weiPass = [self md5:text];
                    YTHLog(@"随机数%@MD5 加密=%@",text,weiPass);
                    //保存
                    myDelegate.passText = weiPass;
                    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                     NSMutableDictionary *md = [NSMutableDictionary dictionary];
                    md[@"openid"]=user.uid;
                    md[@"nickname"]=myDelegate.nickname;
                    md[@"headimgurl"] = myDelegate.icon;
                    md[@"sex"] = myDelegate.gender;
                    md[@"password"]=myDelegate.passText;
                    myDelegate.regist_u_account =user.uid;
                    NSString *url = Url;
                   
                    //http://192.168.1.168:8080/starucan_app/weixinLoginAction.action?id=1
                    
                    NSString *urlString = [NSString stringWithFormat:@"%@v1/user/weixin/login",url];
                    
                    [manager POST:urlString parameters:md success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        YTHLog(@"登录信息：%@",responseObject);
                         YTHLog(@"微信状态 code %ld",(long)[operation.response statusCode]);
    
                        if ([operation.response statusCode]/100==2) {
//                            [MBProgressHUD showSuccess:@"注册成功"];
                            YTHLog(@"微信登录成功");
                            
                             myDelegate.userInfo = [responseObject objectForKey:@"userInfo"];

                        }
    
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                         YTHLog(@"微信状态错误 code %ld",(long)[operation.response statusCode]);
                    }];
                    
 
                    AddInformationViewController *regisVC = [[AddInformationViewController alloc]init];
                    WXNavigationController *nav = [[WXNavigationController alloc]initWithRootViewController:regisVC];
                    [self presentViewController:nav animated:NO completion:nil];

                }{
                    YTHLog(@"微信%@",error);
                }
            }];
        }
            break;
        case 2:{
          
            YTHLog(@"QQ");
            
            [ShareSDK getUserInfo:SSDKPlatformTypeQQ onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
                if (state==SSDKResponseStateSuccess) {
                    YTHLog(@"qquid=%@",user.uid);
                    YTHLog(@"qq%@",user.credential);
                    YTHLog(@"qq_token=%@",user.credential.token);
                    YTHLog(@"nickname=%@",user.nickname);
      
                }{
                    YTHLog(@"qq%@",error);
                }
            }];
        }
            break;
        default:
            break;
    }
    
}
- (NSString *)md5:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}
-(NSString *)ret32bitString

{
    
    char data[9];
    
    for (int x=0;x<9;data[x++] = (char)('A' + (arc4random_uniform(26))));
    
    return [[NSString alloc] initWithBytes:data length:9 encoding:NSUTF8StringEncoding];
    
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
