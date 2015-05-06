//
//  DetailUser.m
//  muzzik
//
//  Created by muzzik on 15/5/5.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "DetailUser.h"
#import "UIImageView+WebCache.h"
@interface DetailUser ()<UIScrollViewDelegate>{
    UIScrollView *mainscroll;
    UIImageView *headimage;
    UIButton *attentionButton;
    UILabel *nameLabel;
    UIImageView *genderImage;
    UILabel *descriptionLabel;
    UIImageView *schoolImage;
    UILabel *schoolLabel;
    UIImageView *birthImage;
    UILabel *birthLabel;
    UIImageView *constellationImage;
    UILabel *constellationLabel;
    UIImageView *companyImage;
    UILabel *companyLabel;
    UIView *genresView;
    UIView *messageView;
}

@property (nonatomic,retain) NSDictionary *profileDic;
@end

@implementation DetailUser

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNagationBar:@"Ta" leftBtn:Constant_backImage rightBtn:0];
    mainscroll = [[UIScrollView alloc] initWithFrame:self.view.frame];
    mainscroll.bounces = YES;
    mainscroll.delegate = self;
    [self.view addSubview:mainscroll];
    headimage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
    [headimage setAlpha:0];
    attentionButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, 16, 85, 23)];
    [attentionButton addTarget:self action:@selector(attentionAction) forControlEvents:UIControlEventTouchUpInside];

    
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, SCREEN_WIDTH/2, 30, 30)];
    [nameLabel setFont:[UIFont fontWithName:Font_Next_DemiBold size:24]];
    nameLabel.textColor = [UIColor whiteColor];
    
    genderImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:Image_profilefemaleImage]];
    UIImageView *coverImage = [[UIImageView alloc] initWithFrame:headimage.frame];
    [coverImage setImage:[UIImage imageNamed:Image_prifilebgcover]];
    [mainscroll addSubview:headimage];
    [mainscroll addSubview:coverImage];
    [mainscroll addSubview:nameLabel];
    [mainscroll addSubview:genderImage];
    [mainscroll addSubview:attentionButton];

    
    ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@",BaseURL,self.uid]]];
    [requestForm addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = requestForm;
    [requestForm setCompletionBlock :^{
        NSLog(@"%@",[weakrequest responseString]);
        NSLog(@"%d",[weakrequest responseStatusCode]);
        if ([weakrequest responseStatusCode] == 200) {
            _profileDic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData]  options:NSJSONReadingMutableContainers error:nil];
            [self.view setNeedsLayout];
        }
        else{
            //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
        }
    }];
    [requestForm setFailedBlock:^{
        NSLog(@"%@",[weakrequest error]);
        NSLog(@"hhhh%@  kkk%@",[weakrequest responseString],[weakrequest responseHeaders]);
        [userInfo checkLoginWithVC:self];
    }];
    [requestForm startAsynchronous];
    // Do any additional setup after loading the view.
}
-(void)viewDidLayoutSubviews {
    if (_profileDic) {
        if ([[_profileDic objectForKey:@"isFollow"] boolValue] &&[[_profileDic objectForKey:@"isFans"] boolValue]) {
            [attentionButton setImage:[UIImage imageNamed:Image_profilefolloweacherother] forState:UIControlStateNormal];
            [attentionButton setFrame:CGRectMake(SCREEN_WIDTH-85, 16, 65, 23)];
        }else if([[_profileDic objectForKey:@"isFollow"] boolValue]){
            [attentionButton setImage:[UIImage imageNamed:Image_profilefollowed] forState:UIControlStateNormal];
            [attentionButton setFrame:CGRectMake(SCREEN_WIDTH-75, 16, 55, 23)];
        }else{
            [attentionButton setImage:[UIImage imageNamed:Image_profilefollow] forState:UIControlStateNormal];
            [attentionButton setFrame:CGRectMake(SCREEN_WIDTH-65, 16, 45, 23)];
        }
        NSArray *dicKeys = [_profileDic allKeys];
        if ([dicKeys containsObject:@"avatar"]) {
            [headimage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,[_profileDic objectForKey:@"avatar"]]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [headimage setAlpha:1];
            }];
        }
        if ([dicKeys containsObject:@"name"]) {
            nameLabel.text = [_profileDic objectForKey:@"name"];
            [nameLabel sizeToFit];
            [nameLabel setFrame:CGRectMake(16, SCREEN_WIDTH/2-nameLabel.frame.size.height, nameLabel.frame.size.width, nameLabel.frame.size.height)];
            [genderImage setFrame:CGRectMake(CGRectGetMaxX(nameLabel.frame)+6, CGRectGetMidY(nameLabel.frame)-10, 16, 16)];
            if ([[_profileDic objectForKey:@"gender"] isEqualToString:@"m"]) {
                [genderImage setImage:[UIImage imageNamed:Image_profilemaleImage]];
            }else{
                [genderImage setImage:[UIImage imageNamed:Image_profilefemaleImage]];
            }
        }
        
        CGFloat recordHeight = 288;
        if ([dicKeys containsObject:@"astro"] && [[_profileDic objectForKey:@"astro"] length]>0) {
            constellationImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, recordHeight+5, 8, 8)];
            [constellationImage setImage:[UIImage imageNamed:Image_profileconstellationImage]];
            [mainscroll addSubview:constellationImage];
            constellationLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, recordHeight, SCREEN_WIDTH/2-50, 20)];
            [constellationLabel setText:[_profileDic objectForKey:@"astro"]];
            [constellationLabel setTextColor:Color_Text_4];
            [constellationLabel setFont:[UIFont systemFontOfSize:12]];
            [mainscroll addSubview:constellationLabel];
            recordHeight = recordHeight-28;
            
        }
        if ([dicKeys containsObject:@"birthday"] && [_profileDic objectForKey:@"birthday"]>0) {
            double unixTimeStamp = [[NSString stringWithFormat:@"%@",[_profileDic objectForKey:@"birthday"]] doubleValue]/1000;
            NSTimeInterval _interval=unixTimeStamp;
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
            NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
            [_formatter setLocale:[NSLocale currentLocale]];
            [_formatter setDateFormat:@"YYYY.MM.dd"];
            NSString *_date=[_formatter stringFromDate:date];
            
            
            birthImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, recordHeight+5, 8, 8)];
            [birthImage setImage:[UIImage imageNamed:Image_profilebirthImage]];
            [mainscroll addSubview:birthImage];
            birthLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, recordHeight, SCREEN_WIDTH/2-50, 20)];
            [birthLabel setText:_date];
            [birthLabel setTextColor:Color_Text_4];
            [birthLabel setFont:[UIFont systemFontOfSize:12]];
            [mainscroll addSubview:birthLabel];
            recordHeight = recordHeight-28;
            
        }
        if ([dicKeys containsObject:@"company"] && [[_profileDic objectForKey:@"company"] length]>0) {
            companyImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, recordHeight+5, 8, 8)];
            [companyImage setImage:[UIImage imageNamed:Image_profilejobImage]];
            [mainscroll addSubview:companyImage];
            companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, recordHeight, SCREEN_WIDTH/2-50, 20)];
            [companyLabel setText:[_profileDic objectForKey:@"company"]];
            [companyLabel setTextColor:Color_Text_4];
            [companyLabel setFont:[UIFont systemFontOfSize:12]];
            [mainscroll addSubview:companyLabel];
            recordHeight = recordHeight-28;
            
        }else if([dicKeys containsObject:@"school"] && [[_profileDic objectForKey:@"school"] length]>0){
            schoolImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, recordHeight+5, 8, 8)];
            [schoolImage setImage:[UIImage imageNamed:Image_profilejobImage]];
            [mainscroll addSubview:schoolImage];
            schoolLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, recordHeight, SCREEN_WIDTH/2-50, 20)];
            [schoolLabel setText:[_profileDic objectForKey:@"school"]];
            [schoolLabel setTextColor:Color_Text_4];
            [schoolLabel setFont:[UIFont systemFontOfSize:12]];
            [mainscroll addSubview:schoolLabel];
            recordHeight = recordHeight-28;
        }
        if ([dicKeys containsObject:@"description"]) {
            UILabel *temp = [[UILabel alloc] initWithFrame:CGRectMake(16, SCREEN_WIDTH/2, SCREEN_WIDTH-32, 100)];
            temp.numberOfLines = 0;
            [temp setFont:[UIFont systemFontOfSize:12]];
            temp.text =  [_profileDic objectForKey:@"description"];
            [temp sizeToFit];
            descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, SCREEN_WIDTH/2, SCREEN_WIDTH-32, temp.frame.size.height)];
            descriptionLabel.numberOfLines = 0;
            
            [descriptionLabel setFont:[UIFont systemFontOfSize:12]];
            descriptionLabel.text = [_profileDic objectForKey:@"description"];
            [descriptionLabel setTextColor:[UIColor whiteColor]];
            [mainscroll addSubview:descriptionLabel];
        }
        
        
        if ([dicKeys containsObject:@"genres"] && [[_profileDic objectForKey:@"genres"] count]>0) {
            genresView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-10, SCREEN_WIDTH-88, SCREEN_WIDTH/2-6, 76)];
            [mainscroll addSubview: genresView];
            int local = SCREEN_WIDTH/2-6;
            int localheight = 56;
            for (NSDictionary * dic in [_profileDic objectForKey:@"genres"]) {
                UILabel *tempLabel = [[UILabel alloc ] initWithFrame:CGRectMake(0, 0, 100, 20)];
                [tempLabel setFont:[UIFont systemFontOfSize:12]];
                [tempLabel setText:[dic objectForKey:@"data"]];
                [tempLabel sizeToFit];
                if (local- tempLabel.frame.size.width-20<0) {
                    localheight = localheight-28;
                    local = SCREEN_WIDTH/2-6;
                    if (localheight<0) {
                        break;
                    }
                }
                UILabel *tagLabel = [[UILabel alloc ] initWithFrame:CGRectMake(local- tempLabel.frame.size.width-20, localheight, tempLabel.frame.size.width+20, 20)];
                [tagLabel setFont:[UIFont systemFontOfSize:12]];
                [tagLabel setText:[dic objectForKey:@"data"]];
                tagLabel.textAlignment = NSTextAlignmentCenter;
                [tagLabel setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.2]];
                tagLabel.layer.cornerRadius = 10;
                tagLabel.clipsToBounds = YES;
                [tagLabel setTextColor:Color_line_1];
                
                [genresView addSubview:tagLabel];
                local = local- tempLabel.frame.size.width-28;
            }
        }
        messageView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_WIDTH, SCREEN_WIDTH, 50)];
        [messageView setBackgroundColor: [ UIColor whiteColor]];
        [mainscroll addSubview:messageView];
         
    }
   
    
}


