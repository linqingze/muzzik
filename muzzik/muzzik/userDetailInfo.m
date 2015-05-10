//
//  userDetailInfo.m
//  muzzik
//
//  Created by muzzik on 15/5/6.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//
#import "showUserVC.h"
#import "userDetailInfo.h"
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
@property(nonatomic,retain)UIImageView *headimage;
@property(nonatomic,retain)UIButton *attentionButton;
@property(nonatomic,retain)UILabel *nameLabel;
@property(nonatomic,retain)UIImageView *genderImage;
@property(nonatomic,retain)UILabel *descriptionLabel;
@property(nonatomic,retain)UIImageView *schoolImage;
@property(nonatomic,retain)UILabel *schoolLabel;
@property(nonatomic,retain)UIImageView *birthImage;
@property(nonatomic,retain)UILabel *birthLabel;
@property(nonatomic,retain)UIImageView *constellationImage;
@property(nonatomic,retain)UILabel *constellationLabel;
@property(nonatomic,retain)UIImageView *companyImage;
@property(nonatomic,retain)UILabel *companyLabel;
@property(nonatomic,retain)UIView *genresView;
@property(nonatomic,retain)UIView *messageView;
@property(nonatomic,retain)UILabel *muzzikCount;
@property(nonatomic,retain)UILabel *followCount;
@property(nonatomic,retain)UILabel *fansCount;
@property(nonatomic,retain)UILabel *songCount;
@property(nonatomic,retain)UIView *headView;
@property(nonatomic,retain)UIImageView *coverImage;
@end

@implementation userDetailInfo

