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
    self.overView.alpha = 0;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.layer.frame = CGRectMake(0, 20, SCREEN_WIDTH, 44);
    self.overView.alpha = 0;
    self.tabBarController.tabBar.layer.frame = CGRectMake(0, SCREEN_HEIGHT-48, SCREEN_WIDTH, 48);
}

- (void)followScrollView:(UIScrollView *)scrollableView
{
	self.scrollableView = scrollableView;
	self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
	[self.panGesture setMaximumNumberOfTouches:1];
	
	[self.panGesture setDelegate:self];
	[self.scrollableView addGestureRecognizer:self.panGesture];

	/* The navbar fadeout is achieved using an overView view with the same barTintColor.
	 this might be improved by adjusting the alpha component of every navbar child */
	CGRect frame = self.navigationController.navigationBar.frame;
	frame.origin = CGPointZero;
	self.overView = [[UIView alloc] initWithFrame:frame];
	if (!self.navigationController.navigationBar.barTintColor) {
		NSLog(@"[%s]: %@", __func__, @"Warning: no bar tint color set");
	}
//	[self.overView setBackgroundColor:self.navigationController.navigationBar.barTintColor];
    self.overView.backgroundColor = [UIColor whiteColor];
	[self.overView setUserInteractionEnabled:NO];
	[self.navigationController.navigationBar addSubview:self.overView];
	[self.overView setAlpha:0];

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
    NSLog(@"tabbar : %@",self.tabBarController.tabBar);
	CGPoint translation = [gesture translationInView:[self.scrollableView superview]];
//	NSLog(@"%f",translation.y);
    //标示 用户向上滑动或者向下滑动 (>0,向上滑动；<0,向下滑动)
	float delta = self.lastContentOffset - translation.y;
    float tabBarDelta = self.lastContentOffset - translation.y;
	self.lastContentOffset = translation.y;
	
	CGRect frame;
    CGRect tabBarFrame;
    
	if (delta > 0) {
//		if (self.isCollapsed) {
//			return;
//		}
		
		frame = self.navigationController.navigationBar.frame;
        tabBarFrame = self.tabBarController.tabBar.frame;
		if (frame.origin.y - delta < -24) {
			delta = frame.origin.y + 24;
		}
		frame.origin.y = MAX(-24, frame.origin.y - delta);
		self.navigationController.navigationBar.frame = frame;
		if (frame.origin.y == -24) {
			self.isCollapsed = YES;
			self.isExpanded = NO;
		}
        
        if (tabBarFrame.origin.y + tabBarDelta  > (SCREEN_HEIGHT)) {
            tabBarDelta = -(tabBarFrame.origin.y - SCREEN_HEIGHT);
        }
        tabBarFrame.origin.y = MIN(SCREEN_HEIGHT, tabBarFrame.origin.y + tabBarDelta);
        self.tabBarController.tabBar.frame = tabBarFrame;
        
		[self updateSizingWithDelta:delta withTabbar:tabBarDelta];
        
		
		// Keeps the view's scroll position steady until the navbar is gone
//		if ([self.scrollableView isKindOfClass:[UIScrollView class]]) {
//			[(UIScrollView*)self.scrollableView setContentOffset:CGPointMake(((UIScrollView*)self.scrollableView).contentOffset.x, ((UIScrollView*)self.scrollableView).contentOffset.y - delta)];
//		}
	}
	
	if (delta < 0) {
//		if (self.isExpanded) {
//			return;
//		}

		frame = self.navigationController.navigationBar.frame;
        tabBarFrame = self.tabBarController.tabBar.frame;
		if (frame.origin.y - delta > 20) {
			delta = frame.origin.y - 20;
		}
		frame.origin.y = MIN(20, frame.origin.y - delta);
		self.navigationController.navigationBar.frame = frame;
		
		if (frame.origin.y == 20) {
			self.isExpanded = YES;
			self.isCollapsed = NO;
		}
        
        if (tabBarFrame.origin.y + tabBarDelta < (SCREEN_HEIGHT-48)) {
            tabBarDelta = (SCREEN_HEIGHT-48) - tabBarFrame.origin.y;
        }
        tabBarFrame.origin.y = MAX((SCREEN_HEIGHT-48), tabBarFrame.origin.y+tabBarDelta);
        self.tabBarController.tabBar.frame = tabBarFrame;
        
        [self updateSizingWithDelta:delta withTabbar:tabBarDelta];
	}
	
	if ([gesture state] == UIGestureRecognizerStateEnded) {
		// Reset the nav bar if the scroll is partial
		self.lastContentOffset = 0;
		[self checkForPartialScroll];
	}
}


