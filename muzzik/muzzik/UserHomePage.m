//
//  UserHomePage.m
//  muzzik
//
//  Created by muzzik on 15/5/4.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "UserHomePage.h"
#import "UIImageView+WebCache.h"
#import "ProfileSetting.h"
@interface UserHomePage ()<UIScrollViewDelegate>{
    UIScrollView *mainscroll;
    UIImageView *headimage;
    UIButton *profileButton;
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
    UILabel *movedCount;
    UILabel *MuzzikCount;
    UILabel *topicCount;
    UILabel *followCount;
    UILabel *fansCount;
    UILabel *songCount;
    
}

@property (nonatomic,retain) NSDictionary *profileDic;
@end

@implementation UserHomePage

- (void)viewDidLoad {
    [super viewDidLoad];
    mainscroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    mainscroll.bounces = YES;
    mainscroll.delegate = self;
    [self.view addSubview:mainscroll];
    headimage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
    [headimage setAlpha:0];
    profileButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-120, 16, 85, 23)];
    [profileButton setImage:[UIImage imageNamed:Image_editInformationImage] forState:UIControlStateNormal];
    [profileButton addTarget:self action:@selector(editProfile) forControlEvents:UIControlEventTouchUpInside];
    
    
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
    [mainscroll addSubview:profileButton];
    
    
    constellationImage = [[UIImageView alloc] init];
    constellationLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 5, SCREEN_WIDTH/2-50, 20)];
    
    birthImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 5, 8, 8)];
    birthLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, SCREEN_WIDTH/2-50, 20)];
    
    companyImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 5, 8, 8)];
    companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, SCREEN_WIDTH/2-50, 20)];
    
    schoolImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 5, 8, 8)];
    schoolLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, SCREEN_WIDTH/2-50, 20)];
    descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, SCREEN_WIDTH/2, SCREEN_WIDTH-32,0)];
    
    messageView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_WIDTH, SCREEN_WIDTH, SCREEN_WIDTH/320.0*204.0)];
    [messageView setBackgroundColor: [ UIColor whiteColor]];
    CGFloat scale = SCREEN_WIDTH/320.0;
    CGFloat height = scale*204.0;
    CGFloat width = SCREEN_WIDTH;
    UIButton *muzzikButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width/3, height/2)];
    [muzzikButton setImage:[UIImage imageNamed:Image_profiletweetImage] forState:UIControlStateNormal];
    [muzzikButton setImageEdgeInsets:UIEdgeInsetsMake(-15, 0, 0, 0)];
    [muzzikButton addTarget:self action:@selector(showMuzziks) forControlEvents:UIControlEventTouchUpInside];
    [messageView addSubview:muzzikButton];
    MuzzikCount = [[UILabel alloc] initWithFrame:CGRectMake(0, height/2-scale*30, width/3, 20)];
    [MuzzikCount setTextColor:Color_Text_2];
    MuzzikCount.textAlignment = NSTextAlignmentCenter;
    [MuzzikCount setFont:[UIFont fontWithName:Font_Next_DemiBold size:12]];
    [messageView addSubview:MuzzikCount];
    
    UIButton *movesButton = [[UIButton alloc] initWithFrame:CGRectMake(width/3, 0, width/3, height/2)];
    [movesButton setImage:[UIImage imageNamed:Image_profilelikeImage] forState:UIControlStateNormal];
    [movesButton addTarget:self action:@selector(showMoveds) forControlEvents:UIControlEventTouchUpInside];
    [messageView addSubview:movesButton];
    [movesButton setImageEdgeInsets:UIEdgeInsetsMake(-15, 0, 0, 0)];
    movedCount = [[UILabel alloc] initWithFrame:CGRectMake(width/3, height/2-scale*30, width/3, 20)];
    [movedCount setTextColor:Color_Text_2];
    movedCount.textAlignment = NSTextAlignmentCenter;
    [movedCount setFont:[UIFont fontWithName:Font_Next_DemiBold size:12]];
    [messageView addSubview:movedCount];
    
    UIButton *topicButton = [[UIButton alloc] initWithFrame:CGRectMake(width*2/3, 0, width/3, height/2)];
    [topicButton setImage:[UIImage imageNamed:Image_profiletopicImage] forState:UIControlStateNormal];
    [topicButton addTarget:self action:@selector(showTopic) forControlEvents:UIControlEventTouchUpInside];
    [messageView addSubview:topicButton];
    [topicButton setImageEdgeInsets:UIEdgeInsetsMake(-15, 0, 0, 0)];
    topicCount = [[UILabel alloc] initWithFrame:CGRectMake(width*2/3, height/2-scale*30, width/3, 20)];
    [topicCount setTextColor:Color_Text_2];
    topicCount.textAlignment = NSTextAlignmentCenter;
    [topicCount setFont:[UIFont fontWithName:Font_Next_DemiBold size:12]];
    [messageView addSubview:topicCount];
    
    UIButton *attentionButton = [[UIButton alloc] initWithFrame:CGRectMake(0, height/2, width/3, height/2)];
    [attentionButton setImage:[UIImage imageNamed:Image_profilefollowerImage] forState:UIControlStateNormal];
    [attentionButton addTarget:self action:@selector(showFollow) forControlEvents:UIControlEventTouchUpInside];
    [messageView addSubview:attentionButton];
    [attentionButton setImageEdgeInsets:UIEdgeInsetsMake(-15, 0, 0, 0)];
    followCount = [[UILabel alloc] initWithFrame:CGRectMake(0, height-scale*30, width/3, 20)];
    [followCount setTextColor:Color_Text_2];
    followCount.textAlignment = NSTextAlignmentCenter;
    [followCount setFont:[UIFont fontWithName:Font_Next_DemiBold size:12]];
    [messageView addSubview:followCount];
    
    UIButton *fansButton = [[UIButton alloc] initWithFrame:CGRectMake(width/3, height/2, width/3, height/2)];
    [fansButton setImage:[UIImage imageNamed:Image_profilefansImage] forState:UIControlStateNormal];
    [fansButton addTarget:self action:@selector(showFans) forControlEvents:UIControlEventTouchUpInside];
    [messageView addSubview:fansButton];
    [fansButton setImageEdgeInsets:UIEdgeInsetsMake(-15, 0, 0, 0)];
    fansCount = [[UILabel alloc] initWithFrame:CGRectMake(width/3, height-scale*30, width/3, 20)];
    [fansCount setTextColor:Color_Text_2];
    fansCount.textAlignment = NSTextAlignmentCenter;
    [fansCount setFont:[UIFont fontWithName:Font_Next_DemiBold size:12]];
    [messageView addSubview:fansCount];
    
    UIButton *songButton = [[UIButton alloc] initWithFrame:CGRectMake(width*2/3, height/2, width/3, height/2)];
    [songButton setImage:[UIImage imageNamed:Image_profilesonglistImage] forState:UIControlStateNormal];
    [songButton addTarget:self action:@selector(showSong) forControlEvents:UIControlEventTouchUpInside];
    [songButton setImageEdgeInsets:UIEdgeInsetsMake(-15, 0, 0, 0)];
    songCount = [[UILabel alloc] initWithFrame:CGRectMake(width*2/3, height-scale*30, width/3, 20)];
    [songCount setTextColor:Color_Text_2];
    songCount.textAlignment = NSTextAlignmentCenter;
    [songCount setFont:[UIFont fontWithName:Font_Next_DemiBold size:12]];
    [messageView addSubview:songCount];
    [messageView addSubview:songButton];
    UIView *linview1 = [[UIView alloc] initWithFrame:CGRectMake(16, height/2, width-32, 1)];
    [linview1 setBackgroundColor:Color_line_1];
    [messageView addSubview:linview1];
    
    
    
    [messageView addSubview:songButton];
    UIView *linview2 = [[UIView alloc] initWithFrame:CGRectMake(width/3, 16, 1, height-32)];
    [linview2 setBackgroundColor:Color_line_1];
    [messageView addSubview:linview2];
    
    [messageView addSubview:songButton];
    UIView *linview3 = [[UIView alloc] initWithFrame:CGRectMake(width*2/3, 16, 1, height-32)];
    [linview3 setBackgroundColor:Color_line_1];
    [messageView addSubview:linview3];
    
    [mainscroll addSubview: messageView];
    [mainscroll setContentSize:CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH+SCREEN_WIDTH/320.0*204.0)];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    userInfo *user = [userInfo shareClass];
    ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@",BaseURL,user.uid]]];
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
}
-(void)viewWillLayoutSubviews {
    if (_profileDic) {
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
            constellationImage.frame = CGRectMake(16, recordHeight+5, 8, 8);
            [constellationImage setImage:[UIImage imageNamed:Image_profileconstellationImage]];
            [mainscroll addSubview:constellationImage];
            constellationLabel.frame = CGRectMake(35, recordHeight, SCREEN_WIDTH/2-50, 20);
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
            
            
            birthImage.frame = CGRectMake(16, recordHeight+5, 8, 8);
            [birthImage setImage:[UIImage imageNamed:Image_profilebirthImage]];
            [mainscroll addSubview:birthImage];
            birthLabel.frame = CGRectMake(35, recordHeight, SCREEN_WIDTH/2-50, 20);
            [birthLabel setText:_date];
            [birthLabel setTextColor:Color_Text_4];
            [birthLabel setFont:[UIFont systemFontOfSize:12]];
            [mainscroll addSubview:birthLabel];
            recordHeight = recordHeight-28;
            
        }
        if ([dicKeys containsObject:@"company"] && [[_profileDic objectForKey:@"company"] length]>0) {
            companyImage.frame = CGRectMake(16, recordHeight+5, 8, 8);
            [companyImage setImage:[UIImage imageNamed:Image_profilejobImage]];
            [mainscroll addSubview:companyImage];
            companyLabel.frame = CGRectMake(35, recordHeight, SCREEN_WIDTH/2-50, 20);
            [companyLabel setText:[_profileDic objectForKey:@"company"]];
            [companyLabel setTextColor:Color_Text_4];
            [companyLabel setFont:[UIFont systemFontOfSize:12]];
            [mainscroll addSubview:companyLabel];
            recordHeight = recordHeight-28;
            
        }else if([dicKeys containsObject:@"school"] && [[_profileDic objectForKey:@"school"] length]>0){
            schoolImage.frame = CGRectMake(16, recordHeight+5, 8, 8);
            [schoolImage setImage:[UIImage imageNamed:Image_profilejobImage]];
            [mainscroll addSubview:schoolImage];
            schoolLabel.frame = CGRectMake(35, recordHeight, SCREEN_WIDTH/2-50, 20);
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
            descriptionLabel.frame = CGRectMake(16, SCREEN_WIDTH/2, SCREEN_WIDTH-32, temp.frame.size.height);
            descriptionLabel.numberOfLines = 0;
            
            [descriptionLabel setFont:[UIFont systemFontOfSize:12]];
            descriptionLabel.text = [_profileDic objectForKey:@"description"];
            [descriptionLabel setTextColor:[UIColor whiteColor]];
            [mainscroll addSubview:descriptionLabel];
        }
        
        
        if ([dicKeys containsObject:@"genres"] && [[_profileDic objectForKey:@"genres"] count]>0) {
            [genresView removeFromSuperview];
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
        MuzzikCount.text = [NSString stringWithFormat:@"%@信息",[_profileDic objectForKey:@"muzzikTotal"]];
        movedCount.text = [NSString stringWithFormat:@"%@喜欢",[_profileDic objectForKey:@"movedTotal"]];
        topicCount.text = [NSString stringWithFormat:@"%@话题",[_profileDic objectForKey:@"topicsTotal"]];
        followCount.text = [NSString stringWithFormat:@"%@关注",[_profileDic objectForKey:@"followsCount"]];
        fansCount.text = [NSString stringWithFormat:@"%@粉丝",[_profileDic objectForKey:@"fansCount"]];
        songCount.text = [NSString stringWithFormat:@"%@歌单",[_profileDic objectForKey:@"musicsTotal"]];
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark action

-(void)editProfile{
    
    ProfileSetting *setting = [[ProfileSetting alloc] init];
    setting.profileDic = self.profileDic;
    setting.header = headimage.image;
    [self.navigationController pushViewController:setting animated:YES];
}

-(void)showMuzziks{
    
}

-(void)showMoveds{
    
}

-(void)showTopic{
    
}

-(void)showFollow{
    
}

-(void)showFans{
    
}

-(void)showSong{
    
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
