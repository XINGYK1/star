//
//  AddInformationViewController.m
//  Starucan
//
//  Created by vgool on 16/1/4.
//  Copyright © 2016年 vgool. All rights reserved.
//

#import "AddInformationViewController.h"
#import "AttentionViewController.h"
#import "UnListViewController.h"
#import "GXHttpTool.h"
#import "AppDelegate.h"
#import "MBProgressHUD+NJ.h"
#import "AFHTTPRequestOperationManager.h"
#import "SUCArchive.h"
#import "SUCUser.h"
#import "AttentionViewController.h"
#import "HandsomeView.h"
#import "LabelModel.h"
#import "NSData+AES256.h"
#import "WXNavigationController.h"


@interface AddInformationViewController ()<HandsomeDelegate>
{
    AppDelegate *myDelegate;
    NSData *data;
    UIButton *univerButton;
    UIButton  *finishButton;
    NSMutableArray *_kTitleArrays;
    NSMutableArray *_kuuidArrays;
    
    int start;
    int count;
    NSMutableArray *labelArray;
    HandsomeView *_kHandsomeView;
    NSMutableDictionary *_kIdMutabDict;
    CGRect _kMarkRect;
    UIScrollView *_kTitleView;
    
    
    
}
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) UIButton *finishButton;
@property (nonatomic, strong)UILabel *labelText;
@property (nonatomic, strong)NSMutableDictionary *jason;

@property (nonatomic,strong)NSMutableArray *labelUuidArr;
@property (nonatomic,strong)UIButton *kDeleteButton;
@property (nonatomic,strong)UILabel *univerLabel;
@property (nonatomic,strong)NSString *imgflag;
@end

@implementation AddInformationViewController
- (void)viewWillAppear:(BOOL)animated {
    
    //调用父类的方法
    [super viewWillAppear:animated];
    
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _labelUuidArr = [NSMutableArray array];
    
    if (!myDelegate) {
        myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    UIScrollView *scrollview = [[UIScrollView alloc] init];
    scrollview.frame =CGRectMake(0,0, YTHScreenWidth, YTHScreenHeight);
    //
    scrollview.backgroundColor = YTHBaseVCBackgroudColor;
    if (threeInch) {
        scrollview.contentSize =CGSizeMake(YTHScreenWidth,YTHScreenHeight+50);
    }else{
        scrollview.contentSize =CGSizeMake(YTHScreenWidth,YTHScreenHeight-64);
    }
    self.scrollView = scrollview;
    self.view = scrollview;
    
    start = 0;
    count = 10;
    labelArray = [[NSMutableArray alloc]init];
    
    // Do any additional setup after loading the view.
    self.title = @"补充信息";
    //self.view.backgroundColor = YTHBaseVCBackgroudColor;
    //请求标签数据
    [self requestData];
    
    [self _initCreat];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receivedNotifDetail:) name:@"noticeRefreshCollectList" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(labelAddStart:) name:@"labelSrart" object:nil];
}


#pragma mark 请求标签
-(void)requestData
{
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];

//    md[@"type"]=@"0";//
//    md[@"start"] = [NSString stringWithFormat:@"%d",start];
//    md[@"count"] =[NSString stringWithFormat:@"%d",count];
//
//    NSString *url1 = Url;
    
    md[@"startPage"] = [NSString stringWithFormat:@"%d",start];//起始页
    md[@"pageSize"] =[NSString stringWithFormat:@"%d",count];//每页多少数据

    
    NSString *labelList = theUrl;
    
    NSString *url =[NSString stringWithFormat:@"%@getLabelListAction.action",labelList];
    
    // @"http://test.platform.vgool.cn/starucan/v1/label"
    
    //[labelArray removeAllObjects];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager POST:url parameters:md success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        self.jason =responseObject;
        
        YTHLog(@"error code %ld",(long)[operation.response statusCode]);
        
        YTHLog(@"标签 -----%@",responseObject);
        
        if (!_kIdMutabDict) {
            _kIdMutabDict = [[NSMutableDictionary alloc]init];
        }
        
        [_kIdMutabDict removeAllObjects];
        
        NSString *status = [responseObject objectForKey:@"status"];
        
        if ([status isEqualToString:@"success"]) {
            
            NSArray *arry = [responseObject objectForKey:@"labelList"];
            
            myDelegate.labelId =[responseObject objectForKey:@"labelList"];
            
            for (NSDictionary *dic in arry)
            {
                [_kIdMutabDict setObject:[dic objectForKey:@"uuid"] forKey:[dic objectForKey:@"name"]];
            }
            labelArray = [NSMutableArray arrayWithArray:_kIdMutabDict.allKeys];
            
            YTHLog(@"标签uuid：%@",_kIdMutabDict);
        }
        
        if (_kHandsomeView) {
            
            [self reloadDataArray];
            
        }else{
            
            [self _initButton];
            
        }
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YTHLog(@"error code %ld",(long)[operation.response statusCode]);
    }];
}

