//
//  TopicVC.m
//  muzzik
//
//  Created by muzzik on 15/4/3.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "TopicVC.h"
#import "topicLabel.h"
#import "UIScrollView+DXRefresh.h"
#import "TopicDetail.h"
#import "UIImageView+WebCache.h"
#import "TapImageView.h"
#import "TTTAttributedLabel.h"
#import "UIButton+WebCache.h"
#import "userDetailInfo.h"
#import "MuzzikTableVC.h"
#import "SuggestMuzzikVC.h"
#import "ActivityUserVC.h"
#import "TopRankVC.h"
#import "UIButton_UserMuzzik.h"
#define width_For_Cell 60.0
@interface TopicVC ()<UIScrollViewDelegate,TapLabelDelegate,TapImageViewDelegate>{
    UIScrollView *mainScroll;
    NSArray *topicArray;
    NSArray *userArray;
    muzzik *feedMuzzik;
    muzzik *suggestMuzzik;
    muzzik *localMuzzik;
    //feed
    UIView *attentionView;
    UILabel * attentionLabel;
    UIImageView * nextImage;
    
    //topic
    UIView *topicView;
    UILabel *hotLabel;
    UIImageView *topicNext;
    
    //user
    UIView *userView;
    UILabel *userLabel;
    UIImageView *userNext;
    
    //muzzik
    UIImageView *muzzikImage;
    UIView *MainMuzzikView ;
    UIView *muzzikView;
    UILabel *muzzikLabel;
    UIImageView *muzzikNext;
    UIButton *playButton;
    UIButton *likeButton;
    
    NSMutableArray *userImageArray;
}
@end

@implementation TopicVC

