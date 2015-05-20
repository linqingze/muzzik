//
//  DeleGateMethodConfigure.h
//  muzzik
//
//  Created by muzzik on 15/5/6.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#ifndef muzzik_DeleGateMethodConfigure_h
#define muzzik_DeleGateMethodConfigure_h
@protocol CellDelegate <NSObject>


@optional
// The content for any tab. Return a view controller and ViewPager will use its view to show as content
-(void)commentAtMuzzik:(muzzik *)localMuzzik;
-(void)showComment:(muzzik *)localMuzzik;
-(void)showShare:(NSString *)muzzik_id;
-(void)showMoved:(NSString *)muzzik_id;
-(void)showRepost:(NSString *)muzzik_id;
-(void)userDetail:(NSString *)uid;
-(void)playSongWithSongModel:(muzzik *)songModel;
-(void)downMusicWithModel:(muzzik *)model;
-(void)moveMuzzikWithId:(NSString *)muzzik_id isMoved:(BOOL) ismoved atIndex:(NSInteger) index;
-(void)repostActionWithMuzzik_id:(NSString *)muzzik_id atIndex:(NSInteger) index;
-(void)shareActionWithMuzzik:(muzzik *)localMuzzik;
-(void)reloadMuzzikSource;
-(void)payAttention:(NSString *)uid;
-(void)showFollow:(NSString *)uid;
-(void)showSong:(NSString *)uid;
-(void)showFans:(NSString *)uid;
-(void)attention:(NSInteger)index;
-(void)newMuzzik:(muzzik *)localMzzik;
@end

#endif
