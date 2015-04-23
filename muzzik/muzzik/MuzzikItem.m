//
//  UuCheck.m
//  ShopUU
//
//  Created by kevin's mac on 14-10-23.
//  Copyright (c) 2014年 IOS. All rights reserved.
//

#import "MuzzikItem.h"

@implementation MuzzikItem
static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
+(MuzzikItem *) shareClass{
    static MuzzikItem *myclass=nil;
    if(!myclass){
        myclass = [[super allocWithZone:NULL] init];
    }
    return myclass;
}

+(id)allocWithZone:(NSZone *)zone{
    return [self shareClass];
}

+(BOOL)checkIsShipingNumForString:(NSString *)string{
    return string.length==12 &&[MuzzikItem isPureInt:string];
}
+(float) heightForTextView: (UITextView *)textView WithText: (NSString *) strText{
    //float fPadding = 16.0; // 8.0px x 2
    CGSize constraint = CGSizeMake(textView.frame.size.width, CGFLOAT_MAX);
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:textView.font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    CGRect size = [strText boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    return size.size.height;
}
+(float) heightForLabel: (UILabel *)Label WithText: (NSString *) strText{
    //float fPadding = 16.0; // 8.0px x 2
    CGSize constraint = CGSizeMake(Label.frame.size.width, CGFLOAT_MAX);
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:Label.font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    CGRect size = [strText boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    return size.size.height;
}
+(float) heightForAttributeString: (UILabel *)Label WithText: (NSMutableAttributedString *) strText{
    //float fPadding = 16.0; // 8.0px x 2
    CGSize constraint = CGSizeMake(Label.frame.size.width, CGFLOAT_MAX);
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
//    NSDictionary *attributes = @{NSFontAttributeName:Label.font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    CGRect rect = [strText boundingRectWithSize:constraint options:(NSStringDrawingUsesLineFragmentOrigin) context:nil];
    return rect.size.height;
}

+ (UIImage*) createImageWithColor: (UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 300.0f, 50.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
+ (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}
+(BOOL)checkIsPhoneNumForString:(NSString *)string{
    return string.length==11 &&[MuzzikItem isPureInt:string];
}
+ (UIImage *)buttonImageFromColor:(UIColor *)color{
    CGRect rect = CGRectMake(0, 0, [ UIScreen mainScreen ].bounds.size.width, 64);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
+(void)alterInAndOutWithView:(UILabel *)view{
    [view setHidden:NO];
    [UIView animateWithDuration:0.3 animations:^{
        [view setAlpha:1];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:5 animations:^{
            [view setAlpha:0];
        }];
        
    }];
}

+(NSMutableAttributedString *) AttributedStringByMoney:(NSString *) orginString{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:orginString];
    NSRange indexRange = [orginString rangeOfString:@"￥"];
    if (indexRange.location != NSNotFound) {
        UIFont *baseFont = [UIFont fontWithName:@"STYuanti-SC-Regular" size:12];
        UIFont *moneyFont = [UIFont fontWithName:@"STYuanti-SC-Regular" size:20];
        [attrString addAttribute:NSFontAttributeName value:moneyFont range:NSMakeRange(indexRange.location, attrString.length-indexRange.location)];
        [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:171.0/255.0 green:33.0/255.0 blue:31.0/255.0 alpha:1] range:NSMakeRange(indexRange.location, attrString.length-indexRange.location)];
        if (indexRange.location>0) {
            [attrString addAttribute:NSFontAttributeName value:baseFont range:NSMakeRange(0, indexRange.location)];
        }
    }
    return attrString;
}
//+ (NSString *)base64StringFromText:(NSString *)text
//{
//    if (text && ![text isEqualToString:LocalStr_None]) {
//        //取项目的bundleIdentifier作为KEY
//        NSString *key = [[NSBundle mainBundle] bundleIdentifier];
//        NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
//        //IOS 自带DES加密 Begin
//        data = [self DESEncrypt:data WithKey:key];
//        //IOS 自带DES加密 End
//        return [self base64EncodedStringFrom:data];
//    }
//    else {
//        return LocalStr_None;
//    }
//}

//+ (NSString *)textFromBase64String:(NSString *)base64
//{
//    if (base64 && ![base64 isEqualToString:LocalStr_None]) {
//        //取项目的bundleIdentifier作为KEY
//        NSString *key = [[NSBundle mainBundle] bundleIdentifier];
//        NSData *data = [self dataWithBase64EncodedString:base64];
//        //IOS 自带DES解密 Begin
//        data = [self DESDecrypt:data WithKey:key];
//        //IOS 自带DES加密 End
//        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    }
//    else {
//        return LocalStr_None;
//    }
//}

//文本先进行DES加密。然后再转成base64
+ (NSString *)base64StringFromText:(NSString *)text withKey:(NSString*)key
{
    if (text && ![text isEqualToString:@""]) {
        //取项目的bundleIdentifier作为KEY
        //NSString *key = [[NSBundle mainBundle] bundleIdentifier];
        NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
        //IOS 自带DES加密 Begin
        data = [self DESEncrypt:data WithKey:key];
        //IOS 自带DES加密 End
        return [self base64EncodedStringFrom:data];
    }
    else {
        return @"";
    }
}

//先把base64转为文本。然后再DES解密
+ (NSString *)textFromBase64String:(NSString *)base64 withKey:(NSString*)key
{
    if (base64 && ![base64 isEqualToString:@""]) {
        //取项目的bundleIdentifier作为KEY
        //NSString *key = [[NSBundle mainBundle] bundleIdentifier];
        NSData *data = [self dataWithBase64EncodedString:base64];
        //IOS 自带DES解密 Begin
        data = [self DESDecrypt:data WithKey:key];
        //IOS 自带DES加密 End
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    else {
        return @"";
    }
}

/************************************************************
 函数名称 : + (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key
 函数描述 : 文本数据进行DES加密
 输入参数 : (NSData *)data
 (NSString *)key
 输出参数 : N/A
 返回参数 : (NSData *)
 备注信息 : 此函数不可用于过长文本
 **********************************************************/
+ (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeDES,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer);
    return nil;
}

/************************************************************
 函数名称 : + (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key
 函数描述 : 文本数据进行DES解密
 输入参数 : (NSData *)data
 (NSString *)key
 输出参数 : N/A
 返回参数 : (NSData *)
 备注信息 : 此函数不可用于过长文本
 **********************************************************/
+ (NSData *)DESDecrypt:(NSData *)data WithKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeDES,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer);
    return nil;
}

