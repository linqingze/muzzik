//
//  LoginViewController.m
//  muzzik
//
//  Created by 林清泽 on 15/4/2.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "LoginViewController.h"
#import "UIColor+HexColor.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "ASIHTTPRequest.h"
#import "WeiboSDK.h"
#import "registerVC.h"
#import "NSString+MD5.h"
#import "phoneForResetVC.h"
@interface LoginViewController ()<TencentSessionDelegate,TencentLoginDelegate,UITextFieldDelegate>{
    CGFloat scaleHeight;
    UIImageView *backGroundImage;
    NSMutableArray *spaceArray;
    UITextField *phoneText;
    UITextField *passwordText;
    TencentOAuth* _tencentOAuth;
    NSArray* _permissions;
    UIButton *loginButton;
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNagationBar:@"" leftBtn:0 rightBtn:0];
     [ASIHTTPRequest clearSession];
    spaceArray = [NSMutableArray arrayWithArray:@[@100.0,@22.0,@73.0,@10.0,@28.0,@13.0,@60.0,@15.0]];
    scaleHeight = SCREEN_HEIGHT;
    scaleHeight = SCREEN_WIDTH;
    if (SCREEN_HEIGHT == 480) {
        scaleHeight = (SCREEN_HEIGHT-290)/278.0;
        [self changeSpaceArray];
    }else if (SCREEN_HEIGHT == 736){
        scaleHeight = (SCREEN_HEIGHT-350)/278.0;
        [self changeSpaceArray];
    }else if (SCREEN_HEIGHT == 667){
        scaleHeight = (SCREEN_HEIGHT-320)/278.0;
        [self changeSpaceArray];
    }
    _permissions = [NSArray arrayWithObjects:
                    kOPEN_PERMISSION_GET_USER_INFO,
                    kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                    kOPEN_PERMISSION_ADD_ALBUM,
                    kOPEN_PERMISSION_ADD_IDOL,
                    kOPEN_PERMISSION_ADD_ONE_BLOG,
                    kOPEN_PERMISSION_ADD_PIC_T,
                    kOPEN_PERMISSION_ADD_SHARE,
                    kOPEN_PERMISSION_ADD_TOPIC,
                    kOPEN_PERMISSION_CHECK_PAGE_FANS,
                    kOPEN_PERMISSION_DEL_IDOL,
                    kOPEN_PERMISSION_DEL_T,
                    kOPEN_PERMISSION_GET_FANSLIST,
                    kOPEN_PERMISSION_GET_IDOLLIST,
                    kOPEN_PERMISSION_GET_INFO,
                    kOPEN_PERMISSION_GET_OTHER_INFO,
                    kOPEN_PERMISSION_GET_REPOST_LIST,
                    kOPEN_PERMISSION_LIST_ALBUM,
                    kOPEN_PERMISSION_UPLOAD_PIC,
                    kOPEN_PERMISSION_GET_VIP_INFO,
                    kOPEN_PERMISSION_GET_VIP_RICH_INFO,
                    kOPEN_PERMISSION_GET_INTIMATE_FRIENDS_WEIBO,
                    kOPEN_PERMISSION_MATCH_NICK_TIPS_WEIBO,
                    nil];
    
    
    _tencentOAuth = [[TencentOAuth alloc] initWithAppId:ID_QQ_APP
                                            andDelegate:self];
    
    int i = 0;
    CGFloat localPosition = 0;
    backGroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [backGroundImage setImage:[UIImage imageNamed:@"bgpic_hd"]];
    UIImageView *coverImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [coverImage setImage:[UIImage imageNamed:@"bg_cover"]];
    [coverImage setAlpha:0.4];
    [self.view addSubview:backGroundImage];
    [self.view addSubview:coverImage];
    localPosition = localPosition + [spaceArray[i++] floatValue];
    UIImageView *logoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Muzzik"]];
    [logoImage setFrame:CGRectMake(SCREEN_WIDTH/2-67, localPosition, 134, 32)];
    [self.view addSubview:logoImage];
    
    localPosition = localPosition + [spaceArray[i++] floatValue]+logoImage.frame.size.height;
    UIImageView *sloganImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Slogan"]];
    [sloganImage setFrame:CGRectMake(SCREEN_WIDTH/2-93, localPosition, 186, 11)];
    [self.view addSubview:sloganImage];
    UIView *tapView = [[UIView alloc] initWithFrame:self.view.frame];
    [tapView setBackgroundColor:[UIColor clearColor]];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnview)];
    [tapView addGestureRecognizer:tap];
    [self.view addSubview:tapView];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 30, 30, 30)];
    [backButton addTarget:self action:@selector(backTo) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:[UIImage imageNamed:Image_back] forState:UIControlStateNormal];
    [backButton setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.4]];
     backButton.layer.cornerRadius = 6;
     backButton.clipsToBounds = YES;
    [self.view addSubview:backButton];
    localPosition = localPosition + [spaceArray[i++] floatValue]+23;
    UIImageView *phoneImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"phoneImage"]];
    [phoneImage setFrame:CGRectMake(45, localPosition, 15, 15)];
    phoneText = [[UITextField alloc] initWithFrame:CGRectMake(75, localPosition, SCREEN_WIDTH-140, 20)];
    [phoneText setKeyboardType:UIKeyboardTypePhonePad];
    [phoneText setFont:[UIFont systemFontOfSize:15]];
    phoneText.placeholder = @"手机号码";
    phoneText.delegate = self;
    
    [phoneText setValue:[UIFont boldSystemFontOfSize:15] forKeyPath:@"_placeholderLabel.font"];
    [phoneText setTextColor:[UIColor whiteColor]];
    [phoneText setValue:[UIColor colorWithHexString:@"dddddd"] forKeyPath:@"_placeholderLabel.textColor"];
    UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(36, localPosition+27, SCREEN_WIDTH-72, 1)];
    [lineView1 setBackgroundColor:[UIColor colorWithHexString:@"dddddd"] ];
    [self.view addSubview:phoneImage];
    [self.view addSubview:phoneText];
    [self.view addSubview:lineView1];

    localPosition = localPosition + [spaceArray[i++] floatValue]+40;
    UIImageView *passwordImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"passwordImage"]];
    [passwordImage setFrame:CGRectMake(47, localPosition, 12, 15)];
    passwordText = [[UITextField alloc] initWithFrame:CGRectMake(75, localPosition, SCREEN_WIDTH-140, 20)];
    [passwordText setTextColor:[UIColor whiteColor]];
    passwordText.placeholder = @"密 码";
    passwordText.delegate = self;
    [passwordText setReturnKeyType:UIReturnKeyDone];
    [passwordText setFont:[UIFont systemFontOfSize:15]];
    [passwordText setSecureTextEntry:YES];
    [passwordText setValue:[UIFont boldSystemFontOfSize:15] forKeyPath:@"_placeholderLabel.font"];
    [passwordText setValue:[UIColor colorWithHexString:@"dddddd"]  forKeyPath:@"_placeholderLabel.textColor"];
    UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(36, localPosition+27, SCREEN_WIDTH-72, 1)];
    [lineView2 setBackgroundColor:[UIColor colorWithHexString:@"dddddd"] ];
    [self.view addSubview:passwordImage];
    [self.view addSubview:passwordText];
    [self.view addSubview:lineView2];

    
    localPosition = localPosition + [spaceArray[i++] floatValue]+28;
    loginButton = [[UIButton alloc] initWithFrame:CGRectMake(36, localPosition, SCREEN_WIDTH-72, 40)];
    loginButton.layer.cornerRadius = 3;
    loginButton.clipsToBounds = YES;
    [loginButton setBackgroundImage:[MuzzikItem createImageWithColor:[UIColor colorWithHexString:@"f26a3d"]]  forState:UIControlStateNormal];
    //[loginButton setImage:[MuzzikItem createImageWithColor:[UIColor colorWithHexString:@"f26a3d"]] forState:UIControlStateNormal];
    
    [loginButton.titleLabel setTextColor:[UIColor whiteColor]];