- (void)viewDidLoad {
    [super viewDidLoad];
    userImageArray = [NSMutableArray array];
    [self.view setBackgroundColor:[UIColor whiteColor]];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataSourceMuzzikUpdate:) name:String_MuzzikDataSource_update object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataSourceUserUpdate:) name:String_UserDataSource_update object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playnextMuzzikUpdate) name:String_SetSongPlayNextNotification object:nil];
    mainScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    [mainScroll setContentSize:CGSizeMake(SCREEN_WIDTH, 1200)];
    [self.view addSubview:mainScroll];
    [self followScrollView:mainScroll];
    attentionView = [[UIView alloc] initWithFrame:CGRectMake(8, 16, SCREEN_WIDTH-16, 40)];
    [attentionView setBackgroundColor:Color_line_2];
    attentionView.layer.cornerRadius = 3;
    attentionView.clipsToBounds = YES;
    UITapGestureRecognizer *tapForAttention = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapForAttention)];
    [attentionView addGestureRecognizer:tapForAttention];
    
    
    attentionLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,0 , 50, 40)];
    [attentionLabel setText:@"关注"];
    [attentionLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [attentionLabel setTextColor:Color_Text_2];
    attentionLabel.textAlignment = NSTextAlignmentCenter;
    [attentionView addSubview:attentionLabel];
    
    nextImage = [[UIImageView alloc] initWithFrame:CGRectMake(attentionView.frame.size.width-30, 14, 7, 12)];
    nextImage.image = [UIImage imageNamed:Image_recommendarrowImage];
    [attentionView addSubview:nextImage];

    
    
    //topic
    topicView = [[UIView alloc] initWithFrame:CGRectMake(8, 76, SCREEN_WIDTH-16, 234)];
    [topicView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapForMoreTopic)]];
    [topicView setBackgroundColor:Color_line_2];
    topicView.layer.cornerRadius =3;
    topicView.clipsToBounds = YES;
    [mainScroll addSubview:topicView];
    hotLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,0 , 60, 40)];
    hotLabel.font = [UIFont boldSystemFontOfSize:15];
    [hotLabel setTextColor:Color_Text_2];
    hotLabel.text = @"热门话题";
    [topicView addSubview:hotLabel];
    topicNext = [[UIImageView alloc] initWithFrame:CGRectMake(attentionView.frame.size.width-30, 14, 7, 12)];
    [topicNext setImage:[UIImage imageNamed:Image_recommendarrowImage]];
    [topicView addSubview:topicNext];
    
    [self loadTopics];
    //user
    userView = [[UIView alloc] initWithFrame:CGRectMake(8, 330, SCREEN_WIDTH-16, 58+SCREEN_WIDTH*2/3)];
    [userView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapForMoreUser)]];
    [userView setBackgroundColor:Color_line_2];
    userView.layer.cornerRadius =3;
    userView.clipsToBounds = YES;
    [mainScroll addSubview:userView];
    userLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,0 , 60, 40)];
    userLabel.font = [UIFont boldSystemFontOfSize:15];
    [userLabel setTextColor:Color_Text_2];
    userLabel.text = @"活跃用户";
    [userView addSubview:userLabel];
    userNext = [[UIImageView alloc] initWithFrame:CGRectMake(attentionView.frame.size.width-30, 14, 7, 12)];
    [userNext setImage:[UIImage imageNamed:Image_recommendarrowImage]];
    [userView addSubview:userNext];
    [self loadUser];
    //Muzzik
    MainMuzzikView = [[UIView alloc] initWithFrame:CGRectMake(0, 408+SCREEN_WIDTH*2/3, SCREEN_WIDTH, 145+SCREEN_WIDTH)];
    [MainMuzzikView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(SeeMoreSuggestMuzzik)]];
    [mainScroll addSubview: MainMuzzikView];
    muzzikImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 40, SCREEN_WIDTH-10, SCREEN_WIDTH-10)];
    [MainMuzzikView addSubview:muzzikImage];
    muzzikView = [[UIView alloc] initWithFrame:CGRectMake(8, 0, SCREEN_WIDTH-16, 145+SCREEN_WIDTH)];
    [muzzikView setBackgroundColor:Color_line_2];
    muzzikView.layer.cornerRadius =3;
    muzzikView.clipsToBounds = YES;
    [MainMuzzikView addSubview:muzzikView];
    muzzikLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,0 , 60, 40)];
    muzzikLabel.font = [UIFont boldSystemFontOfSize:15];
    [muzzikLabel setTextColor:Color_Text_2];
    muzzikLabel.text = @"本期推荐";
    [muzzikView addSubview:muzzikLabel];
    muzzikNext = [[UIImageView alloc] initWithFrame:CGRectMake(attentionView.frame.size.width-30, 14, 7, 12)];
    [muzzikNext setImage:[UIImage imageNamed:Image_recommendarrowImage]];
    [muzzikView addSubview:muzzikNext];
    [self loadMuzzik];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([[userInfo shareClass].token length]>0) {
        [mainScroll addSubview:attentionView];
        topicView.frame = CGRectMake(8, 76, SCREEN_WIDTH-16, 234);
        userView.frame = CGRectMake(8, 330, SCREEN_WIDTH-16, 58+SCREEN_WIDTH*2/3);
        MainMuzzikView.frame = CGRectMake(0, 408+SCREEN_WIDTH*2/3, SCREEN_WIDTH-16, MainMuzzikView.frame.size.height);
        [mainScroll setContentSize:CGSizeMake(SCREEN_WIDTH, MainMuzzikView.frame.origin.y+MainMuzzikView.frame.size.height+20)];
        [self loadFeeds];
    }else{
        [attentionView removeFromSuperview];
        topicView.frame = CGRectMake(8, 16, SCREEN_WIDTH-16, 234);
        userView.frame = CGRectMake(8, 270, SCREEN_WIDTH-16, 58+SCREEN_WIDTH*2/3);
        MainMuzzikView.frame = CGRectMake(0, 348+SCREEN_WIDTH*2/3, SCREEN_WIDTH-16, MainMuzzikView.frame.size.height);
        [mainScroll setContentSize:CGSizeMake(SCREEN_WIDTH, MainMuzzikView.frame.origin.y+MainMuzzikView.frame.size.height+20)];
        
    }
    

}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark -loadData