/************************************************************
 函数名称 : + (NSData *)dataWithBase64EncodedString:(NSString *)string
 函数描述 : base64格式字符串转换为文本数据
 输入参数 : (NSString *)string
 输出参数 : N/A
 返回参数 : (NSData *)
 备注信息 :
 **********************************************************/
+ (NSData *)dataWithBase64EncodedString:(NSString *)string
{
    if (string == nil)
        [NSException raise:NSInvalidArgumentException format:nil];
    if ([string length] == 0)
        return [NSData data];
    
    static char *decodingTable = NULL;
    if (decodingTable == NULL)
    {
        decodingTable = malloc(256);
        if (decodingTable == NULL)
            return nil;
        memset(decodingTable, CHAR_MAX, 256);
        NSUInteger i;
        for (i = 0; i < 64; i++)
            decodingTable[(short)encodingTable[i]] = i;
    }
    
    const char *characters = [string cStringUsingEncoding:NSASCIIStringEncoding];
    if (characters == NULL)     //  Not an ASCII string!
        return nil;
    char *bytes = malloc((([string length] + 3) / 4) * 3);
    if (bytes == NULL)
        return nil;
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (YES)
    {
        char buffer[4];
        short bufferLength;
        for (bufferLength = 0; bufferLength < 4; i++)
        {
            if (characters[i] == '\0')
                break;
            if (isspace(characters[i]) || characters[i] == '=')
                continue;
            buffer[bufferLength] = decodingTable[(short)characters[i]];
            if (buffer[bufferLength++] == CHAR_MAX)      //  Illegal character!
            {
                free(bytes);
                return nil;
            }
        }
        
        if (bufferLength == 0)
            break;
        if (bufferLength == 1)      //  At least two characters are needed to produce one byte!
        {
            free(bytes);
            return nil;
        }
        
        //  Decode the characters in the buffer to bytes.
        bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
        if (bufferLength > 2)
            bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
        if (bufferLength > 3)
            bytes[length++] = (buffer[2] << 6) | buffer[3];
    }
    
    bytes = realloc(bytes, length);
    return [NSData dataWithBytesNoCopy:bytes length:length];
}

