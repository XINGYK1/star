//
//  SuggessViewController.m
//  vgool
//
//  Created by vgool on 15/12/16.
//  Copyright © 2015年 chenyanming. All rights reserved.
//

#import "SuggessViewController.h"
#import "DoImagePickerController.h"
#import "AssetHelper.h"
//#import "AsynImageView.h"
#import "sys/utsname.h"
#include <sys/sysctl.h>
#import "kSuggessPhotoCollectionViewCell.h"
#import "VIPhotoView.h"
#import "AppDelegate.h"
#import "NSData+AES256.h"
#import "AFHTTPRequestOperationManager.h"
#import "MBProgressHUD+NJ.h"
#import "QiniuSDK.h"

#define BWMWidth [[UIScreen mainScreen]bounds].size.width
#define BWMHeight [[UIScreen mainScreen] bounds].size.height
#define BWMDongTaiZhi(dongTaiZhi) (dongTaiZhi/320.0f)*[[UIScreen mainScreen]bounds].size.width
@interface SuggessViewController ()<UITextViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,DoImagePickerControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
{
    UILabel *labelText;
    UIView *addPhoView;
    UIButton *addButton;
    UITextView *textView;
    UICollectionView *_kPhotoCollectionView;
    UICollectionViewFlowLayout *_kPhotoCollectionViewFlowLayout;
    CGFloat _kPhotoCollectionViewJJ;
    VIPhotoView *_kVIPhotoView;
    AppDelegate *myDelegate;
}
@property (retain, nonatomic) NSMutableArray *photoNameList;
@property (retain, nonatomic) NSMutableArray *thumbnails;
@property (nonatomic,strong)NSString *tokenKey;//七牛tokenKey
@property (nonatomic,strong)NSString *qiniuText;//七牛
@property (nonatomic,strong)NSDictionary *dict;
@property (nonatomic,strong)NSString *domain;
@property (nonatomic,strong)NSString *urlString;
@property(nonatomic,strong)NSMutableArray *photoArry;
@property (nonatomic,strong)NSString *photoString;



@end