//    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [loginButton setTintColor:[UIColor whiteColor]];
    [loginButton.titleLabel setText:@"login"];
    [loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [loginButton.titleLabel setFont:[UIFont boldSystemFontOfSize:17.0]];
    [loginButton addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
    localPosition = localPosition + [spaceArray[i++] floatValue]+40;
    
    UIButton *registerButton = [[UIButton alloc] initWithFrame:CGRectMake(36, localPosition, 162, 15)];
    [registerButton setTitle:@"没有Muzzik账号？现在注册！" forState:UIControlStateNormal];
    [registerButton addTarget:self action:@selector(registerAction) forControlEvents:UIControlEventTouchUpInside];
    [registerButton setTitleColor:[UIColor colorWithHexString:@"a8acbb"] forState:UIControlStateNormal];
    [registerButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    [self.view addSubview:registerButton];
    
    UIView *lineView3 = [[UIView alloc]initWithFrame:CGRectMake(36, localPosition+14, 160, 1)];
    [lineView3 setBackgroundColor:[UIColor colorWithHexString:@"a8acbb"]];
    [lineView3 setAlpha:0.3];
    [self.view addSubview:lineView3];
    
    UIButton *forgetButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-96, localPosition, 60, 15)];
    [forgetButton setTitle:@"忘记密码？" forState:UIControlStateNormal];
    [forgetButton addTarget:self action:@selector(foregetAction) forControlEvents:UIControlEventTouchUpInside];
    [forgetButton setTitleColor:[UIColor colorWithHexString:@"a8acbb"] forState:UIControlStateNormal];
    [forgetButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    [self.view addSubview:forgetButton];
    
    localPosition = localPosition + [spaceArray[i++] floatValue]+12;
    
    UILabel *otherLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-25, localPosition, 50, 12)];
    [otherLabel setText:@"其他登录"];
    [otherLabel setTextColor:[UIColor colorWithHexString:@"a8acbb"]];
    [self.view addSubview:otherLabel];
    [otherLabel setFont:[UIFont boldSystemFontOfSize:12]];
    
    UIView *lineView4 = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2-83, localPosition+6, 50, 1)];
    [lineView4 setBackgroundColor:[UIColor colorWithHexString:@"a8acbb"]];
    [lineView4 setAlpha:0.3];
    [self.view addSubview:lineView4];
    UIView *lineView5 = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2+30, localPosition+6, 50, 1)];
    [lineView5 setBackgroundColor:[UIColor colorWithHexString:@"a8acbb"]];
    [lineView5 setAlpha:0.3];
    [self.view addSubview:lineView5];
    userInfo *user = [userInfo shareClass];
    user.isSwitchUser = YES;
    localPosition = localPosition + [spaceArray[i++] floatValue]+12;
    if (user.QQInstalled &&user.WeChatInstalled) {
        
        UIButton *QQButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-16, localPosition, 32, 32)];
        [QQButton setImage:[UIImage imageNamed:@"LoginqqImage"] forState:UIControlStateNormal];
        [QQButton addTarget:self action:@selector(QQlogin) forControlEvents:UIControlEventTouchUpInside];
        QQButton.layer.cornerRadius = 3;
        QQButton.clipsToBounds = YES;
        [self.view addSubview:QQButton];
        
        UIButton *WeiChatButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-78, localPosition, 32, 32)];
        [WeiChatButton setImage:[UIImage imageNamed:@"LoginwechatImage"] forState:UIControlStateNormal];
        [WeiChatButton addTarget:self action:@selector(WeiChatlogin) forControlEvents:UIControlEventTouchUpInside];
        WeiChatButton.layer.cornerRadius = 3;
        WeiChatButton.clipsToBounds = YES;
        [self.view addSubview:WeiChatButton];
        
        UIButton *weiboButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2+46, localPosition, 32, 32)];
        [weiboButton setImage:[UIImage imageNamed:@"LoginweiboImage"] forState:UIControlStateNormal];
        [weiboButton addTarget:self action:@selector(weibologin) forControlEvents:UIControlEventTouchUpInside];
        weiboButton.layer.cornerRadius = 3;
        weiboButton.clipsToBounds = YES;
        [self.view addSubview:weiboButton];
        
        
    }else if(user.QQInstalled || user.WeChatInstalled){
        if (user.WeChatInstalled) {
            UIButton *WeiChatButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-47, localPosition, 32, 32)];
            [WeiChatButton setImage:[UIImage imageNamed:@"LoginwechatImage"] forState:UIControlStateNormal];
            [WeiChatButton addTarget:self action:@selector(WeiChatlogin) forControlEvents:UIControlEventTouchUpInside];
            WeiChatButton.layer.cornerRadius = 3;
            WeiChatButton.clipsToBounds = YES;
            [self.view addSubview:WeiChatButton];
            
            UIButton *weiboButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2+15, localPosition, 32, 32)];
            [weiboButton setImage:[UIImage imageNamed:@"LoginweiboImage"] forState:UIControlStateNormal];
            [weiboButton addTarget:self action:@selector(weibologin) forControlEvents:UIControlEventTouchUpInside];
            weiboButton.layer.cornerRadius = 3;
            weiboButton.clipsToBounds = YES;
            [self.view addSubview:weiboButton];
        }else{
            UIButton *QQButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-47, localPosition, 32, 32)];
            [QQButton setImage:[UIImage imageNamed:@"LoginqqImage"] forState:UIControlStateNormal];
            [QQButton addTarget:self action:@selector(QQlogin) forControlEvents:UIControlEventTouchUpInside];
            QQButton.layer.cornerRadius = 3;
            QQButton.clipsToBounds = YES;
            [self.view addSubview:QQButton];

            
            UIButton *weiboButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2+15, localPosition, 32, 32)];
            [weiboButton setImage:[UIImage imageNamed:@"LoginweiboImage"] forState:UIControlStateNormal];
            [weiboButton addTarget:self action:@selector(weibologin) forControlEvents:UIControlEventTouchUpInside];
            weiboButton.layer.cornerRadius = 3;
            weiboButton.clipsToBounds = YES;
            [self.view addSubview:weiboButton];
        }
    }else{
        
        UIButton *weiboButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-16, localPosition, 32, 32)];
        [weiboButton setImage:[UIImage imageNamed:@"LoginweiboImage"] forState:UIControlStateNormal];
        [weiboButton addTarget:self action:@selector(weibologin) forControlEvents:UIControlEventTouchUpInside];
        weiboButton.layer.cornerRadius = 3;
        weiboButton.clipsToBounds = YES;
        [self.view addSubview:weiboButton];
    }

    
    
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setHidden:NO];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) tapOnview{
    [self.view endEditing:YES];
}
-(void)changeSpaceArray{
    for (int i = 0; i<spaceArray.count; i++) {
        spaceArray[i] = [NSNumber numberWithFloat:[spaceArray[i] floatValue]*scaleHeight];
    }
}