- (void)viewDidLoad {
    [super viewDidLoad];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playnextMuzzikUpdate) name:String_SetSongPlayNextNotification object:nil];
    page = 1;
    [self initNagationBar:@"Ta" leftBtn:Constant_backImage rightBtn:0];
    MyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    self.musicplayer = [musicPlayer shareClass];
    [self.view addSubview:MyTableView];
     _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH+55)];
    [self settingHeadView];
    MyTableView.delegate = self;
    MyTableView.dataSource = self;
    [MyTableView registerClass:[NormalCell class] forCellReuseIdentifier:@"NormalCell"];
    [MyTableView registerClass:[NormalNoCardCell class] forCellReuseIdentifier:@"NormalNoCardCell"];
    MyTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
   
    [MyTableView setTableHeaderView:_headView];
    ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@",BaseURL,self.uid]]];
    [requestForm addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = requestForm;
    [requestForm setCompletionBlock :^{
        NSLog(@"%@",[weakrequest responseString]);
        NSLog(@"%d",[weakrequest responseStatusCode]);
        if ([weakrequest responseStatusCode] == 200) {
            _profileDic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData]  options:NSJSONReadingMutableContainers error:nil];
            if (_profileDic) {
                if ([[_profileDic objectForKey:@"isFollow"] boolValue] &&[[_profileDic objectForKey:@"isFans"] boolValue]) {
                    [_attentionButton setImage:[UIImage imageNamed:Image_profilefolloweacherother] forState:UIControlStateNormal];
                    [_attentionButton setFrame:CGRectMake(SCREEN_WIDTH-85, 16, 65, 23)];
                }else if([[_profileDic objectForKey:@"isFollow"] boolValue]){
                    [_attentionButton setImage:[UIImage imageNamed:Image_profilefollowed] forState:UIControlStateNormal];
                    [_attentionButton setFrame:CGRectMake(SCREEN_WIDTH-75, 16, 55, 23)];
                }else{
                    [_attentionButton setImage:[UIImage imageNamed:Image_profilefollow] forState:UIControlStateNormal];
                    [_attentionButton setFrame:CGRectMake(SCREEN_WIDTH-65, 16, 45, 23)];
                }
                NSArray *dicKeys = [_profileDic allKeys];
                if ([dicKeys containsObject:@"avatar"]) {
                    [_headimage setAlpha:0];
                    [_headimage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,[_profileDic objectForKey:@"avatar"]]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        [_headimage setAlpha:1];
                        [_coverImage setAlpha:1];
                    }];
                }
                if ([dicKeys containsObject:@"name"]) {
                    _nameLabel.text = [_profileDic objectForKey:@"name"];
                    [_nameLabel sizeToFit];
                    [_nameLabel setFrame:CGRectMake(16, SCREEN_WIDTH/2-_nameLabel.frame.size.height, _nameLabel.frame.size.width, _nameLabel.frame.size.height)];
                    [_genderImage setFrame:CGRectMake(CGRectGetMaxX(_nameLabel.frame)+6, CGRectGetMidY(_nameLabel.frame)-10, 16, 16)];
                    if ([[_profileDic objectForKey:@"gender"] isEqualToString:@"m"]) {
                        [_genderImage setImage:[UIImage imageNamed:Image_profilemaleImage]];
                    }else{
                        [_genderImage setImage:[UIImage imageNamed:Image_profilefemaleImage]];
                    }
                }
                
                CGFloat recordHeight = 288;
                if ([dicKeys containsObject:@"astro"] && [[_profileDic objectForKey:@"astro"] length]>0) {
                    _constellationImage.frame = CGRectMake(16, recordHeight+5, 8, 8);
                    [_constellationImage setImage:[UIImage imageNamed:Image_profileconstellationImage]];
                    [_headView addSubview:_constellationImage];
                    _constellationLabel.frame = CGRectMake(35, recordHeight, SCREEN_WIDTH/2-50, 20);
                    [_constellationLabel setText:[_profileDic objectForKey:@"astro"]];
                    [_constellationLabel setTextColor:Color_Text_4];
                    [_constellationLabel setFont:[UIFont systemFontOfSize:12]];
                    [_headView addSubview:_constellationLabel];
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
                    
                    
                    _birthImage.frame = CGRectMake(16, recordHeight+5, 8, 8);
                    [_birthImage setImage:[UIImage imageNamed:Image_profilebirthImage]];
                    [_headView addSubview:_birthImage];
                    _birthLabel.frame = CGRectMake(35, recordHeight, SCREEN_WIDTH/2-50, 20);
                    [_birthLabel setText:_date];
                    [_birthLabel setTextColor:Color_Text_4];
                    [_birthLabel setFont:[UIFont systemFontOfSize:12]];
                    [_headView addSubview:_birthLabel];
                    recordHeight = recordHeight-28;
                    
                }
                if ([dicKeys containsObject:@"company"] && [[_profileDic objectForKey:@"company"] length]>0) {
                    _companyImage.frame = CGRectMake(16, recordHeight+5, 8, 8);
                    [_companyImage setImage:[UIImage imageNamed:Image_profilejobImage]];
                    [_headView addSubview:_companyImage];
                    _companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, recordHeight, SCREEN_WIDTH/2-50, 20)];
                    [_companyLabel setText:[_profileDic objectForKey:@"company"]];
                    [_companyLabel setTextColor:Color_Text_4];
                    [_companyLabel setFont:[UIFont systemFontOfSize:12]];
                    [_headView addSubview:_companyLabel];
                    recordHeight = recordHeight-28;
                    
                }else if([dicKeys containsObject:@"school"] && [[_profileDic objectForKey:@"school"] length]>0){
                    _schoolImage.frame = CGRectMake(16, recordHeight+5, 8, 8);
                    [_schoolImage setImage:[UIImage imageNamed:Image_profilejobImage]];
                    [_headView addSubview:_schoolImage];
                    _schoolLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, recordHeight, SCREEN_WIDTH/2-50, 20)];
                    [_schoolLabel setText:[_profileDic objectForKey:@"school"]];
                    [_schoolLabel setTextColor:Color_Text_4];
                    [_schoolLabel setFont:[UIFont systemFontOfSize:12]];
                    [_headView addSubview:_schoolLabel];
                    recordHeight = recordHeight-28;
                }
                if ([dicKeys containsObject:@"description"]) {
                    UILabel *temp = [[UILabel alloc] initWithFrame:CGRectMake(16, SCREEN_WIDTH/2, SCREEN_WIDTH-32, 100)];
                    temp.numberOfLines = 0;
                    [temp setFont:[UIFont systemFontOfSize:12]];
                    temp.text =  [_profileDic objectForKey:@"description"];
                    [temp sizeToFit];
                    _descriptionLabel.frame = CGRectMake(16, SCREEN_WIDTH/2, SCREEN_WIDTH-32, temp.frame.size.height);
                    _descriptionLabel.numberOfLines = 0;
                    
                    [_descriptionLabel setFont:[UIFont systemFontOfSize:12]];
                    _descriptionLabel.text = [_profileDic objectForKey:@"description"];
                    [_descriptionLabel setTextColor:[UIColor whiteColor]];
                    [_headView addSubview:_descriptionLabel];
                }
                
                
                if ([dicKeys containsObject:@"genres"] && [[_profileDic objectForKey:@"genres"] count]>0) {
                    [_genresView removeFromSuperview];
                    _genresView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-10, SCREEN_WIDTH-88, SCREEN_WIDTH/2-6, 76)];
                    [_headView addSubview: _genresView];
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
                        
                        [_genresView addSubview:tagLabel];
                        local = local- tempLabel.frame.size.width-28;
                    }
                }
                _muzzikCount.text = [NSString stringWithFormat:@"%@",[_profileDic objectForKey:@"muzzikTotal"]];
                _followCount.text = [NSString stringWithFormat:@"%@",[_profileDic objectForKey:@"followsCount"]];;
                _fansCount.text = [NSString stringWithFormat:@"%@",[_profileDic objectForKey:@"fansCount"]];
                _songCount.text = [NSString stringWithFormat:@"%@",[_profileDic objectForKey:@"musicsTotal"]];
            }
            
            
            ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@/muzziks",BaseURL,[_profileDic  objectForKey:@"_id"]]]];
            [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:Limit_Constant,Parameter_Limit,[NSNumber numberWithInt:page],Parameter_page, nil] Method:GetMethod auth:YES];
            __weak ASIHTTPRequest *weakre = request;
            [request setCompletionBlock :^{
                NSLog(@"%@",[weakre responseString]);
                NSLog(@"%d",[weakre responseStatusCode]);
                if ([weakre responseStatusCode] == 200) {
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakre responseData]  options:NSJSONReadingMutableContainers error:nil];
                    _muzziks = [[muzzik new] makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    muzzik *tempMuzzik = self.muzziks[indexPath.row];
    DetaiMuzzikVC *detail = [[DetaiMuzzikVC alloc] init];
    detail.localmuzzik = tempMuzzik;
    [self.navigationController pushViewController:detail animated:YES];

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

-(void)payAttention{
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
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"%f",scrollView.contentOffset.y);
    CGFloat yOffset  = scrollView.contentOffset.y;
    if (yOffset < 0 ) {
        CGRect f = _headimage.frame;
        f.origin.y = yOffset;
        f.size.height =  SCREEN_WIDTH-yOffset;
        _headimage.frame = f;
        
        CGRect cover = _coverImage.frame;
        cover.origin.y = yOffset;
        cover.size.height =  SCREEN_WIDTH-yOffset;
        _coverImage.frame = cover;
        
        CGRect d = _attentionButton.frame;
        d.origin.y = yOffset+16;
        
        _attentionButton.frame = d;
    }
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
-(void) settingHeadView{
    _headimage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
    [_headView addSubview:_headimage];
    _headimage.contentMode = UIViewContentModeScaleAspectFill;
    _coverImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
    [_coverImage setAlpha:0];
    [_coverImage setImage:[UIImage imageNamed:Image_prifilebgcover]];
    _coverImage.contentMode = UIViewContentModeScaleAspectFill;
    [_headView addSubview:_coverImage];
    _attentionButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, 16, 85, 23)];
    [_attentionButton addTarget:self action:@selector(payAttention) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_attentionButton];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, SCREEN_WIDTH/2, 30, 30)];
    [_nameLabel setFont:[UIFont fontWithName:Font_Next_DemiBold size:24]];
    _nameLabel.textColor = [UIColor whiteColor];
    [_headView addSubview:_nameLabel];
    _genderImage = [[UIImageView alloc] init];
    [_headView addSubview:_genderImage];
    
    _constellationImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 5, 8, 8)];
    _constellationLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 5, SCREEN_WIDTH/2-50, 20)];
    
    _birthImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 5, 8, 8)];
    _birthLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, SCREEN_WIDTH/2-50, 20)];
    
    _companyImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 5, 8, 8)];
    _companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, SCREEN_WIDTH/2-50, 20)];
    
    _schoolImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 5, 8, 8)];
    _schoolLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, SCREEN_WIDTH/2-50, 20)];
    _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, SCREEN_WIDTH/2, SCREEN_WIDTH-32,0)];
    
    _messageView = [[UIView alloc] initWithFrame:CGRectMake(16, SCREEN_WIDTH, SCREEN_WIDTH-32, 55)];
    [_messageView setBackgroundColor:[UIColor whiteColor]];
    UIView *muzzikView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_messageView.frame)/4, CGRectGetHeight(_messageView.frame))];
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, CGRectGetWidth(_messageView.frame)/4, 20)];
    messageLabel.font = [UIFont systemFontOfSize:11];
    messageLabel.textColor = Color_Additional_5;
    messageLabel.text = @"信息";
    messageLabel.textAlignment = NSTextAlignmentCenter;
    _muzzikCount = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, CGRectGetWidth(_messageView.frame)/4, 25)];
    [_muzzikCount setFont:[UIFont fontWithName:Font_Next_DemiBold size:15]];
    _muzzikCount.textAlignment = NSTextAlignmentCenter;
    _muzzikCount.textColor = Color_Text_2;
    [muzzikView addSubview:_muzzikCount];
    [muzzikView addSubview:messageLabel];
    
    [_messageView addSubview:muzzikView];
    
    UIView *followView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_messageView.frame)/4, 0, CGRectGetWidth(_messageView.frame)/4, CGRectGetHeight(_messageView.frame))];
    UILabel *followLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, CGRectGetWidth(_messageView.frame)/4, 20)];
    followLabel.font = [UIFont systemFontOfSize:11];
    followLabel.textColor = Color_Additional_5;
    followLabel.text = @"关注";
    followLabel.textAlignment = NSTextAlignmentCenter;
    _followCount = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, CGRectGetWidth(_messageView.frame)/4, 25)];
    [_followCount setFont:[UIFont fontWithName:Font_Next_DemiBold size:15]];
    _followCount.textAlignment = NSTextAlignmentCenter;
    _followCount.textColor = Color_Text_2;
    [followView addSubview:_followCount];
    [followView addSubview:followLabel];
    
    [_messageView addSubview:followView];
    [followView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFollow)]];
    UIView *fansView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_messageView.frame)/2, 0, CGRectGetWidth(_messageView.frame)/4, CGRectGetHeight(_messageView.frame))];
    UILabel *fansLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, CGRectGetWidth(_messageView.frame)/4, 20)];
    fansLabel.font = [UIFont systemFontOfSize:11];
    fansLabel.textColor = Color_Additional_5;
    fansLabel.text = @"粉丝";
    fansLabel.textAlignment = NSTextAlignmentCenter;
    _fansCount = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, CGRectGetWidth(_messageView.frame)/4, 25)];
    [_fansCount setFont:[UIFont fontWithName:Font_Next_DemiBold size:15]];
    _fansCount.textAlignment = NSTextAlignmentCenter;
    _fansCount.textColor = Color_Text_2;
    [fansView addSubview:_fansCount];
    [fansView addSubview:fansLabel];
    [fansView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFans)]];
    [_messageView addSubview:fansView];
    
    UIView *songView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_messageView.frame)*3/4, 0, CGRectGetWidth(_messageView.frame)/4, CGRectGetHeight(_messageView.frame))];
    UILabel *songLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, CGRectGetWidth(_messageView.frame)/4, 20)];
    songLabel.font = [UIFont systemFontOfSize:11];
    songLabel.textColor = Color_Additional_5;
    songLabel.text = @"歌单";
    songLabel.textAlignment = NSTextAlignmentCenter;
    _songCount = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, CGRectGetWidth(_messageView.frame)/4, 25)];
    [_songCount setFont:[UIFont fontWithName:Font_Next_DemiBold size:15]];
    _songCount.textAlignment = NSTextAlignmentCenter;
    _songCount.textColor = Color_Text_2;
    [songView addSubview:_songCount];
    [songView addSubview:songLabel];
    [songView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showSong)]];
    [_messageView addSubview:songView];
    [_headView addSubview:_messageView];
    UIView *linview = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_messageView.frame)/4, 16, 1, 22)];
    [linview setBackgroundColor:Color_line_1];
    [_messageView addSubview:linview];
    
    UIView *linview2 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_messageView.frame)/2, 16, 1, 22)];
    [linview2 setBackgroundColor:Color_line_1];
    [_messageView addSubview:linview2];
    
    UIView *linview3 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_messageView.frame)*3/4, 16, 1, 22)];
    [linview3 setBackgroundColor:Color_line_1];
    [_messageView addSubview:linview3];
    UIView *lineWidth = [[UIView alloc] initWithFrame:CGRectMake(0, 53, CGRectGetWidth(_messageView.frame), 2)];
    [lineWidth setBackgroundColor:Color_line_1];
    [_messageView addSubview:lineWidth];
    
    UIView *lineRed = [[UIView alloc] initWithFrame:CGRectMake(0, 53, CGRectGetWidth(_messageView.frame)/4, 2)];
    [lineRed setBackgroundColor:Color_Active_Button_1];
    [_messageView addSubview:lineRed];
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
