//
//  settingSystemVC.h
//  muzzik
//
//  Created by muzzik on 15/5/11.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "BaseNagationViewController.h"

@interface settingSystemVC : BaseNagationViewController
@property (nonatomic,assign) BOOL isClosed;
-(void)reloadTable;
@end
