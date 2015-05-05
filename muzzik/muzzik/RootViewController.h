//
//  RootViewController.h
//  thrthr
//
//  Created by muzzik on 15/5/3.
//  Copyright (c) 2015年 muzzik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (nonatomic) RFRadioView *musicView;
-(void) showMusicView;
-(void) hideMusicView;
-(void)checkShowMusicView;
@end