@implementation SuggessViewController
#define MineColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
// Mine(我的) 背景色
#define MineBg MineColor(240, 240, 240)
#define NaM MineColor(250, 90, 0)
#define Label MineColor(240, 240, 240)
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (!myDelegate) {
        myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
    
    self.view.backgroundColor = MineBg;
   
    
    if ([self.typeId isEqualToString:@"1"]) {
        self.navigationItem.title =@"意见建议";
    }else{
       self.navigationItem.title=@"错误报告";
    }

    UIButton *cancelBtn = [[UIButton alloc] init];
    cancelBtn.frame = CGRectMake(0, 0, 30, 30);
    [cancelBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    [cancelBtn addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
       UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, BWMWidth, 36)];
    
    
    
    // label.backgroundColor = [UIColor whiteColor];
    label.textColor = [UIColor grayColor];
    label.font = [UIFont systemFontOfSize:14];
    label.tag = 100;
    [self.view addSubview:label];
    
    
    //添加文本框
    textView=[[UITextView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(label.frame), BWMWidth-20, 308/2)];
    textView.tag=102;
    textView.delegate=self;
    textView.textColor = [UIColor grayColor];
    [self.view addSubview:textView];
    
    [textView.layer setMasksToBounds:YES];
    [textView.layer setCornerRadius:4];
    textView.layer.borderColor = [UIColor grayColor].CGColor;
    textView.layer.borderWidth = 0.1;
    
    labelText = [[UILabel alloc]initWithFrame:CGRectMake(0, 5,BWMWidth-23, 20)];
    
    labelText.font = [UIFont systemFontOfSize:11];
    labelText.numberOfLines = 0;
    labelText.textColor =Label;
    labelText.enabled = NO;//lable必须设置为不可用
    labelText.backgroundColor = [UIColor clearColor];
    [textView addSubview:labelText];
    
    if ([self.typeId isEqualToString:@"1"]) {
        //nationLabel.text = @"意见建议";
        label.text = @"   描述建议";
        labelText.text = @"  写下您的宝贵建议吧最少五个字哦";
    }else if ([self.typeId isEqualToString:@"2"])
    {
        label.text = @"   问题描述";
        labelText.text = @"  写下您体验遇到的问题让我们一起打造更好的VGOOL吧";
       // nationLabel.text = @"错误报告";
    }
    UILabel *phoLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(textView.frame)+1, 60, 94/2)];
    //phoLabel.backgroundColor = [UIColor yellowColor];
    phoLabel.text = @"附加图片";
    phoLabel.font = [UIFont systemFontOfSize:14];
    phoLabel.textColor = [UIColor grayColor];
    [self.view addSubview:phoLabel];
    
    UILabel *feiLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(phoLabel.frame)+3, CGRectGetMaxY(textView.frame)+1, 100, 94/2)];
    feiLabel.text = @"(不超过五张)";
    feiLabel.textColor = [UIColor grayColor];
    feiLabel.font = [UIFont systemFontOfSize:10];
    [self.view addSubview:feiLabel];
    self.photoNameList = [[NSMutableArray alloc] init];
    
    _kPhotoCollectionViewJJ = (BWMWidth-20-48*5)/6.0f;
    _kPhotoCollectionViewFlowLayout = [[UICollectionViewFlowLayout alloc]init];
    _kPhotoCollectionViewFlowLayout.sectionInset =  UIEdgeInsetsMake(6.5, _kPhotoCollectionViewJJ, 6.5, 0);
    _kPhotoCollectionViewFlowLayout.minimumInteritemSpacing = 0;
    _kPhotoCollectionViewFlowLayout.minimumLineSpacing = 0;
    
    _kPhotoCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(phoLabel.frame)+1, BWMWidth-20, 73) collectionViewLayout:_kPhotoCollectionViewFlowLayout];
    _kPhotoCollectionView.delegate = self;
    _kPhotoCollectionView.dataSource = self;
    _kPhotoCollectionView.bounces = NO;
    _kPhotoCollectionView.backgroundColor = [UIColor whiteColor];
    
    [_kPhotoCollectionView
     registerClass:[kSuggessPhotoCollectionViewCell class]
     forCellWithReuseIdentifier:@"kSuggessPhotoCollectionViewCellId"];
    [_kPhotoCollectionView.layer setMasksToBounds:YES];
    [_kPhotoCollectionView.layer setCornerRadius:4];
    _kPhotoCollectionView.layer.borderColor = [UIColor grayColor].CGColor;
    _kPhotoCollectionView.layer.borderWidth = 0.1;
    [self.view addSubview:_kPhotoCollectionView];
    [self.photoNameList addObject:[UIImage imageNamed:@"addpic"]];
    [_kPhotoCollectionView reloadData];
    
    //保存按钮
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    saveButton.frame = CGRectMake(15, BWMHeight-130, BWMWidth-30, 40);
    [saveButton setTitle:@"提交" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveButton setBackgroundImage:[UIImage imageNamed:@"btn_tile"] forState:UIControlStateNormal];
    [saveButton.layer setMasksToBounds:YES];
    [saveButton.layer setCornerRadius:5.5];
    [saveButton addTarget:self action:@selector(subit) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:saveButton];
    _thumbnails = [[NSMutableArray alloc] init];
    [self tapToDismissKB];
    
    
    
#warning 这里先获取青牛，以后再保存再改，先测试
   self.photoArry = [[NSMutableArray alloc]init];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"http://test.platform.vgool.cn/starucan/v1/base/qntoken" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.dict = responseObject;
        if ([operation.response statusCode]/100==2) {
            NSLog(@"获取七牛Token%@",self.dict);
            self.tokenKey = [self.dict objectForKey:@"qntoken"];
            self.domain = [NSString stringWithFormat:@"http://%@",[self.dict objectForKey:@"domain"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        [MBProgressHUD showError:[ self.dict objectForKey:@"info"]];
        NSLog(@"-----error code %ld",(long)[operation.response statusCode]);
        
    }];
    

    
    
}
-(void)deletePhotoImage:(UIImage *)image{
    [self.photoNameList removeObject:image];
    [_kPhotoCollectionView reloadData];
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(48+_kPhotoCollectionViewJJ, 60);
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photoNameList.count>5?5:self.photoNameList.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    kSuggessPhotoCollectionViewCell *kPhotoCollectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"kSuggessPhotoCollectionViewCellId"  forIndexPath:indexPath];
    kPhotoCollectionViewCell.kSuggessPhotoCollectionViewCellDelegate = self;
    if (indexPath.row<self.photoNameList.count-1) {
        [kPhotoCollectionViewCell setImage:self.photoNameList[indexPath.row] andDeleteBtnHidden:NO];
    }else{
        [kPhotoCollectionViewCell setImage:self.photoNameList[indexPath.row] andDeleteBtnHidden:YES];
    }
    return kPhotoCollectionViewCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.photoNameList.count-1) {
        [self addButtonAction];
    }else{
        [self magnifyingPhoto:self.photoNameList[indexPath.row]];
    }
}

