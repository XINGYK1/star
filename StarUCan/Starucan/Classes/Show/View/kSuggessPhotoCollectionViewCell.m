//
//  kSuggessPhotoCollectionViewCell.m
//  vgool
//
//  Created by Lonely丶晏袁杰 on 15/12/18.
//  Copyright © 2015年 chenyanming. All rights reserved.
//

#import "kSuggessPhotoCollectionViewCell.h"
#import "SuggessViewController.h"
#import "UIImageView+WebCache.h"
@implementation kSuggessPhotoCollectionViewCell
{
    UIImageView *_kPhotoImageView;
    UIButton *_kDeleteButton;
    UIImage *_kDeleteImage;
}
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _kPhotoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _kPhotoImageView.contentMode = UIViewContentModeScaleAspectFill;
        _kPhotoImageView.layer.masksToBounds = YES;
        [self addSubview:_kPhotoImageView];
                _kDeleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
                _kDeleteButton.frame = CGRectMake(34, 0, 20, 20);
                [_kDeleteButton setImage:[UIImage imageNamed:@"deletepic"] forState:UIControlStateNormal];
                _kDeleteButton.imageEdgeInsets = UIEdgeInsetsMake(0, 8, 8, 0);
                [_kDeleteButton addTarget:self action:@selector(deleteButtonClick) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:_kDeleteButton];
    }
    return self;
}
-(void)deleteButtonClick{
    if (_kSuggessPhotoCollectionViewCellDelegate) {
        [_kSuggessPhotoCollectionViewCellDelegate deletePhotoImage:_kDeleteImage];
    }
}
-(void)setPhotoImageLayer:(BOOL)layer{
    if (layer) {
        _kPhotoImageView.layer.borderWidth = 1;//设置边框的宽度，当然可以不要
        _kPhotoImageView.layer.borderColor = [[UIColor redColor] CGColor];//设置边框的颜色
    }else{
        _kPhotoImageView.layer.borderWidth = 0;//设置边框的宽度，当然可以不要
        _kPhotoImageView.layer.borderColor = [[UIColor redColor] CGColor];//设置边框的颜色
    }
}
-(void)setPhotoImage:(NSString *)image andDeleteBtnHidden:(BOOL)hidden{
    //_kDeleteImage = image;
    //_kPhotoImageView.image = [UIImage imageNamed:image];
    [_kPhotoImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",image]]];
    _kDeleteButton.hidden = hidden;
}
-(void)setImage:(UIImage *)image andDeleteBtnHidden:(BOOL)hidden
{
    _kDeleteImage = image;
    _kPhotoImageView.image = image;
    _kDeleteButton.hidden = hidden;
}
@end