- (void)checkForPartialScroll
{
	CGFloat pos = self.navigationController.navigationBar.frame.origin.y;
//    CGFloat tabbarPos = self.tabBarController.tabBar.frame.origin.y;
	
	// Get back down
	if (pos >= -2) {  //下滑
		[UIView animateWithDuration:0.2 animations:^{
			CGRect frame;
            CGRect tabbarFrame;
			frame = self.navigationController.navigationBar.frame;
            tabbarFrame = self.tabBarController.tabBar.frame;
			CGFloat delta = frame.origin.y - 20;
            CGFloat tabbarDelta = tabbarFrame.origin.y - (SCREEN_HEIGHT-48);
			frame.origin.y = MIN(20, frame.origin.y - delta);
            tabbarFrame.origin.y = MAX((SCREEN_HEIGHT-48), tabbarFrame.origin.y-tabbarDelta);
			self.navigationController.navigationBar.frame = frame;
            self.tabBarController.tabBar.frame = tabbarFrame;
            
			self.isExpanded = YES;
			self.isCollapsed = NO;

			[self updateSizingWithDelta:delta withTabbar:tabbarDelta];
			
			// This line needs tweaking
//			 [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, self.scrollView.contentOffset.y - delta) animated:YES];
		}];
	} else {  //上滑
		// And back up
		[UIView animateWithDuration:0.2 animations:^{
			CGRect frame;
            CGRect tabbarFrame;
			frame = self.navigationController.navigationBar.frame;
            tabbarFrame = self.tabBarController.tabBar.frame;
			CGFloat delta = frame.origin.y + 24;
            CGFloat tabbarDelta = tabbarFrame.origin.y - SCREEN_HEIGHT;
			frame.origin.y = MAX(-24, frame.origin.y - delta);
            tabbarFrame.origin.y = MIN(SCREEN_HEIGHT, tabbarFrame.origin.y - tabbarDelta);
			self.navigationController.navigationBar.frame = frame;
            self.tabBarController.tabBar.frame = tabbarFrame;
			
			self.isExpanded = NO;
			self.isCollapsed = YES;
			
			[self updateSizingWithDelta:delta withTabbar:tabbarDelta];
		}];
	}
}

- (void)updateSizingWithDelta:(CGFloat)delta withTabbar:(CGFloat)tabbarDelta
{
	CGRect frame = self.navigationController.navigationBar.frame;
	
	float alpha = (frame.origin.y + 24) / frame.size.height;
	[self.overView setAlpha:1 - alpha];
	self.navigationController.navigationBar.tintColor = [self.navigationController.navigationBar.tintColor colorWithAlphaComponent:alpha];
	
	frame = self.scrollableView.superview.frame;
    frame.origin.y = self.navigationController.navigationBar.frame.origin.y-20;
//	frame.origin.y = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height;
	frame.size.height = frame.size.height + delta + tabbarDelta;
	self.scrollableView.superview.frame = frame;
	
	// Changing the layer's frame avoids UIWebView's glitchiness
	frame = self.scrollableView.layer.frame;
	frame.size.height = frame.size.height + delta + tabbarDelta;
	self.scrollableView.layer.frame = frame;
}


@end
