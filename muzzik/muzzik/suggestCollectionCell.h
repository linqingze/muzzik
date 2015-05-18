//
//  suggestCollectionCell.h
//  muzzik
//
//  Created by muzzik on 15/5/17.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuggestMuzzikVC.h"
#import "CXAHyperlinkLabel.h"
@interface suggestCollectionCell : UICollectionViewCell
@property (nonatomic,retain) UIImageView *muzzikImage;
@property (nonatomic,assign) CGFloat lastContentOffset;
@property (nonatomic,weak) SuggestMuzzikVC *suggestvc;
@property (nonatomic,retain) UIButton *headImage;
@property (nonatomic,retain) UIButton *playButton;
@property (nonatomic,retain) UILabel *nameLabel;
@property (nonatomic,retain) UIImageView *timeImage;
@property (nonatomic,retain) UILabel *timeLabel;
@property (nonatomic,retain) CXAHyperlinkLabel *message;
@end
