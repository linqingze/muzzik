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
    _timeImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 16, 10, 10)];
    [_timeImage setImage:[UIImage imageNamed:Image_timeImage]];
    [self addSubview:_timeImage];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 16, SCREEN_WIDTH-150, 10)];
    [_timeLabel setFont:[UIFont fontWithName:Font_Next_medium size:8]];
    [_timeLabel setTextColor:Color_line_1];
    [self addSubview:_timeLabel];
    
    _message = [[UILabel alloc] initWithFrame:CGRectMake(16, 35, SCREEN_WIDTH-32, 15)];
    _message.font = [UIFont systemFontOfSize:12];
    [_message setTextColor:Color_Text_1];
    [self addSubview:_message];
    
    
    _deleButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-100, 0, 40, 40)];
    [_deleButton setImage:[UIImage imageNamed:Image_detaildeleteImage] forState:UIControlStateNormal];
    [_deleButton addTarget:self action:@selector(deleAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_deleButton];



}

@end