-(void)magnifyingPhoto:(UIImage *)image{
    _kVIPhotoView = [[VIPhotoView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) andImage:image];
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
-(void)closeVIPhotoView{
    [_kVIPhotoView removeFromSuperview];
    _kVIPhotoView = nil;
}
-(void)subit
{
    
    UIDevice *device = [[UIDevice alloc] init];
    NSString *phoneVersion = device.systemVersion;//获取当前系统的版本
    NSLog(@"获取当前系统的版本%@",phoneVersion);
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *phoneModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    NSLog(@"设备%@",phoneModel);
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    //    if (![self checkUser]) return;
    if (textView.text.length < 5 || [textView.text isEqualToString:@"写下您的宝贵意见与建议"]) {
        //        [self tishi:@"反馈内容不少于5个字！"];
        return;
    }
    
    [self.photoNameList removeLastObject];
    [MBProgressHUD showMessage:@"发送中"];
    __block int num = 0;
    for (UIImage *image in self.photoNameList) {
        NSData *data = UIImagePNGRepresentation(image);
        QNUploadManager *upManager = [[QNUploadManager alloc] init];
        [upManager putData:data key:nil token:self.tokenKey complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
            _qiniuText = [resp objectForKey:@"key"];
            self.urlString = [NSString stringWithFormat:@"%@/%@",self.domain,self.qiniuText];
            NSLog(@"----图片%@",self.urlString);
            [self.photoArry addObject:self.urlString];
            
            self.photoString= [self.photoArry componentsJoinedByString:@","] ;
            NSLog(@"图片拼接%@",self.photoString);
            num++;
            if (num==self.photoNameList.count) {
                NSMutableDictionary *postParems = [NSMutableDictionary dictionary];
                
                // postParems[@"userId"] = myDelegate.userInfo[@"u_Id"];
                postParems[@"note"] = textView.text;
                postParems[@"phoneModel"] = phoneModel;
                postParems[@"phoneVersion"] = phoneVersion;
                postParems[@"type"] = self.typeId;
                NSLog(@"-----%lu",(unsigned long)self.photoNameList.count);
                NSLog(@"%@",self.photoNameList);
                postParems[@"photoUrl"]=self.photoString;
                
                NSString *uS = Url;
                
                NSString *ueltext =@"v1/feedback/save";
                NSString *text = [NSData AES256EncryptWithPlainText:ueltext passtext:myDelegate.accessToken];
                NSLog(@"登录密码=%@",myDelegate.accessToken);
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                [manager.requestSerializer setAuthorizationHeaderFieldWithToken:text];
                [manager.requestSerializer setValue:myDelegate.account forHTTPHeaderField:@"account"];
                
                NSString *urlStr = [NSString stringWithFormat:@"%@v1/feedback/save",uS];
                NSLog(@"建议保存之后%@",urlStr);
                [manager POST:urlStr parameters:postParems success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"建议保存之后 %ld",(long)[operation.response statusCode]);
                    NSLog(@"建议保存之后%@",responseObject);
                    
                    
                    
                    [MBProgressHUD hideHUD];
                    [MBProgressHUD showSuccess:@"发送成功"];
                    
                    [self.navigationController popViewControllerAnimated:YES];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"建议保存错误 %ld",(long)[operation.response statusCode]);
                    
                }];
                

                
                
                
                
            }

        } option:nil];
        
    }
    
    
    
    
   
    
    
    
}

#pragma mark - 设置点击空白处隐藏键盘
- (void)tapToDismissKB{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    // 设置成NO表示当前控件响应后会传播到其他控件上，默认为YES
    tapGestureRecognizer.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:tapGestureRecognizer];
}
-(void)dismissKeyboard
{
    [textView resignFirstResponder];
}
- (void) sendFeedBack:(NSDictionary *)dic{
    if (dic == nil) {
//        [self tishi:@"加载失败\n "];
        return;
    }
    if([[dic objectForKey:@"code"] intValue] == 0){
//        [self tishi:@"感谢你的意见反馈"];
        
                textView.text = @"";
                [self performSelector:@selector(back:) withObject:nil afterDelay:1.5f];
    }
}


