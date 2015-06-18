//
//  HostViewController.m
//  ICViewPager
//
//  Created by Ilter Cengiz on 28/08/2013.
//  Copyright (c) 2013 Ilter Cengiz. All rights reserved.
//
#import "ASIHTTPRequest.h"
#import "HostViewController.h"
#import "Reachability.h"
#import "appConfiguration.h"
#import "muzzikTrendController.h"
#import "TopicVC.h"
#import "musicPlayer.h"
//#import "AFNetworking.h"
@interface HostViewController () <ViewPagerDataSource, ViewPagerDelegate>
{
    UIImageView *coverImageView;
    UITabBarController *tab;
    BOOL isHiddenStatusBar;
}
@property (nonatomic) BOOL hasMiao;
@property (nonatomic) muzzikTrendController *muzzikvc;
@end

@implementation HostViewController
-(muzzikTrendController *)muzzikvc{
    if (!_muzzikvc) {
        _muzzikvc = [[muzzikTrendController alloc] init];
        AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        mydelegate.viewcontroller = _muzzikvc;
    }
    return _muzzikvc;
}
- (void)viewDidLoad {
    
    self.dataSource = self;
    self.delegate = self;
   
    // Keeps tab bar below navigation bar on iOS 7.0+
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//    }
    
    [super viewDidLoad];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reloadData];
    [self.navigationController.navigationBar setHidden:YES];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.isLoaded = YES;
    [self.navigationController.navigationBar setHidden:NO];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ViewPagerDataSource
- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager {
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        return 5;
    }else{
        return 3;
    }
    

}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [self reloadData];
    }
}
//..............................................................................................
- (UIView *)viewPager:(ViewPagerController *)viewPager viewForTabAtIndex:(NSUInteger)index {
    UIView *lview ;
    
    //label.font = [UIFont systemFontOfSize:13.0];
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        lview = [[UIView alloc] initWithFrame:CGRectMake(index*SCREEN_WIDTH/5.0, 0, SCREEN_WIDTH/5.0, 40)];
        if (index ==0) {
            self.tabWidth = SCREEN_WIDTH/5.0;
            UIImageView *iview = [[UIImageView alloc] initWithFrame:CGRectMake(lview.frame.size.width/2-9, lview.frame.size.height/2-9, 18, 18)];
            iview.tag = 10000;
            iview.image = [UIImage imageNamed:@"homeImage"];
            [lview addSubview:iview];
        }
        else if (index ==1) {
            UIImageView *iview = [[UIImageView alloc] initWithFrame:CGRectMake(lview.frame.size.width/2-9, lview.frame.size.height/2-9, 18, 18)];
            iview.tag = 10001;
            iview.image = [UIImage imageNamed:@"recommendImage"];
            [lview addSubview:iview];    }
        else if (index ==2) {
            UIImageView *iview = [[UIImageView alloc] initWithFrame:CGRectMake(lview.frame.size.width/2-9, lview.frame.size.height/2-9, 18, 18)];
            iview.tag = 10002;
            iview.image = [UIImage imageNamed:@"profileImage"];
            [lview addSubview:iview];
        }
        else if (index ==3) {
            UIImageView *iview = [[UIImageView alloc] initWithFrame:CGRectMake(lview.frame.size.width/2-9, lview.frame.size.height/2-9, 18, 18)];
            iview.tag = 10003;
            iview.image = [UIImage imageNamed:@"notiImage"];
            [lview addSubview:iview];
        }
        else{
            UIImageView *iview = [[UIImageView alloc] initWithFrame:CGRectMake(lview.frame.size.width/2-9, lview.frame.size.height/2-9, 18, 18)];
            iview.image = [UIImage imageNamed:@"searchImage"];
            iview.tag = 1004;
            [lview addSubview:iview];
        }
    }else{
        self.tabWidth = SCREEN_WIDTH/3.0;
        lview = [[UIView alloc] initWithFrame:CGRectMake(index*SCREEN_WIDTH/3.0, 0, SCREEN_WIDTH/3.0, 40)];
        if (index ==0) {
            UIImageView *iview = [[UIImageView alloc] initWithFrame:CGRectMake(lview.frame.size.width/2-9, lview.frame.size.height/2-9, 18, 18)];
            iview.tag = 10000;
            iview.image = [UIImage imageNamed:@"homeImage"];
            [lview addSubview:iview];
        }
        else if (index ==1) {
            UIImageView *iview = [[UIImageView alloc] initWithFrame:CGRectMake(lview.frame.size.width/2-9, lview.frame.size.height/2-9, 18, 18)];
            iview.tag = 10001;
            iview.image = [UIImage imageNamed:@"recommendImage"];
            [lview addSubview:iview];    }
        else{
            UIImageView *iview = [[UIImageView alloc] initWithFrame:CGRectMake(lview.frame.size.width/2-9, lview.frame.size.height/2-9, 18, 18)];
            iview.image = [UIImage imageNamed:@"searchImage"];
            iview.tag = 1004;
            [lview addSubview:iview];
        }
    }
    
    
    return lview;
}
//..............................................................................................
- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index {
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        if (index ==0) {
           muzzikTrendController* muzzikvc = [[muzzikTrendController alloc] init];
            AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            mydelegate.viewcontroller = muzzikvc;
            return muzzikvc;
        }
        else if (index ==1) {
            TopicVC *topicvc = [[TopicVC alloc] init];
            
            return topicvc;
        }
        else if (index ==2) {
            return self.muzzikvc;
        }
        else if (index ==3) {
            TopicVC *topicvc = [[TopicVC alloc] init];
            
            return topicvc;
        }
        else{
            TopicVC *topicvc = [[TopicVC alloc] init];
            
            return topicvc;
        }
    }else{
        if (index ==0) {
            return self.muzzikvc;
        }
        else if (index ==1) {
            TopicVC *topicvc = [[TopicVC alloc] init];
            
            return topicvc;
        }
        else{
            return self.muzzikvc;
        }
    }

}
#pragma mark - ViewPagerDelegate

#pragma -mark Player


- (void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event

{
    
    //摇动结束
    if (event.subtype == UIEventSubtypeMotionShake && [[musicPlayer shareClass].MusicArray count]>0) {
        }
    
}


@end
