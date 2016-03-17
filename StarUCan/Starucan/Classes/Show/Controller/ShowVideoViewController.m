//
//  ShowVedioViewController.m
//  Starucan
//
//  Created by vgool on 16/3/14.
//  Copyright © 2016年 vgool. All rights reserved.
//

#import "ShowVideoViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "WMPlayer.h"


@interface ShowVideoViewController ()

@property(nonatomic,strong)UIButton *mediaButton;

@end

@implementation ShowVideoViewController

{
    
    MPMoviePlayerController *_MoviePlayer;
    
    WMPlayer *_wmPlayer;
    
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


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.mediaButton];
    
    
    _MoviePlayer = [[MPMoviePlayerController alloc]initWithContentURL:[NSURL fileURLWithPath:self.vedioURL]];
    
    [_MoviePlayer prepareToPlay];
    
    _MoviePlayer.shouldAutoplay=YES;
    
    //[_MoviePlayer setControlStyle:MPMovieControlStyleDefault];
    
    [_MoviePlayer setFullscreen:YES];
    
    [_MoviePlayer.view setFrame:self.view.bounds];
    
    //_wmPlayer = [[WMPlayer alloc]initWithFrame:self.view.bounds videoURLStr:self.vedioURL];
    
    
}

-(void)buttonClicked{
    
//    [_wmPlayer.player play];
//    
//    [self.view addSubview:_wmPlayer];

    [_MoviePlayer play];
    
    [self.view addSubview:_MoviePlayer.view];//设置写在添加之后   // 这里是addSubView
    
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