-(void) foregetAction{
    phoneForResetVC *phonevc = [[phoneForResetVC alloc] init];
    [self.navigationController pushViewController:phonevc animated:YES];
}
-(void) loginAction{
    loginButton.userInteractionEnabled = NO;
    userInfo *user = [userInfo shareClass];
    NSString *passwordInMD5 = [[NSString stringWithFormat:@"%@Muzzik%@",phoneText.text,passwordText.text] md5Encrypt];
    
    ASIHTTPRequest *requestsquare = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Login]]];
    [requestsquare addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:phoneText.text,@"phone",passwordInMD5,@"hashedPassword",nil] Method:PostMethod auth:YES];
    __weak ASIHTTPRequest *weakrequestsquare = requestsquare;
    [requestsquare setCompletionBlock :^{
        if ([weakrequestsquare responseStatusCode] == 200) {
            NSData *data = [weakrequestsquare responseData];
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            [MuzzikItem addMessageToLocal:responseObject];
            
            
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
        }
        else if ([weakrequestsquare responseStatusCode] == 400)
        {
            [MuzzikItem showNotifyOnView:self.view text:@"请输入正确的手机号"];
        }
        else{
            [MuzzikItem showNotifyOnView:self.view text:@"账号密码错误"];
        }
        
        if ([user.token length]>0) {
            ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Set_Notify]]];
            [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:user.deviceToken,@"deviceToken",@"APN",@"type", nil] Method:PostMethod auth:YES];
            __weak ASIHTTPRequest *weakrequest = request;
            [request setCompletionBlock :^{
                NSLog(@"JSON: %@", [weakrequest responseString]);
            }];
            [request setFailedBlock:^{
                
            }];
            [request startAsynchronous];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    [requestsquare setFailedBlock:^{
        [MuzzikItem showNotifyOnView:self.view text:@"网络请求失败"];
    }];
    [requestsquare startAsynchronous];
}
- (void) registerAction{
    registerVC *registervc = [[registerVC alloc] init];
    [self.navigationController pushViewController:registervc animated:YES];
}
-(void)backTo{
    [self.navigationController popViewControllerAnimated:YES];
}



