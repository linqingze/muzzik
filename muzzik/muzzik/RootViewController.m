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
#import "AppDelegate.h"
#import "searchViewController.h"
#import "UserHomePage.h"
#import "settingSystemVC.h"
#import "NotificationVC.h"
#import "KxMenu.h"
#import "AFViewShaker.h"
#import "DraftBoxVC.h"
@interface RootViewController ()<UIPageViewControllerDelegate,UIPageViewControllerDataSource,UIScrollViewDelegate>{
    NSArray *pageControllers;
    UIView *nacView;
    muzzikTrendController* muzzikvc;
    TopicVC *topicvc ;
    UserHomePage *userHome;
    BOOL isLogiined;
    UIButton *notifyButton;
    UIImageView *notifyImage;
}

@end

@implementation RootViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    _isLaunched = YES;
    [KxMenu setTintColor:Color_NavigationBar];
    [self initNagationBar:0 leftBtn:0 rightBtn:0];
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
    _titleShowView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-50, 25, 100, 15)];

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
    [searchButton setImage:[UIImage imageNamed:Image_searchImage_white] forState:UIControlStateNormal];
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
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    mydelegate.viewcontroller = muzzikvc;
    topicvc = [[TopicVC alloc] init];
    topicvc.parentRoot = self;
    userHome = [[UserHomePage alloc] init];
    userHome.parentRoot = self;
    
   
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
            NSArray* viewControllers = @[muzzikvc];
            [_pageViewController setViewControllers:viewControllers
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:NO
                                         completion:nil];
            userHome = [[UserHomePage alloc] init];
            userHome.parentRoot = self;
            pageControllers = @[muzzikvc,topicvc,userHome];
        }
        
    }else{
        [notifyButton setHidden:YES];
        hasToken = NO;
        if (isLogiined != hasToken) {
            isLogiined = NO;
            NSArray* viewControllers = @[muzzikvc];
            [_pageViewController setViewControllers:viewControllers
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:NO
                                         completion:nil];
            [userHome.view removeFromSuperview];
            pageControllers = @[muzzikvc,topicvc];
            [userHome.view removeFromSuperview];
            userHome = nil;
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
    [self.navigationController pushViewController:search animated:NO];
}

-(void) moreAction:(UIButton *)sender{
    NSArray *menuItems =
    @[
      
      [KxMenuItem menuItem:@"设置"
                     image:nil
                    target:self
                    action:@selector(systemSetting)],
      
      [KxMenuItem menuItem:@"草稿箱"
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
    DraftBoxVC *draftvc = [[DraftBoxVC alloc] init];
    [self.navigationController pushViewController:draftvc animated:YES];
    
}
-(void)getMessage{
    
    [notifyButton setImage:[UIImage imageNamed:Image_NotifynewnotificationImage] forState:UIControlStateNormal];
    [[[AFViewShaker alloc] initWithView:notifyButton] shake];
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
