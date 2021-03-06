//
//  ShowDetailViewController.m
//  Starucan
//
//  Created by vgool on 16/1/22.
//  Copyright © 2016年 vgool. All rights reserved.
//

#import "ShowDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "kSuggessPhotoCollectionViewCell.h"
#import "ShowDetailModel.h"
#import "AFHTTPRequestOperationManager.h"
#import "MBProgressHUD+NJ.h"
#import "NSData+AES256.h"
#import "AppDelegate.h"
#import "ShowCommentModel.h"
#import "ShowTableViewCell.h"
#import "CommentViewController.h"
#import "AnswerViewController.h"
#import "ShowDetailModel.h"
#import "MyFanTableViewCell.h"
#import "VIPhotoView.h"
#import "CommentLayFrame.h"
#import "PraiseTableViewCell.h"
@interface ShowDetailViewController ()<UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSString *sex;
    CGFloat _kPhotoCollectionViewJJ;
    UICollectionView *_kPhotoCollectionView;
    UICollectionViewFlowLayout *_kPhotoCollectionViewFlowLayout;
    
    
    AppDelegate *myDelegate;
    VIPhotoView *_kVIPhotoView;
    
    
    //标签
    UIView *kMarkView;
    UIScrollView *_kTitleView;
    UILabel *kTitleLabel;
    NSMutableArray *_kTitleArrays;
    CGRect _kMarkRect;
    UIImageView *MarkIV;

    
    
    UIImageView *arrowImg;
    UIImageView *praiseImg;
    
    UIView *commentView;//底部View
    UIButton *praiseButton;
    UIButton *moreButton;
    UIButton *commentButton;
    
    UIView *moreView;//更多操作View
    UIButton *collectButton;//收藏
    UIButton *shareButton;//分享
    
    
    PraiseTableViewCell *praiseCell;
    BOOL isPraise;
    
    
}
//
@property (nonatomic,strong ) UIImageView    *headImgV;//头像
@property (nonatomic,strong ) UIView         *headView;//头视图
@property (nonatomic,strong ) NSString       *urlString;
@property (nonatomic,strong ) UILabel        *nameLabel;//姓名
@property (nonatomic,strong ) UIImageView    *sexImV;//性别
@property (nonatomic,strong ) UILabel        *uniserLabel;//学校
@property (nonatomic,strong ) UIButton       *addAttionBtn;//加关注
@property (nonatomic,strong ) UIView         *viewBgDesc;//文字详情view
@property (nonatomic,strong ) UILabel        *labelDesc;

//大图
@property (nonatomic,strong ) UIImageView    *bigImage;
@property (strong, nonatomic) NSMutableArray *photoNameList;
@property (nonatomic,strong ) UITableView    *tableView;
@property (nonatomic,strong ) NSDictionary   *jason;
@property (nonatomic,strong ) NSDictionary   *commentJason;
@property (nonatomic,strong ) NSMutableArray *data;
@property (nonatomic,strong ) NSDictionary   *attenJason;
@property (nonatomic,strong ) NSDictionary   *praiseJason;
@property (nonatomic,strong ) NSDictionary   *praiseListJason;
@property (nonatomic,strong ) NSDictionary   *showdic;
@property (nonatomic,strong ) NSMutableArray *sourceArray;
@property (nonatomic, assign) BOOL           flag;
@property (nonatomic,strong ) NSURL          *bigString;

@end

@implementation ShowDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
    self.title= @"详情";
    YTHLog(@"uuid详情%@",self.uuid);
    
    if (!myDelegate) {
    
        myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    }
    
    _kTitleArrays = [[NSMutableArray alloc]init];
    
    self.photoNameList = [[NSMutableArray alloc]init];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(requestDatatable:) name:@"requestTable" object:nil];
    
    self.flag = YES;
  
    //请求数据
    [self requestData];
    //
    [self requestTable];
    
    [self _initTableView];
    
    [self _initHeadView];
    
    [self _initLabel];
    
    [self _initViewBgDesc];
    
    [self _initComment];
    
    
    // 左边的取消按钮
    UIButton *cancelBtn = [[UIButton alloc] init];
    
    cancelBtn.frame = CGRectMake(0, 0, 30, 30);
    
    [cancelBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    
    [cancelBtn addTarget:self action:@selector(clickCode) forControlEvents:UIControlEventTouchUpInside];
    
    
    
}

-(void)clickCode{
    
    [self dismissViewControllerAnimated:NO completion:nil];
    
}
- (void)requestDatatable:(NSNotification*)notification
{
    [self requestTable];
}

-(void)requestTable
{
    NSString *url1 = @"v1/comment";
    NSString *text = [NSData AES256EncryptWithPlainText:url1 passtext:myDelegate.accessToken];
    YTHLog(@"登录密码=%@",myDelegate.accessToken);
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setAuthorizationHeaderFieldWithToken:text];
    [manager.requestSerializer setValue:myDelegate.account forHTTPHeaderField:@"account"];
    
    NSString *uS = Url;
    NSString *urlStr = [NSString stringWithFormat:@"%@v1/comment/%@/comments",uS,_pinglun];
    YTHLog(@"拼接之后%@",urlStr);
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//评论内容
        YTHLog(@"评论%@",responseObject);
        self.commentJason =responseObject;
//评论返回状态码
        YTHLog(@"评论 %ld",(long)[operation.response statusCode]);
        if ([operation.response statusCode]/100==2)
        {
            self.data = [[NSMutableArray alloc]init];
            NSArray *commontArry = [responseObject objectForKey:@"commonts"];
            for (NSDictionary *dict in commontArry) {
                
                ShowCommentModel *commontModel = [[ShowCommentModel alloc]initContentWithDic:dict];
                
                CommentLayFrame *myFrame = [[CommentLayFrame alloc]init];
                myFrame.showCommentModel = commontModel;
                [self.data addObject:myFrame];
                
                
            }
        }
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YTHLog(@"评论错误 %ld",(long)[operation.response statusCode]);
        self.commentJason = operation.responseObject;
        YTHLog(@"登录%@", self.commentJason);
        [MBProgressHUD showError:[self.commentJason objectForKey:@"info"]];
        YTHLog(@"详情获取错误------%@",[self.commentJason objectForKey:@"info"]);
        
    }];
    
    
}

