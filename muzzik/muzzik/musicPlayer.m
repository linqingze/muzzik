 //
//  musicPlayer.m
//  muzzik
//
//  Created by 林清泽 on 15/3/9.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//
#import "NetTypeHelper.h"
#import "musicPlayer.h"
#import "UIImageView+WebCache.h"
#import "appConfiguration.h"
#import "FMLrcView.h"
#import "FSPlaylistItem.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AudioPlayer.h"
#import "ASIHTTPRequest.h"
#import "FMDatabase.h"
#import "Reachability.h"
static NSMutableArray *playList;
@interface musicPlayer()<RFRadioViewDelegate>{
    
    BOOL isPause;
}

@end
@implementation musicPlayer

+(musicPlayer *) shareClass{
    static musicPlayer *myclass=nil;
    if(!myclass){
        myclass = [[super allocWithZone:NULL] init];
    }
    return myclass;
}
-(id)init{
   self = [super init];
    
    _radioView = [[RFRadioView alloc] initWithFrame:CGRectMake(0,-64,SCREEN_WIDTH,64)];
    _radioView.delegate = self;
    self.playModel = 0;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *dbPath = [DocumentsPath stringByAppendingPathComponent:@"myDataBase"];
    NSLog(@"%@",dbPath);
    
    if (![fileMgr fileExistsAtPath:dbPath]) {
        NSString *srcPath = [[NSBundle mainBundle] pathForResource:@"myDataBase" ofType:@"db"];
        [fileMgr copyItemAtPath:srcPath toPath:dbPath error:NULL];
    }
    self.muzzikDB = [FMDatabase databaseWithPath:dbPath] ;
    return self;
}
+(id)allocWithZone:(NSZone *)zone{
    return [self shareClass];
}

+(NSMutableArray *)playMusicList{
    return playList;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.tabBarController.tabBar setHidden:NO];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.view.backgroundColor = [UIColor whiteColor];


    
    // Do any additional setup after loading the view.
}
-(BOOL)isLocalMP3
{
    if ([self.muzzikDB open]) {
        NSString *dbCreate = [[NSUserDefaults standardUserDefaults] stringForKey:Is_Table_Create];
        if (![dbCreate isEqualToString:@"yes"]) {
            [self.muzzikDB executeUpdate:@"CREATE TABLE SongList (songname text, artist text, music_id text, songkey text,filepath text,lastplay text , playtimes text)"];
            [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:Is_Table_Create];
        }

    }

        FMResultSet *rs = [self.muzzikDB executeQuery:@"SELECT * FROM SongList"];
        
        
        
        // 遍历结果集
        
        while ([rs next]) {
            if ([[rs stringForColumn:@"songkey"] isEqualToString:_localMuzzik.music.key]) {
                [rs close];
                [self.muzzikDB close];
                return YES;
            }
            NSLog(@"song:%@,filepath:%@",[rs stringForColumn:@"SongName"],[rs stringForColumn:@"filepath"]);
            
        }
        
        [rs close];
        [self.muzzikDB close];
    return NO;
}
//-(NSString *)localMP3path
//{
//    NSString *filePath = [DocumentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3",localMuzzik.music.music_id]];
//    return filePath;
//}
-(void)playSongWithSongModel:(muzzik *)playMuzzik{
    
    
    globle = [Globle shareGloble];

    if ([self isLocalMP3]) {
        NSString *path = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"music"] stringByAppendingPathComponent:playMuzzik.music.key];
        _radioView.musicUrl = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@",path]];
    }
    else{
        _radioView.musicUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_audio,playMuzzik.music.key]];
        if ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] == kReachableViaWiFi) {
            [self downLoadFileWithModel:_localMuzzik];
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackgroundSetSongInformation:) name:String_SetSongInformationNotification object:nil];
    if (globle.isApplicationEnterBackground) {
        [self applicationDidEnterBackgroundSetSongInformation:nil];
    }
    _radioView.playMuzzik = playMuzzik;
    //[_radioView setRadioViewLrc];
    globle.isPlaying = YES;
    _localMuzzik = playMuzzik;
    
    self.index = [self.MusicArray indexOfObject:playMuzzik];
    [[NSNotificationCenter defaultCenter] postNotificationName:String_SetSongPlayNextNotification object:nil];
    NSLog(@"%d",self.index);
}


