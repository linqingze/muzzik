//
//  specialOfferListCollectionViewController.m
//  ShopUU
//
//  Created by 林清泽 on 15/1/8.
//  Copyright (c) 2015年 IOS. All rights reserved.
//

#import "UIImageView+WebCache.h"
#import "muzzikTrendController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "NormalCell.h"
#import "TopicHeaderView.h"
#import "appConfiguration.h"
#import <MediaPlayer/MediaPlayer.h>
#import "userInfo.h"
#import "playListController.h"
#import "CXAHyperlinkLabel.h"
#import "ChooseMusicVC.h"
#import "LoginViewController.h"
#import "UIScrollView+DXRefresh.h"
#import "UIButton+WebCache.h"
#import "showUserVC.h"
#import "NormalNoCardCell.h"
#import "DetaiMuzzikVC.h"
#import "MuzzikCard.h"
#import "MuzzikNoCardCell.h"
#import "userDetailInfo.h"
#import "TopicDetail.h"
#define length_to_left 10
#define length_to_right 10
#define length_to_top 10
#define length_to_buttom 10
@interface muzzikTrendController (){
    int numberOfProducts;
    BOOL needsLoad;
    NSMutableDictionary *RefreshDic;
    UITableView *MytableView;
    BOOL isPlaying;
    UIButton *newButton;
    NSString *lastId;
    NSString *headId;
}

@end

@implementation muzzikTrendController

//static NSString * const reuseIdentifier = @"Cell";


- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playnextMuzzikUpdate) name:String_SetSongPlayNextNotification object:nil];
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
    
    
 
    newButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-70, SCREEN_HEIGHT-125, 55, 55)];
    newButton.layer.cornerRadius = 28;
    newButton.clipsToBounds = YES;
    

    
    [newButton addTarget:self action:@selector(newOrLogin) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:newButton];
    RefreshDic = [NSMutableDictionary dictionary];
    
}
- (void)refreshHeader
{
   // [self updateSomeThing];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Muzzik_Trending]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:Limit_Constant forKey:Parameter_Limit] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
       // NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            muzzik *muzzikToy = [muzzik new];
            self.muzziks = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
            muzzikToy = [self.muzziks lastObject];
            lastId = muzzikToy.muzzik_id;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MytableView reloadData];
                [MytableView headerEndRefreshing];
            });
            
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%@,%@",[weakrequest responseHeaders],[weakrequest responseString]);
        [KVNProgress showErrorWithStatus:@"网络请求超时"];
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
            [self.muzziks addObjectsFromArray:[muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]]];
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
        NSLog(@"%@,%@",[weakrequest responseHeaders],[weakrequest responseString]);
        [KVNProgress showErrorWithStatus:@"网络请求超时"];
    }];
    [request startAsynchronous];

}


