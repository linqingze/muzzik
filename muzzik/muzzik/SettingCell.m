//
//  SettingCell.m
//  muzzik
//
//  Created by muzzik on 15/5/11.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "SettingCell.h"

@implementation SettingCell

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
    _label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-100, 60)];
    [_label setFont:[UIFont systemFontOfSize:14]];
    _label.textColor = Color_Text_1;
    [self addSubview:_label];
    _shakeButton = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-50, 12, 36, 36)];
    [self addSubview:_shakeButton];
    [MuzzikItem addLineOnView:self heightPoint:59 toLeft:13 toRight:13 withColor:Color_line_1];
}

@end
