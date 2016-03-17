//
//  ShowVedioViewController.h
//  Starucan
//
//  Created by vgool on 16/3/14.
//  Copyright © 2016年 vgool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "PlayerVIew.h"
@interface ShowVedioViewController : UIViewController

@property(nonatomic,copy)NSURL *videoURL;

@property(nonatomic,strong)PlayerVIew *pView;

@property (nonatomic ,strong) AVPlayerItem *playerItem;

@property(nonatomic,strong)AVPlayer *player;

@end
