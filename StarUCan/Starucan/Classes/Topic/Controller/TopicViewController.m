//
//  TopicViewController.m
//  Starucan
//
//  Created by moodpo on 16/1/20.
//  Copyright © 2016年 vgool. All rights reserved.
//

#import "TopicViewController.h"
#import "WordViewController.h"
#import "AddLabelViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "MBProgressHUD+NJ.h"
#import "AppDelegate.h"
#import "NSData+AES256.h"

@interface TopicViewController()<UITextViewDelegate, AddLabelDelegate> {
    AppDelegate *myDelegate;
    UITextView *editView;//话题内容
    
    NSMutableArray *_kTitleArrays;
    NSMutableArray *kTitleArrays;

    UITextField *topicTF;
    
    UIScrollView *_kTitleView;//标签View
    UILabel *labelText;//秀逼格文字内容
    
    
    NSMutableDictionary *_kMutableTitleIdDict;

    
    CGRect _kMarkRect;
    int swit;  //是否匿名
    
}

@property(nonatomic,strong)UIView *viewBgDesc;//文字详情view
@property(nonatomic,strong)UIView *viewLabel;//添加标签view
@property(nonatomic,strong)UIView *viewLimit;// 匿名发布
@property(nonatomic,strong)UILabel *label;
@property(nonatomic,strong)UITextField *textFiled;
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation TopicViewController
-(void)loadView{
    UIScrollView *sv = [[UIScrollView alloc] init];
    sv.frame = CGRectMake(0, 0, YTHScreenWidth, YTHScreenHeight);
    sv.contentSize = CGSizeMake(YTHScreenWidth, YTHScreenHeight+216);
    sv.backgroundColor = YTHColor(235, 235, 241);
    sv.scrollEnabled = YES;
    self.scrollView = sv;
    self.view = sv;
}
-(void)viewDidLoad {
    [super viewDidLoad];
    swit=0;
    if (!myDelegate) {
        myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
    self.title = @"发起话题";
    //self.view.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0];
    self.view.backgroundColor = YTHBaseVCBackgroudColor;
    [self initNavigation];
    [self initTitleField];
    [self initEditField];
    [self initLabelField];
    [self initLimitField];
    
}

// 初始化导航栏上的视图
-(void)initNavigation {
    
    // 左边的取消按钮
    UIButton *cancelBtn = [[UIButton alloc] init];
    cancelBtn.frame = CGRectMake(0, 0, 30, 30);
    [cancelBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    [cancelBtn addTarget:self action:@selector(clickBack) forControlEvents:UIControlEventTouchUpInside];
    
    // 发布按钮
    UIButton *sendButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [sendButton setTitle:@"发布" forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(clickSend) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *sendItem = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
    self.navigationItem.rightBarButtonItem = sendItem;
    
}

// 初始化话题主题区域
-(void)initTitleField {
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, YTHScreenWidth, 44)];
    titleLabel.text = @"  主题";
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:titleLabel];
    topicTF = [[UITextField alloc]initWithFrame:CGRectMake(60, 0, YTHScreenWidth-60, 44)];
    topicTF.placeholder = @"(5-15个字)";
    self.textFiled = topicTF;
    [self.view addSubview:topicTF];
    
}

// 初始化文字编辑区域
-(void)initEditField {
    
    editView = [[UITextView alloc] initWithFrame:CGRectMake(0, 45, YTHScreenWidth ,646/2)];
    editView.tag = 102;
   
    editView.delegate = self;
   
    labelText = [[UILabel alloc]initWithFrame:CGRectMake(10, 5,YTHScreenWidth-23, 40)];
    labelText.text = @"多给小伙伴们谈谈这个话题吧，悄悄告诉你~话题描述越详细越容易上榜哦！";
  
    labelText.font = [UIFont systemFontOfSize:14];
    labelText.numberOfLines = 0;
    labelText.textColor =[UIColor grayColor];
    labelText.enabled = NO;//lable必须设置为不可用
    labelText.backgroundColor = [UIColor clearColor];
    [editView addSubview:labelText];
    editView.textColor = [UIColor grayColor];
    [self.view addSubview:editView];
    
}

