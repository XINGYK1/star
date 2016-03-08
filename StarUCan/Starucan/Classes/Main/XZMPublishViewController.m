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



#define XZMScreenW [UIScreen mainScreen].bounds.size.width
#define XZMScreenH [UIScreen mainScreen].bounds.size.height

@interface XZMPublishViewController ()
{
    AppDelegate *myDelegate;

    
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
                        
                        
                        //初始化UIAlertController
//                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//                        
//                        [self presentViewController:alertController animated:YES completion:nil];
//                        
//                        
//                        //添加本地上传按钮
//                        UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"本地上传" style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction *action) {
//                            //在这里写本地上传的方法
//                            
//                            
//                        }];
//                        
//                        //添加相机上传按钮
//                        UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"相机上传" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction *action) {
//                            
//                            //在这里写相机上传按钮的方法
//                            
//                            //初始化照片查看器
//                            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
//                            
//                            //给照片查看器设置代理
//                            imagePickerController.delegate = self;
//                            
//                            //关闭图像编辑功能
//                            imagePickerController.allowsEditing = NO;
//                            
//                        }];
//                        
//                        
//                        
//                        //创建取消按钮
//                        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction *action) {
//                            //在这里写取消按钮的方法
//                            
//                        }];
//                        
//                        
//                        //判断可不可以访问相机
//                        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//                            //相机可用的情况，添加全部按钮
//                            
//                            //添加取消按钮
//                            [alertController addAction:cancelAction];
//                            //添加本地上传按钮
//                            [alertController addAction:photoAction];
//                            //添加相机上传按钮
//                            [alertController addAction:cameraAction];
//                            
//
//                            
//                            
//                        
//                        }else{
//                            //相机不可用的情况，不添加相机上传的按钮
//                            
//                            //添加取消按钮
//                            [alertController addAction:cancelAction];
//                            //添加本地上传按钮
//                            [alertController addAction:photoAction];
//                            
//                            
//                        }
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
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



@end

