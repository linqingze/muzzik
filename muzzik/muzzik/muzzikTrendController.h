//
//  specialOfferListCollectionViewController.h
//  ShopUU
//
//  Created by 林清泽 on 15/1/8.
//  Copyright (c) 2015年 IOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMScrollingNavbarViewController.h"
#import "TTTAttributedLabel.h"
#import "AudioPlayer.h"
#import "TencentOpenAPI/QQApiInterface.h"
#import "musicPlayer.h"
#import "RootViewController.h"
#import "WXApiObject.h"
#import "TencentOpenAPI/QQApiInterface.h"


@interface muzzikTrendController : AMScrollingNavbarViewController<UITableViewDataSource,UITableViewDelegate,TTTAttributedLabelDelegate,CellDelegate,WBHttpRequestDelegate>{
     AudioPlayer* audioPlayer;
    NSInteger isPlayBack;
    
}
@property(nonatomic,retain) NSMutableArray *muzziks;
@property(nonatomic,retain) musicPlayer *musicplayer;
@property (nonatomic,weak) RootViewController *parentRoot;
@property(nonatomic,assign) BOOL isRootSubview;
@end
