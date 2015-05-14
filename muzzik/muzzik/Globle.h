//
//  Globle.h
//  FreeMusic
//
//  Created by zhaojianguo-PC on 14-5-27.
//  Copyright (c) 2014年 xiaozi. All rights reserved.
//

#import <Foundation/Foundation.h>
#define DocumentsPath [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

extern NSString * FMRFRadioViewStatusNotifiation;
extern NSString * FMRFRadioViewSetSongInformationNotification;
@interface Globle : NSObject
@property (nonatomic,assign) BOOL isHeadView;
@property (nonatomic,assign) BOOL isPlaying;
@property (nonatomic,assign) BOOL isApplicationEnterBackground;
@property (nonatomic,assign) BOOL isPause;
-(void)copySqlitePath;
+(Globle*)shareGloble;
//-(NSMutableArray *)loadSinger;
@end