-(void) loadFeeds{
    userInfo *user = [userInfo shareClass];
    if (user.checkFollow) {
        if ([[[user.playList objectForKey:Constant_userInfo_follow] objectForKey:@"muzziks"] count]>0) {
            
            feedMuzzik = [[user.playList objectForKey:Constant_userInfo_follow] objectForKey:UserInfo_muzziks][0];
            if ([localMuzzik.muzzik_id isEqualToString:feedMuzzik.muzzik_id]) {
                [attentionView setBackgroundColor:Color_line_2];
                [attentionLabel setTextColor:Color_Text_2];
                [nextImage setImage:[UIImage imageNamed:Image_recommendarrowImage]];
            }else{
                if ([feedMuzzik.color longLongValue]==1) {
                    [attentionView setBackgroundColor:Color_Action_Button_1];
                    [attentionLabel setTextColor:[UIColor whiteColor]];
                    [nextImage setImage:[UIImage imageNamed:Image_recommendwhitearrowImage]];
                }else if ([feedMuzzik.color longLongValue]==2){
                    [attentionView setBackgroundColor:Color_Action_Button_2];
                    [attentionLabel setTextColor:[UIColor whiteColor]];
                    [nextImage setImage:[UIImage imageNamed:Image_recommendwhitearrowImage]];
                }else{
                    [attentionView setBackgroundColor:Color_Action_Button_3];
                    [attentionLabel setTextColor:[UIColor whiteColor]];
                    [nextImage setImage:[UIImage imageNamed:Image_recommendwhitearrowImage]];
                }
            }
        }
    }else{
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/feeds",BaseURL]]];
        [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:@"1" forKey:Parameter_Limit] Method:GetMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = request;
        [request setCompletionBlock :^{
            //    NSLog(@"%@",weakrequest.originalURL);
            NSLog(@"%@",[weakrequest responseString]);
            NSData *data = [weakrequest responseData];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if (dic&&[[dic objectForKey:@"muzziks"]count]>0) {
                feedMuzzik = [[[muzzik new] makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"] ] objectAtIndex:0];
                if ([localMuzzik.muzzik_id isEqualToString:feedMuzzik.muzzik_id]) {
                    [attentionView setBackgroundColor:Color_line_2];
                    [attentionLabel setTextColor:Color_Text_2];
                    [nextImage setImage:[UIImage imageNamed:Image_recommendarrowImage]];
                }else{
                    if ([feedMuzzik.color longLongValue]==1) {
                        [attentionView setBackgroundColor:Color_Action_Button_1];
                        [attentionLabel setTextColor:[UIColor whiteColor]];
                        [nextImage setImage:[UIImage imageNamed:Image_recommendwhitearrowImage]];
                    }else if ([feedMuzzik.color longLongValue]==2){
                        [attentionView setBackgroundColor:Color_Action_Button_2];
                        [attentionLabel setTextColor:[UIColor whiteColor]];
                        [nextImage setImage:[UIImage imageNamed:Image_recommendwhitearrowImage]];
                    }else{
                        [attentionView setBackgroundColor:Color_Action_Button_3];
                        [attentionLabel setTextColor:[UIColor whiteColor]];
                        [nextImage setImage:[UIImage imageNamed:Image_recommendwhitearrowImage]];
                    }
                }
            }
        }];
        [request setFailedBlock:^{
            NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
        }];
        [request startAsynchronous];
    }
    
    
    
    
}
-(void) loadTopics{
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/topic/suggest",BaseURL]]];
    [request addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:NO];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        //    NSLog(@"%@",weakrequest.originalURL);
        NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            CGFloat MaxX = SCREEN_WIDTH-23;
            CGFloat localX = 15;
            CGFloat localY = 52;
            topicArray = [dic objectForKey:@"topics"];
            for (int i = 0; i<topicArray.count; i++) {
                topicLabel *tempLabel = [[topicLabel alloc] init];
                tempLabel.delegate = self;
                [tempLabel setText:[topicArray[i] objectForKey:@"name"] font:[UIFont boldSystemFontOfSize:12] color:[[topicArray[i] objectForKey:@"color"] longValue]];
                tempLabel.tid = [topicArray[i] objectForKey:@"_id"];
                if (localX +tempLabel.frame.size.width+8>MaxX) {
                    localX = 15;
                    localY = localY+38;
                    if (localY<234) {
                        [tempLabel setFrame:CGRectMake(localX, localY, tempLabel.frame.size.width, tempLabel.frame.size.height)];
                        [topicView addSubview:tempLabel];
                        localX = localX+tempLabel.frame.size.width+8;
                    }else{
                        break;
                    }
                }else{
                    [tempLabel setFrame:CGRectMake(localX, localY, tempLabel.frame.size.width, tempLabel.frame.size.height)];
                    [topicView addSubview:tempLabel];
                    localX = localX+tempLabel.frame.size.width+8;
                }
            }
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
    }];
    [request startAsynchronous];
}

