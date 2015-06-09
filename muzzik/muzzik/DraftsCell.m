//
//  DraftsCell.m
//  muzzik
//
//  Created by muzzik on 15/6/7.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "DraftsCell.h"

@implementation DraftsCell

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
    _timeImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 9, 9)];
    [_timeImage setImage:[UIImage imageNamed:Image_timeImage]];
    [self addSubview:_timeImage];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 10, 100, 10)];
    [_timeLabel setFont:[UIFont fontWithName:Font_Next_medium size:8]];
    [_timeLabel setTextColor:Color_line_1];
    [self addSubview:_timeLabel];
    
    _message = [[UILabel alloc] initWithFrame:CGRectMake(20, 35, SCREEN_WIDTH-140, 15)];
    _message.font = [UIFont systemFontOfSize:13];
    [_message setTextColor:Color_Text_1];
    [self addSubview:_message];
    self.songName = [[UILabel alloc] initWithFrame:CGRectMake(150, 10, SCREEN_WIDTH-170, 15)];
    [self.songName setFont:[UIFont fontWithName:Font_Next_Bold size:14]];
    [self.songName setTextColor:[UIColor colorWithHexString:@"777777"]];
    [self addSubview:self.songName];
    self.songName.textAlignment = NSTextAlignmentRight;
    self.Artist = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-130, 28, 110, 12)];
    [self.Artist setFont:[UIFont fontWithName:Font_Next_DemiBold size:12]];
    [self.Artist setTextColor:[UIColor colorWithHexString:@"999999"]];
    self.Artist.textAlignment = NSTextAlignmentRight;
    [self addSubview:self.Artist];
    
    
    [MuzzikItem addLineOnView:self heightPoint:69 toLeft:20 toRight:20 withColor:Color_line_1];

}

@end
