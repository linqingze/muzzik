//
//  AppDelegate.m
//  muzzik
//
//  Created by 林清泽 on 15/3/7.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//
#import <AssetsLibrary/AssetsLibrary.h>
#import "WXApi.h"
#import "WeiboSDK.h"
#import "AppDelegate.h"
#import "muzzikTrendController.h"
#import "appConfiguration.h"
#import "musicPlayer.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "ASIHTTPRequest.h"
#import "userInfo.h"
#import "RootViewController.h"
#import "settingSystemVC.h"
#import "UIImageView+WebCache.m"
#import "NotificationVC.h"
#import "UIImageView+WebCache.h"
@interface AppDelegate ()

@end

@implementation AppDelegate
- (void)registerRemoteNotification
{
#ifdef __IPHONE_8_0
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        
        UIUserNotificationSettings *uns = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound) categories:nil];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:uns];
    } else {
        UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeBadge);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
    }
#else
    UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeBadge);
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
#endif
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [WXApi registerApp:ID_WeiChat_APP];
    [WeiboSDK enableDebugMode:NO];
    [WeiboSDK registerApp:Key_WeiBo];
    [self startSdkWith:kAppId appKey:kAppKey appSecret:kAppSecret];
    [MobClick startWithAppkey:UMAPPKEY reportPolicy:BATCH channelId:@"App Store"];
//    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
//    [MobClick setAppVersion:version];
     userInfo *user = [userInfo shareClass];
    NSDictionary * dic = [MuzzikItem messageFromLocal];
    if (dic) {
       
        user.uid = [dic objectForKey:@"_id"];
        user.token = [dic objectForKey:@"token"];
        user.gender = [dic objectForKey:@"gender"];
        user.avatar = [dic objectForKey:@"avatar"];
        user.name = [dic objectForKey:@"name"];
        
    }
    if ([user.token length]==0) {
        user.loginType = Is_Not_Logined;
    }else{
        user.loginType = Is_Logined;
    }
    
    [self loadData];
    
    [self registerRemoteNotification];
    [self checkChannel];
    NSDictionary* message = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (message) {
        NSString *payloadMsg = [message objectForKey:@"payload"];
        NSString *record = [NSString stringWithFormat:@"[APN]%@, %@", [NSDate date], payloadMsg];
        NSLog(@"%@%@      didFinishLaunchingWithOptions",payloadMsg,record);
    }
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    
    
    
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [ASIHTTPRequest clearSession];
    
    RootViewController *rootvc = [[RootViewController alloc] init];
    UINavigationController *nac = [[UINavigationController alloc] initWithRootViewController:rootvc];

    [self.window setRootViewController:nac];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    if (![[MuzzikItem getStringForKey:@"Muzzik_Create_Album"] isEqualToString:@"yes"]) {
        [self createAlbum];
    }
    
    
    return YES;
}

-(void)GexinSdkDidReceivePayload:(NSString *)payloadId fromApplication:(NSString *)appId{
    _payloadId =payloadId;
    NSData *data = [_gexinPusher retrivePayloadById:payloadId];
    NSString *payloadMsg = nil;
    if (data) {
        UINavigationController *nac = (UINavigationController *)self.window.rootViewController;
        for (UIViewController *vc in nac.viewControllers) {
            if ([vc isKindOfClass:[RootViewController class]]){
                RootViewController *root = (RootViewController *)vc;
                [root getMessage];
                
            }
    }
        payloadMsg = [[NSString alloc] initWithBytes:data.bytes
                                              length:data.length
                                            encoding:NSUTF8StringEncoding];
    NSLog(@"payload:%@",[payloadMsg stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
    }
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self stopSdk];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [Globle shareGloble].isApplicationEnterBackground = YES;
    if([Globle shareGloble].isPlaying){
        [[NSNotificationCenter defaultCenter] postNotificationName:String_SetSongInformationNotification object:nil userInfo:nil];
    }
    
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event

{
    NSString * shakeSwitch = [MuzzikItem getStringForKey:@"User_shakeActionSwitch"];
    if (![shakeSwitch isEqualToString:@"close"]) {
        musicPlayer *player = [musicPlayer shareClass];
        //摇动结束
        if (event.subtype == UIEventSubtypeMotionShake && [player.MusicArray count]>0) {
            [player playNext];
        }
    }
    
    
}
//响应远程音乐播放控制消息
- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        musicPlayer * player = [musicPlayer shareClass];
        NSLog(@"");
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlPause:
                [player play];
                NSLog(@"RemoteControlEvents: pause");
                break;
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [player play];
                NSLog(@"RemoteControlEvents: pause");
                break;
            case UIEventSubtypeRemoteControlPlay:
                [player play];
                NSLog(@"RemoteControlEvents: play");
                [[NSNotificationCenter defaultCenter] postNotificationName:String_SetSongInformationNotification object:nil userInfo:nil];
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [player playNext];
                NSLog(@"RemoteControlEvents: playModeNext");
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                [player PlayPre];
                NSLog(@"RemoteControlEvents: playPrev");
                break;
            default:
                break;
        }
    }
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
#if __QQAPI_ENABLE__
    [QQApiInterface handleOpenURL:url delegate:(id)[QQAPIDemoEntry class]];
