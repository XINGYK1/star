//
//  Z3DScrollView.h
//  Starucan
//
//  Created by 聚能创世 on 16/3/15.
//  Copyright © 2016年 vgool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Z3DScrollView : UIScrollView


@property (nonatomic) CGFloat angleRatio;

@property (nonatomic) CGFloat rotationX;
@property (nonatomic) CGFloat rotationY;
@property (nonatomic) CGFloat rotationZ;

@property (nonatomic) CGFloat translateX;
@property (nonatomic) CGFloat translateY;

- (NSUInteger)currentPage;

- (void)loadNextPage:(BOOL)animated;
- (void)loadPreviousPage:(BOOL)animated;
- (void)loadPageIndex:(NSUInteger)index animated:(BOOL)animated;


@end
