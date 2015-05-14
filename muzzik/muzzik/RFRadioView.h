//
//  RFRadioView.h
//  RadioFree
//
//  Created by zhaojianguo-PC on 14-5-23.
//  Copyright (c) 2014年 xiaozi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FSPlaylistItem;
@class RFRadioView;
@class FMLrcView;
#import "AudioPlayer.h"
#import "muzzik.h"

@protocol RFRadioViewDelegate <NSObject>
-(void)radioView:(RFRadioView *)view musicStop:(NSInteger)playModel;
-(void)radioView:(RFRadioView *)view preSwitchMusic:(UIButton *)pre;
-(void)radioView:(RFRadioView *)view nextSwitchMusic:(UIButton *)next;
-(void)radioView:(RFRadioView *)view playListButton:(UIButton *)btn;
-(void)radioView:(RFRadioView *)view downLoadButton:(UIButton *)btn;
@end
@interface RFRadioView : UIView<AudioPlayerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate>
{
    
    NSTimer *_progressUpdateTimer;
    NSTimer *_playbackSeekTimer;
    double _seekToPoint;
    BOOL _paused;
    
    UILabel *_currentPlaybackTime;
    UILabel * _totalPlaybackTime;
    
    UIButton * _playButton;
    UIButton * _preButton;
    UIButton * _nextButton;
    UIButton * _playbackButton;
    UIButton * _playListButton;
    UIButton * _collectButton;
    UIButton * downLoadButton;
    
    UILabel * noLrcLabel;
    
    BOOL isPlaying;
    BOOL isPasue;
    BOOL isLrc;
    
    NSInteger isPlayBack;
    
    id <RFRadioViewDelegate>delegate;
    
    FMLrcView * lrcView;
    UIImageView * backImageView;
        
   AudioPlayer* audioPlayer;
    
    //new
    UIButton *showButton;
    UILabel *songName;
    UILabel *artistName;
    UIButton *playButton;
    NSMutableArray *playList;
//    UILabel *titleLabel;
    UIImageView *headerImage;
    UIButton *attentionButton;
    UILabel *nickLabel;
    UIPageControl *pagecontrol;
    UIScrollView *Scroll;
    UICollectionView *lyricCollectionview;
//    UILabel *timeLabel;
    UIButton *commentButton;
    UIButton *movedButton;
    UIButton *playModel;
    UIButton *shareButton;
    UIButton *closeButton;
    UIView *detailView;
    UISlider *slider;
    UILabel *message;
    
}
@property (nonatomic,retain) NSMutableArray *lyricArray;
@property (nonatomic) BOOL IsShowDetail;
@property (nonatomic) BOOL isOpen;
@property (nonatomic,strong) FSPlaylistItem *selectedPlaylistItem;
@property (nonatomic,assign) id <RFRadioViewDelegate>delegate;
@property (nonatomic,strong) UIButton * downLoadButton;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic, strong) UISlider *progress;
@property (nonatomic,retain) muzzik *playMuzzik;
@property (nonatomic,copy) NSURL *musicUrl;
-(void)playButtonEvent;
-(void)setRadioViewLrc;
-(void) rollBack;
@end
