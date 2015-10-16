//
//  FeedViewController.m
//  muzzik
//
//  Created by muzzik on 15/6/12.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "FeedViewController.h"
#import "UIImageView+WebCache.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "NormalCell.h"
#import "TopicHeaderView.h"
#import "appConfiguration.h"
#import <MediaPlayer/MediaPlayer.h>
#import "TTTAttributedLabel.h"
#import "ChooseMusicVC.h"
#import "LoginViewController.h"
#import "UIButton+WebCache.h"
#import "showUserVC.h"
#import "NormalNoCardCell.h"
#import "DetaiMuzzikVC.h"
#import "MuzzikCard.h"
#import "MuzzikNoCardCell.h"
#import "userDetailInfo.h"
#import "TopicDetail.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "MuzzikSongCell.h"
#import "MuzzikTopic.h"
#import "songDetailVCViewController.h"
#import "MessageStepViewController.h"
#import "RDVTabBarController.h"
#import "searchViewController.h"
@interface FeedViewController ()<UITableViewDataSource,UITableViewDelegate,UICollectionViewDelegateFlowLayout,TTTAttributedLabelDelegate,CellDelegate>{
    NSMutableArray *suggestDayArray;
    UIView *userView;
    NSMutableArray *userArray;
    BOOL isUserTaped;
    UIImage *shareImage;
    UITableView *feedTableView;
    UITableView *trendTableView;
    
    NSString *trendLastId;
    
    NSString *feedLastId;
    
    
    NSMutableDictionary *feedRefreshDic;
    NSMutableDictionary *feedReFreshPoImageDic;
    
    NSMutableDictionary *trendRefreshDic;
    NSMutableDictionary *trendReFreshPoImageDic;
    
    //shareView
    muzzik *shareMuzzik;
    UIView *shareViewFull;
    UIView *shareView;
    UIButton *shareToTimeLineButton;
    UIButton *shareToWeiChatButton;
    UIButton *shareToWeiboButton;
    UIButton *shareToQQButton;
    UIButton *shareToQQZoneButton;
    CGFloat maxScaleY;
    UIScrollView *mainScroll;
    UIView *switchView;
    UIButton *feedButton;
    UIButton *trendButton;
    UIView *lineBar;
    
    NSTimer *timer;
    NSInteger timeCount;
    UIImageView *coverImageView;
    
}
@property(nonatomic,retain) muzzik *repostMuzzik;

@property(nonatomic,retain) NSMutableArray *feedMuzziks;
@property(nonatomic,retain) NSMutableArray *trendMuzziks;

@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    suggestDayArray = [NSMutableArray array];
    [self initNagationBar:@"" leftBtn:8 rightBtn:0];
    
    self.feedMuzziks = [NSMutableArray array];
    self.trendMuzziks = [NSMutableArray array];
    
    feedRefreshDic = [NSMutableDictionary dictionary];
    feedReFreshPoImageDic = [NSMutableDictionary dictionary];
    
    trendRefreshDic = [NSMutableDictionary dictionary];
    trendReFreshPoImageDic = [NSMutableDictionary dictionary];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteMuzzik:) name:String_Muzzik_Delete object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataSourceMuzzikUpdate:) name:String_MuzzikDataSource_update object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playnextMuzzikUpdate) name:String_SetSongPlayNextNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNewSendMuzzik:) name:String_SendNewMuzzikDataSource_update object:nil];
    // [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    _musicplayer = [musicPlayer shareClass];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    feedTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [feedTableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    feedTableView.dataSource = self;
    feedTableView.delegate = self;
    [feedTableView registerClass:[NormalCell class] forCellReuseIdentifier:@"NormalCell"];
    [feedTableView registerClass:[NormalNoCardCell class] forCellReuseIdentifier:@"NormalNoCardCell"];
    [feedTableView registerClass:[MuzzikCard class] forCellReuseIdentifier:@"MuzzikCard"];
    [feedTableView registerClass:[MuzzikNoCardCell class] forCellReuseIdentifier:@"MuzzikNoCardCell"];
    [feedTableView registerClass:[MuzzikSongCell class] forCellReuseIdentifier:@"MuzzikSongCell"];
    [feedTableView registerClass:[MuzzikTopic class] forCellReuseIdentifier:@"MuzzikTopic"];
    [feedTableView addHeaderWithTarget:self action:@selector(feedRefreshHeader)];
    [feedTableView addFooterWithTarget:self action:@selector(feedReshFooter)];
    
    trendTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [trendTableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    trendTableView.dataSource = self;
    trendTableView.delegate = self;
    [trendTableView registerClass:[NormalCell class] forCellReuseIdentifier:@"NormalCell"];
    [trendTableView registerClass:[NormalNoCardCell class] forCellReuseIdentifier:@"NormalNoCardCell"];
    [trendTableView registerClass:[MuzzikCard class] forCellReuseIdentifier:@"MuzzikCard"];
    [trendTableView registerClass:[MuzzikNoCardCell class] forCellReuseIdentifier:@"MuzzikNoCardCell"];
    [trendTableView registerClass:[MuzzikSongCell class] forCellReuseIdentifier:@"MuzzikSongCell"];
    [trendTableView registerClass:[MuzzikTopic class] forCellReuseIdentifier:@"MuzzikTopic"];
    [trendTableView addHeaderWithTarget:self action:@selector(trendRefreshHeader)];
    [trendTableView addFooterWithTarget:self action:@selector(trendRefreshFooter)];
    
    
    
    mainScroll = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [mainScroll setBackgroundColor:[UIColor whiteColor]];
    [mainScroll setContentSize:CGSizeMake(SCREEN_WIDTH * 2, self.view.bounds.size.height)];
    mainScroll.pagingEnabled = YES;
    [self.view addSubview:mainScroll];
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        
        [mainScroll addSubview:feedTableView];
        [trendTableView setFrame:CGRectMake(SCREEN_WIDTH, trendTableView.frame.origin.y, trendTableView.frame.size.width, trendTableView.frame.size.height)];
        [mainScroll addSubview:trendTableView];
        [self trendReloadMuzzikSource];
        [self feedReloadMuzzikSource];
    }else{
        [mainScroll addSubview:trendTableView];
        [self trendReloadMuzzikSource];
    }
    
    
    [self SettingShareView];

    userView = [[UIView alloc] initWithFrame:CGRectMake(0, -75, SCREEN_WIDTH, 75)];
    [userView setBackgroundColor:Color_line_2];
    [userView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(seeMoreUser)]];
    switchView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 -60, 24, 120, 40)];
    feedButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, switchView.frame.size.width/2, switchView.frame.size.height-2)];
    [feedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [feedButton setTitle:@"关注" forState:UIControlStateNormal];
    [feedButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [feedButton addTarget:self action:@selector(switchTableView:) forControlEvents:UIControlEventTouchDown];
    trendButton = [[UIButton alloc] initWithFrame:CGRectMake(switchView.frame.size.width/2, 0, switchView.frame.size.width/2, switchView.frame.size.height-2)];
    [trendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [trendButton setTitle:@"广场" forState:UIControlStateNormal];
    [trendButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [trendButton addTarget:self action:@selector(switchTableView:) forControlEvents:UIControlEventTouchDown];
    [switchView addSubview:trendButton];
    [switchView addSubview:feedButton];
    [self.navigationController.view addSubview:switchView];
    lineBar = [[UIView alloc] initWithFrame:CGRectMake(0, switchView.frame.size.height-2, switchView.frame.size.width/2, 2)];
    [lineBar setBackgroundColor:Color_Active_Button_1];
    [switchView addSubview:lineBar];
    [mainScroll addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    mainScroll.bounces = NO;
    if (self.rdv_tabBarController.tabBar.translucent) {
        UIEdgeInsets insets = UIEdgeInsetsMake(0,
                                               0,
                                               CGRectGetHeight(self.rdv_tabBarController.tabBar.frame),
                                               0);
        
        feedTableView.contentInset = insets;
        feedTableView.scrollIndicatorInsets = insets;
        
        trendTableView.contentInset = insets;
        trendTableView.scrollIndicatorInsets = insets;
    }
    [self addCoverVCToWindow];
    NSDate *  senddate=[NSDate date];
    
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:@"YYYYMMdd"];
    
    NSString *  locationString=[dateformatter stringFromDate:senddate];
    
    NSLog(@"locationString:%@",locationString);
    NSDictionary *dic = [MuzzikItem getDictionaryFromLocalForKey:@"Muzzik_Check_Comment_Five_star"];
    if (dic == nil) {
        dic = [NSDictionary dictionaryWithObjectsAndKeys:@"0",@"times",locationString,@"date",@"no",@"hasClicked", nil];
        [MuzzikItem addObjectToLocal:dic ForKey:@"Muzzik_Check_Comment_Five_star"];
    }else if(![[dic objectForKey:@"hasClicked"] isEqualToString:@"yes"]){
        
        if (![[dic objectForKey:@"date"] isEqualToString:locationString]) {
            NSString *tempString = [dic objectForKey:@"times"];
            tempString = [NSString stringWithFormat:@"%d",[tempString intValue]+1];
            if ([tempString intValue]==2) {
                [MuzzikItem addObjectToLocal:[NSDictionary dictionaryWithObjectsAndKeys:@"0",@"times",locationString,@"date",@"no",@"hasClicked", nil] ForKey:@"Muzzik_Check_Comment_Five_star"];
                timeCount = 120;
                timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
            }else{
                [MuzzikItem addObjectToLocal:[NSDictionary dictionaryWithObjectsAndKeys:tempString,@"times",locationString,@"date",@"no",@"hasClicked", nil] ForKey:@"Muzzik_Check_Comment_Five_star"];
            }
        }
    }

    
}
-(void)updateTime{
    if (timeCount>0) {
        NSLog(@"%d",timeCount);
        timeCount-- ;
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"跪求五星好评" message:@"" delegate:self cancelButtonTitle:@"残忍拒绝" otherButtonTitles:nil];
        // optional - add more buttons:
        [alert addButtonWithTitle:@"走你!"];
        [alert show];
        [timer invalidate];
        timer = nil;
        
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    [lineBar setFrame:CGRectMake(mainScroll.contentOffset.x*(lineBar.frame.size.width/SCREEN_WIDTH), lineBar.frame.origin.y, lineBar.frame.size.width, lineBar.frame.size.height)];
}
-(void)dealloc{
    [mainScroll removeObserver:self forKeyPath:@"contentOffset"];
}
-(void)switchTableView:(UIButton *)sender{
    if (sender == feedButton ) {
        [mainScroll scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        
    }else{
        [mainScroll scrollRectToVisible:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, 1) animated:YES];
    }
}
-(void)tapAction:(UITapGestureRecognizer *)tap{
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    searchViewController *search = [[searchViewController alloc ] init];
    [self.navigationController pushViewController:search animated:YES];
}

- (void)addCoverVCToWindow {
    userInfo *user = [userInfo shareClass];
    user.launched = YES;
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    coverImageView = [[UIImageView alloc] initWithFrame:self.navigationController.view.bounds];
    [coverImageView setImage:[UIImage imageNamed:@"startImage"]];
    coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    UIImageView *startLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Startslogan"]];
    
    UIImageView *startSlogan = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"muzzikSlogan"]];
    
    [startSlogan setFrame:CGRectMake(SCREEN_WIDTH-18-startSlogan.frame.size.width, SCREEN_HEIGHT-startSlogan.frame.size.height-18, startSlogan.frame.size.width, startSlogan.frame.size.height)];
    [startLogo setAlpha:0];
    NSLog(@"width:%f",[ UIScreen mainScreen ].bounds.size.width);
    if([ UIScreen mainScreen ].bounds.size.width>320){
        [startLogo setFrame:CGRectMake(20, 64, startLogo.frame.size.width, startLogo.frame.size.height)];
    }else{
        [startLogo setFrame:CGRectMake(13, 64, SCREEN_WIDTH-36, startLogo.frame.size.height)];
    }
    
    
    [UIView animateWithDuration:2 animations:^{
        [startLogo setAlpha:1];
    }];
    
    startLogo.contentMode = UIViewContentModeScaleAspectFit;
    [coverImageView addSubview:startLogo];
    [coverImageView addSubview:startSlogan];
    [app.window addSubview:coverImageView];
    [UIView animateWithDuration:0.3 delay:5 options:UIViewAnimationOptionTransitionNone animations:^{
        [coverImageView setAlpha:0];
    } completion:^(BOOL finished) {
        [coverImageView removeFromSuperview];
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_New_notify_Now]]];
        [request addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = request;
        [request setCompletionBlock :^{
            NSData *data = [weakrequest responseData];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if (dic && [[dic allKeys] containsObject:@"result"] && [[dic objectForKey:@"result"] integerValue]>0) {
                [self getMessage];
            }
        }];
        [request startAsynchronous];
    }];
}
-(void)getMessage{
    
}
- (void)feedRefreshHeader
{

    // [self updateSomeThing];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/feeds",BaseURL]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:Limit_Constant forKey:Parameter_Limit] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        // NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            [self.feedMuzziks removeAllObjects];
            muzzik *muzzikToy = [muzzik new];
            NSArray *array = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
            for (muzzik *tempmuzzik in array) {
                BOOL isContained = NO;
                for (muzzik *arrayMuzzik in self.feedMuzziks) {
                    if ([arrayMuzzik.muzzik_id isEqualToString:tempmuzzik.muzzik_id]) {
                        isContained = YES;
                        break;
                    }
                    
                }
                if (!isContained) {
                    [self.feedMuzziks addObject:tempmuzzik];
                }
                isContained = NO;
            }
            
            ASIHTTPRequest *requestCard = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/card",BaseURL]]];
            [requestCard addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
            __weak ASIHTTPRequest *weakrequestCard = requestCard;
            [requestCard setCompletionBlock :^{
                 NSMutableArray *suggestCardArray = [[MuzzikItem getArrayFromLocalForKey:@"Muzzik_suggest_Day_ClickArray"] mutableCopy];
                if (!suggestCardArray) {
                    suggestCardArray = [NSMutableArray array];
                }
                NSData *data = [weakrequestCard responseData];
                NSDictionary *cardDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSArray *requestArray ;
                if (cardDic && [[cardDic allKeys] containsObject:@"muzziks"]) {
                    requestArray = [cardDic objectForKey:@"muzziks"];
                    for (NSDictionary *tempDic in requestArray) {
                        
                        if (![suggestCardArray containsObject:[tempDic objectForKey:@"_id"]]) {
                            for (muzzik *checkMuzzik in self.feedMuzziks) {
                                if ([[tempDic objectForKey:@"_id"] isEqualToString:checkMuzzik.muzzik_id]) {
                                    if (self.feedMuzziks.count >1) {
                                        
                                        [self.feedMuzziks removeObject:checkMuzzik];
                                    }
                                    break;
                                }
                                
                            }
                            [self.feedMuzziks insertObject:[[muzzik new] makeMuzziksByMuzzikArray:[NSMutableArray arrayWithObjects:tempDic, nil]][0] atIndex:1];
                            break;
                        }
                        
                        
                    }
                    [MuzzikItem SetUserInfoWithMuzziks:self.feedMuzziks title:Constant_userInfo_follow description:[NSString stringWithFormat:@"关注列表"]];
                    
                    feedLastId = [dic objectForKey:@"tail"];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [feedTableView reloadData];
                        [feedTableView headerEndRefreshing];
                    });

                }
                
            }];
            [requestCard setFailedBlock:^{
                
                [feedTableView headerEndRefreshing];
            }];
            [requestCard startAsynchronous];
        }
    }];
    [request setFailedBlock:^{
        [feedTableView headerEndRefreshing];
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
    }];
    [request startAsynchronous];
    
}

