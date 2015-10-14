//
//  AppDelegate.h
//  muzzik
//
//  Created by 林清泽 on 15/3/7.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"
#import "GexinSdk.h"
#import "WeiboSDK.h"
#import "Reachability.h"
typedef enum {
    SdkStatusStoped,
    SdkStatusStarting,
    SdkStatusStarted
} SdkStatus;

@class RDVTabBarController,FeedViewController,NotificationCenterViewController,UserHomePage,TopicVC;
@interface AppDelegate : UIResponder <UIApplicationDelegate,GexinSdkDelegate,WeiboSDKDelegate,WXApiDelegate>{
     NSString *_deviceToken;
}
@property (strong, nonatomic) RDVTabBarController *tabviewController;
@property (strong, nonatomic) FeedViewController *feedVC;
@property (strong, nonatomic) NotificationCenterViewController *notifyVC;
@property (strong, nonatomic) UserHomePage *userhomeVC;
@property (strong, nonatomic) TopicVC *topicVC;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) GexinSdk *gexinPusher;
@property (copy, nonatomic) NSString *wbtoken;
@property (copy, nonatomic) NSString *wbCurrentUserID;
@property (copy, nonatomic) NSString *appKey;
@property (copy, nonatomic) NSString *appSecret;
@property (copy, nonatomic) NSString *appID;
@property (copy, nonatomic) NSString *clientId;
@property (assign, nonatomic) SdkStatus sdkStatus;

@property (assign, nonatomic) int lastPayloadIndex;
@property (retain, nonatomic) NSString *payloadId;

- (void)startSdkWith:(NSString *)appID appKey:(NSString *)appKey appSecret:(NSString *)appSecret;
- (void)stopSdk;

- (void)setDeviceToken:(NSString *)aToken;
- (BOOL)setTags:(NSArray *)aTag error:(NSError **)error;
- (NSString *)sendMessage:(NSData *)body error:(NSError **)error;

- (void)bindAlias:(NSString *)aAlias;
- (void)unbindAlias:(NSString *)aAlias;
//-(void) downLoadLyricByMusic:(music *)music;
- (void) sendImageContent:(UIImage *)image;
-(void) sendMusicContentByMuzzik:(muzzik*)localMuzzik scen:(int)scene image:(UIImage *)image;
- (void)sendAuthRequestByVC:(UIViewController *)vc;
-(void)weCahtsendMusicContentByscen:(int)scene;
@end