-(void)applicationDidEnterBackgroundSetSongInformation:(NSNotification *)notification
{
    if (NSClassFromString(@"MPNowPlayingInfoCenter")) {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        [dict setObject:_localMuzzik.music.name forKey:MPMediaItemPropertyTitle];
        [dict setObject:_localMuzzik.music.artist  forKey:MPMediaItemPropertyArtist];
        [dict setObject:[NSNumber numberWithDouble:[AudioPlayer shareClass].duration] forKey:MPMediaItemPropertyPlaybackDuration];
        
        //音乐当前播放时间 在计时器中修改
        [dict setObject:[NSNumber numberWithDouble:[AudioPlayer shareClass].progress] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
        //		[dict setObject:[[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"headerImage.png"]] forKey:MPMediaItemPropertyArtwork];
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
    }
}

-(void)playModleIsLock
{
    
    _radioView.playMuzzik = _localMuzzik;
    globle.isPlaying = YES;
}
-(void)play{
    if (globle.isPlaying == YES) {
        if (isPause) {
            [[AudioPlayer shareClass] resume];
            isPause = !isPause;
        }else{
            isPause = !isPause;
            [[AudioPlayer shareClass] pause];
        }
        
    }else{
        switch (self.playModel) {
            case 0:
            {
                self.index+=1;
                if (self.index>=[self.MusicArray count]) {
                    self.index = 0;
                }
                _localMuzzik = [self.MusicArray objectAtIndex:self.index];
                [self playSongWithSongModel:_localMuzzik];
            }
                break;
            case 1:
            {
                NSInteger  number = [self.MusicArray count];
                _localMuzzik = [self.MusicArray objectAtIndex:arc4random()%number];
                [self playSongWithSongModel:_localMuzzik];
            }
                break;
            case -1:
            {
                [self playModleIsLock];
            }
                break;
            default:
                break;
        }

    }
    
}
-(void)playNext{
    if ([self.MusicArray count]!=0) {
        self.index+=1;
        if (self.index==[self.MusicArray count]) {
            self.index = 0;
        }
        [self playSongWithSongModel:[self.MusicArray objectAtIndex:self.index]];
    }

}
-(void)PlayPre{
    if ([self.MusicArray count]!=0) {
        self.index-=1;
        if (self.index<0) {
            self.index = 0;
        }
        [self playSongWithSongModel:[self.MusicArray objectAtIndex:self.index]];
    }
}
#pragma mark RFRadioViewDelegate
-(void)radioView:(RFRadioView *)view musicStop:(NSInteger)playModel
{
    if (playModel == 0) {
        [self playNext];
        
    }
    
    }
-(void)radioView:(RFRadioView *)view preSwitchMusic:(UIButton *)pre
{
    [self PlayPre];
}
-(void)radioView:(RFRadioView *)view nextSwitchMusic:(UIButton *)next
{
    [self playNext];
}
-(void)radioView:(RFRadioView *)view playListButton:(UIButton *)btn
{
//    FMPlayingListViewController * viewController = [[FMPlayingListViewController alloc] init];
//    UINavigationController * navigation = [[UINavigationController alloc] initWithRootViewController:viewController];
//    [self.navigationController presentViewController:navigation animated:YES completion:^{
//        
//    }];
}
-(void)downLoadFileWithModel:(muzzik*)model{
    
    
    
    //初始化Documents路径
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *folderPath = [path stringByAppendingPathComponent:@"music"];
    //创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //判断temp文件夹是否存在
    BOOL fileExists = [fileManager fileExistsAtPath:folderPath];
    if (!fileExists) {//如果不存在说创建,因为下载时,不会自动创建文件夹
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    BOOL musicExists = false;
    NSArray *array = [fileManager contentsOfDirectoryAtPath: folderPath error:nil];
    for (NSString *pathstring in array) {
        if ([pathstring isEqualToString:model.music.key]) {
            musicExists = YES;
        }
    }
    if (!musicExists) {
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_audio,model.music.key]];
        //设置下载路径
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
        //设置ASIHTTPRequest代理
        request.delegate = self;
        //初始化保存ZIP文件路径
        NSString *savePath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", model.music.key]];
        //初始化临时文件路径
        NSString *tempPath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.temp",model.music.key]];
        //设置文件保存路径
        [request setDownloadDestinationPath:savePath];
        //设置临时文件路径
        [request setTemporaryFileDownloadPath:tempPath];
        //设置进度条的代理,
        //[request setDownloadProgressDelegate:cell];
        //设置是是否支持断点下载
        [request setAllowResumeForFileDownloads:YES];
        __weak ASIHTTPRequest *weakrequest = request;
        [request setCompletionBlock :^{
            if (![self.muzzikDB open]) {
                NSLog(@"Could not open db.");
                return ;
            }
            NSString *dbCreate = [[NSUserDefaults standardUserDefaults] stringForKey:Is_Table_Create];
            if (![dbCreate isEqualToString:@"yes"]) {
                [self.muzzikDB executeUpdate:@"CREATE TABLE SongList (songname text, artist text, music_id text, songkey text,filepath text,lastplay text , playtimes text)"];
                [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:Is_Table_Create];
            }
            if ([weakrequest responseStatusCode] == 200) {
                [self.muzzikDB executeUpdate:@"INSERT INTO SongList (songname, artist, music_id, songkey,filepath,lastplay,playtimes) VALUES (?,?,?,?,?,?,?)",model.music.name, model.music.artist, model.music.music_id, model.music.key,savePath,[NSString stringWithFormat:@"%f",[NSDate timeIntervalSinceReferenceDate]],@"0"];
//                FMResultSet *rs = [self.muzzikDB executeQuery:@"SELECT * FROM SongList"];
//                
//                
//                
//                // 遍历结果集
//                
//                while ([rs next]) {
//                    NSLog(@"song:%@,filepath:%@",[rs stringForColumn:@"SongName"],[rs stringForColumn:@"filepath"]);
//                    
//                }
                
                //[rs close];
                [self.muzzikDB close];
            }
            else{
                //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
            }
        }];
        [request setFailedBlock:^{
            NSLog(@"%@%@",[weakrequest responseString],[weakrequest responseData]);
            NSLog(@"%@",[weakrequest responseHeaders]);
            [KVNProgress showErrorWithStatus:@"网络请求超时"];
        }];
        [request startAsynchronous];
    }

}
-(void)radioView:(RFRadioView *)view downLoadButton:(UIButton *)btn
{
   
}

@end