-(void)viewDidLayoutSubviews{
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        [newButton setImage:[UIImage imageNamed:@"addsongImage"] forState:UIControlStateNormal];
    }
    else{
        [newButton setImage:[UIImage imageNamed:@"yellowlikedImage"] forState:UIControlStateNormal];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reloadMuzzikSource];
    [self.view setNeedsLayout];
    [MytableView addHeaderWithTarget:self action:@selector(refreshHeader)];
    [MytableView addFooterWithTarget:self action:@selector(refreshFooter)];
    
   // MytableView add

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MytableView removeFooter];
    [MytableView removeHeader];
   // [MytableView removeKeyPath];
    needsLoad = NO;
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
    CXAHyperlinkLabel *label = [[CXAHyperlinkLabel alloc] initWithFrame:CGRectMake(75, 0, SCREEN_WIDTH-110, 500)];
    muzzik *tempMuzzik = [self.muzziks objectAtIndex:indexPath.row];
    [label setText:tempMuzzik.message];
    CGSize msize = [label sizeThatFits:CGSizeMake(SCREEN_WIDTH-110, 2000)];
    if ([tempMuzzik.image length]>0) {
        if ([tempMuzzik.type isEqualToString:@"normal"] ||[tempMuzzik.type isEqualToString:@"repost"]) {
            return 245+msize.height+SCREEN_WIDTH*3/4;
        }else if([tempMuzzik.type isEqualToString:@"muzzikCard"]){
            return SCREEN_WIDTH*9/8+msize.height+36;
        }else if ([tempMuzzik.type isEqualToString:@"userCard"] ){
            return 60;
        }else {
            return 60;
        }
    }
    else{
        if ([tempMuzzik.type isEqualToString:@"normal"] ||[tempMuzzik.type isEqualToString:@"repost"]) {
            return 245+msize.height;
        }else if([tempMuzzik.type isEqualToString:@"muzzikCard"]){
            return 60;
        }else if ([tempMuzzik.type isEqualToString:@"userCard"] ){
            return 60;
        }else {
            return 60;
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.muzziks[indexPath.row] isKindOfClass:[muzzik class]]) {
        muzzik *tempMuzzik = self.muzziks[indexPath.row];
        DetaiMuzzikVC *detail = [[DetaiMuzzikVC alloc] init];
        detail.localmuzzik = tempMuzzik;
        [self.navigationController pushViewController:detail animated:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Globle *glob = [Globle shareGloble];
        muzzik *tempMuzzik = [self.muzziks objectAtIndex:indexPath.row];
    if ([tempMuzzik.image length] == 0) {
        if ([tempMuzzik.type isEqualToString:@"repost"] ){
            NormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell" forIndexPath:indexPath];
            cell.songModel = [self.muzziks objectAtIndex:indexPath.row];
            if ([tempMuzzik.music.key isEqualToString:self.musicplayer.localMuzzik.music.key] &&!glob.isPause) {
                cell.isPlaying = YES;
            }else{
                cell.isPlaying = NO;
            }
            if (![[RefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%d",indexPath.row]]) {
                [RefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%d",indexPath.row]];
                [cell.userImage setAlpha:0];
                [cell.poImage setAlpha:0];
            }
            [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,tempMuzzik.MuzzikUser.avatar]] forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [UIView animateWithDuration:0.5 animations:^{
                    [cell.userImage setAlpha:1];
                }];
                
            }];
            cell.userName.text = tempMuzzik.MuzzikUser.name;
            [cell.repostImage setHidden:NO];
            cell.repostUserName.text = tempMuzzik.reposter.name;
            NSString *temp = tempMuzzik.message;
            temp = [self transformMessage:temp withAt:[self searchUsers:temp] andColorString:tempMuzzik.color];
            
            [cell.muzzikMessage setText: [self transformMessage:temp withTopics:tempMuzzik.topics andColorString:[NSString stringWithFormat:@"%@",tempMuzzik.color]]];
            cell.isMoved = tempMuzzik.ismoved;
            cell.index = indexPath.row;
            cell.muzzikMessage.delegate = self;
            CGSize msize = [cell.muzzikMessage sizeThatFits:CGSizeMake(SCREEN_WIDTH-110, 2000)];
            [cell.muzzikMessage setFrame:CGRectMake(cell.muzzikMessage.frame.origin.x, cell.muzzikMessage.frame.origin.y, msize.width, msize.height)];
            [cell.musicPlayView setFrame:CGRectMake(0, 95+cell.muzzikMessage.bounds.size.height, SCREEN_WIDTH, cell.musicPlayView.frame.size.height)];
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
        }else if([tempMuzzik.type isEqualToString:@"normal"]){
            NormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell" forIndexPath:indexPath];
            cell.songModel = [self.muzziks objectAtIndex:indexPath.row];
            if ([tempMuzzik.music.key isEqualToString:self.musicplayer.localMuzzik.music.key] &&!glob.isPause) {
                cell.isPlaying = YES;
            }else{
                cell.isPlaying = NO;
            }
            if (![[RefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%d",indexPath.row]]) {
                [RefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%d",indexPath.row]];
                [cell.userImage setAlpha:0];
                [cell.poImage setAlpha:0];
            }
            [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,tempMuzzik.MuzzikUser.avatar]] forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [UIView animateWithDuration:0.5 animations:^{
                    [cell.userImage setAlpha:1];
                }];
                
            }];
           
            cell.userName.text = tempMuzzik.MuzzikUser.name;
            cell.repostUserName.text = @"";
            [cell.repostImage setHidden:YES];
            cell.repostUserName.text = tempMuzzik.reposter.name;
            NSString *temp = tempMuzzik.message;
            temp = [self transformMessage:temp withAt:[self searchUsers:temp] andColorString:tempMuzzik.color];
            
            [cell.muzzikMessage setText: [self transformMessage:temp withTopics:tempMuzzik.topics andColorString:[NSString stringWithFormat:@"%@",tempMuzzik.color]]];
            cell.isMoved = tempMuzzik.ismoved;
            cell.index = indexPath.row;
            cell.muzzikMessage.delegate = self;
            CGSize msize = [cell.muzzikMessage sizeThatFits:CGSizeMake(SCREEN_WIDTH-110, 2000)];
            [cell.muzzikMessage setFrame:CGRectMake(cell.muzzikMessage.frame.origin.x, cell.muzzikMessage.frame.origin.y, msize.width, msize.height)];
            [cell.musicPlayView setFrame:CGRectMake(0, 95+cell.muzzikMessage.bounds.size.height, SCREEN_WIDTH, cell.musicPlayView.frame.size.height)];
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
        }else if([tempMuzzik.type isEqualToString:@"muzzikCard"]){
            MuzzikCard *cell = [tableView dequeueReusableCellWithIdentifier:@"MuzzikCard" forIndexPath:indexPath];
            cell.songModel = [self.muzziks objectAtIndex:indexPath.row];
            if ([tempMuzzik.music.key isEqualToString:self.musicplayer.localMuzzik.music.key] &&!glob.isPause) {
                cell.isPlaying = YES;
            }else{
                cell.isPlaying = NO;
            }
            cell.cardTitle.text = tempMuzzik.title;
            cell.userName.text = tempMuzzik.MuzzikUser.name;
            cell.timeStamp.text = [MuzzikItem transtromTime:tempMuzzik.date];
            if (![[RefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%d",indexPath.row]]) {
                [RefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%d",indexPath.row]];
                [cell.userImage setAlpha:0];
            }
            [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,tempMuzzik.MuzzikUser.avatar]] forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [UIView animateWithDuration:0.5 animations:^{
                    [cell.userImage setAlpha:1];
                }];
                
            }];
            [cell.muzzikCardImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,tempMuzzik.image]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [UIView animateWithDuration:0.5 animations:^{
                    [cell.muzzikCardImage setAlpha:1];
                }];
                
            }];
            [cell colorViewWithColorString:[NSString stringWithFormat:@"%@",tempMuzzik.color]];
            cell.index = indexPath.row;
            cell.isMoved = tempMuzzik.ismoved;
            NSString *temp = tempMuzzik.message;
            temp = [self transformMessage:temp withAt:[self searchUsers:temp] andColorString:tempMuzzik.color];
            
            [cell.muzzikMessage setText: [self transformMessage:temp withTopics:tempMuzzik.topics andColorString:[NSString stringWithFormat:@"%@",tempMuzzik.color]]];
            cell.RepostID = tempMuzzik.repostID;
            CGSize msize = [cell.muzzikMessage sizeThatFits:CGSizeMake(SCREEN_WIDTH-110, 2000)];
            [cell.muzzikMessage setFrame:CGRectMake(cell.muzzikMessage.frame.origin.x, cell.muzzikMessage.frame.origin.y, msize.width, msize.height)];
            [cell.musicPlayView setFrame:CGRectMake(0, SCREEN_WIDTH*9/8+cell.muzzikMessage.bounds.size.height, SCREEN_WIDTH-16, cell.musicPlayView.frame.size.height)];
            cell.musicArtist.text =tempMuzzik.music.artist;
            cell.musicName.text = tempMuzzik.music.name;
            return cell;
            
        }else{
            return nil;
        }
    }else{
        if ([tempMuzzik.type isEqualToString:@"repost"] ){
            NormalNoCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalNoCardCell" forIndexPath:indexPath];
            cell.songModel = [self.muzziks objectAtIndex:indexPath.row];
            if ([tempMuzzik.music.key isEqualToString:self.musicplayer.localMuzzik.music.key] &&!glob.isPause) {
                cell.isPlaying = YES;
            }else{
                cell.isPlaying = NO;
            }
            if (![[RefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%d",indexPath.row]]) {
                [RefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%d",indexPath.row]];
                [cell.userImage setAlpha:0];
                [cell.poImage setAlpha:0];
            }
            [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,tempMuzzik.MuzzikUser.avatar]] forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [UIView animateWithDuration:0.5 animations:^{
                    [cell.userImage setAlpha:1];
                }];
                
            }];
            [cell.poImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,tempMuzzik.image]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [UIView animateWithDuration:0.5 animations:^{
                    [cell.poImage setAlpha:1];
                }];
                
            }];
            cell.userName.text = tempMuzzik.MuzzikUser.name;
            [cell.repostImage setHidden:NO];
            cell.repostUserName.text = tempMuzzik.reposter.name;
            NSString *temp = tempMuzzik.message;
            temp = [self transformMessage:temp withAt:[self searchUsers:temp] andColorString:tempMuzzik.color];
            
            [cell.muzzikMessage setText: [self transformMessage:temp withTopics:tempMuzzik.topics andColorString:[NSString stringWithFormat:@"%@",tempMuzzik.color]]];
            cell.isMoved = tempMuzzik.ismoved;
            cell.index = indexPath.row;
            cell.muzzikMessage.delegate = self;
            CGSize msize = [cell.muzzikMessage sizeThatFits:CGSizeMake(SCREEN_WIDTH-110, 2000)];
            [cell.muzzikMessage setFrame:CGRectMake(cell.muzzikMessage.frame.origin.x, cell.muzzikMessage.frame.origin.y, msize.width, msize.height)];
            [cell.musicPlayView setFrame:CGRectMake(0, 95+cell.muzzikMessage.bounds.size.height, SCREEN_WIDTH, cell.musicPlayView.frame.size.height)];
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
        }else if([tempMuzzik.type isEqualToString:@"normal"]){
            NormalNoCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalNoCardCell" forIndexPath:indexPath];
            cell.songModel = [self.muzziks objectAtIndex:indexPath.row];
            if ([tempMuzzik.music.key isEqualToString:self.musicplayer.localMuzzik.music.key] &&!glob.isPause) {
                cell.isPlaying = YES;
            }else{
                cell.isPlaying = NO;
            }
            if (![[RefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%d",indexPath.row]]) {
                [RefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%d",indexPath.row]];
                [cell.userImage setAlpha:0];
                [cell.poImage setAlpha:0];
            }
            [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,tempMuzzik.MuzzikUser.avatar]] forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [UIView animateWithDuration:0.5 animations:^{
                    [cell.userImage setAlpha:1];
                }];
                
            }];
            //[cell.poImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,tempMuzzik.image]]];
            [cell.poImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,tempMuzzik.image]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [UIView animateWithDuration:0.5 animations:^{
                    [cell.poImage setAlpha:1];
                }];
            }];
            cell.userName.text = tempMuzzik.MuzzikUser.name;
            cell.repostUserName.text = @"";
            [cell.repostImage setHidden:YES];
            cell.repostUserName.text = tempMuzzik.reposter.name;
            NSString *temp = tempMuzzik.message;
            temp = [self transformMessage:temp withAt:[self searchUsers:temp] andColorString:tempMuzzik.color];
            
            [cell.muzzikMessage setText: [self transformMessage:temp withTopics:tempMuzzik.topics andColorString:[NSString stringWithFormat:@"%@",tempMuzzik.color]]];
            cell.isMoved = tempMuzzik.ismoved;
            cell.index = indexPath.row;
            cell.muzzikMessage.delegate = self;
            CGSize msize = [cell.muzzikMessage sizeThatFits:CGSizeMake(SCREEN_WIDTH-110, 2000)];
            [cell.muzzikMessage setFrame:CGRectMake(cell.muzzikMessage.frame.origin.x, cell.muzzikMessage.frame.origin.y, msize.width, msize.height)];
            [cell.musicPlayView setFrame:CGRectMake(0, 95+cell.muzzikMessage.bounds.size.height, SCREEN_WIDTH, cell.musicPlayView.frame.size.height)];
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
        }else if([tempMuzzik.type isEqualToString:@"muzzikCard"]){
            MuzzikCard *cell = [tableView dequeueReusableCellWithIdentifier:@"MuzzikCard" forIndexPath:indexPath];
            cell.songModel = [self.muzziks objectAtIndex:indexPath.row];
            if ([tempMuzzik.music.key isEqualToString:self.musicplayer.localMuzzik.music.key] &&!glob.isPause) {
                cell.isPlaying = YES;
            }else{
                cell.isPlaying = NO;
            }
            cell.cardTitle.text = tempMuzzik.title;
            cell.userName.text = tempMuzzik.MuzzikUser.name;
            cell.timeStamp.text = [MuzzikItem transtromTime:tempMuzzik.date];
            if (![[RefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%d",indexPath.row]]) {
                [RefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%d",indexPath.row]];
                [cell.userImage setAlpha:0];
            }
            [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,tempMuzzik.MuzzikUser.avatar]] forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [UIView animateWithDuration:0.5 animations:^{
                    [cell.userImage setAlpha:1];
                }];
                
            }];
            [cell.muzzikCardImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,tempMuzzik.image]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [UIView animateWithDuration:0.5 animations:^{
                    [cell.muzzikCardImage setAlpha:1];
                }];
                
            }];
            [cell colorViewWithColorString:[NSString stringWithFormat:@"%@",tempMuzzik.color]];
            cell.index = indexPath.row;
            cell.isMoved = tempMuzzik.ismoved;
            NSString *temp = tempMuzzik.message;
            temp = [self transformMessage:temp withAt:[self searchUsers:temp] andColorString:tempMuzzik.color];
    
            [cell.muzzikMessage setText: [self transformMessage:temp withTopics:tempMuzzik.topics andColorString:[NSString stringWithFormat:@"%@",tempMuzzik.color]]];
            cell.RepostID = tempMuzzik.repostID;
            CGSize msize = [cell.muzzikMessage sizeThatFits:CGSizeMake(SCREEN_WIDTH-80, 2000)];
            [cell.muzzikMessage setFrame:CGRectMake(cell.muzzikMessage.frame.origin.x, cell.muzzikMessage.frame.origin.y, msize.width, msize.height)];
            [cell.musicPlayView setFrame:CGRectMake(0, SCREEN_WIDTH*9/8+cell.muzzikMessage.bounds.size.height-40, SCREEN_WIDTH-16, cell.musicPlayView.frame.size.height)];
            [cell.cardView setFrame:CGRectMake(8, 8, SCREEN_WIDTH-16, SCREEN_WIDTH*9/8+cell.muzzikMessage.bounds.size.height+20)];
            cell.musicArtist.text =tempMuzzik.music.artist;
            cell.musicName.text = tempMuzzik.music.name;
            return cell;
        }
        else {
            return nil;
        }
    }
    
    
}
-(NSString *)transformMessage:(NSString *)message withTopics:(NSArray *)topics andColorString:(NSString *)colorstring{
    message = [message stringByReplacingOccurrencesOfString:@"＃" withString:@"#"];
    message = [message stringByReplacingOccurrencesOfString:@"&" withString:@"&"];
    NSArray *array = [message componentsSeparatedByString:@"#"];
    for (NSDictionary *dic in topics) {
        for (NSString *messageString in array) {
            if ([[messageString lowercaseString] isEqualToString:[dic objectForKey:@"name"]]) {
                NSRange rang = [message rangeOfString:[NSString stringWithFormat:@"#%@#",messageString]];
                message = [message stringByReplacingOccurrencesOfString:[message substringWithRange:rang] withString:[NSString stringWithFormat:@" <a href='#%@'>%@</a>",[dic objectForKey:@"_id"],[message substringWithRange:rang]]];
                break;
            }
        }
    }
    
    
    return message;
}
-(NSString *)transformMessage:(NSString *)message withAt:(NSArray *)topics andColorString:(NSString *)colorstring{
  //  NSMutableString *temp = [NSMutableString stringWithString:message];
    if ([topics count]>0) {
        for (NSString *string in topics) {
            NSLog(@"%d",[message containsString:string]);
            message = [message stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",string] withString:[NSString stringWithFormat:@" <a href='%@'>%@</a>",string,string]];
        }
    }
    return message;
}


#pragma -mark Button_action
-(void) newOrLogin{
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        //new po
        ChooseMusicVC *choosevc = [[ChooseMusicVC alloc] init];
        [self.navigationController pushViewController:choosevc animated:YES];

    }
    else{
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        [self.navigationController pushViewController:loginVC animated:YES];
    }
}
-(void)rightBtnAction:(UIButton *)sender{
     
}
-(void)playListAction{
    
//    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatSession];
//    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
//        if (response.responseCode == UMSResponseCodeSuccess) {
//            
//            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary]valueForKey:UMShareToWechatSession];
//            
//            NSLog(@"username is %@, uid is %@, token is %@ url is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
//            
//        }
//        
//    });

}
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    if (velocity.y>0) {
        [self.homeNav hideMusicView];
    }
    else if (velocity.y<0 && [[musicPlayer shareClass].MusicArray count]>0){
        [self.homeNav showMusicView];
    }
}

