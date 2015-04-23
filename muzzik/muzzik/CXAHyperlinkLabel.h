//
//  CXAHyperlinkLabel.h
//  CXAHyperlinkLabelDemo
//
//  Created by Chen Xian'an on 1/3/13.
//  Copyright (c) 2013 lazyapps. All rights reserved.
//  Updated by Lin Qingze on 16/3/15
//

#import <UIKit/UIKit.h>

@class CXAHyperlinkLabel;

// The URL may be broken into 2 or more lines, that's why CXAHyperlinkLabel provide textRects but not textRect

@protocol CXDelegate <NSObject>

@optional
-(void)pressWithUrl:(NSURL *)url AndRange:(NSRange)rang;
-(void)longpressWithUrl:(NSURL *)url AndRange:(NSRange)rang;
@end


@interface CXAHyperlinkLabel : UILabel

@property (nonatomic, strong) NSDictionary *linkAttributesWhenTouching;
@property (nonatomic, unsafe_unretained) id<CXDelegate> delegate;
- (void)setText:(NSString *)text;
- (void)setURL:(NSURL *)URL forRange:(NSRange)range;
- (void)setURLs:(NSMutableArray *)URLs forRanges:(NSMutableArray *)ranges;
- (void)removeURLForRange:(NSRange)range;
- (void)removeAllURLs;
- (NSURL *)URLAtPoint:(CGPoint)point effectiveRange:(NSRangePointer)effectiveRange;

@end
