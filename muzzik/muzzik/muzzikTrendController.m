//
//  specialOfferListCollectionViewController.m
//  ShopUU
//
//  Created by 林清泽 on 15/1/8.
//  Copyright (c) 2015年 IOS. All rights reserved.
//

#import "UIImageView+WebCache.h"
#import "muzzikTrendController.h"
#import "ASIFormDataRequest.h"
#import "NormalCell.h"
#import "TopicHeaderView.h"
#import "appConfiguration.h"
#import <MediaPlayer/MediaPlayer.h>
#import "userInfo.h"
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
#import "songDetailVCViewController.h"
#import "TopicDetail.h"
#import "MuzzikSongCell.h"
#import "MuzzikTopic.h"
#import "MessageStepViewController.h"
@interface muzzikTrendController (){
    UIView *userView;
    NSMutableArray *userArray;
    BOOL isUserTaped;
    
    int numberOfProducts;
    BOOL needsLoad;
    NSMutableDictionary *RefreshDic;
    UITableView *MytableView;
    BOOL isPlaying;
    UIButton *newButton;
    NSString *lastId;
    UIImage *shareImage;
    
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
}
@property(nonatomic,retain) muzzik *repostMuzzik;
@end

@implementation muzzikTrendController

//static NSString * const reuseIdentifier = @"Cell";


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNagationBar:@"广场" leftBtn:Constant_backImage rightBtn:0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteMuzzik:) name:String_Muzzik_Delete object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playnextMuzzikUpdate) name:String_SetSongPlayNextNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataSourceMuzzikUpdate:) name:String_MuzzikDataSource_update object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNewSendMuzzik:) name:String_SendNewMuzzikDataSource_update object:nil];
    self.muzziks = [NSMutableArray array];
    
    
   // [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    _musicplayer = [musicPlayer shareClass];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    MytableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    [MytableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    MytableView.dataSource = self;
    MytableView.delegate = self;
    [self.view addSubview:MytableView];
    [MytableView registerClass:[NormalCell class] forCellReuseIdentifier:@"NormalCell"];
    [MytableView registerClass:[NormalNoCardCell class] forCellReuseIdentifier:@"NormalNoCardCell"];
    [MytableView registerClass:[MuzzikCard class] forCellReuseIdentifier:@"MuzzikCard"];
    [MytableView registerClass:[MuzzikNoCardCell class] forCellReuseIdentifier:@"MuzzikNoCardCell"];
    [MytableView registerClass:[MuzzikSongCell class] forCellReuseIdentifier:@"MuzzikSongCell"];
    [MytableView registerClass:[MuzzikTopic class] forCellReuseIdentifier:@"MuzzikTopic"];
    [self SettingShareView];
    [self followScrollView:MytableView];
    RefreshDic = [NSMutableDictionary dictionary];

    newButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-75, SCREEN_HEIGHT-139, 60, 60)];
    newButton.layer.cornerRadius = 28;
    newButton.clipsToBounds = YES;
    [newButton addTarget:self action:@selector(newOrLogin) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:newButton];
    
    [self reloadMuzzikSource];
    userView = [[UIView alloc] initWithFrame:CGRectMake(0, -75, SCREEN_WIDTH, 75)];
    [userView setBackgroundColor:Color_line_2];
    [userView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(seeMoreUser)]];
    
    
    [MytableView addHeaderWithTarget:self action:@selector(refreshHeader)];
    [MytableView addFooterWithTarget:self action:@selector(refreshFooter)];
    
}
- (void)refreshHeader
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
            [self.muzziks removeAllObjects];
            muzzik *muzzikToy = [muzzik new];
            NSArray *array = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
            for (muzzik *tempmuzzik in array) {
                BOOL isContained = NO;
                for (muzzik *arrayMuzzik in self.muzziks) {
                    if ([arrayMuzzik.muzzik_id isEqualToString:tempmuzzik.muzzik_id]) {
                        isContained = YES;
                        break;
                    }
                   
                }
                if (!isContained) {
                    [self.muzziks addObject:tempmuzzik];
                }
                isContained = NO;
            }
            
            AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
            
            [manager GET:[NSString stringWithFormat:@"%@api/muzzik/card",BaseURL] parameters:nil success:^(AFHTTPRequestOperation * operation, id responseObject) {
                NSMutableArray *suggestDic = [[MuzzikItem getArrayFromLocalForKey:@"Muzzik_suggest_Day_ClickArray"] mutableCopy];
                NSArray *requestArray = [responseObject objectForKey:@"muzziks"];
                
                for (NSDictionary *tempDic in requestArray) {
                    
                    if (![suggestDic containsObject:[tempDic objectForKey:@"_id"]]) {
                        for (muzzik *checkMuzzik in self.muzziks) {
                            if ([[tempDic objectForKey:@"_id"] isEqualToString:checkMuzzik.muzzik_id]) {
                                if (self.muzziks.count >1) {
                                    
                                    [self.muzziks removeObject:checkMuzzik];
                                }
                                break;
                            }
                            
                        }
                        [self.muzziks insertObject:[[muzzik new] makeMuzziksByMuzzikArray:[NSMutableArray arrayWithObjects:tempDic, nil]][0] atIndex:1];
                        break;
                    }
                    
                    
                }
                [MuzzikItem SetUserInfoWithMuzziks:self.muzziks title:Constant_userInfo_square description:nil];
                lastId = [dic objectForKey:@"tail"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [MytableView reloadData];
                    [MytableView headerEndRefreshing];
                });
                
            } failure:^(AFHTTPRequestOperation *operation, NSError * error) {
                NSLog(@"op: %@    error:%@",operation,error);
                [MytableView headerEndRefreshing];
                
            }];
            
            
            
            
        }
    }];
    [request setFailedBlock:^{
        [MytableView headerEndRefreshing];
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
    }];
    [request startAsynchronous];

}

