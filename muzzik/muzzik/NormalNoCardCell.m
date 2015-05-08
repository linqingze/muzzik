//
//  NormalNoCardCell.m
//  muzzik
//
//  Created by muzzik on 15/5/2.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "NormalNoCardCell.h"

@implementation NormalNoCardCell

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
    _userImage = [[UIButton alloc] initWithFrame:CGRectMake(16, 36, 50, 50)];
    [_userImage addTarget:self action:@selector(goToUser) forControlEvents:UIControlEventTouchUpInside];
    _userImage.layer.cornerRadius = 25;
    _userImage.layer.masksToBounds = YES;
    //    _userImage.layer.borderColor = [UIColor whiteColor].CGColor;
    //    _userImage.layer.borderWidth = 2.0f;
    [self addSubview:_userImage];
    _repostImage = [[UIImageView alloc] initWithFrame:CGRectMake(66, 36, 8, 8)];
    [self addSubview:_repostImage];
    _repostUserName = [[UILabel alloc] initWithFrame:CGRectMake(80, 36, 150, 10)];
    [_repostUserName setTextColor:Color_Additional_5];
    [_repostUserName setFont:[UIFont fontWithName:Font_Next_DemiBold size:8]];
    [self addSubview:_repostUserName];
    
    _songModel = [muzzik new];
    _timeStamp = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-130, 15, 96, 9)];
    [_timeStamp setTextColor:Color_Additional_5];
    [_timeStamp setFont:[UIFont fontWithName:Font_Next_medium size:9]];
    _timeStamp.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_timeStamp];
    _timeImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-30, 15, 9, 9)];
    [_timeImage setImage:[UIImage imageNamed:Image_timeImage]];
    [self.contentView addSubview:_timeImage];
    
    _userName = [[UILabel alloc] initWithFrame:CGRectMake(80, 55, 180, 20)];
    //  [_userName setTextColor:Color_LightGray];
    [_userName setFont:[UIFont fontWithName:Font_Next_DemiBold size:15]];
    [_userName setTextColor:Color_Text_1];
    [self.contentView addSubview:_userName];
    _muzzikMessage = [[CXAHyperlinkLabel alloc] initWithFrame:CGRectMake( 80, 83, SCREEN_WIDTH-110, 2000)];
    [_muzzikMessage setTextColor:Color_Text_2];
    [_muzzikMessage setFont:[UIFont systemFontOfSize:15]];
    [self.contentView addSubview:_muzzikMessage];
    _musicPlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 75, SCREEN_WIDTH, 145+SCREEN_WIDTH*3/4)];
    [self.contentView addSubview:_musicPlayView];
    _progress = [[UIProgressView alloc] initWithFrame:CGRectMake(16, 0, SCREEN_WIDTH-32, 0.5)];
    [_progress setProgress:1];
    [_musicPlayView addSubview:_progress];
    _musicName = [[UILabel alloc] initWithFrame:CGRectMake(80, 12, SCREEN_WIDTH-150, 20)];
    [_musicName setFont:[UIFont fontWithName:Font_Next_Bold size:16]];
    [_musicPlayView addSubview:_musicName];
    _musicArtist = [[UILabel alloc] initWithFrame:CGRectMake(80, 31, SCREEN_WIDTH-150, 25)];
    [_musicArtist setFont:[UIFont fontWithName:Font_Next_Bold size:13]];
    [_musicPlayView addSubview:_musicArtist];
    _likeButton = [[UIButton alloc] initWithFrame:CGRectMake(16, 13, 34, 34)];
    [_likeButton addTarget:self action:@selector(moveAction) forControlEvents:UIControlEventTouchUpInside];
    [_musicPlayView addSubview:_likeButton];
    
    _playButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-50, 13, 34, 34)];
    
    [_playButton addTarget:self action:@selector(playMusicAction:) forControlEvents:UIControlEventTouchUpInside];
    [_musicPlayView addSubview:_playButton];
    
    _poImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/8, 60, SCREEN_WIDTH*3/4, SCREEN_WIDTH*3/4)];
    _poImage.layer.cornerRadius = 3;
    _poImage.clipsToBounds = YES;
    [_poImage setImage:[UIImage imageNamed:Image_yellowretweetImage]];
    [_musicPlayView addSubview:_poImage];
    
    [self.userImage setAlpha:0];
    [self.poImage setAlpha:0];
    
    _reposts = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH*1)/8.0, SCREEN_WIDTH*3/4+60, (SCREEN_WIDTH*3)/16.0, 40)];
    [_reposts setTitle:@"转发数" forState:UIControlStateNormal];
    [_reposts setTitleColor:Color_Additional_5 forState:UIControlStateNormal];
    [_reposts.titleLabel setFont:[UIFont systemFontOfSize:10.0]];
    [_reposts addTarget:self action:@selector(pushRepost) forControlEvents:UIControlEventTouchUpInside];
    _reposts.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_musicPlayView addSubview:_reposts];
    
    _moves = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH*5)/16.0, SCREEN_WIDTH*3/4+60, (SCREEN_WIDTH*3)/16.0, 40)];
    [_moves setTitle:@"喜欢数" forState:UIControlStateNormal];
    [_moves setTitleColor:Color_Additional_5 forState:UIControlStateNormal];
    [_moves.titleLabel setFont:[UIFont systemFontOfSize:10.0]];
    [_moves addTarget:self action:@selector(pushMove) forControlEvents:UIControlEventTouchUpInside];
    _moves.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_musicPlayView addSubview:_moves];
    
    _shares = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, SCREEN_WIDTH*3/4+60, (SCREEN_WIDTH*3)/16.0, 40)];
    [_shares setTitle:@"分享数" forState:UIControlStateNormal];
    [_shares setTitleColor:Color_Additional_5 forState:UIControlStateNormal];
    [_shares.titleLabel setFont:[UIFont systemFontOfSize:10.0]];
    [_shares addTarget:self action:@selector(pushShare) forControlEvents:UIControlEventTouchUpInside];
    _shares.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_musicPlayView addSubview:_shares];
    
    _comments = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH*11)/16.0, SCREEN_WIDTH*3/4+60, (SCREEN_WIDTH*3)/16.0, 40)];
    [_comments setTitle:@"评论数" forState:UIControlStateNormal];
    [_comments setTitleColor:Color_Additional_5 forState:UIControlStateNormal];
    [_comments.titleLabel setFont:[UIFont systemFontOfSize:10.0]];
    [_comments addTarget:self action:@selector(pushComment) forControlEvents:UIControlEventTouchUpInside];
    _comments.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_musicPlayView addSubview:_comments];
    
    
    
    _downLine = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/8,SCREEN_WIDTH*3/4+ 100, SCREEN_WIDTH*3/4, 1)];
    [_downLine setImage:[UIImage imageNamed:Image_lineImage]];
    [_musicPlayView addSubview:_downLine];
    
    _repostButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/8,SCREEN_WIDTH*3/4+100, SCREEN_WIDTH/4.0, 45)];
    [_repostButton setImage:[UIImage imageNamed:Image_retweetImage] forState:UIControlStateNormal];
    [_repostButton addTarget:self action:@selector(repostAction) forControlEvents:UIControlEventTouchUpInside];
    [_musicPlayView addSubview:_repostButton];
    //[_repostButton setBackgroundColor:Color_Additional_4];
    _shareButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*3/8,SCREEN_WIDTH*3/4+100, SCREEN_WIDTH/4.0, 45)];
    [_shareButton setImage:[UIImage imageNamed:Image_shareImage] forState:UIControlStateNormal];
    [_shareButton addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
    [_musicPlayView addSubview:_shareButton];
    
    _commentButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*5/8,SCREEN_WIDTH*3/4+100, SCREEN_WIDTH/4.0, 45)];
    [_commentButton setImage:[UIImage imageNamed:Image_replyImage] forState:UIControlStateNormal];
    [_commentButton addTarget:self action:@selector(commentAction) forControlEvents:UIControlEventTouchUpInside];
    [_musicPlayView addSubview:_commentButton];
    [MuzzikItem addLineOnView:_musicPlayView heightPoint:SCREEN_WIDTH*3/4+145 toLeft:16 toRight:16 withColor:Color_line_1];
}
-(void)downloadMusicAction:(id)sender{
    NSLog(@"download");
    //[self.homeVc downMusicWithModel:self.songModel];
}
-(void)playMusicAction:(id) sender{
    NSLog(@"play");
    [self.delegate playSongWithSongModel:self.songModel];
}
-(void) colorViewWithColorString:(NSString *) colorString{
    UIColor *color;
    if ([colorString isEqualToString:@"1"]) {
        color = [UIColor colorWithHexString:@"fea42c"];
        [self.repostImage setImage:[UIImage imageNamed:Image_yellowretweetImage]];
        if (self.isMoved) {
            [self.likeButton setImage:[UIImage imageNamed:@"yellowlikedImage"] forState:UIControlStateNormal];
        }else{
            [self.likeButton setImage:[UIImage imageNamed:@"yellowlikeImage"] forState:UIControlStateNormal];
        }
        if (self.isPlaying) {
            [self.playButton setImage:[UIImage imageNamed:@"yellowstopImage"] forState:UIControlStateNormal];
        }else{
            [self.playButton setImage:[UIImage imageNamed:@"yellowplayImage"] forState:UIControlStateNormal];
        }
    }
    else if([colorString isEqualToString:@"2"]){
        //bluelikeImage
        [self.repostImage setImage:[UIImage imageNamed:Image_blueretweetImage]];
        color = [UIColor colorWithHexString:@"04a0bf"];
        if (self.isMoved) {
            [self.likeButton setImage:[UIImage imageNamed:@"bluelikedImage"] forState:UIControlStateNormal];
        }else{
            [self.likeButton setImage:[UIImage imageNamed:@"bluelikeImage"] forState:UIControlStateNormal];
        }
        if (self.isPlaying) {
            [self.playButton setImage:[UIImage imageNamed:@"bluestopImage"] forState:UIControlStateNormal];
        }else{
            [self.playButton setImage:[UIImage imageNamed:@"blueplayImage"] forState:UIControlStateNormal];
        }
    }
    else{
        color = [UIColor colorWithHexString:@"f26d7d"];
        [self.repostImage setImage:[UIImage imageNamed:Image_redretweetImage]];
        if (self.isMoved) {
            [self.likeButton setImage:[UIImage imageNamed:@"redlikedImage"] forState:UIControlStateNormal];
        }else{
            [self.likeButton setImage:[UIImage imageNamed:@"redlikeImage"] forState:UIControlStateNormal];
        }
        if (self.isPlaying) {
            [self.playButton setImage:[UIImage imageNamed:@"redstopImage"] forState:UIControlStateNormal];
        }else{
            [self.playButton setImage:[UIImage imageNamed:@"redplayImage"] forState:UIControlStateNormal];
        }
    }
    [_progress setTintColor:color];
    [_musicArtist setTextColor:color];
    [_musicName setTextColor:color];
}
-(void)moveAction{
    NSLog(@"move");
    [self.delegate moveMuzzikWithId:self.muzzik_id isMoved:self.isMoved atIndex:self.index];
}
-(void)repostAction{
    [self.delegate repostActionWithMuzzik_id:self.muzzik_id atIndex:self.index];
    NSLog(@"repost");
}
-(void)shareAction{
    NSLog(@"share");
    [self.delegate shareActionWithMuzzik_id:self.muzzik_id atIndex:self.index];
}
-(void)commentAction{
    [self.delegate commentAtMuzzik:self.muzzik_id];
}
-(void)pushComment{
    [self.delegate showComment:self.muzzik_id];
}
-(void)pushMove{
    [self.delegate showMoved:self.muzzik_id];
}
-(void)pushShare{
    [self.delegate showShare:self.muzzik_id];
}
-(void)pushRepost{
    [self.delegate showRepost:self.muzzik_id];
}

-(void)goToUser{
    [self.delegate userDetail:self.songModel.MuzzikUser.user_id];
}
@end