-(void)addButtonAction
{
    if (self.photoNameList.count >= 10) {
//        [self tishi:@"最多上传10张图片"];
        return;
    }
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil   delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        [sheet addButtonWithTitle:@"本地上传"];
        [sheet addButtonWithTitle:@"拍照上传"];
        [sheet addButtonWithTitle:@"取消"];
        sheet.cancelButtonIndex = sheet.numberOfButtons-1;
    }else {
        [sheet addButtonWithTitle:@"本地上传"];
        [sheet addButtonWithTitle:@"取消"];
        sheet.cancelButtonIndex = sheet.numberOfButtons-1;
    }
    [sheet showInView:self.view];
    
}
#pragma mark-UIActionSheet
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        switch (buttonIndex) {
            case 2:{}
                return;
            case 1:
            {
                UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init] ;
                imagePickerController.delegate = self;
                imagePickerController.allowsEditing = NO;
                imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:imagePickerController animated:YES completion:^{}];
                //					[imagePickerController release];
            }
                break;
            case 0:
                [self showImagePicker];
                break;
        }
        
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.photoNameList insertObject:image atIndex:0];
    //    [self.photoNameList addObject:image];
    //self.photoImg.image = image;
    [self reloadPhotos];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - DoImagePickerControllerDelegate
- (void)didCancelDoImagePickerController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSelectPhotosFromDoImagePickerController:(DoImagePickerController *)picker result:(NSArray *)selectedImages
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (picker.nResultType == DO_PICKER_RESULT_UIIMAGE)
    {
        for (int i = 0; i < MIN(10, selectedImages.count); i++)
        {
            
            [self.photoNameList insertObject:selectedImages[i] atIndex:self.photoNameList.count-1];
            //            [self.photoNameList addObject:selectedImages[i]];
        }
    }
    else if (picker.nResultType == DO_PICKER_RESULT_ASSET)
    {
        for (int i = 0; i < MIN(10, selectedImages.count); i++)
        {
            [self.photoNameList insertObject:[ASSETHELPER getImageFromAsset:selectedImages[i] type:ASSET_PHOTO_SCREEN_SIZE] atIndex:self.photoNameList.count-1];
            //            [self.photoNameList addObject:[ASSETHELPER getImageFromAsset:selectedImages[i] type:ASSET_PHOTO_SCREEN_SIZE]];
        }
        
        [ASSETHELPER clearData];
    }
    if (self.photoNameList.count > 0) {
        //        [self reloadPhotos];
        [_kPhotoCollectionView reloadData];
    }
}

- (void)showImagePicker {
    DoImagePickerController *cont = [[DoImagePickerController alloc] initWithNibName:@"DoImagePickerController" bundle:nil];
    cont.delegate = self;
    cont.nResultType = DO_PICKER_RESULT_UIIMAGE;
    cont.nMaxCount = 5 - (self.photoNameList.count-1);//最大张数
    cont.nColumnCount = 4;//选择器行数
    [self presentViewController:cont animated:YES completion:nil];
}

-(void)reloadPhotos
{
    float x = 0;
    //    for (UIView *view in [addPhoView subviews]) {
    //        if(![view isKindOfClass:[UIButton class] ]){
    //            [view removeFromSuperview];
    //        }
    //    }
    int i = 0;
    for (UIImage *image in self.photoNameList) {
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(x+10, 12, 48, 48)];
        img.image = image;
        img.userInteractionEnabled = YES;
        img.multipleTouchEnabled = YES;
        //img.layer.borderWidth = 1;
        UIButton *deleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        deleBtn.frame = CGRectMake(x+10+40, 9, 12, 12);
        [deleBtn setImage:[UIImage imageNamed:@"deletepic"] forState:UIControlStateNormal];
        [deleBtn addTarget:self action:@selector(deleBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [addPhoView addSubview:deleBtn];
        　
        [addPhoView addSubview:img];
        [addPhoView insertSubview:img belowSubview:deleBtn];
        
        x+=58;
        i++;
    }
    
    if (self.photoNameList.count >= 5) {
        addButton.hidden = YES;
    }else{
        addButton.hidden = NO;
        addButton.frame = CGRectMake(x+10, 12, 48, 48);
    }
    
    
}
-(void)backBtnAction
{
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)textViewDidChange:(UITextView *)textView
{
    // self.examineText =  textView.text;
    if (textView.text.length == 0) {
        if ([self.typeId isEqualToString:@"1"]) {
            labelText.text = @"  写下您的宝贵建议吧最少五个字哦";
        }else if ([self.typeId isEqualToString:@"2"])
        {
            labelText.text = @"  写下您体验遇到的问题让我们一起打造更好的VGOOL吧";
        }
    }else
        labelText.text = @"";
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        //注意\n是一个字符,不是两个字符,一定要注意
        [textView resignFirstResponder];
    }
    return YES;
}

-(void)deleBtnAction:(UIButton *)btn
{
    NSLog(@"删除图片");
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