-(void)reloadDataArray{
    
    [_kHandsomeView reloadDataArray:labelArray];
}

- (void)receivedNotifDetail:(NSNotification*)notification
{
    self.univerLabel.text =myDelegate.university_name;
    self.univerLabel.textColor = YTHColor(91, 91, 91);
    self.univerLabel.textAlignment = NSTextAlignmentCenter;
   
}
#pragma mark 标签换一换
- (void)labelAddStart:(NSNotification*)notification
{
    start=start+count;
    
    [labelArray removeAllObjects];
    [self requestData];
}

- (void)labelAddStart
{
    start = start+1;
    
    if (start== [[self.jason objectForKey:@"page"]integerValue]) {
        
        start=0;
        
    }
    
    NSLog( @"页码%d",start);
    
    [labelArray removeAllObjects];
    
    [self requestData];
 
    
}

-(void)_initCreat
{
    
    // 左边的取消按钮
    UIButton *cancelBtn = [[UIButton alloc] init];
    cancelBtn.frame = CGRectMake(0, 0, 30, 30);
    [cancelBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    [cancelBtn addTarget:self action:@selector(clickCode) forControlEvents:UIControlEventTouchUpInside];
    
    
    //选择大学
    univerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    univerButton.frame = CGRectMake(YTHAdaptation(16),YTHAdaptation(20), YTHScreenWidth-YTHAdaptation(32),YTHAdaptation(40));
    [univerButton addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    univerButton.backgroundColor = [UIColor whiteColor];
    [univerButton.layer setMasksToBounds:YES];
    [univerButton.layer setCornerRadius:4.5];
    univerButton.layer.borderColor = YTHColor(197, 197, 197).CGColor;
    univerButton.layer.borderWidth = 1;
    //    [univerButton setTitle:@"选择你的真实学校，(一旦选择将不可更改)" forState:UIControlStateNormal];
    //    univerButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0,YTHAdaptation(98));
    UILabel *univerLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0,YTHScreenWidth-YTHAdaptation(32), YTHAdaptation(40))];
    univerLabel.text =@"选择你的真实学校，(一旦选择将不可更改)";
    univerLabel.textColor = YTHColor(197, 197, 197);
    univerLabel.font = [UIFont systemFontOfSize:14];
    self.univerLabel = univerLabel;
    [univerButton addSubview:univerLabel];
    [univerButton setTitleColor:YTHColor(197, 197, 197) forState:UIControlStateNormal];
    univerButton.titleLabel.font = [UIFont systemFontOfSize:12];
    
    UIImageView *imageMore = [[UIImageView alloc]initWithFrame:CGRectMake(univerButton.frame.size.width-YTHAdaptation(30), YTHAdaptation(13),YTHAdaptation(8),YTHAdaptation(16))];
    imageMore.image = [UIImage imageNamed:@"more_right"];
    [univerButton addSubview:imageMore];
    [self.view addSubview:univerButton];
    UILabel *labelText= [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(univerButton.frame)+YTHAdaptation(30), YTHScreenWidth, YTHAdaptation(25))];
    labelText.text = @"选择感兴趣的标签我们将能更好的送上适合您的内容";
    labelText.textColor = [UIColor grayColor];
    labelText.font = [UIFont systemFontOfSize:12];
    labelText.textAlignment = NSTextAlignmentCenter;
    self.labelText = labelText;
    [self.view addSubview:labelText];
}
//返回
-(void)clickCode
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)_initButton
{
    _kHandsomeView = [[HandsomeView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.labelText.frame)+YTHAdaptation(10), YTHScreenWidth, YTHAdaptation(250))andData:labelArray];
    // handV.backgroundColor = [UIColor yellowColor];
    
    _kHandsomeView.delegate = self;
    
    [self.view addSubview:_kHandsomeView];
    _kTitleView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(univerButton.frame)+YTHAdaptation(330), YTHScreenWidth, YTHAdaptation(130))];
    //_kTitleView.backgroundColor = [UIColor redColor];
    _kTitleView.backgroundColor = YTHBaseVCBackgroudColor;
    [self.view addSubview:_kTitleView];
    
    
    finishButton = [[UIButton alloc]initWithFrame:CGRectMake(YTHAdaptation(15), CGRectGetMaxY(_kTitleView.frame)+YTHAdaptation(20), YTHScreenWidth-YTHAdaptation(30),YTHAdaptation(40))];
    finishButton.layer.borderColor = YTHColor(200, 200, 200).CGColor;
    [finishButton.layer setMasksToBounds:YES];
    [finishButton.layer setCornerRadius:4.5];
    finishButton.layer.borderWidth = 1;
    [finishButton setTitle:@"完成" forState:UIControlStateNormal];
    [finishButton setBackgroundImage:[UIImage imageNamed:@"btn_tile"] forState:UIControlStateNormal];
    [finishButton addTarget:self action:@selector(finishButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.finishButton = finishButton;
    
    [self.view addSubview:finishButton];
    
    
}

#pragma mark-点击完成
-(void)finishButtonAction
{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    if ([self.univerLabel.text isEqualToString:@"选择你的真实学校，(一旦选择将不可更改)"]) {
        
        [MBProgressHUD showError:@"请选择所在的学校"];
    }

    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSString *uuid = [ud objectForKey:@"user_uuid"];
    
     _sex =[ud objectForKey:@"user_sex"];
    
    
    NSMutableDictionary *mdd = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *mddd = [NSMutableDictionary dictionary];
    
    NSString *universityId = myDelegate.universityId;
    
    md[@"user_uuid"] = uuid;//用户id
    
    md[@"user_sex"]= _sex;//性别
    
    md[@"university_id"] = universityId;//学校
    
    md[@"parameterList"] = _labelUuidArr;//标签uuid数组
//    
//    if (_imgData <0) {
//        
        md[@"flag"] =@"Y";
        
//    }else{
//        md[@"flag"] =@"N";
//    }
//    
    mdd[@"model"] = md;
    
//    YTHLog(@"头像——————%@",_imgData);
    
    YTHLog(@"uuid:%@——————————性别： %@————————学校id：%@————————————标签数组%@",uuid,self.sex,myDelegate.universityId,_labelUuidArr);
    
    NSString *url = theUrl;
    
    
//    NSDictionary *dicc = [NSDictionary dictionary];

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mdd options:0 error:nil];
    
    NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    mddd[@"jsonStr"] = jsonString;
    
    mddd[@"file"] = @"currentImage.png";
    
    NSString *urlString = [NSString stringWithFormat:@"%@registrationRegistrationAction.action",url];
    
      YTHLog(@"完成注册信息参数%@",mddd);
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        
    [manager POST:urlString parameters:mddd constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        //把data拼接给formData,name:是你需要传的参数名,fileName:是你要保存到服务器的参数名 mimeType是文件格式
        [formData appendPartWithFileData:_imgData name:@"file" fileName:@"icon.png" mimeType:@"image/png"];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *status = [responseObject objectForKey:@"status"];

            if ([status isEqualToString:@"success"]) {//补充信息上传成功，跳到推荐页
                
                AttentionViewController *avc = [[AttentionViewController alloc]init];
                
                WXNavigationController *nav = [[WXNavigationController alloc]initWithRootViewController:avc];
                
                [self presentViewController:nav animated:NO completion:nil];
//        
//        SUCTabBarViewController *mainVC = [[SUCTabBarViewController alloc]init];
//        
//        [self presentViewController:mainVC animated:NO completion:nil];
                
            }else{
                
            [MBProgressHUD showError:@"上传失败，请稍后重试"];
                

            }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"fail");
        
    }];
    
}