-(void) loadUser{
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/suggest",BaseURL]]];
    [request addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        //    NSLog(@"%@",weakrequest.originalURL);
        NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            
            MuzzikUser *muzzikToy = [MuzzikUser new];
            userArray = [muzzikToy makeMuzziksByUserArray:[dic objectForKey:@"users"]];
            NSMutableArray *tempArray = [NSMutableArray array];
            if ([userArray count]>6) {
                while (tempArray.count<6) {
                    MuzzikUser *user = [userArray objectAtIndex:arc4random()%userArray.count];
                    if (![tempArray containsObject:user]) {
                        [tempArray addObject:user];
                    }
                }
            }else{
                [tempArray addObjectsFromArray:userArray];
            }
           
            CGFloat localX = 15;
            CGFloat localY = 52;
            for (int i = 0; i<2; i++) {
                for (int j=0; j<3; j++) {
                    MuzzikUser * tempUser = tempArray[i*3+j];
                    UIButton_UserMuzzik *userbutton = [[UIButton_UserMuzzik alloc] initWithFrame:CGRectMake(localX, localY, SCREEN_WIDTH/3-31, SCREEN_WIDTH/3-31)];
                    userbutton.user =tempUser;
                    userbutton.layer.cornerRadius = SCREEN_WIDTH/6-15.5;
                    userbutton.clipsToBounds = YES;
                    [userbutton addTarget:self action:@selector(seeVipUser:) forControlEvents:UIControlEventTouchUpInside];
                    [userbutton setAlpha:0];
                    userbutton.layer.cornerRadius = SCREEN_WIDTH/6-15.5;
                    [userbutton sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?imageView2/1/w/100/h/100",BaseURL_image,tempUser.avatar]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:Image_user_placeHolder] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        [UIView animateWithDuration:0.5 animations:^{
                            [userbutton setAlpha:1];
                        }];
                    }];

                    
                    UIButton_UserMuzzik *followImage = [[UIButton_UserMuzzik alloc] initWithFrame:CGRectMake(userbutton.frame.origin.x+userbutton.frame.size.width-29, userbutton.frame.size.height+userbutton.frame.origin.y-29, 29, 29)];
                    followImage.user = tempUser;
                    
                    if (tempUser.isFans && tempUser.isFollow) {
                        followImage.followType = @"1";
                        [followImage setImage:[UIImage imageNamed:Image_recommendfollowedeachother] forState:UIControlStateNormal];
                    }else if (tempUser.isFollow){
                        followImage.followType = @"1";
                        [followImage setImage:[UIImage imageNamed:Image_recommendfollowed] forState:UIControlStateNormal];
                    }else{
                        followImage.followType = @"0";
                        [followImage setImage:[UIImage imageNamed:Image_recommendfollow] forState:UIControlStateNormal];
                    }
                    [followImage addTarget:self action:@selector(follwUser:) forControlEvents:UIControlEventTouchUpInside];
                    [userImageArray addObject:followImage];
                    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(localX, userbutton.frame.size.height+userbutton.frame.origin.y+5, SCREEN_WIDTH/3-31, 15)];
                    [nameLabel setFont:[UIFont systemFontOfSize:12]];
                    [nameLabel setText:tempUser.name];
                    [nameLabel setTextColor:Color_Text_2];
                    nameLabel.textAlignment = NSTextAlignmentCenter;
                    [userView addSubview:nameLabel];
                    [userView addSubview:userbutton];
                    [userView addSubview:followImage];
                    localX = SCREEN_WIDTH/3-7+localX;
                }
                localY = localY +SCREEN_WIDTH/3+1;
                localX = 15;
            }
            
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
    }];
    [request startAsynchronous];
}
-(void) loadMuzzik{
    userInfo *user = [userInfo shareClass];
    if (user.checkSuggest) {
        suggestMuzzik = [[user.playList objectForKey:Constant_userInfo_suggest] objectForKey:UserInfo_muzziks][0];
        [self suggestViewLayout];
    }else{
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/suggest",BaseURL]]];
        [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"image",[NSNumber numberWithInt:1],Parameter_Limit, nil] Method:GetMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = request;
        [request setCompletionBlock :^{
            //    NSLog(@"%@",weakrequest.originalURL);
            NSLog(@"%@",[weakrequest responseString]);
            NSData *data = [weakrequest responseData];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if (dic&&[[dic objectForKey:@"muzziks"]count]>0) {
                suggestMuzzik =  [[[muzzik new] makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"] ] objectAtIndex:0];
                [self suggestViewLayout];
            }
        }];
        [request setFailedBlock:^{
            NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
        }];
        [request startAsynchronous];
        
    }
    
    
    
    
    
}
-(void)suggestViewLayout{
    muzzikImage.layer.cornerRadius = 3;
    muzzikImage.clipsToBounds = YES;
    [muzzikImage setAlpha:0];
    [muzzikImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?imageView2/1/w/600/h/600",BaseURL_image,suggestMuzzik.image]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [UIView animateWithDuration:0.5 animations:^{
            [muzzikImage setAlpha:1];
        }];
    }];
    [MainMuzzikView addSubview:muzzikImage];
    UIButton *headButton = [[UIButton alloc] initWithFrame:CGRectMake(15, SCREEN_WIDTH+2, 56, 56)];
    headButton.layer.cornerRadius = 28;
    headButton.layer.borderColor = [UIColor whiteColor].CGColor;
    headButton.layer.borderWidth =2;
    headButton.clipsToBounds = YES;
    [headButton addTarget:self action:@selector(goToUser) forControlEvents:UIControlEventTouchUpInside];
    [headButton sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?imageView2/1/w/100/h/100",BaseURL_image,suggestMuzzik.MuzzikUser.avatar]] forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [UIView animateWithDuration:0.5 animations:^{
            [headButton setAlpha:1];
        }];
    }];
    [MainMuzzikView addSubview:headButton];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(69, SCREEN_WIDTH+38, SCREEN_WIDTH-140, 17)];
    [nameLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [nameLabel setTextColor:Color_Text_1];
    nameLabel.text = suggestMuzzik.MuzzikUser.name;
    [muzzikView addSubview:nameLabel];
    UILabel *timeStamp = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-130, SCREEN_WIDTH+38, 96, 9)];
    [timeStamp setTextColor:Color_Additional_5];
    [timeStamp setFont:[UIFont fontWithName:Font_Next_medium size:9]];
    timeStamp.textAlignment = NSTextAlignmentRight;
    [muzzikView addSubview:timeStamp];
    UIImageView *timeImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-30, SCREEN_WIDTH+38, 9, 9)];
    [timeImage setImage:[UIImage imageNamed:Image_timeImage]];
    [muzzikView addSubview:timeImage];
    timeStamp.text = [MuzzikItem transtromTime:suggestMuzzik.date];
    
    
    TTTAttributedLabel *label = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(15, SCREEN_WIDTH+60, SCREEN_WIDTH-46, 500)];
    [label setFont:[UIFont systemFontOfSize:14]];
    [label setTextColor:Color_Text_2];
    label.text = suggestMuzzik.message;
    CGSize msize = [label sizeThatFits:CGSizeMake(SCREEN_WIDTH-46, 2000)];
    if (msize.height>limitHeight) {
        [label setFrame:CGRectMake(15,  SCREEN_WIDTH+60, SCREEN_WIDTH-46,limitHeight)];
    }else{
        [label setFrame:CGRectMake(15,  SCREEN_WIDTH+60, SCREEN_WIDTH-46,msize.height)];
    }
    
    [muzzikView addSubview:label];
    UIView *musicPlayView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_WIDTH+60+label.frame.size.height+10, SCREEN_WIDTH, 60)];
    [MainMuzzikView addSubview:musicPlayView];
    UIProgressView *progress = [[UIProgressView alloc] initWithFrame:CGRectMake(16, 0, SCREEN_WIDTH-32, 1)];
    [progress setProgress:1];
    [musicPlayView addSubview:progress];
    UILabel *musicName = [[UILabel alloc] initWithFrame:CGRectMake(68, 12, SCREEN_WIDTH-150, 20)];
    [musicName setFont:[UIFont fontWithName:Font_Next_Bold size:16]];
    musicName.text = suggestMuzzik.music.name;
    [musicPlayView addSubview:musicName];
    UILabel *musicArtist = [[UILabel alloc] initWithFrame:CGRectMake(68, 31, SCREEN_WIDTH-150, 25)];
    [musicArtist setFont:[UIFont fontWithName:Font_Next_Bold size:13]];
    [musicPlayView addSubview:musicArtist];
    musicArtist.text = suggestMuzzik.music.artist;
    likeButton = [[UIButton alloc] initWithFrame:CGRectMake(23, 13, 34, 34)];
    [likeButton addTarget:self action:@selector(moveAction) forControlEvents:UIControlEventTouchUpInside];
    [musicPlayView addSubview:likeButton];
    
    playButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-59, 13, 34, 34)];
    
    [playButton addTarget:self action:@selector(playMusicAction) forControlEvents:UIControlEventTouchUpInside];
    [musicPlayView addSubview:playButton];
    UIColor *color;
    if ([suggestMuzzik.color longLongValue]==1) {
        color = [UIColor colorWithHexString:@"fea42c"];
        if (suggestMuzzik.ismoved) {
            [likeButton setImage:[UIImage imageNamed:@"yellowlikedImage"] forState:UIControlStateNormal];
        }else{
            [likeButton setImage:[UIImage imageNamed:@"yellowlikeImage"] forState:UIControlStateNormal];
        }
        [playButton setImage:[UIImage imageNamed:@"yellowplayImage"] forState:UIControlStateNormal];
    }
    else if([suggestMuzzik.color longLongValue]==2){
        //bluelikeImage
        color = [UIColor colorWithHexString:@"04a0bf"];
        if (suggestMuzzik.ismoved) {
            [likeButton setImage:[UIImage imageNamed:@"bluelikedImage"] forState:UIControlStateNormal];
        }else{
            [likeButton setImage:[UIImage imageNamed:@"bluelikeImage"] forState:UIControlStateNormal];
        }
        [playButton setImage:[UIImage imageNamed:@"blueplayImage"] forState:UIControlStateNormal];
    }
    
    else{
        color = [UIColor colorWithHexString:@"f26d7d"];
        if (suggestMuzzik.ismoved) {
            [likeButton setImage:[UIImage imageNamed:@"redlikedImage"] forState:UIControlStateNormal];
        }else{
            [likeButton setImage:[UIImage imageNamed:@"redlikeImage"] forState:UIControlStateNormal];
        }
        [playButton setImage:[UIImage imageNamed:@"redplayImage"] forState:UIControlStateNormal];
    }
    [progress setTintColor:color];
    [musicArtist setTextColor:color];
    [musicName setTextColor:color];
    muzzikView.frame = CGRectMake(8, 0, SCREEN_WIDTH-16, 145+SCREEN_WIDTH+label.frame.size.height);
    if ([[userInfo shareClass].token length]>0) {
        MainMuzzikView.frame = CGRectMake(0, 408+SCREEN_WIDTH*2/3, SCREEN_WIDTH-16, 145+SCREEN_WIDTH+label.frame.size.height);
        [mainScroll setContentSize:CGSizeMake(SCREEN_WIDTH, 573+SCREEN_WIDTH*5/3.0+label.frame.size.height)];
    }else{
        MainMuzzikView.frame = CGRectMake(0, 348+SCREEN_WIDTH*2/3, SCREEN_WIDTH-16, 145+SCREEN_WIDTH+label.frame.size.height);
        [mainScroll setContentSize:CGSizeMake(SCREEN_WIDTH, 513+SCREEN_WIDTH*5/3.0+label.frame.size.height)];
    }

}

