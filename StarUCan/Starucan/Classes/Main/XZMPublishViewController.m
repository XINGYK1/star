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
#import "ShowViewController.h"
#import "AppDelegate.h"
#import "TopicViewController.h"

//后加的两个类
#import "DoImagePickerController.h"
#import "AssetHelper.h"

#define XZMScreenW [UIScreen mainScreen].bounds.size.width
#define XZMScreenH [UIScreen mainScreen].bounds.size.height

@interface XZMPublishViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,DoImagePickerControllerDelegate>
{
    AppDelegate *myDelegate;

    //后加的不知道干嘛
    BOOL flag;
}

@property (nonatomic, weak)UIImageView *imageView;
@property (strong, nonatomic) NSMutableArray *photoNameList;
@end

static NSInteger XZMSpringFactor = 10;
static CGFloat XZMSpringDelay = 0.1;
@implementation XZMPublishViewController


//当试图将要出现的时候创建两个button
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSArray *images = @[@"release_show", @"release_topic"];
    NSArray *titles = @[@"发图片", @"发话题"];
    
    NSUInteger cols = 2;
    CGFloat btnW = 60;
    CGFloat btnH = btnW + 30;
    CGFloat beginMargin = YTHAdaptation(82);//82
    CGFloat middleMargin = (XZMScreenW - 2 * beginMargin - cols *btnW)/ (cols - 1);
    CGFloat btnStartY = (XZMScreenH - 2 * btnH) * 0.5;
    
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
        
        
        
        
        CGFloat benginBtnY = btnStartY - XZMScreenH;
        
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
            
            
        }];
        
    }
    
    
    /** 添加sloganView指示条 */
    UIImageView *sloganView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"app_slogan"]];
    
    sloganView.y = -XZMScreenW;
    
    [self.view addSubview:sloganView];
    
    CGFloat centerX = XZMScreenW * 0.5;
    
    CGFloat centerEndY = XZMScreenH * 0.15;
    
    CGFloat centerBenginY = centerEndY - XZMScreenH;
    
    /** 添加动画 */
    POPSpringAnimation *anima = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
    anima.fromValue = [NSValue valueWithCGPoint:CGPointMake(centerX, centerBenginY)];
    anima.toValue = [NSValue valueWithCGPoint:CGPointMake(centerX, centerEndY)];
    anima.springBounciness = XZMSpringDelay;
    anima.beginTime = CACurrentMediaTime() + XZMSpringDelay * images.count;
    
    anima.springSpeed = XZMSpringFactor;
    
    [sloganView pop_addAnimation:anima forKey:nil];
    
    [anima setCompletionBlock:^(POPAnimation *anima, BOOL finish) {
        
        //动画完成后打开用户响应
        self.view.userInteractionEnabled = YES;
        
    }];
    
    
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
#define YTHAdaptation(parameter) (parameter/375.0f)*[[UIScreen mainScreen]bounds].size.width
    
    if (!myDelegate) {
        myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }

#pragma mark -导航栏的返回按钮
    UIButton *cancelBtn = [[UIButton alloc] init];
    cancelBtn.frame = CGRectMake(0, 0, 30, 30);
    [cancelBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    
    //把返回item加到navigationBar上
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    
    [cancelBtn addTarget:self action:@selector(clickBack) forControlEvents:UIControlEventTouchUpInside];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //设置不响应用户事件
    self.view.userInteractionEnabled = NO;
    
#pragma mark -添加发图片和发发话题按钮
    
}

- (void)cancelWithCompletionBlock:(void (^)())block
{
    self.view.userInteractionEnabled = NO;
    
    
    int index = 0;
    for (int i = index; i < self.view.subviews.count; i++) {
        UIView *view = self.view.subviews[i];
    
        POPSpringAnimation *anima = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
        
        anima.springBounciness = XZMSpringDelay;
        
        anima.springSpeed = XZMSpringFactor;
        
        anima.beginTime = CACurrentMediaTime() + (i - index) * XZMSpringDelay;
        
        CGFloat endCenterY = view.centerY + XZMScreenH;
        
        anima.toValue = [NSValue valueWithCGPoint:CGPointMake(view.centerX, endCenterY)];
        
        [view pop_addAnimation:anima forKey:nil];
        
        if (i == self.view.subviews.count - 1) { // 最后一个动画完成时
            
            [anima setCompletionBlock:^(POPAnimation *anima, BOOL finish) {
                
               // [self dismissViewControllerAnimated:NO completion:nil];
                
                block();
            }];
        }
        
        
    }
}

#pragma mark -发表按钮Down点击方法
- (void)chickBtnDown:(UIButton *)btn
{
    POPBasicAnimation *anima = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    anima.toValue = [NSValue valueWithCGSize:CGSizeMake(1.1, 1.1)];
    
    [btn pop_addAnimation:anima forKey:nil];
    
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
                        
                        //如果是登录状态，进入showViewController
                        ShowViewController *showVC = [[ShowViewController alloc]init];
                        [self.navigationController pushViewController:showVC animated:YES];
                        
                        
//                        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil   delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
//                        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
//                            [sheet addButtonWithTitle:@"本地上传"];
//                            [sheet addButtonWithTitle:@"拍照上传"];
//                            [sheet addButtonWithTitle:@"取消"];
//                            sheet.cancelButtonIndex = sheet.numberOfButtons-1;
//                        }else {
//                            [sheet addButtonWithTitle:@"本地上传"];
//                            [sheet addButtonWithTitle:@"取消"];
//                            sheet.cancelButtonIndex = sheet.numberOfButtons-1;
//                        }
//                        [sheet showInView:self.view];
                        
                        return;
                        
                   
                    }else{
                        
                        //如果是非登录状态，进入登录页面
                        LoginFirstViewController *loginVC = [[LoginFirstViewController alloc]init];
                        
                        [self.navigationController pushViewController:loginVC animated:YES];
                        
                    }

                    NSLog(@"hdsbjkb");
                    
                    // 切换对应控制器
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
                    
                    NSLog(@"hdsbjkb");
                    
                    // 切换对应控制器
                }];
            }
            
            
                   }];
        
    }];
    
   
    

}

-(void)clickBack {
    //[self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    
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
    //[self reloadPhotos];
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
        // [_kPhotoCollectionView reloadData];
    }
}

- (void)showImagePicker {
    DoImagePickerController *cont = [[DoImagePickerController alloc] initWithNibName:@"DoImagePickerController" bundle:nil];

    cont.flag = flag;
    cont.delegate = self;
    cont.nResultType = DO_PICKER_RESULT_UIIMAGE;
    cont.nMaxCount = 9 - (self.photoNameList.count-1);//最大张数
    cont.nColumnCount = 4;//选择器行数
    [self presentViewController:cont animated:YES completion:nil];
}

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com