// 初始化标签区域
-(void)initLabelField {
    UIView *viewLabel = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(editView.frame)+10, YTHScreenWidth, 44)];
    viewLabel.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:viewLabel];
    self.viewLabel = viewLabel;
    
    UIImageView *imagV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 14, 16, 16)];
    imagV.image = [UIImage imageNamed:@"icon_lable"];
    [viewLabel addSubview:imagV];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imagV.frame)+10, 14, 100, 16)];
    label.text =@"话题标签";
    label.font = [UIFont systemFontOfSize:14];
    [viewLabel addSubview:label];
    self.label = label;
    
    
    UIButton *addLabelBtn = [[UIButton alloc]initWithFrame:CGRectMake(YTHScreenWidth-10-16, 14, 16, 16)];
    [addLabelBtn setImage:[UIImage imageNamed:@"icon_addlable"] forState:UIControlStateNormal];
    [addLabelBtn addTarget:self action:@selector(addLabelButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [viewLabel addSubview:addLabelBtn];

}

// 初始化是否匿名发布 viewLimit
-(void)initLimitField {
    UIView *limitview = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.viewLabel.frame)+1, YTHScreenWidth, 44)];
    limitview.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:limitview];
    self.viewLimit = limitview;
    
    UIImageView *imagV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 14, 16, 16)];
    imagV.image = [UIImage imageNamed:@"icon_anonymity"];
    [limitview addSubview:imagV];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imagV.frame)+10, 14, 100, 16)];
    label.text =@"匿名发起";
    label.font = [UIFont systemFontOfSize:14];
    [limitview addSubview:label];
     UISwitch *switchV = [[UISwitch alloc]initWithFrame:CGRectMake(YTHScreenWidth-70,7, 16, 16)];
     [switchV addTarget:self action:@selector(swtAction:) forControlEvents:UIControlEventValueChanged];
    [limitview addSubview:switchV];
    
}
#pragma mark - switch 开关事件设置
- (void)swtAction:(UISwitch *)sender {
    
    BOOL remainedSWT = sender.isOn;
    if (remainedSWT) {//选中
        swit = 1;
        YTHLog(@"选中%d",swit);
    }else{
        swit = 0;
        YTHLog(@"未选中%d",swit);
    }
}
// 点击返回
-(void)clickBack {
   [self.navigationController popViewControllerAnimated:YES];
    //[self dismissViewControllerAnimated:YES completion:nil];

}

#pragma mark 发布话题
-(void)clickSend {
    
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSString *user_uuid = [ud objectForKey:@"user_uuid"];
    
    NSString *openId = [ud objectForKey:@"openId"];
    
    NSString *user_udid = @"D633CBA4-91C2-4FB6-A17A-92917B301EA6";
    
    NSString *content = editView.text;
  
    NSString *is_anonymous = [NSString stringWithFormat:@"%d",swit];
    
    NSMutableDictionary *mdd = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *mddd = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    md[@"user_uuid"] = user_uuid;

    md[@"user_udid"] = user_udid;
    
    md[@"openId"] = openId;
    
    md[@"topic_title"] = topicTF.text;
    
    md[@"content"] = content;

    md[@"is_anonymous"] = is_anonymous;
    
#warning 存放标签数组
    md[@"parameterList"] = @[@{@"title":@"哈哈"},@{@"title":@"呵呵"}];

    mdd[@"model"] = md;
    
    NSString *url = theUrl;
    
    NSString *showUrl = [NSString stringWithFormat:@"%@saveTopicAction.action",url];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mdd options:0 error:nil];
    
    NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    mddd[@"jsonStr"] =jsonString;
    
    YTHLog(@"发布话题————————%@",mddd);

    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    [manager POST:showUrl parameters:mddd success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        YTHLog(@"话题发布成功%@",[responseObject objectForKey:@"status"]);

  
        if ([[responseObject objectForKey:@"status"] isEqualToString:@"success"])
        {           //话题发布成功
            [MBProgressHUD showSuccess:@"话题发布成功"];
            
            YTHLog(@"话题发布成功%@",responseObject);
            
        }else{
            
            [MBProgressHUD showError:[responseObject objectForKey:@"status"]];
            
        }
 
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       
        YTHLog(@"新建话题错误error code %ld",(long)[operation.response statusCode]);
        
    }];
    
}



#pragma mark - 点击添加标签
-(void)addLabelButton:(UIButton *)btn
{
    AddLabelViewController *addVC = [[AddLabelViewController alloc]init];
    addVC.delegate = self;
    addVC.type = @"1";
    [self.navigationController pushViewController:addVC animated:YES];
    
}

