//
//  SongTableViewController.m
//  muzzik
//
//  Created by muzzik on 15/4/24.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "SongTableViewController.h"
#import "MusicCell.h"
#import "musicPlayer.h"
#import "ASIFormDataRequest.h"
#import "MessageStepViewController.h"
@interface SongTableViewController (){
    NSInteger indexOfMuzzik;
    BOOL isSearch;
    NSString *pageID;
    NSInteger _index;
    NSString *_searchText;
    NSInteger page;
}
@property(nonatomic,retain)NSMutableArray *movedMusicArray;
@property(nonatomic,retain)NSMutableArray *searchArray;

@end

@implementation SongTableViewController
//-(NSMutableArray *)searchArray{
//    if (!_searchArray) {
//        _searchArray = [NSMutableArray array];
//    }
//    return _searchArray;
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    page = 1;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playnextMuzzikUpdate) name:String_SetSongPlayNextNotification object:nil];
    [self.tableView registerClass:[MusicCell class] forCellReuseIdentifier:@"MusicCell"];
    ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Get_Moved_music]]];
    [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:Limit_Constant,Parameter_Limit ,nil] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = requestForm;
    [requestForm setCompletionBlock :^{
        NSLog(@"%@",[weakrequest responseString]);
        NSLog(@"%d",[weakrequest responseStatusCode]);
        if ([weakrequest responseStatusCode] == 200) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
            pageID = [dic objectForKey:@"page"];
             pageID = [NSString stringWithFormat:@"%d",[pageID integerValue]+1];
            muzzik *tempMuzzik = [muzzik new];
            self.movedMusicArray = [tempMuzzik makeMuzziksByMusicArray:[dic objectForKey:@"music"]];
            [self.tableView reloadData];
        }
        else{
            //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
        }
    }];
    [requestForm setFailedBlock:^{
        NSLog(@"%@",[weakrequest error]);
        NSLog(@"hhhh%@  kkk%@",[weakrequest responseString],[weakrequest responseHeaders]);
        [userInfo checkLoginWithVC:self];
    }];
    [requestForm startAsynchronous];
    [self.tableView addFooterWithTarget:self action:@selector(refreshFooter)];
    
    
}