-(void)pressWithUrl:(NSURL *)url AndRange:(NSRange)rang{
    
    NSString *urlId = [url.lastPathComponent substringFromIndex:1];
    NSLog(@"%@",url.lastPathComponent);
    if ([[url.lastPathComponent substringToIndex:1] isEqualToString:@"#"]) {
        TopicDetail *topicDetail = [[TopicDetail alloc] init];
        topicDetail.topic_id = urlId;
        [self.navigationController pushViewController:topicDetail animated:YES];

    }else {
        userDetailInfo *uInfo = [[userDetailInfo alloc] init];
        uInfo.uid = [urlId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [self.navigationController pushViewController:uInfo animated:YES];
        NSLog(@"好友");
    }
   // [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@",url]];
}
-(void)moveMuzzikWithId:(NSString *)muzzik_id isMoved:(BOOL) ismoved atIndex:(NSInteger) index{
    muzzik *tempMuzzik = self.muzziks[index];
    
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/%@/moved",BaseURL,muzzik_id]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:!tempMuzzik.ismoved] forKey:@"ismoved"] Method:PostMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            if ([weakrequest responseStatusCode] == 200) {
                // NSData *data = [weakrequest responseData];
                tempMuzzik.ismoved = !tempMuzzik.ismoved;
                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:index inSection:0];
                [MytableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
                
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
-(void)repostActionWithMuzzik_id:(NSString *)muzzik_id atIndex:(NSInteger) index{
    ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik",BaseURL]]];
    [requestForm setRequestMethod:@"PUT"];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:muzzik_id forKey:@"repost"];
    [requestForm addBodyDataSourceWithJsonByDic:dictionary Method:PutMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = requestForm;
    [requestForm setCompletionBlock :^{
        NSLog(@"%@",[weakrequest requestHeaders]);
        NSLog(@"%@",[weakrequest responseString]);
        NSLog(@"%d",[weakrequest responseStatusCode]);
        if ([weakrequest responseStatusCode] == 200) {
             muzzik *localMuzzik = self.muzziks[index];
            [KVNProgress showSuccessWithStatus:@"转发成功"];
            localMuzzik.reposts = [NSString stringWithFormat:@"%ld",[localMuzzik.reposts integerValue]+1];
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:index inSection:0];
            [MytableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        }
        
        else if([weakrequest responseStatusCode] == 401){
            [userInfo checkLoginWithVC:self];
            //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
        }else if ([weakrequest responseStatusCode] == 400){
            [KVNProgress showSuccessWithStatus:@"此Muzzik您已转发过"];
        }
    }];
    [requestForm setFailedBlock:^{
        NSLog(@"%@",[weakrequest responseString]);
        [KVNProgress showErrorWithStatus:@"网络请求超时"];
    }];
    [requestForm startAsynchronous];
}
-(void)shareActionWithMuzzik_id:(NSString *)muzzik_id atIndex:(NSInteger)index{
    
}
-(void)reloadMuzzikSource{
    NSDictionary *requestDic;
    if ([headId length]>0) {

        requestDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",self.muzziks.count],Parameter_Limit,headId,Parameter_tail, nil];
    }else{
        requestDic = [NSDictionary dictionaryWithObject:@"20" forKey:Parameter_Limit];
        
    }
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Muzzik_Trending]]];
    [request addBodyDataSourceWithJsonByDic:requestDic Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
    //    NSLog(@"%@",weakrequest.originalURL);
        NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            
            muzzik *muzzikToy = [muzzik new];
            self.muzziks = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
            lastId = [dic objectForKey:@"tail"];
            headId = [dic objectForKey:@"head"];
            [MytableView reloadData];
            
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%@,%@",[weakrequest responseHeaders],[weakrequest responseString]);
         [KVNProgress showErrorWithStatus:@"网络请求超时"];
    }];
    [request startAsynchronous];
}

