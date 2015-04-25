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
@interface ChooseMusicVC () <baseDataSource, baseDataSource>{
    UIView *searchView;
    UISearchBar *searchBar;
}

@end

@implementation ChooseMusicVC

- (void)viewDidLoad {
    
    self.dataSource = self;
    self.delegate = self;
    // Keeps tab bar below navigation bar on iOS 7.0+
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [super viewDidLoad];
    [self initNagationBar:@"选歌" leftBtn:Constant_backImage rightBtn:4];
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(50, 10, 0, 20)];
    //[searchBar.subviews[0] removeFromSuperview];
    [searchBar setBackgroundImage:[MuzzikItem createImageWithColor:[UIColor blackColor]]];
    searchBar.placeholder = @"搜索";
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
        [searchField setBackground: [MuzzikItem createImageWithColor:Color_For_Background]];//在这添加灰色的图片
        [searchField setBorderStyle:UITextBorderStyleNone];
        searchField.layer.cornerRadius = 8;
        searchField.clipsToBounds = YES;
    }
    searchBar.returnKeyType = UIReturnKeySearch;
    searchView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-150, 20, 0, 40)];
    [searchView setBackgroundColor:[UIColor blackColor]];
    [searchView addSubview:searchBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ViewPagerDataSource
- (NSUInteger)numberOfTabsForViewPager:(ScrollVCBase *)viewPager {
    return 10;
}
- (UIView *)viewPager:(ScrollVCBase *)viewPager viewForTabAtIndex:(NSUInteger)index {
    
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:13.0];
    label.text = [NSString stringWithFormat:@"Content View #%i", index];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    [label sizeToFit];
    
    return label;
}

- (UIViewController *)viewPager:(ScrollVCBase *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index {
    
    if (index == 0) {
        SongTableViewController *cvc = [[SongTableViewController alloc] init];
        return cvc;
    }
    else{
        SearchLibraryMusicVC *searchVC = [[SearchLibraryMusicVC alloc] init];
        return searchVC;
    }
}

#pragma mark - ViewPagerDelegate
- (CGFloat)viewPager:(ScrollVCBase *)viewPager valueForOption:(ViewPagerOption)option withDefault:(CGFloat)value {
    
    switch (option) {
        case ViewPagerOptionStartFromSecondTab:
            return 1.0;
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
- (UIColor *)viewPager:(ScrollVCBase *)viewPager colorForComponent:(ViewPagerComponent)component withDefault:(UIColor *)color {
    
    switch (component) {
        case ViewPagerIndicator:
            return [[UIColor redColor] colorWithAlphaComponent:0.64];
            break;
        default:
            break;
    }
    
    return color;
}
-(void)rightBtnAction:(UIButton *)sender{
    [self.navigationController.view addSubview:searchView];
    [UIView animateWithDuration:0.5 animations:^{
        [searchView setFrame:CGRectMake(0, 20, SCREEN_WIDTH, 40)];
        [searchBar becomeFirstResponder];
        [searchBar setFrame:CGRectMake(5, 10, SCREEN_WIDTH-60, 20)];
    } completion:^(BOOL finished) {
        
    }];
    
}
@end
