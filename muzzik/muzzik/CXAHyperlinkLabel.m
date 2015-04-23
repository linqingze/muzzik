//
//  CXAHyperlinkLabel.m
//  CXAHyperlinkLabelDemo
//
//  Created by Chen Xian'an on 1/3/13.
//  Updated by Lin Qingze on 16/3/15
//
#import "appConfiguration.h"
#import "CXAHyperlinkLabel.h"
#import "NSAttributedString+CXACoreTextFrameSize.h"
#import <CoreText/CoreText.h>
#import "NSString+CXAHyperlinkParser.h"
#define ZERORANGE ((NSRange){0, 0})
#define LONGPRESS_DURATION .3
#define LONGPRESS_ARG @[_touchingURL, [NSValue valueWithRange:_touchingURLRange], _touchingRects]

@interface CXAHyperlinkLabel(){
  CFArrayRef _lines;
  CGRect *_lineImageRectsCArray;
  NSUInteger _numLines;
  NSURL *_touchingURL;
  NSRange _touchingURLRange;
  NSMutableArray *_touchingRects;
  NSRangePointer _rangesCArray;
  NSAttributedString *_attributedTextBeforeTouching;
  NSMutableArray *_URLs;
  NSMutableArray *_URLRanges;
}

- (void)drawRun:(CTRunRef)run inContext:(CGContextRef)context lineOrigin:(CGPoint)lineOrigin isTouchingRun:(BOOL)isTouchingRun;
- (void)handleTouches:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)highlightTouchingLinkAtRange:(NSRange)range;
- (void)reset;

@end

@implementation CXAHyperlinkLabel

#pragma mark -
- (id)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]){
    _linkAttributesWhenTouching = @{ NSBackgroundColorAttributeName : [UIColor colorWithHue:.41 saturation:.00 brightness:.76 alpha:1.00] };
    self.userInteractionEnabled = YES;
  }
  
  return self;
}

- (void)dealloc
{
  if (_lines)
    CFRelease(_lines);
  
  if (_lineImageRectsCArray)
    free(_lineImageRectsCArray);
  
  if (_rangesCArray)
    free(_rangesCArray);
}

#pragma mark -
- (void)setURL:(NSURL *)URL
      forRange:(NSRange)range
{
  if (!_URLs){
    _URLs = [@[] mutableCopy];
    _URLRanges = [@[] mutableCopy];
  }
  
  NSValue *rng = [NSValue valueWithRange:range];
  NSUInteger idx = [_URLRanges indexOfObject:rng inSortedRange:NSMakeRange(0, [_URLRanges count]) options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(id obj1, id obj2){
    NSRange r1 = [obj1 rangeValue];
    NSRange r2 = [obj2 rangeValue];
    if (r1.location < r2.location)
      return NSOrderedAscending;
    
    if (r1.location > r2.location)
      return NSOrderedDescending;
    
    return NSOrderedSame;
  }];
    _URLs = [NSMutableArray arrayWithArray:_URLs];
    _URLRanges = [NSMutableArray arrayWithArray:_URLRanges];
  [_URLs insertObject:URL atIndex:idx];
  [_URLRanges insertObject:rng atIndex:idx];
}

- (void)setURLs:(NSMutableArray *)URLs
      forRanges:(NSMutableArray *)ranges
{
  if (!_URLs){
    _URLs = [URLs mutableCopy];
    _URLRanges = [ranges mutableCopy];
    
    return;
  }
  
  [URLs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
    [self setURL:obj forRange:[ranges[idx] rangeValue]];
  }];
}
- (void)removeURLForRange:(NSRange)range
{
  NSValue *v = [NSValue valueWithRange:range];
  NSUInteger idx = [_URLRanges indexOfObject:v];
  if (idx == NSNotFound)
    return;
  
  [_URLRanges removeObjectAtIndex:idx];
  [_URLs removeObjectAtIndex:idx];
}

- (void)removeAllURLs
{
  _URLs = nil;
  _URLRanges = nil;
}

