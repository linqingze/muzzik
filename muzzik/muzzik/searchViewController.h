//
//  searchViewController.h
//  muzzik
//
//  Created by muzzik on 15/5/4.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "BaseNagationViewController.h"
#import "ScrollVCBase.h"

@protocol searchSource <NSObject>


@optional
// The content for any tab. Return a view controller and ViewPager will use its view to show as content
-(void)updateDataSource:(NSString *)searchText;
-(void)searchDataSource:(NSString *)searchText;

@end
@interface searchViewController :ScrollVCBase<baseDelegate, baseDataSource,UISearchBarDelegate>
@property (nonatomic,weak) id<searchSource> activityVC;
@property (nonatomic,retain) UISearchBar *searchBar;
@property (nonatomic,retain) UIView *searchView;
@end