//选择大学
-(void)buttonAction
{
    UnListViewController *unList = [[UnListViewController alloc]init];
    [self.navigationController pushViewController:unList animated:YES];
    
}
-(void)handsomeView:(HandsomeView *)zheView didClickTag:(UIButton *)button didClickTitle:(NSString *)title
{
    if (!_kTitleArrays) {
        _kTitleArrays = [[NSMutableArray alloc]init];
    }
    if(button.selected){
        
    }else{
        
    }
    if([_kTitleArrays containsObject:title]){
        [_kTitleView removeFromSuperview];
        _kTitleView = nil;
        [_kTitleArrays removeObject:title];
        _kMarkRect = CGRectMake(0, 0, 0, 0);
        button.selected = NO;
        button.layer.borderWidth = 0;//设置边框的宽度，当然可以不要
        button.layer.borderColor = [[UIColor redColor] CGColor];//设置边框的颜色
        for (NSString *title in _kTitleArrays) {
            [self _addTitleBtn:title andAdd:NO];
        }
    }else{
        if (_kTitleArrays.count>9) {
            //self.kDeleteButton.enabled = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UibuttonEnable" object:nil userInfo:nil];
            [MBProgressHUD showError:@"标签最多选10个"];
            return ;
        }
        button.selected = YES;
        button.layer.borderWidth = 1;//设置边框的宽度，当然可以不要
        button.layer.borderColor = [[UIColor redColor] CGColor];//设置边框的颜色
        [self _addTitleBtn:title andAdd:YES];
    }
    
}
//
-(void)_addTitleBtn:(NSString *)title andAdd:(BOOL)add{
    if (!_kTitleView) {
        _kTitleView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(univerButton.frame)+ YTHAdaptation(330), YTHScreenWidth,YTHAdaptation(130))];
        // _kTitleView.backgroundColor = [UIColor redColor];
        _kTitleView.backgroundColor = YTHBaseVCBackgroudColor;
        [self.view addSubview:_kTitleView];
    }
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:12]};
    CGFloat length = [title boundingRectWithSize:CGSizeMake(320, 2000) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size.width;
    CGFloat xxxx = _kMarkRect.origin.x + _kMarkRect.size.width + length + 30;
    if (_kMarkRect.origin.y == 0) {
        _kMarkRect.origin.y = 10;
    }
    if (xxxx>_kTitleView.frame.size.width-10) {
        _kMarkRect.origin.y += 37;
        _kMarkRect.origin.x = 0;
        _kMarkRect.size.width = 0;
    }
    UIView *kMarkView = [[UIView alloc]initWithFrame:CGRectMake(_kMarkRect.origin.x + _kMarkRect.size.width + 10, _kMarkRect.origin.y, length+20, 27)];
    [_kTitleView addSubview:kMarkView];
    _kMarkRect = kMarkView.frame;
    UILabel *kTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, length+20,YTHAdaptation(27))];
    kTitleLabel.backgroundColor = YTHColor(169, 214, 255);
    kTitleLabel.layer.cornerRadius = 4;
    kTitleLabel.layer.masksToBounds = YES;
    kTitleLabel.textAlignment = NSTextAlignmentCenter;
    kTitleLabel.font = [UIFont systemFontOfSize:12];
    kTitleLabel.textColor = [UIColor whiteColor];
    kTitleLabel.text = title;
    [kMarkView addSubview:kTitleLabel];
    UIButton *kDeleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    kDeleteButton.frame = CGRectMake(CGRectGetMaxX(kMarkView.frame)-YTHAdaptation(10), kMarkView.frame.origin.y-YTHAdaptation(10),YTHAdaptation(20), YTHAdaptation(20));
    kDeleteButton.enabled = YES;
    [kDeleteButton setImage:[UIImage imageNamed:@"deletepic"] forState:UIControlStateNormal];
    [kDeleteButton addTarget:self action:@selector(btnDeleteClick:) forControlEvents:UIControlEventTouchUpInside];
    self.kDeleteButton = kDeleteButton;
    [_kTitleView addSubview:kDeleteButton];
    
    
    
    if (add) {
        
        [_kTitleArrays addObject:title];
        
        NSString *labelUuid = [_kIdMutabDict objectForKey:title];
        
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        
        [dic setObject:labelUuid forKey:@"main_uuid"];
        
        [_labelUuidArr addObject:dic];
        
        
    }
    kDeleteButton.tag = [_kTitleArrays indexOfObject:title] + 10;
    _kTitleView.contentSize = CGSizeMake(YTHScreenWidth, CGRectGetMaxY(kMarkView.frame)+10);
    _kHandsomeView.kYDataArray = _kTitleArrays;
    
}

#pragma mark 删除选中的标签

-(void)btnDeleteClick:(UIButton *)btn{
    
    [_kTitleView removeFromSuperview];
    
    _kTitleView = nil;
    
    NSString *string = _kTitleArrays[btn.tag - 10];
    
    [_kHandsomeView removeBtnSelected:string];
    
    [_kTitleArrays removeObjectAtIndex:btn.tag - 10];
    
    _kMarkRect = CGRectMake(0, 0, 0, 0);
    
    for (NSString *title in _kTitleArrays) {
    
        [self _addTitleBtn:title andAdd:NO];
    
    }
}



- (void)dealloc
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"noticeRefreshCollectList" object:nil];
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
