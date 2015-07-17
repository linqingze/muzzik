//
//  HostViewController.m
//  ICViewPager
//
//  Created by Ilter Cengiz on 28/08/2013.
//  Copyright (c) 2013 Ilter Cengiz. All rights reserved.
//

#import "ChooseMusicVC.h"
#import "SongTableViewController.h"
#import "SearchLibraryMusicVC.h"
@interface ChooseMusicVC () <baseDelegate, baseDataSource,UISearchBarDelegate>{
    UIView *searchView;
    UIButton *cancelButton;
    UIView *lineview;
}

@end

@implementation ChooseMusicVC

- (void)viewDidLoad {
    
    self.dataSource = self;
    self.delegate = self;
    self.tabWidth = SCREEN_WIDTH/2;
    // Keeps tab bar below navigation bar on iOS 7.0+
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [super viewDidLoad];
    [self initNagationBar:@"发po选歌" leftBtn:0 rightBtn:0];
    lineview = [[UIView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, 1)];
    [lineview setBackgroundColor:Color_NavigationBar];
    [self.navigationController.view addSubview:lineview];
    //[MuzzikItem addLineOnView:self.navigationController.view heightPoint:64 toLeft:0 toRight:0 withColor:Color_NavigationBar];
    [self.view setBackgroundColor:Color_NavigationBar];
    [self initNagationBar:@"选歌" leftBtn:Constant_backImage rightBtn:Constant_searchImage];
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(6, 6, SCREEN_WIDTH-64, 28)];
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
        [searchField setFrame:CGRectMake(30, 5, _searchBar.frame.size.width-30, _searchBar.frame.size.height - 10)];
        [searchField setBackgroundColor:Color_search_background];//在这添加灰色的图片
        [searchField setBorderStyle:UITextBorderStyleNone];
        searchField.layer.cornerRadius = 5;
        searchField.clipsToBounds = YES;
    }
    _searchBar.returnKeyType = UIReturnKeySearch;
    searchView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-150, 20, 0, 40)];
    [searchView setFrame:CGRectMake(0, 20, SCREEN_WIDTH, 40)];
    cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-52, 6, 40, 28)];
    [cancelButton setBackgroundImage:[MuzzikItem createImageWithColor:Color_search_background] forState:UIControlStateNormal];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [cancelButton setTitleColor:Color_Orange forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(searchBarBack) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.layer.cornerRadius = 5;
    cancelButton.clipsToBounds = YES;
    [searchView addSubview:cancelButton];
    NSArray *arr = [self.navigationController.view subviews];
    NSLog(@"%@",arr);
    [searchView setBackgroundColor:Color_NavigationBar];
    [searchView addSubview:_searchBar];
    [self.rightBtn setAlpha:1];
    [self.leftBtn setAlpha:1];
    [self.rightBtn setHidden:NO];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    _searchBar.text = @"";
    _searchBar.placeholder = @"";
    if ([self.activityVC respondsToSelector:@selector(updateDataSource:)]) {
        [self.activityVC updateDataSource:@""];
    }
    [_searchBar resignFirstResponder];
    [_searchBar setFrame:CGRectMake(SCREEN_WIDTH-52, 6, 40, 28)];
    [searchView removeFromSuperview];
    [lineview removeFromSuperview];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ViewPagerDataSource
- (NSUInteger)numberOfTabsForViewPager:(ScrollVCBase *)viewPager {
    return 2;
}
- (UIView *)viewPager:(ScrollVCBase *)viewPager viewForTabAtIndex:(NSUInteger)index {
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(index*SCREEN_WIDTH/2.0, 0, SCREEN_WIDTH/2.0, 15)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:13.0];
    if (index == 0) {
        label.text = @"喜欢";
    }else{
        label.text = @"网络";
    }
    
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithHexString:@"666c80"];
        
    return label;
}

- (UIViewController *)viewPager:(ScrollVCBase *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index {
    
    if (index == 0) {
        SongTableViewController *svc = [[SongTableViewController alloc] init];
        svc.keeper = self;
        return svc;
    }
    else{
        SearchLibraryMusicVC *searchVC = [[SearchLibraryMusicVC alloc] init];
        searchVC.keeper = self;
        return searchVC;
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
-(void)rightBtnAction:(UIButton *)sender{
    _searchBar.placeholder = @"搜索";
    [_searchBar becomeFirstResponder];
    [self.navigationController.view addSubview:searchView];
    [UIView animateWithDuration:0.3 animations:^{
        [searchView setAlpha:1];
        
    } completion:^(BOOL finished) {
        
    }];
    
}

-(void) searchBarBack{
    _searchBar.text = @"";
    _searchBar.placeholder = @"";
    
    if ([self.activityVC respondsToSelector:@selector(updateDataSource:)]) {
        [self.activityVC updateDataSource:@""];
    }
    [UIView animateWithDuration:0.3 animations:^{
        
        [searchView setAlpha:0];
    } completion:^(BOOL finished) {
        [_searchBar resignFirstResponder];
        [searchView removeFromSuperview];
    }];
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