#endif
    if ([WeiboSDK handleOpenURL:url delegate:self]) {
        return [WeiboSDK handleOpenURL:url delegate:self];
    }else if([TencentOAuth HandleOpenURL:url]){
         return [TencentOAuth HandleOpenURL:url];
    }
    else if( [WXApi handleOpenURL:url delegate:self])
    {
        return  [WXApi handleOpenURL:url delegate:self];
    }
    return [WeiboSDK handleOpenURL:url delegate:self];
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    if ([WeiboSDK handleOpenURL:url delegate:self]) {
        return [WeiboSDK handleOpenURL:url delegate:self];
    }else if([TencentOAuth HandleOpenURL:url]){
        return [TencentOAuth HandleOpenURL:url];
    }
    else if( [WXApi handleOpenURL:url delegate:self])
    {
        return  [WXApi handleOpenURL:url delegate:self];
    }

    return [WeiboSDK handleOpenURL:url delegate:self];
}





-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    // [4-EXT]:处理APN
    
    if ([[userInfo allKeys] containsObject:@"aps"] && [[[userInfo objectForKey:@"aps"] allKeys] containsObject:@"alert"] && [[userInfo objectForKey:@"aps"] objectForKey:@"alert"] && [[[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] allKeys] containsObject:@"body"]) {
        
        NSDictionary *aps = [userInfo objectForKey:@"aps"];
        
        NSString *record = [NSString stringWithFormat:@"[APN]%@, %@", [NSDate date], aps];
        NSLog(@"%@       didReceiveRemoteNotification",record);
        NSString *Message = [[aps objectForKey:@"alert" ] objectForKey:@"body"];
        NSArray *array = [Message componentsSeparatedByString:@" "];
        if ([array count]>1 ) {
            NSString *alter = [array objectAtIndex:1];
            if ([alter isEqualToString:@"评论了你"]) {
                [MuzzikItem showNewNotifyByText:Message];
            }else if([alter isEqualToString:@"提到了你"]){
                [MuzzikItem showNewNotifyByText:Message];
            }
        }
    }
    
    UINavigationController *nac = (UINavigationController *)self.window.rootViewController;
    for (UIViewController *vc in nac.viewControllers) {
        if ([vc isKindOfClass:[RootViewController class]]){
            RootViewController *root = (RootViewController *)vc;
            NSLog(@"launch:   %d",root.isLaunched);
            if ((root.isLaunched &&![Globle shareGloble].isApplicationEnterBackground) ||[[nac.viewControllers lastObject] isKindOfClass:[NotificationVC class]]) {
                [root getMessage];
            }else{
                BOOL InNotify= NO;
                for (UIViewController *vc in nac.viewControllers) {
                    if ([vc isKindOfClass:[NotificationVC class]]) {
                        [nac popToViewController:vc animated:YES];
                        InNotify = YES;
                        break;
                    }
                }
                if (!InNotify) {
                    UINavigationController *nac = (UINavigationController *)self.window.rootViewController;
                    NotificationVC *notifyvc = [[NotificationVC alloc] init];
                    [nac pushViewController:notifyvc animated:YES];
                }
                
            }
            
        }
    }

 
    
    completionHandler(UIBackgroundFetchResultNewData);

}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    _deviceToken = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"deviceToken:%@", _deviceToken);
    userInfo *user = [userInfo shareClass];
    user.deviceToken =_deviceToken;
    if ([user.token length]>0) {
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Set_Notify]]];
        [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:user.deviceToken,@"deviceToken",@"APN",@"type", nil] Method:PostMethod auth:YES];
        __weak ASIHTTPRequest *weakreq = request;
        [request setCompletionBlock :^{
            NSLog(@"%@",[weakreq responseString]);
            NSLog(@"%d",[weakreq responseStatusCode]);
            if ([weakreq responseStatusCode] == 200) {
                
                NSLog(@"register ok");
            }
            else{
                //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
            }
        }];
        [request setFailedBlock:^{
            NSLog(@"%@",[weakreq error]);
        }];
        [request startAsynchronous];
    }
    // [3]:向个推服务器注册deviceToken
    if (_gexinPusher) {
        [_gexinPusher registerDeviceToken:_deviceToken];
    }
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
    // 处理推送消息
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    // [4-EXT]:处理APN
    NSString *payloadMsg = [userInfo objectForKey:@"payload"];
    NSString *record = [NSString stringWithFormat:@"[APN]%@, %@", [NSDate date], payloadMsg];
    NSLog(@"receive:%@",record);
    
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    NSLog(@"Regist fail%@",error);
    if (_gexinPusher) {
        [_gexinPusher registerDeviceToken:@""];
    }
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_New_notify_Now]]];
    [request addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic && [[dic allKeys] containsObject:@"result"] && [[dic objectForKey:@"result"] integerValue]>0) {
            UINavigationController *nac = (UINavigationController *)self.window.rootViewController;
            for (UIViewController *vc in nac.viewControllers) {
                if ([vc isKindOfClass:[RootViewController class]]) {
                    RootViewController *rootvc = (RootViewController*)vc;
                    [rootvc getMessage];
                    [MuzzikItem showNewNotifyByText:[NSString stringWithFormat:@"您有%d条新消息",[[dic objectForKey:@"result"] intValue]]];
                    break;
                }
            }
        }
    }];
    [request startAsynchronous];
    
    [self startSdkWith:kAppId appKey:kAppKey appSecret:kAppSecret];
    [Globle shareGloble].isApplicationEnterBackground = NO;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"end");
    [ASIHTTPRequest clearSession];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma  -mark 个推Delegate