-(void)attentionAction{

    if ([[_profileDic objectForKey:@"isFollow"] boolValue]) {
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_user_Unfollow]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:self.uid forKey:@"_id"] Method:PostMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            
            if ([weakrequest responseStatusCode] == 200) {
                [_profileDic setValue:[NSNumber numberWithBool:NO] forKey:@"isFollow"];
                [attentionButton setImage:[UIImage imageNamed:Image_profilefollow] forState:UIControlStateNormal];
                [attentionButton setFrame:CGRectMake(SCREEN_WIDTH-65, 16, 45, 23)];
            }
            else{
                //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
            }
        }];
        [requestForm setFailedBlock:^{
            NSLog(@"%@",[weakrequest error]);
            NSLog(@"hhhh%@  kkk%@",[weakrequest responseString],[weakrequest responseHeaders]);
            [userInfo checkLoginWithVC:self];
        }];
        [requestForm startAsynchronous];
    }else{
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_User_Follow]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:self.uid forKey:@"_id"] Method:PostMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            
            if ([weakrequest responseStatusCode] == 200) {
                [_profileDic setValue:[NSNumber numberWithBool:YES] forKey:@"isFollow"];
                if ([[_profileDic objectForKey:@"isFollow"] boolValue] &&[[_profileDic objectForKey:@"isFans"] boolValue]) {
                    [attentionButton setImage:[UIImage imageNamed:Image_profilefolloweacherother] forState:UIControlStateNormal];
                    [attentionButton setFrame:CGRectMake(SCREEN_WIDTH-85, 16, 65, 23)];
                }else{
                    [attentionButton setImage:[UIImage imageNamed:Image_profilefollowed] forState:UIControlStateNormal];
                    [attentionButton setFrame:CGRectMake(SCREEN_WIDTH-75, 16, 55, 23)];
                }
            }
            else{
                //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
            }
        }];
        [requestForm setFailedBlock:^{
            NSLog(@"%@",[weakrequest error]);
            NSLog(@"hhhh%@  kkk%@",[weakrequest responseString],[weakrequest responseHeaders]);
            [userInfo checkLoginWithVC:self];
        }];
        [requestForm startAsynchronous];
    }

}
@end
