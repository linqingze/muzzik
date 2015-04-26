//
//  NormalCell.m
//  muzzik
//
//  Created by 林清泽 on 15/3/4.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "NormalCell.h"

#import "appConfiguration.h"
@implementation NormalCell
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
    _songModel = [muzzik new];
    _timeStamp = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-125, 0, 100, 5)];
   // [_timeStamp setTextColor:Color_LightGray];
    [_timeStamp setFont:[UIFont systemFontOfSize:Font_Size_Muzzik_Time]];
    _timeStamp.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_timeStamp];
    _timeImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-25, 0, 5, 5)];
    [self.contentView addSubview:_timeImage];
    _userImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 50, 50)];
    _userImage.layer.cornerRadius = 25;
    _userImage.layer.masksToBounds = YES;
    //    _userImage.layer.borderColor = [UIColor whiteColor].CGColor;
    //    _userImage.layer.borderWidth = 2.0f;
    [self.contentView addSubview:_userImage];
    _userName = [[UILabel alloc] initWithFrame:CGRectMake(75, 30, 100, 20)];
  //  [_userName setTextColor:Color_LightGray];
    [_userName setFont:[UIFont systemFontOfSize:Font_Size_Muzzik_Time]];
    [self.contentView addSubview:_userName];
    _muzzikMessage = [[CXAHyperlinkLabel alloc] initWithFrame:CGRectMake( 75, 50, SCREEN_WIDTH-110, 2000)];
    [self.contentView addSubview:_muzzikMessage];
    _musicPlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 75, SCREEN_WIDTH, 140)];
    [self.contentView addSubview:_musicPlayView];
    _progress = [[UIProgressView alloc] initWithFrame:CGRectMake(25, 0, SCREEN_WIDTH-50, 2)];
    [_progress setProgress:1];
    [_musicPlayView addSubview:_progress];
    _musicName = [[UILabel alloc] initWithFrame:CGRectMake(75, 25, SCREEN_WIDTH-150, 20)];
    [_musicName setFont:[UIFont systemFontOfSize:Font_Size_Muzzik_Message]];
    [_musicPlayView addSubview:_musicName];
    _musicArtist = [[UILabel alloc] initWithFrame:CGRectMake(75, 45, SCREEN_WIDTH-150, 20)];
    [_musicArtist setFont:[UIFont systemFontOfSize:Font_Size_Muzzik_Message]];
    [_musicPlayView addSubview:_musicArtist];
    _likeButton = [[UIButton alloc] initWithFrame:CGRectMake(35, 25, 25, 25)];
    [_likeButton addTarget:self action:@selector(moveAction) forControlEvents:UIControlEventTouchUpInside];

    [_musicPlayView addSubview:_likeButton];
    
    _playButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-65, 25, 25, 25)];

    [_playButton addTarget:self action:@selector(playMusicAction:) forControlEvents:UIControlEventTouchUpInside];
    [_musicPlayView addSubview:_playButton];
    
    _upperLine = [[UIImageView alloc] initWithFrame:CGRectMake(50, 70, SCREEN_WIDTH-100, 1)];
    [_upperLine setBackgroundColor:Color_underLine];
    [_musicPlayView addSubview:_upperLine];
    
    _moves = [[UIButton alloc] initWithFrame:CGRectMake(55, 80, (SCREEN_WIDTH-110)/4.0, 20)];
    [_moves setTitle:@"喜欢数" forState:UIControlStateNormal];
    [_moves setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_moves.titleLabel setFont:[UIFont systemFontOfSize:10.0]];
    [_moves addTarget:self action:@selector(pushMove) forControlEvents:UIControlEventTouchUpInside];
    _moves.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_musicPlayView addSubview:_moves];
    
    _reposts = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH+110)/4.0, 80, (SCREEN_WIDTH-110)/4.0, 20)];
    [_reposts setTitle:@"转发数" forState:UIControlStateNormal];
    [_reposts setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_reposts.titleLabel setFont:[UIFont systemFontOfSize:10.0]];
    [_reposts addTarget:self action:@selector(pushRepost) forControlEvents:UIControlEventTouchUpInside];
    _reposts.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_musicPlayView addSubview:_reposts];
    
    _shares = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2.0, 80, (SCREEN_WIDTH-110)/4.0, 20)];
    [_shares setTitle:@"分享数" forState:UIControlStateNormal];
    [_shares setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_shares.titleLabel setFont:[UIFont systemFontOfSize:10.0]];
    [_shares addTarget:self action:@selector(pushShare) forControlEvents:UIControlEventTouchUpInside];
    _shares.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_musicPlayView addSubview:_shares];
    
    _comments = [[UIButton alloc] initWithFrame:CGRectMake(55+(SCREEN_WIDTH-110)*3/4.0, 80, (SCREEN_WIDTH-110)/4.0, 20)];
    [_comments setTitle:@"评论数" forState:UIControlStateNormal];
    [_comments setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_comments.titleLabel setFont:[UIFont systemFontOfSize:10.0]];
    [_comments addTarget:self action:@selector(pushComment) forControlEvents:UIControlEventTouchUpInside];
    _comments.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_musicPlayView addSubview:_comments];
    
    _downLine = [[UIImageView alloc] initWithFrame:CGRectMake(50, 110, SCREEN_WIDTH-100, 1)];
    [_downLine setBackgroundColor:Color_underLine];
    [_musicPlayView addSubview:_downLine];
    
    _repostButton = [[UIButton alloc] initWithFrame:CGRectMake(55,115, (SCREEN_WIDTH-110)/3.0, 30)];
    [_repostButton setImage:[UIImage imageNamed:@"福利社黑"] forState:UIControlStateNormal];
    [_repostButton addTarget:self action:@selector(repostAction) forControlEvents:UIControlEventTouchUpInside];
    [_musicPlayView addSubview:_repostButton];
    
    _shareButton = [[UIButton alloc] initWithFrame:CGRectMake(55+(SCREEN_WIDTH-110)/3.0, 115, (SCREEN_WIDTH-110)/3.0, 30)];
    [_shareButton setImage:[UIImage imageNamed:@"分享"] forState:UIControlStateNormal];
    [_shareButton addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
    [_musicPlayView addSubview:_shareButton];
    
    _commentButton = [[UIButton alloc] initWithFrame:CGRectMake(55+(SCREEN_WIDTH-110)*2/3.0, 115, (SCREEN_WIDTH-110)/3.0, 30)];
    [_commentButton setImage:[UIImage imageNamed:@"回复"] forState:UIControlStateNormal];
    [_commentButton addTarget:self action:@selector(commentAction) forControlEvents:UIControlEventTouchUpInside];
    [_musicPlayView addSubview:_commentButton];
}
-(void)downloadMusicAction:(id)sender{
    NSLog(@"download");
    //[self.homeVc downMusicWithModel:self.songModel];
}
-(void)playMusicAction:(id) sender{
    NSLog(@"play");
    [self.homeVc playSongWithSongModel:self.songModel];
}
-(void) colorViewWithColorString:(NSString *) colorString{
    UIColor *color;
    if ([colorString isEqualToString:@"1"]) {
        color = [UIColor colorWithHexString:@"fea42c"];
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
    [self.homeVc moveMuzzikWithId:self.muzzik_id isMoved:self.isMoved atIndex:self.index];
}
-(void)repostAction{
    [self.homeVc repostActionWithMuzzik_id:self.muzzik_id atIndex:self.index];
    NSLog(@"repost");
}
-(void)shareAction{
    NSLog(@"share");
    [self.homeVc shareActionWithMuzzik_id:self.muzzik_id atIndex:self.index];
}
-(void)commentAction{
    NSLog(@"comment");
}
-(void)pushComment{

}
-(void)pushMove{

}
-(void)pushShare{

}
-(void)pushRepost{

}

@end
