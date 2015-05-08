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
#import "NotificationVC.h"
@interface RootViewController ()<UIPageViewControllerDelegate,UIPageViewControllerDataSource,UIScrollViewDelegate>{
    NSArray *pageControllers;
    UIView *nacView;
    UIPageControl *_pagecontrol;
    UILabel *titleLable;
    UIView *moreItemView;
    BOOL isOpen;
    UIView *glassView;
    muzzikTrendController* muzzikvc;
    TopicVC *topicvc ;
    UserHomePage *userHome;
    NotificationVC *notifyvc;
}

@end

@implementation RootViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNagationBar:0 leftBtn:0 rightBtn:0];
    nacView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    [nacView setBackgroundColor:Color_NavigationBar];
    
    _pagecontrol = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 50, SCREEN_WIDTH, 10)];
    //page control
    
    [_pagecontrol setCurrentPageIndicatorTintColor:Color_Active_Button_1];
    [_pagecontrol setPageIndicatorTintColor:Color_Theme_3];
    
    [nacView addSubview:_pagecontrol];
    titleLable = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-50, 25, 100, 15)];
    titleLable.text = @"广场";
    [titleLable setTextColor:[UIColor whiteColor]];
    [titleLable setFont:[UIFont boldSystemFontOfSize:15]];
    titleLable.textAlignment = NSTextAlignmentCenter;
    [nacView addSubview:titleLable];
    glassView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [glassView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeView)]];
    moreItemView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-120, 44, 120, 0)];
    [moreItemView setBackgroundColor:Color_NavigationBar];
    [moreItemView setAlpha:0];
    moreItemView.layer.shadowOffset = CGSizeMake(1, 1);
    moreItemView.layer.shadowColor = [UIColor blackColor].CGColor;
    UIButton *draftBox = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 50)];
    [draftBox setTitle:@"草稿箱" forState:UIControlStateNormal];
    [draftBox setTitleColor:Color_Text_4 forState:UIControlStateNormal];
    [draftBox.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [draftBox setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 40)];
    [moreItemView addSubview:draftBox];
    
    
    
    UIButton *settingButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 50, 120, 50)];
    [settingButton setTitle:@"设置" forState:UIControlStateNormal];
    [settingButton setTitleColor:Color_Text_4 forState:UIControlStateNormal];
    [settingButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [settingButton setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 56)];
    [moreItemView addSubview:settingButton];
    [MuzzikItem addLineOnView:moreItemView heightPoint:50 toLeft:10 toRight:10 withColor:Color_Text_1];
    
    
    UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 44, 44)];
    [searchButton setImage:[UIImage imageNamed:Image_searchImage_white] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(searchAction) forControlEvents:UIControlEventTouchUpInside];
    [nacView addSubview:searchButton];
    UIButton *moreButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-44, 20, 44, 44)];
    [moreButton setImage:[UIImage imageNamed:Image_moreImage] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
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
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    mydelegate.viewcontroller = muzzikvc;
    muzzikvc.homeNav = self;
    topicvc = [[TopicVC alloc] init];
    userHome = [[UserHomePage alloc] init];
    notifyvc = [[NotificationVC alloc] init];
    
   NSArray* viewControllers = @[muzzikvc];
    pageControllers = @[muzzikvc,topicvc];

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
    [_musicView setBackgroundColor:Color_NavigationBar];
    [self.view addSubview:_musicView];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.view addSubview:nacView];
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        pageControllers = @[muzzikvc,topicvc,userHome,notifyvc];
    }else{
        pageControllers = @[muzzikvc,topicvc];
    }
    _pagecontrol.numberOfPages = pageControllers.count;
    
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
    switch (index) {
        case 0:
            titleLable.text = @"广场";
            break;
        case 1:
            titleLable.text = @"推荐";
            break;
        case 2:
            titleLable.text = @"通知";
            break;
        case 3:
            titleLable.text = @"个人主页";
            break;
            
        default:
            break;
    }
    [_pagecontrol setCurrentPage:index];
    if (index == NSNotFound) {
        return nil;
    }
     NSLog(@"%d",index);
    index++;
   
    if (index == [pageControllers count]) {
        
        return nil;
    }
    return [pageControllers objectAtIndex:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    NSUInteger index = [pageControllers indexOfObject:viewController];
     NSLog(@"%d",index);
    switch (index) {
        case 0:
            titleLable.text = @"广场";
            break;
        case 1:
            titleLable.text = @"推荐";
            break;
        case 2:
            titleLable.text = @"通知";
            break;
        case 3:
            titleLable.text = @"个人主页";
            break;
            
        default:
            break;
    }
    [_pagecontrol setCurrentPage:index];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    index--;
    
    return [pageControllers objectAtIndex:index];
    
}

#pragma -mark Player
-(void)checkShowMusicView{
    if ([[musicPlayer shareClass].MusicArray count]>0) {
        [self showMusicView];
    }
    
}
-(void) showMusicView{
    _musicView.isOpen = YES;
    [UIView animateWithDuration:0.3 animations:^{
        [_musicView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    }];
}
-(void) hideMusicView{
    if (_musicView.IsShowDetail) {
        [_musicView rollBack];
        _musicView.isOpen = NO;
        _musicView.IsShowDetail = NO;
        
    }else{
        _musicView.isOpen = NO;
        _musicView.IsShowDetail = NO;
        [UIView animateWithDuration:0.3 animations:^{
            [_musicView setFrame:CGRectMake(0, -64, SCREEN_WIDTH, 64)];
        }];
    }
    
}

-(void) searchAction{
    searchViewController *search = [[searchViewController alloc ] init];
    [self.navigationController pushViewController:search animated:YES];
}

-(void) moreAction{
    if (isOpen) {
        isOpen = !isOpen;
        [self.view addSubview:glassView];
        [self.view addSubview:moreItemView];
        [UIView animateWithDuration:0.3 animations:^{
            [moreItemView setAlpha:1];
            [moreItemView setFrame:CGRectMake(SCREEN_WIDTH-120, 0, 120, 100)];
        }];
    }else{
        isOpen = !isOpen;
        [UIView animateWithDuration:0.3 animations:^{
            [moreItemView setAlpha:0];
            [moreItemView setFrame:CGRectMake(SCREEN_WIDTH-120, 0, 120, 0)];
        }completion:^(BOOL finished) {
            [moreItemView removeFromSuperview];
            [glassView removeFromSuperview];
        }];
    }
}

-(void) closeView{
    [self moreAction];
}
@end