- (void)feedReshFooter
{
    
    // [self updateSomeThing];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/feeds",BaseURL]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:feedLastId,Parameter_from,Limit_Constant,Parameter_Limit, nil] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        // NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            muzzik *muzzikToy = [muzzik new];
            NSArray *array = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
            for (muzzik *tempmuzzik in array) {
                BOOL isContained = NO;
                for (muzzik *arrayMuzzik in self.feedMuzziks) {
                    if ([arrayMuzzik.muzzik_id isEqualToString:tempmuzzik.muzzik_id]) {
                        isContained = YES;
                        break;
                    }
                    
                }
                if (!isContained) {
                    [self.feedMuzziks addObject:tempmuzzik];
                }
                isContained = NO;
            }
            [MuzzikItem SetUserInfoWithMuzziks:self.feedMuzziks title:Constant_userInfo_follow description:[NSString stringWithFormat:@"关注列表"]];
            feedLastId = [dic objectForKey:@"tail"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [feedTableView reloadData];
                [feedTableView footerEndRefreshing];
                if ([[dic objectForKey:@"muzziks"] count]<1 ) {
                    [feedTableView removeFooter];
                }
            });
            
        }
    }];
    [request setFailedBlock:^{
        [feedTableView footerEndRefreshing];
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
    }];
    [request startAsynchronous];
    
}


- (void)trendRefreshHeader
{
    // [self updateSomeThing];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Muzzik_Trending]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:Limit_Constant forKey:Parameter_Limit] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            [self.trendMuzziks removeAllObjects];
            muzzik *muzzikToy = [muzzik new];
            NSArray *array = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
            for (muzzik *tempmuzzik in array) {
                BOOL isContained = NO;
                for (muzzik *arrayMuzzik in self.trendMuzziks) {
                    if ([arrayMuzzik.muzzik_id isEqualToString:tempmuzzik.muzzik_id]) {
                        isContained = YES;
                        break;
                    }
                    
                }
                if (!isContained) {
                    [self.trendMuzziks addObject:tempmuzzik];
                }
                isContained = NO;
            }
            
            ASIHTTPRequest *requestCard = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/card",BaseURL]]];
            [requestCard addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
            __weak ASIHTTPRequest *weakrequestCard = requestCard;
            [requestCard setCompletionBlock :^{
                NSMutableArray *suggestCardArray = [[MuzzikItem getArrayFromLocalForKey:@"Muzzik_suggest_Day_ClickArray"] mutableCopy];
                if (!suggestCardArray) {
                    suggestCardArray = [NSMutableArray array];
                }
                NSData *data = [weakrequestCard responseData];
                NSDictionary *cardDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSArray *requestArray ;
                if (cardDic && [[cardDic allKeys] containsObject:@"muzziks"]) {
                    requestArray = [cardDic objectForKey:@"muzziks"];
                    for (NSDictionary *tempDic in requestArray) {
                        
                        if (![suggestCardArray containsObject:[tempDic objectForKey:@"_id"]]) {
                            for (muzzik *checkMuzzik in self.trendMuzziks) {
                                if ([[tempDic objectForKey:@"_id"] isEqualToString:checkMuzzik.muzzik_id]) {
                                    if (self.trendMuzziks.count >1) {
                                        
                                        [self.trendMuzziks removeObject:checkMuzzik];
                                    }
                                    break;
                                }
                                
                            }
                            [self.trendMuzziks insertObject:[[muzzik new] makeMuzziksByMuzzikArray:[NSMutableArray arrayWithObjects:tempDic, nil]][0] atIndex:1];
                            break;
                        }
                        
                        
                    }
                    [MuzzikItem SetUserInfoWithMuzziks:self.trendMuzziks title:Constant_userInfo_square description:nil];
                    
                    trendLastId = [dic objectForKey:@"tail"];;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [trendTableView reloadData];
                        [trendTableView headerEndRefreshing];
                    });
                    
                }
                
            }];
            [requestCard setFailedBlock:^{
                
                [trendTableView headerEndRefreshing];
            }];
            [requestCard startAsynchronous];
            
            
            
            
        }
    }];
    [request setFailedBlock:^{
        [trendTableView headerEndRefreshing];
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
    }];
    [request startAsynchronous];
    
}

- (void)trendRefreshFooter
{
    // [self updateSomeThing];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Muzzik_Trending]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:trendLastId,Parameter_from,Limit_Constant,Parameter_Limit, nil] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        // NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            muzzik *muzzikToy = [muzzik new];
            NSArray *array = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
            for (muzzik *tempmuzzik in array) {
                BOOL isContained = NO;
                for (muzzik *arrayMuzzik in self.trendMuzziks) {
                    if ([arrayMuzzik.muzzik_id isEqualToString:tempmuzzik.muzzik_id]) {
                        isContained = YES;
                        break;
                    }
                    
                }
                if (!isContained) {
                    [self.trendMuzziks addObject:tempmuzzik];
                }
                isContained = NO;
            }
            [MuzzikItem SetUserInfoWithMuzziks:self.trendMuzziks title:Constant_userInfo_square description:nil];
            trendLastId = [dic objectForKey:@"tail"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [trendTableView reloadData];
                [trendTableView footerEndRefreshing];
                if ([[dic objectForKey:@"muzziks"] count]<[Limit_Constant integerValue] ) {
                    [trendTableView removeFooter];
                }
            });
            
        }
    }];
    [request setFailedBlock:^{
        [trendTableView footerEndRefreshing];
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
    }];
    [request startAsynchronous];
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
    userInfo *user = [userInfo shareClass];
    if ([user.token length] >0) {
        [self initNagationBar:@"" leftBtn:8 rightBtn:0];
        [self.navigationController.view addSubview:switchView];
    }else{
        [switchView removeFromSuperview];
        [self initNagationBar:@"Muzzik" leftBtn:8 rightBtn:0];
    }
    

//    UIImageView *headImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"followtitleImage"]];
//    [headImage setFrame:CGRectMake((self.parentRoot.titleShowView.frame.size.width-headImage.frame.size.width)/2, 5, headImage.frame.size.width, headImage.frame.size.height)];

    // MytableView add
    //[MytableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [switchView removeFromSuperview];
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

