//
//  RFRadioView.m
//  RadioFree
//
//  Created by zhaojianguo-PC on 14-5-23.
//  Copyright (c) 2014年 xiaozi. All rights reserved.
//
#import "appConfiguration.h"
#import "RFRadioView.h"
#import "FSPlaylistItem.h"
#import "UIView+Additions.h"
//#import "Globle.h"
#import "Cell.h"
#import "LineLayout.h"
#import "FMLrcView.h"
#import "UIImageView+WebCache.h"
#import "FSAudioStream.h"
#import <AVFoundation/AVFoundation.h>
#import "UIColor+HexColor.h"
#import "UIImageView+WebCache.h"
#import "CXAHyperlinkLabel.h"
@implementation RFRadioView
@synthesize delegate = _delegate;
@synthesize selectedPlaylistItem = _selectedPlaylistItem;
@synthesize downLoadButton;

-(NSMutableArray *)lyricArray{
    if (!_lyricArray) {
        _lyricArray = [NSMutableArray array];
    }
    return _lyricArray;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
       
        
        //后台播放音频设置
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackgroundControlRadioStatus:) name:String_StatusNotifiation object:nil];
        
//        audioController = [[FSAudioController alloc] init];
        audioPlayer = [AudioPlayer shareClass];
        audioPlayer.delegate = self;

        
        //[self addSubview:_currentPlaybackTime];
        
        showButton = [[UIButton alloc] initWithFrame:CGRectMake(13, 31, 20, 20)];
        [showButton setImage:[UIImage imageNamed:@"controlImage"] forState:UIControlStateNormal];
        [showButton addTarget:self action:@selector(showFullPlayer:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview: showButton];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 30,SCREEN_WIDTH-80, 20)];
        _titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [_titleLabel setTextColor:[UIColor whiteColor]];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = @"播放歌曲";
        [_titleLabel setAlpha:0];
        [self addSubview:_titleLabel];
        //[self addSubview:_titleLabel];
        playButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 32, 31, 20, 20)];
        [playButton setImage:[UIImage imageNamed:@"playImage"] forState:UIControlStateNormal];
        [playButton addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:playButton];
        
        self.clipsToBounds = YES;
        detailView = [[UIView alloc] initWithFrame:CGRectMake(0, 55, SCREEN_WIDTH, 320)];
        [self addSubview:detailView];
        headerImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-37, 10, 75, 75)];
        headerImage.layer.cornerRadius = 38;
        headerImage.clipsToBounds = YES;
        [detailView addSubview:headerImage];
        attentionButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2+12, 60, 25, 25)];
        [attentionButton addTarget:self action:@selector(attentionAction) forControlEvents:UIControlEventTouchUpInside];
        [attentionButton setImage:[UIImage imageNamed:@"followImage"] forState:UIControlStateNormal];
        [detailView addSubview:attentionButton];
        nickLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, SCREEN_WIDTH, 30)];
        [nickLabel setTextColor:[UIColor whiteColor]];
        [nickLabel setFont:[UIFont fontWithName:Font_Next_Bold size:14]];
        nickLabel.textAlignment = NSTextAlignmentCenter;
        [detailView addSubview:nickLabel];
        pagecontrol = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 125, SCREEN_WIDTH, 10)];
        //page control
        [pagecontrol setCurrentPageIndicatorTintColor:[UIColor colorWithHexString:@"a8acbb"]];
        [pagecontrol setPageIndicatorTintColor:[UIColor colorWithHexString:@"3b4051"]];
        [detailView addSubview:pagecontrol];
        //[pagecontrol setBackgroundColor:[UIColor whiteColor]];
        pagecontrol.numberOfPages = 2;
        Scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 135, SCREEN_WIDTH, 100)];
        Scroll.delegate = self;
        [Scroll setPagingEnabled:YES];
        [Scroll setContentSize:CGSizeMake(SCREEN_WIDTH*2, 100)];
        [detailView addSubview:Scroll];
        message =[[UILabel alloc ] initWithFrame:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, 100)];
        message.textAlignment = NSTextAlignmentCenter;
        message.lineBreakMode = NSLineBreakByCharWrapping;
        message.numberOfLines = 0;
        message.textColor = [UIColor whiteColor];
        [Scroll addSubview:message];
        LineLayout *lineout = [[LineLayout alloc] init];
        lyricCollectionview = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100) collectionViewLayout:lineout];
        [Scroll addSubview:lyricCollectionview];
        lyricCollectionview.delegate = self;
        lyricCollectionview.dataSource = self;
        [lyricCollectionview setBackgroundColor:[UIColor clearColor]];
        [lyricCollectionview registerClass:[Cell class] forCellWithReuseIdentifier:@"MY_CELL"];
        
        
        
        _progress = [[UISlider alloc] initWithFrame:CGRectMake(15, 260, SCREEN_WIDTH-65, 20)];
        _progress.continuous = NO;
        
        _progress.minimumTrackTintColor = [UIColor colorWithRed:244.0f/255.0f green:147.0f/255.0f blue:23.0f/255.0f alpha:1.0f];
        _progress.maximumTrackTintColor = [UIColor lightGrayColor];
        [_progress setThumbImage:[UIImage imageNamed:@"forwardImage"] forState:UIControlStateNormal];
        [_progress addTarget:self action:@selector(progressChange:) forControlEvents:UIControlEventValueChanged];
        [detailView addSubview: _progress];
        
        _currentPlaybackTime = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-50 , 262, 50, 15)];
       // [_currentPlaybackTime setBackgroundColor:[UIColor whiteColor]];
        UIFont *font = [UIFont systemFontOfSize:7];
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
        NSString *itemStr = @"00:00";
        NSAttributedString *item = [MuzzikItem formatAttrItem:itemStr color:[UIColor colorWithHexString:@"a8acbb"] font:font];
        [text appendAttributedString:item];
        NSString *itemStr1 = @"/00:00";
        NSAttributedString *item1 = [MuzzikItem formatAttrItem:itemStr1 color:[UIColor colorWithHexString:@"366ab3"] font:font];
        [text appendAttributedString:item1];
        _currentPlaybackTime.attributedText = text;
        [detailView addSubview:_currentPlaybackTime];
        
        movedButton =[[UIButton alloc] initWithFrame:CGRectMake(15, 300, 30, 30)];
        [movedButton setImage:[UIImage imageNamed:@"redlikeImage"] forState:UIControlStateNormal];
        [movedButton addTarget:self action:@selector(moveAction) forControlEvents:UIControlEventTouchUpInside];
        [detailView addSubview:movedButton];
        
        
        