-(void) WeiChatlogin{
    [(AppDelegate*)[UIApplication sharedApplication].delegate sendAuthRequestByVC:self];

}
#pragma -mark QQlogin
-(void) QQlogin{
    [_tencentOAuth authorize:_permissions inSafari:NO];
}
- (void)getUserInfoResponse:(APIResponse*) response;{
    NSLog(@"info");
}
- (void)tencentDidLogin {
    NSLog(@"qq");
    
    userInfo *user = [userInfo shareClass];
    ASIHTTPRequest *requestsquare = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@%@",BaseURL,URL_QQ_AUTH,_tencentOAuth.accessToken]]];
    [requestsquare addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequestsquare = requestsquare;
    [requestsquare setCompletionBlock :^{
        if ([weakrequestsquare responseStatusCode] == 200) {
            NSData *data = [weakrequestsquare responseData];
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            [MuzzikItem addMessageToLocal:responseObject];
            
            
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
        }
        if ([user.token length]>0) {
            ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Set_Notify]]];
            [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:user.deviceToken,@"deviceToken",@"APN",@"type", nil] Method:PostMethod auth:YES];
            __weak ASIHTTPRequest *weakrequest = request;
            [request setCompletionBlock :^{
                NSLog(@"JSON: %@", [weakrequest responseString]);
            }];
            [request setFailedBlock:^{
                
            }];
            [request startAsynchronous];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    [requestsquare setFailedBlock:^{
        [MuzzikItem showNotifyOnView:self.view text:@"授权登录请求失败"];
    }];
    [requestsquare startAsynchronous];
    

}
- (void)tencentDidNotLogin:(BOOL)cancelled
{
    if (cancelled){
        //  _labelTitle.text = @"用户取消登录";
    }
    else {
        //   _labelTitle.text = @"登录失败";
    }
    
}
-(void)tencentDidNotNetWork
{
    // _labelTitle.text=@"无网络连接，请设置网络";
}
-(void)tencentDidLogout{
    
}
#pragma -mark weiboLogin
-(void)weibologin{
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = URL_WeiBo_redirectURI;
    request.scope = @"all";
    [WeiboSDK sendRequest:request];
}