#pragma mark <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        if (tableView == feedTableView) {
            return self.feedMuzziks.count;
        }else{
            return self.trendMuzziks.count;
        }
    }else{
        return self.trendMuzziks.count;
    }
    
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    muzzik *tempMuzzik;
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        if (tableView == feedTableView) {
            tempMuzzik = [self.feedMuzziks objectAtIndex:indexPath.row];
        }else{
            tempMuzzik = [self.trendMuzziks objectAtIndex:indexPath.row];
        }
    }else{
        tempMuzzik = [self.trendMuzziks objectAtIndex:indexPath.row];
    }
    
    if ([tempMuzzik.type isEqualToString:@"normal"] ||[tempMuzzik.type isEqualToString:@"repost"]) {
        
        TTTAttributedLabel *label = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(75, 0, SCREEN_WIDTH-110, 500)];
        [label setFont:[UIFont systemFontOfSize:Font_Size_Muzzik_Message]];
        [label setText:tempMuzzik.message];
        CGFloat textHeight = [MuzzikItem heightForLabel:label WithText:label.text];
        if (textHeight>limitHeight) {
            if (![tempMuzzik.image isKindOfClass:[NSNull class]] && [tempMuzzik.image length]>0) {
                return (int)(260+limitHeight+SCREEN_WIDTH*3/4)+10;
            }else{
                return 260+limitHeight;
            }
            
        }else{
            if (![tempMuzzik.image isKindOfClass:[NSNull class]] && [tempMuzzik.image length]>0) {
                return (int)(260+textHeight+SCREEN_WIDTH*3/4);
            }else{
                return 260+(int)textHeight;
            }
        }
    }else if([tempMuzzik.type isEqualToString:@"muzzikCard"]){
        TTTAttributedLabel *label = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(75, 0, SCREEN_WIDTH-96, 500)];
        [label setText:tempMuzzik.message];
        [label setFont:[UIFont systemFontOfSize:Font_Size_Muzzik_Message]];
        CGFloat textHeight = [MuzzikItem heightForLabel:label WithText:label.text];
        if (textHeight>limitHeight) {
            if (![tempMuzzik.image isKindOfClass:[NSNull class]] && [tempMuzzik.image length]>0) {
                return SCREEN_WIDTH+limitHeight+80;
            }else{
                return limitHeight+190;
            }
        }
        else{
            if (![tempMuzzik.image isKindOfClass:[NSNull class]] && [tempMuzzik.image length]>0) {
                return (int)(SCREEN_WIDTH+textHeight+80);
            }else{
                return textHeight+190;
            }
            
        }
    }
    else if([tempMuzzik.type isEqualToString:@"musicCard"]){
        return 108;
    }else if([tempMuzzik.type isEqualToString:@"topicCard"]){
        return 101;
    }else{
        return 0;
    }
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    muzzik *tempMuzzik;
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        if (tableView == feedTableView) {
            tempMuzzik = [self.feedMuzziks objectAtIndex:indexPath.row];
        }else{
            tempMuzzik = [self.trendMuzziks objectAtIndex:indexPath.row];
        }
    }else{
        tempMuzzik = [self.trendMuzziks objectAtIndex:indexPath.row];
    }
    
    if ([tempMuzzik isKindOfClass:[muzzik class]]) {
        if ([tempMuzzik.type isEqualToString:@"muzzikCard"]) {
            NSMutableArray *suggestDic = [[MuzzikItem getArrayFromLocalForKey:@"Muzzik_suggest_Day_ClickArray"] mutableCopy];
            if (!suggestDic) {
                suggestDic = [NSMutableArray array];
            }
            BOOL isTaped = NO;
            for (NSString *dicKey in suggestDic) {
                if ([dicKey isEqualToString:tempMuzzik.muzzik_id]) {
                    isTaped = YES;
                    break;
                }
            }
            if (!isTaped) {
                [suggestDic addObject:tempMuzzik.muzzik_id];
                if ([suggestDic count]>300) {
                    [MuzzikItem addObjectToLocal:[suggestDic subarrayWithRange:NSMakeRange(150, suggestDic.count-150)] ForKey:@"Muzzik_suggest_Day_ClickArray"];
                }else{
                    [MuzzikItem addObjectToLocal:[suggestDic copy] ForKey:@"Muzzik_suggest_Day_ClickArray"];
                }
            }
            DetaiMuzzikVC *detail = [[DetaiMuzzikVC alloc] init];
            detail.muzzik_id = tempMuzzik.muzzik_id;
            [self.navigationController pushViewController:detail animated:YES];
        }
        else if([tempMuzzik.type isEqualToString:@"musicCard"]){
            NSMutableArray *suggestDic = [[MuzzikItem getArrayFromLocalForKey:@"Muzzik_suggest_Day_ClickArray"] mutableCopy];
            if (!suggestDic) {
                suggestDic = [NSMutableArray array];
            }
            BOOL isTaped = NO;
            for (NSString *dicKey in suggestDic) {
                if ([dicKey isEqualToString:tempMuzzik.muzzik_id]) {
                    isTaped = YES;
                    break;
                }
            }
            if (!isTaped) {
                [suggestDic addObject:tempMuzzik.muzzik_id];
                if ([suggestDic count]>300) {
                    [MuzzikItem addObjectToLocal:[suggestDic subarrayWithRange:NSMakeRange(150, suggestDic.count-150)] ForKey:@"Muzzik_suggest_Day_ClickArray"];
                }else{
                    [MuzzikItem addObjectToLocal:[suggestDic copy] ForKey:@"Muzzik_suggest_Day_ClickArray"];
                }
            }

            songDetailVCViewController *songDetail = [[songDetailVCViewController alloc] init];
            songDetail.detailMuzzik = tempMuzzik;
            [self.navigationController pushViewController:songDetail animated:YES];
        }
        else if([tempMuzzik.type isEqualToString:@"topicCard"]){
            NSMutableArray *suggestDic = [[MuzzikItem getArrayFromLocalForKey:@"Muzzik_suggest_Day_ClickArray"] mutableCopy];
            if (!suggestDic) {
                suggestDic = [NSMutableArray array];
            }
            BOOL isTaped = NO;
            for (NSString *dicKey in suggestDic) {
                if ([dicKey isEqualToString:tempMuzzik.muzzik_id]) {
                    isTaped = YES;
                    break;
                }
            }
            if (!isTaped) {
                [suggestDic addObject:tempMuzzik.muzzik_id];
                if ([suggestDic count]>300) {
                    [MuzzikItem addObjectToLocal:[suggestDic subarrayWithRange:NSMakeRange(150, suggestDic.count-150)] ForKey:@"Muzzik_suggest_Day_ClickArray"];
                }else{
                    [MuzzikItem addObjectToLocal:[suggestDic copy] ForKey:@"Muzzik_suggest_Day_ClickArray"];
                }
            }

            TopicDetail *topic = [[TopicDetail alloc] init];
            topic.topic_id = [tempMuzzik.topics[0] objectForKey:@"_id"];
            [self.navigationController pushViewController:topic animated:YES];
        }
        else{
            DetaiMuzzikVC *detail = [[DetaiMuzzikVC alloc] init];
            detail.muzzik_id = tempMuzzik.muzzik_id;
            [self.navigationController pushViewController:detail animated:YES];
        }
        
        
    }
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Globle *glob = [Globle shareGloble];
    muzzik *tempMuzzik;
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        if (tableView == feedTableView) {
            tempMuzzik = [self.feedMuzziks objectAtIndex:indexPath.row];
        }else{
            tempMuzzik = [self.trendMuzziks objectAtIndex:indexPath.row];
        }
    }else{
        tempMuzzik = [self.trendMuzziks objectAtIndex:indexPath.row];
    }
    if ([tempMuzzik.type isEqualToString:@"repost"] || [tempMuzzik.type isEqualToString:@"normal"] || [tempMuzzik.type isEqualToString:@"muzzikCard"])
    {
        if (![tempMuzzik.image isKindOfClass:[NSNull class]] && [tempMuzzik.image length] == 0) {
            if ([tempMuzzik.type isEqualToString:@"repost"] ){
                NormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell" forIndexPath:indexPath];
                cell.songModel = tempMuzzik;
                if ([tempMuzzik.muzzik_id isEqualToString:self.musicplayer.localMuzzik.muzzik_id] &&!glob.isPause && glob.isPlaying) {
                    cell.isPlaying = YES;
                }else{
                    cell.isPlaying = NO;
                }
                cell.userName.text = tempMuzzik.MuzzikUser.name;
                if (tempMuzzik.isprivate ) {
                    [cell.privateImage setHidden:NO];
                    [cell.userName sizeToFit];
                    [cell.privateImage setFrame:CGRectMake(cell.userName.frame.origin.x+cell.userName.frame.size.width+2, cell.userName.frame.origin.y, 20, 20)];
                }else{
                    [cell.privateImage setHidden:YES];
                    [cell.userName setFrame:CGRectMake(80, 55, SCREEN_WIDTH-120, 20)];
                }
                
                [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,tempMuzzik.MuzzikUser.avatar,Image_Size_Small]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (tableView == trendTableView) {
                        if (![[trendRefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                            [cell.userImage setAlpha:0];
                            [trendRefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                            [UIView animateWithDuration:0.5 animations:^{
                                [cell.userImage setAlpha:1];
                            }];
                        }
                    }else{
                        if (![[feedRefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                            [cell.userImage setAlpha:0];
                            [feedRefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                            [UIView animateWithDuration:0.5 animations:^{
                                [cell.userImage setAlpha:1];
                            }];
                        }
                    }
                    
                    
                }];

                
                cell.userName.text = tempMuzzik.MuzzikUser.name;
                [cell.repostImage setHidden:NO];
                cell.repostUserName.text = tempMuzzik.reposter.name;
                cell.muzzikMessage.text = tempMuzzik.message;
                [cell.muzzikMessage addClickMessagewithTopics:tempMuzzik.topics];
                [cell.muzzikMessage addClickMessageForAt];
                cell.isMoved = tempMuzzik.ismoved;
                cell.isReposted = tempMuzzik.isReposted;
                cell.index = indexPath.row;
                cell.muzzikMessage.delegate = self;
                CGFloat textHeight = [MuzzikItem heightForLabel:cell.muzzikMessage WithText:cell.muzzikMessage.text];
                if (textHeight>limitHeight) {
                    [cell.muzzikMessage setFrame:CGRectMake((int)floor(cell.muzzikMessage.frame.origin.x), (int)floor(cell.muzzikMessage.frame.origin.y), cell.muzzikMessage.frame.size.width, limitHeight)];
                }else{
                    [cell.muzzikMessage setFrame:CGRectMake((int)floor(cell.muzzikMessage.frame.origin.x), (int)floor(cell.muzzikMessage.frame.origin.y), cell.muzzikMessage.frame.size.width, textHeight)];
                }
                [cell.musicPlayView setFrame:CGRectMake(0, (int)floor(95+cell.muzzikMessage.bounds.size.height), SCREEN_WIDTH, cell.musicPlayView.frame.size.height)];
                cell.musicArtist.text =tempMuzzik.music.artist;
                cell.musicName.text = tempMuzzik.music.name;
                cell.timeStamp.text = [MuzzikItem transtromTime:tempMuzzik.repostDate];
                
                [cell colorViewWithColorString:[NSString stringWithFormat:@"%@",tempMuzzik.color]];
                cell.muzzik_id = tempMuzzik.muzzik_id;
                cell.delegate=self;
                if ([tempMuzzik.moveds integerValue]>0) {
                    [cell.moves setTitle:[NSString stringWithFormat:@"喜欢数%@",tempMuzzik.moveds] forState:UIControlStateNormal];
                }else{
                    [cell.moves setTitle:@"喜欢数" forState:UIControlStateNormal];
                }
                if ([tempMuzzik.reposts integerValue]>0) {
                    [cell.reposts setTitle:[NSString stringWithFormat:@"转发数%@",tempMuzzik.reposts] forState:UIControlStateNormal];
                }
                else{
                    [cell.reposts setTitle:@"转发数" forState:UIControlStateNormal];
                }
                if ([tempMuzzik.comments integerValue]>0) {
                    [cell.comments setTitle:[NSString stringWithFormat:@"评论数%@",tempMuzzik.comments ] forState:UIControlStateNormal];
                }
                else{
                    [cell.comments setTitle:@"评论数" forState:UIControlStateNormal];
                }
                if ([tempMuzzik.shares integerValue]>0) {
                    [cell.shares setTitle:[NSString stringWithFormat:@"分享数%@",tempMuzzik.shares] forState:UIControlStateNormal];
                }
                else{
                    [cell.shares setTitle:@"分享数" forState:UIControlStateNormal];
                }
                return  cell;
            }
            else if([tempMuzzik.type isEqualToString:@"normal"]){
                NormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell" forIndexPath:indexPath];
                cell.songModel = tempMuzzik;
                if ([tempMuzzik.muzzik_id isEqualToString:self.musicplayer.localMuzzik.muzzik_id] &&!glob.isPause && glob.isPlaying) {
                    cell.isPlaying = YES;
                }else{
                    cell.isPlaying = NO;
                }
                [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,tempMuzzik.MuzzikUser.avatar,Image_Size_Small]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (tableView == trendTableView) {
                        if (![[trendRefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                            [cell.userImage setAlpha:0];
                            [trendRefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                            [UIView animateWithDuration:0.5 animations:^{
                                [cell.userImage setAlpha:1];
                            }];
                        }
                    }else{
                        if (![[feedRefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                            [cell.userImage setAlpha:0];
                            [feedRefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                            [UIView animateWithDuration:0.5 animations:^{
                                [cell.userImage setAlpha:1];
                            }];
                        }
                    }
                    
                    
                }];
                
                cell.userName.text = tempMuzzik.MuzzikUser.name;
                if (tempMuzzik.isprivate ) {
                    [cell.privateImage setHidden:NO];
                    [cell.userName sizeToFit];
                    [cell.privateImage setFrame:CGRectMake(cell.userName.frame.origin.x+cell.userName.frame.size.width+2, cell.userName.frame.origin.y, 20, 20)];
                }else{
                    [cell.privateImage setHidden:YES];
                    [cell.userName setFrame:CGRectMake(80, 55, SCREEN_WIDTH-120, 20)];
                }
                
                cell.repostUserName.text = @"";
                [cell.repostImage setHidden:YES];
                cell.muzzikMessage.text = tempMuzzik.message;
                [cell.muzzikMessage addClickMessagewithTopics:tempMuzzik.topics];
                [cell.muzzikMessage addClickMessageForAt];
                cell.isMoved = tempMuzzik.ismoved;
                cell.isReposted = tempMuzzik.isReposted;
                cell.index = indexPath.row;
                cell.muzzikMessage.delegate = self;
                CGFloat textHeight = [MuzzikItem heightForLabel:cell.muzzikMessage WithText:cell.muzzikMessage.text];
                if (textHeight>limitHeight) {
                    [cell.muzzikMessage setFrame:CGRectMake((int)floor(cell.muzzikMessage.frame.origin.x), (int)floor(cell.muzzikMessage.frame.origin.y), cell.muzzikMessage.frame.size.width, limitHeight)];
                }else{
                    [cell.muzzikMessage setFrame:CGRectMake((int)floor(cell.muzzikMessage.frame.origin.x), (int)floor(cell.muzzikMessage.frame.origin.y), cell.muzzikMessage.frame.size.width, textHeight)];
                }
                [cell.musicPlayView setFrame:CGRectMake(0,(int) floor(95+cell.muzzikMessage.bounds.size.height), SCREEN_WIDTH, cell.musicPlayView.frame.size.height)];
                cell.musicArtist.text =tempMuzzik.music.artist;
                cell.musicName.text = tempMuzzik.music.name;
                cell.timeStamp.text = [MuzzikItem transtromTime:tempMuzzik.date];
                
                [cell colorViewWithColorString:[NSString stringWithFormat:@"%@",tempMuzzik.color]];
                cell.muzzik_id = tempMuzzik.muzzik_id;
                cell.delegate=self;
                if ([tempMuzzik.moveds integerValue]>0) {
                    [cell.moves setTitle:[NSString stringWithFormat:@"喜欢数%@",tempMuzzik.moveds] forState:UIControlStateNormal];
                }else{
                    [cell.moves setTitle:@"喜欢数" forState:UIControlStateNormal];
                }
                if ([tempMuzzik.reposts integerValue]>0) {
                    [cell.reposts setTitle:[NSString stringWithFormat:@"转发数%@",tempMuzzik.reposts] forState:UIControlStateNormal];
                }
                else{
                    [cell.reposts setTitle:@"转发数" forState:UIControlStateNormal];
                }
                if ([tempMuzzik.comments integerValue]>0) {
                    [cell.comments setTitle:[NSString stringWithFormat:@"评论数%@",tempMuzzik.comments ] forState:UIControlStateNormal];
                }
                else{
                    [cell.comments setTitle:@"评论数" forState:UIControlStateNormal];
                }
                if ([tempMuzzik.shares integerValue]>0) {
                    [cell.shares setTitle:[NSString stringWithFormat:@"分享数%@",tempMuzzik.shares] forState:UIControlStateNormal];
                }
                else{
                    [cell.shares setTitle:@"分享数" forState:UIControlStateNormal];
                }
                return  cell;
            }
            else{
                MuzzikNoCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MuzzikNoCardCell" forIndexPath:indexPath];
                cell.songModel = tempMuzzik;
                if ([tempMuzzik.muzzik_id isEqualToString:self.musicplayer.localMuzzik.muzzik_id] &&!glob.isPause && glob.isPlaying) {
                    cell.isPlaying = YES;
                }else{
                    cell.isPlaying = NO;
                }
                cell.delegate = self;
                cell.cardTitle.text = tempMuzzik.title;
                cell.userName.text = tempMuzzik.MuzzikUser.name;
                cell.timeStamp.text = [MuzzikItem transtromTime:tempMuzzik.date];
                [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,tempMuzzik.MuzzikUser.avatar,Image_Size_Small]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (tableView == trendTableView) {
                        if (![[trendRefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                            [cell.userImage setAlpha:0];
                            [trendRefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                            [UIView animateWithDuration:0.5 animations:^{
                                [cell.userImage setAlpha:1];
                            }];
                        }
                    }else{
                        if (![[feedRefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                            [cell.userImage setAlpha:0];
                            [feedRefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                            [UIView animateWithDuration:0.5 animations:^{
                                [cell.userImage setAlpha:1];
                            }];
                        }
                    }
                    
                    
                }];
                cell.muzzikMessage.delegate = self;
                [cell colorViewWithColorString:[NSString stringWithFormat:@"%@",tempMuzzik.color]];
                cell.index = indexPath.row;
                cell.isMoved = tempMuzzik.ismoved;
                cell.muzzikMessage.text = tempMuzzik.message;
                [cell.muzzikMessage addClickMessagewithTopics:tempMuzzik.topics];
                [cell.muzzikMessage addClickMessageForAt];
                CGFloat textHeight = [MuzzikItem heightForLabel:cell.muzzikMessage WithText:cell.muzzikMessage.text];
                if (textHeight>limitHeight) {
                    [cell.muzzikMessage setFrame:CGRectMake((int)floor(cell.muzzikMessage.frame.origin.x), (int)floor(cell.muzzikMessage.frame.origin.y), cell.muzzikMessage.frame.size.width, limitHeight)];
                }else{
                    [cell.muzzikMessage setFrame:CGRectMake((int)floor(cell.muzzikMessage.frame.origin.x), (int)floor(cell.muzzikMessage.frame.origin.y), cell.muzzikMessage.frame.size.width, textHeight)];
                }
                [cell.musicPlayView setFrame:CGRectMake(0, (int)floor(cell.muzzikMessage.frame.origin.y+cell.muzzikMessage.frame.size.height+12),cell.musicPlayView.frame.size.width, (int)floor(cell.musicPlayView.frame.size.height))];
                [cell.cardView setFrame:CGRectMake(16, 20, SCREEN_WIDTH-32, (int)floor(cell.muzzikMessage.frame.origin.y+cell.muzzikMessage.frame.size.height+80))];
                cell.musicArtist.text =tempMuzzik.music.artist;
                cell.musicName.text = tempMuzzik.music.name;
                return cell;
                
            }
        }
        else{
            if ([tempMuzzik.type isEqualToString:@"repost"] ){
                NormalNoCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalNoCardCell" forIndexPath:indexPath];
                cell.songModel = tempMuzzik;
                if ([tempMuzzik.muzzik_id isEqualToString:self.musicplayer.localMuzzik.muzzik_id] &&!glob.isPause && glob.isPlaying) {
                    cell.isPlaying = YES;
                }else{
                    cell.isPlaying = NO;
                }
                cell.userName.text = tempMuzzik.MuzzikUser.name;
                if (tempMuzzik.isprivate ) {
                    [cell.privateImage setHidden:NO];
                    [cell.userName sizeToFit];
                    [cell.privateImage setFrame:CGRectMake(cell.userName.frame.origin.x+cell.userName.frame.size.width+2, cell.userName.frame.origin.y, 20, 20)];
                }else{
                    [cell.privateImage setHidden:YES];
                    [cell.userName setFrame:CGRectMake(80, 55, SCREEN_WIDTH-120, 20)];
                }
                [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,tempMuzzik.MuzzikUser.avatar,Image_Size_Small]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (tableView == trendTableView) {
                        if (![[trendRefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                            [cell.userImage setAlpha:0];
                            [trendRefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                            [UIView animateWithDuration:0.5 animations:^{
                                [cell.userImage setAlpha:1];
                            }];
                        }
                    }else{
                        if (![[feedRefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                            [cell.userImage setAlpha:0];
                            [feedRefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                            [UIView animateWithDuration:0.5 animations:^{
                                [cell.userImage setAlpha:1];
                            }];
                        }
                    }
                    
                    
                }];
                
                [cell.poImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,tempMuzzik.image,Image_Size_Big]] placeholderImage:[UIImage imageNamed:Image_placeholdImage] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (tableView == trendTableView) {
                        if (![[trendReFreshPoImageDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                            [cell.poImage setAlpha:0];
                            [trendReFreshPoImageDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                            [UIView animateWithDuration:0.5 animations:^{
                                [cell.poImage setAlpha:1];
                            }];
                        }
                    }else{
                        if (![[feedReFreshPoImageDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                            [cell.poImage setAlpha:0];
                            [feedReFreshPoImageDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                            [UIView animateWithDuration:0.5 animations:^{
                                [cell.poImage setAlpha:1];
                            }];
                        }
                    }
                    
                    
                }];
                cell.userName.text = tempMuzzik.MuzzikUser.name;
                [cell.repostImage setHidden:NO];
                cell.repostUserName.text = tempMuzzik.reposter.name;
                cell.muzzikMessage.text = tempMuzzik.message;
                [cell.muzzikMessage addClickMessagewithTopics:tempMuzzik.topics];
                [cell.muzzikMessage addClickMessageForAt];
                cell.isMoved = tempMuzzik.ismoved;
                cell.isReposted = tempMuzzik.isReposted;
                cell.index = indexPath.row;
                cell.muzzikMessage.delegate = self;
                CGFloat textHeight = [MuzzikItem heightForLabel:cell.muzzikMessage WithText:cell.muzzikMessage.text];
                if (textHeight>limitHeight) {
                    [cell.muzzikMessage setFrame:CGRectMake((int)floor(cell.muzzikMessage.frame.origin.x), (int)floor(cell.muzzikMessage.frame.origin.y), cell.muzzikMessage.frame.size.width, limitHeight)];
                }else{
                    [cell.muzzikMessage setFrame:CGRectMake((int)floor(cell.muzzikMessage.frame.origin.x), (int)floor(cell.muzzikMessage.frame.origin.y), cell.muzzikMessage.frame.size.width, textHeight)];
                }
                [cell.musicPlayView setFrame:CGRectMake(0,(int)floor( 95+cell.muzzikMessage.bounds.size.height), SCREEN_WIDTH, (int)cell.musicPlayView.frame.size.height)];
                cell.musicArtist.text =tempMuzzik.music.artist;
                cell.musicName.text = tempMuzzik.music.name;
                cell.timeStamp.text = [MuzzikItem transtromTime:tempMuzzik.repostDate];
                
                [cell colorViewWithColorString:[NSString stringWithFormat:@"%@",tempMuzzik.color]];
                cell.muzzik_id = tempMuzzik.muzzik_id;
                cell.delegate=self;
                if ([tempMuzzik.moveds integerValue]>0) {
                    [cell.moves setTitle:[NSString stringWithFormat:@"喜欢数%@",tempMuzzik.moveds] forState:UIControlStateNormal];
                }else{
                    [cell.moves setTitle:@"喜欢数" forState:UIControlStateNormal];
                }
                if ([tempMuzzik.reposts integerValue]>0) {
                    [cell.reposts setTitle:[NSString stringWithFormat:@"转发数%@",tempMuzzik.reposts] forState:UIControlStateNormal];
                }
                else{
                    [cell.reposts setTitle:@"转发数" forState:UIControlStateNormal];
                }
                if ([tempMuzzik.comments integerValue]>0) {
                    [cell.comments setTitle:[NSString stringWithFormat:@"评论数%@",tempMuzzik.comments ] forState:UIControlStateNormal];
                }
                else{
                    [cell.comments setTitle:@"评论数" forState:UIControlStateNormal];
                }
                if ([tempMuzzik.shares integerValue]>0) {
                    [cell.shares setTitle:[NSString stringWithFormat:@"分享数%@",tempMuzzik.shares] forState:UIControlStateNormal];
                }
                else{
                    [cell.shares setTitle:@"分享数" forState:UIControlStateNormal];
                }
                return  cell;
            }
            else if([tempMuzzik.type isEqualToString:@"normal"]){
                NormalNoCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalNoCardCell" forIndexPath:indexPath];
                cell.songModel = tempMuzzik;
                if ([tempMuzzik.muzzik_id isEqualToString:self.musicplayer.localMuzzik.muzzik_id] &&!glob.isPause && glob.isPlaying) {
                    cell.isPlaying = YES;
                }else{
                    cell.isPlaying = NO;
                }
                [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,tempMuzzik.MuzzikUser.avatar,Image_Size_Small]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (tableView == trendTableView) {
                        if (![[trendRefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                            [cell.userImage setAlpha:0];
                            [trendRefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                            [UIView animateWithDuration:0.5 animations:^{
                                [cell.userImage setAlpha:1];
                            }];
                        }
                    }else{
                        if (![[feedRefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                            [cell.userImage setAlpha:0];
                            [feedRefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                            [UIView animateWithDuration:0.5 animations:^{
                                [cell.userImage setAlpha:1];
                            }];
                        }
                    }
                    
                    
                }];
                
                [cell.poImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,tempMuzzik.image,Image_Size_Big]] placeholderImage:[UIImage imageNamed:Image_placeholdImage] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (tableView == trendTableView) {
                        if (![[trendReFreshPoImageDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                            [cell.poImage setAlpha:0];
                            [trendReFreshPoImageDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                            [UIView animateWithDuration:0.5 animations:^{
                                [cell.poImage setAlpha:1];
                            }];
                        }
                    }else{
                        if (![[feedReFreshPoImageDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                            [cell.poImage setAlpha:0];
                            [feedReFreshPoImageDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                            [UIView animateWithDuration:0.5 animations:^{
                                [cell.poImage setAlpha:1];
                            }];
                        }
                    }
                    
                    
                }];
                cell.userName.text = tempMuzzik.MuzzikUser.name;
                if (tempMuzzik.isprivate ) {
                    [cell.privateImage setHidden:NO];
                    [cell.userName sizeToFit];
                    [cell.privateImage setFrame:CGRectMake(cell.userName.frame.origin.x+cell.userName.frame.size.width+2, cell.userName.frame.origin.y, 20, 20)];
                }else{
                    [cell.privateImage setHidden:YES];
                    [cell.userName setFrame:CGRectMake(80, 55, SCREEN_WIDTH-120, 20)];
                }
                cell.repostUserName.text = @"";
                [cell.repostImage setHidden:YES];
                cell.muzzikMessage.text = tempMuzzik.message;
                [cell.muzzikMessage addClickMessagewithTopics:tempMuzzik.topics];
                [cell.muzzikMessage addClickMessageForAt];
                cell.isMoved = tempMuzzik.ismoved;
                cell.isReposted = tempMuzzik.isReposted;
                cell.index = indexPath.row;
                cell.muzzikMessage.delegate = self;
                CGFloat textHeight = [MuzzikItem heightForLabel:cell.muzzikMessage WithText:cell.muzzikMessage.text];
                if (textHeight>limitHeight) {
                    [cell.muzzikMessage setFrame:CGRectMake((int)floor(cell.muzzikMessage.frame.origin.x), (int)floor(cell.muzzikMessage.frame.origin.y), cell.muzzikMessage.frame.size.width, limitHeight)];
                }else{
                    [cell.muzzikMessage setFrame:CGRectMake((int)floor(cell.muzzikMessage.frame.origin.x), (int)floor(cell.muzzikMessage.frame.origin.y), cell.muzzikMessage.frame.size.width, textHeight)];
                }
                [cell.musicPlayView setFrame:CGRectMake(0, (int)floor(95+cell.muzzikMessage.bounds.size.height), SCREEN_WIDTH, floor(cell.musicPlayView.frame.size.height))];
                cell.musicArtist.text =tempMuzzik.music.artist;
                cell.musicName.text = tempMuzzik.music.name;
                cell.timeStamp.text = [MuzzikItem transtromTime:tempMuzzik.date];
                
                [cell colorViewWithColorString:[NSString stringWithFormat:@"%@",tempMuzzik.color]];
                cell.muzzik_id = tempMuzzik.muzzik_id;
                cell.delegate=self;
                if ([tempMuzzik.moveds integerValue]>0) {
                    [cell.moves setTitle:[NSString stringWithFormat:@"喜欢数%@",tempMuzzik.moveds] forState:UIControlStateNormal];
                }else{
                    [cell.moves setTitle:@"喜欢数" forState:UIControlStateNormal];
                }
                if ([tempMuzzik.reposts integerValue]>0) {
                    [cell.reposts setTitle:[NSString stringWithFormat:@"转发数%@",tempMuzzik.reposts] forState:UIControlStateNormal];
                }
                else{
                    [cell.reposts setTitle:@"转发数" forState:UIControlStateNormal];
                }
                if ([tempMuzzik.comments integerValue]>0) {
                    [cell.comments setTitle:[NSString stringWithFormat:@"评论数%@",tempMuzzik.comments ] forState:UIControlStateNormal];
                }
                else{
                    [cell.comments setTitle:@"评论数" forState:UIControlStateNormal];
                }
                if ([tempMuzzik.shares integerValue]>0) {
                    [cell.shares setTitle:[NSString stringWithFormat:@"分享数%@",tempMuzzik.shares] forState:UIControlStateNormal];
                }
                else{
                    [cell.shares setTitle:@"分享数" forState:UIControlStateNormal];
                }
                return  cell;
            }
            else {
                MuzzikCard *cell = [tableView dequeueReusableCellWithIdentifier:@"MuzzikCard" forIndexPath:indexPath];
                cell.songModel = tempMuzzik;
                if ([tempMuzzik.muzzik_id isEqualToString:self.musicplayer.localMuzzik.muzzik_id] &&!glob.isPause && glob.isPlaying) {
                    cell.isPlaying = YES;
                }else{
                    cell.isPlaying = NO;
                }
                cell.delegate = self;
                cell.cardTitle.text = tempMuzzik.title;
                cell.userName.text = tempMuzzik.MuzzikUser.name;
                cell.timeStamp.text = [MuzzikItem transtromTime:tempMuzzik.date];
                
                [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,tempMuzzik.MuzzikUser.avatar,Image_Size_Small]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (tableView == trendTableView) {
                        if (![[trendRefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                            [cell.userImage setAlpha:0];
                            [trendRefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                            [UIView animateWithDuration:0.5 animations:^{
                                [cell.userImage setAlpha:1];
                            }];
                        }
                    }else{
                        if (![[feedRefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                            [cell.userImage setAlpha:0];
                            [feedRefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                            [UIView animateWithDuration:0.5 animations:^{
                                [cell.userImage setAlpha:1];
                            }];
                        }
                    }
                    
                    
                }];
                
                [cell.muzzikCardImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,tempMuzzik.image,Image_Size_Big]] placeholderImage:[UIImage imageNamed:Image_placeholdImage] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (tableView == trendTableView) {
                        if (![[trendReFreshPoImageDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                            [cell.muzzikCardImage setAlpha:0];
                            [trendReFreshPoImageDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                            [UIView animateWithDuration:0.5 animations:^{
                                [cell.muzzikCardImage setAlpha:1];
                            }];
                        }
                    }else{
                        if (![[feedReFreshPoImageDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                            [cell.muzzikCardImage setAlpha:0];
                            [feedReFreshPoImageDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                            [UIView animateWithDuration:0.5 animations:^{
                                [cell.muzzikCardImage setAlpha:1];
                            }];
                        }
                    }
                    
                    
                }];
               
                cell.index = indexPath.row;
                cell.isMoved = tempMuzzik.ismoved;
                 [cell colorViewWithColorString:[NSString stringWithFormat:@"%@",tempMuzzik.color]];
                cell.muzzikMessage.text = tempMuzzik.message;
                [cell.muzzikMessage addClickMessagewithTopics:tempMuzzik.topics];
                [cell.muzzikMessage addClickMessageForAt];
                
                
                cell.muzzikMessage.delegate = self;
                cell.RepostID = tempMuzzik.repostID;
                CGFloat textHeight = [MuzzikItem heightForLabel:cell.muzzikMessage WithText:cell.muzzikMessage.text];
                if (textHeight>limitHeight) {
                    [cell.muzzikMessage setFrame:CGRectMake((int)floor(cell.muzzikMessage.frame.origin.x), (int)floor(cell.muzzikMessage.frame.origin.y), cell.muzzikMessage.frame.size.width, limitHeight)];
                }else{
                    [cell.muzzikMessage setFrame:CGRectMake((int)floor(cell.muzzikMessage.frame.origin.x), (int)floor(cell.muzzikMessage.frame.origin.y), cell.muzzikMessage.frame.size.width, textHeight)];
                }
                [cell.musicPlayView setFrame:CGRectMake(0, (int)(cell.muzzikMessage.frame.origin.y+cell.muzzikMessage.frame.size.height+12), SCREEN_WIDTH-16, cell.musicPlayView.frame.size.height)];
                [cell.cardView setFrame:CGRectMake(16, 20, SCREEN_WIDTH-32,(int) (cell.muzzikMessage.frame.origin.y+cell.muzzikMessage.frame.size.height+80))];
                cell.musicArtist.text =tempMuzzik.music.artist;
                cell.musicName.text = tempMuzzik.music.name;
                return cell;
            }
            
        }

    }
    else if ([tempMuzzik.type isEqualToString:@"musicCard"] ){
        MuzzikSongCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MuzzikSongCell" forIndexPath:indexPath];
        cell.cardTitle.text = tempMuzzik.title;
        cell.musicArtist.text = tempMuzzik.music.artist;
        cell.musicName.text = tempMuzzik.music.name;
        cell.songModel = tempMuzzik;
        cell.delegate = self;
        if ([tempMuzzik.muzzik_id isEqualToString:self.musicplayer.localMuzzik.muzzik_id] &&!glob.isPause && glob.isPlaying) {
            [cell.playButton setImage:[UIImage imageNamed:Image_stoporangeImage] forState:UIControlStateNormal];
        }else{
             [cell.playButton setImage:[UIImage imageNamed:Image_playgreyImage] forState:UIControlStateNormal];
        }
        return cell;
    }
    else if([tempMuzzik.type isEqualToString:@"topicCard"]){
        MuzzikTopic *cell = [tableView dequeueReusableCellWithIdentifier:@"MuzzikTopic" forIndexPath:indexPath];
        cell.cardTitle.text = tempMuzzik.title;
        cell.TopicLabel.text = [NSString stringWithFormat:@"#%@#",[tempMuzzik.topics[0] objectForKey:@"name"]];
        cell.songModel = tempMuzzik;
        cell.delegate = self;
        return cell;
    }
    else {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        return cell;
    }
    
    
}
-(void)newMuzzik:(muzzik *)localMzzik{
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        //new po
        user.poController = self;
        MessageStepViewController *msgVC = [[MessageStepViewController alloc] init];
        msgVC.isNewSelected = YES;
        [self.navigationController pushViewController:msgVC animated:YES];
        
    }
    else{
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        [self.navigationController pushViewController:loginVC animated:YES];
    }
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}
- (void)attributedLabel:(TTTAttributedLabel *)label
didSelectLinkWithTransitInformation:(NSDictionary *)components{
    NSLog(@"%@",components);
    if ([[components allKeys] containsObject:@"topic_id"]) {
        TopicDetail *topicDetail = [[TopicDetail alloc] init];
        topicDetail.topic_id = [components objectForKey:@"topic_id"];
        [self.navigationController pushViewController:topicDetail animated:YES];
        [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    }else if([[components allKeys] containsObject:@"at_name"]){
        
        userInfo *user = [userInfo shareClass];
        if ([[components objectForKey:@"at_name"] isEqualToString:user.name]) {
//            UserHomePage *home = [[UserHomePage alloc] init];
//            [self.navigationController pushViewController:home animated:YES];
//            [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
        }else{
            userDetailInfo *uInfo = [[userDetailInfo alloc] init];
            uInfo.uid = [[components objectForKey:@"at_name"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [self.navigationController pushViewController:uInfo animated:YES];
            [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
        }
    }
}
-(void)deleteMuzzik:(NSNotification *)notify{
    muzzik *localMzzik = notify.object;
    for (muzzik *tempMuzzik in self.feedMuzziks) {
        if ([tempMuzzik.muzzik_id isEqualToString:localMzzik.muzzik_id]) {
            [self.feedMuzziks removeObject:tempMuzzik];
            [feedTableView reloadData];
            break;
        }
    }
    for (muzzik *tempMuzzik in self.trendMuzziks) {
        if ([tempMuzzik.muzzik_id isEqualToString:localMzzik.muzzik_id]) {
            [self.trendMuzziks removeObject:tempMuzzik];
            [trendTableView reloadData];
            break;
        }
    }
    
    
}

-(void)moveMuzzik:(muzzik *)tempMuzzik{
    
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        tempMuzzik.ismoved = !tempMuzzik.ismoved;
        if (tempMuzzik.ismoved) {
            tempMuzzik.moveds = [NSString stringWithFormat:@"%d",[tempMuzzik.moveds intValue]+1 ];
        }else{
            tempMuzzik.moveds = [NSString stringWithFormat:@"%d",[tempMuzzik.moveds intValue]-1 ];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:tempMuzzik];
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/%@/moved",BaseURL,tempMuzzik.muzzik_id]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:tempMuzzik.ismoved] forKey:@"ismoved"] Method:PostMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            if ([weakrequest responseStatusCode] == 200) {
                // NSData *data = [weakrequest responseData];
              
                
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
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        [self.navigationController pushViewController:loginVC animated:YES];
        
    }
    
    
}
-(void)repostActionWithMuzzik:(muzzik *)tempMuzzik{
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        self.repostMuzzik = tempMuzzik;
        if (!tempMuzzik.isReposted) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确定转发这条Muzzik吗?" message:@"" delegate:self cancelButtonTitle:@"放弃" otherButtonTitles:nil];
            // optional - add more buttons:
            [alert addButtonWithTitle:@"确定"];
            [alert show];
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确定取消转发这条Muzzik吗?" message:@"" delegate:self cancelButtonTitle:@"放弃" otherButtonTitles:nil];
            // optional - add more buttons:
            [alert addButtonWithTitle:@"确定"];
            [alert show];
        }
    }else{
        [userInfo checkLoginWithVC:self];
    }
   
    
    
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        // do stuff
        if (!self.repostMuzzik.isReposted) {
            
            self.repostMuzzik.isReposted = YES;
            self.repostMuzzik.reposts = [NSString stringWithFormat:@"%d",[self.repostMuzzik.reposts intValue]+1];
            [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:self.repostMuzzik];
            ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik",BaseURL]]];
            NSDictionary *dictionary = [NSDictionary dictionaryWithObject:self.repostMuzzik.muzzik_id forKey:@"repost"];
            [requestForm addBodyDataSourceWithJsonByDic:dictionary Method:PutMethod auth:YES];
            __weak ASIHTTPRequest *weakrequest = requestForm;
            [requestForm setCompletionBlock :^{
                NSLog(@"%@",[weakrequest requestHeaders]);
                NSLog(@"%@",[weakrequest responseString]);
                NSLog(@"%d",[weakrequest responseStatusCode]);
                if ([weakrequest responseStatusCode] == 200) {
                    [MuzzikItem showNotifyOnView:self.view text:@"转发成功"];
                }
                
                else if([weakrequest responseStatusCode] == 401){
                    //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
                }else if ([weakrequest responseStatusCode] == 400){
                }
            }];
            [requestForm setFailedBlock:^{
                NSLog(@"%@",[weakrequest error]);
            }];
            [requestForm startAsynchronous];
        }else{
            
            
            self.repostMuzzik.isReposted = NO;
            self.repostMuzzik.reposts = [NSString stringWithFormat:@"%ld",[self.repostMuzzik.reposts integerValue]-1];
            [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:self.repostMuzzik];
            
            ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/%@/repost",BaseURL,self.repostMuzzik.muzzik_id]]];
            [requestForm addBodyDataSourceWithJsonByDic:nil Method:DeleteMethod auth:YES];
            __weak ASIHTTPRequest *weakrequest = requestForm;
            [requestForm setCompletionBlock :^{
                NSLog(@"%@",[weakrequest requestHeaders]);
                NSLog(@"%@",[weakrequest responseString]);
                NSLog(@"%d",[weakrequest responseStatusCode]);
                if ([weakrequest responseStatusCode] == 200) {
                    [MuzzikItem showNotifyOnView:self.view text:@"取消转发"];
                }
                
                else if([weakrequest responseStatusCode] == 401){
                    //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
                }else if ([weakrequest responseStatusCode] == 400){
                    
                }
            }];
            [requestForm setFailedBlock:^{
                NSLog(@"%@",[weakrequest error]);
            }];
            [requestForm startAsynchronous];
        }
        
        
    }else{
        
    }
    
}

-(void)feedReloadMuzzikSource{
    userInfo *user = [userInfo shareClass];
    if ([user.uid length]>0) {
        if ([MuzzikItem getDataFromLocalKey: [NSString stringWithFormat:@"User_Feed%@",user.uid]]) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[MuzzikItem getDataFromLocalKey: [NSString stringWithFormat:@"User_Feed%@",user.uid]] options:NSJSONReadingMutableContainers error:nil];
            
            if (dic) {
                muzzik *muzzikToy = [muzzik new];
                NSArray *array = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
                for (muzzik *tempmuzzik in array) {
                    BOOL isContained = NO;
                    for (muzzik *arrayMuzzik in self.feedMuzziks) {
                        if ([arrayMuzzik.muzzik_id isEqualToString:tempmuzzik.muzzik_id]) {
                            isContained = YES;
                            break;
                        }
                        
                    }
                    if (!isContained) {
                        [self.feedMuzziks addObject:tempmuzzik];
                    }
                    isContained = NO;
                }
                feedLastId = [dic objectForKey:@"tail"];
                [feedTableView reloadData];
                
            }
        }
    }
    
    NSDictionary *requestDic = [NSDictionary dictionaryWithObject:@"20" forKey:Parameter_Limit];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/feeds",BaseURL]]];
    
    [request addBodyDataSourceWithJsonByDic:requestDic Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        //    NSLog(@"%@",weakrequest.originalURL);
        [self.feedMuzziks removeAllObjects];
        NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            [MuzzikItem addObjectToLocal:data ForKey:[NSString stringWithFormat:@"User_Feed%@",user.uid]];
            
            muzzik *muzzikToy = [muzzik new];
            NSArray *array = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
            for (muzzik *tempmuzzik in array) {
                BOOL isContained = NO;
                for (muzzik *arrayMuzzik in self.feedMuzziks) {
                    if ([arrayMuzzik.muzzik_id isEqualToString:tempmuzzik.muzzik_id]) {
                        isContained = YES;
                        break;
                    }
                    
                }
                if (!isContained) {
                    [self.feedMuzziks addObject:tempmuzzik];
                }
                isContained = NO;
            }
            [MuzzikItem SetUserInfoWithMuzziks:self.feedMuzziks title:Constant_userInfo_follow description:[NSString stringWithFormat:@"关注列表"]];
            ASIHTTPRequest *requestCard = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/card",BaseURL]]];
            [requestCard addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
            __weak ASIHTTPRequest *weakrequestCard = requestCard;
            [requestCard setCompletionBlock :^{
                NSMutableArray *suggestCardArray = [[MuzzikItem getArrayFromLocalForKey:@"Muzzik_suggest_Day_ClickArray"] mutableCopy];
                if (!suggestCardArray) {
                    suggestCardArray = [NSMutableArray array];
                }
                NSData *data = [weakrequestCard responseData];
                NSDictionary *cardDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSArray *requestArray ;
                if (cardDic && [[cardDic allKeys] containsObject:@"muzziks"]) {
                    requestArray = [cardDic objectForKey:@"muzziks"];
                    for (NSDictionary *tempDic in requestArray) {
                        
                        if (![suggestCardArray containsObject:[tempDic objectForKey:@"_id"]]) {
                            for (muzzik *checkMuzzik in self.feedMuzziks) {
                                if ([[tempDic objectForKey:@"_id"] isEqualToString:checkMuzzik.muzzik_id]) {
                                    if (self.feedMuzziks.count >1) {
                                        
                                        [self.feedMuzziks removeObject:checkMuzzik];
                                    }
                                    break;
                                }
                                
                            }
                            [self.feedMuzziks insertObject:[[muzzik new] makeMuzziksByMuzzikArray:[NSMutableArray arrayWithObjects:tempDic, nil]][0] atIndex:1];
                            break;
                        }
                        
                        
                    }
                    [MuzzikItem SetUserInfoWithMuzziks:self.feedMuzziks title:Constant_userInfo_follow description:[NSString stringWithFormat:@"关注列表"]];
                    
                    feedLastId = [dic objectForKey:@"tail"];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [feedTableView reloadData];
                        [feedTableView headerEndRefreshing];
                    });
                    
                }
                
            }];
            [requestCard setFailedBlock:^{
                
                [feedTableView headerEndRefreshing];
            }];
            [requestCard startAsynchronous];
            
            
        }
    }];
    [request setFailedBlock:^{
        
        if (![[weakrequest responseString] length]>0) {
            [self networkErrorShow];
        }
    }];
    [request startAsynchronous];
}

-(void)trendReloadMuzzikSource{
    if ([MuzzikItem getDataFromLocalKey: Constant_Data_Square] ) {
        NSData *data = [MuzzikItem getDataFromLocalKey: Constant_Data_Square];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            
            muzzik *muzzikToy = [muzzik new];
            NSArray *array = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
            for (muzzik *tempmuzzik in array) {
                BOOL isContained = NO;
                for (muzzik *arrayMuzzik in self.trendMuzziks) {
                    if ([arrayMuzzik.muzzik_id isEqualToString:tempmuzzik.muzzik_id]) {
                        isContained = YES;
                        break;
                    }
                    
                }
                if (!isContained) {
                    [self.trendMuzziks addObject:tempmuzzik];
                }
                isContained = NO;
            }
        }
    }
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Muzzik_Trending]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:@"20" forKey:Parameter_Limit] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        //    NSLog(@"%@",weakrequest.originalURL);
        [self.trendMuzziks removeAllObjects];
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            
            muzzik *muzzikToy = [muzzik new];
            NSArray *array = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
            for (muzzik *tempmuzzik in array) {
                BOOL isContained = NO;
                for (muzzik *arrayMuzzik in self.trendMuzziks) {
                    if ([arrayMuzzik.muzzik_id isEqualToString:tempmuzzik.muzzik_id]) {
                        isContained = YES;
                        break;
                    }
                    
                }
                if (!isContained) {
                    [self.trendMuzziks addObject:tempmuzzik];
                }
                isContained = NO;
            }
            ASIHTTPRequest *requestCard = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/card",BaseURL]]];
            [requestCard addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
            __weak ASIHTTPRequest *weakrequestCard = requestCard;
            [requestCard setCompletionBlock :^{
                NSMutableArray *suggestCardArray = [[MuzzikItem getArrayFromLocalForKey:@"Muzzik_suggest_Day_ClickArray"] mutableCopy];
                if (!suggestCardArray) {
                    suggestCardArray = [NSMutableArray array];
                }
                NSData *data = [weakrequestCard responseData];
                NSDictionary *cardDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSArray *requestArray ;
                if (cardDic && [[cardDic allKeys] containsObject:@"muzziks"]) {
                    requestArray = [cardDic objectForKey:@"muzziks"];
                    for (NSDictionary *tempDic in requestArray) {
                        
                        if (![suggestCardArray containsObject:[tempDic objectForKey:@"_id"]]) {
                            for (muzzik *checkMuzzik in self.trendMuzziks) {
                                if ([[tempDic objectForKey:@"_id"] isEqualToString:checkMuzzik.muzzik_id]) {
                                    if (self.trendMuzziks.count >1) {
                                        
                                        [self.trendMuzziks removeObject:checkMuzzik];
                                    }
                                    break;
                                }
                                
                            }
                            [self.trendMuzziks insertObject:[[muzzik new] makeMuzziksByMuzzikArray:[NSMutableArray arrayWithObjects:tempDic, nil]][0] atIndex:1];
                            break;
                        }
                        
                        
                    }
                    [MuzzikItem SetUserInfoWithMuzziks:self.trendMuzziks title:Constant_userInfo_square description:nil];
                    
                    trendLastId = [dic objectForKey:@"tail"];;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [trendTableView reloadData];
                        [trendTableView headerEndRefreshing];
                    });
                    
                }
                
            }];
            [requestCard setFailedBlock:^{
                
                [trendTableView headerEndRefreshing];
            }];
            [requestCard startAsynchronous];
            
            
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
        if (![[weakrequest responseString] length]>0) {
            [self networkErrorShow];
        }
        
    }];
    [request startAsynchronous];
    
}
-(void)reloadDataSource{
    [super reloadDataSource];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        userInfo *user = [userInfo shareClass];
        if ([user.token length]>0) {
            if (mainScroll.contentOffset.x >200) {
                [self trendReloadMuzzikSource];
            }else{
                [self feedReloadMuzzikSource];
            }
        }else{
            [self trendReloadMuzzikSource];
        }
    });
    
    
}
-(void)playnextMuzzikUpdate{
    [feedTableView reloadData];
    [trendTableView reloadData];
}
-(void)playSongWithSongModel:(muzzik *)songModel{
    MuzzikRequestCenter *center = [MuzzikRequestCenter shareClass];
    
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        if (mainScroll.contentOffset.x>200) {
            center.subUrlString = @"api/muzzik/feeds";
            center.requestDic = [NSDictionary dictionaryWithObjectsAndKeys:trendLastId,Parameter_from,Limit_Constant,Parameter_Limit, nil];
            center.isPage = NO;
            center.singleMusic = NO;
            center.MuzzikType = Type_Muzzik_Muzzik;
            center.lastId = trendLastId;
            [musicPlayer shareClass].MusicArray = [self.trendMuzziks mutableCopy];
            [MuzzikItem SetUserInfoWithMuzziks:self.trendMuzziks title:Constant_userInfo_square description:[NSString stringWithFormat:@"广场列表"]];
            [_musicplayer playSongWithSongModel:songModel Title:@"广场列表"];
            _musicplayer.listType = SquareList;
        }else{
            center.subUrlString = @"api/muzzik/feeds";
            center.requestDic = [NSDictionary dictionaryWithObjectsAndKeys:feedLastId,Parameter_from,Limit_Constant,Parameter_Limit, nil];
            center.isPage = NO;
            center.singleMusic = NO;
            center.MuzzikType = Type_Muzzik_Muzzik;
            center.lastId = feedLastId;
            
            [musicPlayer shareClass].MusicArray = [self.feedMuzziks mutableCopy];
            [MuzzikItem SetUserInfoWithMuzziks:self.feedMuzziks title:Constant_userInfo_follow description:[NSString stringWithFormat:@"关注列表"]];
            [_musicplayer playSongWithSongModel:songModel Title:@"关注列表"];
            _musicplayer.listType = SquareList;
        }
    }else{
        center.subUrlString = @"api/muzzik/feeds";
        center.requestDic = [NSDictionary dictionaryWithObjectsAndKeys:trendLastId,Parameter_from,Limit_Constant,Parameter_Limit, nil];
        center.isPage = NO;
        center.singleMusic = NO;
        center.MuzzikType = Type_Muzzik_Muzzik;
        center.lastId = trendLastId;
        [musicPlayer shareClass].MusicArray = [self.trendMuzziks mutableCopy];
        [MuzzikItem SetUserInfoWithMuzziks:self.trendMuzziks title:Constant_userInfo_square description:[NSString stringWithFormat:@"广场列表"]];
        [_musicplayer playSongWithSongModel:songModel Title:@"广场列表"];
        _musicplayer.listType = SquareList;
    }
    //[self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    
}

-(void) commentAtMuzzik:(muzzik *)localMuzzik{
    muzzik *tempMuzzik = localMuzzik;
    DetaiMuzzikVC *detail = [[DetaiMuzzikVC alloc] init];
    detail.muzzik_id = tempMuzzik.muzzik_id;
    detail.showType = Constant_Comment;
     [self.navigationController pushViewController:detail animated:YES];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}
-(void) showRepost:(NSString *)muzzik_id{
    showUserVC *showvc = [[showUserVC alloc] init];
    showvc.muzzik_id = muzzik_id;
    showvc.showType = @"repost";
    [self.navigationController pushViewController:showvc animated:YES];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}
-(void) showShare:(NSString *)muzzik_id{
    showUserVC *showvc = [[showUserVC alloc] init];
    showvc.muzzik_id = muzzik_id;
    showvc.showType = @"share";
    [self.navigationController pushViewController:showvc animated:YES];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}
-(void)showComment:(muzzik *)localMuzzik{
    muzzik *tempMuzzik = localMuzzik;
    DetaiMuzzikVC *detail = [[DetaiMuzzikVC alloc] init];
    detail.muzzik_id = tempMuzzik.muzzik_id;
    detail.showType = Constant_showComment;
    [self.navigationController pushViewController:detail animated:YES];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}

-(void) showMoved:(NSString *)muzzik_id{
    showUserVC *showvc = [[showUserVC alloc] init];
    showvc.muzzik_id = muzzik_id;
    showvc.showType = @"moved";
    [self.navigationController pushViewController:showvc animated:YES];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}

-(void)userDetail:(NSString *)user_id{
    userInfo *user = [userInfo shareClass];
    if ([user_id isEqualToString:user.uid]) {
//        UserHomePage *home = [[UserHomePage alloc] init];
//        [self.navigationController pushViewController:home animated:YES];
//        [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
        
    }else{
        userDetailInfo *detailuser = [[userDetailInfo alloc] init];
        detailuser.uid = user_id;
        [self.navigationController pushViewController:detailuser animated:YES];
        [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    }
    
}

-(NSMutableArray *) searchUsers:(NSString *)message{
    NSString *checkTabel = @"<>,.~!@＠#$¥%％^&*()，。：；;:‘“～  》？《！＃＊……‘“”／/";
    NSMutableArray *array = [NSMutableArray array];
    BOOL GetAt = NO;
    //  || [[message substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"＠"]
    int location = 0;
    for (int i = 0; i<message.length; i++) {
        if ([[message substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"@"]|| [[message substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"＠"]) {
            GetAt = YES;
            location = i;
            continue;
        }else if ([checkTabel rangeOfString:[message substringWithRange:NSMakeRange(i, 1)]].location != NSNotFound && GetAt){
            GetAt = NO;
            [array addObject:[message substringWithRange:NSMakeRange(location, i-location)]];
            
        }else if(i == message.length-1 && GetAt){
            [array addObject:[message substringWithRange:NSMakeRange(location, i-location+1)]];
        }
    }
    
    
    return array;
}



-(void)shareActionWithMuzzik:(muzzik *)localMuzzik image:(UIImage *) image{
    shareMuzzik = localMuzzik;
    shareImage = image;
    [self addShareView];
}
-(void)SettingShareView{
    CGFloat screenWidth = SCREEN_WIDTH;
    
    CGFloat scaleX = 0.1;
    CGFloat scaleY = 0.08;
    userInfo *user = [userInfo shareClass];
    if (user.WeChatInstalled && user.QQInstalled) {
        maxScaleY = 0.7;
    }else{
        maxScaleY = 0.4;
    }
    shareViewFull = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, SCREEN_HEIGHT)];
    [shareViewFull setAlpha:0];
    [shareViewFull setBackgroundColor:[UIColor colorWithRed:0.125 green:0.121 blue:0.164 alpha:0.8]];
    [shareViewFull addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeShareView)]];
    shareView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, screenWidth, screenWidth*maxScaleY)];
    [shareView setBackgroundColor:[UIColor colorWithRed:0.125 green:0.121 blue:0.164 alpha:0.85]];
    if (user.WeChatInstalled) {
        UIButton *wechatButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth*0.1, screenWidth*0.08, screenWidth*0.18, screenWidth*0.18)];
        [wechatButton setImage:[UIImage imageNamed:Image_wechatImage] forState:UIControlStateNormal];
        [wechatButton setBackgroundImage:[UIImage imageNamed:Image_sharebgImage] forState:UIControlStateNormal];
        [wechatButton setBackgroundImage:[UIImage imageNamed:Image_shareclickbgImage] forState:UIControlStateHighlighted];
        [wechatButton setImage:[UIImage imageNamed:Image_wechatImage] forState:UIControlStateHighlighted];
        [wechatButton addTarget:self action:@selector(shareWeChat) forControlEvents:UIControlEventTouchUpInside];
        [shareView addSubview:wechatButton];
        UILabel *weiChatLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth*0.1, screenWidth*0.26, screenWidth*0.18, 20)];
        weiChatLabel.text = @"微 信";
        weiChatLabel.textAlignment = NSTextAlignmentCenter;
        [weiChatLabel setFont:[UIFont systemFontOfSize:12]];
        weiChatLabel.textColor =  Color_line_2;
        [shareView addSubview:weiChatLabel];
        UIButton *timeLineButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth*0.41, screenWidth*0.08, SCREEN_WIDTH*0.18, SCREEN_WIDTH*0.18)];
        [timeLineButton setImage:[UIImage imageNamed:Image_momentImage] forState:UIControlStateNormal];
        [timeLineButton setBackgroundImage:[UIImage imageNamed:Image_sharebgImage] forState:UIControlStateNormal];
        [timeLineButton setBackgroundImage:[UIImage imageNamed:Image_shareclickbgImage] forState:UIControlStateHighlighted];
        [timeLineButton setImage:[UIImage imageNamed:Image_momentImage] forState:UIControlStateHighlighted];
        [timeLineButton addTarget:self action:@selector(shareTimeLine) forControlEvents:UIControlEventTouchUpInside];
        [shareView addSubview:timeLineButton];
        
        UILabel *timeLineLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth*0.41, screenWidth*0.26, screenWidth*0.18, 20)];
        timeLineLabel.text = @"朋友圈";
        timeLineLabel.textAlignment = NSTextAlignmentCenter;
        [timeLineLabel setFont:[UIFont systemFontOfSize:12]];
        timeLineLabel.textColor =  Color_line_2;
        [shareView addSubview:timeLineLabel];
        scaleX = 0.72;
    }
    
    
    UIButton *weiboButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth*scaleX, screenWidth*0.08, SCREEN_WIDTH*0.18, SCREEN_WIDTH*0.18)];
    [weiboButton setImage:[UIImage imageNamed:Image_weiboImage] forState:UIControlStateNormal];
    [weiboButton setBackgroundImage:[UIImage imageNamed:Image_sharebgImage] forState:UIControlStateNormal];
    [weiboButton setBackgroundImage:[UIImage imageNamed:Image_shareclickbgImage] forState:UIControlStateHighlighted];
    [weiboButton setImage:[UIImage imageNamed:Image_weiboImage] forState:UIControlStateHighlighted];
    [weiboButton addTarget:self action:@selector(shareWeiBo) forControlEvents:UIControlEventTouchUpInside];
    [shareView addSubview:weiboButton];
    UILabel *weiBoLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth*scaleX, screenWidth*0.26, screenWidth*0.18, 20)];
    weiBoLabel.text = @"微 博";
    weiBoLabel.textAlignment = NSTextAlignmentCenter;
    [weiBoLabel setFont:[UIFont systemFontOfSize:12]];
    weiBoLabel.textColor = Color_line_2;
    [shareView addSubview:weiBoLabel];
    if (user.WeChatInstalled) {
        scaleY = 0.39;
        scaleX = 0.1;
    }else{
        scaleX = 0.41;
    }
    if (user.QQInstalled) {
        UIButton *QQButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth*scaleX, screenWidth*scaleY, screenWidth*0.18, screenWidth*0.18)];
        [QQButton setImage:[UIImage imageNamed:Image_qqImage] forState:UIControlStateNormal];
        [QQButton setBackgroundImage:[UIImage imageNamed:Image_sharebgImage] forState:UIControlStateNormal];
        [QQButton setBackgroundImage:[UIImage imageNamed:Image_shareclickbgImage] forState:UIControlStateHighlighted];
        [QQButton setImage:[UIImage imageNamed:Image_qqImage] forState:UIControlStateHighlighted];
        [QQButton addTarget:self action:@selector(shareQQ) forControlEvents:UIControlEventTouchUpInside];
        [shareView addSubview:QQButton];
        
        UILabel *QQLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth*scaleX, screenWidth*(scaleY+0.18), screenWidth*0.18, 20)];
        QQLabel.text = @"QQ";
        QQLabel.textAlignment = NSTextAlignmentCenter;
        [QQLabel setFont:[UIFont systemFontOfSize:12]];
        QQLabel.textColor = Color_line_2;
        [shareView addSubview:QQLabel];
        
        UIButton *qqZoneButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth*(scaleX+0.31), screenWidth*scaleY, screenWidth*0.18, screenWidth*0.18)];
        [qqZoneButton setImage:[UIImage imageNamed:Image_q_zoneImage] forState:UIControlStateNormal];
        [qqZoneButton setBackgroundImage:[UIImage imageNamed:Image_sharebgImage] forState:UIControlStateNormal];
        [qqZoneButton setBackgroundImage:[UIImage imageNamed:Image_shareclickbgImage] forState:UIControlStateHighlighted];
        [qqZoneButton setImage:[UIImage imageNamed:Image_q_zoneImage] forState:UIControlStateHighlighted];
        [qqZoneButton addTarget:self action:@selector(shareQQZone) forControlEvents:UIControlEventTouchUpInside];
        [shareView addSubview:qqZoneButton];
        
        UILabel *QQZoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth*(scaleX+0.31), screenWidth*(scaleY+0.18), screenWidth*0.18, 20)];
        QQZoneLabel.text = @"QQ空间";
        QQZoneLabel.textAlignment = NSTextAlignmentCenter;
        [QQZoneLabel setFont:[UIFont systemFontOfSize:12]];
        QQZoneLabel.textColor = Color_line_2;
        [shareView addSubview:QQZoneLabel];
        
    }
    
    [shareViewFull addSubview:shareView];
    
    
    
}
-(void)closeShareView{
    [UIView animateWithDuration:0.5 animations:^{
        [shareViewFull setAlpha:0];
        [shareView setFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_WIDTH*maxScaleY)];
    } completion:^(BOOL finished) {
        [shareViewFull removeFromSuperview];
        
    }];
}
-(void) addShareView{
    [self.navigationController.view addSubview:shareViewFull];
    [UIView animateWithDuration:0.3 animations:^{
        [shareViewFull setAlpha:1];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            [shareView setFrame:CGRectMake(0, SCREEN_HEIGHT-SCREEN_WIDTH*maxScaleY, SCREEN_WIDTH, SCREEN_WIDTH*maxScaleY)];
        } ];
    }];
}
- (WBMessageObject *)messageToShare
{
    WBMessageObject *message = [WBMessageObject message];
    
    message.text =[NSString stringWithFormat:@"一起来用Muzzik吧 %@%@",URL_Muzzik_SharePage,shareMuzzik.muzzik_id];
    
    WBImageObject *image = [WBImageObject object];
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        if (mainScroll.contentOffset.x>200) {
            image.imageData = UIImageJPEGRepresentation([MuzzikItem convertViewToImage:[trendTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.trendMuzziks indexOfObject:shareMuzzik] inSection:0]]], 1.0);
        }else{
            image.imageData = UIImageJPEGRepresentation([MuzzikItem convertViewToImage:[feedTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.feedMuzziks indexOfObject:shareMuzzik] inSection:0]]], 1.0);
        }
    }else{
        image.imageData = UIImageJPEGRepresentation([MuzzikItem convertViewToImage:[trendTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.trendMuzziks indexOfObject:shareMuzzik] inSection:0]]], 1.0);
    }
    
    message.imageObject = image;
    return message;
}
-(void)shareWeiBo{
    AppDelegate *myDelegate =(AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = URL_WeiBo_redirectURI;
    authRequest.scope = @"all";
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:[self messageToShare] authInfo:authRequest access_token:myDelegate.wbtoken];
    
    //    request.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
    [WeiboSDK sendRequest:request];
    NSDictionary *requestDic = [NSDictionary dictionaryWithObjectsAndKeys:shareMuzzik.muzzik_id,@"_id",@"weibo",@"channel", nil];
    
    ASIHTTPRequest *requestShare = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Share_Muzzik]]];
    
    [requestShare addBodyDataSourceWithJsonByDic:requestDic Method:PostMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = requestShare;
    [requestShare setCompletionBlock :^{
        
        shareMuzzik.shares = [NSString stringWithFormat:@"%d",[shareMuzzik.shares intValue]+1];
        [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:shareMuzzik];
    }];
    [requestShare setFailedBlock:^{
        NSLog(@"%@",[weakrequest error]);
    }];
    [requestShare startAsynchronous];
}
-(void) shareQQ{
    TencentOAuth *tencentOAuth = [[TencentOAuth alloc] initWithAppId:ID_QQ_APP
                                                         andDelegate:nil];
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_Muzzik_SharePage,shareMuzzik.muzzik_id];
    //分享图预览图URL地址
    NSString *previewImageUrl = @"http://muzzik-image.qiniudn.com/FieqckeQDGWACSpDA3P0aDzmGcB6";
    //音乐播放的网络流媒体地址
    QQApiAudioObject *audioObj =[QQApiAudioObject objectWithURL:[NSURL URLWithString:url]
                                                          title:shareMuzzik.music.name description:shareMuzzik.music.artist previewImageURL:[NSURL URLWithString:previewImageUrl]];
    //设置播放流媒体地址
    audioObj.flashURL=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_audio,shareMuzzik.music.key]];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:audioObj];
    //将内容分享到qq
    
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
    //将被容分享到qzone
    //QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
    
    NSDictionary *requestDic = [NSDictionary dictionaryWithObjectsAndKeys:shareMuzzik.muzzik_id,@"_id",@"qq",@"channel", nil];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Share_Muzzik]]];
    
    [request addBodyDataSourceWithJsonByDic:requestDic Method:PostMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{

        shareMuzzik.shares = [NSString stringWithFormat:@"%d",[shareMuzzik.shares intValue]+1];
        [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:shareMuzzik];
    }];
    [request setFailedBlock:^{
        NSLog(@"%@",[weakrequest error]);
    }];
    [request startAsynchronous];
    
    
}
- (void)handleSendResult:(QQApiSendResultCode)sendResult
{
    switch (sendResult)
    {
        case EQQAPIAPPNOTREGISTED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"App未注册" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送参数错误" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"未安装手Q" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"API接口不支持" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            
            break;
        }
        case EQQAPISENDFAILD:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        default:
        {
            break;
        }
    }
}
-(void) shareQQZone{
    TencentOAuth *tencentOAuth = [[TencentOAuth alloc] initWithAppId:ID_QQ_APP
                                                         andDelegate:nil];
    NSURL *previewURL = [NSURL URLWithString:@"http://muzzik-image.qiniudn.com/Fscv0d_e94ij-WgpvIoTiHmPJgu9"];
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_Muzzik_SharePage,shareMuzzik.muzzik_id];
    
    QQApiNewsObject* img = [QQApiNewsObject objectWithURL:[NSURL URLWithString:url] title:@"在Muzzik上分享了首歌" description:[NSString stringWithFormat:@"%@  %@",shareMuzzik.music.name,shareMuzzik.music.artist] previewImageURL:previewURL];
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
    
    
    //将被容分享到qzone
    QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
    [self handleSendResult:sent];
    
    NSDictionary *requestDic = [NSDictionary dictionaryWithObjectsAndKeys:shareMuzzik.muzzik_id,@"_id",@"qzone",@"channel", nil];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Share_Muzzik]]];
    
    [request addBodyDataSourceWithJsonByDic:requestDic Method:PostMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        
        shareMuzzik.shares = [NSString stringWithFormat:@"%d",[shareMuzzik.shares intValue]+1];
        [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:shareMuzzik];
    }];
    [request setFailedBlock:^{
        NSLog(@"%@",[weakrequest error]);
    }];
    [request startAsynchronous];
    
}
-(void) shareTimeLine{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [app sendMusicContentByMuzzik:shareMuzzik scen:1 image:shareImage];
    NSDictionary *requestDic = [NSDictionary dictionaryWithObjectsAndKeys:shareMuzzik.muzzik_id,@"_id",@"moment",@"channel", nil];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Share_Muzzik]]];
    
    [request addBodyDataSourceWithJsonByDic:requestDic Method:PostMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        
        shareMuzzik.shares = [NSString stringWithFormat:@"%d",[shareMuzzik.shares intValue]+1];
        [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:shareMuzzik];
    }];
    [request setFailedBlock:^{
        NSLog(@"%@",[weakrequest error]);
    }];
    [request startAsynchronous];
}