//        UISlider *slider = [[UISlider alloc ] initWithFrame:CGRectMake(10, 20, 300, 20)];
//        [slider addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventValueChanged];
//        [self addSubview:slider];
        closeButton = [[UIButton alloc] init];
        shareButton = [[UIButton alloc] init];
        playModel = [[UIButton alloc] init];
        commentButton = [[UIButton alloc] init];
        
       
        songName = [[UILabel alloc] init];
        artistName = [[UILabel alloc] init];
         [songName setFrame:CGRectMake(60, 25, SCREEN_WIDTH -120, 15)];
        [songName setTextColor:[UIColor whiteColor]];
        [songName setFont:[UIFont boldSystemFontOfSize:16]];
        [self addSubview:songName];
        artistName.frame=CGRectMake(60, 41, SCREEN_WIDTH -120, 15);
        artistName.adjustsFontSizeToFitWidth = YES;
        [artistName setFont:[UIFont boldSystemFontOfSize:12]];
        [artistName setTextColor:[UIColor whiteColor]];
        [self addSubview:artistName];
        [self layoutSubviews];
        
        
        [self setNeedsLayout];
    }
    return self;
}
-(void) rollBack{
    [_titleLabel setAlpha:0];
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation2.duration = 0.3; // 持续时间
    animation2.removedOnCompletion = YES;
    animation2.autoreverses = NO;
    animation2.fillMode = kCAFillModeForwards;
    animation2.repeatCount = 1; // 重复次数
    animation2.fromValue = [NSNumber numberWithFloat:M_PI_4]; // 起始角度
    animation2.toValue = [NSNumber numberWithFloat:0.0]; // 终止角度
    [showButton.layer addAnimation:animation2 forKey:@"rotate-layer"];
    showButton.transform = CGAffineTransformMakeRotation(0);
    [showButton.layer addAnimation:animation2 forKey:@"move-rotate-layer"];
    [UIView animateWithDuration:0.3 animations:^{
        [self setFrame:CGRectMake(0, -64, SCREEN_WIDTH, 64)];
    }completion:^(BOOL finished) {
        [playButton setFrame:CGRectMake(SCREEN_WIDTH - 32, 31, 20, 20)];
    }];
    [songName setFrame:CGRectMake(60, 25, SCREEN_WIDTH -120, 15)];
    [self addSubview:songName];
    artistName.frame=CGRectMake(60,41, SCREEN_WIDTH -120, 15);
    [self addSubview:artistName];
    
    [playButton setFrame:CGRectMake(SCREEN_WIDTH - 32, 31, 20, 20)];
    [playButton setImage:[UIImage imageNamed:@"playImage"] forState:UIControlStateNormal];
    //[playButton addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:playButton];
}
-(void)layoutSubviews{
    if (_isOpen) {
        if (!_IsShowDetail) {
            [UIView animateWithDuration:0.3 animations:^{
                [_titleLabel setAlpha:0];
                [self setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
            }completion:^(BOOL finished) {
                [playButton setFrame:CGRectMake(SCREEN_WIDTH - 32, 31, 20, 20)];
            }];
            [songName setFrame:CGRectMake(60, 25, SCREEN_WIDTH -120, 15)];
            [self addSubview:songName];
            artistName.frame=CGRectMake(60, 41, SCREEN_WIDTH -120, 15);
            [self addSubview:artistName];
            [playButton setFrame:CGRectMake(SCREEN_WIDTH - 32, 31, 20, 20)];
            [playButton setImage:[UIImage imageNamed:@"playImage"] forState:UIControlStateNormal];
            //[playButton addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:playButton];
        }else{
            
            [UIView animateWithDuration:0.1 animations:^{
                [playButton setAlpha:0];
            } completion:^(BOOL finished) {
                [playButton setImage:[UIImage imageNamed:@"bluecircleplayImage"] forState:UIControlStateNormal];
                [playButton setAlpha:1];
                [playButton setFrame:CGRectMake(SCREEN_WIDTH-42, 300, 30, 30)];
                [detailView addSubview: playButton];
            }];
            
            [UIView animateWithDuration:0.3 animations:^{
                [_titleLabel setAlpha:1];
//                [playButton setFrame:CGRectMake(SCREEN_WIDTH - 32, 231, 20, 20)];
                [songName setFrame:CGRectMake(60, 355, SCREEN_WIDTH -120, 15)];
                
                artistName.frame = CGRectMake(60, 371, SCREEN_WIDTH -120, 15);
                
                [self setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 430)];
            //    [self ]
            }];
        }

    }
}