#pragma -mark textField Delegate Method

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == passwordText) {
        loginButton.userInteractionEnabled = NO;
        userInfo *user = [userInfo shareClass];
        NSString *passwordInMD5 = [[NSString stringWithFormat:@"%@Muzzik%@",phoneText.text,passwordText.text] md5Encrypt];
        ASIHTTPRequest *requestsquare = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Login]]];
        [requestsquare addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:phoneText.text,@"phone",passwordInMD5,@"hashedPassword",nil] Method:PostMethod auth:YES];
        __weak ASIHTTPRequest *weakrequestsquare = requestsquare;
        [requestsquare setCompletionBlock :^{
            if ([weakrequestsquare responseStatusCode] == 200) {
                NSData *data = [weakrequestsquare responseData];
                NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                [MuzzikItem addMessageToLocal:responseObject];
                
                
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
            }
            else if ([weakrequestsquare responseStatusCode] == 400)
            {
                [MuzzikItem showNotifyOnView:self.view text:@"请输入正确的手机号"];
            }
            else{
                [MuzzikItem showNotifyOnView:self.view text:@"账号密码错误"];
            }
            
            if ([user.token length]>0) {
                ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Set_Notify]]];
                [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:user.deviceToken,@"deviceToken",@"APN",@"type", nil] Method:PostMethod auth:YES];
                __weak ASIHTTPRequest *weakrequest = request;
                [request setCompletionBlock :^{
                    NSLog(@"JSON: %@", [weakrequest responseString]);
                }];
                [request setFailedBlock:^{
                    
                }];
                [request startAsynchronous];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
        [requestsquare setFailedBlock:^{
            [MuzzikItem showNotifyOnView:self.view text:@"网络请求失败"];
        }];
        [requestsquare startAsynchronous];
    }
    [textField resignFirstResponder];
    return YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
