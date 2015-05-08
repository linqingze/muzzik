//
//  DetaiMuzzikVC.m
//  muzzik
//
//  Created by muzzik on 15/5/2.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "DetaiMuzzikVC.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "CXAHyperlinkLabel.h"
#import "CommentMuzzikCell.h"
@interface DetaiMuzzikVC ()<UITableViewDataSource,UITableViewDelegate,CXDelegate>{
    UITableView *muzzikTableView;
    UIView *headView;
    NSMutableArray *commentArray;
    int page;
}
@property (nonatomic,retain) NSMutableDictionary *profileDic;
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

//muzzik
@property (nonatomic,retain) UIView *muzzikView;
@property (nonatomic) UILabel *repostUserName;                 //转发用户名
@property (nonatomic) UIImageView *repostImage;                //muzzik类型图标
@property (nonatomic) UIButton *userImage;                  //用户头像
@property (nonatomic) UILabel *userName;                       //用户名
@property (nonatomic) UILabel *timeStamp;                      //时间
@property (nonatomic) UIProgressView *progress;
@property (nonatomic) UIButton *playButton;
@property (nonatomic) UIButton *likeButton;
@property (nonatomic) CXAHyperlinkLabel *muzzikMessage;        //muzzik文字
@property (nonatomic) UILabel *musicName;                      //音乐名称
@property (nonatomic) UILabel *musicArtist;                    //音乐家
@property (nonatomic) UIImageView *timeImage;                  //时间图标
@property (nonatomic) UILabel *muzzikRepostText;               //转发文字
@property (nonatomic) UIView *socialView;                      //社交图层
@property (nonatomic) UIImageView *upperLine;
@property (nonatomic) UIImageView *downLine;
@property (nonatomic) UIButton *moves;
@property (nonatomic) UIButton *reposts;
@property (nonatomic) UIButton *shares;
@property (nonatomic) UIButton *comments;
@property (nonatomic) UIButton *repostButton;
@property (nonatomic) UIButton *shareButton;
@property (nonatomic) UIButton *commentButton;
@property (nonatomic) NSString *colorName;
@property (nonatomic) BOOL isMoved;
@property (nonatomic) BOOL hasLoad;
@property (nonatomic) BOOL isReposted;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic) UIImageView *poImage;
@end

@implementation DetaiMuzzikVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNagationBar:@"详情" leftBtn:Constant_backImage rightBtn:0];
    muzzikTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    muzzikTableView.contentInset = UIEdgeInsetsMake(SCREEN_WIDTH/2, 0, 0, 0);
    muzzikTableView.backgroundColor = [UIColor whiteColor];
    muzzikTableView.delegate = self;
    muzzikTableView.dataSource = self;
     muzzikTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:muzzikTableView];
    [muzzikTableView registerClass:[CommentMuzzikCell class] forCellReuseIdentifier:@"CommentMuzzikCell"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playnextMuzzikUpdate) name:String_SetSongPlayNextNotification object:nil];
    page = 1;
    self.musicplayer = [musicPlayer shareClass];
    headView = [[UIView alloc] initWithFrame:CGRectMake(0, -SCREEN_WIDTH/2, SCREEN_WIDTH, SCREEN_WIDTH/2)];
    [muzzikTableView insertSubview:headView atIndex:[[muzzikTableView subviews] count]-1];