-(void)playnextMuzzikUpdate{
    [MytableView reloadData];
}
-(void)playSongWithSongModel:(muzzik *)songModel{
    _musicplayer.listType = SquareList;
    _musicplayer.MusicArray = self.muzziks;
    [_musicplayer playSongWithSongModel:songModel];
    
    
    
    [self.homeNav checkShowMusicView];
}

-(void) commentAtMuzzik:(NSString *)muzzik_id{
    NSLog(@"comment in%@",muzzik_id);
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
-(void) showComment:(NSString *)muzzik_id{
    NSLog(@"commenn%@",muzzik_id);
}

-(void) showMoved:(NSString *)muzzik_id{
    showUserVC *showvc = [[showUserVC alloc] init];
    showvc.muzzik_id = muzzik_id;
    showvc.showType = @"moved";
    [self.navigationController pushViewController:showvc animated:YES];
}

-(void)userDetail:(NSString *)user_id{
    userDetailInfo *detailuser = [[userDetailInfo alloc] init];
    detailuser.uid = user_id;
    [self.navigationController pushViewController:detailuser animated:YES];

    
}

-(NSMutableArray *) searchUsers:(NSString *)message{
   
    NSMutableArray *array = [NSMutableArray array];
    BOOL GetAt = NO;
   //  || [[message substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"＠"]
    int location = 0;
    for (int i = 0; i<message.length; i++) {
        if ([[message substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"@"]|| [[message substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"＠"]) {
            GetAt = YES;
            location = i;
            continue;
        }else if (([[message substringWithRange:NSMakeRange(i, 1)] isEqualToString:@" "] || [[message substringWithRange:NSMakeRange(i, 1)] isEqualToString:@" "]) && GetAt){
            GetAt = NO;
            [array addObject:[message substringWithRange:NSMakeRange(location, i-location)]];
            
        }else if(i == message.length-1 && GetAt){
            [array addObject:[message substringWithRange:NSMakeRange(location, i-location+1)]];
        }
    }
    
    
    return array;
}


@end
