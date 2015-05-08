//
//  MusicAndArtistCell.m
//  muzzik
//
//  Created by muzzik on 15/5/4.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "MusicAndArtistCell.h"

@implementation MusicAndArtistCell

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
    self.songName = [[UILabel alloc] initWithFrame:CGRectMake(18, 8, SCREEN_WIDTH-100, 20)];
    [self.songName setFont:[UIFont fontWithName:Font_Next_Bold size:14]];
    [self.songName setTextColor:[UIColor colorWithHexString:@"777777"]];
    [self addSubview:self.songName];
    self.Artist = [[UILabel alloc] initWithFrame:CGRectMake(18, 30, SCREEN_WIDTH-100, 20)];
    [self.Artist setFont:[UIFont fontWithName:Font_Next_DemiBold size:12]];
    [self.Artist setTextColor:[UIColor colorWithHexString:@"999999"]];
    [self addSubview:self.Artist];
    self.playButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-53, 0, 40, 50)];
    [self.playButton setImage:[UIImage imageNamed:@"playImage_new"] forState:UIControlStateNormal];
    [self.playButton addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.playButton];
    
    self.CommentButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-93, 0, 40, 50)];
    [self.CommentButton setImage:[UIImage imageNamed:Image_replyImage] forState:UIControlStateNormal];
    [self.CommentButton addTarget:self action:@selector(CommentAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.CommentButton];
    [MuzzikItem addLineOnView:self heightPoint:59 toLeft:13 toRight:13 withColor:Color_underLine];
    
}


-(void)playAction{
    NSLog(@"play");
    [self.songVC playMuzzikWithIndex:self.index];
}
-(void)CommentAction{
    [self.songVC commentMuzzikWithIndex:self.index];
    NSLog(@"dele");
}


@end