//
//  userInfo.h
//  ShopUpUp
//
//  Created by kevin's mac on 14-8-1.
//  Copyright (c) 2014年 IOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface userInfo : NSObject
@property (nonatomic,copy) NSString *token;
@property (nonatomic,copy) NSString *uid;
@property (nonatomic,copy) NSString *avatar;
@property (nonatomic,copy) NSString *gender;
@property (nonatomic) BOOL blocked;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *deviceToken;
@property (nonatomic,copy) NSString *clientId;
+(userInfo *) shareClass;
+(void)checkLoginWithVC:(UIViewController *)vc;
@end
