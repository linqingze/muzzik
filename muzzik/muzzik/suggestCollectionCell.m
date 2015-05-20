//
//  suggestCollectionCell.m
//  muzzik
//
//  Created by muzzik on 15/5/17.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "suggestCollectionCell.h"

@implementation suggestCollectionCell
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-84)];
        [self.scroll setContentSize:CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH*2)];
        [self addSubview:self.scroll];
        
        self.muzzikImage = [[UIImageView alloc] initWithFrame:CGRectMake(23, 0, SCREEN_WIDTH-46, SCREEN_WIDTH-46)];
        self.muzzikImage.layer.cornerRadius = 3;
        self.muzzikImage.clipsToBounds = YES;
        [self.scroll addSubview:self.muzzikImage];
        _headImage = [[UIButton alloc] initWithFrame:CGRectMake(23, SCREEN_WIDTH-74, 56, 56)];
        _headImage.layer.cornerRadius = 28;
        _headImage.layer.borderColor = [UIColor whiteColor].CGColor;
        _headImage.layer.borderWidth =2;
        _headImage.clipsToBounds = YES;
        [_headImage addTarget:self action:@selector(goToUser) forControlEvents:UIControlEventTouchUpInside];
        [self.scroll addSubview:_headImage];
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(84, SCREEN_WIDTH-40, SCREEN_WIDTH-140, 17)];
        [_nameLabel setFont:[UIFont boldSystemFontOfSize:15]];
        [_nameLabel setTextColor:Color_Text_1];
        [self.scroll addSubview:_nameLabel];
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-130, SCREEN_WIDTH-40, 96, 9)];
        [_timeLabel setTextColor:Color_Additional_5];
        [_timeLabel setFont:[UIFont fontWithName:Font_Next_medium size:9]];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        [self.scroll addSubview:_timeLabel];
        _timeImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-30, SCREEN_WIDTH-40, 9, 9)];
        [_timeImage setImage:[UIImage imageNamed:Image_timeImage]];
        [self.scroll addSubview:_timeImage];
        
        _message = [[CXAHyperlinkLabel alloc] initWithFrame:CGRectMake(23, SCREEN_WIDTH-10, SCREEN_WIDTH-46, 400)];
        [_message setFont:[UIFont systemFontOfSize:14]];
        [_message setTextColor:Color_Text_2];
        [self.scroll addSubview:_message];
        
        _ActionView  = [[UIView alloc] initWithFrame:CGRectMake(25, 200, SCREEN_WIDTH-50, 40)];
        
        _downLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-50, 1)];
        [_downLine setBackgroundColor:Color_line_1];
        [_ActionView addSubview:_downLine];
        
        _moveButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0, _ActionView.frame.size.width/4, 40)];
        [_moveButton setImage:[UIImage imageNamed:Image_retweetImage] forState:UIControlStateNormal];
        [_moveButton addTarget:self action:@selector(moveAction) forControlEvents:UIControlEventTouchUpInside];
        [_ActionView addSubview:_moveButton];
        
        _repostButton = [[UIButton alloc] initWithFrame:CGRectMake(_ActionView.frame.size.width/4,0, _ActionView.frame.size.width/4, 40)];
        [_repostButton setImage:[UIImage imageNamed:Image_retweetImage] forState:UIControlStateNormal];
        [_repostButton addTarget:self action:@selector(repostAction) forControlEvents:UIControlEventTouchUpInside];
        [_ActionView addSubview:_repostButton];
        //[_repostButton setBackgroundColor:Color_Additional_4];
        _shareButton = [[UIButton alloc] initWithFrame:CGRectMake(_ActionView.frame.size.width/2,0, _ActionView.frame.size.width/4, 40)];
        [_shareButton setImage:[UIImage imageNamed:Image_shareImage] forState:UIControlStateNormal];
        [_shareButton addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
        [_ActionView addSubview:_shareButton];
        
        _commentButton = [[UIButton alloc] initWithFrame:CGRectMake(_ActionView.frame.size.width*3/4,0,_ActionView.frame.size.width/4, 40)];
        [_commentButton setImage:[UIImage imageNamed:Image_replyImage] forState:UIControlStateNormal];
        [_commentButton addTarget:self action:@selector(commentAction) forControlEvents:UIControlEventTouchUpInside];
        [_ActionView addSubview:_commentButton];
        [self.scroll addSubview:_ActionView];
    }
    return self;
}

@end
