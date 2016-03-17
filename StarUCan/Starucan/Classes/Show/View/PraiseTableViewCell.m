//
//  PraiseTableViewCell.m
//  Starucan
//
//  Created by vgool on 16/2/22.
//  Copyright © 2016年 vgool. All rights reserved.
//

#import "PraiseTableViewCell.h"

@implementation PraiseTableViewCell

- (void)awakeFromNib {
    // Initialization code
}
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _commentButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
        
        _commentLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
        
        _commentLabel.text = @"评论";
        
        _commentLabel.font = [UIFont systemFontOfSize:14];
        
        _commentLabel.textAlignment = NSTextAlignmentCenter;
        
        _commentLabel.textColor = [UIColor grayColor];
        
        [_commentButton addSubview:_commentLabel];

        [self.contentView addSubview:_commentButton];
        
        _praiseButton = [[UIButton alloc]initWithFrame:CGRectMake(100, 0, 100, 44)];
        
        _praiseLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
        
        _praiseLabel.text = @"赞";
        
        _praiseLabel.font = [UIFont systemFontOfSize:14];
        
        _praiseLabel.textAlignment = NSTextAlignmentCenter;
        
        _praiseLabel.textColor = [UIColor grayColor];
        
        [_praiseButton addSubview:_praiseLabel];
        
        
        [self.contentView addSubview:_praiseButton];
        
        
        
        _arrowImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 44, 100, 2)];
        
        _arrowImg.backgroundColor = [UIColor redColor];
        
        [self.contentView addSubview:_arrowImg];
        
    }
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