-(void) shareWeChat{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [app sendMusicContentByMuzzik:shareMuzzik scen:0 image:shareImage];
    NSDictionary *requestDic = [NSDictionary dictionaryWithObjectsAndKeys:shareMuzzik.muzzik_id,@"_id",@"wechat",@"channel", nil];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Share_Muzzik]]];
    
    [request addBodyDataSourceWithJsonByDic:requestDic Method:PostMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        
        shareMuzzik.shares = [NSString stringWithFormat:@"%d",[shareMuzzik.shares intValue]+1];
        [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:shareMuzzik];
    }];
    [request setFailedBlock:^{
        NSLog(@"%@",[weakrequest error]);
    }];
    [request startAsynchronous];
}
-(void)dataSourceMuzzikUpdate:(NSNotification *)notify{
    muzzik *tempMuzzik = (muzzik *)notify.object;
    if ([MuzzikItem checkMutableArray:self.trendMuzziks isContainMuzzik:tempMuzzik]) {
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:[self.trendMuzziks indexOfObject:tempMuzzik] inSection:0];
        [trendTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    if ([MuzzikItem checkMutableArray:self.feedMuzziks isContainMuzzik:tempMuzzik]) {
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:[self.feedMuzziks indexOfObject:tempMuzzik] inSection:0];
        [feedTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    
}
-(void)receiveNewSendMuzzik:(NSNotification *)notify{
    
    muzzik *tempMuzzik = (muzzik *)notify.object;
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/byMusic",BaseURL]]];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"1",Parameter_page,[tempMuzzik.music.artist stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"artist",[tempMuzzik.music.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"name", nil];
    [request addBodyDataSourceWithJsonByDic:dic Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        userArray = [[MuzzikUser new] makeMuzziksByUserArray:[dic objectForKey:@"users"]];
        if ([userArray count]>0) {
            for (UIView *subview in userView.subviews) {
                [subview removeFromSuperview];
            }
            int fromX = 16;
            UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 8, 250, 14)];
            if ([userArray count] == 1) {
                [tipsLabel setText:[NSString stringWithFormat:@"Ta也分享了这首歌： %@",tempMuzzik.music.name]];
            }else{
                [tipsLabel setText:[NSString stringWithFormat:@"他们也分享了这首歌： %@",tempMuzzik.music.name]];
            }
            
            [tipsLabel setTextColor:Color_Text_2];
            [tipsLabel setFont:[UIFont systemFontOfSize:11]];
            [userView addSubview:tipsLabel];
            UIButton *closeViewButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-31, 0, 31, 75)];
            [closeViewButton setImage:[UIImage imageNamed:@"recommandcloseImage"] forState:UIControlStateNormal];
            [closeViewButton addTarget:self action:@selector(closeUserView) forControlEvents:UIControlEventTouchUpInside];
            [userView addSubview:closeViewButton];
            BOOL GotMore = NO;
            if ((SCREEN_WIDTH-50)/50<userArray.count) {
                GotMore = YES;
                UIButton *moreButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-71, 27, 40, 40)];
                [moreButton setImage:[UIImage imageNamed:@"recommandmoreImage"] forState:UIControlStateNormal];
                [moreButton addTarget:self action:@selector(seeMoreUser) forControlEvents:UIControlEventTouchUpInside];
                [userView addSubview:moreButton];
            }
            
            for (MuzzikUser *user in userArray) {
                int temp = GotMore ? SCREEN_WIDTH-110 :SCREEN_WIDTH-71;
                if (fromX < temp) {
                    
                    UIButton_UserMuzzik *userbutton = [[UIButton_UserMuzzik alloc] initWithFrame:CGRectMake(fromX, 27, 40, 40)];
                    userbutton.user =user;
                    userbutton.layer.cornerRadius = 20;
                    userbutton.clipsToBounds = YES;
                    [userbutton addTarget:self action:@selector(seeVipUser:) forControlEvents:UIControlEventTouchUpInside];
                    [userbutton setAlpha:0];
                    
                    [userbutton sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,user.avatar,Image_Size_Small]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        [UIView animateWithDuration:0.5 animations:^{
                            [userbutton setAlpha:1];
                        }];
                        
                        
                    }];
                    fromX += 48;
                    [userView addSubview:userbutton];
                }else{
                    break;
                }
            }
            [self.view addSubview:userView];
            [UIView animateWithDuration:1 animations:^{
                [userView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 75)];
                [feedTableView setFrame:CGRectMake(0, 75, SCREEN_WIDTH, SCREEN_HEIGHT-139)];
                [trendTableView setFrame:CGRectMake(0, 75, SCREEN_WIDTH, SCREEN_HEIGHT-139)];
            }];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (!isUserTaped) {
                    [UIView animateWithDuration:0.5 animations:^{
                        [userView setFrame:CGRectMake(0, -75, SCREEN_WIDTH, 75)];
                        [feedTableView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
                        [trendTableView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
                    } completion:^(BOOL finished) {
                        [userView removeFromSuperview];
                    }];
                }else{
                    isUserTaped = NO;
                }
                
            });
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%@",[weakrequest error]);
    }];
    [request startAsynchronous];
    
    [self.feedMuzziks insertObject:tempMuzzik atIndex:0];
    [self.trendMuzziks insertObject:tempMuzzik atIndex:0];
    [feedTableView reloadData];
    [trendTableView reloadData];
}

-(void) seeVipUser:(UIButton_UserMuzzik *)button{
    isUserTaped = YES;
    userInfo *user = [userInfo shareClass];
    if ([button.user.user_id isEqualToString:user.uid]) {
//        UserHomePage *home = [[UserHomePage alloc] init];
//        [self.navigationController pushViewController:home animated:YES];
    }else{
        userDetailInfo *detailuser = [[userDetailInfo alloc] init];
        detailuser.uid = button.user.user_id;
        [self.navigationController pushViewController:detailuser animated:YES];
        [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    }
}
-(void)closeUserView{
    isUserTaped = NO;
    [UIView animateWithDuration:0.5 animations:^{
        [userView setFrame:CGRectMake(0, -75, SCREEN_WIDTH, 75)];
        [feedTableView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
        [trendTableView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    } completion:^(BOOL finished) {
        [userView removeFromSuperview];
    }];
}
-(void)seeMoreUser{
    isUserTaped = YES;
    showUserVC *showvc = [[showUserVC alloc] init];
    showvc.showType = @"songUser";
    showvc.userArray = userArray;
    [self.navigationController pushViewController:showvc animated:YES];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];

}
@end
