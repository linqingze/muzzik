//
//  appConfiguration.h
//  muzzik
//
//  Created by 林清泽 on 15/3/3.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#ifndef muzzik_appConfiguration_h
#define muzzik_appConfiguration_h
//手机屏幕
#define SCREEN_WIDTH [ UIScreen mainScreen ].bounds.size.width
#define SCREEN_HEIGHT [ UIScreen mainScreen ].bounds.size.height

#pragma -mark URL Address

#define URL_Lyric_Me            @"http://geci.me/api/lyric/"
#define BaseURL                 @"http://117.121.26.174/"
//#define BaseURL                 @"http://192.168.1.112:3000/"
#define BaseURL_audio           @"http://7bvaim.com1.z0.glb.clouddn.com/"
#define BaseURL_image           @"http://7bvarm.com1.z0.glb.clouddn.com/"

#define URL_protocol            @"http://www.muzziker.com/about.html"

#define URL_WeiBo_redirectURI   @"http://muzziker.com"
#define URL_QQ_AUTH             @"auth/qq?access_token="
#define URL_WeiBo_AUTH          @"auth/weibo?access_token="
//#define URL_WeiChat_AUTH        @"auth/weixin?access_token="
#define URL_WeiChat_AUTH        @"auth/weixin/callback?result=json&code="
#define URL_Muzzik_Trending     @"api/muzzik/trending"

#define URL_check_phone         @"api/user/check"
#define URL_register            @"api/user/register"
#define URL_GetVerifiCode       @"api/user/verifiCode"
#define URL_Login               @"api/user/login"
#define URL_Update_Profile      @"api/user/profile"
#define URL_Upload_Image        @"api/image/upload/params"
#define URL_Upload_audio        @"api/music/upload/params"

#define URL_Reset_Pwd           @"api/user/resetPassword"
#define URL_Get_Moved_music     @"api/user/movedMusic"
#define URL_Get_suggest_muzzik  @"api/muzzik/suggest"

//#define URL_





//#define URL_check_phone @"http://192.168.1.112:3000/api/user/check"
//#define URL_register @"http://192.168.1.112:3000/api/user/register"
//#define URL_GetVerifiCode @"http://192.168.1.112:3000/api/user/verifiCode"
//#define URL_Login @"http://192.168.1.112:3000/api/user/login"

#pragma -mark App_Color
#define Color_underLine [UIColor colorWithRed:227.0/255.0 green:227.0/255.0 blue:227.0/255.0 alpha:1]
#define Color_scarlet [UIColor colorWithRed:171.0/255.0 green:33.0/255.0 blue:31.0/255.0 alpha:1]
#define Color_For_Background [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1]
#define Color_For_bubble [UIColor colorWithRed:255.0/255.0 green:125.0/255.0 blue:105.0/255.0 alpha:1]
#define Color_NavigationBar [UIColor colorWithHexString:@"555555"]
#define Color_IndicatorColor [UIColor colorWithHexString:@"b2cc3a"]

#pragma -mark Notification string
#define String_StatusNotifiation                   @"StatusNotifiation"
#define String_SetSongInformationNotification      @"SetSongInformationNotification"
#define String_WeiBo_Response_Notification         @"weiboresponse"
#define String_SetSongPlayNextNotification         @"notification_play_next"


#pragma -mark Font_Size

#define Font_Size_Muzzik_Time 7.0
#define Font_Size_Muzzik_Message 12.0
#define Constant_String_PlayMode_Once 0
#define Constant_String_PlayMode_Cycle 1
#define Constant_String_PlayMode_Single 2
#define Constant_String_PlayMode_Random 3
#define Font_Next_Regular        @"AvenirNext-Regular"
#define Font_Next_medium         @"AvenirNext-Medium"
#define Font_Next_Bold           @"AvenirNext-Bold"
#define Font_Next_DemiBold           @"AvenirNext-DemiBold"
#define Font_Next_UltraLight     @"AvenirNext-UltraLight"

#define DocumentsPath [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

#define UMAPPKEY @"5503f6b7fd98c520c4000362"

#define ID_WeiChat_APP @"wx9d1e9620b322ce35"
#define Secret_WeiChat_APP @"8f0094ad31273ba1b6ca45d25bae4910"

#define ID_QQ_APP @"101142713"
#define Key_QQ_APP @"abccb400bf06b9a23fc8326fdeadebf5"

#define Key_WeiBo @"2871037752"
#define Secret_WeiBo @"9f370076f566782489471837ced4f7ef"

#define kAppId           @"3rIHoZnUS56Bu3H9X2FKm1"
#define kAppKey          @"2871037752"
#define kAppSecret       @"uGD286iqV4AUBMY1JndC64"

#pragma -mark string
#define Is_Table_Create @"IsTableCreate"
#define IOS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define SCREEN_TYPE_is_4S [ UIScreen mainScreen ].bounds.size.height == 480.0


#pragma -mark Constant

#define Cell_width 60.0
#define Constant_backImage      1     //返回按钮图片
#define Constant_filterImage    2     //筛选按钮图片
#define Constant_markImage      3     //对勾按钮图片
#define Constant_searchImage    4     //搜索按钮图片
#define Constant_nextStep       5     //下一步
#define Constant_submit         6     //提交
#define Constant_camera         7     //自拍
#define Constant_share          8
#define Constant_register       9
#define Constant_manager        10
#define Constant_add            11
#define Constant_save           12
#define Constant_back           13



#define SquareList             1
#define MovedList              2
#define LibraryList            3
#define TempList               4

#endif