-(void)requestData
{
    
    NSString *url1 = @"v1/show";
    NSString *text = [NSData AES256EncryptWithPlainText:url1 passtext:myDelegate.accessToken];
    YTHLog(@"登录密码=%@",myDelegate.accessToken);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager.requestSerializer setAuthorizationHeaderFieldWithToken:text];
    
    [manager.requestSerializer setValue:myDelegate.account forHTTPHeaderField:@"account"];
    NSString *uS = Url;
    NSString *urlStr = [NSString stringWithFormat:@"%@v1/show/%@",uS,self.uuid];
    YTHLog(@"详情拼接之后%@",urlStr);
    
    
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YTHLog(@"详情%@",responseObject);
        self.jason = responseObject;
        YTHLog(@"详情 %ld",(long)[operation.response statusCode]);
        if ([operation.response statusCode]/100==2)
        {
            
            NSDictionary *showdic = [responseObject objectForKey:@"show"];
            self.showdic = showdic;
            //内容
            self.userUuid = [showdic objectForKey:@"userUuid"];
            //评论
            _pinglun = [showdic objectForKey:@"uuid"];
            _attenuuid = [[showdic objectForKey:@"user"]objectForKey:@"uuid"];
            
            [self _initTableView];
            [self _initHeadView];
            [self _initComment];
            [self _initViewBgDesc];
            [self requestTable];
            
            //描述内容
            self.labelDesc.text = [showdic objectForKey:@"content"];
            self.labelDesc.backgroundColor =[UIColor clearColor];
            
            
            CGSize size;
            NSDictionary *dicrary = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:14],NSFontAttributeName,nil];
            
            size =  [self.labelDesc.text boundingRectWithSize:CGSizeMake(self.labelDesc.frame.size.width, 1000) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:dicrary context:nil].size;
            
            float f;
            f=size.height;
            
            self.labelDesc.numberOfLines = 0;
            self.labelDesc.textColor = YTHColor(140, 140, 140);
            self.labelDesc.font = [UIFont systemFontOfSize:14];
            self.labelDesc.frame = CGRectMake(10, 5, YTHScreenWidth-20, size.height);
            //self.labelDesc.backgroundColor = [UIColor orangeColor];
            //            [self.labelDesc sizeToFit];
            //self.viewBgDesc.backgroundColor = [UIColor orangeColor];
            
            
            //是否关注
            if (!IsNilOrNull([[showdic objectForKey:@"user"]objectForKey:@"userRelStatus"])) {
                NSString *userRelStatus=[[showdic objectForKey:@"user"]objectForKey:@"userRelStatus"];
               
                if ([userRelStatus isEqualToString:@"0"]) {
                    
                    [self.addAttionBtn setImage:[UIImage imageNamed:@"attention_add"] forState:UIControlStateNormal];
                    
                }else if ([userRelStatus isEqualToString:@"1"])
                {
    
                    [self.addAttionBtn setImage:[UIImage imageNamed:@"attention_yet"] forState:UIControlStateNormal];
                
                }else if ([userRelStatus isEqualToString:@"2"])
                {
                    [self.addAttionBtn setImage:[UIImage imageNamed:@"attention_together"] forState:UIControlStateNormal];
                    
                    
                }
            }else{
                //[self.addAttionBtn removeFromSuperview];
                self.addAttionBtn.hidden = NO;
            }
            
            
            self.praiseuuid = [showdic objectForKey:@"uuid"];
            
            //图片
            NSArray *photosUrlArr = [[NSString stringWithFormat:@"%@",[showdic objectForKey:@"photoUrl"]] componentsSeparatedByString:@","];
            
            for (NSString *photoUrl in photosUrlArr) {
            
                [self.photoNameList addObject:photoUrl];
            
            }
            
            [self.bigImage sd_setImageWithURL:[NSURL URLWithString:[self.photoNameList objectAtIndex:0]]];
            
            _bigString =[self.photoNameList objectAtIndex:0];
            
            self.bigImage.userInteractionEnabled = YES;
            
            UITapGestureRecognizer  * faceTapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(alertFace:)];
            
            faceTapGesture.numberOfTapsRequired = 1;
            
            [self.bigImage addGestureRecognizer:faceTapGesture];
            
            
            
            if (self.photoNameList.count>1) {
              
                [self.photoNameList removeObjectAtIndex:0];
                
                [self _initCollectionView];
                
                _headView.frame = CGRectMake(0, 0, YTHScreenWidth, 400);
                
                _viewBgDesc.frame = CGRectMake(0, CGRectGetMaxY(_kPhotoCollectionView.frame), YTHScreenWidth, size.height+10);
                
                _headView.frame = CGRectMake(0, 0, YTHScreenWidth, 400+f);
                
                _tableView.tableHeaderView = _headView;
      
            }
            //标签
            NSArray *labellid=[showdic objectForKey:@"labels"];
            
            for (NSDictionary *labelDict in labellid) {

                NSString *labelArry = [labelDict objectForKey:@"name"];
                
                [_kTitleArrays addObject:labelArry];
            
            }
            
            [self _initLabel];
            
            if (_kTitleArrays.count>0) {
                
                _headView.frame = CGRectMake(0, 0, YTHScreenWidth, 400+f+16);
                
                _tableView.tableHeaderView = _headView;
            }
            
            //姓名
            _nameLabel.text=[[showdic objectForKey:@"user"]objectForKey:@"name"];
            CGSize sizeName;

            sizeName =  [_nameLabel.text boundingRectWithSize:CGSizeMake(YTHScreenWidth-150, 1000) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:dicrary context:nil].size;
            
            _nameLabel.frame = CGRectMake(YTHAdaptation(60), YTHAdaptation(10), sizeName.width, sizeName.height);
            
            self.sexImV.frame =CGRectMake(CGRectGetMaxX(_nameLabel.frame)+3, YTHAdaptation(10),YTHAdaptation(15), YTHAdaptation(15));
            
            //大学
            if (!IsNilOrNull([[showdic objectForKey:@"user"]objectForKey:@"universityName"])) {
                _uniserLabel.text = [[showdic objectForKey:@"user"]objectForKey:@"universityName"];
            }
            //性别
            NSString *sexurl = [[showdic objectForKey:@"user"] objectForKey:@"sex"];
            if ([sexurl isEqualToString:@"0"]) {
                self.sexImV.image = [UIImage imageNamed:@"sex_male"];
            }
            else if ([sexurl isEqualToString:@"1"])
            {
                self.sexImV.image = [UIImage imageNamed:@"sex_female"];
            }

            //头像
            self.urlString = [[showdic objectForKey:@"user"]objectForKey:@"avatar"];
           
            YTHLog(@"头像%@",self.urlString);
            
            if (!IsNilOrNull([[showdic objectForKey:@"user"]objectForKey:@"avatar"])&&!self.urlString.length==0) {
              
                [self.headImgV sd_setImageWithURL:[NSURL URLWithString:self.urlString]];
                
            }else{
              
                if ([sexurl isEqualToString:@"0"]) {
                
                    self.headImgV.image = [UIImage imageNamed:@"female"];
                
                }else if ([sexurl isEqualToString:@"1"]){
                
                    self.headImgV.image = [UIImage imageNamed:@"male"];
                
                }
            }
            
        }
        [self.tableView reloadData];
        
        [_kPhotoCollectionView reloadData];
    
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
#warning statusCode 500
       
        YTHLog(@"详情错误返回状态码 %ld",(long)[operation.response statusCode]);
        
        self.jason = operation.responseObject;
        
        YTHLog(@"登录%@", self.jason);
        
        [MBProgressHUD showError:[self.jason objectForKey:@"info"]];
    
    }];
 
}

