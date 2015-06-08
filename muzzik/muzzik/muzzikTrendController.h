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
#import "TencentOpenAPI/QQApi.h"


@interface muzzikTrendController : AMScrollingNavbarViewController<UITableViewDataSource,UITableViewDelegate,TTTAttributedLabelDelegate,CellDelegate,WBHttpRequestDelegate>{
     AudioPlayer* audioPlayer;
    NSInteger isPlayBack;
    
}
@property(nonatomic) NSMutableArray *muzziks;
@property(nonatomic) musicPlayer *musicplayer;
@property(nonatomic) NSString *topicName;
@property(nonatomic) NSURL *imageURL;
@property (nonatomic,weak) RootViewController *parentRoot;
@end
