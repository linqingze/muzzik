//
//  muzzik.h
//  muzzik
//
//  Created by muzzik on 15/4/11.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//
#import "user.h"
#import "music.h"
#import <Foundation/Foundation.h>

@interface muzzik : NSObject
@property (nonatomic,copy) NSString *muzzik_id;
@property (nonatomic) NSString *date;
@property (nonatomic) user *user;
@property (nonatomic) NSString *message;
@property (nonatomic) NSString *image;
@property (nonatomic) NSArray *tpoics;
@property (nonatomic) NSArray *users;
@property (nonatomic) music *music;
@property (nonatomic) NSString *type;
@property (nonatomic) BOOL onlytext;
@property (nonatomic) NSString *reposts;
@property (nonatomic) NSString *shares;
@property (nonatomic) NSString *comments;
@property (nonatomic) NSString *color;
@property (nonatomic) NSString *moveds;
@property (nonatomic) BOOL isprivate;
@property (nonatomic) NSString *plays;
-(NSMutableArray*)makeMuzziksByarray:(NSMutableArray *)array;
@end
