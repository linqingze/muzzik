//
//  ActivityUserCell.m
//  muzzik
//
//  Created by 林清泽 on 15/4/4.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "ActivityUserCell.h"

@implementation ActivityUserCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.userHeaderImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, Cell_width, Cell_width)];
        self.userHeaderImage.layer.cornerRadius = Cell_width/2;
        self.userHeaderImage.clipsToBounds = YES;
        [self addSubview:self.userHeaderImage];
        
        self.addUserButton = [[UIButton alloc] initWithFrame:CGRectMake(Cell_width*2/3.0, Cell_width*2/3.0, Cell_width/3.0, Cell_width/3.0)];
        self.addUserButton.layer.cornerRadius = Cell_width/6.0;
        self.addUserButton.clipsToBounds = YES;
        [self.addUserButton addTarget:self action:@selector(attentionForUser) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.addUserButton];
        
        self.userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 100, 20)];
        [self.userNameLabel setFont:[UIFont systemFontOfSize:12]];
        [self addSubview:self.userNameLabel];
    }
    return self;
}

-(void)attentionForUser{
    NSLog(@"123");
}
@end
