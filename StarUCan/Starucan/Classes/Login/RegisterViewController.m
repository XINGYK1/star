//
//  RegisterViewController.m
//  Starucan
//
//  Created by vgool on 15/12/31.
//  Copyright © 2015年 vgool. All rights reserved.
//

#import "RegisterViewController.h"
#import "MBProgressHUD+NJ.h"
#import "RegisterSecondViewController.h"
#import "GXHttpTool.h"
#import "AddInformationViewController.h"
#import "AppDelegate.h"
#import "NSData+AES256.h"
#import <CommonCrypto/CommonDigest.h>
@interface RegisterViewController ()<UITextFieldDelegate,UIScrollViewDelegate>{
    NSTimer *yanzhengmaTimer;
    int yanzhengmaIndex;
    AppDelegate *myDelegate;
    
}
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UITextField *phoneTF;
@property (nonatomic, weak) UIButton *getBtn;
@property (nonatomic, weak) UITextField *authCodeTF;//验证码输入框
@property (nonatomic, weak) UITextField *passwordTF;
@property (nonatomic, weak) UITextField *passwordSecondTF;

@property (nonatomic, weak) UIButton *regisBtn;
@property (nonatomic,strong)NSDictionary *jsonDict;
@property (nonatomic,strong)NSDictionary *regisDict;
@property (nonatomic, assign)BOOL loginStatus;


@end