#pragma mark -action
- (void) tappedWithObject:(topicLabel*) sender{
    TopicDetail *topic = [[TopicDetail alloc] init];
    topic.topic_id = sender.tid;
    [self.navigationController pushViewController:topic animated:YES];
}
-(void)SeeMoreSuggestMuzzik{
    SuggestMuzzikVC *suggsetvc = [[SuggestMuzzikVC alloc]init];
    [self.navigationController pushViewController:suggsetvc animated:YES];
}
-(void)goToUser{
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    userDetailInfo *detailuser = [[userDetailInfo alloc] init];
    detailuser.uid = suggestMuzzik.MuzzikUser.user_id;
    [self.navigationController pushViewController:detailuser animated:YES];
}
-(void)moveAction{
    
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/%@/moved",BaseURL,suggestMuzzik.muzzik_id]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:!suggestMuzzik.ismoved] forKey:@"ismoved"] Method:PostMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            if ([weakrequest responseStatusCode] == 200) {
                // NSData *data = [weakrequest responseData];
                suggestMuzzik.ismoved = !suggestMuzzik.ismoved;
                if (suggestMuzzik.ismoved) {
                    suggestMuzzik.moveds = [NSString stringWithFormat:@"%d",[suggestMuzzik.moveds intValue]+1 ];
                }else{
                    suggestMuzzik.moveds = [NSString stringWithFormat:@"%d",[suggestMuzzik.moveds intValue]-1 ];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:suggestMuzzik];
                
                
            }
            else{
                //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
            }
        }];
        [requestForm setFailedBlock:^{
            NSLog(@"%@",[weakrequest error]);
        }];
        [requestForm startAsynchronous];
        
        //NSLog(@"json:%@,dic:%@",tempJsonData,dic);
        
    }else{
        [userInfo checkLoginWithVC:self];
    }
}

