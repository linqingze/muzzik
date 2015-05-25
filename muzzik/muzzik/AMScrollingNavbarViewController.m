//
//  AMScrollingNavbarViewController.m
//  AMScrollingNavbar
//
//  Created by Andrea on 08/11/13.
//  Copyright (c) 2013 Andrea Mazzini. All rights reserved.
//

#import "AMScrollingNavbarViewController.h"
#import "AppConfiguration.h"

@interface AMScrollingNavbarViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, weak)	UIScrollView *scrollableView;
@property (assign, nonatomic) float lastContentOffset;
@property (assign, nonatomic) BOOL isCollapsed;
@property (assign, nonatomic) BOOL isExpanded;
@property (assign, nonatomic) BOOL isStatuBarHide;
@property (retain, nonatomic) UIButton *backBtn;

@end

@implementation AMScrollingNavbarViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    for (UIView *view in [self.navigationController.view subviews]) {
        if ([view isKindOfClass:[RFRadioView class]]) {
            RFRadioView *musicview = (RFRadioView *)view;
            if (musicview.IsShowDetail) {
                [musicview setAlpha:1];
            }else{
                [view setAlpha:0];
                [self.leftBtn setAlpha:0];
                [self.rightBtn setAlpha:0];
                [self.headerView setAlpha:0];
            }
            
            break;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    for (UIView *view in [self.navigationController.view subviews]) {
        if ([view isKindOfClass:[RFRadioView class]]) {
            [view setAlpha:0];
            break;
        }
    }
    [self.leftBtn setAlpha:1];
    [self.rightBtn setAlpha:1];
    [self.headerView setAlpha:1];
    
}

- (void)followScrollView:(UIScrollView *)scrollableView
{
	self.scrollableView = scrollableView;
	self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
	[self.panGesture setMaximumNumberOfTouches:1];
	
	[self.panGesture setDelegate:self];
	[self.scrollableView addGestureRecognizer:self.panGesture];


}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	return YES;
}

// called when a gesture recognizer attempts to transition out of UIGestureRecognizerStatePossible. returning NO causes it to transition to UIGestureRecognizerStateFailed
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

// called when the recognition of one of gestureRecognizer or otherGestureRecognizer would be blocked by the other
// return YES to allow both to recognize simultaneously. the default implementation returns NO (by default no two gestures can be recognized simultaneously)
//
// note: returning YES is guaranteed to allow simultaneous recognition. returning NO is not guaranteed to prevent simultaneous recognition, as the other gesture's delegate may return YES


// called before touchesBegan:withEvent: is called on the gesture recognizer for a new touch. return NO to prevent the gesture recognizer from seeing this touch
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}


- (void)handlePan:(UIPanGestureRecognizer*)gesture
{
    CGPoint translation = [gesture translationInView:[self.scrollableView superview]];
    NSLog(@"%f",translation.y);
    //标示 用户向上滑动或者向下滑动 (>0,向上滑动；<0,向下滑动)
    if ([gesture state] == UIGestureRecognizerStateBegan) {
        self.lastContentOffset = translation.y;
    }
    float delta = self.lastContentOffset - translation.y;
    for (UIView *view in [self.navigationController.view subviews]) {
        if ([view isKindOfClass:[RFRadioView class]]) {
            RFRadioView *musicView = (RFRadioView*)view;
            if (self.lastContentOffset != 0 &&delta < -2 &&[[musicPlayer shareClass].MusicArray count]>0) {
                musicView.isOpen = YES;
                [UIView animateWithDuration:Play_timeinterval animations:^{
                    [self.leftBtn setAlpha:0];
                    [self.rightBtn setAlpha:0];
                    [self.headerView setAlpha:0];
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:Play_timeinterval animations:^{
                        [musicView setAlpha:1];
                    }];
                    
                }];
            }
            
            if (delta > 2&&self.lastContentOffset != 0  ) {
                musicView.isOpen = NO;
                musicView.IsShowDetail = NO;
                [UIView animateWithDuration:Play_timeinterval animations:^{
                    [musicView setAlpha:0];
                }completion:^(BOOL finished) {
                    [UIView animateWithDuration:Play_timeinterval animations:^{
                        [self.leftBtn setAlpha:1];
                        [self.rightBtn setAlpha:1];
                        [self.headerView setAlpha:1];
                        
                    }];
                }];
                
                
            }
            break;
        }
    }
    if ([gesture state] == UIGestureRecognizerStateEnded) {
        // Reset the nav bar if the scroll is partial
        self.lastContentOffset = 0;
    }
}





@end
