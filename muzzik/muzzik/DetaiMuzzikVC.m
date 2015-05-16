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
#import "userDetailInfo.h"
#import "HPGrowingTextView.h"
#import "ChooseMusicVC.h"
#import "showUserVC.h"
#import "LoginViewController.h"
#import "FriendVC.h"
#import "TopicDetail.h"
#import "TopicHotVC.h"
#import "Globle.h"
#import "UIScrollView+DXRefresh.h"
@interface DetaiMuzzikVC ()<UITableViewDataSource,UITableViewDelegate,CXDelegate,HPGrowingTextViewDelegate,CellDelegate>{
    UITableView *muzzikTableView;
    UIView *headView;
    NSMutableArray *commentArray;
    UIView *genresV;
    UIView *cardView;
    int page;
    //评论框
    UIView *commentView;
    HPGrowingTextView *comnentTextView;
    UIButton *musicButton;
    UIButton *privateButton;
    UIButton *sendButton;
    UIView *songView;
    UILabel *songLabel;
    UILabel *artistLabel;
    UIButton *deleButton;
    CGRect tableOriginRect;
    CGRect commentViewRect;
    BOOL firstLoad;
    BOOL isContainMusic;
    muzzik *commentToMuzzik;
    BOOL checkPair;                    //取配对＃和@，防止多次跳转
    NSString *commentText;
    UIView *commentTitle;               //评论头视图
    CGFloat MuzzikViewheight;
    BOOL isComment;                  //评论时，关闭键盘自动滚到表头；
    NSString *lastID;
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
@property(nonatomic,retain)UIImageView *coverImage;

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
@property (nonatomic) UIButton *deleMuzzikButton;
@property (nonatomic) UIButton *repostButton;
@property (nonatomic) UIButton *shareButton;
@property (nonatomic) UIButton *commentButton;
@property (nonatomic) NSString *colorName;
@property (nonatomic) BOOL isMoved;
@property (nonatomic) BOOL hasLoad;
@property (nonatomic) BOOL isReposted;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic) UIImageView *poImage;
@property (nonatomic) UIButton *addFriendButton;

@end