#pragma mark 添加标签

-(void)_initLabel
{
    //    _kTitleView = [[UIScrollView alloc]init];
    //    if (self.photoNameList.count<1) {
    //        _kTitleView.frame =CGRectMake(10, CGRectGetMaxY(self.viewBgDesc.frame)+10, YTHScreenWidth-20, 44);
    //        self.headView.frame = CGRectMake(0, 0, YTHScreenWidth, 380);
    //        [self.tableView reloadData];
    //    }else{
    //        _kTitleView.frame =CGRectMake(10, CGRectGetMaxY(_kPhotoCollectionView.frame)+10, YTHScreenWidth-20, 44);
    //        self.headView.frame = CGRectMake(0, 0, YTHScreenWidth, 350+99);
    //        [self.tableView reloadData];
    //    }
    //    _kTitleView.backgroundColor = [UIColor redColor];
    // _kTitleView.backgroundColor = [UIColor yellowColor];
    
    _kMarkRect = CGRectMake(0,0,0,0);
    
    [self.headView addSubview:_kTitleView];
    
    for (NSString *title in _kTitleArrays) {
        
        [self _addTitleBtn:title andAdd:NO];
        
    }
    
}

-(void)_addTitleBtn:(NSString *)title andAdd:(BOOL)add{
    
    if (!_kTitleView) {//创建标签View
        
        [MarkIV removeFromSuperview];
        
        _kTitleView = [[UIScrollView alloc]initWithFrame:CGRectMake(0,CGRectGetMaxY(self.viewBgDesc.frame) , YTHScreenWidth, 50)];
        
//        _kTitleView.backgroundColor = [UIColor yellowColor];
        //        _kTitleView.backgroundColor = YTHBaseVCBackgroudColor;
        
        _headView.frame = CGRectMake(0, 0, YTHScreenWidth, CGRectGetMaxY(self.viewBgDesc.frame));
        
        _tableView.tableHeaderView = _headView;
        
        [self.headView addSubview:_kTitleView];
        
        MarkIV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 12, 16, 16)];
        
        MarkIV.image = [UIImage imageNamed:@"lable_blue"];
        
        [_kTitleView addSubview:MarkIV];
        
        if (_kTitleView.height <40) {//只有一行标签时 不可滚动
            
            _kTitleView.scrollEnabled = NO;
            
        }else{
            
            _kTitleView.scrollEnabled = YES;
        }
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
    kMarkView = [[UIView alloc]initWithFrame:CGRectMake(_kMarkRect.origin.x + _kMarkRect.size.width + 10, _kMarkRect.origin.y, length+20, 27)];
    
    
    [_kTitleView addSubview:kMarkView];
    
    _kMarkRect = kMarkView.frame;
    
    //标签 Label
    kTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(25, 0, length+14, 20)];
    
    kTitleLabel.backgroundColor = YTHColor(120,190, 253);
    
    kTitleLabel.layer.cornerRadius = 8;
    
    kTitleLabel.layer.masksToBounds = YES;
    
    kTitleLabel.textAlignment = NSTextAlignmentCenter;
    
    kTitleLabel.font = [UIFont systemFontOfSize:12];
    
    kTitleLabel.textColor = [UIColor whiteColor];
    
    kTitleLabel.text = title;
    
    [kMarkView addSubview:kTitleLabel];
    
    //删除按钮
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
        
    }
    
    kDeleteButton.tag = [_kTitleArrays indexOfObject:title] + 999;
    
    _kTitleView.contentSize = CGSizeMake(YTHScreenWidth, CGRectGetMaxY(kMarkView.frame)+10);
    // self.viewLabel.height =kMarkView.height;
    float h;
    YTHLog(@"frame标签%f",kMarkView.frame.origin.y);
    
}


