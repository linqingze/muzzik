//
//  FeedViewController.h
//  muzzik
//
//  Created by muzzik on 15/6/12.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "AMScrollingNavbarViewController.h"

@interface FeedViewController : AMScrollingNavbarViewController
@property(nonatomic) NSMutableArray *muzziks;
@property(nonatomic) musicPlayer *musicplayer;
@property (nonatomic,weak) RootViewController *parentRoot;
@end
