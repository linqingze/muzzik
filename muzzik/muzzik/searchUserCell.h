//
//  searchUserCell.h
//  muzzik
//
//  Created by muzzik on 15/5/4.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchForUser.h"
#import "AttentionUser.h"
@interface searchUserCell : UITableViewCell
@property (nonatomic,retain) UIButton *headerImage;
@property (nonatomic,retain) UILabel *label;
@property (nonatomic) BOOL isSelected;
@property (nonatomic,retain) UIButton *attentionButton;
@property (nonatomic,assign) NSInteger index;
@property (nonatomic,weak) id<CellDelegate> delegate;
@property (nonatomic,retain) AttentionUser *muzzikUser;
@end
