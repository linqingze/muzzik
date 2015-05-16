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
#import "userDetailInfo.h"
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
}
@end

@implementation TopicVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    mainScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    [mainScroll setContentSize:CGSizeMake(SCREEN_WIDTH, 1000)];
    [self.view addSubview:mainScroll];
    attentionView = [[UIView alloc] initWithFrame:CGRectMake(8, 16, SCREEN_WIDTH-16, 40)];
    [attentionView setBackgroundColor:[UIColor blueColor]];
    attentionView.layer.cornerRadius = 3;
    attentionView.clipsToBounds = YES;
    UITapGestureRecognizer *tapForAttention = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapForAttention)];
    [attentionView addGestureRecognizer:tapForAttention];
    [mainScroll addSubview:attentionView];
    
    attentionLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,0 , 50, 40)];
    [attentionLabel setText:@"关注"];
    [attentionLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [attentionLabel setTextColor:[UIColor whiteColor]];
    attentionLabel.textAlignment = NSTextAlignmentCenter;
    [attentionView addSubview:attentionLabel];
    
    nextImage = [[UIImageView alloc] initWithFrame:CGRectMake(attentionView.frame.size.width-30, 14, 7, 12)];
    nextImage.image = [UIImage imageNamed:Image_recommendwhitearrowImage];
    [attentionView addSubview:nextImage];
    
    //topic
    topicView = [[UIView alloc] initWithFrame:CGRectMake(8, 76, SCREEN_WIDTH-16, 234)];
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
    [self loadMuzzik];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadFeeds];

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
#pragma -mark Action
-(void) tapForAttention{
    NSLog(@"tap");
}
-(void) tapForMoreUser{
    NSLog(@"user");
}
-(void) tapForMoreTopic{
    NSLog(@"topic");
}









#pragma mark -loadData

-(void) loadFeeds{
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
                [tempLabel setText:[topicArray[i] objectForKey:@"name"] font:[UIFont boldSystemFontOfSize:12] color:[[topicArray[i] objectForKey:@"color"] longLongValue]];
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
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:@"6" forKey:Parameter_Limit] Method:GetMethod auth:YES];
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
            while (tempArray.count<=6) {
                MuzzikUser *user = [userArray objectAtIndex:arc4random()%userArray.count];
                if (![tempArray containsObject:user]) {
                    [tempArray addObject:user];
                }
            }
            CGFloat localX = 15;
            CGFloat localY = 52;
            for (int i = 0; i<2; i++) {
                for (int j=0; j<3; j++) {
                    MuzzikUser * tempUser = tempArray[i*3+j];
                    TapImageView *tapImage = [[TapImageView alloc] initWithFrame:CGRectMake(localX, localY, SCREEN_WIDTH/3-31, SCREEN_WIDTH/3-31)];
                    tapImage.user =tempUser;
                    [tapImage setAlpha:0];
                    tapImage.layer.cornerRadius = SCREEN_WIDTH/6-15.5;
                    tapImage.delegate = self;
                    [tapImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?imageView2/1/w/100/h/100",BaseURL_image,tempUser.avatar]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                         [tapImage setAlpha:1];
                    }];
                    
                    TapImageView *followImage = [[TapImageView alloc] initWithFrame:CGRectMake(tapImage.frame.origin.x+tapImage.frame.size.width-29, tapImage.frame.size.height+tapImage.frame.origin.y-29, 29, 29)];
                    followImage.user = tempUser;

                    followImage.delegate = self;
                    if (tempUser.isFans && tempUser.isFollow) {
                        followImage.followType = @"1";
                        [followImage setImage:[UIImage imageNamed:Image_recommendfollowedeachother]];
                    }else if (tempUser.isFollow){
                        followImage.followType = @"1";
                        [followImage setImage:[UIImage imageNamed:Image_recommendfollowed]];
                    }else{
                        followImage.followType = @"0";
                        [followImage setImage:[UIImage imageNamed:Image_recommendfollow]];
                    }
                    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(localX, tapImage.frame.size.height+tapImage.frame.origin.y+5, SCREEN_WIDTH/3-31, 15)];
                    [nameLabel setFont:[UIFont systemFontOfSize:12]];
                    [nameLabel setText:tempUser.name];
                    [nameLabel setTextColor:Color_Text_2];
                    
                    [userView addSubview:nameLabel];
                    [userView addSubview:tapImage];
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
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/suggest",BaseURL]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:@"1" forKey:Parameter_Limit] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        //    NSLog(@"%@",weakrequest.originalURL);
        NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic&&[[dic objectForKey:@"muzziks"]count]>0) {
            suggestMuzzik =  [[[muzzik new] makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"] ] objectAtIndex:0];
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
    }];
    [request startAsynchronous];
}


#pragma mark -action
- (void) tappedWithObject:(topicLabel*) sender{
    TopicDetail *topic = [[TopicDetail alloc] init];
    topic.topic_id = sender.tid;
    [self.navigationController pushViewController:topic animated:YES];
}
-(void)tappedWithImage:(TapImageView *)sender{
    if ([sender.followType length]>0) {
        if ([sender.followType isEqualToString:@"0"]) {
            ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_User_Follow]]];
            [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:sender.user.user_id forKey:@"_id"] Method:PostMethod auth:YES];
            __weak ASIHTTPRequest *weakrequest = requestForm;
            [requestForm setCompletionBlock :^{
                NSLog(@"%@",[weakrequest responseString]);
                NSLog(@"%d",[weakrequest responseStatusCode]);
                
                if ([weakrequest responseStatusCode] == 200) {
                    sender.user.isFollow = YES;
                    sender.followType = @"1";
                    if (sender.user.isFans && sender.user.isFollow) {
                        [sender setImage:[UIImage imageNamed:Image_recommendfollowedeachother]];
                    }else {
                        [sender setImage:[UIImage imageNamed:Image_recommendfollowed]];
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
    }else{
        userDetailInfo *detailuser = [[userDetailInfo alloc] init];
        detailuser.uid = sender.user.user_id;
        [self.navigationController pushViewController:detailuser animated:YES];
    }
}
@end
