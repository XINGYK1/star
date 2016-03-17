//
//  Z3DScrollView.m
//  Starucan
//
//  Created by 聚能创世 on 16/3/15.
//  Copyright © 2016年 vgool. All rights reserved.
//

#import "Z3DScrollView.h"


#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@implementation Z3DScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(!self){
        return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(!self){
        return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (void)commonInit
{
    self.pagingEnabled = YES;
    self.clipsToBounds = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    
}

- (void)setEffect{
    
    self.angleRatio = .5;
    
    self.rotationX = -1.;
    self.rotationY = 0.;
    self.rotationZ = 0.;
    
    self.translateX = .25;
    self.translateY = 0.;
    
    [self setNeedsDisplay];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat contentOffsetX = self.contentOffset.x;
    CGFloat contentOffsetY = self.contentOffset.y;
    
    for(UIView *view in self.subviews){
        CATransform3D t1 = view.layer.transform; // Hack for avoid visual bug
        view.layer.transform = CATransform3DIdentity;
        
        CGFloat distanceFromCenterX = view.frame.origin.x - contentOffsetX;
        
        
        view.layer.transform = t1;
        
        distanceFromCenterX = distanceFromCenterX * 100. / CGRectGetWidth(self.frame);
        
        
        CGFloat angle = distanceFromCenterX * self.angleRatio;
        
        CGFloat offset = distanceFromCenterX;
        CGFloat translateX = (CGRectGetWidth(self.frame) * self.translateX) * offset / 100.;
        CGFloat translateY = (CGRectGetWidth(self.frame) * self.translateY) * abs(offset) / 100.;
        CATransform3D t = CATransform3DMakeTranslation(translateX, translateY, 0.);
        
        view.layer.transform = CATransform3DRotate(t, DEGREES_TO_RADIANS(angle), self.rotationX, self.rotationY, self.rotationZ);
    }
}

- (NSUInteger)currentPage               //当前页
{
    CGFloat pageWidth = self.frame.size.width;
    float fractionalPage = self.contentOffset.x / pageWidth;
    return lround(fractionalPage);
}

- (void)loadNextPage:(BOOL)animated     //下一页
{
    [self loadPageIndex:self.currentPage + 1 animated:animated];
}

- (void)loadPreviousPage:(BOOL)animated //上一页
{
    [self loadPageIndex:self.currentPage - 1 animated:animated];
}

- (void)loadPageIndex:(NSUInteger)index animated:(BOOL)animated
{
    CGRect frame = self.frame;
    frame.origin.x = frame.size.width * index;
    frame.origin.y = 0;
    
    [self scrollRectToVisible:frame animated:animated];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
