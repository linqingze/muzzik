//
//  RootViewController.h
//  thrthr
//
//  Created by muzzik on 15/5/3.
//  Copyright (c) 2015年 muzzik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseNagationViewController.h"
@interface RootViewController : BaseNagationViewController

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (nonatomic) RFRadioView *musicView;
@property (nonatomic,assign) BOOL isLaunched;
-(void) showMusicView;
-(void) hideMusicView;
-(void)checkShowMusicView;
-(void) getMessage;
@end

