//
//  specialOfferListCollectionViewController.h
//  ShopUU
//
//  Created by 林清泽 on 15/1/8.
//  Copyright (c) 2015年 IOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMScrollingNavbarViewController.h"
#import "CXAHyperlinkLabel.h"
#import "AudioPlayer.h"
#import "RFRadioView.h"
#import "musicPlayer.h"
#import "RootViewController.h"
#import "WXApiObject.h"




@interface muzzikTrendController : AMScrollingNavbarViewController<UITableViewDataSource,UITableViewDelegate,UICollectionViewDelegateFlowLayout,CXDelegate>{
     AudioPlayer* audioPlayer;
    NSInteger isPlayBack;
    
}
@property(weak,nonatomic) RootViewController *homeNav;
@property(nonatomic) NSMutableArray *muzziks;
@property(nonatomic) musicPlayer *musicplayer;
@property(nonatomic) NSString *topicName;
@property(nonatomic) NSURL *imageURL;
-(void)playSongWithSongModel:(muzzik *)songModel;
-(void)downMusicWithModel:(muzzik *)model;
-(void)moveMuzzikWithId:(NSString *)muzzik_id isMoved:(BOOL) ismoved atIndex:(NSInteger) index;
-(void)repostActionWithMuzzik_id:(NSString *)muzzik_id atIndex:(NSInteger) index;
-(void)shareActionWithMuzzik_id:(NSString *)muzzik_id atIndex:(NSInteger) index;

-(void)reloadMuzzikSource;

-(void) commentAtMuzzik:(NSString *)muzzik_id;
-(void) showRepost:(NSString *)muzzik_id;
-(void) showShare:(NSString *)muzzik_id;
-(void) showComment:(NSString *)muzzik_id;
-(void) showMoved:(NSString *)muzzik_id;
@end
