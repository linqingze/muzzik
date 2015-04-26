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
@interface ChooseMusicVC () <baseDataSource, baseDataSource,UISearchBarDelegate>{
    UIView *searchView;
    UISearchBar *searchBar;
    UIButton *cancelButton;
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
    //[MuzzikItem addLineOnView:self.navigationController.view heightPoint:64 toLeft:0 toRight:0 withColor:Color_NavigationBar];
    [self.view setBackgroundColor:Color_NavigationBar];
    [self initNagationBar:@"选歌" leftBtn:Constant_backImage rightBtn:4];
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(50, 6, 0, 20)];
    //[searchBar.subviews[0] removeFromSuperview];
    [searchBar setBackgroundImage:[MuzzikItem createImageWithColor:Color_NavigationBar]];
    searchBar.placeholder = @"搜索";
    [searchBar setTintColor:Color_Orange];
    searchBar.delegate = self;
    UITextField *searchField;
    UIView *view = searchBar.subviews[0];
    
    for(int i = 0; i < [view.subviews count]; i++) {
        NSLog(@"%@",[[view.subviews objectAtIndex:i] class]);
        if([[view.subviews objectAtIndex:i] isKindOfClass:[UITextField class]]) {
            searchField = [view.subviews objectAtIndex:i];
        }
    }
    if(!(searchField == nil)) {
        searchField.textColor = [UIColor whiteColor];
        [searchField setFrame:CGRectMake(30, 5, searchBar.frame.size.width-30, searchBar.frame.size.height - 10)];
        [searchField setBackgroundColor:Color_search_background];//在这添加灰色的图片
        [searchField setBorderStyle:UITextBorderStyleNone];
        searchField.layer.cornerRadius = 5;
        searchField.clipsToBounds = YES;
    }
    searchBar.returnKeyType = UIReturnKeySearch;
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
    
    [searchView setBackgroundColor:Color_NavigationBar];
    [searchView addSubview:searchBar];
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
    [self.navigationController.view addSubview:searchView];
    [UIView animateWithDuration:0.3 animations:^{
//        [searchView setFrame:CGRectMake(0, 20, SCREEN_WIDTH, 40)];
        [searchBar becomeFirstResponder];
        [searchBar setFrame:CGRectMake(6, 6, SCREEN_WIDTH-64, 28)];
    } completion:^(BOOL finished) {
        
    }];
    
}

-(void) searchBarBack{
    searchBar.text = @"";
    if ([self.activityVC respondsToSelector:@selector(updateDataSource:)]) {
        [self.activityVC updateDataSource:@""];
    }
    [UIView animateWithDuration:0.3 animations:^{
        [searchBar resignFirstResponder];
        [searchBar setFrame:CGRectMake(SCREEN_WIDTH-52, 6, 40, 28)];
    } completion:^(BOOL finished) {
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
    [searchBar resignFirstResponder];
    if ([self.activityVC respondsToSelector:@selector(searchDataSource:)]) {
        [self.activityVC searchDataSource:loclsearchBar.text];
    }
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [searchBar resignFirstResponder];
}
@end
