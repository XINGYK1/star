//
//  UnListViewController.m
//  Starucan
//
//  Created by vgool on 16/1/4.
//  Copyright © 2016年 vgool. All rights reserved.
//

#import "UnListViewController.h"
#import "UINavigationItem+CustomItem.h"
#import "AppDelegate.h"
#import "CCLocationManager.h"
#import "GXHttpTool.h"
#import "MBProgressHUD+NJ.h"

@interface UnListViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchBarDelegate>
{
    AppDelegate *myDelegate;
    CLLocationCoordinate2D locationCorrrdinate;

}
@property (weak, nonatomic) UITableView *universityTableView;

@property (strong, nonatomic) UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray * dataSource;
@property (weak, nonatomic) UITableView *resultTableView;
@end

@implementation UnListViewController

- (UISearchBar *)searchBar
{
    if (!_searchBar) {
        // 搜索框
        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, YTHScreenWidth-80, 40)];
        searchBar.placeholder = @"搜索学校";
        searchBar.delegate = self;
        searchBar.tintColor = YTHColor(100, 100, 100);
        [searchBar setImage:[UIImage imageNamed:@"icon_search"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
        searchBar.backgroundImage = [UIImage imageNamed:@"ui_searchbar_back"];
        _searchBar = searchBar;
    }
    return _searchBar;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    if (!myDelegate) {
        myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    self.dataSource = [[NSMutableArray alloc] init];
    locationCorrrdinate = (CLLocationCoordinate2D){0,0};
    [self _initNation];
//
    [self _initCreat];
   

}
#pragma mark - 布局
-(void)_initCreat
{
    // 添加一个tableview
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, YTHScreenWidth, YTHScreenHeight) style:UITableViewStylePlain];
    
    tableView.backgroundColor = YTHColor(240, 240, 240);
    
    self.universityTableView = tableView;
    
    [self.view addSubview:self.universityTableView];
    
    self.universityTableView.delegate = self;
    self.universityTableView.dataSource = self;
    self.universityTableView.sectionIndexColor = YTHColor(255, 73, 120);
    self.universityTableView.sectionIndexBackgroundColor = [UIColor clearColor];

}
- (void) locationBack:(CLLocationCoordinate2D ) loc{
    locationCorrrdinate = loc;
    NSLog(@"纬度--%f",locationCorrrdinate.latitude);
    NSLog(@"经度%f",locationCorrrdinate.longitude);
    
    //请求数据
    [self requestData];
}


