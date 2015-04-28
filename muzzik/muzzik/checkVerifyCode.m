//
//  checkVerifyCode.m
//  muzzik
//
//  Created by muzzik on 15/4/15.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "checkVerifyCode.h"
#import "NSString+MD5.h"
#import "setNameVc.h"
@interface checkVerifyCode ()<UITextFieldDelegate>{
    UITextField *checkcode;
}
@end
@implementation checkVerifyCode

-(void)viewDidLoad{
    [super viewDidLoad];
    [self initNagationBar:@"验证手机号" leftBtn:Constant_backImage rightBtn:0];
    UIImageView *checkImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"messageImage"]];
    [checkImage setFrame:CGRectMake(20, 15, 15, 15)];
    [self.view addSubview:checkImage];
    
    checkcode = [[UITextField alloc] initWithFrame:CGRectMake(45, 0 , SCREEN_WIDTH-50, 45)];
    
    [checkcode setClearButtonMode:UITextFieldViewModeAlways];
    [checkcode setPlaceholder:@"请输入收到的验证码"];
    checkcode.delegate = self;
    [checkcode setTextColor:[UIColor colorWithHexString:@"555555"]];
    [checkcode setKeyboardType:UIKeyboardTypePhonePad];
    [checkcode setFont:[UIFont systemFontOfSize:15]];
    [self.view addSubview:checkcode];
    [MuzzikItem addLineOnView:self.view heightPoint:45 toLeft:13 toRight:13 withColor:Color_underLine];
    UIButton *nextButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-67, SCREEN_HEIGHT-133, 54, 52)];
    [nextButton setImage:[UIImage imageNamed:Image_Next] forState:UIControlStateNormal];
    [self.view addSubview: nextButton];
    [nextButton addTarget:self action:@selector(summitAction) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *tapOnview = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tapOnview];
}
-(void)getVerifyCode{
    ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_GetVerifiCode]]];
    [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:self.phoneNumber forKey:@"phone"] Method:PostMethod auth:NO];
    __weak ASIHTTPRequest *weakrequest = requestForm;
    [requestForm setCompletionBlock :^{
         NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"%@",[weakrequest responseString]);
        NSLog(@"%d",[weakrequest responseStatusCode]);
        if ([weakrequest responseStatusCode] == 200 && [[dic objectForKey:@"result"] boolValue]) {
            
        }
    }];
    [requestForm setFailedBlock:^{
        // [SVProgressHUD showErrorWithStatus:@"network error"];
    }];
    [requestForm startAsynchronous];
}


-(void) summitAction{
    setNameVc *setname = [[setNameVc alloc] init];
    [self.navigationController pushViewController:setname animated:YES];
    ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_register]]];
    NSString *passwordInMD5 = [[NSString stringWithFormat:@"%@Muzzik%@",self.phoneNumber,self.passWord] md5Encrypt];
    
    [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:self.phoneNumber,@"phone",passwordInMD5,@"hashedPassword",checkcode.text,@"code",nil] Method:PostMethod auth:NO];
    __weak ASIHTTPRequest *weakrequest = requestForm;
    [requestForm setCompletionBlock :^{
        NSLog(@"%@",[weakrequest responseString]);
        NSLog(@"%d",[weakrequest responseStatusCode]);
        if ([weakrequest responseStatusCode] == 200) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
            userInfo *user = [userInfo shareClass];
            user.token = [dic objectForKey:@"token"];
            setNameVc *setname = [[setNameVc alloc] init];
            [self.navigationController pushViewController:setname animated:YES];
        }
    }];
    [requestForm setFailedBlock:^{
        NSLog(@"%@    %@   %@",[weakrequest responseString],[weakrequest responseHeaders],[weakrequest responseCookies]);
        // [SVProgressHUD showErrorWithStatus:@"network error"];
    }];
    [requestForm startAsynchronous];
}

-(NSAttributedString *)formatAttrItem:(NSString *)content color:(UIColor *)color font:(UIFont *)font
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.maximumLineHeight = 25.f;
    paragraphStyle.minimumLineHeight = 15.f;
    paragraphStyle.lineHeightMultiple = 20.f;
    
    NSDictionary *attrDict = @{NSParagraphStyleAttributeName: paragraphStyle,
                               NSForegroundColorAttributeName:color,
                               NSFontAttributeName:font};
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]
                                          initWithString: content
                                          attributes:attrDict];
    return attrStr;
}
@end
