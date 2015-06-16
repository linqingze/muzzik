//
//  setGenderVC.m
//  muzzik
//
//  Created by muzzik on 15/4/16.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "setGenderVC.h"

@implementation setGenderVC
-(void)viewDidLoad{
    [super viewDidLoad];
    [self initNagationBar:@"生日/性别" leftBtn:Constant_backImage rightBtn:0];
    UIImageView *birthImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"birthImage"]];
    [birthImage setFrame:CGRectMake(22, 15, 11, 15)];
    [self.view addSubview:birthImage];
    
    
    birthText = [[UITextField alloc] initWithFrame:CGRectMake(45, 0 , SCREEN_WIDTH-50, 45)];
    
    [birthText setClearButtonMode:UITextFieldViewModeAlways];
    [birthText setPlaceholder:@"选择出生日期"];
    birthText.delegate = self;
    [birthText setTextColor:[UIColor colorWithHexString:@"555555"]];
    [birthText setKeyboardType:UIKeyboardTypePhonePad];
    [birthText setFont:[UIFont systemFontOfSize:15]];
    [self.view addSubview:birthText];
    [MuzzikItem addLineOnView:self.view heightPoint:45 toLeft:13 toRight:13 withColor:Color_underLine];
    UIImageView *genderImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"genderImage"]];
    [genderImage setFrame:CGRectMake(21, 61, 15, 13)];
    [self.view addSubview:genderImage];
    maleButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-90, 45, 80, 45)];
    [maleButton setImage:[UIImage imageNamed:@"selectcircleImage"] forState:UIControlStateNormal];
    [maleButton setTitle:@"男" forState:UIControlStateNormal];
    [maleButton addTarget:self action:@selector(setmale) forControlEvents:UIControlEventTouchUpInside];
    [maleButton setTitleColor:[UIColor colorWithHexString:@"555555"] forState:UIControlStateNormal];
    [maleButton setImageEdgeInsets:UIEdgeInsetsMake(12, 0, 12, 60)];
    [self.view addSubview:maleButton];
    
    femaleButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2+10, 45, 80, 45)];
    [femaleButton setImage:[UIImage imageNamed:@"selectcircleImage"] forState:UIControlStateNormal];
    [femaleButton setTitle:@"女" forState:UIControlStateNormal];
    [femaleButton addTarget:self action:@selector(setfemale) forControlEvents:UIControlEventTouchUpInside];
    [femaleButton setTitleColor:[UIColor colorWithHexString:@"555555"] forState:UIControlStateNormal];
    [femaleButton setImageEdgeInsets:UIEdgeInsetsMake(12, 0, 12, 60)];
    [self.view addSubview:femaleButton];
    [MuzzikItem addLineOnView:self.view heightPoint:90 toLeft:13 toRight:13 withColor:Color_underLine];
    UIButton *nextButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-67, SCREEN_HEIGHT-133, 54, 52)];
    [nextButton setImage:[UIImage imageNamed:@"cycledone"] forState:UIControlStateNormal];
    [self.view addSubview: nextButton];
    [nextButton addTarget:self action:@selector(summitAction) forControlEvents:UIControlEventTouchUpInside];
}
-(void) setfemale{
    [maleButton setImage:[UIImage imageNamed:@"selectcircleImage"] forState:UIControlStateNormal];
    [femaleButton setImage:[UIImage imageNamed:@"femaleselectedImage"] forState:UIControlStateNormal];
    gender = @"f";
}

-(void) setmale{
    [maleButton setImage:[UIImage imageNamed:@"maleselectedImage"] forState:UIControlStateNormal];
    [femaleButton setImage:[UIImage imageNamed:@"selectcircleImage"] forState:UIControlStateNormal];
    gender = @"m";
}
-(void) summitAction{
    if ([birthText.text length] == 0 &&[gender length] == 0) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else{
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString : [NSString stringWithFormat:@"%@%@",BaseURL,URL_Update_Profile]]];
        NSMutableDictionary *dic= [NSMutableDictionary dictionaryWithObjectsAndKeys:gender,@"gender",birthText.text,@"birthday", nil];
        if ([gender length] == 0) {
            [dic removeObjectForKey:@"gender"];
        }
        if ([birthText.text length] == 0) {
            [dic removeObjectForKey:@"birthday"];
        }
        [requestForm addBodyDataSourceWithJsonByDic:dic Method:PostMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
             NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            if ([weakrequest responseStatusCode] == 200 && [[dic objectForKey:@"result"] boolValue]) {
                [MuzzikItem showNotifyOnView:self.navigationController.view text:@"注册成功"];
                [self dismissViewControllerAnimated:YES completion:nil];
                //
            }
        }];
        [requestForm setFailedBlock:^{
            // [SVProgressHUD showErrorWithStatus:@"network error"];
        }];
        [requestForm startAsynchronous];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [textField endEditing:YES];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    NSDate *date=[NSDate dateWithTimeIntervalSinceNow:8000000];
    pickview=[[ZHPickView alloc] initDatePickWithDate:date datePickerMode:UIDatePickerModeDate isHaveNavControler:NO];
    pickview.delegate=self;
    [pickview setBackgroundColor:[UIColor whiteColor]];
    [pickview show];
    return NO;
}
-(void)toobarDonBtnHaveClick:(ZHPickView *)pickView resultString:(NSString *)resultString{
    
    birthText.text=resultString;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
}


@end