- (void)startSdkWith:(NSString *)appID appKey:(NSString *)appKey appSecret:(NSString *)appSecret
{
    if (!_gexinPusher) {
        _sdkStatus = SdkStatusStoped;
        
        self.appID = appID;
        self.appKey = appKey;
        self.appSecret = appSecret;
        
        _clientId = nil;
        
        NSError *err = nil;
        _gexinPusher = [GexinSdk createSdkWithAppId:_appID
                                             appKey:_appKey
                                          appSecret:_appSecret
                                         appVersion:@"0.0.0"
                                           delegate:self
                                              error:&err];
        if (!_gexinPusher) {
            NSLog(@"%@",err);
        } else {
            _sdkStatus = SdkStatusStarting;
        }
        
    }
}

- (void)stopSdk
{
    if (_gexinPusher) {
        [_gexinPusher destroy];
        _gexinPusher = nil;
        
        _sdkStatus = SdkStatusStoped;
        
        _clientId = nil;
        
    }
}
- (BOOL)checkSdkInstance
{
    if (!_gexinPusher) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:@"SDK未启动" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
        return NO;
    }
    return YES;
}

- (void)setDeviceToken:(NSString *)aToken
{
    if (![self checkSdkInstance]) {
        return;
    }
    
    [_gexinPusher registerDeviceToken:aToken];
}

