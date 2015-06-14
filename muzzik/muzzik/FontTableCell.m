//
//  FontTableCell.m
//  muzzik
//
//  Created by muzzik on 15/6/4.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "FontTableCell.h"

@implementation FontTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
        
    }
    return self;
}

-(void)setup{
    _fontImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 15, 85, 20)];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self addSubview:_fontImage];
    _downloadProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 48, SCREEN_WIDTH, 2)];
    [self addSubview:_downloadProgress];
    _downButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-60, 5, 40, 40)];
    [_downButton setImage:[UIImage imageNamed:@"downloadImage"] forState:UIControlStateNormal];
    [_downButton addTarget:self action:@selector(startDownload) forControlEvents:UIControlEventTouchUpInside];
    _pieProgress = [[SDTransparentPieProgressView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-60, 5, 40, 40)];
    [self addSubview:_pieProgress];
    
    [self addSubview:_downButton];
}

-(void)startDownload{
    if (!self.keeperVC.downLoadList) {
        self.keeperVC.downLoadList = [NSMutableArray array];
    }
    [self.pieProgress setHidden:NO];
    [self.keeperVC.downLoadList addObject:self.dic];
    [self.keeperVC startDownload];
    
    
    
}
@end
