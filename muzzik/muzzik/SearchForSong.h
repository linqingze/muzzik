//
//  SearchForSong.h
//  muzzik
//
//  Created by muzzik on 15/5/4.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "searchViewController.h"
@interface SearchForSong : UITableViewController<searchSource>
@property (nonatomic,weak) searchViewController *keeper;
-(void) playMuzzikWithIndex:(NSInteger) index;
-(void) commentMuzzikWithIndex:(NSInteger) index;
@property (nonatomic,retain) NSMutableDictionary *shareDic;
@end
