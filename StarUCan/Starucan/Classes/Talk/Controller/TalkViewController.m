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
#import "SDCycleScrollView.h"

@interface TalkViewController ()<UITableViewDelegate,UITableViewDataSource,SDCycleScrollViewDelegate>

{
    //类别
    UITableView *_kCatTableView;
    UIImageView *lineIV;
    NSArray *_kCatTableViewTitles;
    NSMutableDictionary *_kIdMutabDict;
    UIButton *typeBtn;
    
    UIScrollView *bannerSV;//轮播图
    
    UITableView *mainTV;//主TableView
    
    AppDelegate *myDelegate;
    NSString *labelId;
    
    //话题
    int start;
    int count;
}

@property (strong, nonatomic)UIScrollView    *catScrollView;//类别SV

@property (nonatomic, strong) NSMutableArray *imageURLs;//轮播图图片数组
@property (strong, nonatomic) NSMutableArray *cycleArray;
@property (nonatomic,strong ) NSDictionary   *bannerDict;//轮播图字典


@end

@implementation TalkViewController

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];

    self.tabBarController.tabBar.hidden=NO;

}



- (void)viewDidLoad {
    [super viewDidLoad];
   

    self.title = @"话题";
    
    
    [self getBannerData];//获取轮播图数据


    [self _initNation];
    
    [self initTableView];
    
    [self _initTableView];//类别TV
    
    [self _initDataArray];
  
    
    start = 1;//起始页

    count = 10;//每页多少数据
    
  
    
}

#pragma mark 搜索
-(void)_initNation
{
    //左侧全部按钮
    typeBtn= [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 90, 40)];
    
    [typeBtn setTitle:@"全  部" forState:UIControlStateNormal];
    [typeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    typeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [typeBtn setTitleEdgeInsets:UIEdgeInsetsMake(5, 0, 5, 10)];
    [typeBtn addTarget:self action:@selector(typeChoose) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:typeBtn];
    
    UIImageView *unfoldIV = [[UIImageView alloc]initWithFrame:CGRectMake(75, 18, 10, 4)];
    unfoldIV.image = [UIImage imageNamed:@"unfold"];
    [typeBtn addSubview:unfoldIV];
  
    // 右边的搜索按钮
    UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [searchButton setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    CustomBarItem *rightUtem = [self.navigationItem setItemWithCustomView:searchButton itemType:right];
    [searchButton addTarget:self action:@selector(pushToSearchViewControll) forControlEvents:UIControlEventTouchUpInside];
    [rightUtem setOffset:18];
    
    self.catScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, YTHScreenWidth, 40)];
    
    [self.view addSubview:_catScrollView];
    
    [self.catScrollView setContentSize:CGSizeMake(0, 280)];
    
}
//右上角搜索事件
-(void)pushToSearchViewControll
{
    //点击进入搜索页面
    SearchViewController *searchVC = [[SearchViewController alloc]init];
    
    [self.navigationController pushViewController:searchVC animated:YES];

}

-(void)typeChoose
{
    
    [self.view bringSubviewToFront:self.catScrollView];
    
    if (self.catScrollView.frame.size.height == 0) {
       
        YTHLog(@"点击");
        [lineIV removeFromSuperview];
        
        _kCatTableView.frame = CGRectMake(0, 0, YTHScreenWidth, 0);
        
        //self.catScrollView.frame = CGRectMake(0, self.viewButton.frame.origin.y + self.viewButton.frame.size.height, YTHScreenWidth, 0);
        
        self.catScrollView.frame = CGRectMake(0, 0, YTHScreenWidth, YTHScreenHeight- 64 );
        
        [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseOut animations: ^(void){
            
            _kCatTableView.frame = CGRectMake(0, 0, YTHScreenWidth, 40.0f *7+28);
        
            //类别、大学下面的线
            lineIV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, YTHScreenWidth, 5)];
            
            lineIV.image = [UIImage imageNamed:@"shadow"];
            
            [self.catScrollView addSubview:lineIV];
            
        }completion:^(BOOL finished){
        
        }];
        
        
    }else{
        
        [lineIV removeFromSuperview];
        
        self.catScrollView.frame = CGRectMake(0, 0, YTHScreenWidth, 300-64);
        
        [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseOut animations: ^(void){
            self.catScrollView.frame = CGRectMake(0, 0, YTHScreenWidth, 0);
            
        } completion:^(BOOL finished){}];
        
        //类别、大学下面的线
        lineIV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, YTHScreenWidth, 5)];
      
        lineIV.image = [UIImage imageNamed:@"shadow"];
        
        [self.catScrollView addSubview:lineIV];
        
    }

    
}