#pragma -mark head
    _headimage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH/2)];
    _headimage.contentMode = UIViewContentModeScaleAspectFill;
    [_headimage setAlpha:0];
    [headView addSubview:_headimage];
    UIImageView *coverImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
    [coverImage setImage:[UIImage imageNamed:Image_prifilebgcover]];
    [headView addSubview:coverImage];
    _attentionButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, 16, 85, 23)];
    [_attentionButton addTarget:self action:@selector(attentionAction) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:_attentionButton];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, SCREEN_WIDTH/2, 30, 30)];
    [_nameLabel setFont:[UIFont fontWithName:Font_Next_DemiBold size:24]];
    _nameLabel.textColor = [UIColor whiteColor];
    [headView addSubview:_nameLabel];
    _genderImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:Image_profilefemaleImage]];
    [headView addSubview:_genderImage];
    
    _constellationImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 5, 8, 8)];
    _constellationLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 5, SCREEN_WIDTH/2-50, 20)];
    
    _birthImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 5, 8, 8)];
    _birthLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, SCREEN_WIDTH/2-50, 20)];
    
    _companyImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 5, 8, 8)];
    _companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, SCREEN_WIDTH/2-50, 20)];
    
    _schoolImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 5, 8, 8)];
    _schoolLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, SCREEN_WIDTH/2-50, 20)];
    _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, SCREEN_WIDTH/2, SCREEN_WIDTH-32,0)];

   
    ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@",BaseURL,self.localmuzzik.MuzzikUser.user_id]]];
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
                    [_headimage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,[_profileDic objectForKey:@"avatar"]]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        [_headimage setAlpha:1];
                    }];
                }
                if ([dicKeys containsObject:@"name"]) {
                    _nameLabel.text = [_profileDic objectForKey:@"name"];
                    [_nameLabel sizeToFit];
                    [_nameLabel setFrame:CGRectMake(16, 16, _nameLabel.frame.size.width, _nameLabel.frame.size.height)];
                    [_genderImage setFrame:CGRectMake(CGRectGetMaxX(_nameLabel.frame)+6, CGRectGetMidY(_nameLabel.frame)-10, 16, 16)];
                    if ([[_profileDic objectForKey:@"gender"] isEqualToString:@"m"]) {
                        [_genderImage setImage:[UIImage imageNamed:Image_profilemaleImage]];
                    }else{
                        [_genderImage setImage:[UIImage imageNamed:Image_profilefemaleImage]];
                    }
                }
                
                CGFloat recordHeight = SCREEN_WIDTH/2-32;
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
                    [headView addSubview:_birthImage];
                    _birthLabel.frame = CGRectMake(35, recordHeight, SCREEN_WIDTH/2-50, 20);
                    [_birthLabel setText:_date];
                    [_birthLabel setTextColor:Color_Text_4];
                    [_birthLabel setFont:[UIFont systemFontOfSize:12]];
                    [headView addSubview:_birthLabel];
                    recordHeight = recordHeight-28;
                    
                }
                if ([dicKeys containsObject:@"company"] && [[_profileDic objectForKey:@"company"] length]>0) {
                    _companyImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, recordHeight+5, 8, 8)];
                    [_companyImage setImage:[UIImage imageNamed:Image_profilejobImage]];
                    [headView addSubview:_companyImage];
                    _companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, recordHeight, SCREEN_WIDTH/2-50, 20)];
                    [_companyLabel setText:[_profileDic objectForKey:@"company"]];
                    [_companyLabel setTextColor:Color_Text_4];
                    [_companyLabel setFont:[UIFont systemFontOfSize:12]];
                    [headView addSubview:_companyLabel];
                    recordHeight = recordHeight-28;
                    
                }else if([dicKeys containsObject:@"school"] && [[_profileDic objectForKey:@"school"] length]>0){
                    _schoolImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, recordHeight+5, 8, 8)];
                    [_schoolImage setImage:[UIImage imageNamed:Image_profileschoolImage]];
                    [headView addSubview:_schoolImage];
                    _schoolLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, recordHeight, SCREEN_WIDTH/2-50, 20)];
                    [_schoolLabel setText:[_profileDic objectForKey:@"school"]];
                    [_schoolLabel setTextColor:Color_Text_4];
                    [_schoolLabel setFont:[UIFont systemFontOfSize:12]];
                    [headView addSubview:_schoolLabel];
                    recordHeight = recordHeight-28;
                }
                if ([dicKeys containsObject:@"description"]) {
                    UILabel *temp = [[UILabel alloc] initWithFrame:CGRectMake(16, SCREEN_WIDTH/2, SCREEN_WIDTH-32, 100)];
                    temp.numberOfLines = 0;
                    [temp setFont:[UIFont systemFontOfSize:12]];
                    temp.text =  [_profileDic objectForKey:@"description"];
                    [temp sizeToFit];
                    _descriptionLabel.frame = CGRectMake(16, CGRectGetMaxY(_nameLabel.frame)+10, SCREEN_WIDTH-32, temp.frame.size.height);
                    _descriptionLabel.numberOfLines = 0;
                    
                    [_descriptionLabel setFont:[UIFont systemFontOfSize:12]];
                    _descriptionLabel.text = [_profileDic objectForKey:@"description"];
                    [_descriptionLabel setTextColor:[UIColor whiteColor]];
                    [headView addSubview:_descriptionLabel];
                }
                
                
                if ([dicKeys containsObject:@"genres"] && [[_profileDic objectForKey:@"genres"] count]>0) {
                    _genresView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-10, SCREEN_WIDTH/2-88, SCREEN_WIDTH/2-6, 76)];
                    [headView addSubview: _genresView];
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
                            if (localheight<28) {
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

        }
        else{
            //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
        }
        }
    }];
    [requestForm setFailedBlock:^{
        NSLog(@"%@",[weakrequest error]);
        NSLog(@"hhhh%@  kkk%@",[weakrequest responseString],[weakrequest responseHeaders]);
        [userInfo checkLoginWithVC:self];
    }];
    [requestForm startAsynchronous];
    