@implementation RegisterViewController
#define BWMDongTaiZhi(dongTaiZhi) (dongTaiZhi/320.0f)*[[UIScreen mainScreen]bounds].size.width

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!myDelegate) {
        myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    self.regisDict = [[NSDictionary alloc]init];
    self.jsonDict = [[NSDictionary alloc]init];
    // Do any additional setup after loading the view.
    self.title = @"注册";
    [self _initNation];
    UIScrollView *scrollview = [[UIScrollView alloc] init];
    scrollview.frame =CGRectMake(0, 0, YTHScreenWidth, YTHScreenHeight);
    scrollview.backgroundColor = YTHColor(235, 235, 241);
    scrollview.scrollEnabled = YES;
    scrollview.contentSize =CGSizeMake(YTHScreenWidth,YTHScreenHeight+150);
    self.scrollView = scrollview;
    self.getBtn.enabled = YES;
    self.view = scrollview;
    //设置手机号输入框
    [self setPhoneTextFied];
    //请输入验证码
    [self setauthCodeTextFied];
    //验证码
    [self setGetAuthcodeButton];
    //点击空白处
    [self tapToDismissKB];
    //密码
    [self setPasswordTextFied];
    //注册按钮
    [self setRegisterButton];
    //注册协议
    [self _initAgreement];
    yanzhengmaIndex = 0;
    [self.getBtn setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"button_verify_off.png"]]];
}
#pragma mark - 设置手机号输入框
- (void)setPhoneTextFied{
    UITextField *phoneTF = [[UITextField alloc] initWithFrame:CGRectMake(YTHAdaptation(16),YTHAdaptation(32), YTHScreenWidth- YTHAdaptation(32),YTHAdaptation(40))];
    phoneTF.delegate = self;
    phoneTF.borderStyle = UITextBorderStyleNone;
    phoneTF.backgroundColor = [UIColor whiteColor];
    phoneTF.layer.borderColor = YTHColor(200, 200, 200).CGColor;
    [phoneTF.layer setMasksToBounds:YES];
    [phoneTF.layer setCornerRadius:4.5];
    phoneTF.layer.borderWidth = 1;
    phoneTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, YTHAdaptation(60), YTHAdaptation(45))];
    phoneTF.leftViewMode = UITextFieldViewModeAlways;
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,YTHAdaptation(60),YTHAdaptation(45))];
    lab.font = [UIFont systemFontOfSize:14];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.text = @"+86   ";
    lab.textColor = YTHColor(118, 118, 118);
    [phoneTF.leftView addSubview:lab];
    phoneTF.placeholder = @"请输入手机号";
    phoneTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    phoneTF.keyboardType = UIKeyboardTypeNumberPad;
    phoneTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [phoneTF addTarget:self action:@selector(textChanged) forControlEvents:UIControlEventEditingChanged];
    self.phoneTF = phoneTF;
    [self.view addSubview:phoneTF];
}
#pragma mark - 请输入短信中的验证码
- (void)setauthCodeTextFied{
    UITextField *authCodeTF = [[UITextField alloc] initWithFrame:CGRectMake(YTHAdaptation(16), CGRectGetMaxY(self.phoneTF.frame)+YTHAdaptation(10), YTHScreenWidth-YTHAdaptation(32), YTHAdaptation(40))];
    authCodeTF.delegate = self;
    authCodeTF.borderStyle = UITextBorderStyleNone;
    authCodeTF.backgroundColor = [UIColor whiteColor];
    authCodeTF.layer.borderColor = YTHColor(200, 200, 200).CGColor;
    [authCodeTF.layer setMasksToBounds:YES];
    [authCodeTF.layer setCornerRadius:4.5];
    authCodeTF.layer.borderWidth = 1;
    authCodeTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, YTHAdaptation(20), YTHAdaptation(50))];
    authCodeTF.leftViewMode = UITextFieldViewModeAlways;
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, YTHAdaptation(20), YTHAdaptation(50))];
    [authCodeTF.leftView addSubview:lab];
    authCodeTF.placeholder = @"请输入短信中的验证码";
    authCodeTF.keyboardType = UIKeyboardTypeNumberPad;
    authCodeTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [authCodeTF addTarget:self action:@selector(textChanged) forControlEvents:UIControlEventEditingChanged];
    self.authCodeTF = authCodeTF;
    [self.view addSubview:authCodeTF];
}
#pragma mark - 设置获取验证码按钮
- (void)setGetAuthcodeButton{
    
    UIButton *getBtn = [[UIButton alloc]initWithFrame:CGRectMake(YTHScreenWidth-YTHAdaptation(115), CGRectGetMaxY(self.phoneTF.frame)+YTHAdaptation(10), YTHAdaptation(98),YTHAdaptation(40))];
    
    [getBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    //getBtn.backgroundColor = [UIColor redColor];
    
    [getBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    getBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    
    [getBtn addTarget:self action:@selector(getRegisterAuth:) forControlEvents:UIControlEventTouchUpInside];
    
    self.getBtn = getBtn;
    
    [self.view addSubview:getBtn];
}
-(void)getRegisterAuth:(UIButton *)btn
{
    
    if (![self isValidatePhone:self.phoneTF.text]) {
        [MBProgressHUD showError:@"手机号格式不正确"];
        return;
    }
    
    if (self.phoneTF.text.length != 11){
        [MBProgressHUD showError:@"请输入正确的手机号码"];
        return;
    }
    
    //获取验证码参数
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    md[@"mobile"] =self.phoneTF.text;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *url = Url;
    
    NSString *urlString = [NSString stringWithFormat:@"%@v1/base/authcode",url];
    //http://test.platform.vgool.cn/starucan/
    
//    [manager GET:urlString parameters:md success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        
//        self.jsonDict = responseObject;
//        
//        if ([operation.response statusCode]/100==2) {
//            //服务器返回status=200，表示连接成功。
//            
//            YTHLog(@"返回%ld",[operation.response statusCode]);
//            
//            [MBProgressHUD showSuccess:@"发送成功"];
//            
//            self.getBtn.enabled = NO;
//            if (yanzhengmaTimer) {
//                [yanzhengmaTimer invalidate];
//                yanzhengmaTimer  = nil;
//            }
//            yanzhengmaIndex = 60;
//            
//            [self huoquyanzhengmaBtLoad];
//            
//            yanzhengmaIndex--;
//            
//            yanzhengmaTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(huoquyanzhengmaBtLoad) userInfo:nil repeats:YES];
//        }else{
//            
//            self.getBtn.enabled = YES;
//        }
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//        self.jsonDict = operation.responseObject;
//        
//        [MBProgressHUD showError:[ self.jsonDict objectForKey:@"info"]];
//        
//        YTHLog(@"-----error code %ld",(long)[operation.response statusCode]);
//    
//    }];
    
    [manager POST:urlString parameters:md success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        self.jsonDict = responseObject;
        
        if ([operation.response statusCode]/100==2) {
            //服务器返回status=200，表示连接成功。
            
            YTHLog(@"返回%ld",[operation.response statusCode]);
            
            [MBProgressHUD showSuccess:@"发送成功"];
            
            self.getBtn.enabled = NO;
            if (yanzhengmaTimer) {
                [yanzhengmaTimer invalidate];
                yanzhengmaTimer  = nil;
            }
            yanzhengmaIndex = 60;
            
            [self huoquyanzhengmaBtLoad];
            
            yanzhengmaIndex--;
            
            yanzhengmaTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(huoquyanzhengmaBtLoad) userInfo:nil repeats:YES];
        }else{
            
            self.getBtn.enabled = YES;
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        self.jsonDict = operation.responseObject;
        
        [MBProgressHUD showError:[ self.jsonDict objectForKey:@"info"]];
        
        YTHLog(@"-----error code %ld",(long)[operation.response statusCode]);
        
    }];
    
}

//计时器
- (void) huoquyanzhengmaBtLoad{
    
    if (yanzhengmaIndex <= 0) {
        self.getBtn.enabled = YES;
        [yanzhengmaTimer invalidate];
        yanzhengmaTimer  = nil;
        [self.getBtn setTitle:@"获取验证码" forState: UIControlStateNormal];
    }else{
        [self.getBtn setTitle:[NSString stringWithFormat:@"%ds后重发",yanzhengmaIndex] forState: UIControlStateDisabled];
    }
    yanzhengmaIndex--;
}
#pragma mark - 设置密码输入框
- (void)setPasswordTextFied{
    UITextField *passwordTF = [[UITextField alloc] initWithFrame:CGRectMake(YTHAdaptation(16), CGRectGetMaxY(self.authCodeTF.frame)+YTHAdaptation(20), YTHScreenWidth-YTHAdaptation(32), YTHAdaptation(40))];
    passwordTF.delegate = self;
    passwordTF.borderStyle = UITextBorderStyleNone;
    passwordTF.backgroundColor = [UIColor whiteColor];
    passwordTF.layer.borderColor = YTHColor(200, 200, 200).CGColor;
    [passwordTF.layer setMasksToBounds:YES];
    [passwordTF.layer setCornerRadius:4.5];
    passwordTF.layer.borderWidth = 1;
    passwordTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, YTHAdaptation(40),YTHAdaptation(50))];
    passwordTF.leftViewMode = UITextFieldViewModeAlways;
    UIView *passView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,YTHAdaptation(40),YTHAdaptation(50))];
    UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(YTHAdaptation(15), YTHAdaptation(15), YTHAdaptation(16), YTHAdaptation(16))];
    imgV.image = [UIImage imageNamed:@"key"];
    [passView addSubview:imgV];
    [passwordTF.leftView addSubview:passView];
    passwordTF.placeholder = @"密码(6~15个字符)";
    passwordTF.secureTextEntry = YES;
    passwordTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [passwordTF addTarget:self action:@selector(textChanged) forControlEvents:UIControlEventEditingChanged];
    self.passwordTF = passwordTF;
    [self.view addSubview:passwordTF];
    UITextField *passwordSecondTF = [[UITextField alloc] initWithFrame:CGRectMake(YTHAdaptation(16), CGRectGetMaxY(passwordTF.frame)+YTHAdaptation(10), YTHScreenWidth-YTHAdaptation(32), YTHAdaptation(40))];
    passwordSecondTF.delegate = self;
    passwordSecondTF.borderStyle = UITextBorderStyleNone;
    passwordSecondTF.backgroundColor = [UIColor whiteColor];
    passwordSecondTF.layer.borderColor = YTHColor(200, 200, 200).CGColor;
    [passwordSecondTF.layer setMasksToBounds:YES];
    [passwordSecondTF.layer setCornerRadius:4.5];
    passwordSecondTF.layer.borderWidth = 1;
    passwordSecondTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, YTHAdaptation(40),YTHAdaptation(50))];
    passwordSecondTF.leftViewMode = UITextFieldViewModeAlways;
    UIView *passSecView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, YTHAdaptation(40), YTHAdaptation(50))];
    UIImageView *imgVSec = [[UIImageView alloc]initWithFrame:CGRectMake(YTHAdaptation(15), YTHAdaptation(15), YTHAdaptation(16), YTHAdaptation(16))];
    imgVSec.image = [UIImage imageNamed:@"key_ture"];
    [passSecView addSubview:imgVSec];
    [passwordSecondTF.leftView addSubview:passSecView];
    passwordSecondTF.placeholder = @"再次输入密码";
    passwordSecondTF.secureTextEntry = YES;
    passwordSecondTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [passwordSecondTF addTarget:self action:@selector(textChanged) forControlEvents:UIControlEventEditingChanged];
    self.passwordSecondTF = passwordSecondTF;
    [self.view addSubview:passwordSecondTF];
}
#pragma mark - 设置注册按钮
- (void)setRegisterButton{
    UIButton *regisBtn = [[UIButton alloc]initWithFrame:CGRectMake(YTHAdaptation(15), CGRectGetMaxY(self.passwordSecondTF.frame)+YTHAdaptation(44), YTHScreenWidth-YTHAdaptation(30), YTHAdaptation(40))];
    regisBtn.layer.borderColor = YTHColor(200, 200, 200).CGColor;
    [regisBtn.layer setMasksToBounds:YES];
    [regisBtn.layer setCornerRadius:4.5];
    regisBtn.layer.borderWidth = 1;
    [regisBtn setTitle:@"注册" forState:UIControlStateNormal];
    [regisBtn addTarget:self action:@selector(clickRegisBtn:) forControlEvents:UIControlEventTouchUpInside];
    [regisBtn setBackgroundImage:[UIImage imageNamed:@"btn_tile"] forState:UIControlStateNormal];
    regisBtn.enabled = NO;
    self.regisBtn = regisBtn;
    [self.view addSubview:regisBtn];
}
#pragma mark - 注册点击按钮
- (void)clickRegisBtn:(UIButton *)btn{
    if (![self isValidatePhone:self.phoneTF.text]) {
        [MBProgressHUD showError:@"手机号格式不正确"];
        return;
    }
    if (self.authCodeTF.text.length != 6) {
        [MBProgressHUD showError:@"请输入正确验证码"];
        return;
    }
    if (![self.passwordSecondTF.text isEqualToString:self.passwordTF.text]){
        [MBProgressHUD showError:@"两次输入密码不一致"];
        return;
    }
    if (![self isValidatePassword:self.passwordTF.text]) {
        [MBProgressHUD showError:@"请输入6-15位字符密码"];
    }
    if (self.phoneTF.text.length == 0 || self.passwordTF.text.length == 0 || self.authCodeTF.text.length == 0||self.passwordSecondTF.text.length==0){
        [MBProgressHUD showError:@"请输入完整信息"];
        return;
    }
    
    //注册传得参数
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    NSString *text =[self md5:self.passwordTF.text];
    md[@"mobile"] =self.phoneTF.text;
    md[@"authCode"] = self.authCodeTF.text;
    md[@"password"] = text;
    //保存
    myDelegate.accessToken = text;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *url = Url;
    NSString *urlString = [NSString stringWithFormat:@"%@v1/user/regist",url];
    [manager POST:urlString parameters:md success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.regisDict = responseObject;
        if ([operation.response statusCode]/100==2) {
            [MBProgressHUD showSuccess:@"注册成功"];
            //清空
            self.phoneTF.text = @"";
            self.authCodeTF.text = @"";
            self.passwordSecondTF.text= @"";
            self.passwordTF.text = @"";
            //第二种
            myDelegate.regist_accesstoken = responseObject[@"token"];
//            myDelegate.userInfo = [responseObject objectForKey:@"userInfo"];
            
//            myDelegate.name = [responseObject objectForKey:@"name"];
            //保存信息第一方式测试
            SUCArchive *archive = [SUCArchive shareArchiveManager];
            
            // 网络请求成功, 就在用户偏好中设置登录状态
            NSUserDefaults *userDE=[NSUserDefaults standardUserDefaults];
            
            _loginStatus = YES;
            [userDE setBool:self.loginStatus forKey:LoginStatus];
            [userDE synchronize];
            // 注册成功, 就在用户偏好中设置为登录成功状态
            //            NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
             if ([archive online]) {
                 
#warning 内存泄露
//            SUCUser *user = [SUCUser shareUser];
            SUCUser *user = [SUCUser objectWithKeyValues:responseObject[@"userInfo"]];
            NSMutableDictionary *md = [NSMutableDictionary dictionary];
            md[@"uuid"] = user.uuid;
            md[@"name"] = user.name;
            md[@"avatar"] = user.avatar;//头像
            md[@"account"] = user.account;
            
            [archive synchronize];
             }
            //             [user setObject:[operation.response statusCode] forKey:@"success"];
            myDelegate.regist_u_account =self.phoneTF.text;
            myDelegate.account =self.phoneTF.text;
            RegisterSecondViewController *regisSuccV = [[RegisterSecondViewController alloc]init];
            [self presentViewController:regisSuccV animated:NO completion:nil];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    
        YTHLog(@"-----error code %ld",(long)[operation.response statusCode]);
        self.jsonDict = operation.responseObject;
        [MBProgressHUD showError:[ self.jsonDict objectForKey:@"info"]];
    
    
    }];
    
    
}
- (void)textChanged{
    self.regisBtn.enabled = (self.phoneTF.text.length>0 && self.passwordTF.text.length>0&&self.authCodeTF.text.length>0&&[self.passwordSecondTF.text isEqualToString:self.passwordTF.text]);
}

