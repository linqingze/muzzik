//
//  userHeadCell.m
//  muzzik
//
//  Created by muzzik on 15/5/6.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "userHeadCell.h"

@implementation userHeadCell

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
    _headimage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
    [_headimage setAlpha:0];
    [self addSubview:_headimage];
    UIImageView *coverImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
    [coverImage setImage:[UIImage imageNamed:Image_prifilebgcover]];
    [self addSubview:coverImage];
    _attentionButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, 16, 85, 23)];
    [_attentionButton addTarget:self action:@selector(attentionAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_attentionButton];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, SCREEN_WIDTH/2, 30, 30)];
    [_nameLabel setFont:[UIFont fontWithName:Font_Next_DemiBold size:24]];
    _nameLabel.textColor = [UIColor whiteColor];
    [self addSubview:_nameLabel];
    _genderImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:Image_profilefemaleImage]];
    [self addSubview:_genderImage];
    
    _constellationImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 5, 8, 8)];
    _constellationLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 5, SCREEN_WIDTH/2-50, 20)];
    
    _birthImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 5, 8, 8)];
    _birthLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, SCREEN_WIDTH/2-50, 20)];
    
    _companyImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 5, 8, 8)];
    _companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, SCREEN_WIDTH/2-50, 20)];

    _schoolImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 5, 8, 8)];
    _schoolLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, SCREEN_WIDTH/2-50, 20)];
    _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, SCREEN_WIDTH/2, SCREEN_WIDTH-32,0)];
    
    _messageView = [[UIView alloc] initWithFrame:CGRectMake(16, SCREEN_WIDTH, SCREEN_WIDTH-32, 55)];
    [_messageView setBackgroundColor:[UIColor whiteColor]];
    UIView *muzzikView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_messageView.frame)/4, CGRectGetHeight(_messageView.frame))];
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, CGRectGetWidth(_messageView.frame)/4, 20)];
    messageLabel.font = [UIFont systemFontOfSize:11];
    messageLabel.textColor = Color_Additional_5;
    messageLabel.text = @"信息";
    messageLabel.textAlignment = NSTextAlignmentCenter;
    _muzzikCount = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, CGRectGetWidth(_messageView.frame)/4, 25)];
    [_muzzikCount setFont:[UIFont fontWithName:Font_Next_DemiBold size:15]];
    _muzzikCount.textAlignment = NSTextAlignmentCenter;
    _muzzikCount.textColor = Color_Text_2;
    [muzzikView addSubview:_muzzikCount];
    [muzzikView addSubview:messageLabel];
    
    [_messageView addSubview:muzzikView];
    
    UIView *followView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_messageView.frame)/4, 0, CGRectGetWidth(_messageView.frame)/4, CGRectGetHeight(_messageView.frame))];
    UILabel *followLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, CGRectGetWidth(_messageView.frame)/4, 20)];
    followLabel.font = [UIFont systemFontOfSize:11];
    followLabel.textColor = Color_Additional_5;
    followLabel.text = @"关注";
    followLabel.textAlignment = NSTextAlignmentCenter;
    _followCount = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, CGRectGetWidth(_messageView.frame)/4, 25)];
    [_followCount setFont:[UIFont fontWithName:Font_Next_DemiBold size:15]];
    _followCount.textAlignment = NSTextAlignmentCenter;
    _followCount.textColor = Color_Text_2;
    [followView addSubview:_followCount];
    [followView addSubview:followLabel];
    
    [_messageView addSubview:followView];
    [followView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFollow)]];
    UIView *fansView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_messageView.frame)/2, 0, CGRectGetWidth(_messageView.frame)/4, CGRectGetHeight(_messageView.frame))];
    UILabel *fansLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, CGRectGetWidth(_messageView.frame)/4, 20)];
    fansLabel.font = [UIFont systemFontOfSize:11];
    fansLabel.textColor = Color_Additional_5;
    fansLabel.text = @"粉丝";
    fansLabel.textAlignment = NSTextAlignmentCenter;
    _fansCount = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, CGRectGetWidth(_messageView.frame)/4, 25)];
    [_fansCount setFont:[UIFont fontWithName:Font_Next_DemiBold size:15]];
    _fansCount.textAlignment = NSTextAlignmentCenter;
    _fansCount.textColor = Color_Text_2;
    [fansView addSubview:_fansCount];
    [fansView addSubview:fansLabel];
    [fansView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFans)]];
    [_messageView addSubview:fansView];
    
    UIView *songView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_messageView.frame)*3/4, 0, CGRectGetWidth(_messageView.frame)/4, CGRectGetHeight(_messageView.frame))];
    UILabel *songLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, CGRectGetWidth(_messageView.frame)/4, 20)];
    songLabel.font = [UIFont systemFontOfSize:11];
    songLabel.textColor = Color_Additional_5;
    songLabel.text = @"歌单";
    songLabel.textAlignment = NSTextAlignmentCenter;
    _songCount = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, CGRectGetWidth(_messageView.frame)/4, 25)];
    [_songCount setFont:[UIFont fontWithName:Font_Next_DemiBold size:15]];
    _songCount.textAlignment = NSTextAlignmentCenter;
    _songCount.textColor = Color_Text_2;
    [songView addSubview:_songCount];
    [songView addSubview:songLabel];
    [songView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showSong)]];
    [_messageView addSubview:songView];
     [self addSubview:_messageView];
    UIView *linview = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_messageView.frame)/4, 16, 1, 22)];
    [linview setBackgroundColor:Color_line_1];
    [_messageView addSubview:linview];
    
    UIView *linview2 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_messageView.frame)/2, 16, 1, 22)];
    [linview2 setBackgroundColor:Color_line_1];
    [_messageView addSubview:linview2];
    
    UIView *linview3 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_messageView.frame)*3/4, 16, 1, 22)];
    [linview3 setBackgroundColor:Color_line_1];
    [_messageView addSubview:linview3];
    UIView *lineWidth = [[UIView alloc] initWithFrame:CGRectMake(0, 53, CGRectGetWidth(_messageView.frame), 2)];
    [lineWidth setBackgroundColor:Color_line_1];
    [_messageView addSubview:lineWidth];
    
    UIView *lineRed = [[UIView alloc] initWithFrame:CGRectMake(0, 53, CGRectGetWidth(_messageView.frame)/4, 2)];
    [lineRed setBackgroundColor:Color_Active_Button_1];
    [_messageView addSubview:lineRed];
    
}
-(void) attentionAction{
    if ([self.delegate respondsToSelector:@selector(payAttention:)]) {
        [self.delegate payAttention:self.uid];
    }
    
}

-(void)showFollow{
    if ([self.delegate respondsToSelector:@selector(showFollow:)]) {
        [self.delegate showFollow:self.uid];
    }
}
-(void)showFans{
    if ([self.delegate respondsToSelector:@selector(showFans:)]) {
        [self.delegate showFans:self.uid];
    }
}
-(void)showSong{
    if ([self.delegate respondsToSelector:@selector(showSong:)]) {
        [self.delegate showSong:self.uid];
    }
}
@end