@implementation DetaiMuzzikVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [self initNagationBar:@"详情" leftBtn:Constant_backImage rightBtn:0];
    commentToMuzzik = self.localmuzzik;
    muzzikTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-119)];
    tableOriginRect = muzzikTableView.frame;
    muzzikTableView.contentInset = UIEdgeInsetsMake(SCREEN_WIDTH/2, 0, 0, 0);
    muzzikTableView.backgroundColor = [UIColor whiteColor];
    muzzikTableView.delegate = self;
    muzzikTableView.dataSource = self;
     muzzikTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:muzzikTableView];
    [self followScrollView:muzzikTableView];
    commentView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-119, SCREEN_WIDTH, 55)];
    
    [commentView setBackgroundColor:Color_line_2];
    [self.view addSubview:commentView];
    [MuzzikItem addLineOnView:commentView heightPoint:0 toLeft:0 toRight:0 withColor:Color_line_1];
    musicButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 36, 55)];
    [musicButton setImage:[UIImage imageNamed:Image_detailaddsongImage] forState:UIControlStateNormal];
    [musicButton addTarget:self action:@selector(selectMusic) forControlEvents:UIControlEventTouchUpInside];
    [commentView addSubview:musicButton];
    comnentTextView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(36, 10, SCREEN_WIDTH-72, 40)];
    comnentTextView.layer.borderWidth =1;
    comnentTextView.layer.borderColor = Color_Text_4.CGColor;
    comnentTextView.layer.cornerRadius = 3;
    comnentTextView.clipsToBounds = YES;
    comnentTextView.delegate = self;
    comnentTextView.maxHeight = 100;
    comnentTextView.font = [UIFont systemFontOfSize:15];
    comnentTextView.textColor = Color_Text_2;
    [comnentTextView setReturnKeyType:UIReturnKeySend];
    comnentTextView.animateHeightChange = NO;
    comnentTextView.placeholder = [NSString stringWithFormat:@"评论 %@",self.localmuzzik.MuzzikUser.name];
    comnentTextView.placeholderColor = Color_Text_4;
    [commentView addSubview:comnentTextView];
    privateButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-36, 0, 36, 55)];
    [privateButton setImage:[UIImage imageNamed:Image_detailvisibleImage] forState:UIControlStateNormal];
    [privateButton addTarget:self action:@selector(PrivateAction) forControlEvents:UIControlEventTouchUpInside];
    [commentView addSubview:privateButton];
    commentViewRect = commentView.frame;
    
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
    _coverImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH/2)];
    [_coverImage setAlpha:0];
    [_coverImage setImage:[UIImage imageNamed:Image_prifilebgcover]];
    [headView addSubview:_coverImage];
    _attentionButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, 16, 85, 23)];
    [_attentionButton addTarget:self action:@selector(attentionAction) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:_attentionButton];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, SCREEN_WIDTH/2, 30, 30)];
    [_nameLabel setFont:[UIFont fontWithName:Font_Next_DemiBold size:24]];
    _nameLabel.textColor = [UIColor whiteColor];
    [headView addSubview:_nameLabel];
    _genderImage = [[UIImageView alloc] init];
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
                _addFriendButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 93, SCREEN_WIDTH-62, 27)];
                [_addFriendButton addTarget:self action:@selector(attentionOrVisit) forControlEvents:UIControlEventTouchUpInside];
                [cardView addSubview:_addFriendButton];
                if ([[_profileDic objectForKey:@"isFollow"] boolValue] &&[[_profileDic objectForKey:@"isFans"] boolValue]) {
                    [_addFriendButton setImage:[UIImage imageNamed:Image_viewprofileImage] forState:UIControlStateNormal];
                    [_attentionButton setImage:[UIImage imageNamed:Image_profilefolloweacherother] forState:UIControlStateNormal];
                    [_attentionButton setFrame:CGRectMake(SCREEN_WIDTH-85, 16, 65, 23)];
                }else if([[_profileDic objectForKey:@"isFollow"] boolValue]){
                    
                    [_addFriendButton setImage:[UIImage imageNamed:Image_viewprofileImage] forState:UIControlStateNormal];
                    [_attentionButton setImage:[UIImage imageNamed:Image_profilefollowed] forState:UIControlStateNormal];
                    [_attentionButton setFrame:CGRectMake(SCREEN_WIDTH-75, 16, 55, 23)];
                }else{
                    
                    [_addFriendButton setImage:[UIImage imageNamed:Image_detailfollowImage] forState:UIControlStateNormal];
                    [_attentionButton setImage:[UIImage imageNamed:Image_profilefollow] forState:UIControlStateNormal];
                    [_attentionButton setFrame:CGRectMake(SCREEN_WIDTH-65, 16, 45, 23)];
                }
                NSArray *dicKeys = [_profileDic allKeys];
                if ([dicKeys containsObject:@"avatar"]) {
                    [_headimage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,[_profileDic objectForKey:@"avatar"]]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        [UIView animateWithDuration:0.5 animations:^{
                            [_headimage setAlpha:1];
                            [_coverImage setAlpha:1];
                        }];
                        
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
                
                if ([[_profileDic allKeys] containsObject:@"genres"] && [[_profileDic objectForKey:@"genres"] count]>0) {
                    genresV = [[UIView alloc] initWithFrame:CGRectMake(97, 55, SCREEN_WIDTH-140, 40)];
                    [cardView addSubview: genresV];
                    int local = 0;
                    int localheight = 0;
                    for (NSDictionary * dic in [_profileDic objectForKey:@"genres"]) {
                        UILabel *tempLabel = [[UILabel alloc ] initWithFrame:CGRectMake(local, localheight, 100, 20)];
                        [tempLabel setFont:[UIFont systemFontOfSize:12]];
                        [tempLabel setText:[dic objectForKey:@"data"]];
                        [tempLabel setTextColor:Color_Text_3];
                        [tempLabel sizeToFit];
                        if (local+ tempLabel.frame.size.width>SCREEN_WIDTH-140) {
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
    _timeStamp = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-130, 15, 96, 9)];
    [_timeStamp setTextColor:Color_Additional_5];
    [_timeStamp setFont:[UIFont fontWithName:Font_Next_medium size:9]];
    _timeStamp.textAlignment = NSTextAlignmentRight;
    
    if ([self.localmuzzik.type isEqualToString:@"repost"]) {
        _repostImage = [[UIImageView alloc] initWithFrame:CGRectMake(66, 36, 8, 8)];
        [_muzzikView addSubview:_repostImage];
        _repostUserName = [[UILabel alloc] initWithFrame:CGRectMake(80, 36, 150, 10)];
        [_repostUserName setTextColor:Color_Additional_5];
        [_repostUserName setFont:[UIFont fontWithName:Font_Next_DemiBold size:8]];
        _repostUserName.text = self.localmuzzik.reposter.name;
        [_muzzikView addSubview:_repostUserName];
        _timeStamp.text = [MuzzikItem transtromTime:self.localmuzzik.repostDate];
    }else{
        _timeStamp.text = [MuzzikItem transtromTime:self.localmuzzik.date];
    }
    
    
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
    temp = [MuzzikItem transformMessage:temp withAt:[MuzzikItem searchUsers:temp] ];
    [_muzzikMessage setText: [MuzzikItem transformMessage:temp withTopics:self.localmuzzik.topics ]];
    _muzzikMessage.delegate = self;
    CXAHyperlinkLabel *label = [[CXAHyperlinkLabel alloc] initWithFrame:CGRectMake(75, 0, SCREEN_WIDTH-110, 500)];
    [label setText:self.localmuzzik.message];
    CGSize msize = [label sizeThatFits:CGSizeMake(SCREEN_WIDTH-110, 2000)];
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
    
    [_playButton addTarget:self action:@selector(playMusicLocal) forControlEvents:UIControlEventTouchUpInside];
    [_muzzikView addSubview:_playButton];
    if ([self.localmuzzik.image length]>0) {
        _poImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/8, CGRectGetMaxY(_progress.frame)+60, SCREEN_WIDTH*3/4, SCREEN_WIDTH*3/4)];
        _poImage.layer.cornerRadius = 3;
        _poImage.clipsToBounds = YES;
        [_poImage  sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?imageView2/1/w/600/h/600",BaseURL_image,self.localmuzzik.image]]];
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
    
    _moves = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH*5)/16.0, _reposts.frame.origin.y, (SCREEN_WIDTH*3)/16.0, 40)];
    [_moves setTitle:@"喜欢数" forState:UIControlStateNormal];
    [_moves setTitleColor:Color_Additional_5 forState:UIControlStateNormal];
    [_moves.titleLabel setFont:[UIFont systemFontOfSize:10.0]];
    [_moves addTarget:self action:@selector(pushMove) forControlEvents:UIControlEventTouchUpInside];
    _moves.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_moves setTitle:[self.localmuzzik.moveds integerValue]>0? [NSString stringWithFormat:@"喜欢数%@",self.localmuzzik.moveds] : @"喜欢数" forState:UIControlStateNormal];
    [_muzzikView addSubview:_moves];
    
    _shares = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, _reposts.frame.origin.y, (SCREEN_WIDTH*3)/16.0, 40)];
    [_shares setTitle:@"分享数" forState:UIControlStateNormal];
    [_shares setTitleColor:Color_Additional_5 forState:UIControlStateNormal];
    [_shares.titleLabel setFont:[UIFont systemFontOfSize:10.0]];
    [_shares addTarget:self action:@selector(pushShare) forControlEvents:UIControlEventTouchUpInside];
    [_shares setTitle:[self.localmuzzik.shares integerValue]>0? [NSString stringWithFormat:@"分享数%@",self.localmuzzik.shares] : @"分享数" forState:UIControlStateNormal];
    _shares.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_muzzikView addSubview:_shares];
    
    _comments = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH*11)/16.0, _reposts.frame.origin.y, (SCREEN_WIDTH*3)/16.0, 40)];
    [_comments setTitle:@"评论数" forState:UIControlStateNormal];
    [_comments setTitleColor:Color_Additional_5 forState:UIControlStateNormal];
    [_comments.titleLabel setFont:[UIFont systemFontOfSize:10.0]];
    [_comments addTarget:self action:@selector(pushComment) forControlEvents:UIControlEventTouchUpInside];
    [_comments setTitle:[self.localmuzzik.comments integerValue]>0? [NSString stringWithFormat:@"评论数%@",self.localmuzzik.comments] : @"评论数" forState:UIControlStateNormal];
    _comments.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_muzzikView addSubview:_comments];
    
    [self colorViewWithColorString:[NSString stringWithFormat:@"%@",self.localmuzzik.color]];
    
    _downLine = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/8,_reposts.frame.origin.y+40, SCREEN_WIDTH*3/4, 1)];
    [_downLine setImage:[UIImage imageNamed:Image_lineImage]];
    [_muzzikView addSubview:_downLine];
    userInfo *user = [userInfo shareClass];
    
    if ([user.uid isEqualToString:self.localmuzzik.MuzzikUser.user_id]) {
        
        _deleMuzzikButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/8,_reposts.frame.origin.y+40, SCREEN_WIDTH*3/16.0, 45)];
        [_deleMuzzikButton setImage:[UIImage imageNamed:Image_detaildeleteImage] forState:UIControlStateNormal];
        [_deleMuzzikButton addTarget:self action:@selector(deleMuzzikAction) forControlEvents:UIControlEventTouchUpInside];
        [_muzzikView addSubview:_deleMuzzikButton];
        
        _repostButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*5/16,_reposts.frame.origin.y+40, SCREEN_WIDTH*3/16.0, 45)];
        [_repostButton setImage:[UIImage imageNamed:Image_detailretweetImage] forState:UIControlStateNormal];
        [_repostButton addTarget:self action:@selector(repostAction) forControlEvents:UIControlEventTouchUpInside];
        [_muzzikView addSubview:_repostButton];
        //[_repostButton setBackgroundColor:Color_Additional_4];
        _shareButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2,_reposts.frame.origin.y+40, SCREEN_WIDTH*3/16.0, 45)];
        [_shareButton setImage:[UIImage imageNamed:Image_detailshareImage] forState:UIControlStateNormal];
        [_shareButton addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
        [_muzzikView addSubview:_shareButton];
        
        _commentButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*11/16,_reposts.frame.origin.y+40, SCREEN_WIDTH*3/16.0, 45)];
        [_commentButton setImage:[UIImage imageNamed:Image_detailreplyImage] forState:UIControlStateNormal];
        [_commentButton addTarget:self action:@selector(commentAction) forControlEvents:UIControlEventTouchUpInside];
        [_muzzikView addSubview:_commentButton];
        commentTitle = [[UIView alloc] initWithFrame:CGRectMake(0, _reposts.frame.origin.y+85, SCREEN_WIDTH, 20)];
        UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, 30, 20)];
        commentLabel.font = [UIFont boldSystemFontOfSize:15];
        commentLabel.textColor = Color_Text_1;
        commentLabel.text = @"评论";
        [commentTitle addSubview:commentLabel];
        [MuzzikItem addLineOnView:commentTitle heightPoint:19 toLeft:16 toRight:16 withColor:Color_line_1];
        [MuzzikItem addLineOnView:commentTitle heightPoint:20 toLeft:16 toRight:16 withColor:Color_line_1];
        
        [_muzzikView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, _reposts.frame.origin.y+105)];
        [muzzikTableView setTableHeaderView:_muzzikView];
    }else{
        _repostButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/8,_reposts.frame.origin.y+40, SCREEN_WIDTH/4.0, 45)];
        [_repostButton setImage:[UIImage imageNamed:Image_detailretweetImage] forState:UIControlStateNormal];
        [_repostButton addTarget:self action:@selector(repostAction) forControlEvents:UIControlEventTouchUpInside];
        [_muzzikView addSubview:_repostButton];
        //[_repostButton setBackgroundColor:Color_Additional_4];
        _shareButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*3/8,_reposts.frame.origin.y+40, SCREEN_WIDTH/4.0, 45)];
        [_shareButton setImage:[UIImage imageNamed:Image_detailshareImage] forState:UIControlStateNormal];
        [_shareButton addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
        [_muzzikView addSubview:_shareButton];
        
        _commentButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*5/8,_reposts.frame.origin.y+40, SCREEN_WIDTH/4.0, 45)];
        [_commentButton setImage:[UIImage imageNamed:Image_detailreplyImage] forState:UIControlStateNormal];
        [_commentButton addTarget:self action:@selector(commentAction) forControlEvents:UIControlEventTouchUpInside];
        [_muzzikView addSubview:_commentButton];
        cardView = [[UIView alloc] initWithFrame:CGRectMake(16, _reposts.frame.origin.y+85, SCREEN_WIDTH-32, 135)];
        cardView.backgroundColor = Color_line_2;
        cardView.layer.cornerRadius = 5;
        cardView.clipsToBounds = YES;
        cardView.layer.borderColor = Color_line_1.CGColor;
        cardView.layer.borderWidth = 1.0f;
        
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
        commentTitle = [[UIView alloc] initWithFrame:CGRectMake(0, _reposts.frame.origin.y+220, SCREEN_WIDTH, 20)];
        UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, 30, 20)];
        commentLabel.font = [UIFont boldSystemFontOfSize:15];
        commentLabel.textColor = Color_Text_1;
        commentLabel.text = @"评论";
        [commentTitle addSubview:commentLabel];
        [MuzzikItem addLineOnView:commentTitle heightPoint:19 toLeft:16 toRight:16 withColor:Color_line_1];
        [MuzzikItem addLineOnView:commentTitle heightPoint:20 toLeft:16 toRight:16 withColor:Color_line_1];
        
        [_muzzikView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, _reposts.frame.origin.y+240)];
        [muzzikTableView setTableHeaderView:_muzzikView];

    }
    
    [self loadComment];
    songView = [[UIView alloc] initWithFrame:CGRectMake(0, 55, SCREEN_WIDTH, 55)];
    songLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 7.5, SCREEN_WIDTH-100, 20)];
    [songLabel setFont:[UIFont fontWithName:Font_Next_DemiBold size:16]];
    songLabel.textColor = Color_Text_1;
    [songView addSubview:songLabel];
    
    artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 27.5, SCREEN_WIDTH-100, 20)];
    [artistLabel setFont:[UIFont fontWithName:Font_Next_DemiBold size:14]];
    artistLabel.textColor = Color_Text_1;
    [songView addSubview:artistLabel];
    deleButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-40, 7.5, 40, 40)];
    [deleButton setImage:[UIImage imageNamed:Image_deletesongImage] forState:UIControlStateNormal];
    [deleButton addTarget:self action:@selector(deleSong) forControlEvents:UIControlEventTouchUpInside];
    [songView addSubview:deleButton];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [Globle shareGloble].isHeadView = YES;
    MuzzikObject *mobject = [MuzzikObject shareClass];
    if ([mobject.music.name length]>0) {
        //已经选择歌曲了
        if (isContainMusic) {
            songLabel.text = mobject.music.name;
            artistLabel.text = mobject.music.artist;
        }
        //尚未选择歌曲
        else{
            isContainMusic = YES;
            [songView setFrame:CGRectMake(0, commentView.frame.size.height, SCREEN_WIDTH, 55)];
            [commentView setFrame:CGRectMake(commentView.frame.origin.x, commentView.frame.origin.y-55, SCREEN_WIDTH, commentView.frame.size.height+55)];
            [commentView addSubview:songView];
            songLabel.text = mobject.music.name;
            artistLabel.text = mobject.music.artist;
            [muzzikTableView setFrame:CGRectMake(muzzikTableView.frame.origin.x, muzzikTableView.frame.origin.y, SCREEN_WIDTH, muzzikTableView.frame.size.height-55)];
            muzzikTableView.contentOffset = CGPointMake(muzzikTableView.contentOffset.x, muzzikTableView.contentOffset.y+55);
            [musicButton setImage:[UIImage imageNamed:Image_detailaddedsongImage] forState:UIControlStateNormal];
            tableOriginRect = CGRectMake(tableOriginRect.origin.x, tableOriginRect.origin.y, tableOriginRect.size.width, tableOriginRect.size.height-55);
            commentViewRect = CGRectMake(commentViewRect.origin.x, commentViewRect.origin.y-55, SCREEN_WIDTH, commentViewRect.size.height+55);
        }
    }
    if ([mobject.tempmessage length]>0) {
        checkPair = YES;
        NSString *temp = [comnentTextView.text stringByAppendingString:[mobject.tempmessage substringFromIndex:1]];
        if ([temp length]>140) {
            [MuzzikItem showNotifyOnView:self.view text:@"发送内容超出140个字符的限制"];
            mobject.tempmessage = nil;
        }else{
            comnentTextView.text = temp;
            mobject.tempmessage = nil;
        }
        
    }
    if ([self.showType isEqualToString:Constant_Comment]) {
        [comnentTextView becomeFirstResponder];
    }else if([self.showType isEqualToString:Constant_showComment]){
        [muzzikTableView setContentOffset:CGPointMake(0, _muzzikView.frame.size.height-SCREEN_WIDTH/2) animated:NO];
    }
    
    [muzzikTableView addFooterWithTarget:self action:@selector(refreshFooter)];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [Globle shareGloble].isHeadView = NO;
    [muzzikTableView removeFooter];

    // [MytableView removeKeyPath];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) loadComment{
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/%@/comments",BaseURL,self.localmuzzik.muzzik_id]]];
    [request addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakre = request;
    [request setCompletionBlock :^{
        NSLog(@"%@",[weakre responseString]);
        NSLog(@"%d",[weakre responseStatusCode]);
        if ([weakre responseStatusCode] == 200) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakre responseData]  options:NSJSONReadingMutableContainers error:nil];
            lastID = [dic objectForKey:@"tail"];
            commentArray = [[muzzik new] makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
            if ([commentArray count]>0) {
                [_muzzikView addSubview:commentTitle];
            }
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
-(void)viewDidScroll:(UIScrollView *)scrollView{
    [super viewDidScroll:scrollView];
    NSLog(@"%f",scrollView.contentOffset.y);
    CGFloat yOffset  = scrollView.contentOffset.y;
    if (yOffset < -SCREEN_WIDTH/2 ) {
        CGRect f = _headimage.frame;
        f.origin.y = yOffset+SCREEN_WIDTH/2;
        f.size.height =  -yOffset;
        _headimage.frame = f;
        
        CGRect cover = _coverImage.frame;
        cover.origin.y = yOffset+SCREEN_WIDTH/2;
        cover.size.height =  -yOffset;
        _coverImage.frame = cover;
        
        CGRect d = _attentionButton.frame;
        d.origin.y = yOffset+SCREEN_WIDTH/2+16;
        
        _attentionButton.frame = d;
    }
}
#warning  播放器控制
//
//-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
//    for (UIView *view in [self.navigationController.view subviews]) {
//        if ([view isKindOfClass:[RFRadioView class]]) {
//            RFRadioView *musicView = (RFRadioView*)view;
//            if (velocity.y>0) {
//                
//                if (musicView.IsShowDetail) {
//                    [musicView rollBack];
//                    musicView.isOpen = NO;
//                    musicView.IsShowDetail = NO;
//                    
//                }else{
//                    musicView.isOpen = NO;
//                    musicView.IsShowDetail = NO;
//                    [UIView animateWithDuration:0.3 animations:^{
//                        [musicView setFrame:CGRectMake(0, -64, SCREEN_WIDTH, 64)];
//                    }];
//                }
//            }
//            else if (velocity.y<0 && [[musicPlayer shareClass].MusicArray count]>0){
//                musicView.isOpen = YES;
//                [UIView animateWithDuration:0.3 animations:^{
//                    [musicView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
//                }];
//            }
//        }
//    }
//    
//}




#pragma -mark tableView Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    muzzik *tempMuzzik = commentArray[indexPath.row];
    CXAHyperlinkLabel *label = [[CXAHyperlinkLabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-140, 2000)];
    label.text = tempMuzzik.message;
    
    [label setFont:[UIFont systemFontOfSize:15]];
    CGSize msize = [label  sizeThatFits:CGSizeMake(SCREEN_WIDTH-140, 2000)];
    
    if ([tempMuzzik.music.key isEqualToString:self.localmuzzik.music.key]) {
        return 70+msize.height-15;
    }else{
        return 95+msize.height-15;
    }
    
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    muzzik *tempMuzzik = commentArray[indexPath.row];
    CommentMuzzikCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentMuzzikCell" forIndexPath:indexPath];
    [cell.userImage sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?imageView2/1/w/100/h/100",BaseURL_image,tempMuzzik.MuzzikUser.avatar]] forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [UIView animateWithDuration:0.5 animations:^{
            [cell.userImage setAlpha:1];
        }];
    }];
    
    cell.delegate = self;
    Globle *glob = [Globle shareGloble];
    BOOL ispalying = false;
    if ([tempMuzzik.muzzik_id isEqualToString:self.musicplayer.localMuzzik.muzzik_id] &&!glob.isPause) {
        ispalying = YES;
    }
    cell.MuzzikModel = tempMuzzik;
    cell.userName.text = tempMuzzik.MuzzikUser.name;
    [cell.userName sizeToFit];
    [cell.privateImage setFrame:CGRectMake(cell.userName.frame.origin.x+cell.userName.frame.size.width+5, cell.userName.frame.origin.y-2, 20, 20)];
    if (tempMuzzik.isprivate ) {
        [cell.privateImage setHidden:NO];
    }else{
        [cell.privateImage setHidden:YES];
    }
    NSString *temp = tempMuzzik.message;
    temp = [MuzzikItem transformMessage:temp withAt:[MuzzikItem searchUsers:temp]];
    
    [cell.message setText: [MuzzikItem transformMessage:temp withTopics:tempMuzzik.topics]];
    CGSize msize = [cell.message sizeThatFits:CGSizeMake(SCREEN_WIDTH-140, 2000)];
    [cell.message setFrame:CGRectMake(cell.message.frame.origin.x, cell.message.frame.origin.y, msize.width, msize.height)];
    cell.timeLabel.text = [MuzzikItem transtromTime:tempMuzzik.date];
    if (![tempMuzzik.music.key isEqualToString:self.localmuzzik.music.key]) {
        [cell.songName setHidden:NO];
        UIColor *color;
        if ([tempMuzzik.color longLongValue] == 1) {
            color = [UIColor colorWithHexString:@"fea42c"];
            if (ispalying) {
                [cell.playButton setImage:[UIImage imageNamed:Image_detailstopyellowImage] forState:UIControlStateNormal];
            }else{
                [cell.playButton setImage:[UIImage imageNamed:Image_detailyellowplay] forState:UIControlStateNormal];
            }
        }
        else if([tempMuzzik.color longLongValue] == 2){
            //bluelikeImage
            color = [UIColor colorWithHexString:@"04a0bf"];
            if (ispalying) {
                [cell.playButton setImage:[UIImage imageNamed:Image_detailstopblueImage] forState:UIControlStateNormal];
            }else{
                [cell.playButton setImage:[UIImage imageNamed:Image_detailblueplay] forState:UIControlStateNormal];
            }
        }
        else{
            color = [UIColor colorWithHexString:@"f26d7d"];
            if (ispalying) {
                [cell.playButton setImage:[UIImage imageNamed:Image_detailstopredImage] forState:UIControlStateNormal];
            }else{
                [cell.playButton setImage:[UIImage imageNamed:Image_detailredplay] forState:UIControlStateNormal];
            }
        }
        [cell.songName setFrame:CGRectMake(66, cell.message.frame.size.height+cell.message.frame.origin.y+16, SCREEN_WIDTH-140, 20)];
        NSMutableAttributedString *attributesText = [[NSMutableAttributedString alloc] init];

        NSAttributedString *item = [MuzzikItem formatAttrItem:tempMuzzik.music.name color:color font:[UIFont boldSystemFontOfSize:15]];
        [attributesText appendAttributedString:item];
        
        NSAttributedString *item1 = [MuzzikItem formatAttrItem:[NSString stringWithFormat:@"  %@",tempMuzzik.music.artist] color:color font:[UIFont boldSystemFontOfSize:13]];
        [attributesText appendAttributedString:item1];
        cell.songName.attributedText = attributesText;
        [cell.lineview setFrame:CGRectMake(16, cell.message.frame.size.height+cell.message.frame.origin.y+42, SCREEN_WIDTH-32, 1)];
    }else{
        [cell.lineview setFrame:CGRectMake(16, cell.message.frame.size.height+cell.message.frame.origin.y+20, SCREEN_WIDTH-32, 1)];
        if (ispalying) {
            [cell.playButton setImage:[UIImage imageNamed:Image_detailstoporangeImage] forState:UIControlStateNormal];
        }else{
            [cell.playButton setImage:[UIImage imageNamed:Image_detailgreyplay] forState:UIControlStateNormal];
        }
        
        [cell.songName setHidden:YES];
    }
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return commentArray.count;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    isComment = YES;
    commentToMuzzik = commentArray[indexPath.row];
    comnentTextView.placeholder = [NSString stringWithFormat:@"回复 %@",commentToMuzzik.MuzzikUser.name];
    [comnentTextView becomeFirstResponder];
    

}
#pragma mark - HOGrowingDelegate
-(void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height{
    CGFloat delta = height-growingTextView.frame.size.height;
    tableOriginRect = CGRectMake(tableOriginRect.origin.x, tableOriginRect.origin.y, tableOriginRect.size.width, tableOriginRect.size.height-delta);
    commentViewRect = CGRectMake(commentViewRect.origin.x, commentViewRect.origin.y-delta, SCREEN_WIDTH, commentViewRect.size.height+delta);
    [songView setFrame:CGRectMake(0, songView.frame.origin.y+delta, SCREEN_WIDTH, 55)];
    [commentView setFrame:CGRectMake(commentView.frame.origin.x, commentView.frame.origin.y-delta, SCREEN_WIDTH, commentView.frame.size.height+delta)];
    [muzzikTableView setFrame:CGRectMake(muzzikTableView.frame.origin.x, muzzikTableView.frame.origin.y, muzzikTableView.frame.size.width, muzzikTableView.frame.size.height-delta)];
    [UIView animateWithDuration:0.2 animations:^{
        muzzikTableView.contentOffset = CGPointMake(muzzikTableView.contentOffset.x, muzzikTableView.contentOffset.y+delta);
    }];
    
}
-(BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView{
    if ([comnentTextView.text length]>0) {
        MuzzikObject *mobject = [MuzzikObject shareClass];
        ASIHTTPRequest *shareRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL,URL_Muzzik_new]]];
        NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
        [requestDic setObject:[NSString stringWithFormat:@"@%@ %@",commentToMuzzik.MuzzikUser.name,comnentTextView.text] forKey:Parameter_message];
        if (mobject.music) {
            NSDictionary *musicDic = [NSDictionary dictionaryWithObjectsAndKeys:mobject.music.key,@"key",mobject.music.name,@"name",mobject.music.artist,@"artist", nil];
            [requestDic setObject:musicDic forKey:@"music"];
        }
        if (mobject.isPrivate) {
            [requestDic setObject:[NSNumber numberWithBool:YES] forKey:@"private"];
        }else{
            [requestDic setObject:[NSNumber numberWithBool:NO] forKey:@"private"];
        }
        [requestDic setObject:commentToMuzzik.muzzik_id forKey:@"reply"];
        [shareRequest addBodyDataSourceWithJsonByDic:requestDic Method:PutMethod auth:YES];
        __weak ASIHTTPRequest *weakShare = shareRequest;
        [shareRequest setCompletionBlock:^{
            NSLog(@"data:%@, status:%d",[weakShare responseString],[weakShare responseStatusCode]);
            if ([weakShare responseStatusCode] == 200) {
                
                comnentTextView.text = @"";
                if (mobject.music) {
                    [self deleSong];
                }

                [mobject clearObject];
                [comnentTextView performSelector:@selector(resignFirstResponder) withObject:nil afterDelay:0.3];
                
                ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/%@/comments",BaseURL,self.localmuzzik.muzzik_id]]];
                [request addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
                __weak ASIHTTPRequest *weakre = request;
                [request setCompletionBlock :^{
                    NSLog(@"%@",[weakre responseString]);
                    NSLog(@"%d",[weakre responseStatusCode]);
                    if ([weakre responseStatusCode] == 200) {
                        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakre responseData]  options:NSJSONReadingMutableContainers error:nil];
                        lastID = [dic objectForKey:@"tail"];
                        commentArray = [[muzzik new] makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
                        if ([commentArray count]>0) {
                            [_muzzikView addSubview:commentTitle];
                            [muzzikTableView reloadData];
                            [muzzikTableView scrollToRowAtIndexPath:
                             [NSIndexPath indexPathForRow:0 inSection:0]
                                                   atScrollPosition: UITableViewScrollPositionBottom
                                                           animated:YES];
                        }
                        
                        
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
        [shareRequest setFailedBlock:^{
            NSLog(@"%@",[weakShare error]);
        }];
        [shareRequest startAsynchronous];
    }else{
         [growingTextView resignFirstResponder];
    }
    return YES;
}

-(void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView{
    if ([growingTextView.text length]<138-[commentToMuzzik.MuzzikUser.name length]) {
        if (growingTextView.text.length> commentText.length) {
            NSString *temp = [growingTextView.text substringFromIndex:[growingTextView.text length]-1];
            if ([temp isEqualToString:@"@"] || [temp isEqualToString:@"＠"]) {
                FriendVC *friendvc = [[FriendVC alloc] init];
                [self.navigationController pushViewController:friendvc animated:YES];
            }else if([temp isEqualToString:@"#"] || [temp isEqualToString:@"＃"]){
                if (checkPair) {
                    checkPair = !checkPair;
                }else{
                    TopicHotVC *topicvc = [[TopicHotVC alloc] init];
                    [self.navigationController pushViewController:topicvc animated:YES];
                }
                
            }
        }
        commentText = growingTextView.text;
    }
    else{
        growingTextView.internalTextView.text = [growingTextView.text substringToIndex:138-[commentToMuzzik.MuzzikUser.name length]];
    }
    
   
}
#pragma mark - action
-(void)PrivateAction{
    MuzzikObject *mobject = [MuzzikObject shareClass];
    if (mobject.isPrivate) {
        mobject.isPrivate = !mobject.isPrivate;
        [privateButton setImage:[UIImage imageNamed:Image_detailvisibleImage] forState:UIControlStateNormal];
    }else{
        mobject.isPrivate = !mobject.isPrivate;
        [privateButton setImage:[UIImage imageNamed:Image_detailinvisibleImage] forState:UIControlStateNormal];
    }
}
-(void) colorViewWithColorString:(NSString *) colorString{
    UIColor *color;
    if ([colorString isEqualToString:@"1"]) {
        color = [UIColor colorWithHexString:@"fea42c"];
        [self.repostImage setImage:[UIImage imageNamed:Image_yellowretweetImage]];
        if (self.localmuzzik.ismoved) {
            [self.likeButton setImage:[UIImage imageNamed:@"yellowlikedImage"] forState:UIControlStateNormal];
        }else{
            [self.likeButton setImage:[UIImage imageNamed:@"yellowlikeImage"] forState:UIControlStateNormal];
        }
        if (self.isPlaying) {
            [self.playButton setImage:[UIImage imageNamed:@"yellowstopImage"] forState:UIControlStateNormal];
        }else{
            [self.playButton setImage:[UIImage imageNamed:@"yellowplayImage"] forState:UIControlStateNormal];
        }
    }
    else if([colorString isEqualToString:@"2"]){
        //bluelikeImage
        [self.repostImage setImage:[UIImage imageNamed:Image_blueretweetImage]];
        color = [UIColor colorWithHexString:@"04a0bf"];
        if (self.localmuzzik.ismoved) {
            [self.likeButton setImage:[UIImage imageNamed:@"bluelikedImage"] forState:UIControlStateNormal];
        }else{
            [self.likeButton setImage:[UIImage imageNamed:@"bluelikeImage"] forState:UIControlStateNormal];
        }
        if (self.isPlaying) {
            [self.playButton setImage:[UIImage imageNamed:@"bluestopImage"] forState:UIControlStateNormal];
        }else{
            [self.playButton setImage:[UIImage imageNamed:@"blueplayImage"] forState:UIControlStateNormal];
        }
    }
    else{
        color = [UIColor colorWithHexString:@"f26d7d"];
        [self.repostImage setImage:[UIImage imageNamed:Image_redretweetImage]];
        if (self.localmuzzik.ismoved) {
            [self.likeButton setImage:[UIImage imageNamed:@"redlikedImage"] forState:UIControlStateNormal];
        }else{
            [self.likeButton setImage:[UIImage imageNamed:@"redlikeImage"] forState:UIControlStateNormal];
        }
        if (self.isPlaying) {
            [self.playButton setImage:[UIImage imageNamed:@"redstopImage"] forState:UIControlStateNormal];
        }else{
            [self.playButton setImage:[UIImage imageNamed:@"redplayImage"] forState:UIControlStateNormal];
        }
    }
    [_progress setTintColor:color];
    [_musicArtist setTextColor:color];
    [_musicName setTextColor:color];
}
-(void)attentionAction{
    if ([[_profileDic objectForKey:@"isFollow"] boolValue]) {
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_user_Unfollow]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:self.localmuzzik.MuzzikUser.user_id forKey:@"_id"] Method:PostMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            
            if ([weakrequest responseStatusCode] == 200) {
                [_profileDic setValue:[NSNumber numberWithBool:NO] forKey:@"isFollow"];
                [_addFriendButton setImage:[UIImage imageNamed:Image_detailfollowImage] forState:UIControlStateNormal];
                [_attentionButton setImage:[UIImage imageNamed:Image_profilefollow] forState:UIControlStateNormal];
                [_attentionButton setFrame:CGRectMake(SCREEN_WIDTH-65, 16, 45, 23)];
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
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:self.localmuzzik.MuzzikUser.user_id forKey:@"_id"] Method:PostMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            
            if ([weakrequest responseStatusCode] == 200) {
                [_profileDic setValue:[NSNumber numberWithBool:YES] forKey:@"isFollow"];
                if ([[_profileDic objectForKey:@"isFollow"] boolValue] &&[[_profileDic objectForKey:@"isFans"] boolValue]) {
                    [_addFriendButton setImage:[UIImage imageNamed:Image_viewprofileImage] forState:UIControlStateNormal];
                    [_attentionButton setImage:[UIImage imageNamed:Image_profilefolloweacherother] forState:UIControlStateNormal];
                    [_attentionButton setFrame:CGRectMake(SCREEN_WIDTH-85, 16, 65, 23)];
                }else if([[_profileDic objectForKey:@"isFollow"] boolValue]){
                    
                    [_addFriendButton setImage:[UIImage imageNamed:Image_viewprofileImage] forState:UIControlStateNormal];
                    [_attentionButton setImage:[UIImage imageNamed:Image_profilefollowed] forState:UIControlStateNormal];
                    [_attentionButton setFrame:CGRectMake(SCREEN_WIDTH-75, 16, 55, 23)];
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
}
-(void)attentionOrVisit{
    if ([[_profileDic objectForKey:@"isFollow"] boolValue]) {
        userDetailInfo *uInfo = [[userDetailInfo alloc] init];
        uInfo.uid = self.localmuzzik.MuzzikUser.user_id;
        [self.navigationController pushViewController:uInfo animated:YES];
    }else{
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_User_Follow]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:self.localmuzzik.MuzzikUser.user_id forKey:@"_id"] Method:PostMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            
            if ([weakrequest responseStatusCode] == 200) {
                [_profileDic setValue:[NSNumber numberWithBool:YES] forKey:@"isFollow"];
                if ([[_profileDic objectForKey:@"isFollow"] boolValue] &&[[_profileDic objectForKey:@"isFans"] boolValue]) {
                    [_addFriendButton setImage:[UIImage imageNamed:Image_viewprofileImage] forState:UIControlStateNormal];
                    [_attentionButton setImage:[UIImage imageNamed:Image_profilefolloweacherother] forState:UIControlStateNormal];
                    [_attentionButton setFrame:CGRectMake(SCREEN_WIDTH-85, 16, 65, 23)];
                }else if([[_profileDic objectForKey:@"isFollow"] boolValue]){
                    
                    [_addFriendButton setImage:[UIImage imageNamed:Image_viewprofileImage] forState:UIControlStateNormal];
                    [_attentionButton setImage:[UIImage imageNamed:Image_profilefollowed] forState:UIControlStateNormal];
                    [_attentionButton setFrame:CGRectMake(SCREEN_WIDTH-75, 16, 55, 23)];
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
}
-(void)goToUser{
    userDetailInfo *detailuser = [[userDetailInfo alloc] init];
    detailuser.uid = self.localmuzzik.MuzzikUser.user_id;
    [self.navigationController pushViewController:detailuser animated:YES];
}
-(void)pushRepost{
    showUserVC *showvc = [[showUserVC alloc] init];
    showvc.muzzik_id = self.localmuzzik.muzzik_id;
    showvc.showType = @"repost";
    [self.navigationController pushViewController:showvc animated:YES];
}


-(void)pushMove{
    showUserVC *showvc = [[showUserVC alloc] init];
    showvc.muzzik_id = self.localmuzzik.muzzik_id;
    showvc.showType = @"movesd";
    [self.navigationController pushViewController:showvc animated:YES];
}
-(void)pushShare{
    showUserVC *showvc = [[showUserVC alloc] init];
    showvc.muzzik_id = self.localmuzzik.muzzik_id;
    showvc.showType = @"share";
    [self.navigationController pushViewController:showvc animated:YES];
}
-(void)pushComment{
    [muzzikTableView setContentOffset:CGPointMake(0, muzzikTableView.contentSize.height-SCREEN_WIDTH/2) animated:YES];
    
}
-(void) moveAction{
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
       ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/%@/moved",BaseURL,self.localmuzzik.muzzik_id]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:!self.localmuzzik.ismoved] forKey:@"ismoved"] Method:PostMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            if ([weakrequest responseStatusCode] == 200) {
                // NSData *data = [weakrequest responseData];
                self.localmuzzik.ismoved = !self.localmuzzik.ismoved;
                [self colorViewWithColorString:[NSString stringWithFormat:@"%@",self.localmuzzik.color]];
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
-(void)repostAction{
    
}
-(void)shareAction{
    
}
-(void)commentAction{
    [comnentTextView becomeFirstResponder];
}
-(void)deleMuzzikAction{
    ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString : [NSString stringWithFormat:@"%@api/muzzik/%@",BaseURL,self.localmuzzik.muzzik_id]]];
    [requestForm addBodyDataSourceWithJsonByDic:nil Method:DeleteMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = requestForm;
    [requestForm setCompletionBlock :^{
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"%@",[weakrequest responseString]);
        NSLog(@"%d",[weakrequest responseStatusCode]);
        if ([weakrequest responseStatusCode] == 200 && [[dic objectForKey:@"result"] boolValue]) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    [requestForm setFailedBlock:^{
        // [SVProgressHUD showErrorWithStatus:@"network error"];
    }];
    [requestForm startAsynchronous];
}

-(void)playMusicLocal{
    _musicplayer.listType = TempList;
    _musicplayer.MusicArray = [NSMutableArray arrayWithArray:@[self.localmuzzik]];
    [_musicplayer playSongWithSongModel:self.localmuzzik];
    if ([[musicPlayer shareClass].MusicArray count]>0) {
        for (UIView *view in [self.navigationController.view subviews]) {
            if ([view isKindOfClass:[RFRadioView class]]) {
                RFRadioView *musicView = (RFRadioView*)view;
                musicView.isOpen = YES;
                [UIView animateWithDuration:0.3 animations:^{
                    [musicView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
                }];
                break;
            }
        }
    }
}
-(void) sendComment{
    if ([comnentTextView.text length]>0) {
        MuzzikObject *mobject = [MuzzikObject shareClass];
        ASIHTTPRequest *shareRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL,URL_Muzzik_new]]];
        NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
        if (mobject.isPrivate) {
            [requestDic setObject:[NSNumber numberWithBool:YES] forKey:Parameter_private];
        }
        [requestDic setObject:[NSString stringWithFormat:@"@%@ %@",commentToMuzzik.MuzzikUser.name,comnentTextView.text] forKey:Parameter_message];
        if (mobject.music) {
            NSDictionary *musicDic = [NSDictionary dictionaryWithObjectsAndKeys:mobject.music.key,@"key",mobject.music.name,@"name",mobject.music.artist,@"artist", nil];
            [requestDic setObject:musicDic forKey:@"music"];
        }
        if (mobject.isPrivate) {
            [requestDic setValue:[NSNumber numberWithBool:YES] forKey:@"private"];
        }else{
            [requestDic setValue:[NSNumber numberWithBool:NO] forKey:@"private"];
        }
        [requestDic setObject:commentToMuzzik.muzzik_id forKey:@"reply"];
        [shareRequest addBodyDataSourceWithJsonByDic:requestDic Method:PutMethod auth:YES];
        __weak ASIHTTPRequest *weakShare = shareRequest;
        [shareRequest setCompletionBlock:^{
            NSLog(@"data:%@",[weakShare responseString]);
            if ([weakShare responseStatusCode] == 200) {
                
                comnentTextView.internalTextView.text = @"";
                if (mobject.music) {
                    [self deleSong];
                }
                [mobject clearObject];
                [comnentTextView performSelector:@selector(resignFirstResponder) withObject:nil afterDelay:0.3];
                
                ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/%@/comments",BaseURL,self.localmuzzik.muzzik_id]]];
                [request addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:NO];
                __weak ASIHTTPRequest *weakre = request;
                [request setCompletionBlock :^{
                    NSLog(@"%@",[weakre responseString]);
                    NSLog(@"%d",[weakre responseStatusCode]);
                    if ([weakre responseStatusCode] == 200) {
                        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakre responseData]  options:NSJSONReadingMutableContainers error:nil];
                        commentArray = [[muzzik new] makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
                        if ([commentArray count]>0) {
                            [_muzzikView addSubview:commentTitle];
                        }
                        [muzzikTableView reloadData];
                        [muzzikTableView scrollToRowAtIndexPath:
                         [NSIndexPath indexPathForRow:0 inSection:0]
                                               atScrollPosition: UITableViewScrollPositionBottom
                                                       animated:YES];
                        
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
        [shareRequest setFailedBlock:^{
            NSLog(@"%@",[weakShare error]);
        }];
        [shareRequest startAsynchronous];
    }
   

}
-(void)deleSong{
    [musicButton setImage:[UIImage imageNamed:Image_detailaddsongImage] forState:UIControlStateNormal];
    isContainMusic = NO;
    MuzzikObject *mobject = [MuzzikObject shareClass];
    mobject.music = nil;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [songView setFrame:CGRectMake(0, commentView.frame.size.height+55, 0, 0)];
    [commentView setFrame:CGRectMake(commentView.frame.origin.x, commentView.frame.origin.y+55, SCREEN_WIDTH, commentView.frame.size.height-55)];
    [muzzikTableView setFrame:CGRectMake(muzzikTableView.frame.origin.x, muzzikTableView.frame.origin.y, SCREEN_WIDTH, muzzikTableView.frame.size.height+55)];
    [musicButton setImage:[UIImage imageNamed:Image_detailaddsongImage] forState:UIControlStateNormal];
    tableOriginRect = CGRectMake(tableOriginRect.origin.x, tableOriginRect.origin.y, tableOriginRect.size.width, tableOriginRect.size.height+55);
    commentViewRect = CGRectMake(commentViewRect.origin.x, commentViewRect.origin.y+55, SCREEN_WIDTH, commentViewRect.size.height-55);
    //    [self reloadChatTable];
    [UIView commitAnimations];
}
-(void) selectMusic{
    ChooseMusicVC *choosevc = [[ChooseMusicVC alloc] init];
    choosevc.comeInType = @"comment";
    [self.navigationController pushViewController:choosevc animated:YES];
}
-(void)userDetail:(NSString *)user_id{
    userDetailInfo *detailuser = [[userDetailInfo alloc] init];
    detailuser.uid = user_id;
    [self.navigationController pushViewController:detailuser animated:YES];
    
    
}

-(void)playnextMuzzikUpdate{
    Globle *glob = [Globle shareGloble];
    if ([[musicPlayer shareClass].localMuzzik.muzzik_id isEqualToString:self.localmuzzik.muzzik_id]&&!glob.isPause) {
        self.isPlaying = YES;
    }else{
        self.isPlaying = NO;
    }
    [self colorViewWithColorString:[NSString stringWithFormat:@"%@",self.localmuzzik.color]];
    [muzzikTableView reloadData];
}
- (void)refreshFooter
{
    // [self updateSomeThing];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/%@/comments",BaseURL,self.localmuzzik.muzzik_id]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:lastID,Parameter_from,Limit_Constant,Parameter_Limit, nil] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        // NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            muzzik *muzzikToy = [muzzik new];
            [commentArray addObjectsFromArray:[muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]]];
            lastID = [dic objectForKey:@"tail"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [muzzikTableView reloadData];
                [muzzikTableView footerEndRefreshing];
                if ([[dic objectForKey:@"muzziks"] count]<[Limit_Constant integerValue] ) {
                    [muzzikTableView removeFooter];
                }
            });
            
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
    }];
    [request startAsynchronous];
    
}
#pragma mark - 监听键盘高度改变事件

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    //
    CGRect newTableFrame = tableOriginRect;
    newTableFrame.size.height += -keyboardRect.size.height;
    

    
    CGRect newInputFieldFrame = commentViewRect;
    newInputFieldFrame.origin.y += -keyboardRect.size.height;
    
    
    // 键盘的动画时间，设定与其完全保持一致
    NSNumber *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];

    if ([animationDurationValue doubleValue]  < 0.05) {
        //不用动画
        muzzikTableView.frame = newTableFrame;
        commentView.frame = newInputFieldFrame;
        [self reloadChatTable];
        return;
    }
    
    
    NSNumber *num = [NSNumber new];
    [animationDurationValue getValue:(__bridge void *)(num)];
    
    
    // 键盘的动画是变速的，设定与其完全保持一致
    NSNumber *animationCurveObject = [userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // 开始及执行动画
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[animationDurationValue doubleValue]];
    [UIView setAnimationCurve:(UIViewAnimationCurve)animationCurveObject];
    
    muzzikTableView.frame = newTableFrame;
    commentView.frame = newInputFieldFrame;
    
    [self reloadChatTable];
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary* userInfo = [notification userInfo];
    
    // 键盘的动画时间，设定与其完全保持一致
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // 键盘的动画是变速的，设定与其完全保持一致
    NSValue *animationCurveObject =[userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey];
    NSUInteger animationCurve;
    [animationCurveObject getValue:&animationCurve];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:(UIViewAnimationCurve)animationCurve];
    
    commentView.frame = commentViewRect;
    muzzikTableView.frame = tableOriginRect;
    [UIView commitAnimations];
}

-(void)reloadChatTable
{
    
    CGPoint contentOffsetPoint = muzzikTableView.contentOffset;
    CGRect frame = muzzikTableView.frame;
    if (fabs(contentOffsetPoint.y - muzzikTableView.contentSize.height - frame.size.height) < 15.0 || muzzikTableView.contentSize.height < frame.size.height || !firstLoad ||frame.size.height != tableOriginRect.size.height)
    {
        firstLoad = YES;
        if (!isComment) {
            [muzzikTableView setContentOffset:CGPointMake(0, _muzzikView.frame.size.height-SCREEN_WIDTH/2) animated:NO];
        }else{
            [muzzikTableView scrollToRowAtIndexPath:
             [NSIndexPath indexPathForRow:[commentArray indexOfObject:commentToMuzzik]  inSection:0]
                                   atScrollPosition: UITableViewScrollPositionBottom
                                           animated:YES];
        }
        
//        if ([commentArray count]>0) {
//            [muzzikTableView scrollToRowAtIndexPath:
//             [NSIndexPath indexPathForRow:[commentArray count]-1 inSection:0]
//                                   atScrollPosition: UITableViewScrollPositionBottom
//                                           animated:YES];
//        }
//        else{
//            [muzzikTableView setContentOffset:CGPointMake(0, _muzzikView.frame.size.height-SCREEN_WIDTH/2) animated:YES];
//        }
        
    }
}

#pragma mark - 后退
-(void)tapAction:(UITapGestureRecognizer *)tap{
    
    MuzzikObject *mobject = [MuzzikObject shareClass];
    [mobject clearObject];
    [super tapAction:tap];
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
#pragma -mark cellDelegate
-(void)playSongWithSongModel:(muzzik *)songModel{
    _musicplayer.listType = TempList;
    _musicplayer.MusicArray = [NSMutableArray arrayWithArray:@[songModel]];
    [_musicplayer playSongWithSongModel:songModel];
    if ([[musicPlayer shareClass].MusicArray count]>0) {
        for (UIView *view in [self.navigationController.view subviews]) {
            if ([view isKindOfClass:[RFRadioView class]]) {
                RFRadioView *musicView = (RFRadioView*)view;
        musicView.isOpen = YES;
        [UIView animateWithDuration:0.3 animations:^{
            [musicView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
        }];
                break;
            }
        }
    }
    
    

}
@end