-(void) showFullPlayer:(UIButton *) sender{
    if (_IsShowDetail) {
        CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation2.duration = 0.3; // 持续时间
        animation2.removedOnCompletion = YES;
        animation2.autoreverses = NO;
        animation2.fillMode = kCAFillModeForwards;
        animation2.repeatCount = 1; // 重复次数
        animation2.fromValue = [NSNumber numberWithFloat:M_PI_4]; // 起始角度
        animation2.toValue = [NSNumber numberWithFloat:0.0]; // 终止角度
        [showButton.layer addAnimation:animation2 forKey:@"rotate-layer"];
        showButton.transform = CGAffineTransformMakeRotation(0);
        [showButton.layer addAnimation:animation2 forKey:@"move-rotate-layer"];
    }else{
        CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation2.duration = 0.3; // 持续时间
        animation2.removedOnCompletion = YES;
        animation2.autoreverses = NO;
        animation2.fillMode = kCAFillModeForwards;
        animation2.repeatCount = 1; // 重复次数
        animation2.fromValue = [NSNumber numberWithFloat:0.0]; // 起始角度
        animation2.toValue = [NSNumber numberWithFloat:M_PI_4]; // 终止角度
        [showButton.layer addAnimation:animation2 forKey:@"rotate-layer"];
        showButton.transform = CGAffineTransformMakeRotation(M_PI_4);
        [showButton.layer addAnimation:animation2 forKey:@"move-rotate-layer"];
    }
   
//    CABasicAnimation *monkeyAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
//    monkeyAnimation.toValue = [NSNumber numberWithFloat:0.25 *M_PI];
//    monkeyAnimation.duration = 0.5f;
//    monkeyAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
//    monkeyAnimation.cumulative = NO;
//    monkeyAnimation.removedOnCompletion = YES; //No Remove
//
//    [showButton.layer addAnimation:monkeyAnimation forKey:@"AnimatedKey"];
//    showButton.layer.speed = 0.5;
//    showButton.layer.beginTime = 0.0;
    _IsShowDetail = !_IsShowDetail;
    [self setNeedsLayout];
}

