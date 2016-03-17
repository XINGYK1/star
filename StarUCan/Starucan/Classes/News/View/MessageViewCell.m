//
//  MessageViewCell.m
//  Starucan
//
//  Created by vgool on 16/3/11.
//  Copyright © 2016年 vgool. All rights reserved.
//

#import "MessageViewCell.h"
#import "Masonry.h"

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

@implementation MessageViewCell

{
    UIImageView *_imageView;
    
    UILabel *_titleLabel;
    
    UILabel *_messageLabel;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        [self createSubViews];
    }
    
    return self;
}

-(void)createSubViews{
    
    //创建子视图
    
    _imageView = [[UIImageView alloc]init];
    
    [self.contentView addSubview:_imageView];
    
    _titleLabel = [[UILabel alloc]init];
    
    [self.contentView addSubview:_titleLabel];
    
    _messageLabel = [[UILabel alloc]init];
    
    [self.contentView addSubview:_messageLabel];
    
    WS(ws);
    
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
      
        make.top.equalTo(ws.mas_top).with.offset(8);
        make.left.equalTo(ws.mas_left).with.offset(24);
        make.right.equalTo(_titleLabel.mas_left).with.offset(-24);
        make.bottom.equalTo(ws.mas_bottom).with.offset(-8);
        
        
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(ws.mas_centerY);
        
        make.left.equalTo(_imageView.mas_right).with.offset(24);
        
        make.height.equalTo(@14);
        
        make.width.equalTo(@100);
        
    }];
    
    [_messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        
    }];
    
    
}

-(void)relodDataWithtitle:(NSString *)title andImage:(NSString *)imageName{
    
    _imageView.image = [UIImage imageNamed:imageName];
    
    _titleLabel.text=title;
    
}

@end
