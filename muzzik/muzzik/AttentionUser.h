//
//  AttentionUser.h
//  muzzik
//
//  Created by muzzik on 15/5/5.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AttentionUser : NSObject
@property (nonatomic,copy) NSString *uid;
@property (nonatomic,copy) NSString *avatar;
@property (nonatomic,copy) NSString *descrip;
@property (nonatomic,copy) NSString *gender;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,assign) BOOL isFollow;
@property (nonatomic,assign) BOOL isFans;

-(NSMutableArray*)makeAttentionUserByArray:(NSMutableArray *)array;
@end
