//
//  ProfileSetting.h
//  muzzik
//
//  Created by muzzik on 15/5/7.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "BaseNagationViewController.h"
#import "UserHomePage.h"
@interface ProfileSetting : BaseNagationViewController
@property (nonatomic,retain) NSDictionary *profileDic;
@property (nonatomic,weak) UserHomePage *userhome;
@end