- (void)refreshFooter
{
   // [self updateSomeThing];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Muzzik_Trending]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:lastId,Parameter_from,Limit_Constant,Parameter_Limit, nil] Method:GetMethod auth:YES];
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
                for (muzzik *arrayMuzzik in self.muzziks) {
                    if ([arrayMuzzik.muzzik_id isEqualToString:tempmuzzik.muzzik_id]) {
                        isContained = YES;
                        break;
                    }
                    
                }
                if (!isContained) {
                    [self.muzziks addObject:tempmuzzik];
                }
                isContained = NO;
            }
            [MuzzikItem SetUserInfoWithMuzziks:self.muzziks title:Constant_userInfo_square description:nil];
            lastId = [dic objectForKey:@"tail"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MytableView reloadData];
                [MytableView footerEndRefreshing];
                if ([[dic objectForKey:@"muzziks"] count]<[Limit_Constant integerValue] ) {
                    [MytableView removeFooter];
                }
            });
            
        }
    }];
    [request setFailedBlock:^{
        [MytableView footerEndRefreshing];
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
    }];
    [request startAsynchronous];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//        for(NSString *familyName in [UIFont familyNames]){
//            NSLog(@"Font FamilyName = %@",familyName); //*输出字体族科名字
//            for(NSString *fontame in [UIFont fontNamesForFamilyName:familyName]){
//                NSLog(@"\t%@",fontame);         //*输出字体族科下字样名字
//            }
//        }
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        [newButton setImage:[UIImage imageNamed:@"addsongImage"] forState:UIControlStateNormal];
    }
    else{
        [newButton setImage:[UIImage imageNamed:@"loginImage"] forState:UIControlStateNormal];
    }
    if (self.isRootSubview) {
        for (UIView *view in [self.parentRoot.titleShowView subviews]) {
            [view removeFromSuperview];
        }
        UIImageView *headImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:Image_MuzzikImage]];
        [headImage setFrame:CGRectMake((self.parentRoot.titleShowView.frame.size.width-headImage.frame.size.width)/2, 5, headImage.frame.size.width, headImage.frame.size.height)];
        [self.parentRoot.pagecontrol setCurrentPage:0];
        [self.parentRoot.titleShowView addSubview:headImage];
    }
   // MytableView add

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
   // [MytableView removeKeyPath];
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
    
    
    return self.muzziks.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    muzzik *tempMuzzik = [self.muzziks objectAtIndex:indexPath.row];
    
    
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
    else if([tempMuzzik.type isEqualToString:@"musicCard"] || [tempMuzzik.type isEqualToString:@"topicCard"]){
        return 105;
    }else{
        return 0;
    }
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.muzziks[indexPath.row] isKindOfClass:[muzzik class]]) {
        muzzik *tempMuzzik = self.muzziks[indexPath.row];
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
            detail.localmuzzik = tempMuzzik;
            [self.navigationController pushViewController:detail animated:YES];
        }else if([tempMuzzik.type isEqualToString:@"musicCard"]){
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
        }else if([tempMuzzik.type isEqualToString:@"topicCard"]){
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
        }else{
            DetaiMuzzikVC *detail = [[DetaiMuzzikVC alloc] init];
            detail.localmuzzik = tempMuzzik;
            [self.navigationController pushViewController:detail animated:YES];
        }
        
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Globle *glob = [Globle shareGloble];
    muzzik *tempMuzzik = [self.muzziks objectAtIndex:indexPath.row];
    if ([tempMuzzik.type isEqualToString:@"repost"] || [tempMuzzik.type isEqualToString:@"normal"] || [tempMuzzik.type isEqualToString:@"muzzikCard"]) {
        if (![tempMuzzik.image isKindOfClass:[NSNull class]] && [tempMuzzik.image length] == 0) {
            if ([tempMuzzik.type isEqualToString:@"repost"] ){
                NormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell" forIndexPath:indexPath];
                cell.songModel = [self.muzziks objectAtIndex:indexPath.row];
                if ([tempMuzzik.muzzik_id isEqualToString:self.musicplayer.localMuzzik.muzzik_id] &&!glob.isPause && glob.isPlaying) {
                    cell.isPlaying = YES;
                }else{
                    cell.isPlaying = NO;
                }
                [cell.privateImage setHidden:YES];
                [cell.userName setFrame:CGRectMake(80, 55, SCREEN_WIDTH-120, 20)];
                if (![[RefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                    [cell.userImage setAlpha:0];
                    [RefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                }
                [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?imageView2/1/w/100/h/100",BaseURL_image,tempMuzzik.MuzzikUser.avatar]] forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    [UIView animateWithDuration:0.5 animations:^{
                        [cell.userImage setAlpha:1];
                    }];
                    
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
                cell.songModel = [self.muzziks objectAtIndex:indexPath.row];
                if ([tempMuzzik.muzzik_id isEqualToString:self.musicplayer.localMuzzik.muzzik_id] &&!glob.isPause && glob.isPlaying) {
                    cell.isPlaying = YES;
                }else{
                    cell.isPlaying = NO;
                }
                if (![[RefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                    [cell.userImage setAlpha:0];
                    [RefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                }
                [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?imageView2/1/w/100/h/100",BaseURL_image,tempMuzzik.MuzzikUser.avatar]] forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    [UIView animateWithDuration:0.5 animations:^{
                        [cell.userImage setAlpha:1];
                    }];
                    
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
                cell.songModel = [self.muzziks objectAtIndex:indexPath.row];
                if ([tempMuzzik.muzzik_id isEqualToString:self.musicplayer.localMuzzik.muzzik_id] &&!glob.isPause && glob.isPlaying) {
                    cell.isPlaying = YES;
                }else{
                    cell.isPlaying = NO;
                }
                cell.delegate = self;
                if (![[RefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                    [cell.userImage setAlpha:0];
                    [RefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                }
                cell.cardTitle.text = tempMuzzik.title;
                cell.userName.text = tempMuzzik.MuzzikUser.name;
                cell.timeStamp.text = [MuzzikItem transtromTime:tempMuzzik.date];
                [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?imageView2/1/w/100/h/100",BaseURL_image,tempMuzzik.MuzzikUser.avatar]] forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    [UIView animateWithDuration:0.5 animations:^{
                        [cell.userImage setAlpha:1];
                    }];
                    
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
        }else{
            if ([tempMuzzik.type isEqualToString:@"repost"] ){
                NormalNoCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalNoCardCell" forIndexPath:indexPath];
                cell.songModel = [self.muzziks objectAtIndex:indexPath.row];
                if ([tempMuzzik.muzzik_id isEqualToString:self.musicplayer.localMuzzik.muzzik_id] &&!glob.isPause && glob.isPlaying) {
                    cell.isPlaying = YES;
                }else{
                    cell.isPlaying = NO;
                }
                [cell.privateImage setHidden:YES];
                [cell.userName setFrame:CGRectMake(80, 55, SCREEN_WIDTH-120, 20)];
                if (![[RefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                    [cell.userImage setAlpha:0];
                    [cell.poImage setAlpha:0];
                    [RefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                }
                [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?imageView2/1/w/100/h/100",BaseURL_image,tempMuzzik.MuzzikUser.avatar]] forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    [UIView animateWithDuration:0.5 animations:^{
                        [cell.userImage setAlpha:1];
                    }];
                    
                }];
                [cell.poImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?imageView2/1/w/600/h/600",BaseURL_image,tempMuzzik.image]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    [UIView animateWithDuration:0.5 animations:^{
                        [cell.poImage setAlpha:1];
                    }];
                    
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
                cell.songModel = [self.muzziks objectAtIndex:indexPath.row];
                if ([tempMuzzik.muzzik_id isEqualToString:self.musicplayer.localMuzzik.muzzik_id] &&!glob.isPause && glob.isPlaying) {
                    cell.isPlaying = YES;
                }else{
                    cell.isPlaying = NO;
                }
                if (![[RefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                    [cell.userImage setAlpha:0];
                    [cell.poImage setAlpha:0];
                    [RefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                }
                [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?imageView2/1/w/100/h/100",BaseURL_image,tempMuzzik.MuzzikUser.avatar]] forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    [UIView animateWithDuration:0.5 animations:^{
                        [cell.userImage setAlpha:1];
                    }];
                    
                }];
                
                //[cell.poImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,tempMuzzik.image]]];
                [cell.poImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?imageView2/1/w/600/h/600",BaseURL_image,tempMuzzik.image]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    [UIView animateWithDuration:0.5 animations:^{
                        [cell.poImage setAlpha:1];
                    }];
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
                cell.songModel = [self.muzziks objectAtIndex:indexPath.row];
                if ([tempMuzzik.muzzik_id isEqualToString:self.musicplayer.localMuzzik.muzzik_id] &&!glob.isPause && glob.isPlaying) {
                    cell.isPlaying = YES;
                }else{
                    cell.isPlaying = NO;
                }
                cell.delegate = self;
                if (![[RefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                    [cell.userImage setAlpha:0];
                    [cell.muzzikCardImage setAlpha:0];
                    [RefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                }
                cell.cardTitle.text = tempMuzzik.title;
                cell.userName.text = tempMuzzik.MuzzikUser.name;
                cell.timeStamp.text = [MuzzikItem transtromTime:tempMuzzik.date];
                [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?imageView2/1/w/100/h/100",BaseURL_image,tempMuzzik.MuzzikUser.avatar]] forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    [UIView animateWithDuration:0.5 animations:^{
                        [cell.userImage setAlpha:1];
                    }];
                    
                }];
                [cell.muzzikCardImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?imageView2/1/w/600/h/600",BaseURL_image,tempMuzzik.image]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    [UIView animateWithDuration:0.5 animations:^{
                        [cell.muzzikCardImage setAlpha:1];
                    }];
                    
                }];
                [cell colorViewWithColorString:[NSString stringWithFormat:@"%@",tempMuzzik.color]];
                cell.index = indexPath.row;
                cell.isMoved = tempMuzzik.ismoved;
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
        user.poController = self.parentRoot;
        MessageStepViewController *msgVC = [[MessageStepViewController alloc] init];
        msgVC.isNewSelected = YES;
        [self.navigationController pushViewController:msgVC animated:YES];
        
    }
    else{
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        [self.navigationController pushViewController:loginVC animated:YES];
    }
}
#pragma -mark Button_action
-(void) newOrLogin{
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        //new po
        user.poController = self;
        ChooseMusicVC *choosevc = [[ChooseMusicVC alloc] init];
        [self.navigationController pushViewController:choosevc animated:YES];

    }
    else{
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        [self.navigationController pushViewController:loginVC animated:YES];
    }
}
- (void)attributedLabel:(TTTAttributedLabel *)label
didSelectLinkWithTransitInformation:(NSDictionary *)components{
    NSLog(@"%@",components);
    if ([[components allKeys] containsObject:@"topic_id"]) {
        TopicDetail *topicDetail = [[TopicDetail alloc] init];
        topicDetail.topic_id = [components objectForKey:@"topic_id"];
        [self.navigationController pushViewController:topicDetail animated:YES];
    }else if([[components allKeys] containsObject:@"at_name"]){
        
        userInfo *user = [userInfo shareClass];
        if ([[components objectForKey:@"at_name"] isEqualToString:user.name]) {
            UserHomePage *home = [[UserHomePage alloc] init];
            [self.navigationController pushViewController:home animated:YES];
        }else{
            userDetailInfo *uInfo = [[userDetailInfo alloc] init];
            uInfo.uid = [[components objectForKey:@"at_name"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [self.navigationController pushViewController:uInfo animated:YES];
        }
    }
}
-(void)moveMuzzik:(muzzik *) tempMuzzik{
    
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/%@/moved",BaseURL,tempMuzzik.muzzik_id]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:!tempMuzzik.ismoved] forKey:@"ismoved"] Method:PostMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            if ([weakrequest responseStatusCode] == 200) {
                // NSData *data = [weakrequest responseData];
                tempMuzzik.ismoved = !tempMuzzik.ismoved;
                if (tempMuzzik.ismoved) {
                    tempMuzzik.moveds = [NSString stringWithFormat:@"%d",[tempMuzzik.moveds intValue]+1 ];
                }else{
                    tempMuzzik.moveds = [NSString stringWithFormat:@"%d",[tempMuzzik.moveds intValue]-1 ];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:tempMuzzik];
//                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:[self.muzziks indexOfObject:tempMuzzik] inSection:0];
//                [MytableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
                
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
-(void)repostActionWithMuzzik:(muzzik *)tempMuzzik{
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
    
    
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        // do stuff
        if (!self.repostMuzzik.isReposted) {
            
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
                    self.repostMuzzik.isReposted = YES;
                    self.repostMuzzik.reposts = [NSString stringWithFormat:@"%d",[self.repostMuzzik.reposts intValue]+1];
                    [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:self.repostMuzzik];
                }
                
                else if([weakrequest responseStatusCode] == 401){
                    [userInfo checkLoginWithVC:self];
                    //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
                }else if ([weakrequest responseStatusCode] == 400){
                }
            }];
            [requestForm setFailedBlock:^{
                NSLog(@"%@",[weakrequest error]);
            }];
            [requestForm startAsynchronous];
        }else{
            ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/%@/repost",BaseURL,self.repostMuzzik.muzzik_id]]];
            [requestForm addBodyDataSourceWithJsonByDic:nil Method:DeleteMethod auth:YES];
            __weak ASIHTTPRequest *weakrequest = requestForm;
            [requestForm setCompletionBlock :^{
                NSLog(@"%@",[weakrequest requestHeaders]);
                NSLog(@"%@",[weakrequest responseString]);
                NSLog(@"%d",[weakrequest responseStatusCode]);
                if ([weakrequest responseStatusCode] == 200) {
                    [MuzzikItem showNotifyOnView:self.view text:@"取消转发"];
                    self.repostMuzzik.isReposted = NO;
                    self.repostMuzzik.reposts = [NSString stringWithFormat:@"%d",[self.repostMuzzik.reposts intValue]-1];
                    [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:self.repostMuzzik];
                }
                
                else if([weakrequest responseStatusCode] == 401){
                    [userInfo checkLoginWithVC:self];
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

-(void)shareActionWithMuzzik:(muzzik *)localMuzzik image:(UIImage *) image{
    shareMuzzik = localMuzzik;
    shareImage = image;
    [self addShareView];
}
-(void)reloadMuzzikSource{
    if ([MuzzikItem getDataFromLocalKey: Constant_Data_Square] ) {
        NSData *data = [MuzzikItem getDataFromLocalKey: Constant_Data_Square];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            
            muzzik *muzzikToy = [muzzik new];
            NSArray *array = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
            for (muzzik *tempmuzzik in array) {
                BOOL isContained = NO;
                for (muzzik *arrayMuzzik in self.muzziks) {
                    if ([arrayMuzzik.muzzik_id isEqualToString:tempmuzzik.muzzik_id]) {
                        isContained = YES;
                        break;
                    }
                    
                }
                if (!isContained) {
                    [self.muzziks addObject:tempmuzzik];
                }
                isContained = NO;
            }
            AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
            
            [manager GET:[NSString stringWithFormat:@"%@api/muzzik/card",BaseURL] parameters:nil success:^(AFHTTPRequestOperation * operation, id responseObject) {
                NSMutableArray *suggestDic = [[MuzzikItem getArrayFromLocalForKey:@"Muzzik_suggest_Day_ClickArray"] mutableCopy];
                NSArray *requestArray = [responseObject objectForKey:@"muzziks"];
                
                for (NSDictionary *tempDic in requestArray) {
                    
                    if (![suggestDic containsObject:[tempDic objectForKey:@"_id"]]) {
                        for (muzzik *checkMuzzik in self.muzziks) {
                            if ([[tempDic objectForKey:@"_id"] isEqualToString:checkMuzzik.muzzik_id]) {
                                if (self.muzziks.count >1) {
                                    
                                    [self.muzziks removeObject:checkMuzzik];
                                }
                                break;
                            }
                            
                        }
                        [self.muzziks insertObject:[[muzzik new] makeMuzziksByMuzzikArray:[NSMutableArray arrayWithObjects:tempDic, nil]][0] atIndex:1];
                        break;
                    }
                    
                    
                }
                [MuzzikItem SetUserInfoWithMuzziks:self.muzziks title:Constant_userInfo_square description:nil];
                lastId = [dic objectForKey:@"tail"];
                [MytableView reloadData];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError * error) {
                NSLog(@"op: %@    error:%@",operation,error);
                [MytableView headerEndRefreshing];
                
            }];
            
        }
    }
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Muzzik_Trending]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:@"20" forKey:Parameter_Limit] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        //    NSLog(@"%@",weakrequest.originalURL);
        
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            
            muzzik *muzzikToy = [muzzik new];
            NSArray *array = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
            for (muzzik *tempmuzzik in array) {
                BOOL isContained = NO;
                for (muzzik *arrayMuzzik in self.muzziks) {
                    if ([arrayMuzzik.muzzik_id isEqualToString:tempmuzzik.muzzik_id]) {
                        isContained = YES;
                        break;
                    }
                    
                }
                if (!isContained) {
                    [self.muzziks addObject:tempmuzzik];
                }
                isContained = NO;
            }
            AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
            
            [manager GET:[NSString stringWithFormat:@"%@api/muzzik/card",BaseURL] parameters:nil success:^(AFHTTPRequestOperation * operation, id responseObject) {
                NSMutableArray *suggestDic = [[MuzzikItem getArrayFromLocalForKey:@"Muzzik_suggest_Day_ClickArray"] mutableCopy];
                NSArray *requestArray = [responseObject objectForKey:@"muzziks"];
                
                for (NSDictionary *tempDic in requestArray) {
                    
                    if (![suggestDic containsObject:[tempDic objectForKey:@"_id"]]) {
                        for (muzzik *checkMuzzik in self.muzziks) {
                            if ([[tempDic objectForKey:@"_id"] isEqualToString:checkMuzzik.muzzik_id]) {
                                if (self.muzziks.count >1) {
                                    
                                    [self.muzziks removeObject:checkMuzzik];
                                }
                                break;
                            }
                            
                        }
                        [self.muzziks insertObject:[[muzzik new] makeMuzziksByMuzzikArray:[NSMutableArray arrayWithObjects:tempDic, nil]][0] atIndex:1];
                        break;
                    }
                    
                    
                }
                [MuzzikItem SetUserInfoWithMuzziks:self.muzziks title:Constant_userInfo_square description:nil];
                lastId = [dic objectForKey:@"tail"];
                [MytableView reloadData];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError * error) {
                NSLog(@"op: %@    error:%@",operation,error);
                
            }];
            
           
            
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
        [self reloadMuzzikSource];
    });
    
    
}
-(void)playnextMuzzikUpdate{
    [MytableView reloadData];
}
-(void)playSongWithSongModel:(muzzik *)songModel{
    _musicplayer.listType = SquareList;
    _musicplayer.MusicArray = self.muzziks;
    [_musicplayer playSongWithSongModel:songModel Title:@"广场列表"];
}

-(void) commentAtMuzzik:(muzzik *)localMuzzik{
    muzzik *tempMuzzik = localMuzzik;
    DetaiMuzzikVC *detail = [[DetaiMuzzikVC alloc] init];
    detail.localmuzzik = tempMuzzik;
    detail.showType = Constant_Comment;
    [self.navigationController pushViewController:detail animated:YES];
}
-(void) showRepost:(NSString *)muzzik_id{
    showUserVC *showvc = [[showUserVC alloc] init];
    showvc.muzzik_id = muzzik_id;
    showvc.showType = @"repost";
    [self.navigationController pushViewController:showvc animated:YES];
}
-(void) showShare:(NSString *)muzzik_id{
    showUserVC *showvc = [[showUserVC alloc] init];
    showvc.muzzik_id = muzzik_id;
    showvc.showType = @"share";
    [self.navigationController pushViewController:showvc animated:YES];
}
-(void)showComment:(muzzik *)localMuzzik{
    muzzik *tempMuzzik = localMuzzik;
    DetaiMuzzikVC *detail = [[DetaiMuzzikVC alloc] init];
    detail.localmuzzik = tempMuzzik;
    detail.showType = Constant_showComment;
    [self.navigationController pushViewController:detail animated:YES];
}


-(void) showMoved:(NSString *)muzzik_id{
    showUserVC *showvc = [[showUserVC alloc] init];
    showvc.muzzik_id = muzzik_id;
    showvc.showType = @"moved";
    [self.navigationController pushViewController:showvc animated:YES];
}

-(void)userDetail:(NSString *)user_id{
    userInfo *user = [userInfo shareClass];
    if ([user_id isEqualToString:user.uid]) {
        UserHomePage *home = [[UserHomePage alloc] init];
        [self.navigationController pushViewController:home animated:YES];
    }else{
        userDetailInfo *detailuser = [[userDetailInfo alloc] init];
        detailuser.uid = user_id;
        [self.navigationController pushViewController:detailuser animated:YES];
    }

    
}
-(void)deleteMuzzik:(NSNotification *)notify{
    muzzik *localMzzik = notify.object;
    for (muzzik *tempMuzzik in self.muzziks) {
        if ([tempMuzzik.muzzik_id isEqualToString:localMzzik.muzzik_id]) {
            [self.muzziks removeObject:localMzzik];
            [MytableView reloadData];
            break;
        }
    }
    
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
    image.imageData = UIImageJPEGRepresentation([MuzzikItem convertViewToImage:[MytableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.muzziks indexOfObject:shareMuzzik] inSection:0]]], 1.0);
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
    if ([MuzzikItem checkMutableArray:self.muzziks isContainMuzzik:tempMuzzik]) {
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:[self.muzziks indexOfObject:tempMuzzik] inSection:0];
        [MytableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
    }
    
}
//-(void)receiveNewSendMuzzik:(NSNotification *)notify{
//    muzzik *tempMuzzik = (muzzik *)notify.object;
//
//    [self.muzziks insertObject:tempMuzzik atIndex:0];
//    [MytableView reloadData];
//}
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
                    [userbutton sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?imageView2/1/w/100/h/100",BaseURL_image,user.avatar]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:Image_user_placeHolder] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
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
                [MytableView setFrame:CGRectMake(0, 75, SCREEN_WIDTH, SCREEN_HEIGHT-139)];
            }];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (!isUserTaped) {
                    [UIView animateWithDuration:0.5 animations:^{
                        [userView setFrame:CGRectMake(0, -75, SCREEN_WIDTH, 75)];
                        [MytableView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
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
    
    [self.muzziks insertObject:tempMuzzik atIndex:0];
    [MytableView reloadData];
}

-(void) seeVipUser:(UIButton_UserMuzzik *)button{
    isUserTaped = YES;
    userInfo *user = [userInfo shareClass];
    if ([button.user.user_id isEqualToString:user.uid]) {
        UserHomePage *home = [[UserHomePage alloc] init];
        [self.navigationController pushViewController:home animated:YES];
    }else{
        userDetailInfo *detailuser = [[userDetailInfo alloc] init];
        detailuser.uid = button.user.user_id;
        [self.navigationController pushViewController:detailuser animated:YES];
    }
}
-(void)closeUserView{
    isUserTaped = NO;
    [UIView animateWithDuration:0.5 animations:^{
        [userView setFrame:CGRectMake(0, -75, SCREEN_WIDTH, 75)];
        [MytableView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
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
    
}
@end
