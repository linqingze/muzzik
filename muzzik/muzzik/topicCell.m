//
//  topicCell.m
//  muzzik
//
//  Created by 林清泽 on 15/4/4.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "topicCell.h"

@implementation topicCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.topicLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 100, 20)];
        [self.topicLabel setFont:[UIFont systemFontOfSize:12]];
        [self addSubview:self.topicLabel];
    }
    return self;
}
@end