#pragma -mark muzzik
    _muzzikView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _userImage = [[UIButton alloc] initWithFrame:CGRectMake(16, 36, 50, 50)];
    [_userImage addTarget:self action:@selector(goToUser) forControlEvents:UIControlEventTouchUpInside];
    _userImage.layer.cornerRadius = 25;
    _userImage.layer.masksToBounds = YES;
    [_userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,self.localmuzzik.MuzzikUser.avatar]] forState:UIControlStateNormal];
    [_muzzikView addSubview:_userImage];
    if ([self.localmuzzik.type isEqualToString:@"repost"]) {
        _repostImage = [[UIImageView alloc] initWithFrame:CGRectMake(66, 36, 8, 8)];
        [_muzzikView addSubview:_repostImage];
        _repostUserName = [[UILabel alloc] initWithFrame:CGRectMake(80, 36, 150, 10)];
        [_repostUserName setTextColor:Color_Additional_5];
        [_repostUserName setFont:[UIFont fontWithName:Font_Next_DemiBold size:8]];
        _repostUserName.text = self.localmuzzik.reposter.name;
        [_muzzikView addSubview:_repostUserName];
    }
    
    _timeStamp = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-130, 15, 96, 9)];
    [_timeStamp setTextColor:Color_Additional_5];
    [_timeStamp setFont:[UIFont fontWithName:Font_Next_medium size:9]];
    _timeStamp.textAlignment = NSTextAlignmentRight;
    _timeStamp.text = [MuzzikItem transtromTime:self.localmuzzik.date];
    [_muzzikView addSubview:_timeStamp];
    _timeImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-30, 15, 9, 9)];
    [_timeImage setImage:[UIImage imageNamed:Image_timeImage]];
    [_muzzikView addSubview:_timeImage];
    
    _userName = [[UILabel alloc] initWithFrame:CGRectMake(80, 55, 180, 20)];
    //  [_userName setTextColor:Color_LightGray];
    [_userName setFont:[UIFont fontWithName:Font_Next_DemiBold size:15]];
    [_userName setTextColor:Color_Text_1];
    _userName.text = self.localmuzzik.MuzzikUser.name;
    [_muzzikView addSubview:_userName];
    _muzzikMessage = [[CXAHyperlinkLabel alloc] initWithFrame:CGRectMake( 80, 83, SCREEN_WIDTH-110, 2000)];
    [_muzzikMessage setTextColor:Color_Text_2];
    [_muzzikMessage setFont:[UIFont systemFontOfSize:15]];
    
    NSString *temp = self.localmuzzik.message;
    temp = [self transformMessage:temp withAt:[self searchUsers:temp] ];
    [_muzzikMessage setText: [self transformMessage:temp withTopics:self.localmuzzik.topics ]];
    _muzzikMessage.delegate = self;
    CXAHyperlinkLabel *label = [[CXAHyperlinkLabel alloc] initWithFrame:CGRectMake(75, 0, SCREEN_WIDTH-80, 500)];
    [label setText:self.localmuzzik.message];
    CGSize msize = [label sizeThatFits:CGSizeMake(SCREEN_WIDTH-80, 2000)];
    [_muzzikMessage setFrame:CGRectMake( 80, 83, SCREEN_WIDTH-110, msize.height)];
    [_muzzikView addSubview:_muzzikMessage];
    _muzzikView.backgroundColor = [UIColor whiteColor];
    _progress = [[UIProgressView alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(_muzzikMessage.frame)+10, SCREEN_WIDTH-32, 0.5)];
    [_progress setProgress:1];
    [_muzzikView addSubview:_progress];
    _musicName = [[UILabel alloc] initWithFrame:CGRectMake(80, CGRectGetMaxY(_progress.frame)+12, SCREEN_WIDTH-150, 20)];
    [_musicName setFont:[UIFont fontWithName:Font_Next_Bold size:16]];
    _musicName.text = self.localmuzzik.music.name;
    [_muzzikView addSubview:_musicName];
    
    _musicArtist = [[UILabel alloc] initWithFrame:CGRectMake(80, CGRectGetMaxY(_progress.frame)+31, SCREEN_WIDTH-150, 25)];
    [_musicArtist setFont:[UIFont fontWithName:Font_Next_Bold size:13]];
    _musicArtist.text = self.localmuzzik.music.artist;
    [_muzzikView addSubview:_musicArtist];
    
    _likeButton = [[UIButton alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(_progress.frame)+13, 34, 34)];
    [_likeButton addTarget:self action:@selector(moveAction) forControlEvents:UIControlEventTouchUpInside];
    [_muzzikView addSubview:_likeButton];
    
    _playButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-50, CGRectGetMaxY(_progress.frame)+13, 34, 34)];
    
    [_playButton addTarget:self action:@selector(playMusicAction:) forControlEvents:UIControlEventTouchUpInside];
    [_muzzikView addSubview:_playButton];
    if ([self.localmuzzik.image length]>0) {
        _poImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/8, CGRectGetMaxY(_progress.frame)+60, SCREEN_WIDTH*3/4, SCREEN_WIDTH*3/4)];
        _poImage.layer.cornerRadius = 3;
        _poImage.clipsToBounds = YES;
        [_poImage  sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,self.localmuzzik.image]]];
        [_muzzikView addSubview:_poImage];
        
        _reposts = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH*1)/8.0, CGRectGetMaxY(_progress.frame)+SCREEN_WIDTH*3/4+60, (SCREEN_WIDTH*3)/16.0, 40)];

        
    }else{
        _upperLine = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/8,CGRectGetMaxY(_progress.frame)+59, SCREEN_WIDTH*3/4, 1)];
        [_upperLine setImage:[UIImage imageNamed:Image_lineImage]];
        [_muzzikView addSubview:_upperLine];
        _reposts = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH*1)/8.0, CGRectGetMaxY(_progress.frame)+60, (SCREEN_WIDTH*3)/16.0, 40)];

    }
    [_reposts setTitle:[self.localmuzzik.reposts integerValue]>0? [NSString stringWithFormat:@"转发数%@",self.localmuzzik.reposts] : @"转发数" forState:UIControlStateNormal];
    [_reposts setTitleColor:Color_Additional_5 forState:UIControlStateNormal];
    [_reposts.titleLabel setFont:[UIFont systemFontOfSize:10.0]];
    [_reposts addTarget:self action:@selector(pushRepost) forControlEvents:UIControlEventTouchUpInside];
    _reposts.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_muzzikView addSubview:_reposts];
    
    _moves = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH*5)/16.0, CGRectGetMidY(_reposts.frame), (SCREEN_WIDTH*3)/16.0, 40)];
    [_moves setTitle:@"喜欢数" forState:UIControlStateNormal];
    [_moves setTitleColor:Color_Additional_5 forState:UIControlStateNormal];
    [_moves.titleLabel setFont:[UIFont systemFontOfSize:10.0]];
    [_moves addTarget:self action:@selector(pushMove) forControlEvents:UIControlEventTouchUpInside];
    _moves.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_moves setTitle:[self.localmuzzik.moveds integerValue]>0? [NSString stringWithFormat:@"转发数%@",self.localmuzzik.moveds] : @"转发数" forState:UIControlStateNormal];
    [_muzzikView addSubview:_moves];
    
    _shares = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, CGRectGetMidY(_reposts.frame), (SCREEN_WIDTH*3)/16.0, 40)];
    [_shares setTitle:@"分享数" forState:UIControlStateNormal];
    [_shares setTitleColor:Color_Additional_5 forState:UIControlStateNormal];
    [_shares.titleLabel setFont:[UIFont systemFontOfSize:10.0]];
    [_shares addTarget:self action:@selector(pushShare) forControlEvents:UIControlEventTouchUpInside];
    [_shares setTitle:[self.localmuzzik.shares integerValue]>0? [NSString stringWithFormat:@"转发数%@",self.localmuzzik.shares] : @"转发数" forState:UIControlStateNormal];
    _shares.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_muzzikView addSubview:_shares];
    
    _comments = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH*11)/16.0, CGRectGetMidY(_reposts.frame), (SCREEN_WIDTH*3)/16.0, 40)];
    [_comments setTitle:@"评论数" forState:UIControlStateNormal];
    [_comments setTitleColor:Color_Additional_5 forState:UIControlStateNormal];
    [_comments.titleLabel setFont:[UIFont systemFontOfSize:10.0]];
    [_comments addTarget:self action:@selector(pushComment) forControlEvents:UIControlEventTouchUpInside];
    [_comments setTitle:[self.localmuzzik.comments integerValue]>0? [NSString stringWithFormat:@"转发数%@",self.localmuzzik.comments] : @"转发数" forState:UIControlStateNormal];
    _comments.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_muzzikView addSubview:_comments];
    
    
    
    _downLine = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/8,CGRectGetMidY(_reposts.frame)+40, SCREEN_WIDTH*3/4, 1)];
    [_downLine setImage:[UIImage imageNamed:Image_lineImage]];
    [_muzzikView addSubview:_downLine];
    
    _repostButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/8,CGRectGetMidY(_reposts.frame)+40, SCREEN_WIDTH/4.0, 45)];
    [_repostButton setImage:[UIImage imageNamed:Image_retweetImage] forState:UIControlStateNormal];
    [_repostButton addTarget:self action:@selector(repostAction) forControlEvents:UIControlEventTouchUpInside];
    [_muzzikView addSubview:_repostButton];
    //[_repostButton setBackgroundColor:Color_Additional_4];
    _shareButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*3/8,CGRectGetMidY(_reposts.frame)+40, SCREEN_WIDTH/4.0, 45)];
    [_shareButton setImage:[UIImage imageNamed:Image_shareImage] forState:UIControlStateNormal];
    [_shareButton addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
    [_muzzikView addSubview:_shareButton];
    
    _commentButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*5/8,CGRectGetMidY(_reposts.frame)+40, SCREEN_WIDTH/4.0, 45)];
    [_commentButton setImage:[UIImage imageNamed:Image_replyImage] forState:UIControlStateNormal];
    [_commentButton addTarget:self action:@selector(commentAction) forControlEvents:UIControlEventTouchUpInside];
    [_muzzikView addSubview:_commentButton];
    
    UIView *cardView = [[UIView alloc] initWithFrame:CGRectMake(16, CGRectGetMidY(_reposts.frame)+85, SCREEN_WIDTH-32, 135)];
    cardView.backgroundColor = Color_line_2;
    cardView.layer.cornerRadius = 5;
    cardView.clipsToBounds = YES;
    cardView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    cardView.layer.borderWidth = 2.0f;
    
    [_muzzikView addSubview:cardView];
    UIButton *cardHeader = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, 67, 67)];
    cardHeader.layer.cornerRadius = 33.5;
    cardHeader.clipsToBounds = YES;
    [cardHeader setImage:[_userImage imageForState:UIControlStateNormal]  forState:UIControlStateNormal];
    [cardHeader addTarget:self action:@selector(goToUser) forControlEvents:UIControlEventTouchUpInside];
    [cardView addSubview:cardHeader];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(97, 18, 150, 20)];
    [nameLabel setFont:[UIFont fontWithName:Font_Next_DemiBold size:20]];
    nameLabel.text =self.localmuzzik.MuzzikUser.name;
    [nameLabel sizeToFit];
    [cardView addSubview:nameLabel];
    
    UIImageView *genderSign = [[UIImageView alloc] initWithFrame:CGRectMake(97+nameLabel.frame.size.width+15, 18, 20, 20)];
    if ([self.localmuzzik.MuzzikUser.gender isEqualToString:@"m"]) {
        [genderSign setImage:[UIImage imageNamed:Image_profilemaleImage]];
    }else{
        [genderSign setImage:[UIImage imageNamed:Image_profilefemaleImage]];
    }
    [cardView addSubview:genderSign];
    if ([[_profileDic allKeys] containsObject:@"genres"] && [[_profileDic objectForKey:@"genres"] count]>0) {
        UIView *genresV = [[UIView alloc] initWithFrame:CGRectMake(97, 55, SCREEN_WIDTH-160, 40)];
        [cardView addSubview: genresV];
        int local = 0;
        int localheight = 0;
        for (NSDictionary * dic in [_profileDic objectForKey:@"genres"]) {
            UILabel *tempLabel = [[UILabel alloc ] initWithFrame:CGRectMake(local, localheight, 100, 20)];
            [tempLabel setFont:[UIFont systemFontOfSize:12]];
            [tempLabel setText:[dic objectForKey:@"data"]];
            [tempLabel setTextColor:Color_Text_3];
            [tempLabel sizeToFit];
            if (local+ tempLabel.frame.size.width+10>SCREEN_WIDTH-160) {
                localheight = localheight+20;
                local = 0;
                if (localheight>30) {
                    break;
                }
            }else{
                local = local+tempLabel.frame.size.width+15;
                [genresV addSubview:tempLabel];
            }

        }
    }
    [muzzikTableView setTableHeaderView:_muzzikView];
    [_muzzikView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetMidY(_reposts.frame)+220)];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/%@/comments",BaseURL,self.localmuzzik.muzzik_id]]];
    [request addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:NO];
    __weak ASIHTTPRequest *weakre = request;
    [request setCompletionBlock :^{
        NSLog(@"%@",[weakre responseString]);
        NSLog(@"%d",[weakre responseStatusCode]);
        if ([weakre responseStatusCode] == 200) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakre responseData]  options:NSJSONReadingMutableContainers error:nil];
            commentArray = [[muzzik new] makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
            [muzzikTableView reloadData];
            
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"%f",scrollView.contentOffset.y);
    CGFloat yOffset  = scrollView.contentOffset.y;
    if (yOffset < -SCREEN_WIDTH/2 ) {
        CGRect f = _headimage.frame;
        f.origin.y = yOffset+SCREEN_WIDTH/2;
        f.size.height =  -yOffset;
        _headimage.frame = f;
        
        CGRect d = _attentionButton.frame;
        d.origin.y = yOffset+SCREEN_WIDTH/2+16;
       
        _attentionButton.frame = d;
    }
}
#pragma -mark method
-(NSString *)transformMessage:(NSString *)message withTopics:(NSArray *)topics {
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
-(NSString *)transformMessage:(NSString *)message withAt:(NSArray *)topics {
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



#pragma -mark tableView Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    muzzik *tempMuzzik = commentArray[indexPath.row];
    CommentMuzzikCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentMuzzikCell" forIndexPath:indexPath];
    [cell.userImage sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,tempMuzzik.MuzzikUser.avatar]] forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [UIView animateWithDuration:0.5 animations:^{
            [cell.userImage setAlpha:1];
        }];
    }];
    cell.userName.text = tempMuzzik.MuzzikUser.name;
    cell.message.text = tempMuzzik.message;
    cell.timeLabel.text = [MuzzikItem transtromTime:tempMuzzik.date];
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return commentArray.count;
}
@end
