//
//  ShowVedioViewController.m
//  Starucan
//
//  Created by vgool on 16/3/14.
//  Copyright © 2016年 vgool. All rights reserved.
//

#import "ShowVedioViewController.h"

@interface ShowVedioViewController ()


@end

@implementation ShowVedioViewController



-(PlayerVIew *)pView{
    
    if (!_pView) {
        
        _pView = [[PlayerVIew alloc]initWithFrame:self.view.bounds];
        
        _pView.backgroundColor = [UIColor redColor];
        
    }
    
    return _pView;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.view addSubview:self.pView];
    
    self.playerItem = [AVPlayerItem playerItemWithURL:self.videoURL];
    
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    self.player.volume = 1.0;
    
    self.pView.myPlayer = _player;

}

//观察方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            
            [self.player play];
        
        }
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