//初始化类别
-(void)_initTableView
{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *url1 = Url;
    
    NSString *url =[NSString stringWithFormat:@"%@v1/label/cats",url1];
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

      //  YTHLog(@"标签是--------%@",responseObject);
        
   //     YTHLog(@"error code %ld",(long)[operation.response statusCode]);
        
        if (!_kIdMutabDict) {
       
            _kIdMutabDict = [[NSMutableDictionary alloc]init];
        
        }
        
        [_kIdMutabDict removeAllObjects];
        
        if ([operation.response statusCode]/100==2)
        {
            NSArray *arry = [responseObject objectForKey:@"labelCats"];//类别数组
            
            myDelegate.labelId =[responseObject objectForKey:@"labelCats"];
            
            for (NSDictionary *dic in arry)
            {
                
                [_kIdMutabDict setObject:[dic objectForKey:@"uuid"] forKey:[dic objectForKey:@"name"]];
                
            }
            
            _kCatTableViewTitles = [NSMutableArray arrayWithArray:_kIdMutabDict.allKeys];
        }
#warning 修改
        [_kCatTableView reloadData];
    
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        YTHLog(@"标签错误error code %ld",(long)[operation.response statusCode]);
        
    }];
    _kCatTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, YTHScreenWidth, 300) style:UITableViewStylePlain];
    
    _kCatTableView.delegate = self;
    _kCatTableView.dataSource = self;
  
    _kCatTableView.bounces = NO;
    
    //透明图
    UIButton *kCatScrollViewBgView = [UIButton buttonWithType:UIButtonTypeCustom];
    
    kCatScrollViewBgView.frame = CGRectMake(0, 0, YTHScreenWidth, 300);
    
    [self.catScrollView addSubview:kCatScrollViewBgView];
    
    [self.catScrollView addSubview:_kCatTableView];
    
    [self.catScrollView bringSubviewToFront:_kCatTableView];
    
    [_kCatTableView reloadData];
    
    self.catScrollView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    
    self.catScrollView.frame = CGRectMake(0, 64, YTHScreenWidth, 0);
    
    CGFloat kCatScrollViewCntentSizeHeight;
    
//    if (YTHScreenHeight- 64 + self.viewButton.frame.size.height>_kCatTableView.frame.size.height) {
//        kCatScrollViewCntentSizeHeight = YTHScreenHeight- 64 + self.viewButton.frame.size.height;
//    }else{

    kCatScrollViewCntentSizeHeight = _kCatTableView.frame.size.height;
   
    self.catScrollView.contentSize = CGSizeMake(YTHScreenWidth, kCatScrollViewCntentSizeHeight);
   
    [kCatScrollViewBgView addTarget:self action:@selector(kCatkCatTabelViewFooterBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    
}

-(void)kCatkCatTabelViewFooterBtnClick{
    
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseOut animations: ^(void){
        self.catScrollView.frame = CGRectMake(0, 0, YTHScreenWidth, 0);
      
        
    } completion:^(BOOL finished){
    
    }];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCatTabelViewCellId = @"kCatTabelViewCellId";
  
    UITableViewCell *kCatTabelViewCell = [tableView dequeueReusableCellWithIdentifier:kCatTabelViewCellId];
    
    if (!kCatTabelViewCell) {
        kCatTabelViewCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCatTabelViewCellId];
    }
    
    kCatTabelViewCell.textLabel.text = _kCatTableViewTitles[indexPath.row];
    
    kCatTabelViewCell.textLabel.textColor = GXColor(150, 150, 150);//灰色字体
    
    kCatTabelViewCell.textAlignment = UITextAlignmentCenter;
    
    kCatTabelViewCell.textLabel.font = [UIFont systemFontOfSize:14];
    
    return kCatTabelViewCell;
    
}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section{
    if (tableView ==_kCatTableView) {
        return 15.0;
    }
    return 15.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView ==_kCatTableView) {
        return 40.0f;
    }
    return 44.0f;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView ==_kCatTableView) {
  
        return _kCatTableViewTitles.count;
    }
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [lineIV removeFromSuperview];
  
    [typeBtn removeFromSuperview];
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
  
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [typeBtn setTitle:cell.textLabel.text forState:UIControlStateNormal];
    
  //  [self initTypeBtn:(NSString *)cell.textLabel.text];
    
    labelId = [_kIdMutabDict objectForKey:_kCatTableViewTitles[indexPath.row]];
   // YTHLog(@"标签id%@",labelId);
 
    [self kCatkCatTabelViewFooterBtnClick];
    
    [self _initDataArray];
    // [self catTableViewDidSelect:indexPath.row];
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (tableView == _kCatTableView) {
        
        UIButton *kCatTabelViewFooterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        CGFloat kTopAndBottom = (15 - 5)/2.0f;//上下边距5.0f
        
        CGFloat kLeftAndRight = (YTHScreenWidth - 16)/2.0f;//左右边距
        
        kCatTabelViewFooterBtn.imageEdgeInsets = UIEdgeInsetsMake(kTopAndBottom+5.0f, kLeftAndRight, kTopAndBottom, kLeftAndRight);
        
        [kCatTabelViewFooterBtn setImage:[UIImage imageNamed:@"slide"] forState:UIControlStateNormal];
        
        [kCatTabelViewFooterBtn setImage:[UIImage imageNamed:@"slide"] forState:UIControlStateSelected];
        
        kCatTabelViewFooterBtn.backgroundColor = [UIColor whiteColor];
        
        kCatTabelViewFooterBtn.frame = CGRectMake(0, 0, YTHScreenWidth, 10.0f);
        //线
        UIView *kGXian = [[UIView alloc]initWithFrame:CGRectMake(0, 0, YTHScreenWidth, 0.4)];
      
        kGXian.backgroundColor = [UIColor colorWithRed:154.0f/255.0f green:154.0f/255.0f blue:154.0f/255.0f alpha:0.7f];
        //kGXian.backgroundColor = [UIColor redColor];
       
        [kCatTabelViewFooterBtn addSubview:kGXian];
        
        [kCatTabelViewFooterBtn addTarget:self action:@selector(kCatkCatTabelViewFooterBtnClick) forControlEvents:UIControlEventTouchUpInside];
        
        return kCatTabelViewFooterBtn;
    }
    return nil;
}
//获取话题内容
-(void)_initDataArray{
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSMutableDictionary *md = [NSMutableDictionary dictionary];
        md[@"start"] = [NSString stringWithFormat:@"%d",start];
        md[@"count"] =[NSString stringWithFormat:@"%d",count];
        NSString *url = Url;
        NSString *urlString = [NSString stringWithFormat:@"%@v1/topic",url];
#warning 话题接口 无数据
        [manager GET:urlString parameters:md success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *jasonDic = responseObject;
            YTHLog( @"------获取话题接口链接：%@",urlString);
            
            YTHLog(@"瀑布流error code %ld",(long)[operation.response statusCode]);
            if ([operation.response statusCode]/100==2) {
                YTHLog( @"------获取话题：%@",jasonDic);

                
                
                }
            
            
//            [_collectionView reloadData];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
#warning 初始化两次，检测内存泄露时出现问题
            NSDictionary *topicDic = [[NSDictionary alloc]init];
            
            topicDic = operation.responseObject;

            [MBProgressHUD showError:[topicDic objectForKey:@"info"]];
            
        }];
        
 
    
}


