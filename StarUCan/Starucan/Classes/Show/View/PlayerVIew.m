//
//  PlayerVIew.m
//  Starucan
//
//  Created by vgool on 16/3/17.
//  Copyright © 2016年 vgool. All rights reserved.
//

#import "PlayerVIew.h"

@implementation PlayerVIew

-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        
        
    }
    return  self;
}

+(Class)layerClass{
    
    return [AVPlayerLayer class];
    
}

-(AVPlayer *)myPlayer{
    
    return [(AVPlayerLayer *)[self layer] player];
    
}

-(void)setMyPlayer:(AVPlayer *)myPlayer{
    
    [(AVPlayerLayer *)[self layer] setPlayer:myPlayer];
    
}

@end
