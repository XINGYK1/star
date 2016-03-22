//
//  AttentionCollectionViewCell.m
//  Starucan
//
//  Created by vgool on 16/1/11.
//  Copyright © 2016年 vgool. All rights reserved.
//

#import "AttentionCollectionViewCell.h"
#import "UIImageView+WebCache.h"
@implementation AttentionCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupSubViews];
    }
    return self;
}
- (void)setupSubViews
{
    
    //推荐用户头像
    _collectionImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,(YTHScreenWidth-70)/3, 120)];
   
    NSURL * url = [[NSURL alloc]initWithString:@"http://img10.3lian.com/show2013/03/37/24.jpg"];
    
    
    
    [_collectionImage sd_setImageWithURL:url];
    [self.contentView addSubview:_collectionImage];
    
    //推荐用户姓名
     _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 120, (YTHScreenWidth-70)/3, 30)];
    //_labelName.backgroundColor = [UIColor redColor];
    _nameLabel.text = @"某某某";
    _nameLabel.numberOfLines = 1;
    _nameLabel.textColor = [UIColor grayColor];
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    //_labelName.backgroundColor = [UIColor yellowColor];
    _nameLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:_nameLabel];
    
    //推荐用户性别
    _sexIV = [[UIImageView alloc]initWithFrame:CGRectMake((YTHScreenWidth-70)/3, 120,(YTHScreenWidth-70)/3, 30)];
    
    [_sexIV sd_setImageWithURL:url];
    
    [self.contentView addSubview:_sexIV];
    
    //推荐用户大学
    _universityLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_nameLabel.frame),(YTHScreenWidth-60)/3, 25 )];
    _universityLabel.text = @"北京大学";
    _universityLabel.textAlignment =NSTextAlignmentCenter;
    _universityLabel.font = [UIFont systemFontOfSize:14];
  //  _uniserLabel.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:_universityLabel];
  
    
    //打钩按钮
    _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _selectButton.frame = CGRectMake(90, 0, 20, 20);
    _selectButton.selected = YES;
    [_selectButton setImage:[UIImage imageNamed:@"RadioSelected"] forState:UIControlStateSelected];
    [_selectButton setImage:[UIImage imageNamed:@"RadioUnselected"] forState:UIControlStateNormal];
    //_selectButton.backgroundColor = [UIColor redColor];
    _selectButton.layer.borderColor = YTHColor(200, 200, 200).CGColor;
    [_selectButton.layer setMasksToBounds:YES];
    [_selectButton.layer setCornerRadius:10];
    _selectButton.layer.borderWidth = 1;
    [_selectButton addTarget:self action:@selector(buttonAttion:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_selectButton];
    
    [self.contentView bringSubviewToFront:_selectButton];
    
}


-(void)setAttentionModel:(attenModel *)attentionModel
{
    
    _attentionModel = attentionModel;
   
    [_collectionImage sd_setImageWithURL:[NSURL URLWithString:attentionModel.avatar]];
    
    _nameLabel.text= attentionModel.name;

}
-(void)buttonAttion:(UIButton *)btn
{
    btn.selected = !btn.selected;
    if (btn.selected) {
         [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectedButtonClicked" object:nil userInfo:nil];
    }
   
    
}
@end