- (BOOL)setTags:(NSArray *)aTags error:(NSError **)error
{
    if (![self checkSdkInstance]) {
        return NO;
    }
    
    return [_gexinPusher setTags:aTags];
}
- (void)GexinSdkDidRegisterClient:(NSString *)clientId{
     _sdkStatus = SdkStatusStarted;
    _clientId = clientId;


}
- (NSString *)sendMessage:(NSData *)body error:(NSError **)error {
    if (![self checkSdkInstance]) {
        return nil;
    }
    
    return [_gexinPusher sendMessage:body error:error];
}

- (void)bindAlias:(NSString *)aAlias {
    if (![self checkSdkInstance]) {
        return;
    }
    
    return [_gexinPusher bindAlias:aAlias];
}

- (void)unbindAlias:(NSString *)aAlias {
    if (![self checkSdkInstance]) {
        return;
    }
    
    return [_gexinPusher unbindAlias:aAlias];
}
#pragma -mark weibo
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
        if ((int)response.statusCode == 0) {
            [MuzzikItem showNotifyOnView:self.window.rootViewController.view text:@"分享成功"];
        }
        else if ((int)response.statusCode == -1) {
            [MuzzikItem showNotifyOnView:self.window.rootViewController.view text:@"取消分享"];
        }else if ((int)response.statusCode == -2) {
            [MuzzikItem showNotifyOnView:self.window.rootViewController.view text:@"分享失败"];
        }
        
        WBSendMessageToWeiboResponse* sendMessageToWeiboResponse = (WBSendMessageToWeiboResponse*)response;
        NSString* accessToken = [sendMessageToWeiboResponse.authResponse accessToken];
        if (accessToken)
        {
            self.wbtoken = accessToken;
        }
        NSString* userID = [sendMessageToWeiboResponse.authResponse userID];
        if (userID) {
            self.wbCurrentUserID = userID;
        }
    }
    else if ([response isKindOfClass:WBAuthorizeResponse.class])
    {

        self.wbtoken = [(WBAuthorizeResponse *)response accessToken];
        self.wbCurrentUserID = [(WBAuthorizeResponse *)response userID];
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
        userInfo *user = [userInfo shareClass];
        [manager GET:[NSString stringWithFormat:@"%@%@%@",BaseURL,URL_WeiBo_AUTH,[(WBAuthorizeResponse *)response accessToken]] parameters:nil success:^(AFHTTPRequestOperation * operation, id responseObject) {
            
            NSLog(@"JSON: %@", responseObject);
            NSDictionary *fileDic = [NSDictionary dictionaryWithObjectsAndKeys:[responseObject objectForKey:@"_id"],@"_id",[responseObject objectForKey:@"token"],@"token",[responseObject objectForKey:@"gender"],@"gender",[responseObject objectForKey:@"avatar"],@"avatar",[responseObject objectForKey:@"name"],@"name", nil];
            [MuzzikItem addMessageToLocal:fileDic];
            if ([[responseObject allKeys] containsObject:@"token"]) {
                user.token = [responseObject objectForKey:@"token"];
            }
            if ([[responseObject allKeys] containsObject:@"avatar"]) {
                user.avatar = [responseObject objectForKey:@"avatar"];
            }
            if ([[responseObject allKeys] containsObject:@"gender"]) {
                user.gender = [responseObject objectForKey:@"gender"];
            }
            if ([[responseObject allKeys] containsObject:@"_id"]) {
                user.uid = [responseObject objectForKey:@"_id"];
            }
            if ([[responseObject allKeys] containsObject:@"blocked"]) {
                user.blocked = [[responseObject objectForKey:@"blocked"] boolValue];
            }
            if ([[responseObject allKeys] containsObject:@"name"]) {
                user.name = [responseObject objectForKey:@"name"];
            }
            if ([[responseObject allKeys] containsObject:@"token"]) {
                user.token = [responseObject objectForKey:@"token"];
            }
            
            AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
            [manager POST:[NSString stringWithFormat:@"%@%@",BaseURL,URL_Set_Notify] parameters:[NSDictionary dictionaryWithObjectsAndKeys:user.deviceToken,@"deviceToken",@"APN",@"type", nil] success:^(AFHTTPRequestOperation * operation, id responseObject) {
                NSLog(@"JSON: %@", responseObject);
                
            } failure:^(AFHTTPRequestOperation *operation, NSError * error) {
                NSLog(@"op: %@    error:%@",operation,error);
                
            }];
            UINavigationController *nac = (UINavigationController *)self.window.rootViewController;
            for (UIViewController *vc in nac.viewControllers) {
                if ([vc isKindOfClass:[settingSystemVC class]]) {
                    settingSystemVC *settingvc = (settingSystemVC*)vc;
                    [settingvc reloadTable];
                    break;
                }
            }
            [nac popViewControllerAnimated:YES];
        } failure:^(AFHTTPRequestOperation *operation, NSError * error) {
            NSLog(@"op: %@    error:%@",operation,error);
            
        }];
        
    }
}

