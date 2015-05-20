//
//  UserSongVC.m
//  muzzik
//
//  Created by muzzik on 15/5/13.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "UserSongVC.h"
#import "SongListCell.h"
#import "UIScrollView+DXRefresh.h"
#import "MessageStepViewController.h"
@interface UserSongVC ()<UITableViewDataSource,UITableViewDelegate,CellDelegate>{
    UITableView *songTableView;
    NSString *lastId;
}
@property (nonatomic,retain) NSMutableArray *muzziks;
@end

@implementation UserSongVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNagationBar:@"歌单" leftBtn:Constant_backImage rightBtn:0];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playnextMuzzikUpdate) name:String_SetSongPlayNextNotification object:nil];
    self.muzziks = [NSMutableArray array];
    songTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    [self.view addSubview:songTableView];
    songTableView.delegate = self;
    songTableView.dataSource = self;
    songTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self followScrollView:songTableView];
    [songTableView registerClass:[SongListCell class] forCellReuseIdentifier:@"SongListCell"];
    if ([self.uid length]==0) {
        self.uid = [userInfo shareClass].uid;
    }
    ASIHTTPRequest *request= [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@/muzziks",BaseURL,self.uid]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:Limit_Constant,Parameter_Limit, nil] Method:GetMethod auth:YES];
    
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        // NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            muzzik *muzzikToy = [muzzik new];
            NSMutableArray *songarray = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
            for (muzzik *localMuzzik in songarray) {
                BOOL isContained = NO;
                for (muzzik *originMuzzik in self.muzziks) {
                    if ([originMuzzik.music.key isEqualToString:localMuzzik.music.key]) {
                        isContained = YES;
                        break;
                    }
                }
                if (!isContained) {
                    [self.muzziks addObject:localMuzzik];
                }
            }
            
            lastId = [dic objectForKey:@"tail"];
            [songTableView reloadData];
            if ([[dic objectForKey:@"muzziks"] count]<[Limit_Constant integerValue] ) {
                [songTableView removeFooter];
            }
            
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
    }];
    [request startAsynchronous];
    // Do any additional setup after loading the view.
}
- (void)refreshFooter
{
    
    // [self updateSomeThing];
    ASIHTTPRequest *request= [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@/muzziks",BaseURL,self.uid]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:lastId,Parameter_from,Limit_Constant,Parameter_Limit, nil] Method:GetMethod auth:YES];
    
    
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        // NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            muzzik *muzzikToy = [muzzik new];
            NSMutableArray *songarray = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
            for (muzzik *localMuzzik in songarray) {
                BOOL isContained = NO;
                for (muzzik *originMuzzik in self.muzziks) {
                    if ([originMuzzik.music.key isEqualToString:localMuzzik.music.key]) {
                        isContained = YES;
                        break;
                    }
                }
                if (!isContained) {
                    [self.muzziks addObject:localMuzzik];
                }
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [songTableView reloadData];
                [songTableView footerEndRefreshing];
                if ([[dic objectForKey:@"muzziks"] count]<[Limit_Constant integerValue] ) {
                    [songTableView removeFooter];
                }
            });
            
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
    }];
    [request startAsynchronous];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.muzziks.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
     SongListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SongListCell" forIndexPath:indexPath];
    muzzik *tempMuzzik = self.muzziks[indexPath.row];
    cell.timeLabel.text = [MuzzikItem transtromTime:tempMuzzik.date];
    cell.songName.text = tempMuzzik.music.name;
    cell.Artist.text = tempMuzzik.music.artist;
    cell.cellMuzzik = tempMuzzik;
    cell.delegate = self;
    BOOL isplaying = NO;
    if ([[musicPlayer shareClass].localMuzzik.music.key isEqualToString:tempMuzzik.music.key]) {
        isplaying = YES;
    }
    Globle *glob = [Globle shareGloble];
    UIColor *color;
    if (isplaying) {
        if ([tempMuzzik.color longLongValue] == 1) {
            color = [UIColor colorWithHexString:@"fea42c"];
            if (!glob.isPause) {
                [cell.playButton setImage:[UIImage imageNamed:Image_detailstopyellowImage] forState:UIControlStateNormal];
            }else{
                [cell.playButton setImage:[UIImage imageNamed:Image_detailyellowplay] forState:UIControlStateNormal];
            }
            [cell.CommentButton setImage:[UIImage imageNamed:Image_songlistpostweetImage] forState:UIControlStateNormal];
            [cell.timeImage setImage:[UIImage imageNamed:Image_timelineyellowImage]];
            [cell.songName setTextColor:color];
            [cell.Artist setTextColor:color];
            
        }
        else if([tempMuzzik.color longLongValue] == 2){
            //bluelikeImage
            color = [UIColor colorWithHexString:@"04a0bf"];
            if (!glob.isPause) {
                [cell.playButton setImage:[UIImage imageNamed:Image_detailstopblueImage] forState:UIControlStateNormal];
            }else{
                [cell.playButton setImage:[UIImage imageNamed:Image_detailblueplay] forState:UIControlStateNormal];
            }
            [cell.CommentButton setImage:[UIImage imageNamed:Image_songlistpostweetImage] forState:UIControlStateNormal];
            [cell.timeImage setImage:[UIImage imageNamed:Image_timelineblueImage]];
            [cell.songName setTextColor:color];
            [cell.Artist setTextColor:color];
        }
        else{
            color = [UIColor colorWithHexString:@"f26d7d"];
            if (!glob.isPause) {
                [cell.playButton setImage:[UIImage imageNamed:Image_detailstopredImage] forState:UIControlStateNormal];
            }else{
                [cell.playButton setImage:[UIImage imageNamed:Image_detailredplay] forState:UIControlStateNormal];
            }
            [cell.CommentButton setImage:[UIImage imageNamed:Image_songlistpostweetImage] forState:UIControlStateNormal];
            [cell.timeImage setImage:[UIImage imageNamed:Image_timelineredImage]];
            [cell.songName setTextColor:color];
            [cell.Artist setTextColor:color];
        }
    }else{
        [cell.songName setTextColor:Color_Text_2];
        [cell.Artist setTextColor:Color_Text_2];
        [cell.CommentButton setImage:[UIImage imageNamed:Image_songlistpostweetImage] forState:UIControlStateNormal];
        [cell.playButton setImage:[UIImage imageNamed:Image_detailgreyplay] forState:UIControlStateNormal];
        if ([tempMuzzik.color longLongValue] == 1) {
            [cell.timeImage setImage:[UIImage imageNamed:Image_timelineyellowImage]];
        }
        else if([tempMuzzik.color longLongValue] == 2){
            [cell.timeImage setImage:[UIImage imageNamed:Image_timelineblueImage]];
        }
        else{
             [cell.timeImage setImage:[UIImage imageNamed:Image_timelineredImage]];
        }
        
    }
    return cell;
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)playSongWithSongModel:(muzzik *)songModel{
    musicPlayer *player = [musicPlayer shareClass];
    player.listType = TempList;
    player.MusicArray = self.muzziks;
    player.index = [self.muzziks indexOfObject:songModel];
    [player playSongWithSongModel:songModel];
}

-(void)newMuzzik:(muzzik *)localMzzik{
    MuzzikObject *mobject = [MuzzikObject shareClass];
    
    mobject.music = localMzzik.music;
    MessageStepViewController *messagebv = [[MessageStepViewController alloc] init];
    [self.navigationController pushViewController:messagebv animated:YES];
}

-(void)playnextMuzzikUpdate{
    [songTableView reloadData];
}
@end