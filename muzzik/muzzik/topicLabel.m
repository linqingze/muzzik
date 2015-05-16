//
//  topicLabel.m
//  muzzik
//
//  Created by muzzik on 15/5/13.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "topicLabel.h"
#import "UIImageView+WebCache.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "NormalCell.h"
#import "TopicHeaderView.h"
#import "appConfiguration.h"
#import <MediaPlayer/MediaPlayer.h>
#import "userInfo.h"
#import "playListController.h"
#import "CXAHyperlinkLabel.h"
#import "ChooseMusicVC.h"
#import "LoginViewController.h"
#import "UIScrollView+DXRefresh.h"
#import "UIButton+WebCache.h"
#import "showUserVC.h"
#import "NormalNoCardCell.h"
#import "DetaiMuzzikVC.h"
#import "MuzzikCard.h"
#import "MuzzikNoCardCell.h"
#import "userDetailInfo.h"
#import "TopicDetail.h"
@implementation topicLabel
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Tapped:)];
        [self addGestureRecognizer:tap];
        
        self.clipsToBounds = YES;
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.userInteractionEnabled = YES;
    }
    return self;
}
-(void)setText:(NSString *)text font:(UIFont *) font color:(long)color{
    UIColor *mycolor;
    if (color == 1) {
        mycolor = Color_Action_Button_1;
    }else if(color == 2){
        mycolor = Color_Action_Button_2;
    }else{
        mycolor = Color_Action_Button_3;
    }
    [super setTextColor:[UIColor whiteColor]];
    [super setBackgroundColor:mycolor];
    [super setText:[NSString stringWithFormat:@"#%@#",text]];
    [super setFont:font];
    [self sizeToFit];
    
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width+6, self.frame.size.height+6)];
    self.textAlignment = NSTextAlignmentCenter;
    self.adjustsFontSizeToFitWidth = YES;
    self.layer.cornerRadius = 3;
    self.clipsToBounds = YES;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void) Tapped:(UIGestureRecognizer *) gesture
{
    if ([self.delegate respondsToSelector:@selector(tappedWithObject:)])
    {
        [UIView animateWithDuration:0.2 animations:^{
            [self setFrame:CGRectMake(self.frame.origin.x+10, self.frame.origin.y+4, self.frame.size.width-20, self.frame.size.height-8)];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                [self setFrame:CGRectMake(self.frame.origin.x-10, self.frame.origin.y-4, self.frame.size.width+20, self.frame.size.height+8)];
            } completion:^(BOOL finished) {
                [self.delegate tappedWithObject:self];
            }];
        }];
        
    }
}
@end
