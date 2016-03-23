//
//  AttentionViewController.m
//  Starucan
//
//  Created by vgool on 16/1/11.
//  Copyright © 2016年 vgool. All rights reserved.
//

#import "AttentionViewController.h"
#import "AttentionCollectionViewCell.h"
#import "ZxlDataServiece.h"
#import "attenModel.h"
@interface AttentionViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (nonatomic,strong ) UICollectionView * myCollection;

@property (nonatomic,strong ) NSMutableArray   *data;
@property (nonatomic, strong) NSMutableArray   *arrBools;
@property (nonatomic, weak  ) UIButton         *finishButton;
@property (nonatomic,strong ) NSDictionary     *recommendDic;


@end

@implementation AttentionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"为您推荐";
    
    [self getRecommendData];//获取推荐信息
    
    [self _initCreat];
    
    [self initFinishButton];
    [self initCreatCollect];
    
    self.data = [NSMutableArray array];
    
//    self.arrBools = [NSMutableArray arrayWithObjects:@"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", nil];
//    self.data = [[NSMutableArray alloc]init];
//    NSDictionary *jasonDic = [ZxlDataServiece requestData:@"movie163_detail"];
//    NSArray *cinemaList = [jasonDic objectForKey:@"seckill"];
   
//    for (NSDictionary *dic in cinemaList)
//    {
//        attenModel *attontionModel = [[attenModel alloc]initContentWithDic:dic];
//        [self.data addObject:attontionModel];
//        [self.myCollection reloadData];
//        
//    }
    
    [self.myCollection reloadData];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedBtnReceivedNotif) name:@"SelectedButtonClicked" object:nil];
}

//获取推荐用户数据
-(void)getRecommendData{
    
    NSString *url = theUrl;
    
    NSString *recommendUrl = [NSString stringWithFormat:@"%@getRecommendUserListAction.action",url];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager POST:recommendUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        _recommendDic = responseObject;
        
        self.data = [responseObject objectForKey:@"recommendUserList"];
        
        YTHLog( @"推荐用户——————————%@",self.data);
        
        for (NSDictionary *dic in self.data) {
           
            _avatar = [dic objectForKey:@"avatar"];
            _name = [dic objectForKey:@"name"];
            _sex = [dic objectForKey:@"sex"];
            _talentCate = [dic objectForKey:@"talentCate"];
            _university = [dic objectForKey:@"university"];
            _uuid = [dic objectForKey:@"uuid"];
   
        }
 
        YTHLog(@"success");
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
        YTHLog(@"failure");
        
    }];
    
}

-(void)_initCreat
{
    
    // 左边的取消按钮
    UIButton *cancelBtn = [[UIButton alloc] init];
    cancelBtn.frame = CGRectMake(0, 0, 30, 30);
    [cancelBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    [cancelBtn addTarget:self action:@selector(clickCode) forControlEvents:UIControlEventTouchUpInside];
    
}

//返回
-(void)clickCode
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


-(void)initFinishButton
{
    UIButton  *finishButton = [[UIButton alloc]initWithFrame:CGRectMake(15, 500, YTHScreenWidth-30, 40)];
    finishButton.layer.borderColor = YTHColor(200, 200, 200).CGColor;
    [finishButton.layer setMasksToBounds:YES];
    [finishButton.layer setCornerRadius:4.5];
    finishButton.layer.borderWidth = 1;
    finishButton.backgroundColor = [UIColor orangeColor];
    [finishButton setTitle:@"完成" forState:UIControlStateNormal];
    
    [finishButton addTarget:self action:@selector(finishButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.finishButton = finishButton;
    
    [self.view addSubview:finishButton];

}
-(void)initCreatCollect
{
    UICollectionViewFlowLayout * flowlayout = [[UICollectionViewFlowLayout alloc]init];
   
    flowlayout.scrollDirection = UICollectionViewScrollDirectionVertical;//竖滚动
    _myCollection = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 64, YTHScreenWidth, 350) collectionViewLayout:flowlayout];
    _myCollection.delegate = self;
    _myCollection.dataSource = self;
    _myCollection.backgroundColor = YTHColor(255, 255, 255);
    
    _myCollection.scrollEnabled = YES;
    [self.view addSubview:_myCollection];
    [_myCollection registerClass:[AttentionCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AttentionCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.attentionModel                = self.data[indexPath.row];

    cell.backgroundColor               = [UIColor lightGrayColor];
    cell.layer.borderColor             = YTHColor(200, 200, 200).CGColor;

    cell.layer.borderWidth             = 1;
    
    [cell.layer setCornerRadius:4.5];
    
    if (self.data.count > 0) {
        
        [self.arrBools replaceObjectAtIndex:indexPath.row withObject:cell.selectButton];
    
    }

    return cell;
    
    //cell.labelName = self.guessData[indexPath.row];
    
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (threeInch || fourInch) {
        return CGSizeMake(145, 200);
    }    else{
        return CGSizeMake((YTHScreenWidth-70)/3, 180);
    }
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(30, 20, 20, 20);
}
- (void)selectedBtnReceivedNotif
{
    for (int i = 0; i < self.data.count; i++) {
                attenModel *model = (attenModel *)self.data[i];
        NSString *str2 = model.name;
               YTHLog(@"%@",str2
              );
    }
}

#pragma mark 完成

-(void)finishButtonAction:(UIButton *)btn
{

    NSUserDefaults *ud      = [NSUserDefaults standardUserDefaults];

    NSString *url           = theUrl;

    NSString *recommendUrl  = [NSString stringWithFormat:@"%@saveUserFollowRelAction.action",url];

    NSMutableDictionary *md = [NSMutableDictionary dictionary];

    md[@"user_uuid"]        = [ud objectForKey:@"user_uuid"];

    md[@"main_uuid"]        = [ud objectForKey:@"user_sex"];
    
    YTHLog( @"推荐用户——————————%@",md);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    
    [manager POST:recommendUrl parameters:md success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *status = [responseObject objectForKey:@"status"];
        
        if ([status isEqualToString:@"success"]) {
            
               YTHLog(@"success");
            
            SUCTabBarViewController *mainVC = [[SUCTabBarViewController alloc]init];
            
            [self presentViewController:mainVC animated:NO completion:nil];
            
        }else{
   
            [MBProgressHUD showError:@"上传失败，请稍后重试"];
            
            [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(hideHub) userInfo:nil repeats:NO];
                    
        }   
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [MBProgressHUD showError:@"上传失败，请稍后重试"];
        
        [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(hideHub) userInfo:nil repeats:NO];

        YTHLog(@"failure");
        
    }];
    
    NSMutableArray *shopCarts = [NSMutableArray array];
    
    for (int i = 0; i < self.data.count ; i++) {
        
        attenModel *model = (attenModel *)self.data[i];
        
        UIButton *selectbtn = self.arrBools[i];
        if (selectbtn.selected) {
            
            NSString *str2 = model.name;
            YTHLog(@"%@",str2);
            
            [shopCarts addObject:model];
        }
    }
}

-(void)hideHub{
    
    [UIView animateWithDuration:1 animations:^{
        [MBProgressHUD hideHUD];
    }];
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
