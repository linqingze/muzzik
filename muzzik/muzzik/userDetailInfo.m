//
//  userDetailInfo.m
//  muzzik
//
//  Created by muzzik on 15/5/6.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//
#import "showUserVC.h"
#import "userDetailInfo.h"
#import "userHeadCell.h"
#import "NormalCell.h"
#import "NormalNoCardCell.h"
#import "UIButton+WebCache.h"
#import "DetaiMuzzikVC.h"
#import "UIImageView+WebCache.h"
#import "UIScrollView+DXRefresh.h"
@interface userDetailInfo ()<UITableViewDataSource,UITableViewDelegate,CXDelegate,CellDelegate>{
    UITableView *MyTableView;
    int page;
}
@property (nonatomic,retain) NSDictionary *profileDic;
@property (nonatomic,retain) NSMutableArray *muzziks;
@end

@implementation userDetailInfo

- (void)viewDidLoad {
    [super viewDidLoad];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playnextMuzzikUpdate) name:String_SetSongPlayNextNotification object:nil];
    page = 1;
    [self initNagationBar:@"Ta" leftBtn:Constant_backImage rightBtn:0];
    MyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-44)];
    self.musicplayer = [musicPlayer shareClass];
    [self.view addSubview:MyTableView];
    MyTableView.delegate = self;
    MyTableView.dataSource = self;
    [MyTableView registerClass:[userHeadCell class] forCellReuseIdentifier:@"userHeadCell"];
    [MyTableView registerClass:[NormalCell class] forCellReuseIdentifier:@"NormalCell"];
    [MyTableView registerClass:[NormalNoCardCell class] forCellReuseIdentifier:@"NormalNoCardCell"];
    MyTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@",BaseURL,self.uid]]];
    [requestForm addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = requestForm;
    [requestForm setCompletionBlock :^{
        NSLog(@"%@",[weakrequest responseString]);
        NSLog(@"%d",[weakrequest responseStatusCode]);
        if ([weakrequest responseStatusCode] == 200) {
            _profileDic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData]  options:NSJSONReadingMutableContainers error:nil];
            ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@/muzziks",BaseURL,self.uid]]];
            [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:Limit_Constant,Parameter_Limit,[NSNumber numberWithInt:page],Parameter_page, nil] Method:GetMethod auth:YES];
            __weak ASIHTTPRequest *weakre = request;
            [request setCompletionBlock :^{
                NSLog(@"%@",[weakre responseString]);
                NSLog(@"%d",[weakre responseStatusCode]);
                if ([weakre responseStatusCode] == 200) {
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakre responseData]  options:NSJSONReadingMutableContainers error:nil];
                    _muzziks = [[muzzik new] makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
                    [_muzziks insertObject:[muzzik new] atIndex:0];
                    [MyTableView reloadData];
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
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MyTableView addFooterWithTarget:self action:@selector(refreshFooter)];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MyTableView removeFooter];
}
-(void)refreshFooter{
    page++;
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@/muzziks",BaseURL,self.uid]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:Limit_Constant,Parameter_Limit,[NSNumber numberWithInt:page],Parameter_page, nil] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        //    NSLog(@"%@",weakrequest.originalURL);
        NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            
            muzzik *muzzikToy = [muzzik new];
            [self.muzziks addObjectsFromArray:[muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]]];
            muzzikToy = [self.muzziks lastObject];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MyTableView reloadData];
                [MyTableView footerEndRefreshing];
                if ([[dic objectForKey:@"muzziks"] count]<[Limit_Constant integerValue] ) {
                    [MyTableView removeFooter];
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
    if (indexPath.row == 0) {
        return SCREEN_WIDTH+55;
    }else{
        CXAHyperlinkLabel *label = [[CXAHyperlinkLabel alloc] initWithFrame:CGRectMake(75, 0, SCREEN_WIDTH-80, 500)];
        muzzik *tempMuzzik = [self.muzziks objectAtIndex:indexPath.row];
        [label setText:tempMuzzik.message];
        CGSize msize = [label sizeThatFits:CGSizeMake(SCREEN_WIDTH-80, 2000)];
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
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.muzziks[indexPath.row] isKindOfClass:[muzzik class]] && indexPath.row!=0) {
        muzzik *tempMuzzik = self.muzziks[indexPath.row];
        DetaiMuzzikVC *detail = [[DetaiMuzzikVC alloc] init];
        detail.muzzik_id = tempMuzzik.muzzik_id;
        UINavigationController *nac = [[UINavigationController alloc] initWithRootViewController:detail];
        [self presentViewController:nac animated:YES completion:nil];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        userHeadCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userHeadCell" forIndexPath:indexPath];
        cell.uid = self.uid;
        if (_profileDic) {
            cell.delegate = self;
            if ([[_profileDic objectForKey:@"isFollow"] boolValue] &&[[_profileDic objectForKey:@"isFans"] boolValue]) {
                [cell.attentionButton setImage:[UIImage imageNamed:Image_profilefolloweacherother] forState:UIControlStateNormal];
                [cell.attentionButton setFrame:CGRectMake(SCREEN_WIDTH-85, 16, 65, 23)];
            }else if([[_profileDic objectForKey:@"isFollow"] boolValue]){
                [cell.attentionButton setImage:[UIImage imageNamed:Image_profilefollowed] forState:UIControlStateNormal];
                [cell.attentionButton setFrame:CGRectMake(SCREEN_WIDTH-75, 16, 55, 23)];
            }else{
                [cell.attentionButton setImage:[UIImage imageNamed:Image_profilefollow] forState:UIControlStateNormal];
                [cell.attentionButton setFrame:CGRectMake(SCREEN_WIDTH-65, 16, 45, 23)];
            }
            NSArray *dicKeys = [_profileDic allKeys];
            if ([dicKeys containsObject:@"avatar"]) {
                [cell.headimage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,[_profileDic objectForKey:@"avatar"]]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    [cell.headimage setAlpha:1];
                }];
            }
            if ([dicKeys containsObject:@"name"]) {
                cell.nameLabel.text = [_profileDic objectForKey:@"name"];
                [cell.nameLabel sizeToFit];
                [cell.nameLabel setFrame:CGRectMake(16, SCREEN_WIDTH/2-cell.nameLabel.frame.size.height, cell.nameLabel.frame.size.width, cell.nameLabel.frame.size.height)];
                [cell.genderImage setFrame:CGRectMake(CGRectGetMaxX(cell.nameLabel.frame)+6, CGRectGetMidY(cell.nameLabel.frame)-10, 16, 16)];
                if ([[_profileDic objectForKey:@"gender"] isEqualToString:@"m"]) {
                    [cell.genderImage setImage:[UIImage imageNamed:Image_profilemaleImage]];
                }else{
                    [cell.genderImage setImage:[UIImage imageNamed:Image_profilefemaleImage]];
                }
            }
            
            CGFloat recordHeight = 288;
            if ([dicKeys containsObject:@"astro"] && [[_profileDic objectForKey:@"astro"] length]>0) {
                cell.constellationImage.frame = CGRectMake(16, recordHeight+5, 8, 8);
                [cell.constellationImage setImage:[UIImage imageNamed:Image_profileconstellationImage]];
                [cell addSubview:cell.constellationImage];
                cell.constellationLabel.frame = CGRectMake(35, recordHeight, SCREEN_WIDTH/2-50, 20);
                [cell.constellationLabel setText:[_profileDic objectForKey:@"astro"]];
                [cell.constellationLabel setTextColor:Color_Text_4];
                [cell.constellationLabel setFont:[UIFont systemFontOfSize:12]];
                [cell addSubview:cell.constellationLabel];
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
                
                
                cell.birthImage.frame = CGRectMake(16, recordHeight+5, 8, 8);
                [cell.birthImage setImage:[UIImage imageNamed:Image_profilebirthImage]];
                [cell addSubview:cell.birthImage];
                cell.birthLabel.frame = CGRectMake(35, recordHeight, SCREEN_WIDTH/2-50, 20);
                [cell.birthLabel setText:_date];
                [cell.birthLabel setTextColor:Color_Text_4];
                [cell.birthLabel setFont:[UIFont systemFontOfSize:12]];
                [cell addSubview:cell.birthLabel];
                recordHeight = recordHeight-28;
                
            }
            if ([dicKeys containsObject:@"company"] && [[_profileDic objectForKey:@"company"] length]>0) {
                cell.companyImage.frame = CGRectMake(16, recordHeight+5, 8, 8);
                [cell.companyImage setImage:[UIImage imageNamed:Image_profilejobImage]];
                [cell addSubview:cell.companyImage];
                cell.companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, recordHeight, SCREEN_WIDTH/2-50, 20)];
                [cell.companyLabel setText:[_profileDic objectForKey:@"company"]];
                [cell.companyLabel setTextColor:Color_Text_4];
                [cell.companyLabel setFont:[UIFont systemFontOfSize:12]];
                [cell addSubview:cell.companyLabel];
                recordHeight = recordHeight-28;
                
            }else if([dicKeys containsObject:@"school"] && [[_profileDic objectForKey:@"school"] length]>0){
                cell.schoolImage.frame = CGRectMake(16, recordHeight+5, 8, 8);
                [cell.schoolImage setImage:[UIImage imageNamed:Image_profilejobImage]];
                [cell addSubview:cell.schoolImage];
                cell.schoolLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, recordHeight, SCREEN_WIDTH/2-50, 20)];
                [cell.schoolLabel setText:[_profileDic objectForKey:@"school"]];
                [cell.schoolLabel setTextColor:Color_Text_4];
                [cell.schoolLabel setFont:[UIFont systemFontOfSize:12]];
                [cell addSubview:cell.schoolLabel];
                recordHeight = recordHeight-28;
            }
            if ([dicKeys containsObject:@"description"]) {
                UILabel *temp = [[UILabel alloc] initWithFrame:CGRectMake(16, SCREEN_WIDTH/2, SCREEN_WIDTH-32, 100)];
                temp.numberOfLines = 0;
                [temp setFont:[UIFont systemFontOfSize:12]];
                temp.text =  [_profileDic objectForKey:@"description"];
                [temp sizeToFit];
                cell.descriptionLabel.frame = CGRectMake(16, SCREEN_WIDTH/2, SCREEN_WIDTH-32, temp.frame.size.height);
                cell.descriptionLabel.numberOfLines = 0;
                
                [cell.descriptionLabel setFont:[UIFont systemFontOfSize:12]];
                cell.descriptionLabel.text = [_profileDic objectForKey:@"description"];
                [cell.descriptionLabel setTextColor:[UIColor whiteColor]];
                [cell addSubview:cell.descriptionLabel];
            }
            
            
            if ([dicKeys containsObject:@"genres"] && [[_profileDic objectForKey:@"genres"] count]>0) {
                [cell.genresView removeFromSuperview];
                cell.genresView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-10, SCREEN_WIDTH-88, SCREEN_WIDTH/2-6, 76)];
                [cell addSubview: cell.genresView];
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
                    
                    [cell.genresView addSubview:tagLabel];
                    local = local- tempLabel.frame.size.width-28;
                }
            }
            cell.muzzikCount.text = [NSString stringWithFormat:@"%@",[_profileDic objectForKey:@"muzzikTotal"]];
            cell.followCount.text = [NSString stringWithFormat:@"%@",[_profileDic objectForKey:@"followsCount"]];;
            cell.fansCount.text = [NSString stringWithFormat:@"%@",[_profileDic objectForKey:@"fansCount"]];
            cell.songCount.text = [NSString stringWithFormat:@"%@",[_profileDic objectForKey:@"musicsTotal"]];
        }
        return cell;
    }else{
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
                [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,tempMuzzik.MuzzikUser.avatar]] forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    [UIView animateWithDuration:0.5 animations:^{
                        [cell.userImage setAlpha:1];
                    }];
                    
                }];
                [cell.userImage setUserInteractionEnabled:NO];
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
            }else {
                NormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell" forIndexPath:indexPath];
                cell.songModel = [self.muzziks objectAtIndex:indexPath.row];
                if ([tempMuzzik.music.key isEqualToString:self.musicplayer.localMuzzik.music.key] &&!glob.isPause) {
                    cell.isPlaying = YES;
                }else{
                    cell.isPlaying = NO;
                }
                [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,tempMuzzik.MuzzikUser.avatar]] forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    [UIView animateWithDuration:0.5 animations:^{
                        [cell.userImage setAlpha:1];
                    }];
                    
                }];
                [cell.userImage setUserInteractionEnabled:NO];
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
        }else{
            if ([tempMuzzik.type isEqualToString:@"repost"] ){
                NormalNoCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalNoCardCell" forIndexPath:indexPath];
                cell.songModel = [self.muzziks objectAtIndex:indexPath.row];
                if ([tempMuzzik.music.key isEqualToString:self.musicplayer.localMuzzik.music.key] &&!glob.isPause) {
                    cell.isPlaying = YES;
                }else{
                    cell.isPlaying = NO;
                }
                [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,tempMuzzik.MuzzikUser.avatar]] forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    [UIView animateWithDuration:0.5 animations:^{
                        [cell.userImage setAlpha:1];
                    }];
                    
                }];
                [cell.userImage setUserInteractionEnabled:NO];
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
            }else {
                NormalNoCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalNoCardCell" forIndexPath:indexPath];
                cell.songModel = [self.muzziks objectAtIndex:indexPath.row];
                if ([tempMuzzik.music.key isEqualToString:self.musicplayer.localMuzzik.music.key] &&!glob.isPause) {
                    cell.isPlaying = YES;
                }else{
                    cell.isPlaying = NO;
                }
                [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,tempMuzzik.MuzzikUser.avatar]] forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    [UIView animateWithDuration:0.5 animations:^{
                        [cell.userImage setAlpha:1];
                    }];
                    
                }];
                [cell.userImage setUserInteractionEnabled:NO];
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
            }
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

