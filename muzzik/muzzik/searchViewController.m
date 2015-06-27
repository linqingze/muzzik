//
//  searchViewController.m
//  muzzik
//
//  Created by muzzik on 15/5/4.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "searchViewController.h"
#import "SearchForUser.h"
#import "SearchForSong.h"
#import "SearchForTopic.h"
@interface searchViewController () {
    UIButton *cancelButton;
    UIView *lineview;
}

@end

@implementation searchViewController

- (void)viewDidLoad {
    
    self.dataSource = self;
    self.delegate = self;
    self.tabWidth = SCREEN_WIDTH/3;
    // Keeps tab bar below navigation bar on iOS 7.0+
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [super viewDidLoad];
    lineview = [[UIView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, 1)];
    [lineview setBackgroundColor:Color_NavigationBar];
    
    [self.view setBackgroundColor:Color_NavigationBar];
    [self initNagationBar:nil leftBtn:0 rightBtn:0];
    _searchBar = [[UISearchBar alloc] initWithFrame: CGRectMake(6, 6, SCREEN_WIDTH-60, 28)];
    //[searchBar.subviews[0] removeFromSuperview];
    [_searchBar setBackgroundImage:[MuzzikItem createImageWithColor:Color_NavigationBar]];
    _searchBar.placeholder = @"搜索";
    [_searchBar setTintColor:Color_Orange];
    _searchBar.delegate = self;
    UITextField *searchField;
    UIView *view = _searchBar.subviews[0];
    
    for(int i = 0; i < [view.subviews count]; i++) {
        NSLog(@"%@",[[view.subviews objectAtIndex:i] class]);
        if([[view.subviews objectAtIndex:i] isKindOfClass:[UITextField class]]) {
            searchField = [view.subviews objectAtIndex:i];
        }
    }
    if(!(searchField == nil)) {
        searchField.textColor = [UIColor whiteColor];
       // [searchField setFrame:CGRectMake(30, 5, _searchBar.frame.size.width-30, _searchBar.frame.size.height - 10)];
        [searchField setBackgroundColor:Color_search_background];//在这添加灰色的图片
        [searchField setBorderStyle:UITextBorderStyleNone];
        searchField.layer.cornerRadius = 5;
        searchField.clipsToBounds = YES;
        searchField.textAlignment = NSTextAlignmentLeft;
    }
    _searchBar.returnKeyType = UIReturnKeySearch;
    _searchView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-150, 20, 0, 40)];
    [_searchView setFrame:CGRectMake(0, 20, SCREEN_WIDTH, 40)];
    cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-52, 6, 40, 28)];
    [cancelButton setBackgroundImage:[MuzzikItem createImageWithColor:Color_search_background] forState:UIControlStateNormal];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [cancelButton setTitleColor:Color_Orange forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(searchBarBack) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.layer.cornerRadius = 5;
    cancelButton.clipsToBounds = YES;
    [_searchView addSubview:cancelButton];
    
    [_searchView setBackgroundColor:Color_NavigationBar];
    [_searchView addSubview:_searchBar];
    [self.navigationController.view addSubview:_searchView];

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    for (UIView *view in [self.navigationController.view subviews]) {
        if ([view isKindOfClass:[RFRadioView class]]) {
            RFRadioView *musicView = (RFRadioView*)view;
            [self.navigationController.view insertSubview:self.searchView belowSubview:musicView];
        }
    }
    [self.navigationController.view addSubview:lineview];
    [self.searchView setHidden:NO];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.searchView removeFromSuperview];
    [self.searchView setHidden:YES];
    [lineview removeFromSuperview];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ViewPagerDataSource
- (NSUInteger)numberOfTabsForViewPager:(ScrollVCBase *)viewPager {
    return 3;
}
- (UIView *)viewPager:(ScrollVCBase *)viewPager viewForTabAtIndex:(NSUInteger)index {
    self.tabWidth = SCREEN_WIDTH/3;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(index*SCREEN_WIDTH/3.0, 0, SCREEN_WIDTH/3.0, 15)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:13.0];
    if (index == 0) {
        label.text = @"歌曲";
    }else if(index == 1){
        label.text = @"用户";
    }else{
        label.text = @"话题";
    }
    
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithHexString:@"666c80"];
    
    return label;
}

- (UIViewController *)viewPager:(ScrollVCBase *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index {
    
    if (index == 0) {
        SearchForSong *svcsong = [[SearchForSong alloc] init];
        svcsong.keeper = self;
        return svcsong;
    }
    else if (index == 1) {
        SearchForUser *searchvcUser = [[SearchForUser alloc] init];
        searchvcUser.keeper = self;
        return searchvcUser;
    }else{
        SearchForTopic *searchtopic = [[SearchForTopic alloc] init];
        searchtopic.keeper = self;
        return searchtopic;
    }
}

-(void) searchBarBack{
    [_searchBar resignFirstResponder];
    [_searchView removeFromSuperview];
    [self.navigationController popViewControllerAnimated:NO];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    NSLog(@"%@",searchText);
    if ([self.activityVC respondsToSelector:@selector(updateDataSource:)]) {
        [self.activityVC updateDataSource:searchText];
    }
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)loclsearchBar{
    NSLog(@"search%@",loclsearchBar.text);
    [_searchBar resignFirstResponder];
    if ([self.activityVC respondsToSelector:@selector(searchDataSource:)]) {
        [self.activityVC searchDataSource:loclsearchBar.text];
    }
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_searchBar resignFirstResponder];
}

@end