- (void)removeNetWorkChangeNot
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}


#pragma -mark weichat

//- (void)sendAuthRequest
//{
//    SendAuthReq* req = [[[SendAuthReq alloc] init] autorelease];
//    req.scope = @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact"; // @"post_timeline,sns"
//    req.state = @"xxx";
//    req.openID = @"0c806938e2413ce73eef92cc3";
//    
//    [WXApi sendAuthReq:req viewController:self.viewController delegate:self];
//}
- (void)sendAuthRequestByVC:(UIViewController *)vc
{
    SendAuthReq* req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo"; // @"post_timeline,sns"
    req.state = @"123";
    
    [WXApi sendAuthReq:req viewController:vc delegate:self];
    req = nil;
}

-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        if (resp.errCode == 0) {
            [MuzzikItem showNotifyOnViewUpon:self.window.rootViewController.view text:@"分享成功"];
        }
        else if (resp.errCode == -1) {
            [MuzzikItem showNotifyOnViewUpon:self.window.rootViewController.view text:@"分享失败"];
        }else if (resp.errCode == -2) {
            [MuzzikItem showNotifyOnViewUpon:self.window.rootViewController.view text:@"取消分享"];
        }
    }
    else if([resp isKindOfClass:[SendAuthResp class]])
    {
        SendAuthResp *temp = (SendAuthResp*)resp;
        
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
        userInfo *user = [userInfo shareClass];
        [manager GET:[NSString stringWithFormat:@"%@%@",BaseURL,URL_WeiChat_AUTH] parameters:[NSDictionary dictionaryWithObjectsAndKeys:@"json",@"result",temp.code,@"code", nil] success:^(AFHTTPRequestOperation * operation, id responseObject) {
            
            NSLog(@"JSON: %@", responseObject);
            NSDictionary *fileDic = [NSDictionary dictionaryWithObjectsAndKeys:[responseObject objectForKey:@"_id"],@"_id",[responseObject objectForKey:@"token"],@"token",[responseObject objectForKey:@"gender"],@"gender",[responseObject objectForKey:@"avatar"],@"avatar",[responseObject objectForKey:@"name"],@"name", nil];
            [MuzzikItem addMessageToLocal:fileDic];
            if ([[responseObject allKeys] containsObject:@"token"]) {
                user.token = [responseObject objectForKey:@"token"];
            }
            if ([[responseObject allKeys] containsObject:@"avatar"]) {
                user.avatar = [responseObject objectForKey:@"avatar"];
            }
            if ([[responseObject allKeys] containsObject:@"gender"]) {
                user.gender = [responseObject objectForKey:@"gender"];
            }
            if ([[responseObject allKeys] containsObject:@"_id"]) {
                user.uid = [responseObject objectForKey:@"_id"];
            }
            if ([[responseObject allKeys] containsObject:@"blocked"]) {
                user.blocked = [[responseObject objectForKey:@"blocked"] boolValue];
            }
            if ([[responseObject allKeys] containsObject:@"name"]) {
                user.name = [responseObject objectForKey:@"name"];
            }
            if ([[responseObject allKeys] containsObject:@"token"]) {
                user.token = [responseObject objectForKey:@"token"];
            }
            if ([user.token length]>0) {
                AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
                [manager POST:[NSString stringWithFormat:@"%@%@",BaseURL,URL_Set_Notify] parameters:[NSDictionary dictionaryWithObjectsAndKeys:user.deviceToken,@"deviceToken",@"APN",@"type", nil] success:^(AFHTTPRequestOperation * operation, id responseObject) {
                    NSLog(@"JSON: %@", responseObject);
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError * error) {
                    NSLog(@"op: %@    error:%@",operation,error);
                    
                }];
                UINavigationController *nac = (UINavigationController *)self.window.rootViewController;
                for (UIViewController *vc in nac.viewControllers) {
                    if ([vc isKindOfClass:[settingSystemVC class]]) {
                        settingSystemVC *settingvc = (settingSystemVC*)vc;
                        [settingvc reloadTable];
                        break;
                    }
                }
                [nac popViewControllerAnimated:YES];
            }
            
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError * error) {
            NSLog(@"op: %@    error:%@",operation,error);
            
        }];
    }
    else if ([resp isKindOfClass:[AddCardToWXCardPackageResp class]])
    {
        AddCardToWXCardPackageResp* temp = (AddCardToWXCardPackageResp*)resp;
        NSMutableString* cardStr = [[NSMutableString alloc] init];
        for (WXCardItem* cardItem in temp.cardAry) {
            [cardStr appendString:[NSString stringWithFormat:@"cardid:%@ cardext:%@ cardstate:%u\n",cardItem.cardId,cardItem.extMsg,(unsigned int)cardItem.cardState]];
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"add card resp" message:cardStr delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void) sendImageContent:(UIImage *)image
{
    WXMediaMessage *message = [WXMediaMessage message];
    [message setThumbImage:nil];
    
    WXImageObject *ext = [WXImageObject object];
    ext.imageData = UIImageJPEGRepresentation(image, 1);
    message.mediaObject = ext;
    message.mediaTagName = @"Muzzik";
    message.messageExt = @"share Image";
    message.messageAction = @"<action>dotalist</action>";
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneTimeline;
    
    [WXApi sendReq:req];
}
-(void)weCahtsendMusicContentByscen:(int)scene{
    WXWebpageObject *wobject = [WXWebpageObject object];
    wobject.webpageUrl = URL_Muzzik_download;
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = @"一起来用Muzzik 吧";
    message.description = @"听最喜欢的歌，遇见最好的Ta";
    
    [message setThumbImage:[UIImage imageNamed:@"logo"]];
    message.mediaObject = wobject;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    
    [WXApi sendReq:req];
}
-(void) sendMusicContentByMuzzik:(muzzik*)localMuzzik scen:(int)scene image:(UIImage *)image
{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = localMuzzik.music.name;
    message.description = localMuzzik.music.artist;

    [message setThumbImage:image];
    WXMusicObject *ext = [WXMusicObject object];
    ext.musicUrl = [NSString stringWithFormat:@"%@%@",URL_Muzzik_SharePage,localMuzzik.muzzik_id];
    ext.musicDataUrl = [NSString stringWithFormat:@"%@%@",BaseURL_audio,localMuzzik.music.key];
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    
    [WXApi sendReq:req];
}

//#pragma -mark 辅助方法
//-(void) downLoadLyricByMusic:(music *)music{
//    
//}


-(void) checkChannel{
    userInfo *user = [userInfo shareClass];
    user.WeChatInstalled = [WXApi isWXAppInstalled];
    user.QQInstalled = [QQApi isQQInstalled];
}
-(void)loadData{
    userInfo *user = [userInfo shareClass];

    ASIHTTPRequest *requestsquare = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Muzzik_Trending]]];
    [requestsquare addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:@"20" forKey:Parameter_Limit] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequestsquare = requestsquare;
    [requestsquare setCompletionBlock :^{
        //    NSLog(@"%@",weakrequest.originalURL);
        NSData *data = [weakrequestsquare responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic  && [[dic objectForKey:@"muzziks"] count]>0 ) {
            NSMutableArray *squareMuzziks = [NSMutableArray array];
            muzzik *muzzikToy = [muzzik new];
            NSArray *array = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
            for (muzzik *tempmuzzik in array) {
                BOOL isContained = NO;
                for (muzzik *arrayMuzzik in squareMuzziks) {
                    if ([arrayMuzzik.muzzik_id isEqualToString:tempmuzzik.muzzik_id]) {
                        isContained = YES;
                        break;
                    }
                    
                }
                if (!isContained) {
                    [squareMuzziks addObject:tempmuzzik];
                }
                isContained = NO;
            }
            [MuzzikItem SetUserInfoWithMuzziks:squareMuzziks title:Constant_userInfo_square description:nil];
            [MuzzikItem addObjectToLocal:data ForKey:Constant_Data_Square];
            
        }
    }];
    [requestsquare setFailedBlock:^{
        NSLog(@"%@,%@",[weakrequestsquare error],[weakrequestsquare responseString]);
    }];
    [requestsquare startAsynchronous];
    
    
    
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/suggest",BaseURL]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:@"10",Parameter_Limit,[NSNumber numberWithBool:YES],@"image", nil] Method:GetMethod auth:NO];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        //    NSLog(@"%@",weakrequest.originalURL);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic&&[[dic objectForKey:@"muzziks"]count]>0) {
            if ([[dic allKeys] containsObject:@"data"] && [[[dic objectForKey:@"data"] allKeys] containsObject:@"title"] && [[[dic objectForKey:@"data"] objectForKey:@"title"] length] >0) {
                user.suggestTitle = [[dic objectForKey:@"data"] objectForKey:@"title"];
            }
            [MuzzikItem SetUserInfoWithMuzziks:[[muzzik new] makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]] title:Constant_userInfo_suggest description:[NSString stringWithFormat:@"推荐列表"]];
            [MuzzikItem addObjectToLocal:data ForKey:Constant_Data_Suggest];
            
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
    }];
    [request startAsynchronous];
    
    if ([user.token length]>0) {
        ASIHTTPRequest *requestOwn = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@/muzziks",BaseURL,user.uid]]];
        [requestOwn addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:20],Parameter_Limit ,nil] Method:GetMethod auth:YES];
        __weak ASIHTTPRequest *weakrequestOwn = requestOwn;
        [requestOwn setCompletionBlock :^{
            if ([weakrequestOwn responseStatusCode] == 200) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequestOwn responseData] options:NSJSONReadingMutableContainers error:nil];
                if (dic  && [[dic objectForKey:@"muzziks"] count]>0 ) {
                    NSMutableArray *ownerMuzziks = [NSMutableArray array];
                    muzzik *muzzikToy = [muzzik new];
                    NSArray *array = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
                    for (muzzik *tempmuzzik in array) {
                        BOOL isContained = NO;
                        for (muzzik *arrayMuzzik in ownerMuzziks) {
                            if ([arrayMuzzik.muzzik_id isEqualToString:tempmuzzik.muzzik_id]) {
                                isContained = YES;
                                break;
                            }
                            
                        }
                        if (!isContained) {
                            [ownerMuzziks addObject:tempmuzzik];
                        }
                        isContained = NO;
                    }
                    [MuzzikItem SetUserInfoWithMuzziks:ownerMuzziks title:Constant_userInfo_own description:[NSString stringWithFormat:@"我的Muzzik"]];
                     [MuzzikItem addObjectToLocal:[weakrequestOwn responseData] ForKey:[NSString stringWithFormat:@"Persistence_own_data%@",user.token]];
                }
            }
            }];
            [requestOwn setFailedBlock:^{
                NSLog(@"%@",[weakrequestOwn error]);
            }];
            [requestOwn startAsynchronous];
        
        ASIHTTPRequest *requestfollow = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/feeds",BaseURL]]];
        [requestfollow addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:30] forKey:Parameter_Limit] Method:GetMethod auth:YES];
        __weak ASIHTTPRequest *weakrequestfollow = requestfollow;
        [requestfollow setCompletionBlock :^{
            // NSLog(@"%@",[weakrequest responseString]);
            NSData *data = [weakrequestfollow responseData];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            if (dic  && [[dic objectForKey:@"muzziks"] count]>0 ) {
                NSMutableArray *feedMuzziks = [NSMutableArray array];
                muzzik *muzzikToy = [muzzik new];
                NSArray *array = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
                for (muzzik *tempmuzzik in array) {
                    BOOL isContained = NO;
                    for (muzzik *arrayMuzzik in feedMuzziks) {
                        if ([arrayMuzzik.muzzik_id isEqualToString:tempmuzzik.muzzik_id]) {
                            isContained = YES;
                            break;
                        }
                        
                    }
                    if (!isContained) {
                        [feedMuzziks addObject:tempmuzzik];
                    }
                    isContained = NO;
                }
                 [MuzzikItem SetUserInfoWithMuzziks:feedMuzziks title:Constant_userInfo_follow description:[NSString stringWithFormat:@"关注列表"]];
                [MuzzikItem addObjectToLocal:data ForKey:[NSString stringWithFormat:@"User_Feed%@",user.uid]];
            }
        }];
        [requestfollow setFailedBlock:^{
            NSLog(@"%@,%@",[weakrequestfollow error],[weakrequestfollow responseString]);
        }];
        [requestfollow startAsynchronous];
        
        ASIHTTPRequest *requestmove = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/movedMuzzik",BaseURL]]];
        [requestmove addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:20] forKey:Parameter_Limit] Method:GetMethod auth:YES];
        __weak ASIHTTPRequest *weakrequestmove = requestmove;
        [requestmove setCompletionBlock :^{
            // NSLog(@"%@",[weakrequest responseString]);
            NSData *data = [weakrequestmove responseData];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] == kReachableViaWiFi) {
                NSArray *musicArray = [MuzzikItem getArrayFromLocalForKey:Muzzik_local_Music_Moved_Array];
            }
            
            
            if (dic  && [[dic objectForKey:@"muzziks"] count]>0 ) {
                NSMutableArray *movedMuzziks = [NSMutableArray array];
                muzzik *muzzikToy = [muzzik new];
                NSArray *array = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
                for (muzzik *tempmuzzik in array) {
                    BOOL isContained = NO;
                    for (muzzik *arrayMuzzik in movedMuzziks) {
                        if ([arrayMuzzik.muzzik_id isEqualToString:tempmuzzik.muzzik_id]) {
                            isContained = YES;
                            break;
                        }
                        
                    }
                    if (!isContained) {
                        [movedMuzziks addObject:tempmuzzik];
                    }
                    isContained = NO;
                }
                [MuzzikItem SetUserInfoWithMuzziks:movedMuzziks title:Constant_userInfo_move description:[NSString stringWithFormat:@"喜欢列表"]];
                [MuzzikItem addObjectToLocal:data ForKey:[NSString stringWithFormat:@"Persistence_moved_data%@",user.token]];
            }
        }];
        [requestmove setFailedBlock:^{
            NSLog(@"%@,%@",[weakrequestmove error],[weakrequestmove responseString]);
        }];
        [requestmove startAsynchronous];
    }
    NSLog(@"%@",[NSString stringWithFormat:@"%@%@",BaseURL_image,user.avatar]);
    // 2.构建网络URL对象, NSURL
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,user.avatar]];
    // 3.创建网络请求
    NSURLRequest *requestimage = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    // 创建同步链接
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:requestimage returningResponse:&response error:&error];
    user.userHeadThumb = [UIImage imageWithData:data];
    
    
}
#pragma mark - 创建相册
-(void) createAlbum{
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    NSMutableArray *groups=[[NSMutableArray alloc]init];
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop)
    {
        if (group)
        {
            [groups addObject:group];
        }
        
        else
        {
            BOOL haveHDRGroup = NO;
            
            for (ALAssetsGroup *gp in groups)
            {
                NSString *name =[gp valueForProperty:ALAssetsGroupPropertyName];
                
                if ([name isEqualToString:@"Muzzik相册"])
                {
                    haveHDRGroup = YES;
                }
            }
            
            if (!haveHDRGroup)
            {
                //do add a group named "XXXX"
                [assetsLibrary addAssetsGroupAlbumWithName:@"Muzzik相册"
                                               resultBlock:^(ALAssetsGroup *group)
                 {
                     [groups addObject:group];
                     [MuzzikItem addObjectToLocal:@"yes" ForKey:@"Muzzik_Create_Album"];
                     
                 }
                                              failureBlock:nil];
                haveHDRGroup = YES;
            }
        }
        
    };
    //创建相簿
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:listGroupBlock failureBlock:nil];
}

@end
