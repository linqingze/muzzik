//
//  AppDelegate.h
//  muzzik
//
//  Created by 林清泽 on 15/3/7.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"
#import "WeiboSDK.h"
#import "muzzikTrendController.h"
#import "Reachability.h"
#import "LoginViewController.h"
typedef enum {
    SdkStatusStoped,
    SdkStatusStarting,
    SdkStatusStarted
} SdkStatus;


@interface AppDelegate : UIResponder <UIApplicationDelegate,WeiboSDKDelegate,WXApiDelegate,sendMsgToWeChatViewDelegate>{
     NSString *_deviceToken;
}
@property (nonatomic) muzzikTrendController *viewcontroller;
@property (nonatomic) LoginViewController *loginVC;
@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSString *wbtoken;
@property (strong, nonatomic) NSString *wbCurrentUserID;
@property (retain, nonatomic) NSString *appKey;
@property (retain, nonatomic) NSString *appSecret;
@property (retain, nonatomic) NSString *appID;
@property (retain, nonatomic) NSString *clientId;
@property (assign, nonatomic) SdkStatus sdkStatus;

@property (assign, nonatomic) int lastPayloadIndex;



-(void) downLoadLyricByMusic:(music *)music;
- (void) sendImageContent:(UIImage *)image;
@end