-(void)setRadioViewLrc
{
        noLrcLabel.text = @"无歌词";
        [lrcView scrollViewClearSubView];
        [lrcView selfClearKeyAndTitle];
        isLrc = NO;
}
-(void)playButtonEvent
{
    Globle *glob = [Globle shareGloble];
    if (glob.isPlaying) {
        glob.isPlaying = NO;
    }else{
        glob.isPlaying = YES;
    }
    if (audioPlayer.state == AudioPlayerStatePaused){
        [audioPlayer resume];
        [self startTimer];
        backImageView.layer.speed = 0.2;
        CFTimeInterval pausedTime = [backImageView.layer timeOffset];
        CFTimeInterval timeSincePause = [backImageView.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
        backImageView.layer.beginTime = timeSincePause;
        
    }
    else{
        [audioPlayer pause];
        [_progressUpdateTimer invalidate];
        CFTimeInterval pausedTime = [backImageView.layer convertTime:CACurrentMediaTime() fromLayer:nil];
        backImageView.layer.speed = 0.0;
        backImageView.layer.timeOffset = pausedTime;

    }
    [playButton setImage:glob.isPlaying?[UIImage imageNamed:@"stopImage"]:[UIImage imageNamed:@"playImage"] forState:UIControlStateNormal];

}
//-(void)playBackButtonEvent
//{
//    isPlayBack+=1;
//    NSString * name = nil;
//    NSString * title = nil;
//    switch (isPlayBack) {
//        case 0:
//            name = @"order.png";
//            title = @"顺序播放";
//            break;
//        case 1:
//            name = @"random.png";
//            title = @"随机播放";
//            break;
//        case 2:
//            name = @"lock.png";
//            title = @"单曲播放";
//            isPlayBack=-1;
//            break;
//        default:
//            break;
//    }
//    [_playbackButton setImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
//
//}

-(void)preButtonEvent:(UIButton *)btn
{
    [self stopEverything];
    [_delegate radioView:self preSwitchMusic:btn];
}

-(void)nextButtonEvent:(UIButton *)btn
{
    [self stopEverything];
    [_delegate radioView:self nextSwitchMusic:btn];
}
-(void)playListButtonEvent:(UIButton *)btn
{
    [_delegate radioView:self playListButton:btn];
}
-(void)downLoadButtonEvent:(UIButton *)btn
{
    self.downLoadButton.enabled = NO;
   [_delegate radioView:self downLoadButton:btn];
}
-(void)collectButtonEvent:(UIButton *)btn
{
    
    
}
-(void)startTimer
{
    _progressUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                            target:self
                                                          selector:@selector(updatePlaybackProgress)
                                                          userInfo:nil
                                                           repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_progressUpdateTimer forMode:NSRunLoopCommonModes];
}
-(void)startMusic
{
    
    NSLog(@"%@",self.playMuzzik.music.name);
    [audioPlayer play:self.musicUrl];
}

