//
//  UuCheck.h
//  ShopUU
//
//  Created by kevin's mac on 14-10-23.
//  Copyright (c) 2014年 IOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonCryptor.h>
@interface MuzzikItem : NSObject


+(MuzzikItem *) shareClass;
+ (BOOL)isPureInt:(NSString*)string;
+(BOOL)checkIsPhoneNumForString:(NSString *)string;
+(BOOL)checkIsShipingNumForString:(NSString *)string;
+ (UIImage *)buttonImageFromColor:(UIColor *)color;
+(void) showView:(UILabel *)view Text:(NSString *)string;
+(void) showTipsAtView:(UIView *)view xPoint:(CGFloat)x yPoint:(CGFloat) y text:(NSString *)text;
+(void) alterInAndOutWithView:(UIView*)view;

+(float) heightForLabel: (UILabel *)Label WithText: (NSString *) strText;
+(float) heightForTextView: (UITextView *)textView WithText: (NSString *) strText;
+(float) heightForAttributeString: (UILabel *)Label WithText: (NSMutableAttributedString *) strText;

+(NSMutableAttributedString *) AttributedStringByMoney:(NSString *) orginString;

+ (NSString *)base64StringFromText:(NSString *)text withKey:(NSString*)key;   //对文本进行加密
+ (NSString *)textFromBase64String:(NSString *)base64 withKey:(NSString*)key; //对文本进行解密
+ (UIImage*) createImageWithColor: (UIColor*) color;      //创建图片
+ (void)addMessageToLocal:(NSMutableDictionary *)message;
+ (void)removeMessageFromLocal;
+ (NSMutableDictionary *)messageFromLocal;
+ (BOOL) saveImageToCacheDir:(NSString *)directoryPath Image:(UIImage *)image imageName:(NSString *)imageName ImageType:(NSString *)imageType;
+(NSData*) loadImageData:(NSString *)directoryPath Name:(NSString *)imageName;
//加下划线
+(void)addLineOnView:(UIView *)view heightPoint:(CGFloat)height toLeft:(CGFloat)left toRight:(CGFloat)right withColor:(UIColor*)color;
+(void)addLabelOnView:(UIView *)view localPoint:(CGFloat)local toLeft:(CGFloat)left toRight:(CGFloat)right height:(CGFloat)height withColor:(UIColor*)color font:(UIFont*)font text:(NSString *) text;
+(NSAttributedString *)formatAttrItem:(NSString *)content color:(UIColor *)color font:(UIFont *)font;
@end