#pragma mark - 注册协议
-(void)_initAgreement{
    UILabel *labelAgreement = [[UILabel alloc]initWithFrame:CGRectMake(50, CGRectGetMaxY(self.regisBtn.frame)+12, YTHScreenWidth-100, 20)];
    labelAgreement.text = @"注册或绑定即代表您同意我们的注册协议";
    labelAgreement.font = [UIFont systemFontOfSize:12];
    labelAgreement.textAlignment = NSTextAlignmentCenter;
    labelAgreement.textColor = YTHColor(197, 197, 197);
    labelAgreement.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(agreeWith:)];
    [labelAgreement addGestureRecognizer:tapGesture];

    [self.view addSubview:labelAgreement];
}
- (void)agreeWith:(UITapGestureRecognizer *)gesture {
    YTHLog(@"注册协议");
}
-(void)_initNation
{
    // 左边的取消按钮
    UIButton *cancelBtn = [[UIButton alloc] init];
    cancelBtn.frame = CGRectMake(0, 0, 40, 40);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    [cancelBtn addTarget:self action:@selector(clickCode) forControlEvents:UIControlEventTouchUpInside];
    
    
}
-(void)clickCode
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
#pragma mark - 设置点击空白处隐藏键盘
- (void)tapToDismissKB{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    // 设置成NO表示当前控件响应后会传播到其他控件上，默认为YES
    tapGestureRecognizer.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)dismissKeyboard{
    [self.phoneTF resignFirstResponder];
    [self.authCodeTF resignFirstResponder];
    [self.passwordTF resignFirstResponder];
    [self.passwordSecondTF resignFirstResponder];
    
    
}

