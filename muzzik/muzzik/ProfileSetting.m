//
//  ProfileSetting.m
//  muzzik
//
//  Created by muzzik on 15/5/7.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "ProfileSetting.h"
#import "HPGrowingTextView.h"
#import "ClassifySelectionVC.h"
#import "ZHPickView.h"
#import "AFViewShaker.h"
#import "TWPhotoPickerController.h"
#import "ASIFormDataRequest.h"
@interface ProfileSetting ()<HPGrowingTextViewDelegate,UITextFieldDelegate,ZHPickViewDelegate,UITableViewDelegate>{
    UIButton *headimage;
    UITextField *NameText;
    HPGrowingTextView *decripText;
    UIView *belowView;
    UILabel *schoolLabel;
    UITextField *schoolText;
    UILabel *companyLabel;
    UITextField *companyText;
    UILabel *birthLabel;
    UITextField *birthText;
    
    UILabel *genderLabel;
    UIButton *maleButton;
    UIButton *femaleButton;
    
    UILabel *classifyLabel;
    UIView *classifyBiew;
    UILabel *addClassifyLabel;
    CGFloat frameHeight;
    BOOL changImage;
    BOOL changeName;
    BOOL changeDescrip;
    BOOL changeSchool;
    BOOL ChangeCompany;
    BOOL changeBirth;
    BOOL changClass;
    BOOL changeGenres;
    UIImage *localImage;
    UITableView *mainTableView;
    UIView *mainView;
}
@property(nonatomic,strong)ZHPickView *pickview;
@property(nonatomic,copy) NSString *birthString;
@property(nonatomic,copy) NSString *genderString;
@end

@implementation ProfileSetting