#pragma mark--创建底部 赞、更多、评论
-(void)_initComment
{
    //底部View
    commentView = [[UIView alloc]initWithFrame:CGRectMake(0, YTHScreenHeight-YTHAdaptation(46), YTHScreenWidth,46)];
    
    [self.view addSubview:commentView];
    
    [self.view bringSubviewToFront:commentView];
    
    UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, YTHScreenWidth, 1)];
    
    lineLabel.backgroundColor = YTHColor(229, 229, 229);
    
    [commentView addSubview:lineLabel];
    
   
    //赞按钮
    praiseButton = [[UIButton alloc]initWithFrame:CGRectMake(YTHAdaptation(40), YTHAdaptation(15), YTHAdaptation(18),YTHAdaptation(18) )];
    
    [praiseButton setImage:[UIImage imageNamed:@"icon_zan"] forState:UIControlStateNormal];
    
    praiseButton.tag = 10;
    
    [praiseButton addTarget:self action:@selector(commentBtn:) forControlEvents:UIControlEventTouchUpInside];
  
    [commentView addSubview:praiseButton];
    
    //更多按钮
    moreButton = [[UIButton alloc]initWithFrame:CGRectMake(YTHAdaptation(40)+YTHScreenWidth/4, YTHAdaptation(16), YTHAdaptation(18),YTHAdaptation(16) )];
    
    [moreButton setImage:[UIImage imageNamed:@"icon_operate"] forState:UIControlStateNormal];
    
    moreButton.tag = 15;
    
    moreButton.showsTouchWhenHighlighted = YES;
    
    [moreButton addTarget:self action:@selector(commentBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    //self.praiseButton = moreButton;
    
    [commentView addSubview:moreButton];
    
    //竖线
    UILabel *middleL = [[UILabel alloc]initWithFrame:CGRectMake(YTHScreenWidth/4-.5, 0, 1, commentView.height)];
    
    middleL.backgroundColor = YTHColor(229, 229, 229);
    
    [commentView addSubview:middleL];
    
    //评论按钮
    commentButton = [[UIButton alloc]initWithFrame:CGRectMake(YTHScreenWidth/2, 0, YTHScreenWidth/2, commentView.height)];
    
    commentButton.backgroundColor = YTHColor(255, 70, 80);
    
    [commentButton setTitle:@"评论" forState:UIControlStateNormal];
    
    [commentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    commentButton.tag = 20;
    
    [commentButton addTarget:self action:@selector(commentBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [commentView addSubview:commentButton];
    
    //更多操作View
    
    moreView = [[UIView alloc]initWithFrame:CGRectMake(YTHScreenWidth/4-10, YTHScreenHeight-YTHAdaptation(46), YTHScreenWidth/4+20, 0)];

//    moreView = [[UIView alloc]initWithFrame:CGRectMake(YTHScreenWidth/4-10+(YTHScreenWidth/8+10), YTHScreenHeight-YTHAdaptation(46)-YTHAdaptation(40), 0, 0)];

    moreView.backgroundColor = YTHColor(255, 255, 255);
    
    moreView.layer.cornerRadius = 5;
    
    moreView.layer.masksToBounds = YES;
    
    moreView.layer.borderWidth = 1;
    
    moreView.layer.borderColor = [[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1] CGColor];
    
    [self.view addSubview:moreView];

    //收藏按钮
    
    collectButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, YTHScreenWidth/4+20, YTHAdaptation(40))];
    
    [collectButton setTitle:@"收藏" forState:UIControlStateNormal];
    
    [collectButton setTitleColor:[UIColor grayColor]];
    
    [collectButton addTarget:self action:@selector(clickMore:) forControlEvents:UIControlEventTouchUpInside];
    
    collectButton.tag = 1;
    
    [moreView addSubview:collectButton];
    
    
    //分享按钮
    shareButton = [[UIButton alloc]initWithFrame:CGRectMake(0, YTHAdaptation(40), YTHScreenWidth/4+20, YTHAdaptation(40))];
    
    [shareButton setTitle:@"分享" forState:UIControlStateNormal];
    
    [shareButton setTitleColor:[UIColor grayColor]];

    [shareButton addTarget:self action:@selector(clickMore:) forControlEvents:UIControlEventTouchUpInside];
    
    shareButton.tag = 2;
    
    [moreView addSubview:shareButton];
    
    moreView.clipsToBounds = YES;
    
    UILabel *lineL = [[UILabel alloc]initWithFrame:CGRectMake(0, YTHAdaptation(40)-.5, YTHScreenWidth/4+20, 1)];
    
    lineL.backgroundColor = [UIColor lightGrayColor];
    
    [moreView addSubview:lineL];
    
}

#pragma mark 收藏、分享
-(void)clickMore:(UIButton *)btn{
    
    btn.selected = !btn.selected;
    
    if (btn.tag ==1) {     //收藏
        if (btn.selected==YES) {//点击收藏

            NSString *uS = Url;
            
            NSString *ueltext = [NSString stringWithFormat:@"v1/show/%@/collection", self.praiseuuid];
            
            NSString *text = [NSData AES256EncryptWithPlainText:ueltext passtext:myDelegate.accessToken];
            
            YTHLog(@"登录密码=%@",myDelegate.accessToken);
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            
            [manager.requestSerializer setAuthorizationHeaderFieldWithToken:text];
            
            [manager.requestSerializer setValue:myDelegate.account forHTTPHeaderField:@"account"];
            
            NSString *urlStr = [NSString stringWithFormat:@"%@v1/show/%@/collection",uS, self.praiseuuid];
           
            YTHLog(@"赞拼接之后%@",urlStr);
            
            [manager POST:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                YTHLog(@"赞%@",responseObject);
                
                self.praiseJason = responseObject;
                
                YTHLog(@"赞 %ld",(long)[operation.response statusCode]);
                
//                if ([operation.response statusCode]/100==2)//收藏 成功
//                {
//                    [praiseButton setImage:[UIImage imageNamed:@"icon_zan_red"] forState:UIControlStateNormal];
//                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                YTHLog(@"赞 %ld",(long)[operation.response statusCode]);
                
                self.praiseJason = operation.responseObject;
                
                YTHLog(@"赞%@", self.praiseJason);
                
                [MBProgressHUD showError:[self.praiseJason objectForKey:@"info"]];
                
            }];

        
        }else{  //分享
            
            
           
            
            
        }
        
        
        
    }else{                 //分享
        
        
        
    
    
    }
    
    
}

#pragma mark -- 点击 赞、 更多、评论
-(void)commentBtn:(UIButton *)btn
{
    
    YTHLog(@"-----------------------点击了底部某个按钮----------------");

    if(btn.tag==10){
        
        YTHLog(@"-----------------------点击了赞----------------");


        btn.selected = !btn.selected;
        if (btn.selected==YES) {//点赞
            NSString *uS = Url;
            
            NSString *ueltext = [NSString stringWithFormat:@"v1/show/%@/praise", self.praiseuuid];
            NSString *text = [NSData AES256EncryptWithPlainText:ueltext passtext:myDelegate.accessToken];
            YTHLog(@"登录密码=%@",myDelegate.accessToken);
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            [manager.requestSerializer setAuthorizationHeaderFieldWithToken:text];
            [manager.requestSerializer setValue:myDelegate.account forHTTPHeaderField:@"account"];
            
            NSString *urlStr = [NSString stringWithFormat:@"%@v1/show/%@/praise",uS, self.praiseuuid];
            YTHLog(@"赞拼接之后%@",urlStr);
            [manager POST:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                YTHLog(@"赞%@",responseObject);
                self.praiseJason = responseObject;
                YTHLog(@"赞 %ld",(long)[operation.response statusCode]);
                if ([operation.response statusCode]/100==2)//赞 成功
                {
                    [praiseButton setImage:[UIImage imageNamed:@"icon_zan_red"] forState:UIControlStateNormal];
                    
                    
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                YTHLog(@"赞 %ld",(long)[operation.response statusCode]);
                self.praiseJason = operation.responseObject;
                YTHLog(@"赞%@", self.praiseJason);
                [MBProgressHUD showError:[self.praiseJason objectForKey:@"info"]];
                
                
            }];
    
            
       }else {//取消赞
           
           NSString *uS = Url;
           
           NSString *ueltext = [NSString stringWithFormat:@"v1/show/%@/praise", self.praiseuuid];
           
           NSString *text = [NSData AES256EncryptWithPlainText:ueltext passtext:myDelegate.accessToken];
           
           YTHLog(@"登录密码=%@",myDelegate.accessToken);
           
           AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
           
           [manager.requestSerializer setAuthorizationHeaderFieldWithToken:text];
           
           [manager.requestSerializer setValue:myDelegate.account forHTTPHeaderField:@"account"];
           
           NSString *urlStr = [NSString stringWithFormat:@"%@v1/show/%@/praise",uS, self.praiseuuid];
           
           YTHLog(@"赞拼接之后%@",urlStr);
           
           [manager DELETE:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
               YTHLog(@"赞%@",responseObject);
               self.praiseJason = responseObject;
               YTHLog(@"赞 %ld",(long)[operation.response statusCode]);
               if ([operation.response statusCode]/100==2)
               {
                   
                   [praiseButton setImage:[UIImage imageNamed:@"icon_zan"] forState:UIControlStateNormal];
                   
               }
               
           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               YTHLog(@"赞 %ld",(long)[operation.response statusCode]);
               self.praiseJason = operation.responseObject;
               YTHLog(@"赞%@", self.praiseJason);
               [MBProgressHUD showError:[self.praiseJason objectForKey:@"info"]];
               
               
           }];
           
        }
    }else if (btn.tag==15)//点击更多
        
    {
        YTHLog(@"-----------------------点击了更多----------------");

        btn.selected = !btn.selected;
        if (btn.selected==YES) {//点击更多
        
        [UIView animateWithDuration:.4 animations:^{

           moreView.frame = CGRectMake(YTHScreenWidth/4-10, YTHScreenHeight-YTHAdaptation(40)-100, YTHScreenWidth/4+20, YTHAdaptation(40)*2) ;

        }];
            
        }else{  //再次点击更多
        [UIView animateWithDuration:.4 animations:^{
            moreView.frame = CGRectMake(YTHScreenWidth/4-10, YTHScreenHeight-YTHAdaptation(46), YTHScreenWidth/4+20, 0);
  
//            moreView.frame = CGRectMake(YTHScreenWidth/4-10+(YTHScreenWidth/8+10), YTHScreenHeight-YTHAdaptation(46)-YTHAdaptation(40), 0, 0);
        
        }];
         
        }
    }else if (btn.tag==20)//点击评论
    {
        YTHLog(@"-----------------------点击了评论----------------");

        
        CommentViewController *commentVC = [[CommentViewController alloc]init];
       
        commentVC.uuid = self.uuid;
        
        commentVC.userUuid = self.userUuid;
        
        [self.navigationController pushViewController:commentVC animated:YES];
    }
    
}

