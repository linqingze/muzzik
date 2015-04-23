//
//  musicPlayer.h
//  muzzik
//
//  Created by 林清泽 on 15/3/9.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFRadioView.h"
#import "Globle.h"
#import "FMDatabase.h"
@interface musicPlayer : UIViewController{
     muzzik * localMuzzik;
        Globle * globle;
    NSString *songpath;
}
@property (nonatomic) FMDatabase *muzzikDB;
@property (nonatomic,strong) NSMutableArray * MusicArray;
@property (nonatomic,assign) NSInteger index;
@property (nonatomic) NSInteger playModel;
@property (nonatomic) RFRadioView * radioView;
+(musicPlayer *) shareClass;
+(NSMutableArray *)playMusicList;
-(void)playSongWithSongModel:(muzzik *)playMuzzik;
-(void)play;
-(void)playNext;
-(void)PlayPre;
-(void)downLoadFileWithModel:(muzzik*)playMuzzik;
@end