- (void)viewDidLoad {
    [super viewDidLoad];
    mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    [self.view addSubview:mainTableView];
    mainTableView.delegate = self;
    frameHeight = 152;
    [self initNagationBar:@"编辑个人资料" leftBtn:Constant_backImage rightBtn:3];
    headimage = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-38, 16, 76, 76)];
    [headimage setImage:[UIImage imageNamed:Image_settingavatarscover] forState:UIControlStateNormal];
    headimage.layer.cornerRadius = 38;
    headimage.clipsToBounds = YES;
    [headimage setBackgroundImage:self.userhome.headimage.image forState:UIControlStateNormal];
    [headimage addTarget:self action:@selector(changeHeadImage) forControlEvents:UIControlEventTouchUpInside];
    [mainView addSubview:headimage];
    NameText = [[UITextField alloc] initWithFrame:CGRectMake(50, 92, SCREEN_WIDTH-100, 60)];
    [NameText setTextColor:Color_Text_1];
    [NameText setFont:[UIFont fontWithName:Font_Next_DemiBold size:20]];
    NameText.placeholder = @"用户昵称";
    NameText.delegate = self;
    NameText.textAlignment = NSTextAlignmentCenter;
    NameText.text = [self.profileDic objectForKey:@"name"];
    [NameText setReturnKeyType:UIReturnKeyDone];
    [mainView addSubview:NameText];
    [MuzzikItem addLineOnView:mainView heightPoint:151 toLeft:13 toRight:13 withColor:Color_line_1];
    
    decripText = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(30, 152, SCREEN_WIDTH-60, 80)];
    decripText.placeholder = @"编辑个性签名";
    [decripText setFont:[UIFont fontWithName:Font_Next_DemiBold size:15]];
    decripText.textColor = Color_Text_1;
    [decripText setPlaceholderColor:Color_Text_4];
    decripText.textAlignment = NSTextAlignmentCenter;
    decripText.delegate = self;
    decripText.animateHeightChange = NO;
    [decripText setMaxHeight:120];
    [decripText setReturnKeyType:UIReturnKeyDone];
    if ([[_profileDic allKeys] containsObject:@"description"] && [[self.profileDic objectForKey:@"description"] length]>0) {
        decripText.text = [self.profileDic objectForKey:@"description"];
    }
    
    [mainView addSubview:decripText];
    
    
    belowView = [[UIView alloc] initWithFrame:CGRectMake(13, 193, SCREEN_WIDTH-26, 260)];
    [mainView addSubview:belowView];
    schoolLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 50)];
    schoolLabel.text = @"学校";
    schoolLabel.textColor = Color_Text_2;
    [schoolLabel setFont:[UIFont boldSystemFontOfSize:14]];
    
    schoolText = [[UITextField alloc] initWithFrame:CGRectMake(60, 0, SCREEN_WIDTH-100,50)];
    schoolText.textColor = Color_Text_1;
    schoolText.font = [UIFont systemFontOfSize:15];
    schoolText.placeholder = @"填写学校";
    schoolText.delegate = self;
    if ([[_profileDic allKeys] containsObject:@"school"] && [[self.profileDic objectForKey:@"school"] length]>0) {
        schoolText.text = [self.profileDic objectForKey:@"school"];
    }
    [schoolText setReturnKeyType:UIReturnKeyDone];
    [schoolText setValue:[UIFont boldSystemFontOfSize:15] forKeyPath:@"_placeholderLabel.font"];
    [belowView addSubview:schoolLabel];
    [belowView addSubview:schoolText];
    [MuzzikItem addLineOnView:belowView heightPoint:49 toLeft:0 toRight:26 withColor:Color_line_1];

    companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 30, 50)];
    companyLabel.text = @"公司";
    companyLabel.textColor = Color_Text_2;
    [companyLabel setFont:[UIFont boldSystemFontOfSize:14]];
   
    companyText = [[UITextField alloc] initWithFrame:CGRectMake(60, 50, SCREEN_WIDTH-100,50)];
    companyText.textColor = Color_Text_1;
    companyText.font = [UIFont systemFontOfSize:15];
    companyText.placeholder = @"填写公司";
    companyText.delegate = self;
    if ([[_profileDic allKeys] containsObject:@"company"] && [[self.profileDic objectForKey:@"company"] length]>0) {
        companyText.text = [self.profileDic objectForKey:@"company"];
    }
    [companyText setReturnKeyType:UIReturnKeyDone];
    [companyText setValue:[UIFont boldSystemFontOfSize:15] forKeyPath:@"_placeholderLabel.font"];
    [belowView addSubview:companyLabel];
    [belowView addSubview:companyText];
    [MuzzikItem addLineOnView:belowView heightPoint:99 toLeft:0 toRight:26 withColor:Color_line_1];
    
    birthLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 30, 50)];
    birthLabel.text = @"生日";
    birthLabel.textColor = Color_Text_2;
    [birthLabel setFont:[UIFont boldSystemFontOfSize:14]];
   
    birthText = [[UITextField alloc] initWithFrame:CGRectMake(60, 100, SCREEN_WIDTH-100,50)];
    birthText.textColor = Color_Text_1;
    birthText.font = [UIFont systemFontOfSize:15];
    birthText.placeholder = @"填选生日";
    birthText.delegate = self;
    if ([[_profileDic allKeys] containsObject:@"birthday"] && [[self.profileDic objectForKey:@"birthday"] doubleValue]>0) {
        double unixTimeStamp = [[NSString stringWithFormat:@"%@",[_profileDic objectForKey:@"birthday"]] doubleValue]/1000;
        NSTimeInterval _interval=unixTimeStamp;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
        NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
        [_formatter setLocale:[NSLocale currentLocale]];
        [_formatter setDateFormat:@"YYYY.MM.dd"];
        birthText.text =[_formatter stringFromDate:date];
    }
    [birthText setValue:[UIFont boldSystemFontOfSize:15] forKeyPath:@"_placeholderLabel.font"];
    [belowView addSubview:birthLabel];
    [belowView addSubview:birthText];
    [MuzzikItem addLineOnView:belowView heightPoint:149 toLeft:0 toRight:26 withColor:Color_line_1];
    
    genderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, 30, 50)];
    genderLabel.text = @"性别";
    genderLabel.textColor = Color_Text_2;
    [genderLabel setFont:[UIFont boldSystemFontOfSize:14]];
    
    maleButton = [[UIButton alloc] initWithFrame:CGRectMake(belowView.frame.size.width/2-66, 150, 80, 50)];
    [maleButton setImage:[UIImage imageNamed:@"selectcircleImage"] forState:UIControlStateNormal];
    [maleButton setTitle:@"男" forState:UIControlStateNormal];
    [maleButton addTarget:self action:@selector(setmale) forControlEvents:UIControlEventTouchUpInside];
    [maleButton setTitleColor:[UIColor colorWithHexString:@"555555"] forState:UIControlStateNormal];
    [maleButton setImageEdgeInsets:UIEdgeInsetsMake(12, 0, 12, 60)];
    
    femaleButton = [[UIButton alloc] initWithFrame:CGRectMake(belowView.frame.size.width/2+46, 150, 80, 50)];
    [femaleButton setImage:[UIImage imageNamed:@"selectcircleImage"] forState:UIControlStateNormal];
    [femaleButton setTitle:@"女" forState:UIControlStateNormal];
    [femaleButton addTarget:self action:@selector(setfemale) forControlEvents:UIControlEventTouchUpInside];
    [femaleButton setTitleColor:[UIColor colorWithHexString:@"555555"] forState:UIControlStateNormal];
    [femaleButton setImageEdgeInsets:UIEdgeInsetsMake(12, 0, 12, 60)];
    if ([[_profileDic allKeys] containsObject:@"gender"]) {
        if ([[_profileDic objectForKey:@"gender"] isEqualToString:@"f"]) {
            [femaleButton setImage:[UIImage imageNamed:Image_femaleselectedImage] forState:UIControlStateNormal];
        }
        else if([[_profileDic objectForKey:@"gender"] isEqualToString:@"m"]){
            [maleButton setImage:[UIImage imageNamed:Image_maleselectedImage] forState:UIControlStateNormal];
        }
    }
    UIView *speView = [[UIView alloc] initWithFrame:CGRectMake(belowView.frame.size.width/2+15, 160, 1, 30)];
    [speView setBackgroundColor:Color_line_1];
    
    [belowView addSubview:speView];
    [belowView addSubview:genderLabel];
    [belowView addSubview:maleButton];
    [belowView addSubview:femaleButton];
    [MuzzikItem addLineOnView:belowView heightPoint:199 toLeft:0 toRight:26 withColor:Color_line_1];
    
    classifyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, 30, 50)];
    classifyLabel.text = @"风格";
    classifyLabel.textColor = Color_Text_2;
    [classifyLabel setFont:[UIFont boldSystemFontOfSize:14]];
    
    classifyBiew = [[UIView alloc] initWithFrame:CGRectMake(60, 200, belowView.frame.size.width-60, 60)];
    [classifyBiew addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectClass)]];
    addClassifyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
    addClassifyLabel.textColor = Color_Text_4;
    addClassifyLabel.font = [UIFont systemFontOfSize:15];
    addClassifyLabel.text = @"点击选择您的风格...";
    
    [belowView addSubview:classifyBiew];
    [belowView addSubview:classifyLabel];
    [classifyBiew addSubview: addClassifyLabel];
    [MuzzikItem addLineOnView:belowView heightPoint:1 toLeft:0 toRight:26 withColor:Color_line_1];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditOnView)]];
    [mainTableView setTableHeaderView:mainView];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height{
    [growingTextView setFrame:CGRectMake(30, 152, SCREEN_WIDTH-60, height)];
    frameHeight = 152+height;
    [belowView setFrame:CGRectMake(13, 152+height, SCREEN_WIDTH-26, 260)];
    [mainView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 152+height+260)];
    [mainTableView setTableHeaderView:mainView];
    [mainTableView reloadData];
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView{
    changeDescrip = YES;
    if ([growingTextView.text length]>60) {
        growingTextView.text = [growingTextView.text substringToIndex:60];
    }
}
- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView{
    [growingTextView resignFirstResponder];
    return YES;
}


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == birthText) {
        [self.view endEditing:YES];
         [_pickview remove];
        NSDate *date=[NSDate dateWithTimeIntervalSince1970:654150000];
        _pickview=[[ZHPickView alloc] initDatePickWithDate:date datePickerMode:UIDatePickerModeDate isHaveNavControler:NO];
        _pickview.delegate=self;
        
        [_pickview show];
        return NO;
    }
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
     [_pickview remove];
    if (textField !=NameText) {
        CGRect frame = textField.frame;
        int offset = frameHeight+114+frame.origin.y - (self.view.frame.size.height - 216);//键盘高度216
        NSTimeInterval animationDuration = 0.30f;
        [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        float width = self.view.frame.size.width;
        float height = self.view.frame.size.height;
        if(offset > 0)
        {
            CGRect rect = CGRectMake(0.0f, -offset,width,height);
            self.view.frame = rect;
        }
        [UIView commitAnimations];
    }
    
    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    CGRect rect = CGRectMake(0.0f, 64.0f,width,height);
    self.view.frame = rect;
    [UIView commitAnimations];
    return YES;
}
-(void) endEditOnView{
    
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    CGRect rect = CGRectMake(0.0f, 64.0f,width,height);
    self.view.frame = rect;
    [self.view endEditing:YES];
    [UIView commitAnimations];
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == NameText && ![NameText.text isEqualToString:[_profileDic objectForKey:@"name"]]) {
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString : [NSString stringWithFormat:@"%@%@",BaseURL,URL_check_phone]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:textField.text forKey:@"name"] Method:PostMethod auth:NO];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            if ([weakrequest responseStatusCode] == 200) {
                changeName = YES;
                //
            }
            else if([weakrequest responseStatusCode] == 400){
                [MuzzikItem showNotifyOnView:self.view text:@"用户名超过15个字"];
                [[[AFViewShaker alloc] initWithView:textField] shake];
                [textField becomeFirstResponder];
            }
            else if([weakrequest responseStatusCode] == 406){
                [MuzzikItem showNotifyOnView:self.view text:@"用户名含非法字符"];
                [[[AFViewShaker alloc] initWithView:textField] shake];
                [textField becomeFirstResponder];
            }
            else if([weakrequest responseStatusCode] == 409){
                [MuzzikItem showNotifyOnView:self.view text:@"用户名已被使用"];
                [[[AFViewShaker alloc] initWithView:textField] shake];
                [textField becomeFirstResponder];
            }
        }];
        [requestForm setFailedBlock:^{
            // [SVProgressHUD showErrorWithStatus:@"network error"];
        }];
        [requestForm startAsynchronous];
    }else if(textField == companyText && ![NameText.text isEqualToString:[_profileDic objectForKey:@"company"]]){
        ChangeCompany = YES;
    }
    else if(textField == schoolText && ![NameText.text isEqualToString:[_profileDic objectForKey:@"school"]]){
        changeSchool = YES;
    }

    
}
-(void) changeHeadImage{
    TWPhotoPickerController *photoPicker = [[TWPhotoPickerController alloc] init];
    photoPicker.cropBlock = ^(UIImage *image) {
        localImage = image;
        [headimage setBackgroundImage:image forState:UIControlStateNormal];
    };
    [self presentViewController:photoPicker animated:YES completion:NULL];
}

