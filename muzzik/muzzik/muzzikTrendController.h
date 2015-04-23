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
#import "HostViewController.h"
#import "WXApiObject.h"




@interface muzzikTrendController : AMScrollingNavbarViewController<UITableViewDataSource,UITableViewDelegate,UICollectionViewDelegateFlowLayout,CXDelegate>{
     AudioPlayer* audioPlayer;
    NSInteger isPlayBack;
    
}
@property(nonatomic) NSMutableArray *muzziks;
@property(nonatomic) musicPlayer *musicplayer;
@property(nonatomic) NSString *topicName;
@property(nonatomic) NSURL *imageURL;
-(void)playSongWithSongModel:(muzzik *)songModel;
-(void)downMusicWithModel:(muzzik *)model;
-(void)moveMuzzikWithId:(NSString *)muzzik_id isMoved:(NSString *) ismoved atIndex:(NSInteger) index;
-(void)repostActionWithMuzzik_id:(NSString *)muzzik_id atIndex:(NSInteger) index;
-(void)shareActionWithMuzzik_id:(NSString *)muzzik_id atIndex:(NSInteger) index;
@property(weak,nonatomic) HostViewController *homeNav;
-(void)reloadMuzzikSource;
@end
