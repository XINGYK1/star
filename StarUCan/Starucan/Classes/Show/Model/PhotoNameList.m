//
//  PhotoNameList.m
//  Starucan
//
//  Created by vgool on 16/3/11.
//  Copyright © 2016年 vgool. All rights reserved.
//

#import "PhotoNameList.h"

@implementation PhotoNameList

+(instancetype)shareInstance{

    static PhotoNameList *photoNameList;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        photoNameList = [[PhotoNameList alloc]init];
        
    });
    
    return photoNameList;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    
    return [self shareInstance];
    
}
@end