-(NSAttributedString*)TimeformatFromSeconds:(int)seconds total:(int)total
{
    int totalm = seconds/(60);
    int totalConstant = total/(60);
    
    int th = totalConstant/(60);
    int h = totalm/(60);
    
    int tm = totalConstant%(60);
    int m = totalm%(60);
    
    int ts = total%(60);
    int s = seconds%(60);
    UIFont *font = [UIFont systemFontOfSize:7];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
    NSString *itemStr;
    
    NSString *itemStr1;
    
    
    if (h==0) {
        itemStr = [NSString stringWithFormat:@"%02d:%02d", m, s];
    }
    else{
        itemStr = [NSString stringWithFormat:@"%02d:%02d:%02d", h, m, s];
    }
    NSAttributedString *item = [MuzzikItem formatAttrItem:itemStr color:[UIColor colorWithHexString:@"a8acbb"] font:font];
    [text appendAttributedString:item];
    
    if (th==0) {
        itemStr1 = [NSString stringWithFormat:@"/%02d:%02d", tm, ts];
    }
    else{
        itemStr1 = [NSString stringWithFormat:@"/%02d:%02d:%02d", th, tm, ts];
    }
    if ([self.lyricArray count]>0) {
        for (NSDictionary *dic in self.lyricArray) {
            if ([[[dic allKeys] objectAtIndex:0] isEqualToString:itemStr]) {
                [self performSelector:@selector(scrolllyric:) withObject:dic afterDelay:1.5];
                
                break;
            }
        }
    }

    NSAttributedString *item1 = [MuzzikItem formatAttrItem:itemStr1 color:[UIColor colorWithHexString:@"366ab3"] font:font];
    [text appendAttributedString:item1];
    return  text;
    
}
-(void)scrolllyric:(NSDictionary *)dic{
    if ([self.lyricArray containsObject:dic]) {
        [lyricCollectionview scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:[self.lyricArray indexOfObject:dic] inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
    }
    
}
-(void)stopEverything
{
    Globle *glob = [Globle shareGloble];
    self.downLoadButton.enabled = NO;
    glob.isPlaying = NO;
    [audioPlayer stop];
#warning 处理歌词
}
-(void)setPlayMuzzik:(muzzik *)playMuzzik{
    self.isOpen = YES;
    [UIView animateWithDuration:0.3 animations:^{
        [self setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    }];
    NSLog(@"%@",[NSString stringWithFormat:@"%@/%@",playMuzzik.music.name,playMuzzik.music.artist]);
    if (!([playMuzzik.muzzik_id isEqualToString:_playMuzzik.muzzik_id]||([playMuzzik.muzzik_id length] == 0 &&[playMuzzik.music.music_id isEqualToString:_playMuzzik.music.music_id]))||([[musicPlayer shareClass].MusicArray count] ==1 && ![playMuzzik.muzzik_id isEqualToString:_playMuzzik.muzzik_id])) {
        [Globle shareGloble].isPause = NO;
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString :[[NSString stringWithFormat:@"%@%@/%@",URL_Lyric_Me,playMuzzik.music.name,playMuzzik.music.artist] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        [requestForm setUseCookiePersistence:NO];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
           // NSLog(@"%@",[weakrequest responseString]);
            //NSLog(@"URL:%@     status:%d",[weakrequest originalURL],[weakrequest responseStatusCode]);
            if ([weakrequest responseStatusCode] == 200) {
                [weakrequest originalURL];
                NSData *data = [weakrequest responseData];
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data  options:NSJSONReadingMutableContainers error:nil];
                if ([[dic objectForKey:@"count"] longValue]>0) {
                    ASIHTTPRequest *lyricRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[[[[dic objectForKey:@"result"] objectAtIndex:0] objectForKey:@"lrc"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                    __weak ASIHTTPRequest *lrcRequest = lyricRequest;
                    [lyricRequest setCompletionBlock:^{
                        NSString *lyric =  [[NSString alloc] initWithData:[lrcRequest responseData]   encoding:NSUTF8StringEncoding];
                        [self parseLrcLine:lyric];
                       // NSLog(@"%@",self.lyricArray);
                       // NSLog(@"%@",[lrcRequest responseString]);
                       // NSLog(@"URL:%@     status:%d",[lrcRequest originalURL],[lrcRequest responseStatusCode]);
                    }];
                    [lyricRequest setFailedBlock:^{
                        NSLog(@"%@",lrcRequest.error);
                    }];
                    [lyricRequest startAsynchronous];
                }
                else{
                    ASIHTTPRequest *requestForm1 = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString :[[NSString stringWithFormat:@"%@%@",URL_Lyric_Me,playMuzzik.music.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                    [requestForm1 setUseCookiePersistence:NO];
                    __weak ASIHTTPRequest *weakrequest1 = requestForm1;
                    [requestForm1 setCompletionBlock :^{
                      //  NSLog(@"%@",[weakrequest1 responseString]);
                       // NSLog(@"URL:%@     status:%d",[weakrequest1 originalURL],[weakrequest1 responseStatusCode]);
                        if ([weakrequest1 responseStatusCode] == 200) {
                            [weakrequest1 originalURL];
                            NSData *data = [weakrequest1 responseData];
                            NSDictionary *dic1 = [NSJSONSerialization JSONObjectWithData:data  options:NSJSONReadingMutableContainers error:nil];
                            if ([[dic1 objectForKey:@"count"] longValue]>0) {
                                ASIHTTPRequest *lyricRequest1 = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[[[[dic1 objectForKey:@"result"] objectAtIndex:0] objectForKey:@"lrc"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                                __weak ASIHTTPRequest *lrcRequest1 = lyricRequest1;
                                [lyricRequest1 setCompletionBlock:^{
                                    NSString *lyric =  [[NSString alloc] initWithData:[lrcRequest1 responseData]   encoding:NSUTF8StringEncoding];
                                    [self parseLrcLine:lyric];
                                   // NSLog(@"%@",self.lyricArray);
                                  //  NSLog(@"%@",[lrcRequest1 responseString]);
                                  //  NSLog(@"URL:%@     status:%d",[lrcRequest1 originalURL],[lrcRequest1 responseStatusCode]);
                                }];
                                [lyricRequest1 setFailedBlock:^{
                                    NSLog(@"%@",lrcRequest1.error);
                                }];
                                [lyricRequest1 startAsynchronous];
                            }
                            else{
                                
                            }
                            
                        }
                        else{
                            //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
                        }
                    }];
                    [requestForm1 setFailedBlock:^{
                        NSLog(@"URL:%@     status:%d",[weakrequest originalURL],[weakrequest responseStatusCode]);
                        NSLog(@"  kkk%@",[weakrequest error]);
                    }];
                    [requestForm1 startAsynchronous];
                }
                
            }
            else{
                //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
            }
        }];
        [requestForm setFailedBlock:^{
            NSLog(@"URL:%@     status:%d",[weakrequest originalURL],[weakrequest responseStatusCode]);
            NSLog(@"  kkk%@",[weakrequest error]);
        }];
        [requestForm startAsynchronous];
        _playMuzzik = playMuzzik;
        if ([playMuzzik.message length]>0) {
            message.text = playMuzzik.message;
        }
        
        artistName.text = playMuzzik.music.artist;
        songName.text = playMuzzik.music.name;
        if (playMuzzik.MuzzikUser) {
            nickLabel.text = playMuzzik.MuzzikUser.name;
            [headerImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?imageView2/1/w/100/h/100",BaseURL_image,playMuzzik.MuzzikUser.avatar]]];
        }else{
            userInfo *user = [userInfo shareClass];
            if ([user.token length]>0) {
                [headerImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?imageView2/1/w/100/h/100",BaseURL_image,user.avatar]]];
                nickLabel.text = user.name;
            }else{
                nickLabel.text = @"Muzzik";
                [headerImage setImage:[UIImage imageNamed:@"logo"]];
            }
        }
        
        [self stopEverything];
        [self startMusic];
        [self startTimer];
    }else{
        musicPlayer *player = [musicPlayer shareClass];
        [player play];
    }

}
-(NSString*) parseLrcLine:(NSString *)sourceLineText
{
    [self.lyricArray removeAllObjects];
    if (!sourceLineText || sourceLineText.length <= 0)
        return nil;
    NSArray *array = [sourceLineText componentsSeparatedByString:@"\n"];
    for (int i = 0; i < array.count; i++) {
        NSString *tempStr = [array objectAtIndex:i];
        NSArray *lineArray = [tempStr componentsSeparatedByString:@"]"];
        for (int j = 0; j < [lineArray count]-1; j ++) {
            
            if ([lineArray[j] length] > 8) {
                NSString *str1 = [tempStr substringWithRange:NSMakeRange(3, 1)];
                NSString *str2 = [tempStr substringWithRange:NSMakeRange(6, 1)];
                if ([str1 isEqualToString:@":"] && [str2 isEqualToString:@"."]) {
                    NSString *lrcStr = [lineArray lastObject];
                    NSString *timeStr = [[lineArray objectAtIndex:j] substringWithRange:NSMakeRange(1, 8)];//分割区间求歌词时间
                    //把时间 和 歌词 加入词典
                    NSDictionary *dic = [NSDictionary dictionaryWithObject:lrcStr forKey:[timeStr substringToIndex:5]];
                    [self.lyricArray addObject:dic];
                }
            }
        }
    }
    self.lyricArray = [NSMutableArray arrayWithArray:[self.lyricArray sortedArrayUsingComparator: ^(id obj1, id obj2) {
        NSDictionary *dic1 = (NSDictionary *)obj1;
        NSDictionary *dic2 = (NSDictionary *)obj2;
       // [[dic1 allKeys] objectAtIndex:0]
        if ([[[dic1 allKeys] objectAtIndex:0] compare:[[dic2 allKeys] objectAtIndex:0] options:NSCaseInsensitiveSearch]==NSOrderedAscending) {
            return NSOrderedAscending;//递减
        }
        if ([[[dic1 allKeys] objectAtIndex:0] compare:[[dic2 allKeys] objectAtIndex:0] options:NSCaseInsensitiveSearch]==NSOrderedDescending){
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }]];
    NSArray *larray = [NSArray arrayWithArray:self.lyricArray];
    for (int i = larray.count-1; i>0; i--) {
        NSDictionary *dic = larray[i];
       // NSLog(@"%d",[[[dic allValues][0] stringByTrimmingCharactersInSet:[NSCharacterSet symbolCharacterSet]] length]);
        if ([[[dic allValues][0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0 ) {
            [self.lyricArray removeObjectAtIndex:[larray indexOfObject:dic]];
        }
    }
    [lyricCollectionview reloadData];
    return nil;
}

-(void)applicationDidEnterBackgroundControlRadioStatus:(NSNotification *)notification
{
     NSDictionary *dict = [notification userInfo];
    NSString * string = [dict objectForKey:@"keyStatus"];
    if ([string isEqualToString:@"UIEventSubtypeRemoteControlPause"]) {
        [self playButtonEvent];
    }else if ([string isEqualToString:@"UIEventSubtypeRemoteControlPlay"]){
        [self playButtonEvent];
    }else if ([string isEqualToString:@"UIEventSubtypeRemoteControlPreviousTrack"]){
        [self preButtonEvent:_preButton];
    }else if ([string isEqualToString:@"UIEventSubtypeRemoteControlNextTrack"]){
        [self nextButtonEvent:_nextButton];
    }
}
-(void) seek
{
    if (!audioPlayer)
    {
        return;
    }
    NSLog(@"Slider Changed: %f", _progress.value);
    [audioPlayer seekToTime:_progress.value];
}

-(void) updateControls
{
    Globle *glob = [Globle shareGloble];
    if (audioPlayer.state == AudioPlayerStateStopped) {
        if (glob.isPlaying) {
            [_delegate radioView:self musicStop:isPlayBack];
        }
        glob.isPlaying = NO;
    }else if (audioPlayer.state == AudioPlayerStateReady){
        
    }else if (audioPlayer.state == AudioPlayerStateRunning){
        
    }else if (audioPlayer.state == AudioPlayerStatePlaying){
        glob.isPlaying = YES;
        
    }else if (audioPlayer.state == AudioPlayerStateError){
         [_delegate radioView:self musicStop:isPlayBack];
        glob.isPlaying = YES;
    }
    [playButton setImage:glob.isPlaying&&!glob.isPause?[UIImage imageNamed:@"stopImage"]:[UIImage imageNamed:@"playImage"] forState:UIControlStateNormal];
}
-(void) updatePlaybackProgress
{
    if (!audioPlayer || audioPlayer.duration == 0){
        _progress.value = 0;
        return;
    }
    _progress.minimumValue = 0;
    _progress.maximumValue = audioPlayer.duration;
    
    [_progress setValue:audioPlayer.progress animated:YES];
    _currentPlaybackTime.attributedText =[self TimeformatFromSeconds:audioPlayer.progress total:audioPlayer.duration];
  
}
-(void) updateValue:(UISlider *)sender{
    NSLog(@"%f",sender.value);
}
-(void) audioPlayer:(AudioPlayer*)audioPlayer stateChanged:(AudioPlayerState)state
{
    [self updateControls];
}

-(void) audioPlayer:(AudioPlayer*)audioPlayer didEncounterError:(AudioPlayerErrorCode)errorCode
{
    [self updateControls];
}

-(void) audioPlayer:(AudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId
{
    [self updateControls];
}

-(void) audioPlayer:(AudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId
{
    [self updateControls];
}

-(void) audioPlayer:(AudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(NSObject*)queueItemId withReason:(AudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration
{
    [self updateControls];
}
#pragma -mark  picker委托方法
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return self.lyricArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    Cell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
    cell.label.text =[_lyricArray[indexPath.row] allObjects][0];
    return cell;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sView
{
    NSInteger index = fabs(sView.contentOffset.x) / sView.frame.size.width;
    //NSLog(@"%d",index);
    [pagecontrol setCurrentPage:index];
}

#pragma -mark progress change
-(void)progressChange:(UISlider *) progressSlider{
    [audioPlayer seekToTime:progressSlider.value];
}

-(void)playAction{
    musicPlayer *player = [musicPlayer shareClass];
    [player play];
    [[NSNotificationCenter defaultCenter] postNotificationName:String_SetSongPlayNextNotification object:nil];
}
@end
