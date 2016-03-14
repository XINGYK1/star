//
//  XZMPublishViewController.m
//  百思不得姐
//
//  Created by 谢忠敏 on 15/7/30.
//  Copyright (c) 2015年 谢忠敏. All rights reserved.
//

#import "XZMPublishViewController.h"
#import "XZMButton.h"
#import "POP.h"
#import "UIView+XZMFrame.h"
#import "WXNavigationController.h"
#import "LoginFirstViewController.h"
#import "AppDelegate.h"
#import "TopicViewController.h"
#import "ShowPhotoViewController.h"

#import "DoImagePickerController.h"
#import "AssetHelper.h"

@interface XZMPublishViewController ()<DoImagePickerControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    AppDelegate *myDelegate;
    BOOL flag;
}
@property (nonatomic, weak)UIImageView *imageView;
@property (strong, nonatomic) NSMutableArray *photoNameList;//存储照片的数组

@end

static NSInteger XZMSpringFactor = 10;
static CGFloat XZMSpringDelay = 0.1;

@implementation XZMPublishViewController

//当试图将要出现的时候创建两个button
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //创建两个按钮并且添加出现动画
    [self createBUttonAndAddAnimated];
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
#define YTHAdaptation(parameter) (parameter/375.0f)*[[UIScreen mainScreen]bounds].size.width
    
    //设置导航栏标题
    self.title = @"秀逼格";
    
    flag = YES;
    
    if(!self.photoNameList){
        
        self.photoNameList = [[NSMutableArray alloc]init];
    }
    
    if (!myDelegate) {
        
        myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    [self navigationBarSetting];
    self.view.backgroundColor = [UIColor whiteColor];
    
}

#pragma mark -发表按钮Down点击方法
- (void)chickBtnDown:(UIButton *)btn
{
    POPBasicAnimation *anima = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    anima.toValue = [NSValue valueWithCGSize:CGSizeMake(1.1, 1.1)];
    
    [btn pop_addAnimation:anima forKey:nil];
    
}

//点击一个按钮后让另一个按钮也跟着消失
- (void)cancelWithCompletionBlock:(void (^)())block
{
    
    int index = 0;
    for (int i = index; i < self.view.subviews.count; i++) {
        
        UIView *view = self.view.subviews[i];
        
        POPSpringAnimation *anima = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
        
        anima.springBounciness = XZMSpringDelay;//0.1
        
        anima.springSpeed = XZMSpringFactor;//10
        
        anima.beginTime = CACurrentMediaTime() + (i - index) * XZMSpringDelay;
        
        CGFloat endCenterY = view.centerY + YTHScreenHeight;
        
        anima.toValue = [NSValue valueWithCGPoint:CGPointMake(view.centerX, endCenterY)];
        
        [view pop_addAnimation:anima forKey:nil];
        
        //如果视图的index等于子视图的个数的时候，会执行动画让这个子视图也消失
        if (i == self.view.subviews.count - 1) {
            
            [anima setCompletionBlock:^(POPAnimation *anima, BOOL finish) {
                
                // [self dismissViewControllerAnimated:NO completion:nil];
                
                //本方法里面的内容执行完以后，执行回调方法里面的内容
                block();
            }];
        }
    }
}