-(void)playMusicAction{
    [musicPlayer shareClass].listType = TempList;
    [musicPlayer shareClass].MusicArray = [NSMutableArray arrayWithArray:@[suggestMuzzik]];
    [[musicPlayer shareClass] playSongWithSongModel:suggestMuzzik Title:[NSString stringWithFormat:@"单曲<%@>",suggestMuzzik.music.name]];
    [MuzzikItem SetUserInfoWithMuzziks:[NSMutableArray arrayWithArray:@[suggestMuzzik]] title:Constant_userInfo_temp description:[NSString stringWithFormat:@"单曲<%@>",suggestMuzzik.music.name]];
}
-(void) tapForAttention{
    localMuzzik = feedMuzzik;
    MuzzikTableVC *muzziktablevc = [[MuzzikTableVC alloc] init];
    muzziktablevc.requstType = @"feeds";
    [self.navigationController pushViewController:muzziktablevc animated:YES];
}
-(void) tapForMoreUser{
    ActivityUserVC *activity = [[ActivityUserVC alloc] init];
    [self.navigationController pushViewController:activity animated:YES];
    NSLog(@"user");
}
-(void) tapForMoreTopic{
    TopRankVC *toprank = [[TopRankVC alloc] init];
    [self.navigationController pushViewController:toprank animated:YES];
}
-(void)playnextMuzzikUpdate{
    Globle *glob = [Globle shareGloble];
    BOOL isPlaying = [[musicPlayer shareClass].localMuzzik.muzzik_id isEqualToString:suggestMuzzik.muzzik_id]&&!glob.isPause;
    if ([suggestMuzzik.color longLongValue]==1) {

        if (isPlaying) {
            [playButton setImage:[UIImage imageNamed:@"yellowstopImage"] forState:UIControlStateNormal];
        }else{
            [playButton setImage:[UIImage imageNamed:@"yellowplayImage"] forState:UIControlStateNormal];
        }
    }
    else if([suggestMuzzik.color longLongValue]==2){

        if (isPlaying) {
            [playButton setImage:[UIImage imageNamed:@"bluestopImage"] forState:UIControlStateNormal];
        }else{
            [playButton setImage:[UIImage imageNamed:@"blueplayImage"] forState:UIControlStateNormal];
        }
    }
    else{

        if (isPlaying) {
            [playButton setImage:[UIImage imageNamed:@"redstopImage"] forState:UIControlStateNormal];
        }else{
            [playButton setImage:[UIImage imageNamed:@"redplayImage"] forState:UIControlStateNormal];
        }
    }
    
}