- (void)refreshFooter
{
   
    // [self updateSomeThing];
    page++;

    ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Get_Moved_music]]];
    [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",page],Parameter_page,Limit_Constant,Parameter_Limit,[_searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"search", nil] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = requestForm;
    [requestForm setCompletionBlock :^{
        NSLog(@"%@",[weakrequest responseString]);
        NSLog(@"%d",[weakrequest responseStatusCode]);
        
        if ([weakrequest responseStatusCode] == 200) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
            if (isSearch) {
                
                [self.searchArray addObjectsFromArray:[[muzzik new] makeMuzziksByMusicArray:[dic objectForKey:@"music"]]];
                                    
            }else{
                [self.movedMusicArray addObjectsFromArray:[[muzzik new] makeMuzziksByMusicArray:[dic objectForKey:@"music"]]];
                [MuzzikItem SetUserInfoWithMuzziks:self.movedMusicArray title:Constant_userInfo_move description:[NSString stringWithFormat:@"喜欢列表"]];
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self.tableView footerEndRefreshing];
            });
        }
        else{
            //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
        }
    }];
    [requestForm setFailedBlock:^{
        [self.tableView footerEndRefreshing];
        NSLog(@"%@",[weakrequest error]);
        NSLog(@"hhhh%@  kkk%@",[weakrequest responseString],[weakrequest responseHeaders]);
    }];
    [requestForm startAsynchronous];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.keeper.activityVC = self;

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return isSearch ?[self.searchArray count]:[self.movedMusicArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MusicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MusicCell" forIndexPath:indexPath];
    muzzik *localMuzzik = isSearch ?self.searchArray[indexPath.row]:self.movedMusicArray[indexPath.row];
    cell.songName.text = localMuzzik.music.name;
    cell.Artist.text = localMuzzik.music.artist;
    cell.index = indexPath.row;
    cell.songVC = self;
    if ([[musicPlayer shareClass].localMuzzik.music.key isEqualToString:localMuzzik.music.key]) {
        [cell.playButton setImage:[UIImage imageNamed:@"stopImage_new"] forState:UIControlStateNormal];
    }else{
        [cell.playButton setImage:[UIImage imageNamed:@"playImage_new"] forState:UIControlStateNormal];
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.shareDic = [NSMutableDictionary dictionary];
    muzzik *tempMuzzik = [muzzik new];
    if (isSearch) {
        tempMuzzik = [self.searchArray objectAtIndex:indexPath.row];
    }
    else{
        tempMuzzik = [self.movedMusicArray objectAtIndex:indexPath.row];
    }
    MuzzikObject *mobject = [MuzzikObject shareClass];
    if ([self.keeper.comeInType isEqualToString:@"comment"]) {
        mobject.music = tempMuzzik.music;
        [self.keeper.navigationController popViewControllerAnimated:YES];
    }else{
        [MuzzikItem getLyricByMusic:tempMuzzik.music];
        if (mobject.isMessageVCOpen) {
            mobject.music = tempMuzzik.music;
            [self.keeper.navigationController popViewControllerAnimated:YES];
        }else{
            mobject.music = tempMuzzik.music;
            MessageStepViewController *msgVC = [[MessageStepViewController alloc] init];
            [self.keeper.navigationController pushViewController:msgVC animated:YES];
        }
    }
    
    
}

-(void)playMuzzikWithIndex:(NSInteger)index{
    musicPlayer *player = [musicPlayer shareClass];
    player.listType = MovedList;
    player.MusicArray = [self.searchArray count]>0 ?self.searchArray:self.movedMusicArray;
    player.index = index;
    [player playSongWithSongModel:isSearch ?self.searchArray[index]:self.movedMusicArray[index] Title:isSearch? [NSString stringWithFormat:@"搜索 %@ 的歌曲",_searchText] : @"喜欢列表"];
    if (isSearch) {
        [MuzzikItem SetUserInfoWithMuzziks:self.searchArray title:Constant_userInfo_temp description:[NSString stringWithFormat:@"搜索 %@ 的歌曲",_searchText]];
        player.listType = TempList;
    }else{
        [MuzzikItem SetUserInfoWithMuzziks:self.movedMusicArray title:Constant_userInfo_move description:[NSString stringWithFormat:@"喜欢列表"]];
        player.listType = MovedList;
    }
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        // do stuff
        
        muzzik *tempMuzzik = self.movedMusicArray[_index];
        ASIFormDataRequest *requestForm = [[ASIFormDataRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@%@",BaseURL,URL_UnMoved,tempMuzzik.music.music_id]]];
        userInfo *user = [userInfo shareClass];
        [requestForm setUseCookiePersistence:NO];
        if ([user.token length]>0) {
            [requestForm addRequestHeader:@"X-Auth-Token" value:user.token];
        }
        [requestForm setRequestMethod:@"DELETE"];
        __weak ASIFormDataRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            if ([weakrequest responseStatusCode] == 200) {
                [self.movedMusicArray removeObjectAtIndex:_index];
                [self.tableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:[NSIndexPath indexPathForRow:_index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else{
                //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
            }
        }];
        [requestForm setFailedBlock:^{
            NSLog(@"%@",[weakrequest error]);
            NSLog(@"hhhh%@  kkk%@",[weakrequest responseString],[weakrequest responseHeaders]);
            [userInfo checkLoginWithVC:self];
        }];
        [requestForm startAsynchronous];
    }
}

-(void)deleleMuzzikWithIndex:(NSInteger)index{
    _index = index;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"取消对这首歌的喜欢" message:@"" delegate:self cancelButtonTitle:@"放弃" otherButtonTitles:nil];
    // optional - add more buttons:
    [alert addButtonWithTitle:@"确定"];
    [alert show];
    
    
    
    
    
    
}
-(void)playnextMuzzikUpdate{
    [self.tableView reloadData];
    
    
}
-(void)updateDataSource:(NSString *)searchText{
    _searchText = searchText;
   // [self.searchArray removeAllObjects];
    if ([searchText length]>0) {
        isSearch = YES;
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Get_Moved_music]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:[_searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"search"] Method:GetMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            
            if ([weakrequest responseStatusCode] == 200) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
                self.searchArray = [[muzzik new] makeMuzziksByMusicArray:[dic objectForKey:@"music"]];
                [self.tableView reloadData];
            }
            else{
                //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
            }
        }];
        [requestForm setFailedBlock:^{
            NSLog(@"%@",[weakrequest error]);
            NSLog(@"hhhh%@  kkk%@",[weakrequest responseString],[weakrequest responseHeaders]);
            [userInfo checkLoginWithVC:self];
        }];
        [requestForm startAsynchronous];
    }else{
        isSearch = NO;
        [self.tableView reloadData];
    }
    
}

@end
