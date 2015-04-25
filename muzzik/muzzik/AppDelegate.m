//
//  AppDelegate.m
//  muzzik
//
//  Created by 林清泽 on 15/3/7.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//
#import "UMSocialWechatHandler.h"
#import "UMSocial.h"
#import "WeiboSDK.h"
#import "AppDelegate.h"
#import "muzzikTrendController.h"
#import "appConfiguration.h"
#import "musicPlayer.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "ASIHTTPRequest.h"
#import "userInfo.h"
#import "HostViewController.h"
#import "NetTypeHelper.h"
@interface AppDelegate ()

@end

@implementation AppDelegate
 
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [UMSocialData setAppKey:UMAPPKEY];
    [UMSocialWechatHandler setWXAppId:ID_WeiChat_APP appSecret:Secret_WeiChat_APP url:@"http://www.umeng.com/social"];
    [WeiboSDK enableDebugMode:NO];
    [WeiboSDK registerApp:Key_WeiBo];
    [self startSdkWith:kAppId appKey:kAppKey appSecret:kAppSecret];
    NSDictionary * dic = [MuzzikItem messageFromLocal];
    userInfo *user = [userInfo shareClass];
    user.uid = [dic objectForKey:@"_id"];
    user.token = [dic objectForKey:@"token"];
    user.gender = [dic objectForKey:@"gender"];
    user.avatar = [dic objectForKey:@"avatar"];
    user.name = [dic objectForKey:@"name"];
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
    NSDictionary* message = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (message) {
        NSString *payloadMsg = [message objectForKey:@"payload"];
        NSString *record = [NSString stringWithFormat:@"[APN]%@, %@", [NSDate date], payloadMsg];
        NSLog(@"%@%@",payloadMsg,record);
    }
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    [self registNetWorkChangeNot];
    
    
    
    
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    Globle * globle = [Globle shareGloble];
//    [globle copySqlitePath];
    globle.isPlaying = YES;
    [ASIHTTPRequest clearSession];
    
    HostViewController *hostVC = [[HostViewController alloc] init];
    UINavigationController *nac = [[UINavigationController alloc] initWithRootViewController:hostVC];
    //[nac.navigationBar setBarStyle:UIBarStyleBlack];
    [self.window setRootViewController:nac];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    return YES;
}

-(void)GexinSdkDidReceivePayload:(NSString *)payloadId fromApplication:(NSString *)appId{
    NSData *data = [_gexinPusher retrivePayloadById:payloadId];
    NSString *payloadMsg = nil;
    if (data) {
        payloadMsg = [[NSString alloc] initWithBytes:data.bytes
                                              length:data.length
                                            encoding:NSUTF8StringEncoding];
    NSLog(@"payload:%@",payloadMsg);
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
    [[NSNotificationCenter defaultCenter] postNotificationName:String_SetSongInformationNotification object:nil userInfo:nil];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
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
            case UIEventSubtypeRemoteControlPlay:
                [player play];
                NSLog(@"RemoteControlEvents: play");
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
    if ([WeiboSDK handleOpenURL:url delegate:self]) {
        return [WeiboSDK handleOpenURL:url delegate:self];
    }else if([TencentOAuth HandleOpenURL:url]){
         return [TencentOAuth HandleOpenURL:url];
    }
    else if( [UMSocialSnsService handleOpenURL:url wxApiDelegate:nil])
    {
        return  [UMSocialSnsService handleOpenURL:url wxApiDelegate:nil];
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
    else if( [UMSocialSnsService handleOpenURL:url wxApiDelegate:nil])
    {
        return  [UMSocialSnsService handleOpenURL:url wxApiDelegate:nil];
    }

    return [WeiboSDK handleOpenURL:url delegate:self];
}





-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    // [4-EXT]:处理APN
    NSString *payloadMsg = [userInfo objectForKey:@"payload"];
    
    NSDictionary *aps = [userInfo objectForKey:@"aps"];
    NSNumber *contentAvailable = aps == nil ? nil : [aps objectForKeyedSubscript:@"content-available"];
    
    NSString *record = [NSString stringWithFormat:@"[APN]%@, %@, [content-available: %@]", [NSDate date], payloadMsg, contentAvailable];
    NSLog(@"%@",record);
    
    completionHandler(UIBackgroundFetchResultNewData);

}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)pToken {
    
    NSString *token = [[_deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    _deviceToken = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"deviceToken:%@", _deviceToken);
    
    
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
    [self startSdkWith:_appID appKey:_appKey appSecret:_appSecret];
    [Globle shareGloble].isApplicationEnterBackground = NO;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"end");
    [ASIHTTPRequest clearSession];
    ASIHTTPRequest *htt = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL,URL_Muzzik_Trending]]];
    NSLog(@"%@",[htt requestHeaders]);
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

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
        NSString *title = NSLocalizedString(@"发送结果", nil);
        NSString *message = [NSString stringWithFormat:@"%@: %d\n%@: %@\n%@: %@", NSLocalizedString(@"响应状态", nil), (int)response.statusCode, NSLocalizedString(@"响应UserInfo数据", nil), response.userInfo, NSLocalizedString(@"原请求UserInfo数据", nil),response.requestUserInfo];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                              otherButtonTitles:nil];
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
        [alert show];
    }
    else if ([response isKindOfClass:WBAuthorizeResponse.class])
    {

        self.wbtoken = [(WBAuthorizeResponse *)response accessToken];
        self.wbCurrentUserID = [(WBAuthorizeResponse *)response userID];
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@%@",BaseURL,URL_WeiBo_AUTH,[(WBAuthorizeResponse *)response accessToken]]]];
        
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            //  NSLog(@"%@",[weakrequest responseString]);
            //  NSLog(@"%d",[weakrequest responseStatusCode]);
            if ([weakrequest responseStatusCode] == 200) {
                NSData *data = [weakrequest responseData];
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data  options:NSJSONReadingMutableContainers error:nil];
                [MuzzikItem addMessageToLocal:dic];
                userInfo *user = [userInfo shareClass];
                user.uid = [dic objectForKey:@"_id"];
                user.token = [dic objectForKey:@"token"];
                user.gender = [dic objectForKey:@"gender"];
                user.avatar = [dic objectForKey:@"avatar"];
                user.name = [dic objectForKey:@"name"];
            }
            else{
                //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
            }
        }];
        [requestForm setFailedBlock:^{
            [KVNProgress showErrorWithStatus:@"网络加载超时"];
        }];
        [requestForm startAsynchronous];
        
    }
}
#pragma -mark 网络状态
- (void)registNetWorkChangeNot
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkNetworkStatus:)
                                                 name:kReachabilityChangedNotification object:nil];
    Reachability *NetReachable = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    [NetReachable startNotifier];
}

- (void)removeNetWorkChangeNot
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (void)checkNetworkStatus:(NSNotification *)not
{
    Reachability *NetReachable = not.object;
    NetworkStatus NetStatus = [NetReachable currentReachabilityStatus];
    switch (NetStatus) {
        case NotReachable:
        {
            [NetTypeHelper shareClass].nNetType = NotNet;
        }
            break;
        case ReachableViaWiFi:
        {
            [NetTypeHelper shareClass].nNetType = WifiNet;
        }
            break;
        case ReachableViaWWAN:
        {
            [NetTypeHelper shareClass].nNetType = OtherNet;
        }
            break;
        default:
            break;
    }
}
@end