#pragma mark -发表按钮UpInside点击方法
- (void)chickBtnUpInside:(UIButton *)btn
{
    POPBasicAnimation *anima = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    
    //点击后出现按钮图标放大到1.3倍的动画
    anima.toValue = [NSValue valueWithCGSize:CGSizeMake(1.3, 1.3)];
    
    [btn pop_addAnimation:anima forKey:nil];
    
    [anima setCompletionBlock:^(POPAnimation *anima, BOOL finish) {
        
        //动画1结束的回调方法，在这里给按钮增加动画2：点击后按钮消失
        POPBasicAnimation *anima2 = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        
        anima2.toValue = @(0);
        
        [btn pop_addAnimation:anima2 forKey:nil];
        
        [anima2 setCompletionBlock:^(POPAnimation *anima, BOOL finish) {
            
            //在动画2结束的回调方法中，判断点击的是哪一个按钮
            if ( btn.tag==0) {
                
                //发图片按钮的点击方法
                [self cancelWithCompletionBlock:^{
                    
                    //判断登录状态
                    if (!IsNilOrNull([myDelegate.userInfo objectForKey:@"uuid"])) {

                        //初始化UIAlertController
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                        
                        
                        //添加本地上传按钮
                        UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"本地上传" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
                            
                            //在这里写本地上传的方法
                            [self showImagePicker];
                            
                        }];

                        //添加相机上传按钮
                        UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"相机上传" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
                            
                            //调取相机方法
                            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init] ;
                            
                            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                            
                            NSArray *temp_MediaTypes = [UIImagePickerController availableMediaTypesForSourceType:imagePickerController.sourceType];
                            
                            imagePickerController.mediaTypes = temp_MediaTypes;
                            
                            imagePickerController.delegate = self;
                            
                            imagePickerController.allowsEditing = YES;
                            
                            //拍照上传
                            [self presentViewController:imagePickerController animated:YES completion:nil];
                            
                        }];
                    
                        //创建取消按钮
                        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction *action) {
                            //在这里写取消按钮的方法
                            
                            [self dismissViewControllerAnimated:YES completion:nil];
        
                        }];
                        //判断可不可以访问相机
                        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                            //相机可用的情况，添加全部按钮
                            //添加相机上传按钮
                            [alertController addAction:cameraAction];
                            //添加本地上传按钮
                            [alertController addAction:photoAction];
                            //添加取消按钮
                            [alertController addAction:cancelAction];
                        }else{
                            //相机不可用的情况，不添加相机上传的按钮
                            //添加取消按钮
                            [alertController addAction:cancelAction];
                            //添加本地上传按钮
                            [alertController addAction:photoAction];
                        }
                        //把UIAlertController展示到当前页面上
                        [self presentViewController:alertController animated:YES completion:nil];
                        
                        return;
                    }else{
                        //如果是非登录状态，进入登录页面
                        LoginFirstViewController *loginVC = [[LoginFirstViewController alloc]init];
                        [self.navigationController pushViewController:loginVC animated:YES];
                    }
                }];
            }else{
                //发文字按钮的点击方法。
                [self cancelWithCompletionBlock:^{
                    //如果是登录状态，进入发表话题页面
                    if (!IsNilOrNull([myDelegate.userInfo objectForKey:@"uuid"])) {
                        TopicViewController *showVC = [[TopicViewController alloc]init];
                        
                        [self.navigationController pushViewController:showVC animated:YES];
                        return;
                        
                    }else{
                        //如果是非登录状态，进入登录页面
                        LoginFirstViewController *loginVC = [[LoginFirstViewController alloc]init];
                        
                        [self.navigationController pushViewController:loginVC animated:YES];
                    }
                    // 切换对应控制器
                }];//最后一个图标消失后的回调方法
            }//发表话题按钮的点击方法
        }];//点击按钮消失动画结束后的回调方法
    }];//点击图标变大动画的回调方法
}

#pragma mark -imagePickerControllerDelegate

//拍照后使用拍摄的照片调用的代理方法，在这里对照片进行相关的操作
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:@"public.image"]) {
        
        //如果媒体类型为图片
        
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        //在这里对拍摄的照片进行相关操作，把照片传到showPhotoViewController
        [self.photoNameList insertObject:image atIndex:0];
        
        ShowPhotoViewController *showVC = [[ShowPhotoViewController alloc]init];
        
        [showVC setPhotoNameList:self.photoNameList];
        
        WXNavigationController *nav = [[WXNavigationController alloc]initWithRootViewController:showVC];
        
        [picker presentViewController:nav animated:YES completion:nil];
        
        
    }else if ([mediaType isEqualToString:@"public.movie"]){
        
        //如果媒体类型为视频，在这里对拍摄的视频做相关的处理
        
        
        
    }
    
}


//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    /**以前
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    //在这里对拍摄的照片进行相关操作，把照片传到showPhotoViewController
    [self.photoNameList insertObject:image atIndex:0];
    
    ShowPhotoViewController *showVC = [[ShowPhotoViewController alloc]init];
    
    [showVC setPhotoNameList:self.photoNameList];
    
    WXNavigationController *nav = [[WXNavigationController alloc]initWithRootViewController:showVC];
    
    [picker presentViewController:nav animated:YES completion:nil];
    
    //[self reloadPhotos];
     */
//}

//取消使用相机的代理方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self dismissViewControllerAnimated:YES completion:^{}];

}

//本地上传按钮的点击方法
- (void)showImagePicker {
    
    DoImagePickerController *cont = [[DoImagePickerController alloc] initWithNibName:@"DoImagePickerController" bundle:nil];
    
    cont.flag = flag;
    
    cont.delegate = self;
    
    cont.nResultType = DO_PICKER_RESULT_UIIMAGE;
    
    cont.nMaxCount = 9 - (self.photoNameList.count-1);//最大张数
    
    cont.nColumnCount = 4;//选择器行数
    
    [self presentViewController:cont animated:YES completion:nil];
}