-(void)requestData
{
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    NSString *latitude = [NSString stringWithFormat:@"%f",locationCorrrdinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f",locationCorrrdinate.longitude];
    
    md[@"lat"] =latitude;
    md[@"lng"] =longitude;
    md[@"name"]=_searchBar.text;
    
    [MBProgressHUD showMessage:@"加载中"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *url = Url;
    NSString *urlString = [NSString stringWithFormat:@"%@v1/base/universities",url];
    
    NSLog(@"地址为：%@",urlString);
    
//    [manager GET:urlString parameters:md success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        NSLog(@"学校%@",responseObject);
//        
//        NSLog(@"error code %ld",(long)[operation.response statusCode]);
//        
//        if ([operation.response statusCode]/100==2) {
//            
//            [self saveDictionary:[responseObject objectForKey:@"universities"] forKey:@"universitys" toFile:@"universitys"];
//            
//                        [self showUniversitys:[responseObject objectForKey:@"universities"]];
//            
//            
//        }
//        
//        [MBProgressHUD hideHUD];
//        [MBProgressHUD showSuccess:@"加载完成"];
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//         NSLog(@"error code %ld",(long)[operation.response statusCode]);
//        
//    }];
    
    
    
    
    
    [MBProgressHUD showMessage:@"加载中"];
    [GXHttpTool POST:@"http://platform.vgool.cn/api/university/universityList" parameters:md success:^(id responseObject) {
        NSLog(@"%@",responseObject);
        NSDictionary *jsonDict = responseObject;
        if (jsonDict == nil) {
          [MBProgressHUD showError:@"服务器连接失败"];
            return;
        }
        
        if([[jsonDict objectForKey:@"code"] intValue] == 0){
             NSMutableArray *list = [jsonDict objectForKey:@"nearUniversityList"];
            
            //保存
            [self saveDictionary:[jsonDict objectForKey:@"list"] forKey:@"universitys" toFile:@"universitys"];
            
            [self showUniversitys:[jsonDict objectForKey:@"list"]];
            
            
        };
        [MBProgressHUD hideHUD];
        [MBProgressHUD showSuccess:@"加载成功"];
    } failure:^(NSError *error) {
        
        NSLog(@"123");
        
    }];
    
}

-(void) showUniversitys:(NSMutableArray *)list{
    NSMutableArray *zimulist = [[NSMutableArray alloc] initWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"G",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil];
    
    for (NSString *leter in zimulist) {
        
        NSMutableArray *dataList = [[NSMutableArray alloc] init];
        
        for (NSMutableDictionary *unitDic in list) {
            
            if ([unitDic objectForKey:@"pinyin"] != nil && ![[unitDic objectForKey:@"pinyin"] isEqualToString:@""]) {
                
                NSString *pinyin = [unitDic objectForKey:@"pinyin"];
                
                if ([[pinyin substringWithRange:NSMakeRange(0,1)] isEqualToString:[leter lowercaseString]]) {
                    
                    [dataList addObject:unitDic];
                    
                }
            }
        }
        if ([dataList count] > 0) {
            NSMutableDictionary *leterDic = [[NSMutableDictionary alloc] init];
           
            

            [leterDic setObject:leter forKey:@"indexTitle"];
            [leterDic setObject:dataList forKey:@"data"];
            [self.dataSource addObject:leterDic];
            
        }
       
    }
    
    NSMutableArray *ortherlist = [[NSMutableArray alloc] init];
    
    for (NSMutableDictionary *unitDic in list) {
        if ([unitDic objectForKey:@"pinyin"] == nil || [[unitDic objectForKey:@"pinyin"] isEqualToString:@""]) {
            [ortherlist addObject:unitDic];
        }
    }
    if (ortherlist.count > 0) {
        NSMutableDictionary *leterDic = [[NSMutableDictionary alloc] init];
        [leterDic setObject:@"#" forKey:@"indexTitle"];
        [leterDic setObject:ortherlist forKey:@"data"];
        [self.dataSource addObject:leterDic];
    }
    [self.universityTableView reloadData];
}
#pragma mark - 导航栏上的东西
-(void)_initNation
{
    // 搜索框
    [self.navigationItem setItemWithCustomView:self.searchBar itemType:left];
    
    // 取消按钮
    UIButton *cancelBtn = [[UIButton alloc] init];
    cancelBtn.frame = CGRectMake(0, 0, 40, 40);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    [cancelBtn addTarget:self action:@selector(clickBackToMeet) forControlEvents:UIControlEventTouchUpInside];

}

- (void)clickBackToMeet
{
    //返回首页的遇见页面
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark---tableView--
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
   return self.dataSource[section][@"indexTitle"];

}

// 显示共有几个分组
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView==self.universityTableView) {
        
        return self.dataSource.count;
    }else{
        return 1;
    }
    
    
}
// 显示第几个分组中有多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
 
    if (tableView ==self.universityTableView) {
    return [self.dataSource[section][@"data"] count];
    }
    return 8;
   

}
//-- 重点方法
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray * indexTitles = [NSMutableArray array];
    for (NSDictionary * sectionDictionary in self.dataSource) {
        [indexTitles addObject:sectionDictionary[@"indexTitle"]];
    }
    return indexTitles;

}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView==self.universityTableView) {
        return 20;
    }
    else {
        return 40;
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==self.universityTableView) {
        return 44;
    }else{
        return 40;
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    if (tableView==self.universityTableView) {
        static NSString *ID = @"uniser";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.textLabel.text = self.dataSource[indexPath.section][@"data"][indexPath.row][@"name"];
        cell.textLabel.tag = [self.dataSource[indexPath.section][@"data"][indexPath.row][@"uuid"] intValue];
        
        
        return cell;
    }else
    {
        static NSString *cellId = @"mycell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
       
        return cell;

    }
    
    
        

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    myDelegate.university_name = cell.textLabel.text;
    int tagid = cell.textLabel.tag;
    myDelegate.universityId = [NSString stringWithFormat:@"%d",tagid];
    NSLog(@"学校id:%@",myDelegate.universityId);
    [self back];

    
}
-(void)back
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"noticeRefreshCollectList" object:nil userInfo:nil];
    [self.navigationController popViewControllerAnimated:YES];

}
#pragma mark -searchBarDelegte
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length > 0) {
        if (![searchBar.text isEqualToString:@""]) {
            
            [self.dataSource removeAllObjects];
            
            NSMutableArray *list = [self getDictionaryWithKey:@"universitys" fromFile:@"universitys"];
            
            NSMutableArray *slist = [[NSMutableArray alloc] init];
            
            for (NSMutableDictionary *dic in list) {
                
                if ([[dic objectForKey:@"name"] rangeOfString:searchBar.text].location != NSNotFound || [[dic objectForKey:@"pinyin"] rangeOfString:searchBar.text].location != NSNotFound ) {
                    
                    [slist addObject:dic];
                }
            }
            
            [self showUniversitys:slist];
            
        }
    }
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
     if (![searchBar.text isEqualToString:@""]) {
         [self.dataSource removeAllObjects];
         NSMutableArray *list = [self getDictionaryWithKey:@"universitys" fromFile:@"universitys"];
             NSMutableArray *slist = [[NSMutableArray alloc] init];
             for (NSMutableDictionary *dic in list) {
                 if ([[dic objectForKey:@"name"] rangeOfString:searchBar.text].location != NSNotFound || [[dic objectForKey:@"pinyin"] rangeOfString:searchBar.text].location != NSNotFound ) {
                     [slist addObject:dic];
                 }
             }
             [self showUniversitys:slist];
         
         
         
     }

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
