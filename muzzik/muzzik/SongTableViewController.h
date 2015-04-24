//
//  SongTableViewController.h
//  muzzik
//
//  Created by muzzik on 15/4/24.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SongTableViewController : UITableViewController

-(void) playMuzzikWithIndex:(NSInteger) index;
-(void) deleleMuzzikWithIndex:(NSInteger) index;
@end