#pragma mark -DoImagePickerController的代理方法
//取消选择照片的代理方法。
- (void)didCancelDoImagePickerController
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

/*
//选择照片以后的代理方法
- (void)didSelectPhotosFromDoImagePickerController:(DoImagePickerController *)picker result:(NSArray *)selectedImages
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //判断如果选择的是图片 ： nResultType等于0
    if (picker.nResultType == DO_PICKER_RESULT_UIIMAGE)
    {
        for (int i = 0; i < MIN(10, selectedImages.count); i++)
        {
            
            [self.photoNameList insertObject:selectedImages[i] atIndex:self.photoNameList.count-1];
            //            [self.photoNameList addObject:selectedImages[i]];
        }
    }
    
    //如果nResultType等于1
    else if (picker.nResultType == DO_PICKER_RESULT_ASSET)
    {
        for (int i = 0; i < MIN(10, selectedImages.count); i++)
        {
            [self.photoNameList insertObject:[ASSETHELPER getImageFromAsset:selectedImages[i] type:ASSET_PHOTO_SCREEN_SIZE] atIndex:self.photoNameList.count-1];
            //[self.photoNameList addObject:[ASSETHELPER getImageFromAsset:selectedImages[i] type:ASSET_PHOTO_SCREEN_SIZE]];
        }
        
        [ASSETHELPER clearData];
    }
    if (self.photoNameList.count > 0) {
        //        [self reloadPhotos];
        // [_kPhotoCollectionView reloadData];
        
        YTHLog(@"你是干啥的");
    }
}
 
 */

#pragma mark -设置导航栏
-(void)navigationBarSetting{
    
    UIButton *cancelBtn = [[UIButton alloc] init];
    cancelBtn.frame = CGRectMake(0, 0, 30, 30);
    [cancelBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    
    //把返回item加到navigationBar上
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    
    [cancelBtn addTarget:self action:@selector(clickBack) forControlEvents:UIControlEventTouchUpInside];
    
}

#pragma mark -创建两个按钮并且添加出现动画
-(void)createBUttonAndAddAnimated{
    
    NSArray *images = @[@"release_show", @"release_topic"];
    NSArray *titles = @[@"发图片", @"发话题"];
    
    NSUInteger cols = 2;
    CGFloat btnW = 60;
    CGFloat btnH = btnW + 30;
    CGFloat beginMargin = YTHAdaptation(82);//82
    CGFloat middleMargin = (YTHScreenWidth - 2 * beginMargin - cols *btnW)/ (cols - 1);
    CGFloat btnStartY = (YTHScreenHeight - 2 * btnH) * 0.5;
    
    for (int i = 0; i < images.count; i++) {
        
        XZMButton *btn = [XZMButton buttonWithType:UIButtonTypeCustom];
        
        NSInteger col = i % cols;
        NSInteger row = i / cols;
        
        CGFloat btnX = col * (middleMargin +btnW) + beginMargin;
        CGFloat btnY = row * btnH + btnStartY;
        
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [btn setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        
        //为什么添加两次方法
        [btn addTarget:self action:@selector(chickBtnDown:) forControlEvents:UIControlEventTouchDown];
        
        [btn addTarget:self action:@selector(chickBtnUpInside:) forControlEvents:UIControlEventTouchUpInside];
        
        btn.tag = i;
        
        //把Button添加到父视图上
        [self.view addSubview:btn];
        
        CGFloat benginBtnY = btnStartY - YTHScreenHeight;
        
        /** 添加动画 */
        POPSpringAnimation *anima = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
        
        anima.fromValue = [NSValue valueWithCGRect:CGRectMake(btnX, benginBtnY, btnW, btnH)];
        
        anima.toValue = [NSValue valueWithCGRect:CGRectMake(btnX, btnY, btnW, btnH)];
        
        anima.springSpeed = XZMSpringFactor;
        
        anima.springBounciness = XZMSpringDelay;
        
        anima.beginTime = CACurrentMediaTime() + i * XZMSpringDelay;
        
        //给两个button添加出现动画
        [btn pop_addAnimation:anima forKey:nil];
        
        [anima setCompletionBlock:^(POPAnimation *anima, BOOL finish) {
            
            //两个按钮出现动画完成后，在里面进行相关的操作
            
        }];
    }
}


-(void)clickBack {
    
    //[self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end

