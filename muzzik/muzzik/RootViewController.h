//
//  RootViewController.h
//  thrthr
//
//  Created by muzzik on 15/5/3.
//  Copyright (c) 2015年 muzzik. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface RootViewController : AMScrollingNavbarViewController

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (nonatomic,retain) RFRadioView *musicView;
@property (nonatomic,assign) BOOL isLaunched;
@property (nonatomic,retain) StyledPageControl *pagecontrol;
@property (nonatomic,retain) UIView *titleShowView;
-(void) getMessage;
-(void)seeMessage;
@end

