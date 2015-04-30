//
//  MuzzikObject.h
//  muzzik
//
//  Created by muzzik on 15/4/27.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MuzzikObject : NSObject
@property (nonatomic,retain) music *music;
@property (nonatomic,copy) NSString *message;
@property (nonatomic,copy) NSString *imageKey;
@property (nonatomic,retain)NSMutableArray *lyricArray;
@property (nonatomic,assign) BOOL isPrivate;
+(MuzzikObject *) shareClass;
@end
