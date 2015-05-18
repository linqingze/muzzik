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
        self.muzzikImage = [[UIImageView alloc] initWithFrame:CGRectMake(23, 0, SCREEN_WIDTH-46, SCREEN_WIDTH-46)];
        self.muzzikImage.layer.cornerRadius = 3;
        self.muzzikImage.clipsToBounds = YES;
        [self addSubview:self.muzzikImage];
        _headImage = [[UIButton alloc] initWithFrame:CGRectMake(23, SCREEN_WIDTH-74, 56, 56)];
        _headImage.layer.cornerRadius = 28;
        _headImage.layer.borderColor = [UIColor whiteColor].CGColor;
        _headImage.layer.borderWidth =2;
        _headImage.clipsToBounds = YES;
        [_headImage addTarget:self action:@selector(goToUser) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_headImage];
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(84, SCREEN_WIDTH-40, SCREEN_WIDTH-140, 17)];
        [_nameLabel setFont:[UIFont boldSystemFontOfSize:15]];
        [_nameLabel setTextColor:Color_Text_1];
        [self addSubview:_nameLabel];
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-130, SCREEN_WIDTH-40, 96, 9)];
        [_timeLabel setTextColor:Color_Additional_5];
        [_timeLabel setFont:[UIFont fontWithName:Font_Next_medium size:9]];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_timeLabel];
        _timeImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-30, SCREEN_WIDTH-40, 9, 9)];
        [_timeImage setImage:[UIImage imageNamed:Image_timeImage]];
        [self addSubview:_timeImage];
        
        _message = [[CXAHyperlinkLabel alloc] initWithFrame:CGRectMake(23, SCREEN_WIDTH-10, SCREEN_WIDTH-46, SCREEN_HEIGHT-SCREEN_WIDTH-84)];
        [_message setFont:[UIFont systemFontOfSize:14]];
        [_message setTextColor:Color_Text_2];
        [self addSubview:_message];

        
    }
    return self;
}

@end
