//
//  MusicAndArtistCell.h
//  muzzik
//
//  Created by muzzik on 15/5/4.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchForSong.h"
@interface MusicAndArtistCell : UITableViewCell
@property (nonatomic,retain) UILabel *songName;
@property (nonatomic,retain) UILabel *Artist;
@property (nonatomic,retain) UIButton *CommentButton;
@property (nonatomic,retain) UIButton *playButton;
@property (nonatomic,assign) NSInteger index;
@property (nonatomic,weak) SearchForSong *songVC;
@end