- (NSURL *)URLAtPoint:(CGPoint)point
       effectiveRange:(NSRangePointer)effectiveRange
{
  if (effectiveRange)
    *effectiveRange = ZERORANGE;
  
  if (![_URLRanges count] ||
      !CGRectContainsPoint(self.bounds, point))
    return nil;
  
  void *found = bsearch_b(&point, _lineImageRectsCArray, _numLines, sizeof(CGRect), ^int(const void *key, const void *el){
    CGPoint *p = (CGPoint *)key;
    CGRect *r = (CGRect *)el;
    if (CGRectContainsPoint(*r, *p))
      return 0;
    
    if  (p->y > CGRectGetMaxY(*r))
      return 1;
    
    return -1;
  });
  
  if (!found)
    return nil;
  
  size_t idx = (CGRect *)found - _lineImageRectsCArray;
  CTLineRef line = CFArrayGetValueAtIndex(_lines, idx);
  CFIndex strIdx = CTLineGetStringIndexForPosition(line, point);
  if (strIdx == kCFNotFound)
    return nil;
  
  CGFloat offset = CTLineGetOffsetForStringIndex(line, strIdx, NULL);
  offset += _lineImageRectsCArray[idx].origin.x;
  if (point.x < offset)
    strIdx--;
  
  found = bsearch_b(&strIdx, _rangesCArray, [_URLRanges count], sizeof(NSRange), ^int(const void *key, const void *el){
    NSUInteger *idx = (NSUInteger *)key;
    NSRangePointer rng = (NSRangePointer)el;
    if (NSLocationInRange(*idx, *rng))
      return 0;
    
    if (*idx < rng->location)
      return -1;
    
    return 1;
  });
  
  if (!found)
    return nil;
  
  idx = (NSRangePointer)found - _rangesCArray;
  if (effectiveRange)
    *effectiveRange = [_URLRanges[idx] rangeValue];
  
  return _URLs[idx];
}

#pragma mark - 
- (void)drawTextInRect:(CGRect)rect
{
  if (!self.attributedText)
    return;
  
  CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.attributedText);
  CGPathRef path = CGPathCreateWithRect(rect, NULL);  
  CGFloat rectHeight = CGRectGetHeight(rect);
  CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [self.attributedText length]), path, NULL);
  CGContextRef context = UIGraphicsGetCurrentContext();
  if (_lines)
    CFRelease(_lines);
  
  _lines = CTFrameGetLines(frame);  
  _numLines = CFArrayGetCount(_lines);
  CGPoint *lineOrigins = malloc(sizeof(CGPoint) * _numLines);
  CTFrameGetLineOrigins(frame, CFRangeMake(0, _numLines), lineOrigins);
  if (_lineImageRectsCArray)
    free(_lineImageRectsCArray);
  
  _lineImageRectsCArray = malloc(sizeof(CGRect) * _numLines);
  for (CFIndex i=0; i<_numLines; i++){
    CTLineRef line = CFArrayGetValueAtIndex(_lines, i);
    CGRect imgBounds = CTLineGetImageBounds(line, context);
    CGFloat ascender, descender, leading;
    CTLineGetTypographicBounds(line, &ascender, &descender, &leading);
    CGFloat filpY = CGRectGetHeight(self.bounds) - lineOrigins[i].y - ascender;
    imgBounds.origin.y = filpY - imgBounds.origin.y;
    _lineImageRectsCArray[i] = imgBounds;
  }
  
  if (_rangesCArray)
    free(_rangesCArray);
  
  _rangesCArray = malloc(sizeof(NSRange) * [_URLs count]);
  [_URLRanges enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
    _rangesCArray[idx] = [obj rangeValue];
  }];
  
  if (!_touchingRects)
    _touchingRects = [@[] mutableCopy];
  else
    [_touchingRects removeAllObjects];
  
  CGContextTranslateCTM(context, 0, rectHeight);
  CGContextScaleCTM(context, 1, -1);
  CGContextSetTextMatrix(context, CGAffineTransformIdentity);
  [(__bridge NSArray *)_lines enumerateObjectsUsingBlock:^(id lineObj, NSUInteger lineIdx, BOOL *lineStop){
    CTLineRef line = (__bridge CTLineRef)lineObj;
    CFArrayRef runs = CTLineGetGlyphRuns(line);
    [(__bridge NSArray *)runs enumerateObjectsUsingBlock:^(id runObj, NSUInteger runIdx, BOOL *runStop){
      CTRunRef run = (__bridge CTRunRef)runObj;
      CFRange cfrng = CTRunGetStringRange(run);
      [self drawRun:run inContext:context lineOrigin:lineOrigins[lineIdx] isTouchingRun:NSLocationInRange(cfrng.location, _touchingURLRange)];
    }];
  }];
  
  free(lineOrigins);
  CFRelease(framesetter);
  CFRelease(path);
}