-(void) setfemale{
    [maleButton setImage:[UIImage imageNamed:@"selectcircleImage"] forState:UIControlStateNormal];
    [femaleButton setImage:[UIImage imageNamed:@"femaleselectedImage"] forState:UIControlStateNormal];
    _genderString= @"f";
}

-(void) setmale{
    [maleButton setImage:[UIImage imageNamed:@"maleselectedImage"] forState:UIControlStateNormal];
    [femaleButton setImage:[UIImage imageNamed:@"selectcircleImage"] forState:UIControlStateNormal];
    
    _genderString = @"m";
}

-(void) selectClass{
    ClassifySelectionVC *class = [[ClassifySelectionVC alloc] init];
    class.classifys = [_profileDic objectForKey:@"genres"];

    [self.navigationController pushViewController:class animated:YES];
}
-(void)rightBtnAction:(UIButton *)sender{

    ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString : [NSString stringWithFormat:@"%@%@",BaseURL,URL_Update_Profile]]];
    NSMutableDictionary *dic= [NSMutableDictionary dictionary];
   
    if (changeName) {
        [dic setObject:NameText.text forKey:@"name"];
    }
    if (changeSchool) {
        [dic setObject:schoolText.text forKey:@"school"];
    }
    if (ChangeCompany) {
        [dic setObject:companyText.text forKey:@"company"];
    }
    if ([_birthString length]>0) {
        [dic setObject:_birthString forKey:@"birthday"];
    }
    if (changeDescrip) {
        [dic setObject:decripText.text forKey:@"description"];
    }
    if ([_genderString length]>0) {
        [dic setObject:_genderString forKey:@"gender"];
    }
    if (changeGenres) {
        [dic setObject:[_profileDic objectForKey:@"genres"] forKey:@"genres"];
    }
    if (localImage) {
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString : [NSString stringWithFormat:@"%@%@",BaseURL,URL_Upload_Image]]];
        
        [requestForm addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@    %@",[weakrequest originalURL],[weakrequest requestHeaders]);
            NSLog(@"%@",[weakrequest responseHeaders]);
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            if ([weakrequest responseStatusCode] == 200) {
                NSDictionary *imagedic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
                
                ASIFormDataRequest *interRequest = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:[imagedic objectForKey:@"url"]]];
                [ASIFormDataRequest clearSession];
                [interRequest setPostFormat:ASIMultipartFormDataPostFormat];
                [interRequest addRequestHeader:@"Host" value:@"upload.qiniu.com"];
                [interRequest setPostValue:[[imagedic objectForKey:@"data"] objectForKey:@"token"] forKey:@"token"];
                NSData *imageData = UIImageJPEGRepresentation(localImage, 0.75);
                [interRequest addData:imageData forKey:@"file"];
                __weak ASIFormDataRequest *form = interRequest;
                [interRequest buildRequestHeaders];
                NSLog(@"header:%@",interRequest.requestHeaders);
                [interRequest setCompletionBlock:^{
                    NSDictionary *keydic = [NSJSONSerialization JSONObjectWithData:[form responseData] options:NSJSONReadingMutableContainers error:nil];
                    ASIHTTPRequest *updateImageRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL,URL_Update_Profile]]];
                    [dic setObject:[keydic objectForKey:@"key"] forKey:@"avatar"];
                    [updateImageRequest addBodyDataSourceWithJsonByDic:dic Method:PostMethod auth:YES];
                    __weak ASIHTTPRequest *WeakImageRequest = updateImageRequest;
                    [updateImageRequest setCompletionBlock:^{
                        if ([WeakImageRequest responseStatusCode]==200) {
                            self.userhome.headimage.image = localImage;
                            [self.navigationController popViewControllerAnimated:YES];
                            
                        }
                    }];
                    [updateImageRequest setFailedBlock:^{
                        NSLog(@"%@",[WeakImageRequest error]);
                    }];
                    [updateImageRequest startAsynchronous];
                }];
                [interRequest setFailedBlock:^{
                    NSLog(@"%@",[form responseString]);
                }];
                [interRequest startAsynchronous];
                
            }
            else if([weakrequest responseStatusCode] == 400){
            }
            else if([weakrequest responseStatusCode] == 409){
                
            }
        }];
        [requestForm setFailedBlock:^{
            // [SVProgressHUD showErrorWithStatus:@"network error"];
        }];
        [requestForm startAsynchronous];
    }
    else{
        ASIHTTPRequest *updateImageRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL,URL_Update_Profile]]];
        [updateImageRequest addBodyDataSourceWithJsonByDic:dic Method:PostMethod auth:YES];
        __weak ASIHTTPRequest *WeakImageRequest = updateImageRequest;
        [updateImageRequest setCompletionBlock:^{
            if ([WeakImageRequest responseStatusCode]==200) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
        [updateImageRequest setFailedBlock:^{
            NSLog(@"%@",[WeakImageRequest error]);
        }];
        [updateImageRequest startAsynchronous];
    }
    [requestForm addBodyDataSourceWithJsonByDic:dic Method:PostMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = requestForm;
    [requestForm setCompletionBlock :^{
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"%@",[weakrequest responseString]);
        NSLog(@"%d",[weakrequest responseStatusCode]);
        if ([weakrequest responseStatusCode] == 200 && [[dic objectForKey:@"result"] boolValue]) {
            [self.navigationController popViewControllerAnimated:YES];
            //
        }
    }];
    [requestForm setFailedBlock:^{
        // [SVProgressHUD showErrorWithStatus:@"network error"];
    }];
    [requestForm startAsynchronous];
}
#pragma mark ZhpickVIewDelegate

-(void)toobarDonBtnHaveClick:(ZHPickView *)pickView resultString:(NSString *)resultString{
    _birthString = resultString;
    birthText.text = [_birthString stringByReplacingOccurrencesOfString:@"-" withString:@"."];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