/************************************************************
 函数名称 : + (NSString *)base64EncodedStringFrom:(NSData *)data
 函数描述 : 文本数据转换为base64格式字符串
 输入参数 : (NSData *)data
 输出参数 : N/A
 返回参数 : (NSString *)
 备注信息 :
 **********************************************************/
+ (NSString *)base64EncodedStringFrom:(NSData *)data
{
    if ([data length] == 0)
        return @"";
    
    char *characters = malloc((([data length] + 2) / 3) * 4);
    if (characters == NULL)
        return nil;
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (i < [data length])
    {
        char buffer[3] = {0,0,0};
        short bufferLength = 0;
        while (bufferLength < 3 && i < [data length])
            buffer[bufferLength++] = ((char *)[data bytes])[i++];
        
        //  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
        characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
        characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        if (bufferLength > 1)
            characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        else characters[length++] = '=';
        if (bufferLength > 2)
            characters[length++] = encodingTable[buffer[2] & 0x3F];
        else characters[length++] = '=';
    }
    
    return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
}


+ (void)addMessageToLocal:(NSMutableDictionary *)message
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:message forKey:@"LoginAcess"];
    [userDefault synchronize];
}


+ (void)removeMessageFromLocal
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:@"LoginAcess"];
    
}

+ (NSMutableDictionary *)messageFromLocal
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([[userDefault dictionaryForKey:@"LoginAcess"] allKeys].count!=0) {
        return [NSMutableDictionary dictionaryWithDictionary:[userDefault dictionaryForKey:@"LoginAcess"]];
    }
    return nil;
    
}
-(NSAttributedString *)formatAttrItem:(NSString *)content font:(UIFont *)font color:(UIColor *)color
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.maximumLineHeight = 25.f;
    paragraphStyle.minimumLineHeight = 15.f;
    paragraphStyle.lineHeightMultiple = 20.f;
    NSDictionary *attrDict = @{NSFontAttributeName : font,NSForegroundColorAttributeName:color,
                               NSParagraphStyleAttributeName: paragraphStyle};
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]
                                          initWithString: content
                                          attributes:attrDict];
    return attrStr;
}
#pragma -mark 存储本地图片
+(BOOL) saveImageToCacheDir:(NSString *)directoryPath Image:(UIImage *)image imageName:(NSString *)imageName ImageType:(NSString *)imageType
{
    imageName = [imageName stringByReplacingOccurrencesOfString:@"/" withString:@"q"];
    NSString *cachePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];

    NSString *imageDir = [cachePath stringByAppendingPathComponent:directoryPath];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:imageDir isDirectory:&isDir];
    bool isCreated = false;
    if ( !(isDir == YES && existed == YES) )
    {
        isCreated = [fileManager createDirectoryAtPath:imageDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    bool isSaved = false;
    if ( isDir == YES && existed == YES )
    {
        if ([[imageType lowercaseString] isEqualToString:@"png"])
        {
            isSaved = [UIImagePNGRepresentation(image) writeToFile:[imageDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"png"]] options:NSAtomicWrite error:nil];
        }
        else if ([[imageType lowercaseString] isEqualToString:@"jpg"] || [[imageType lowercaseString] isEqualToString:@"jpeg"])
        {
            NSError *error;
            isSaved = [UIImageJPEGRepresentation(image, 1.0) writeToFile:[imageDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]] options:NSAtomicWrite error:&error];
            NSLog(@"%@",error);
        }
        else
        {
            NSLog(@"Image Save Failed\nExtension: (%@) is not recognized, use (PNG/JPG)", imageType);
        }
    }
    return isSaved;
}

