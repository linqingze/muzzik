//
//  RootViewController.m
//  thrthr
//
//  Created by muzzik on 15/5/3.
//  Copyright (c) 2015年 muzzik. All rights reserved.
//

#import "RootViewController.h"
#import "muzzikTrendController.h"
#import "TopicVC.h"
#import "searchViewController.h"
#import "UserHomePage.h"
#import "settingSystemVC.h"
#import "NotificationVC.h"
#import "KxMenu.h"
#import "AFViewShaker.h"
#import "DraftBoxVC.h"
#import "FeedViewController.h"
@interface RootViewController ()<UIPageViewControllerDelegate,UIPageViewControllerDataSource,UIScrollViewDelegate>{
    NSArray *pageControllers;
    UIView *nacView;
    muzzikTrendController* muzzikvc;
    TopicVC *topicvc ;
    UserHomePage *userHome;
    FeedViewController *feedvc;
    BOOL isLogiined;
    UIButton *notifyButton;
    UIImageView *notifyImage;
    UIImageView *coverImageView;
    NSTimer *timer;
    int timeCount;
}

@end

@implementation RootViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    _isLaunched = YES;
    [KxMenu setTintColor:Color_NavigationBar];
    [self initNagationBar:@"Root" leftBtn:0 rightBtn:0];
    nacView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    [nacView setBackgroundColor:Color_NavigationBar];
    
    _pagecontrol = [[StyledPageControl alloc] initWithFrame:CGRectMake(0, 50, SCREEN_WIDTH, 8)];
    //page control
    [_pagecontrol setCoreSelectedColor:Color_Active_Button_1];
    _pagecontrol.strokeSelectedColor = [UIColor clearColor] ;
    _pagecontrol.strokeNormalColor = [UIColor clearColor] ;
    [_pagecontrol setCoreNormalColor:[UIColor whiteColor]];
    [_pagecontrol setDiameter:8];
    [_pagecontrol setGapWidth:5];

    
    [nacView addSubview:_pagecontrol];
    _titleShowView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-50, 25, 100, 25)];

    [nacView addSubview:_titleShowView];
    notifyButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-80, 24, 36, 36)];
    [notifyButton setImage:[UIImage imageNamed:Image_Notify_clockButton] forState:UIControlStateNormal];
    [notifyButton addTarget:self action:@selector(seeNotify) forControlEvents:UIControlEventTouchUpInside];
    [nacView addSubview:notifyButton];
    if ([[userInfo shareClass].token length]>0) {
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString : [NSString stringWithFormat:@"%@%@",BaseURL,URL_New_Notify]]];
        [requestForm addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
            if ([[dic objectForKey:@"result"] longValue]>0) {
                [notifyImage setHidden:NO];
            }
        }];
        [requestForm setFailedBlock:^{
            // [SVProgressHUD showErrorWithStatus:@"network error"];
        }];
        [requestForm startAsynchronous];
    }
    
    
    UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 44, 44)];
    [searchButton setImage:[UIImage imageNamed:@"searchImage"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(searchAction) forControlEvents:UIControlEventTouchUpInside];
    [nacView addSubview:searchButton];
    UIButton *moreButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-44, 20, 44, 44)];
    [moreButton setImage:[UIImage imageNamed:Image_moreImage] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
    [nacView addSubview:moreButton];
    // Do any additional setup after loading the view, typically from a nib.
    // Configure the page view controller and add it as a child view controller.
    NSDictionary *options =[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin]
                                                       forKey: UIPageViewControllerOptionSpineLocationKey];
    
    // 实例化UIPageViewController对象，根据给定的属性
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options: options];
    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self;
    [[_pageViewController view] setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    
    muzzikvc = [[muzzikTrendController alloc] init];
    muzzikvc.parentRoot = self;
    muzzikvc.isRootSubview = YES;
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    mydelegate.viewcontroller = muzzikvc;
    topicvc = [[TopicVC alloc] init];
    topicvc.parentRoot = self;
    userHome = [[UserHomePage alloc] init];
    userHome.parentRoot = self;
    
    feedvc = [[FeedViewController alloc] init];
    feedvc.parentRoot = self;
   
    pageControllers = @[muzzikvc,topicvc];
    NSArray* viewControllers = @[muzzikvc];
    [_pageViewController setViewControllers:viewControllers
                              direction:UIPageViewControllerNavigationDirectionForward
                               animated:NO
                             completion:nil];
    
    // 在页面上，显示UIPageViewController对象的View
    [self addChildViewController:_pageViewController];
    [[self view] addSubview:[_pageViewController view]];
    
    
    
//    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
//
//
//    [self addChildViewController:self.pageViewController];
//    [self.view addSubview:self.pageViewController.view];

    //[self.pageViewController didMoveToParentViewController:self];

    // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
    self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
    _musicView = [musicPlayer shareClass].radioView;
    [_musicView setBackgroundColor:[UIColor clearColor]];
    [self.navigationController.view addSubview:_musicView];
    [self addCoverVCToWindow];
    NSDate *  senddate=[NSDate date];
    
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:@"YYYYMMdd"];
    
    NSString *  locationString=[dateformatter stringFromDate:senddate];
    
    NSLog(@"locationString:%@",locationString);
    NSDictionary *dic = [MuzzikItem getDictionaryFromLocalForKey:@"Muzzik_Check_Comment_Five_star"];
    if (dic == nil) {
        dic = [NSDictionary dictionaryWithObjectsAndKeys:@"0",@"times",locationString,@"date",@"no",@"hasClicked", nil];
        [MuzzikItem addObjectToLocal:dic ForKey:@"Muzzik_Check_Comment_Five_star"];
    }else if(![[dic objectForKey:@"hasClicked"] isEqualToString:@"yes"]){
        
        if ([[dic objectForKey:@"date"] isEqualToString:locationString]) {
            NSString *tempString = [dic objectForKey:@"times"];
            tempString = [NSString stringWithFormat:@"%d",[tempString intValue]+1];
            if ([tempString intValue]==2) {
                [MuzzikItem addObjectToLocal:[NSDictionary dictionaryWithObjectsAndKeys:@"0",@"times",locationString,@"date",@"no",@"hasClicked", nil] ForKey:@"Muzzik_Check_Comment_Five_star"];
                timeCount = 120;
                timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
            }else{
                [MuzzikItem addObjectToLocal:[NSDictionary dictionaryWithObjectsAndKeys:tempString,@"times",locationString,@"date",@"no",@"hasClicked", nil] ForKey:@"Muzzik_Check_Comment_Five_star"];
            }
        }
    }
    
    
}
-(void)updateTime{
    if (timeCount>0) {
        NSLog(@"%d",timeCount);
        timeCount-- ;
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"跪求五星好评" message:@"" delegate:self cancelButtonTitle:@"残忍拒绝" otherButtonTitles:nil];
        // optional - add more buttons:
        [alert addButtonWithTitle:@"走你!"];
        [alert show];
        [timer invalidate];
        timer = nil;
        
    }
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
         NSDictionary *dic = [MuzzikItem getDictionaryFromLocalForKey:@"Muzzik_Check_Comment_Five_star"];
        [MuzzikItem addObjectToLocal:[NSDictionary dictionaryWithObjectsAndKeys:[dic objectForKey:@"times"],@"times",[dic objectForKey:@"date"],@"date",@"yes",@"hasClicked", nil] ForKey:@"Muzzik_Check_Comment_Five_star"];
        NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@?mt=8",APP_ID ];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }
}
- (void)addCoverVCToWindow {
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    coverImageView = [[UIImageView alloc] initWithFrame:self.navigationController.view.bounds];
    [coverImageView setImage:[UIImage imageNamed:@"startImage"]];
    coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    UIImageView *startLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Startslogan"]];
    
    UIImageView *startSlogan = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"muzzikSlogan"]];
    
    [startSlogan setFrame:CGRectMake(SCREEN_WIDTH-18-startSlogan.frame.size.width, SCREEN_HEIGHT-startSlogan.frame.size.height-18, startSlogan.frame.size.width, startSlogan.frame.size.height)];
    [startLogo setAlpha:0];
    NSLog(@"width:%f",[ UIScreen mainScreen ].bounds.size.width);
    if([ UIScreen mainScreen ].bounds.size.width>320){
        [startLogo setFrame:CGRectMake(20, 64, startLogo.frame.size.width, startLogo.frame.size.height)];
    }else{
        [startLogo setFrame:CGRectMake(13, 64, SCREEN_WIDTH-36, startLogo.frame.size.height)];
    }
    
    
    [UIView animateWithDuration:2 animations:^{
        [startLogo setAlpha:1];
    }];
    
    startLogo.contentMode = UIViewContentModeScaleAspectFit;
    [coverImageView addSubview:startLogo];
    [coverImageView addSubview:startSlogan];
    [app.window addSubview:coverImageView];
    [UIView animateWithDuration:0.3 delay:5 options:UIViewAnimationOptionTransitionNone animations:^{
        [coverImageView setAlpha:0];
    } completion:^(BOOL finished) {
        [coverImageView removeFromSuperview];
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_New_notify_Now]]];
        [request addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = request;
        [request setCompletionBlock :^{
            NSData *data = [weakrequest responseData];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if (dic && [[dic allKeys] containsObject:@"result"] && [[dic objectForKey:@"result"] integerValue]>0) {
                [self getMessage];
            }
        }];
        [request startAsynchronous];
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    BOOL hasToken = NO;
    [self.navigationController.view insertSubview:nacView belowSubview:_musicView];
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        [notifyButton setHidden:NO];
        hasToken = YES;
        if (isLogiined != hasToken) {
            isLogiined = YES;
            feedvc = [[FeedViewController alloc] init];
            feedvc.parentRoot = self;
            userHome = [[UserHomePage alloc] init];
            userHome.parentRoot = self;
            
            pageControllers = @[feedvc,topicvc,userHome];
            NSArray* viewControllers = @[feedvc];
            [_pageViewController setViewControllers:viewControllers
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:NO
                                         completion:nil];
            [muzzikvc.view removeFromSuperview];
            muzzikvc = nil;
            
            
        }
        
    }else{
        [notifyButton setHidden:YES];
        hasToken = NO;
        if (isLogiined != hasToken) {
            isLogiined = NO;
            muzzikvc = [[muzzikTrendController alloc] init];
            muzzikvc.isRootSubview = YES;
            muzzikvc.parentRoot = self;
            pageControllers = @[muzzikvc,topicvc];
            NSArray* viewControllers = @[muzzikvc];
            [_pageViewController setViewControllers:viewControllers
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:NO
                                         completion:nil];
            
            [userHome.view removeFromSuperview];
            userHome = nil;
            [feedvc.view removeFromSuperview];
            feedvc = nil;
            
        }
        
        
    }
    
    _pagecontrol.numberOfPages = (int)pageControllers.count;
    
  //  [self reloadData];

}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [nacView removeFromSuperview];
 
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"1111");
}
#pragma mark - UIPageViewController delegate methods

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    NSUInteger index = [pageControllers indexOfObject:viewController];

    if (index == NSNotFound) {
        return nil;
    }
    index++;
   
    if (index == [pageControllers count]) {
        
        return nil;
    }
    return [pageControllers objectAtIndex:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    NSUInteger index = [pageControllers indexOfObject:viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    index--;
    
    return [pageControllers objectAtIndex:index];
    
}

#pragma -mark Player


-(void) searchAction{
    searchViewController *search = [[searchViewController alloc ] init];
    [self.navigationController pushViewController:search animated:YES];
}

-(void) moreAction:(UIButton *)sender{
    NSArray *menuItems =
    @[
      
      [KxMenuItem menuItem:@"设置       "
                     image:nil
                    target:self
                    action:@selector(systemSetting)],
      
      [KxMenuItem menuItem:@"草稿箱      "
                     image:nil
                    target:self
                    action:@selector(DraftAction)],
      
//      [KxMenuItem menuItem:@"Check menu"
//                     image:[UIImage imageNamed:@"check_icon"]
//                    target:self
//                    action:@selector(pushMenuItem:)],
//      
//      [KxMenuItem menuItem:@"Reload page"
//                     image:[UIImage imageNamed:@"reload"]
//                    target:self
//                    action:@selector(pushMenuItem:)],
//      
//      [KxMenuItem menuItem:@"Search"
//                     image:[UIImage imageNamed:@"search_icon"]
//                    target:self
//                    action:@selector(pushMenuItem:)],
//      
//      [KxMenuItem menuItem:@"Go home"
//                     image:[UIImage imageNamed:@"home_icon"]
//                    target:self
//                    action:@selector(pushMenuItem:)],
      ];
    
    //    KxMenuItem *first = menuItems[0];
    //    first.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
    //    first.alignment = NSTextAlignmentCenter;
    
    [KxMenu showMenuInView:self.navigationController.view
                  fromRect:sender.frame
                 menuItems:menuItems];
}
-(void) DraftAction{
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        DraftBoxVC *draftvc = [[DraftBoxVC alloc] init];
        [self.navigationController pushViewController:draftvc animated:YES];
    }else{
        [userInfo checkLoginWithVC:self];
    }
    
    
}
-(void)getMessage{
    
    [notifyButton setImage:[UIImage imageNamed:Image_NotifynewnotificationImage] forState:UIControlStateNormal];
    [[[AFViewShaker alloc] initWithView:notifyButton] shake];
}
-(void)seeMessage{
    [notifyButton setImage:[UIImage imageNamed:Image_Notify_clockButton] forState:UIControlStateNormal];
}
-(void)systemSetting{
    settingSystemVC *setting = [[settingSystemVC alloc] init];
    [self.navigationController pushViewController:setting animated:YES];
    
}
-(void)seeNotify{
    [notifyButton setImage:[UIImage imageNamed:Image_Notify_clockButton] forState:UIControlStateNormal];
    NotificationVC *notifyvc = [[NotificationVC alloc] init];
    [self.navigationController pushViewController:notifyvc animated:YES];
}

@end
