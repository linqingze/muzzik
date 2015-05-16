//
//  TopicDetail.m
//  muzzik
//
//  Created by muzzik on 15/5/10.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//
#import "UIImageView+WebCache.h"
#import "muzzikTrendController.h"
#import "ASIFormDataRequest.h"
#import "NormalCell.h"
#import "TopicHeaderView.h"
#import "appConfiguration.h"
#import "userInfo.h"
#import "playListController.h"
#import "CXAHyperlinkLabel.h"
#import "ChooseMusicVC.h"
#import "showUserVC.h"
#import "NormalNoCardCell.h"
#import "DetaiMuzzikVC.h"
#import "userDetailInfo.h"
#import "TopicDetail.h"
#import "UIScrollView+DXRefresh.h"
#import "UIButton+WebCache.h"
#import "LoginViewController.h"

@interface TopicDetail ()<UITableViewDataSource,UITableViewDelegate,CXDelegate,CellDelegate>{
    UITableView *MytableView;
    NSMutableArray *TopicArray;
    NSInteger page;
    UIView *initiatorView;
    UIButton *headButton;
    UILabel *titleLabel;
    NSString *topicUserId;
    NSString *topicName;
     NSMutableDictionary *RefreshDic;
    NSString *lastId;
    NSString *headId;
}
@end

@implementation TopicDetail


-(void)viewDidLoad{
    [super viewDidLoad];
    [self initNagationBar:@"选择话题" leftBtn:Constant_backImage rightBtn:0];
    initiatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    headButton = [[UIButton alloc] initWithFrame:CGRectMake(16, 5, 30, 30)];
    headButton.layer.cornerRadius = 15;
    headButton.clipsToBounds = YES;
    [initiatorView addSubview:headButton];
    [initiatorView setBackgroundColor:[UIColor whiteColor]];
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 10, SCREEN_WIDTH-90, 20)];
    [MuzzikItem addLineOnView:initiatorView heightPoint:40 toLeft:16 toRight:16 withColor:Color_line_1];
    [initiatorView addSubview:titleLabel];
    [self.view addSubview:initiatorView];
    
    
    MytableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 41, SCREEN_WIDTH, SCREEN_HEIGHT-104)];
    [MytableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    MytableView.dataSource = self;
    MytableView.delegate = self;
    [self.view addSubview:MytableView];
    [MytableView registerClass:[NormalCell class] forCellReuseIdentifier:@"NormalCell"];
    [MytableView registerClass:[NormalNoCardCell class] forCellReuseIdentifier:@"NormalNoCardCell"];
    
    [self followScrollView:MytableView];
    RefreshDic = [NSMutableDictionary dictionary];
    [self followScrollView:MytableView];
    [self loadTopicTittle];

}
- (void)refreshHeader
{
    // [self updateSomeThing];
   ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/topic/%@",BaseURL,self.topic_id]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:Limit_Constant forKey:Parameter_Limit] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        // NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            muzzik *muzzikToy = [muzzik new];
            TopicArray = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
            lastId = [dic objectForKey:@"tail"];
             headId = [dic objectForKey:@"from"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MytableView reloadData];
                [MytableView headerEndRefreshing];
            });
            
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
    }];
    [request startAsynchronous];
    
}