-(void)payAttention:(NSString *)uid{
    if ([[_profileDic objectForKey:@"isFollow"] boolValue]) {
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_user_Unfollow]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:self.uid forKey:@"_id"] Method:PostMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            
            if ([weakrequest responseStatusCode] == 200) {
                [_profileDic setValue:[NSNumber numberWithBool:NO] forKey:@"isFollow"];
                [MyTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
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
                [MyTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
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


-(void)moveMuzzikWithId:(NSString *)muzzik_id isMoved:(BOOL) ismoved atIndex:(NSInteger) index{
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/%@/moved",BaseURL,muzzik_id]]];
        NSDictionary *dic;
        if (!ismoved ) {
            dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"ismoved"];
        }
        else{
            dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"ismoved"];
        }
        [requestForm addBodyDataSourceWithJsonByDic:dic Method:PostMethod auth:YES];
        //NSLog(@"json:%@,dic:%@",tempJsonData,dic);
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            // NSLog(@"%@",[weakrequest responseString]);
            // NSLog(@"%d",[weakrequest responseStatusCode]);
            if ([weakrequest responseStatusCode] == 200) {
                // NSData *data = [weakrequest responseData];
                muzzik *localMuzzik = self.muzziks[index];
                localMuzzik.ismoved = [[dic objectForKey:@"ismoved"] boolValue];
                if ([[dic objectForKey:@"ismoved"] boolValue]) {
                    localMuzzik.moveds = [NSString stringWithFormat:@"%ld",[localMuzzik.moveds integerValue]-1];
                }else{
                    localMuzzik.moveds = [NSString stringWithFormat:@"%ld",[localMuzzik.moveds integerValue]-1];
                }
                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:index inSection:0];
                [MyTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
            }
            else{
                //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
            }
        }];
        [requestForm setFailedBlock:^{
            NSLog(@"%@",[weakrequest error]);
        }];
        [requestForm startAsynchronous];
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
            [MyTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
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


-(void)playnextMuzzikUpdate{
    [MyTableView reloadData];
}
-(void)playSongWithSongModel:(muzzik *)songModel{
    _musicplayer.listType = SquareList;
    _musicplayer.MusicArray = self.muzziks;
    [_musicplayer playSongWithSongModel:songModel];

   // [self.homeNav checkShowMusicView];
}

-(void) commentAtMuzzik:(NSString *)muzzik_id{
    NSLog(@"comment in%@",muzzik_id);
}
-(void) showRepost:(NSString *)muzzik_id{
    showUserVC *showvc = [[showUserVC alloc] init];
    showvc.muzzik_id = muzzik_id;
    showvc.showType = @"repost";
    UINavigationController *nac = [[UINavigationController alloc] initWithRootViewController:showvc];
    [self presentViewController:nac animated:YES completion:nil];
}
-(void) showShare:(NSString *)muzzik_id{
    showUserVC *showvc = [[showUserVC alloc] init];
    showvc.muzzik_id = muzzik_id;
    showvc.showType = @"share";
    UINavigationController *nac = [[UINavigationController alloc] initWithRootViewController:showvc];
    [self presentViewController:nac animated:YES completion:nil];
}
-(void) showComment:(NSString *)muzzik_id{
    NSLog(@"commenn%@",muzzik_id);
}

-(void) showMoved:(NSString *)muzzik_id{
    showUserVC *showvc = [[showUserVC alloc] init];
    showvc.muzzik_id = muzzik_id;
    showvc.showType = @"moved";
    UINavigationController *nac = [[UINavigationController alloc] initWithRootViewController:showvc];
    [self presentViewController:nac animated:YES completion:nil];
}
-(void)showSong:(NSString *)uid{
    
}

-(void)showFans:(NSString *)uid{

}

-(void)showFollow:(NSString *)uid{
    
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
