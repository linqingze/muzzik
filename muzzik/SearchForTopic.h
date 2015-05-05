//
//  SearchForTopic.h
//  muzzik
//
//  Created by muzzik on 15/5/4.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "searchViewController.h"
@interface SearchForTopic : UITableViewController<searchSource>
@property (nonatomic,weak) searchViewController *keeper;
@property (nonatomic,retain) NSMutableDictionary *shareDic;
-(void) poAction:(NSInteger)index;
@end