- (void)refreshFooter
{
    // [self updateSomeThing];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/topic/%@",BaseURL,self.topic_id]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:lastId,Parameter_from,Limit_Constant,Parameter_Limit, nil] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        // NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            muzzik *muzzikToy = [muzzik new];
            [TopicArray addObjectsFromArray:[muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]]];
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
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
    }];
    [request startAsynchronous];
    
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
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) loadTopicTittle{
    ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/topic/%@",BaseURL,self.topic_id]]];
    NSDictionary  *paraDic;
    paraDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",page],Parameter_page, Limit_Constant,Parameter_Limit,nil];
    [requestForm addBodyDataSourceWithJsonByDic:paraDic Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = requestForm;
    [requestForm setCompletionBlock :^{
        NSLog(@"%@",[weakrequest responseString]);
        NSLog(@"%d",[weakrequest responseStatusCode]);
        if ([weakrequest responseStatusCode] == 200) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
            topicName = [dic objectForKey:@"name"];
            ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@",BaseURL,[dic objectForKey:@"initiator"]]]];
            [request addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
            __weak ASIHTTPRequest *weakre = request;
            [request setCompletionBlock :^{
                NSLog(@"%@",[weakre responseString]);
                NSLog(@"%d",[weakre responseStatusCode]);
                if ([weakre responseStatusCode] == 200) {
                    [headButton setAlpha:0];
                    NSDictionary *userDic = [NSJSONSerialization JSONObjectWithData:[weakre responseData] options:NSJSONReadingMutableContainers error:nil];
                    [headButton sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?imageView2/1/w/100/h/100",BaseURL_image,[userDic objectForKey:@"avatar"]]] forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        [headButton setAlpha:1];
                    }];
                    UIFont *font = [UIFont systemFontOfSize:14];
                    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
                    NSString *itemStr = [NSString stringWithFormat:@"%@ 发起的话题",[userDic objectForKey:@"name"]];
                    NSAttributedString *item = [MuzzikItem formatAttrItem:itemStr color:Color_Text_2 font:font];
                    [text appendAttributedString:item];
                    NSString *itemStr1 = [NSString stringWithFormat:@"#%@#",topicName];
                    NSAttributedString *item1 = [MuzzikItem formatAttrItem:itemStr1 color:Color_Additional_4 font:font];
                    [text appendAttributedString:item1];
                    titleLabel.attributedText = text;
                    titleLabel.adjustsFontSizeToFitWidth = YES;
                    
        }
        else{
            //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
        }
            }];
            [request setFailedBlock:^{
                NSLog(@"%@",[weakre error]);
                NSLog(@"hhhh%@  kkk%@",[weakre responseString],[weakre responseHeaders]);
                [userInfo checkLoginWithVC:self];
            }];
            [request startAsynchronous];
        }
    }];
    [requestForm setFailedBlock:^{
        NSLog(@"%@",[weakrequest error]);
        NSLog(@"hhhh%@  kkk%@",[weakrequest responseString],[weakrequest responseHeaders]);
        [userInfo checkLoginWithVC:self];
    }];
    [requestForm startAsynchronous];
}
#pragma mark <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    
    return TopicArray.count;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CXAHyperlinkLabel *label = [[CXAHyperlinkLabel alloc] initWithFrame:CGRectMake(75, 0, SCREEN_WIDTH-110, 500)];
    muzzik *tempMuzzik = [TopicArray objectAtIndex:indexPath.row];
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
    
    if ([TopicArray[indexPath.row] isKindOfClass:[muzzik class]]) {
        muzzik *tempMuzzik = TopicArray[indexPath.row];
        DetaiMuzzikVC *detail = [[DetaiMuzzikVC alloc] init];
        detail.localmuzzik = tempMuzzik;
        [self.navigationController pushViewController:detail animated:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Globle *glob = [Globle shareGloble];
    muzzik *tempMuzzik = [TopicArray objectAtIndex:indexPath.row];
    if ([tempMuzzik.image length] == 0) {
        if ([tempMuzzik.type isEqualToString:@"repost"] ){
            NormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell" forIndexPath:indexPath];
            cell.songModel = [TopicArray objectAtIndex:indexPath.row];
            if ([tempMuzzik.muzzik_id isEqualToString:[musicPlayer shareClass].localMuzzik.muzzik_id] &&!glob.isPause) {
                cell.isPlaying = YES;
            }else{
                cell.isPlaying = NO;
            }
            if (![[RefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%d",indexPath.row]]) {
                [RefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%d",indexPath.row]];
                [cell.userImage setAlpha:0];
                [cell.poImage setAlpha:0];
            }
            [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?imageView2/1/w/100/h/100",BaseURL_image,tempMuzzik.MuzzikUser.avatar]] forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
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
        }else if([tempMuzzik.type isEqualToString:@"normal"]){
            NormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell" forIndexPath:indexPath];
            cell.songModel = [TopicArray objectAtIndex:indexPath.row];
            if ([tempMuzzik.muzzik_id isEqualToString:[musicPlayer shareClass].localMuzzik.muzzik_id] &&!glob.isPause) {
                cell.isPlaying = YES;
            }else{
                cell.isPlaying = NO;
            }
            if (![[RefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%d",indexPath.row]]) {
                [RefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%d",indexPath.row]];
                [cell.userImage setAlpha:0];
                [cell.poImage setAlpha:0];
            }
            [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?imageView2/1/w/100/h/100",BaseURL_image,tempMuzzik.MuzzikUser.avatar]] forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
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
        }else{
            return nil;
        }
    }else{
        if ([tempMuzzik.type isEqualToString:@"repost"] ){
            NormalNoCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalNoCardCell" forIndexPath:indexPath];
            cell.songModel = [TopicArray objectAtIndex:indexPath.row];
            if ([tempMuzzik.muzzik_id isEqualToString:[musicPlayer shareClass].localMuzzik.muzzik_id] &&!glob.isPause) {
                cell.isPlaying = YES;
            }else{
                cell.isPlaying = NO;
            }
            if (![[RefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%d",indexPath.row]]) {
                [RefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%d",indexPath.row]];
                [cell.userImage setAlpha:0];
                [cell.poImage setAlpha:0];
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
        }else if([tempMuzzik.type isEqualToString:@"normal"]){
            NormalNoCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalNoCardCell" forIndexPath:indexPath];
            cell.songModel = [TopicArray objectAtIndex:indexPath.row];
            if ([tempMuzzik.muzzik_id isEqualToString:[musicPlayer shareClass].localMuzzik.muzzik_id] &&!glob.isPause) {
                cell.isPlaying = YES;
            }else{
                cell.isPlaying = NO;
            }
            if (![[RefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%d",indexPath.row]]) {
                [RefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%d",indexPath.row]];
                [cell.userImage setAlpha:0];
                [cell.poImage setAlpha:0];
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
    muzzik *tempMuzzik = TopicArray[index];
    
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
            muzzik *localMuzzik = TopicArray[index];
            [MuzzikItem showNotifyOnView:self.view text:@"转发成功"];
            localMuzzik.reposts = [NSString stringWithFormat:@"%ld",[localMuzzik.reposts integerValue]+1];
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:index inSection:0];
            [MytableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
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
-(void)shareActionWithMuzzik_id:(NSString *)muzzik_id atIndex:(NSInteger)index{
    
}
-(void)reloadMuzzikSource{
    NSDictionary *requestDic;
    if ([lastId length]>0) {
        
        requestDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",TopicArray.count],Parameter_Limit,lastId,Parameter_tail, nil];
    }else{
        requestDic = [NSDictionary dictionaryWithObject:@"20" forKey:Parameter_Limit];
        
    }
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/topic/%@",BaseURL,self.topic_id]]];
    [request addBodyDataSourceWithJsonByDic:requestDic Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        //    NSLog(@"%@",weakrequest.originalURL);
        NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            muzzik *muzzikToy = [muzzik new];
            TopicArray = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
            lastId = [dic objectForKey:@"tail"];
            headId = [dic objectForKey:@"from"];
            [MytableView reloadData];
            
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
    }];
    [request startAsynchronous];
}

-(void)playnextMuzzikUpdate{
    [MytableView reloadData];
}
-(void)playSongWithSongModel:(muzzik *)songModel{
    [musicPlayer shareClass].listType = SquareList;
    [musicPlayer shareClass].MusicArray = TopicArray;
    [[musicPlayer shareClass] playSongWithSongModel:songModel];
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
        }else if ([@"<>,.~!@＠#$¥%％^&*()，。：；;:.,‘“~～  》？《！＃＊……‘“”／/" containsString:[message substringWithRange:NSMakeRange(i, 1)]] && GetAt){
            GetAt = NO;
            [array addObject:[message substringWithRange:NSMakeRange(location, i-location)]];
            
        }else if(i == message.length-1 && GetAt){
            [array addObject:[message substringWithRange:NSMakeRange(location, i-location+1)]];
        }
    }
    
    
    return array;
}

@end
