//
//  ShowVedioViewController.m
//  Starucan
//
//  Created by vgool on 16/3/14.
//  Copyright © 2016年 vgool. All rights reserved.
//

#import "ShowVedioViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>

@interface ShowVedioViewController ()

@property(nonatomic,strong)UIButton *mediaButton;

@end

@implementation ShowVedioViewController

{
    
    MPMoviePlayerController *_MoviePlayer;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //NSLog(@"%@",self.vedioURL);
    
    [self.view addSubview:self.mediaButton];
    
    _MoviePlayer = [[MPMoviePlayerController alloc]initWithContentURL:self.vedioURL];
    
    
    
}


-(UIButton *)mediaButton{
    
    if (_mediaButton ==nil) {
        
        _mediaButton = [[UIButton alloc]initWithFrame:CGRectMake(150, 50, 100, 40)];
        
        [_mediaButton setTitle:@"播放视频" forState:UIControlStateNormal];
        
        [_mediaButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [_mediaButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        
        [_mediaButton addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _mediaButton;
}

-(void)buttonClicked{
    
    //播放按钮的点击方法
    
    [_MoviePlayer play];
    
    
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