#pragma mark - 验证手机号合法性
- (BOOL)isValidatePhone:(NSString *)phone {
    
    NSString *phoneRegex = @"^1(3[0-9]|5[0-9]|7[0-9]|8[0-9])\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phoneTest evaluateWithObject:phone];
    
}
#pragma mark -TextField代理
- (BOOL)textFieldShouldBeginEditing:(UITextField*)textField {
    if (textField==self.passwordTF) {
        if (self.phoneTF.text.length==0) {
            [MBProgressHUD showError:@"手机号不能为空"];
        }
        if (self.authCodeTF.text.length==0) {
            [MBProgressHUD showError:@"验证码不能为空"];
            
        }
    }
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
    if (textField==self.phoneTF) {
        if (![self isValidatePhone:toBeString]) {
            self.getBtn.enabled=NO;
            [self.getBtn setBackgroundImage: [UIImage imageNamed:@"button_verify_off"] forState:UIControlStateNormal];
        }else{
            self.getBtn.enabled = YES;
            [self.getBtn setBackgroundImage:[UIImage imageNamed:@"button_verify_on"] forState:UIControlStateNormal];
        }
    }
    if (textField==self.passwordTF) {
        if (![self isValidatePassword:toBeString]) {
            self.passwordTF.layer.borderColor = [UIColor redColor].CGColor;
        }else{
            self.passwordTF.layer.borderColor = [UIColor greenColor].CGColor;
        }
        
        
    }
    if (textField==self.passwordSecondTF) {
        if (![toBeString isEqualToString:self.passwordTF.text]||![self isValidatePassword:toBeString]) {
            self.passwordSecondTF.layer.borderColor = [UIColor redColor].CGColor;
        }else{
            self.passwordSecondTF.layer.borderColor = [UIColor greenColor].CGColor;
        }
    }
    
    return YES;
    
}
#pragma mark - 验证密码合法性
- (BOOL)isValidatePassword:(NSString *)passWord
{
    NSString *passWordRegex = @"^[a-zA-Z0-9]{6,15}+$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passWordRegex];
    return [passWordPredicate evaluateWithObject:passWord];
}
-(UIColor *)getColor:(NSString *)hexColor {
    unsigned int red,green,blue;
    NSRange range;
    range.length = 2;
    
    range.location = 0;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
    
    range.location = 2;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
    
    range.location = 4;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];
    
    return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green / 255.0f) blue:(float)(blue / 255.0f) alpha:1.0f];
}
-(NSString *)ret32bitString

{
    
    char data[32];
    
    for (int x=0;x<32;data[x++] = (char)('A' + (arc4random_uniform(26))));
    
    return [[NSString alloc] initWithBytes:data length:32 encoding:NSUTF8StringEncoding];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