#pragma mark -添加标签实现代理方法
-(void)AddLabelView:(AddLabelViewController *)zheView didClickTag:(NSString *)idKey didClickTitle:(NSString *)title
{
    if (!_kTitleArrays) {
        _kTitleArrays = [[NSMutableArray alloc]init];
    }
    if (!_kMutableTitleIdDict) {
        _kMutableTitleIdDict = [[NSMutableDictionary alloc]init];
    }
    if (_kTitleArrays.count>4) {
        [MBProgressHUD showError:@"标签最多选5个"];
        return ;
    }
    if([_kTitleArrays containsObject:title]){
        [_kTitleView removeFromSuperview];
        _kTitleView = nil;
        [_kTitleArrays removeObject:title];
        _kMarkRect = CGRectMake(0, 0, 0, 0);
        
        [_kMutableTitleIdDict removeObjectForKey:title];
        for (NSString *title in _kTitleArrays) {
            
            [self _addTitleBtn:title andAdd:NO];
        }
    }else{
        [_kMutableTitleIdDict setObject:idKey forKey:title];
        [self _addTitleBtn:title andAdd:YES];
    }

}

-(void)_addTitleBtn:(NSString *)title andAdd:(BOOL)add{
    if (!_kTitleView) {
        _kTitleView = [[UIScrollView alloc]initWithFrame:CGRectMake(30, 0, YTHScreenWidth-54, 44)];
        _kTitleView.backgroundColor = [UIColor whiteColor];
        //_kTitleView.backgroundColor = YTHBaseVCBackgroudColor;
        [self.viewLabel addSubview:_kTitleView];
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
    UILabel *kTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, length+20, 27)];
    kTitleLabel.backgroundColor = YTHColor(169, 214, 255);
    kTitleLabel.layer.cornerRadius = 5;
    kTitleLabel.layer.masksToBounds = YES;
    kTitleLabel.textAlignment = NSTextAlignmentCenter;
    kTitleLabel.font = [UIFont systemFontOfSize:12];
    kTitleLabel.textColor = [UIColor whiteColor];
    kTitleLabel.text = title;
    [kMarkView addSubview:kTitleLabel];
    UIButton *kDeleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    kDeleteButton.frame = CGRectMake(CGRectGetMaxX(kMarkView.frame)-10, kMarkView.frame.origin.y-10, 20, 20);
    //    [kDeleteButton setTitle:@"X" forState:UIControlStateNormal];
    [kDeleteButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    //    [kDeleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //    [kDeleteButton addTarget:self action:@selector(btnDeleteClick:)];
    [kDeleteButton addTarget:self action:@selector(btnDeleteClick:) forControlEvents:UIControlEventTouchUpInside];
    [_kTitleView addSubview:kDeleteButton];
    if (add) {
        
        [_kTitleArrays addObject:title];
        
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        
        [dic setObject:title forKey:@"title"];
        
        [kTitleArrays addObject:dic];

        
    }
    kDeleteButton.tag = [_kTitleArrays indexOfObject:title] + 999;
    _kTitleView.contentSize = CGSizeMake(YTHScreenWidth, CGRectGetMaxY(kMarkView.frame)+10);
    // self.viewLabel.height =kMarkView.height;
    float h;
    YTHLog(@"frame标签%f",kMarkView.frame.origin.y);
    if (kMarkView.frame.origin.y>10) {
        h = kMarkView.frame.origin.y + 44;
        self.viewLabel.frame = CGRectMake(0, CGRectGetMaxY(self.viewBgDesc.frame)+10, YTHScreenWidth, h);
        _kTitleView.frame = CGRectMake(30, 0, YTHScreenWidth-54, h);
        //   h+= _kTitleView.frame.size.height+12;
        self.viewLimit.frame = CGRectMake(0, CGRectGetMaxY(self.viewLabel.frame)+1, YTHScreenWidth, 44);
    }
    
}
-(void)btnDeleteClick:(UIButton *)btn{
    [_kTitleView removeFromSuperview];
    _kTitleView = nil;
    //    NSString *string = _kTitleArrays[btn.tag - 999];
    //  [_kHandsomeView removeBtnSelected:string];
    [_kTitleArrays removeObjectAtIndex:btn.tag - 999];
    _kMarkRect = CGRectMake(0, 0, 0, 0);
    for (NSString *title in _kTitleArrays) {
        
        [self _addTitleBtn:title andAdd:NO];
    
    }
}

-(void)textViewDidChange:(UITextView *)textView
{
    // self.examineText =  textView.text;
    if (textView.text.length == 0) {
        labelText.text = @" 多给小伙伴们谈谈这个话题吧，悄悄告诉你~话题描述越详细越容易上榜哦！";
    }
    else{
        labelText.text = @"";
    }
    
}

@end
