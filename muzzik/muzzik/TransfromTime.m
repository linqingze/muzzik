//
//  TransfromTime.m
//  ShopUU
//
//  Created by iOS Fangli on 15/1/30.
//  Copyright (c) 2015年 陆秦网络科技有限公司. All rights reserved.
//

#import "TransfromTime.h"
#import "PinYin4Objc.h"
#import <AddressBook/AddressBook.h>
@implementation TransfromTime

- (NSString *)transtromTime:(NSString *)time
{
//    NSString* timeStr = @"2011-01-26 17:40:50";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
//    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
//    [formatter setTimeZone:timeZone];
    
    NSDate *date = [formatter dateFromString:time];
    NSLog(@"date : %@",date);
    NSTimeInterval interval = fabs([date timeIntervalSinceNow]);
    NSLog(@"interval : %f",interval);
    
    return  [self deventTime:interval time:time];
}

- (NSString *)deventTime:(NSTimeInterval)interval time:(NSString *)time;
{
    NSCalendar*calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps;
    NSString *str;
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *date = [formatter dateFromString:time];
    
    if (interval>7*24*60*60) { //一周之外
        str = [formatter stringFromDate:date];
        NSRange range = [str rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
        range = NSMakeRange(0, range.location);
        str = [str substringWithRange:range];
        return str;
        
    }else if(interval>24*60*60){ //一天之外
        
        comps =[calendar components:(NSWeekCalendarUnit | NSWeekdayCalendarUnit |NSWeekdayOrdinalCalendarUnit)
                           fromDate:date];
        NSInteger weekday = [comps weekday]; // 星期几（注意，周日是“1”，周一是“2”。。。。）
//        NSInteger week = [comps week]; // 今年的第几周
//        NSInteger weekdayOrdinal = [comps weekdayOrdinal]; // 这个月的第几周
        if (weekday == 1) {
            str = [NSString stringWithFormat:@"星期日"];
        }else if (weekday == 2) {
            str = [NSString stringWithFormat:@"星期一"];
        }else if (weekday == 3) {
            str = [NSString stringWithFormat:@"星期二"];
        }else if (weekday == 4) {
            str = [NSString stringWithFormat:@"星期三"];
        }else if (weekday == 5) {
            str = [NSString stringWithFormat:@"星期四"];
        }else if (weekday == 6) {
            str = [NSString stringWithFormat:@"星期五"];
        }else {
            str = [NSString stringWithFormat:@"星期六"];
        }
        return str;
        
    }else if (interval>60*60) { //一小时以外
        int time = (int)interval/(60*60);
        return [NSString stringWithFormat:@"%d小时之前",time];
    }else if (interval>60) {
        int time = (int)interval/(60);
        return [NSString stringWithFormat:@"%d分钟之前",time];
    }else{
        return [NSString stringWithFormat:@"刚刚"];
    }
    return nil;
}

//根据汉字获取按首字母
- (NSMutableArray *)firstCharactor:(NSMutableArray *)arr
{
    NSString *table = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableArray *stringArr = [NSMutableArray array];
    NSString *string = [NSString string];
    for (MuzzikUser *muzzikuser in arr) {
        string = muzzikuser.name;
        if ([string length]>0) {
            NSString *pinyin = [self pinyin:string];
            if ([table containsString:[[pinyin substringToIndex:1] uppercaseString]]) {
                [stringArr addObject:[NSDictionary dictionaryWithObjectsAndKeys:pinyin,@"pinyin",muzzikuser,@"user",[[pinyin substringToIndex:1] uppercaseString],@"firstcapital", nil]];
            }else{
                [stringArr addObject:[NSDictionary dictionaryWithObjectsAndKeys:pinyin,@"pinyin",string,muzzikuser,@"user",@"#",@"firstcapital", nil]];
            }
            
        }
        
    }
    stringArr = [NSMutableArray arrayWithArray:[stringArr sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) { //排序
        if ([[obj1 objectForKey:@"pinyin"] compare:[obj2 objectForKey:@"pinyin"] options:NSCaseInsensitiveSearch]==NSOrderedAscending) {
            return NSOrderedAscending;//递减
        }
        if ([[obj1 objectForKey:@"pinyin"] compare:[obj2 objectForKey:@"pinyin"] options:NSCaseInsensitiveSearch]==NSOrderedDescending){
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }]];
    return stringArr;
    
}

//汉字转化为拼音
- (NSString *)pinyin:(NSString *)str
{
    //方式一
    //先转换为带声调的拼音
//    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    //再转换为不带声调的拼音
//    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
//    NSLog(@"%@",str);
//    return str;
    
//  方式二 (简单明了,易于使用,一行代码 方便他人)
//     return [ChineseToPinyin pinyinFromChiniseString:str];
    
    HanyuPinyinOutputFormat *outputFormat = [[HanyuPinyinOutputFormat alloc] init];
    [outputFormat setToneType:ToneTypeWithoutTone];
    [outputFormat setVCharType:VCharTypeWithV];
    [outputFormat setCaseType:CaseTypeLowercase];
    NSString *outputPinyin = [PinyinHelper toHanyuPinyinStringWithNSString:str withHanyuPinyinOutputFormat:outputFormat withNSString:@" "];
    return outputPinyin;
    
}


//根据首字母获取分组数据
- (NSMutableArray *)arrayFromString:(NSMutableArray *)arr searchStr:(NSArray *)CapitalArr
{
    NSMutableArray *results = [NSMutableArray array];
    for (int i=0; i<CapitalArr.count; i++) {
        NSMutableArray *array = [NSMutableArray array];
        for (int j=0; j<arr.count; j++) { //传过来的arr是首字母数组
            if ([[arr[j] objectForKey:@"firstcapital"] isEqualToString:[CapitalArr[i] uppercaseString]] ) {
                [array addObject:arr[j]];
            }
        }
        [results addObject:array];
    }
    
    return results;
}
//根据首字母获取分组数据
- (NSMutableDictionary *)dicFromString:(NSMutableArray *)arr searchStr:(NSArray *)CapitalArr
{
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    for (int i=0; i<CapitalArr.count; i++) {
        NSMutableArray *array = [NSMutableArray array];
        for (int j=0; j<arr.count; j++) { //传过来的arr是首字母数组
            if ([[arr[j] objectForKey:@"firstcapital"] isEqualToString:[CapitalArr[i] lowercaseString]]) {
                [array addObject:[arr[j] objectForKey:@"chinese"]];
            }
        }
        [results setObject:array forKey:CapitalArr[i]];
    }
    
    return results;
}

//读取所有联系人

-(NSMutableArray *)ReadAllPeoples

{
    
    //取得本地通信录名柄
    
    ABAddressBookRef tmpAddressBook = nil;
    
    if ([[UIDevice currentDevice].systemVersion floatValue]>=6.0) {
        tmpAddressBook=ABAddressBookCreateWithOptions(NULL, NULL);
        dispatch_semaphore_t sema=dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(tmpAddressBook, ^(bool greanted, CFErrorRef error){
            dispatch_semaphore_signal(sema);
        });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    else
    {
        tmpAddressBook =ABAddressBookCreate();
    }
    //取得本地所有联系人记录
    
    
    if (tmpAddressBook==nil) {
        return nil;
    };
    NSArray* tmpPeoples = (__bridge NSArray *)(ABAddressBookCopyArrayOfAllPeople(tmpAddressBook));
    NSMutableArray *phonelist = [NSMutableArray array];
    for(id tmpPerson in tmpPeoples)
        
    {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        //获取的联系人单一属性:First name
        
        NSString* tmpFirstName = (__bridge NSString*)ABRecordCopyValue((__bridge ABRecordRef)(tmpPerson), kABPersonFirstNameProperty);
        
        NSLog(@"First name:%@", tmpFirstName);
        
        //获取的联系人单一属性:Last name
        
        NSString* tmpLastName = (__bridge NSString*)ABRecordCopyValue((__bridge ABRecordRef)(tmpPerson), kABPersonLastNameProperty);
        
        NSLog(@"Last name:%@", tmpLastName);
        [dic setObject:[NSString stringWithFormat:@"%@%@",[tmpLastName length]>0 ? tmpLastName:@"",[tmpFirstName length]>0 ? tmpFirstName:@""] forKey:@"phonename"];
        //获取的联系人单一属性:Nickname
//        
//        NSString* tmpNickname = (__bridge NSString*)ABRecordCopyValue((__bridge ABRecordRef)(tmpPerson), kABPersonNicknameProperty);
//        
//        NSLog(@"Nickname:%@", tmpNickname);
//  
//        //获取的联系人单一属性:Company name
//        
//        NSString* tmpCompanyname = (__bridge NSString*)ABRecordCopyValue((__bridge ABRecordRef)(tmpPerson), kABPersonOrganizationProperty);
//        
//        NSLog(@"Company name:%@", tmpCompanyname);
//
//        //获取的联系人单一属性:Job Title
//        
//        NSString* tmpJobTitle= (__bridge NSString*)ABRecordCopyValue((__bridge ABRecordRef)(tmpPerson), kABPersonJobTitleProperty);
//        
//        NSLog(@"Job Title:%@", tmpJobTitle);
//        
//        //获取的联系人单一属性:Department name
//        
//        NSString* tmpDepartmentName = (__bridge NSString*)ABRecordCopyValue((__bridge ABRecordRef)(tmpPerson), kABPersonDepartmentProperty);
//        
//        NSLog(@"Department name:%@", tmpDepartmentName);
//
//        
//        //获取的联系人单一属性:Email(s)
//        
//        ABMultiValueRef tmpEmails = ABRecordCopyValue((__bridge ABRecordRef)(tmpPerson), kABPersonEmailProperty);
//        
//        for(NSInteger j = 0; ABMultiValueGetCount(tmpEmails); j++)
//            
//        {
//            
//            NSString* tmpEmailIndex = (__bridge NSString*)ABMultiValueCopyValueAtIndex(tmpEmails, j);
//            
//            NSLog(@"Emails%d:%@", j, tmpEmailIndex);
//            
//            
//        }
//        
//        CFRelease(tmpEmails);
//        
//        //获取的联系人单一属性:Birthday
//        
//        NSDate* tmpBirthday = (__bridge NSDate*)ABRecordCopyValue((__bridge ABRecordRef)(tmpPerson), kABPersonBirthdayProperty);
//        
//        NSLog(@"Birthday:%@", tmpBirthday);
//
//        
//        //获取的联系人单一属性:Note
//        
//        NSString* tmpNote = (__bridge NSString*)ABRecordCopyValue((__bridge ABRecordRef)(tmpPerson), kABPersonNoteProperty);
//        
//        NSLog(@"Note:%@", tmpNote);
//        
//        //获取的联系人单一属性:Generic phone number
        
        ABMultiValueRef tmpPhones = ABRecordCopyValue((__bridge ABRecordRef)(tmpPerson), kABPersonPhoneProperty);
        NSMutableArray *tempArray = [NSMutableArray array];
        for(NSInteger j = 0; j < ABMultiValueGetCount(tmpPhones); j++)
            
        {
            
            NSString* tmpPhoneIndex = (__bridge NSString*)ABMultiValueCopyValueAtIndex(tmpPhones, j);
            [tempArray addObject:[[tmpPhoneIndex stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@"+86" withString:@""] ];
            
        }
        [dic setObject:tempArray forKey:@"phones"];
        CFRelease(tmpPhones);
        [phonelist addObject:dic];
        
    }
    
    //释放内存&nbsp;
    
    CFRelease(tmpAddressBook);
    return phonelist;
}
@end