- (CGSize)sizeThatFits:(CGSize)size
{
  return [self.attributedText cxa_coreTextFrameSizeWithConstraints:size];
}

- (void)sizeToFit
{
  CGSize toFitSize = self.superview ? self.superview.bounds.size : [UIScreen mainScreen].bounds.size;
  CGSize size = [self sizeThatFits:toFitSize];
  self.frame = (CGRect){self.frame.origin, size};
}

#pragma mark -
- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
  if (!_attributedTextBeforeTouching)
    _attributedTextBeforeTouching = self.attributedText;
    [self handleTouches:touches withEvent:event];
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches
           withEvent:(UIEvent *)event
{
  [self URLAtPoint:[[touches anyObject] locationInView:self] effectiveRange:&_touchingURLRange];
    
  if (_touchingURL){
      [self pressWithUrl:_touchingURL AndRange:_touchingURLRange];
  } else 
    [super touchesEnded:touches withEvent:event];
  
  [self reset];
}

- (void)touchesMoved:(NSSet *)touches
           withEvent:(UIEvent *)event
{
  if (_touchingURL)
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(longpressWithUrl:AndRange:) object:nil];
  
  [self handleTouches:touches withEvent:event];
  if (!_touchingURL)
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches
               withEvent:(UIEvent *)event
{
  if (_touchingURL)
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(longpressWithUrl:AndRange:) object:nil];
  
  [super touchesCancelled:touches withEvent:event];
  [self reset];
}

