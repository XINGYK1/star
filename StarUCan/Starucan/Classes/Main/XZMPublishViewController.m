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
#import "TopicViewController.h"
#import "ShowPhotoViewController.h"
#import "ShowViewController.h"


@interface XZMPublishViewController ()
{
    AppDelegate *myDelegate;
    
}
@property (nonatomic, weak)UIImageView *imageView;

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
    self.title = @"秀";
    
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

                        //进入秀的页面
                        ShowViewController *show = [[ShowViewController alloc]init];
                        
                        [self.navigationController pushViewController:show animated:YES];
                
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
    NSArray *titles = @[@"秀逼格", @"发话题"];
    
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

