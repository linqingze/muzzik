//
//  CommentMuzzikCell.h
//  muzzik
//
//  Created by muzzik on 15/5/9.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CXAHyperlinkLabel.h"
@interface CommentMuzzikCell : UITableViewCell

@property(nonatomic ,retain) UIButton *userImage;
@property(nonatomic ,retain) UILabel *userName;
@property(nonatomic ,retain) CXAHyperlinkLabel *message;
@property(nonatomic ,retain) UIButton *playButton;
@property(nonatomic ,retain) UILabel *songName;
@property(nonatomic ,retain) UILabel *artist;
@property(nonatomic ,retain) UILabel *timeLabel;
@end