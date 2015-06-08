//
//  TeachViewController.h
//  ShopUU
//
//  Created by iOS Fangli on 14/12/19.
//  Copyright (c) 2014年 IOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseNagationViewController.h"
@interface TeachViewController :BaseNagationViewController <UIWebViewDelegate>

@property (nonatomic,retain)UIWebView *teachWebView;
@property (nonatomic,copy) NSString *showType;

@end