//初始化头View
-(void)_initHeadView
{
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, YTHScreenWidth, 400)];
   
    headView.backgroundColor = [UIColor whiteColor];
    
    self.headView = headView;
    
    [self.tableView.tableHeaderView addSubview:self.headView];
    //  headView.backgroundColor = [UIColor blueColor];
    // self.tableView.tableHeaderView = headView;
    
    //头像
    UIImageView *headImgV      = [[UIImageView alloc]initWithFrame:CGRectMake(YTHAdaptation(10),YTHAdaptation(15),YTHAdaptation(40),YTHAdaptation(40))];

    [headImgV.layer setMasksToBounds:YES];

    [headImgV.layer setCornerRadius:YTHAdaptation(20)];

    headImgV.layer.borderColor = [UIColor whiteColor].CGColor;

    headImgV.layer.borderWidth = 1;

    self.headImgV             = headImgV;
    
    [self.headView addSubview:headImgV];
    //名字
    
    UILabel *nameLabel  = [[UILabel alloc]initWithFrame:CGRectMake(YTHAdaptation(60), YTHAdaptation(10), YTHAdaptation(50),YTHAdaptation(20))];

    nameLabel.text      = @"gmc";

    nameLabel.font      = [UIFont systemFontOfSize:14];

    nameLabel.textColor = YTHColor(91, 91, 91);
   // nameLabel.backgroundColor = [UIColor yellowColor];

    self.nameLabel      = nameLabel;
    
    [self.headView addSubview:nameLabel];
    
    //性别
    UIImageView *sexImV  = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(nameLabel.frame), YTHAdaptation(15),YTHAdaptation(15), YTHAdaptation(15))];

    sexImV.image        = [UIImage imageNamed:@"sex_female"];

    self.sexImV         = sexImV;
    
    [self.headView addSubview:sexImV];
    
    //达人
