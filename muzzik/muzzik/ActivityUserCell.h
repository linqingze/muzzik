//
//  ActivityUserCell.h
//  muzzik
//
//  Created by 林清泽 on 15/4/4.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityUserCell : UICollectionViewCell
@property (nonatomic) UILabel *userNameLabel;
@property (nonatomic) NSString *user_id;
@property (nonatomic) UIButton *addUserButton;
@property (nonatomic) UIImageView *userHeaderImage;
@end
