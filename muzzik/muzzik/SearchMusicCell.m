//
//  SearchMusicCell.m
//  muzzik
//
//  Created by muzzik on 15/4/26.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "SearchMusicCell.h"

@implementation SearchMusicCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
        
    }
    return self;
}

-(void)setup{
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    self.songName = [[UILabel alloc] initWithFrame:CGRectMake(18, 9, SCREEN_WIDTH-100, 20)];
    [self.songName setFont:[UIFont fontWithName:Font_Next_Bold size:14]];
    [self.songName setTextColor:[UIColor colorWithHexString:@"777777"]];
    [self addSubview:self.songName];
    self.Artist = [[UILabel alloc] initWithFrame:CGRectMake(18, 30, SCREEN_WIDTH-100, 20)];
    [self.Artist setFont:[UIFont fontWithName:Font_Next_DemiBold size:12]];
    [self.Artist setTextColor:[UIColor colorWithHexString:@"999999"]];
    [self addSubview:self.Artist];
    self.playButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-48, 0, 40, 60)];
    [self.playButton setImage:[UIImage imageNamed:@"playImage_new"] forState:UIControlStateNormal];
    [self.playButton addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.playButton];

    [MuzzikItem addLineOnView:self heightPoint:59 toLeft:13 toRight:13 withColor:Color_underLine];
    
}


-(void)playAction{
    NSLog(@"play");
    [self.delegate playSongWithSongModel:self.songMuzzik];
}

@end