#pragma mark - privates
- (void)drawRun:(CTRunRef)run
      inContext:(CGContextRef)context
     lineOrigin:(CGPoint)lineOrigin
  isTouchingRun:(BOOL)isTouchingRun
{
  CFRange range = CFRangeMake(0, 0);
  CGFloat lineOriginX = ceilf(lineOrigin.x);
  CGFloat lineOriginY = ceilf(lineOrigin.y);
  const CGPoint *posPtr = CTRunGetPositionsPtr(run);
  CGPoint *pos = NULL;
  NSDictionary *attrs = (__bridge NSDictionary *)CTRunGetAttributes(run);
  UIColor *bgColor = attrs[NSBackgroundColorAttributeName];
  if (isTouchingRun || bgColor){
    if (!posPtr){
      pos = malloc(sizeof(CGPoint));
      CTRunGetPositions(run, CFRangeMake(0, 1), pos);
      posPtr = pos;
    }
    CGFloat ascender, descender, leading;
    CGFloat width = CTRunGetTypographicBounds(run, range, &ascender, &descender, &leading);
    CGRect rect = CGRectMake(lineOriginX + posPtr->x, lineOriginY - descender, width, ascender + descender);
    rect = CGRectIntegral(rect);
    rect = CGRectInset(rect, -2, -2);
    if (lineOriginX + posPtr->x <= 0){
      rect.origin.x += 2;
      rect.size.width -= 2;
    }
    
    if (lineOriginY <= 0){
      rect.origin.y += 2;
      rect.size.height -= 2;
    }
    
    if (bgColor){
      UIBezierPath *bp = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:3.];
      CGContextSaveGState(context);
      CGContextAddPath(context, bp.CGPath);
      CGContextSetFillColorWithColor(context, bgColor.CGColor);
      CGContextFillPath(context);
      CGContextRestoreGState(context);
    }
    
    if (isTouchingRun){
      rect.origin.y = CGRectGetHeight(self.bounds) - CGRectGetMaxY(rect);
      [_touchingRects addObject:[NSValue valueWithCGRect:rect]];
    }
  }
  
  NSShadow *shadow = attrs[NSShadowAttributeName];
  if (shadow){
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, [shadow.shadowColor CGColor]);
  }
  
  CGContextSetTextPosition(context, lineOriginX, lineOriginY);
  CTRunDraw(run, context, range);
  if (shadow)
    CGContextRestoreGState(context);
  
  NSNumber *underlineStyle = attrs[NSUnderlineStyleAttributeName];
  if (underlineStyle && [underlineStyle intValue] == NSUnderlineStyleSingle){
    UIColor *fgColor = attrs[NSForegroundColorAttributeName];
    if (!fgColor)
      fgColor = [UIColor blackColor];
    
    CGFloat width = CTRunGetTypographicBounds(run, range, NULL, NULL, NULL);
    if (!posPtr){
      pos = malloc(sizeof(CGPoint));
      CTRunGetPositions(run, CFRangeMake(0, 1), pos);
      posPtr = pos;
    }
    
    CGContextSetStrokeColorWithColor(context, fgColor.CGColor);
    CGContextSetLineWidth(context, 1.);
    CGContextMoveToPoint(context, lineOriginX + posPtr->x, lineOriginY-1.5);
    CGContextAddLineToPoint(context, lineOriginX + posPtr->x + width, lineOriginY-1.5);
    CGContextSaveGState(context);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    if (pos)
      free(pos);
  }
}
- (void)setText:(NSString *)text{
    [super setText:text];
    NSAttributedString *as = [self attributedStringWith:text];
    self.numberOfLines = 0;
    self.backgroundColor = [UIColor clearColor];
    self.attributedText = as;
    [self setURLs:_URLs forRanges:_URLRanges];
    
}
- (NSAttributedString *)attributedStringWith:(NSString *)text
{
    NSMutableArray *URLs;
    NSMutableArray *URLRanges;
    UIColor *color = [UIColor blackColor];
    UIFont *font = [UIFont systemFontOfSize:Font_Size_Muzzik_Message];
    NSMutableParagraphStyle *mps = [[NSMutableParagraphStyle alloc] init];
    mps.lineSpacing = ceilf(font.pointSize * .5);
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor whiteColor];
    shadow.shadowOffset = CGSizeMake(0, 1);
    NSString *str = [NSString stringWithHTMLText:text baseURL:[NSURL URLWithString:BaseURL] URLs:&URLs URLRanges:&URLRanges];
    NSMutableAttributedString *mas = [[NSMutableAttributedString alloc] initWithString:str attributes:@
                                      {
                                          NSForegroundColorAttributeName : color,
                                          NSFontAttributeName            : font,
                                          NSParagraphStyleAttributeName  : mps,
                                          NSShadowAttributeName          : shadow,
                                      }];
    [URLRanges enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        [mas addAttributes:@
         {
             NSForegroundColorAttributeName : [UIColor blueColor],
             NSUnderlineStyleAttributeName  : @(NSUnderlineStyleNone)
         } range:[obj rangeValue]];
    }];
    
    _URLs = URLs;
    _URLRanges = URLRanges;
    
    return [mas copy];
}
- (void)handleTouches:(NSSet *)touches
            withEvent:(UIEvent *)event
{
  NSRange prevHitURLRange = _touchingURLRange;
  _touchingURL = [self URLAtPoint:[[touches anyObject] locationInView:self] effectiveRange:&_touchingURLRange];
  if (_touchingURLRange.length){
    if (!prevHitURLRange.length ||
        !NSEqualRanges(prevHitURLRange, _touchingURLRange))
      [self highlightTouchingLinkAtRange:_touchingURLRange];
  } else {
    if (prevHitURLRange.length)
        self.attributedText = _attributedTextBeforeTouching;
  }
}

- (void)highlightTouchingLinkAtRange:(NSRange)range
{
  if (!self.linkAttributesWhenTouching)
    return;
  
  NSMutableAttributedString *mas = [_attributedTextBeforeTouching mutableCopy];
  [mas addAttributes:self.linkAttributesWhenTouching range:range];
  self.attributedText = mas;
}

- (void)reset
{
  if (_touchingURL){
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setAttributedText:) object:_attributedTextBeforeTouching];
    [self performSelector:@selector(setAttributedText:) withObject:_attributedTextBeforeTouching afterDelay:.3];
  }
  
  _touchingURLRange = ZERORANGE;
  _touchingURL = nil;
  _attributedTextBeforeTouching = nil;
}

-(void)longpressWithUrl:(NSURL *)url AndRange:(NSRange)rang{
    NSLog(@"long press");
    if ([self.delegate respondsToSelector:@selector(longpressWithUrl:AndRange:)]) {
        [self.delegate longpressWithUrl:_touchingURL AndRange:_touchingURLRange];
    }
}
-(void)pressWithUrl:(NSURL *)url AndRange:(NSRange)rang{

    if ([self.delegate respondsToSelector:@selector(pressWithUrl:AndRange:)]) {
        [self.delegate pressWithUrl:_touchingURL AndRange:_touchingURLRange];
    }
}
@end
