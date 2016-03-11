//
//  TopicModel.h
//  Starucan
//
//  Created by 聚能创世 on 16/3/11.
//  Copyright © 2016年 vgool. All rights reserved.
//

#import "BaseModel.h"

@interface TopicModel : BaseModel
@property (nonatomic,copy) NSString     *uuid;//话题ID
@property (nonatomic,copy) NSString     *userUuid;
@property (nonatomic,copy) NSString     *authorUuid;
@property (nonatomic,copy) NSString     *status;//状态

@property (nonatomic,copy) NSString     *title;//标题
@property (nonatomic,copy) NSString     *content;//内容

@property (nonatomic,copy) NSString     *isCollection;//收藏数
@property (nonatomic,copy) NSString     *isAttention;//关注数
@property (nonatomic,copy) NSString     *participatCount;//点赞数
@property (nonatomic,copy) NSString     *createTime;//发布时间
@property (nonatomic,copy) NSString     *modifyTime;//修改时间



@property (nonatomic,copy) NSDictionary *createUser;
@property (nonatomic,copy) NSString     *name;   //发布人姓名
@property (nonatomic,copy) NSString     *sex;    //发布人性别
@property (nonatomic,copy) NSString     *avatar; //头像



@end
