//
//  DraftsCell.h
//  muzzik
//
//  Created by muzzik on 15/6/7.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DraftsCell : UITableViewCell
@property (nonatomic,retain) UIImageView *timeImage;
@property (nonatomic,retain) UILabel *timeLabel;
@property (nonatomic,retain) UILabel *message;
@property (nonatomic,retain) UIButton *deleButton;
@property (nonatomic,retain) UIButton *editButton;
@end