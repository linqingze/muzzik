//
//  NotifyButton.m
//  muzzik
//
//  Created by muzzik on 15/6/27.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "NotifyButton.h"
#import "NotificationVC.h"
@implementation NotifyButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self addTarget:self action:@selector(showNotify) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}
-(void)showNotify{
    [self setHidden:YES];
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UINavigationController *nac = (UINavigationController *)app.window.rootViewController;
    for (UIViewController *vc in nac.viewControllers) {
        if ([vc isKindOfClass:[RootViewController class]]) {
            RootViewController *rootvc = (RootViewController*)vc;
            [rootvc seeMessage];
            break;
        }
    }
    if ([nac.viewControllers.lastObject isKindOfClass:[NotificationVC class]]) {
        NotificationVC *currentVC = (NotificationVC *)nac.viewControllers.lastObject;
        [currentVC reloadDataSource];
        
    }else{
        NotificationVC *notify = [[NotificationVC alloc] init];
        [nac pushViewController:notify animated:YES];
    }
    
}
@end