//    UIImageView *expertImage = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(sexImV.frame)+YTHAdaptation(5), YTHAdaptation(15), YTHAdaptation(40), YTHAdaptation(14))];
//    expertImage.image = [UIImage imageNamed:@"tarento"];
//    [self.headView addSubview:expertImage];
//    //达人名字
//    UILabel *expertLabel = [[UILabel alloc]initWithFrame:CGRectMake(YTHAdaptation(10), 0, YTHAdaptation(35), YTHAdaptation(14))];
//    expertLabel.text = @"模特";
//    expertLabel.font = [UIFont systemFontOfSize:12];
//    expertLabel.textColor = [UIColor blackColor];
//    [expertImage addSubview:expertLabel];
    
    //学校
    UILabel *uniserLabel         = [[UILabel alloc]initWithFrame:CGRectMake(YTHAdaptation(60), YTHAdaptation(40), YTHAdaptation(200), YTHAdaptation(30))];

    uniserLabel.text             = @"";

    uniserLabel.font             = [UIFont systemFontOfSize:12];

    uniserLabel.textColor        = YTHColor(197, 197, 197);

    self.uniserLabel             = uniserLabel;

    [self.headView addSubview:uniserLabel];

    UIButton *addAttionBtn       = [UIButton buttonWithType:UIButtonTypeCustom];

    addAttionBtn.frame           = CGRectMake(YTHScreenWidth-YTHAdaptation(59),YTHAdaptation(30),YTHAdaptation(49), YTHAdaptation(20));

    [addAttionBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];

    addAttionBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    
    //    [addAttionBtn.layer setMasksToBounds:YES];
    //    [addAttionBtn.layer setCornerRadius:YTHAdaptation(4.5)];
    //    addAttionBtn.layer.borderColor = [UIColor blueColor].CGColor;
    //    addAttionBtn.layer.borderWidth = 1;
    
    [addAttionBtn addTarget:self action:@selector(attention:) forControlEvents:UIControlEventTouchUpInside];
    
    self.addAttionBtn = addAttionBtn;
    
    [self.headView addSubview:addAttionBtn];
    
    //大图
    UIImageView *bigImage  = [[UIImageView alloc]initWithFrame:CGRectMake(YTHAdaptation(10), CGRectGetMaxY(uniserLabel.frame)+YTHAdaptation(10), YTHScreenWidth-YTHAdaptation(20), YTHAdaptation(175))];

//   bigImage.contentMode = UIViewContentModeScaleAspectFit;
//   bigImage.contentMode = UIViewContentModeScaleAspectFill;

    self.bigImage         = bigImage;

    [self.headView addSubview:bigImage];
    //    self.photoNameList = [[NSMutableArray alloc] initWithObjects:@"0.tiff",@"1.tiff",@"2.tiff",@"3.tiff",@"4.tiff",nil];
}
#pragma mark - 小图
-(void)_initCollectionView
{
    //小图

    _kPhotoCollectionViewJJ                                   = (YTHScreenWidth-20-83*4)/3.0f;

    _kPhotoCollectionViewFlowLayout                         = [[UICollectionViewFlowLayout alloc]init];

    _kPhotoCollectionViewFlowLayout.sectionInset            = UIEdgeInsetsMake(8, 10, 8, 10);

    _kPhotoCollectionViewFlowLayout.minimumInteritemSpacing = 0;

    _kPhotoCollectionViewFlowLayout.minimumLineSpacing      = 10;
    
    _kPhotoCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.bigImage.frame)+10,
                                                                              YTHScreenWidth, 99) collectionViewLayout:_kPhotoCollectionViewFlowLayout];
    

    _kPhotoCollectionView.delegate          = self;

    _kPhotoCollectionView.dataSource      = self;

    _kPhotoCollectionView.bounces         = NO;

    _kPhotoCollectionView.backgroundColor = [UIColor whiteColor];
    
    [_kPhotoCollectionView registerClass:[kSuggessPhotoCollectionViewCell class]
     
     forCellWithReuseIdentifier:@"kSuggessPhotoCollectionViewCellId"];
    
    [self.headView addSubview:_kPhotoCollectionView];
    
    [_kPhotoCollectionView reloadData];
    
}

#pragma mark-发布文字
-(void)_initViewBgDesc
{
    UIView *viewBgDesc       = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.bigImage.frame)+10, YTHScreenWidth, 25)];

   // viewBgDesc.backgroundColor = [UIColor whiteColor];
    self.viewBgDesc         = viewBgDesc;

    [self.view addSubview:viewBgDesc];

    UILabel *labelDesc      = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, YTHScreenWidth-20, 25)];

    labelDesc.textColor     = [UIColor blackColor];

    labelDesc.numberOfLines = 0;

    labelDesc.font          = [UIFont systemFontOfSize:14];

    [viewBgDesc addSubview:labelDesc];

    self.labelDesc           = labelDesc;
    
    [self.headView addSubview:viewBgDesc];
    
    
}



