//
//  CommentMuzzikCell.m
//  muzzik
//
//  Created by muzzik on 15/5/9.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "CommentMuzzikCell.h"

@implementation CommentMuzzikCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
        
    }
    return self;
}

-(void)setup{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    _lineview = [[UIView alloc] initWithFrame:CGRectMake(16, 0, SCREEN_WIDTH-32, 1)];
    [_lineview setBackgroundColor:Color_line_1];
    [self addSubview:_lineview];
    
    _privateImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [_privateImage setImage:[UIImage imageNamed:Image_detailinvisibleImage]];
    [_privateImage setHidden:YES];
    [self addSubview:_privateImage];
    _userImage = [[UIButton alloc] initWithFrame:CGRectMake(16, 15, 40, 40)];
    [_userImage addTarget:self action:@selector(goToUser) forControlEvents:UIControlEventTouchUpInside];
    _userImage.layer.cornerRadius = 20;
    _userImage.layer.masksToBounds = YES;
    [self.userImage setAlpha:0];
    //    _userImage.layer.borderColor = [UIColor whiteColor].CGColor;
    //    _userImage.layer.borderWidth = 2.0f;
    [self addSubview:_userImage];
    _userName = [[UILabel alloc] initWithFrame:CGRectMake(66, 20,100, 20)];
    [_userName setTextColor:Color_Text_1];
    [_userName setFont:[UIFont fontWithName:Font_Next_medium size:14]];
    [self addSubview:_userName];
    _message = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(66, 40, SCREEN_WIDTH-140, 30)];
    [_message setFont:[UIFont systemFontOfSize:Font_Size_Muzzik_Message]];
    [_message setTextColor:Color_Text_1];
    [self addSubview:_message];
    
    _playButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-56, 40, 40, 40)];
    [_playButton addTarget:self action:@selector(playMuzzik) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_playButton];
    _songName = [[UILabel alloc] initWithFrame:CGRectMake(80, 12, SCREEN_WIDTH-150, 20)];
    [self addSubview:_songName];
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-76, 20, 45, 20)];
    _timeLabel.textAlignment = NSTextAlignmentRight;
    _timeImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-25, 25, 10, 10)];
    [_timeImage setImage:[UIImage imageNamed:Image_timeImage]];
    [self addSubview:_timeImage];
    [_timeLabel setFont:[UIFont systemFontOfSize:10]];
    [_timeLabel setTextColor:Color_Text_4];
    [self addSubview:_timeLabel];
    
}
-(void) playMuzzik{
     [self.delegate playSongWithSongModel:self.MuzzikModel];
}
-(void) goToUser{
    [self.delegate userDetail:self.MuzzikModel.MuzzikUser.user_id];
}

@end