-(void)initTableView{
    
    mainTV = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, YTHScreenWidth, YTHScreenHeight-64)];

//    mainTV.delegate = self;
//    mainTV.dataSource = self;
    
//高度改为内容的高度+YTHAdaptation(175) （banner）
    
    [mainTV setContentSize:CGSizeMake(0, 1000)];
    
    [self.view addSubview:mainTV];
    
//    [self _initBanner];
    
}


#pragma mark 获取话题页轮播图数据
-(void)getBannerData{
    
    self.imageURLs = [NSMutableArray array];

    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    md[@"type"] =@"3";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *url1 = theUrl;
    
    NSString *url =[NSString stringWithFormat:@"%@getAdvertListAction.action",url1];
    
    [manager POST:url parameters:md success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YTHLog(@"话题轮播图%@",responseObject);
        
        if ([[responseObject objectForKey:@"status"] isEqualToString:@"success"])
        {
            [self.imageURLs removeAllObjects];
            
            NSArray *arr = [responseObject objectForKey:@"adList"];
            for (NSDictionary *dic in arr) {
                
                NSString *ad_pic = [dic objectForKey:@"ad_pic"];
                
//                NSString *ad_uuid = [dic objectForKey:@"ad_uuid"];

                [self.imageURLs addObject:ad_pic];
                
            }
    
            YTHLog(@"0话题页轮播图数组：%@",self.imageURLs);
            
             [self _initBanner];
            
            YTHLog(@"success");
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        YTHLog(@"标签错误error code %ld",(long)[operation.response statusCode]);
        
    }];
    
   
    
}

//轮播图
-(void)_initBanner
{
    
//    YTHLog(@"1话题页轮播图数组：%@",self.imageURLs);

    bannerSV= [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, YTHScreenWidth, 64+YTHAdaptation(175))];//175
    
    bannerSV.backgroundColor = [UIColor clearColor];

    [self.view addSubview:bannerSV];
    
    mainTV.tableHeaderView = bannerSV;
    
#pragma mark  轮播图 图片数组  ------  替换成self.imageURLs

    CGFloat w = self.view.bounds.size.width;

    // 网络加载 --- 创建自定义图片的pageControlDot的图片轮播器
    SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, w, YTHAdaptation(175)) delegate:self placeholderImage:[UIImage imageNamed:@""]];
    cycleScrollView.imageURLStringsGroup = self.imageURLs;
    
    cycleScrollView.currentPageDotImage = [UIImage imageNamed:@"checkbox_selected"];
    
    cycleScrollView.pageDotImage = [UIImage imageNamed:@"checkbox_unselected"];
    
    cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleAnimated;

    cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
    
    
    YTHLog(@"2话题页轮播图数组：%@",self.imageURLs);

    
    [bannerSV addSubview:cycleScrollView];
    
}


#pragma mark - SDCycleScrollViewDelegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    YTHLog(@"---点击了第%ld张图片", (long)index);
    
    [self.navigationController pushViewController:[NSClassFromString(@"DemoVCWithXib") new] animated:YES];
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