#pragma mark - UITableView
-(void)_initTableView
{

    UITableView *tableView    = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, YTHScreenWidth, YTHScreenHeight-110)
                                                         style:UITableViewStyleGrouped];
    tableView.dataSource      = self;

    tableView.delegate        = self;

    self.tableView            = tableView;

//  tableView.backgroundColor = [UIColor orangeColor];

    tableView.tableHeaderView = self.headView;
    
    [self.view addSubview:tableView];
    
}
#pragma mark-关注
- (void)attention:(UIButton *)sender{
    
    sender.selected = !sender.selected;
    
    if (sender.selected == YES) {

        NSString *uS       = Url;

        NSString *ueltext = [NSString stringWithFormat:@"v1/user/%@/follow",_attenuuid];

        NSString *text    = [NSData AES256EncryptWithPlainText:ueltext passtext:myDelegate.accessToken];
        
        YTHLog(@"登录密码=%@",myDelegate.accessToken);
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager.requestSerializer setAuthorizationHeaderFieldWithToken:text];
        
        [manager.requestSerializer setValue:myDelegate.account forHTTPHeaderField:@"account"];
        
        NSString *urlStr = [NSString stringWithFormat:@"%@v1/user/%@/follow",uS,_attenuuid];
        YTHLog(@"关注拼接之后%@",urlStr);
        
        //用户id 传过去
        [manager POST:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            YTHLog(@"关注%@",responseObject);
        
            self.attenJason = responseObject;
            
            YTHLog(@"关注 %ld",(long)[operation.response statusCode]);
            
            if ([operation.response statusCode]/100==2)
            {
                [self.addAttionBtn setTitle:@"已关注" forState:UIControlStateNormal];
                
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            YTHLog(@"关注 %ld",(long)[operation.response statusCode]);
            
            self.attenJason = operation.responseObject;
            
            YTHLog(@"关注%@", self.attenJason);
            
            [MBProgressHUD showError:[self.attenJason objectForKey:@"info"]];
            
        }];
        
    }else{
        NSString *uS       = Url;

        NSString *ueltext  = [NSString stringWithFormat:@"v1/user/%@/follow",_attenuuid];

        NSString *text     = [NSData AES256EncryptWithPlainText:ueltext passtext:myDelegate.accessToken];
        
        YTHLog(@"登录密码=%@",myDelegate.accessToken);
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager.requestSerializer setAuthorizationHeaderFieldWithToken:text];
        
        [manager.requestSerializer setValue:myDelegate.account forHTTPHeaderField:@"account"];
        
        NSString *urlStr = [NSString stringWithFormat:@"%@v1/user/%@/follow",uS,_attenuuid];
        
        [manager DELETE:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            YTHLog(@"取消关注%@",responseObject);
            
            self.attenJason = responseObject;
            
            YTHLog(@"取消关注 %ld",(long)[operation.response statusCode]);
            
            if ([operation.response statusCode]/100==2)
            {
                [self.addAttionBtn setTitle:@"取消关注" forState:UIControlStateNormal];
                
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            YTHLog(@"取消关注 %ld",(long)[operation.response statusCode]);
            
            self.attenJason = operation.responseObject;
            
            YTHLog(@"取消关注%@", self.attenJason);
            
            [MBProgressHUD showError:[self.attenJason objectForKey:@"info"]];
            
        }];
    }
}

