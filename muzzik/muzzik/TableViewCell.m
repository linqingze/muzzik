//
//  TableViewCell.m
//  muzzik
//
//  Created by muzzik on 15/4/29.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
        
    }
    return self;
}

-(void)setup{
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, SCREEN_WIDTH-80, 30)];
    self.label.numberOfLines = 0;
    self.label.lineBreakMode = NSLineBreakByWordWrapping;
    self.label.font = [UIFont fontWithName:Font_Next_Bold size:17];
    self.label.textColor = Color_Text_1;
    self.label.textAlignment = NSTextAlignmentCenter;
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self addSubview:self.label];
    self.backgroundColor=[UIColor clearColor];
}
@end
