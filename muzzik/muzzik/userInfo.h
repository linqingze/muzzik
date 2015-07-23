//
//  userInfo.h
//  ShopUpUp
//
//  Created by kevin's mac on 14-8-1.
//  Copyright (c) 2014年 IOS. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface userInfo : NSObject
@property (nonatomic,retain) muzzik *poMuzzik;
@property (nonatomic,copy) NSString *token;
@property (nonatomic,copy) NSString *uid;
@property (nonatomic,copy) NSString *avatar;
@property (nonatomic,copy) NSString *gender;
@property (nonatomic,assign) BOOL blocked;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *deviceToken;
@property (nonatomic,copy) NSString *clientId;
@property (nonatomic,assign) BOOL WeChatInstalled;
@property (nonatomic,assign) BOOL QQInstalled;
@property (nonatomic,retain) NSMutableDictionary *playList;
@property (nonatomic,assign) BOOL checkSquare;
@property (nonatomic,assign) BOOL checkOwn;
@property (nonatomic,assign) BOOL checkFollow;
@property (nonatomic,assign) BOOL checkMove;
@property (nonatomic,assign) BOOL checkSuggest;
@property (nonatomic,assign) BOOL checkTemp;
@property (nonatomic,retain) UIImage *userHeadThumb;
@property (nonatomic,copy) NSString *suggestTitle;
@property (nonatomic,assign) int poType;
+(userInfo *) shareClass;
+(void)checkLoginWithVC:(UIViewController *)vc;
@end