#pragma mark tableView的代理和数据源方法
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
        {
            if (self.flag) {
                
                return self.data.count;
            }else{
                
                return _sourceArray.count;
            }
        }
            break;
        default:
            return 0;
            break;
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    switch (indexPath.section) {
        case 0:   //赞列表
        {
           praiseCell = [[PraiseTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
            
            [praiseCell.commentButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            
            praiseCell.commentButton.tag = 0;
            
           // praiseCell.commentButton.backgroundColor = [UIColor greenColor];
            
            [praiseCell.praiseButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            
            praiseCell.praiseButton.tag = 1;
            
            NSUserDefaults *praiseArrow = [NSUserDefaults standardUserDefaults];
            
            BOOL what;
            
            what = [praiseArrow objectForKey:@"praiseStatus"];
            
            if (what ==YES) {
                
                praiseCell.arrowImg.alpha = 1;
                
            }else{
                praiseCell.arrowImg.alpha = 0;

            }
            
            return praiseCell;
        }
            break;
        case 1://评论列表
        {
            if (self.flag) {
                static NSString *indetify = @"showCommentCell";
               
                ShowTableViewCell *showTableCell = [tableView dequeueReusableCellWithIdentifier:indetify];
                
                if (showTableCell==nil) {
                    showTableCell=[[ShowTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indetify];
               
                }
                
                showTableCell.myLayoutFrame = self.data[indexPath.row];
            
//            showTableCell.backgroundColor = [UIColor yellowColor];
                return showTableCell;
            
            }else{
               
                static NSString *identify = @"kIdentifier";
                
                MyFanTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
                
                if (cell == nil) {
                    cell = [[MyFanTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
                }
                
                cell.flag = self.flag;
                
                cell.showModel = _sourceArray[indexPath.row];
                
                return cell;
                
            }
            
        }
            break;
    }
    return cell;
    
}
#pragma mark -赞列表,评论列表
-(void)buttonAction:(UIButton *)btn
{
    
    if (btn.tag ==0) {//点击列表上部的评论
        
        isPraise = YES;
        
        NSUserDefaults *praiseArrow = [NSUserDefaults standardUserDefaults];
        
        [praiseArrow setBool:isPraise  forKey:@"praiseStatus"];
        
        [praiseArrow synchronize];
        
        [self requestTable];
        
    }else{   //点击列表上部的赞
        
        isPraise =NO;
        
        NSUserDefaults *praiseArrow = [NSUserDefaults standardUserDefaults];
        
        [praiseArrow setBool:isPraise  forKey:@"praiseStatus"];
        
        [praiseArrow synchronize];
  
        //赞列表
   
        YTHLog(@"赞列表");

    
        NSString *userUuid                     = _pinglun;

    
        NSString *url1                         = [NSString stringWithFormat:@"v1/show/%@/praises",userUuid];

    
        NSString *text                         = [NSData AES256EncryptWithPlainText:url1 passtext:myDelegate.accessToken];
    
        YTHLog(@"登录密码=%@",myDelegate.accessToken);
    
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
        [manager.requestSerializer setAuthorizationHeaderFieldWithToken:text];
    
        [manager.requestSerializer setValue:myDelegate.account forHTTPHeaderField:@"account"];
   
        NSString *uS                           = Url;
    
        NSString *urlStr                       = [NSString stringWithFormat:@"%@v1/show/%@/praises",uS,_pinglun];
    
        YTHLog(@"赞列表拼接之后%@",urlStr);
    
        [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
            YTHLog(@" 赞列表%ld",(long)[operation.response statusCode]);
         _sourceArray                           = [[NSMutableArray alloc]init];
        
        if ([operation.response statusCode]/100==2)
        {
            YTHLog(@"赞列表%@",responseObject);
            
            NSArray *usersArray = [responseObject objectForKey:@"users"];
            
            for (NSDictionary *dict in usersArray) {
            
                ShowDetailModel *model = [[ShowDetailModel alloc]initContentWithDic:dict];
               
                [self.sourceArray addObject:model];
            }
        }
        
            [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       
        YTHLog(@"赞列表错误 %ld",(long)[operation.response statusCode]);
        
        _praiseListJason = operation.responseObject;
        
        [MBProgressHUD showError:[_praiseListJason objectForKey:@"info"]];
        
    }];
     }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
            
            return 44;
            
            break;
            
        case 1:
            
        {
            if (self.flag) {
                CommentLayFrame *weiboF = self.data[indexPath.row];
               
                return weiboF.cellHeight;
            }
            
            return 100;
        }
            
            break;
            
        default:
            return 0;
            
            break;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==1) {
       
        AnswerViewController *answerVC = [[AnswerViewController alloc]init];
        
        NSInteger row = [indexPath row];
        
        CommentLayFrame *layoutFrame = [self.data objectAtIndex:row];
        
        ShowCommentModel *model  = layoutFrame.showCommentModel;
        
        answerVC.nameTitle = [NSString stringWithFormat:@"%@",[model.createUser objectForKey:@"name"]];
       
        answerVC.uuid = [NSString stringWithFormat:@"%@",[model.createUser objectForKey:@"uuid"]];
        
        answerVC.authorUuid = [NSString stringWithFormat:@"%@",model.authorUuid];
        
        answerVC.pinglun = self.pinglun;
        
        [self.navigationController pushViewController:answerVC animated:YES];
        
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
   
    if (section==0) {
    
        return 10;
        
    }else{
        
        return 0.01;
    }
}

#pragma mark -collection代理
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake(83, 83);
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photoNameList.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
   
    CGRect frame = self.view.bounds;
   
    UIImageView *aimg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    
    [aimg sd_setImageWithURL:self.photoNameList[indexPath.row] placeholderImage:nil];
    
    [self magnifyingPhoto:aimg.image];
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    kSuggessPhotoCollectionViewCell *kPhotoCollectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"kSuggessPhotoCollectionViewCellId"  forIndexPath:indexPath];
    
    kPhotoCollectionViewCell.kSuggessPhotoCollectionViewCellDelegate = self;
    
    if (indexPath.row==self.photoNameList.count) {
        
        [kPhotoCollectionViewCell setPhotoImage:self.photoNameList[indexPath.row] andDeleteBtnHidden:NO];
    
    }else{
        
        [kPhotoCollectionViewCell setPhotoImage:self.photoNameList[indexPath.row] andDeleteBtnHidden:YES];
   
    }
    return kPhotoCollectionViewCell;

}

//小图 点击看大图
-(void)magnifyingPhoto:(UIImage *)image{
    
    self.navigationController.navigationBarHidden = YES;

    _kVIPhotoView = [[VIPhotoView alloc] initWithFrame:CGRectMake(0, 0, YTHScreenWidth, YTHScreenHeight) andImage:image];
    
    _kVIPhotoView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    
    [_kVIPhotoView setContentMode:UIViewContentModeScaleAspectFit];
    
    _kVIPhotoView.alpha = 0;
    
    [self.view addSubview:_kVIPhotoView];
    
    [UIView animateWithDuration:0.3 animations:^{
    
        _kVIPhotoView.alpha = 1;
        
    } completion:^(BOOL finished) {
       
        //创建一个点击手势
        UITapGestureRecognizer*kVIPhotoViewTap=[[UITapGestureRecognizer alloc]init];
        
        //给手势添加事件处理程序
        [kVIPhotoViewTap addTarget:self action:@selector(closeVIPhotoView)];
        
        //指定点击几下触发响应
        kVIPhotoViewTap.numberOfTapsRequired=1;
        
        //指定需要几个手指点击
        kVIPhotoViewTap.numberOfTouchesRequired=1;
        
        //给self.view 添加点击手势
        [_kVIPhotoView addGestureRecognizer:kVIPhotoViewTap];
    
    }];
}
//关闭图片放大
-(void)closeVIPhotoView{
    
    self.navigationController.navigationBarHidden = NO;
    
    [_kVIPhotoView removeFromSuperview];
    
    _kVIPhotoView = nil;
}
//秀第一个图片 点击看大图
- (void)alertFace:(UITapGestureRecognizer *)gesture {
    
    self.navigationController.navigationBarHidden = YES;
    
  //  CGRect frame = self.view.bounds;
    
    UIImageView *aimg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, YTHScreenWidth, YTHScreenHeight)];
    
    [aimg sd_setImageWithURL:_bigString placeholderImage:nil];
    
    [self magnifyingPhoto:aimg.image];
    
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