-(void)dataSourceUserUpdate:(NSNotification *)notify{
    MuzzikUser *user = notify.object;
    for (TapImageView *tap in userImageArray) {
        if ([tap.user.user_id isEqualToString:user.user_id]) {
            tap.user.isFollow = user.isFollow;
            tap.user.isFans = user.isFans;
            if (user.isFans &&user.isFollow) {
                [tap setImage:[UIImage imageNamed:Image_recommendfollowedeachother]];
            }else if (user.isFollow){
                [tap setImage:[UIImage imageNamed:Image_recommendfollowed]];
            }else{
                 [tap setImage:[UIImage imageNamed:Image_recommendfollow]];
            }
            break;
        }
    }
}
-(void)dataSourceMuzzikUpdate:(NSNotification *)notify{
    muzzik *tempMuzzik = (muzzik *)notify.object;
    if ([suggestMuzzik.muzzik_id isEqualToString:tempMuzzik.muzzik_id]) {
        suggestMuzzik.ismoved = tempMuzzik.ismoved;
        suggestMuzzik.isReposted = tempMuzzik.isReposted;
        suggestMuzzik.moveds = tempMuzzik.moveds;
        suggestMuzzik.reposts = tempMuzzik.reposts;
        suggestMuzzik.shares = tempMuzzik.shares;
        suggestMuzzik.comments = tempMuzzik.comments;
        UIColor *color ;
        if ([suggestMuzzik.color longLongValue]==1) {
            color = [UIColor colorWithHexString:@"fea42c"];
            if (suggestMuzzik.ismoved) {
                [likeButton setImage:[UIImage imageNamed:@"yellowlikedImage"] forState:UIControlStateNormal];
            }else{
                [likeButton setImage:[UIImage imageNamed:@"yellowlikeImage"] forState:UIControlStateNormal];
            }
        }
        else if([suggestMuzzik.color longLongValue]==2){
            //bluelikeImage
            color = [UIColor colorWithHexString:@"04a0bf"];
            if (suggestMuzzik.ismoved) {
                [likeButton setImage:[UIImage imageNamed:@"bluelikedImage"] forState:UIControlStateNormal];
            }else{
                [likeButton setImage:[UIImage imageNamed:@"bluelikeImage"] forState:UIControlStateNormal];
            }
        }
        
        else{
            color = [UIColor colorWithHexString:@"f26d7d"];
            if (suggestMuzzik.ismoved) {
                [likeButton setImage:[UIImage imageNamed:@"redlikedImage"] forState:UIControlStateNormal];
            }else{
                [likeButton setImage:[UIImage imageNamed:@"redlikeImage"] forState:UIControlStateNormal];
            }
        }
    }
    
}

-(void) seeVipUser:(UIButton_UserMuzzik *)button{
    userDetailInfo *detailuser = [[userDetailInfo alloc] init];
    detailuser.uid = button.user.user_id;
    [self.navigationController pushViewController:detailuser animated:YES];
}
-(void)follwUser:(UIButton_UserMuzzik *)button{
    if ([button.followType isEqualToString:@"0"]) {
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_User_Follow]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:button.user.user_id forKey:@"_id"] Method:PostMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            
            if ([weakrequest responseStatusCode] == 200) {
                button.user.isFollow = YES;
                button.followType = @"1";
                [[NSNotificationCenter defaultCenter] postNotificationName:String_UserDataSource_update object:button.user];
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
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_user_Unfollow]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:button.user.user_id forKey:@"_id"] Method:PostMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            
            if ([weakrequest responseStatusCode] == 200) {
                button.user.isFollow = NO;
                button.followType = @"0";
                
                [[NSNotificationCenter defaultCenter] postNotificationName:String_UserDataSource_update object:button.user];
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
