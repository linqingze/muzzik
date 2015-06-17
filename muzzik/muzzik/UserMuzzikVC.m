//
//  UserMuzzikVC.m
//  muzzik
//
//  Created by muzzik on 15/5/7.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "UserMuzzikVC.h"
#import "MuzzikTableVC.h"
#import "CommentTableVC.h"
@interface UserMuzzikVC()<baseDelegate, baseDataSource>{
    UIView *lineView;
}

@end

@implementation UserMuzzikVC

- (void)viewDidLoad {
    self.dataSource = self;
    self.delegate = self;
    self.tabWidth = SCREEN_WIDTH/2;
    // Keeps tab bar below navigation bar on iOS 7.0+
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [super viewDidLoad];
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, 1)];
    [lineView setBackgroundColor:Color_NavigationBar];
    [self.view setBackgroundColor:Color_NavigationBar];
    [self initNagationBar:@"我的Muzzik" leftBtn:Constant_backImage rightBtn:0];
    // Do any additional setup after loading the view.
}
- (NSUInteger)numberOfTabsForViewPager:(ScrollVCBase *)viewPager {
    return 2;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.view addSubview:lineView];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [lineView removeFromSuperview];
}
- (UIView *)viewPager:(ScrollVCBase *)viewPager viewForTabAtIndex:(NSUInteger)index {
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(index*SCREEN_WIDTH/2.0, 0, SCREEN_WIDTH/2.0, 15)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:13.0];
    if (index == 0) {
        label.text = @"信息";
    }else{
        label.text = @"评论";
    }
    
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithHexString:@"666c80"];
    
    return label;
}

- (UIViewController *)viewPager:(ScrollVCBase *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index {
    
    if (index == 0) {
        MuzzikTableVC *muzzikTable = [[MuzzikTableVC alloc] init];
        muzzikTable.keeper = self;
        return muzzikTable;
    }
    else{
        CommentTableVC *commentvc = [[CommentTableVC alloc] init];
        commentvc.keeper = self;
        return commentvc;
    }
}

#pragma mark - ViewPagerDelegate
- (CGFloat)viewPager:(ScrollVCBase *)viewPager valueForOption:(ViewPagerOption)option withDefault:(CGFloat)value {
    
    switch (option) {
        case ViewPagerOptionStartFromSecondTab:
            return 0.0;
            break;
        case ViewPagerOptionCenterCurrentTab:
            return 0.0;
            break;
        case ViewPagerOptionTabLocation:
            return 1.0;
            break;
        default:
            break;
    }
    
    return value;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
