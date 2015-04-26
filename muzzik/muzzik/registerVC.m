//
//  registerVC.m
//  muzzik
//
//  Created by muzzik on 15/4/12.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "registerVC.h"
#import "NSString+MD5.h"
#import "TeachViewController.h"
#import "checkVerifyCode.h"
#import "AFViewShaker.h"
@interface registerVC ()<UITextFieldDelegate>{
    UITextField *phoneText;
    UITextField *passwordText;
    BOOL isOk;
    UIButton *visibleButton;
    UILabel *tipsLabel;
}

@end

@implementation registerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNagationBar:@"填写登录信息" leftBtn:Constant_backImage rightBtn:0];
    UIImageView *phoneImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"phonenumImage"]];
    [phoneImage setFrame:CGRectMake(20, 15, 9, 15)];
    [self.view addSubview:phoneImage];
    
    phoneText = [[UITextField alloc] initWithFrame:CGRectMake(45, 0 , SCREEN_WIDTH-50, 45)];
    [phoneText setKeyboardType:UIKeyboardTypePhonePad];
    [phoneText setClearButtonMode:UITextFieldViewModeAlways];
    [phoneText setPlaceholder:@"手机号"];
    phoneText.delegate = self;
    [phoneText setTextColor:[UIColor colorWithHexString:@"555555"]];
    [phoneText setFont:[UIFont systemFontOfSize:15]];
    [self.view addSubview:phoneText];
    [MuzzikItem addLineOnView:self.view heightPoint:45 toLeft:13 toRight:13 withColor:Color_underLine];
    
    UIImageView *passwordImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"passwordImage-1"]];
    [passwordImage setFrame:CGRectMake(20, 60, 12, 15)];
    [self.view addSubview:passwordImage];
    
    passwordText = [[UITextField alloc] initWithFrame:CGRectMake(45, 45, SCREEN_WIDTH-55, 45)];
    [passwordText setPlaceholder:@"密码"];
    passwordText.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldChanged:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:passwordText];
    [passwordText setTextColor:[UIColor colorWithHexString:@"555555"]];
    [passwordText setFont:[UIFont systemFontOfSize:15]];
    [passwordText setSecureTextEntry:YES];
    [self.view addSubview:passwordText];
    
    visibleButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-30, 60, 20, 20)];
    [visibleButton setImage:[UIImage imageNamed:@"visibleImage"] forState:UIControlStateNormal];
    [visibleButton addTarget:self action:@selector(setVisible) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:visibleButton];
    [visibleButton setHidden:YES];
    UIFont *font = [UIFont boldSystemFontOfSize:12];
    [MuzzikItem addLineOnView:self.view heightPoint:90 toLeft:13 toRight:13 withColor:Color_underLine];
    UILabel * protocolLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-30, 20)];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
    NSString *itemStr = @"下一步即表示同意";
    NSAttributedString *item = [self formatAttrItem:itemStr color:[UIColor colorWithHexString:@"a8acbb"] font:font];
    [text appendAttributedString:item];
    NSString *itemStr1 = @"《Muzzik用户协议》";
    NSAttributedString *item1 = [self formatAttrItem:itemStr1 color:[UIColor colorWithHexString:@"366ab3"] font:font];
    [text appendAttributedString:item1];
    protocolLabel.attributedText = text;
    UIView *tapview = [[UIView alloc] initWithFrame:CGRectMake(15, 105, SCREEN_WIDTH-30, 20)];
    [tapview addSubview:protocolLabel];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickProtol)];
    [tapview addGestureRecognizer:tap];
    [self.view addSubview:tapview];
    
    tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 125, SCREEN_WIDTH-30, 20)];
    tipsLabel.font = [UIFont boldSystemFontOfSize:12];
    [tipsLabel setTextColor:[UIColor colorWithHexString:@"f26a3d"]];
    [self.view addSubview:tipsLabel];
    UIButton *nextButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-67, SCREEN_HEIGHT-133, 54, 52)];
    [nextButton setBackgroundImage:[UIImage imageNamed:@"backgroundImage"] forState:UIControlStateNormal];
    [nextButton setImage:[UIImage imageNamed:@"nextImage"] forState:UIControlStateNormal];
    [self.view addSubview: nextButton];
    [nextButton addTarget:self action:@selector(checkAction) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *tapOnview = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tapOnview];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setHidden:NO];
}
-(void) textFieldChanged:(NSNotification *)info{
    UITextField *textField = info.object;
    if ([textField.text length]>0) {
        [visibleButton setHidden:NO];
    }
    else{
        [visibleButton setHidden:YES];
    }
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == phoneText && [textField.text length]>0) {
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_check_phone]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:phoneText.text forKey:@"phone"] Method:PostMethod auth:NO];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
             NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
            if ([weakrequest responseStatusCode] == 200 && [[dic objectForKey:@"result"] boolValue]) {
                isOk = YES;
            }else{
                [MuzzikItem showView:tipsLabel Text:@"手机号已被注册"];
                
                isOk = NO;
            }
        }];
        [requestForm setFailedBlock:^{
           // [SVProgressHUD showErrorWithStatus:@"network error"];
        }];
        [requestForm startAsynchronous];
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
-(void) setVisible{
    if (passwordText.secureTextEntry) {
        [passwordText setSecureTextEntry:NO];
    }
    else{
        [passwordText setSecureTextEntry:YES];
    }
    
}
-(void)clickProtol{
    NSLog(@"11");
    TeachViewController *teach = [[TeachViewController alloc] initWithNibName:@"TeachViewController" bundle:nil];
    [self.navigationController pushViewController:teach animated:YES];
}
-(void)checkAction{
    if (isOk) {
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString : [NSString stringWithFormat:@"%@%@",BaseURL,URL_GetVerifiCode]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:phoneText.text forKey:@"phone"] Method:PostMethod auth:NO];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            if ([weakrequest responseStatusCode] == 200 && [[dic objectForKey:@"result"] boolValue]) {
                checkVerifyCode *checkVc = [[checkVerifyCode alloc] init];
                checkVc.phoneNumber = phoneText.text;
                checkVc.passWord = passwordText.text;
                
                [self.navigationController pushViewController:checkVc animated:YES];
            }
        }];
        [requestForm setFailedBlock:^{
            // [SVProgressHUD showErrorWithStatus:@"network error"];
        }];
        [requestForm startAsynchronous];
    }
    else{
        [[[AFViewShaker alloc] initWithView:phoneText] shake];
    }

    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