// load Image from caches dir to imageview
+(NSData*) loadImageData:(NSString *)directoryPath Name:(NSString *)imageName
{
    imageName = [imageName stringByReplacingOccurrencesOfString:@"/" withString:@"q"];
    BOOL isDir = NO;
    NSString *cachePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    NSString *imageDir = [cachePath stringByAppendingPathComponent:directoryPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL dirExisted = [fileManager fileExistsAtPath:imageDir isDirectory:&isDir];
    if ( isDir == YES && dirExisted == YES )
    {
        NSString *imagePath = [imageDir stringByAppendingPathComponent : [NSString stringWithFormat:@"%@.jpg",imageName]];
        BOOL fileExisted = [fileManager fileExistsAtPath:imagePath];
        if (!fileExisted) {
            return NULL;
        }
        NSData *imageData = [NSData dataWithContentsOfFile : imagePath];
        return imageData;
    }
    else
    {
        return NULL;
    }
}

-(BOOL)createDirInCache:(NSString *)dirName
{
    
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cachePaths objectAtIndex:0];
    NSString *imageDir = [cachePath stringByAppendingPathComponent:dirName];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:imageDir isDirectory:&isDir];
    bool isCreated = false;
    if ( !(isDir == YES && existed == YES) )
    {
        isCreated = [fileManager createDirectoryAtPath:imageDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return isCreated;
}

+(void)addLineOnView:(UIView *)view heightPoint:(CGFloat)height toLeft:(CGFloat)left toRight:(CGFloat)right withColor:(UIColor *)color{
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(left, height, SCREEN_WIDTH-left-right, 1)];
    [lineView setBackgroundColor:color];
    [view addSubview:lineView];
}

+(void)addLabelOnView:(UIView *)view localPoint:(CGFloat)local toLeft:(CGFloat)left toRight:(CGFloat)right height:(CGFloat)height withColor:(UIColor*)color font:(UIFont*)font text:(NSString *) text{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(left, local, SCREEN_WIDTH-left-right, height)];
    [label setFont:font];
    [label setText:text];
    [label setTextColor:color];
    [view addSubview:label];
}
+(void) showView:(UILabel *)view Text:(NSString *)string{
    [view setText:string];
    [view setAlpha:0];
    [UIView animateWithDuration:0.3 animations:^{
        [view setAlpha:1];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:3 animations:^{
            [view setAlpha:0];
        }];
    }];
}
+(void)showTipsAtView:(UIView *)view xPoint:(CGFloat)x yPoint:(CGFloat)y text:(NSString *)text{
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, SCREEN_WIDTH-x-15, 20)];
    tipsLabel.font = [UIFont boldSystemFontOfSize:12];
    [tipsLabel setTextColor:[UIColor colorWithHexString:@"f26a3d"]];
    [tipsLabel setText:text];
    [view addSubview:tipsLabel];
    [tipsLabel setAlpha:0];
    [UIView animateWithDuration:0.3 animations:^{
        [tipsLabel setAlpha:1];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:3 animations:^{
            [tipsLabel setAlpha:0];
        }];
    }];
}
#pragma -mark label多字体颜色
+(NSAttributedString *)formatAttrItem:(NSString *)content color:(UIColor *)color font:(UIFont *)font
{
//    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
//    paragraphStyle.maximumLineHeight = 25.f;
//    paragraphStyle.minimumLineHeight = 15.f;
//    paragraphStyle.lineHeightMultiple = 20.f;
    //NSParagraphStyleAttributeName: paragraphStyle,
    NSDictionary *attrDict = @{
                               NSForegroundColorAttributeName:color,
                               NSFontAttributeName:font};
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]
                                          initWithString: content
                                          attributes:attrDict];
    return attrStr;
}



+(void) showNotifyOnView:(UIView *)view text:(NSString *)text{
    
}
+(void) showView:(UILabel *)view Text:(NSString *)string pointY:(CGFloat) pointY{
    
}
@end

