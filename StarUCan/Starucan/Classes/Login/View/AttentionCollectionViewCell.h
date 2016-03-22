//
//  AttentionCollectionViewCell.h
//  Starucan
//
//  Created by vgool on 16/1/11.
//  Copyright © 2016年 vgool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "attenModel.h"
@interface AttentionCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong)UIImageView * collectionImage;

@property (nonatomic,strong)UILabel * nameLabel;//同户名

@property (nonatomic,strong)UIImageView *sexIV;//性别

@property (nonatomic,strong)UILabel *university;//大学

@property (nonatomic,strong)UILabel * universityLabel;

@property (nonatomic,strong)UIButton * selectButton;

@property (nonatomic,strong)attenModel *attentionModel;
@end
