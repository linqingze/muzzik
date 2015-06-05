//
//  SearchForSong.m
//  muzzik
//
//  Created by muzzik on 15/5/4.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "SearchForSong.h"
#import "MusicAndArtistCell.h"
#import "MessageStepViewController.h"
#import "MuzzikObject.h"
#import "songDetailVCViewController.h"
@interface SearchForSong ()<searchSource,UITableViewDataSource,UITableViewDelegate>{
    UITableView *myTableView;
    NSInteger indexOfMuzzik;
    BOOL isSearch;
    NSString *pageID;
    NSInteger _index;
    NSString *_searchText;
    UIView *searchView;
    UILabel *searchLabel;
    int page;
}
@property(nonatomic,retain)NSMutableArray *searchArray;
@end

@implementation SearchForSong

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playnextMuzzikUpdate) name:String_SetSongPlayNextNotification object:nil];
    myTableView  = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-94)];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    [self.view addSubview:myTableView];
    
    
    myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    searchLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 13, SCREEN_WIDTH-60, 20)];
    [searchLabel setFont:[UIFont systemFontOfSize:14]];
    [searchLabel setTextColor:Color_Active_Button_1];
    UIImageView *searchImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 15, 15, 15)];
    [searchImage setImage:[UIImage imageNamed:Image_search_Oranger]];
    [searchView addSubview:searchImage];
    [searchView addSubview:searchLabel];
    [searchView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchSong)]];
    [MuzzikItem addLineOnView:searchView heightPoint:50 toLeft:13 toRight:13 withColor:Color_line_1];
    [myTableView registerClass:[MusicAndArtistCell class] forCellReuseIdentifier:@"MusicAndArtistCell"];
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.keeper.activityVC = self;
    [self.keeper followScrollView:myTableView];
    if ([self.keeper.searchBar.text length]>0 &&![_searchText isEqualToString:self.keeper.searchBar.text] && [self.searchArray count] == 0) {
        searchLabel.text = [NSString stringWithFormat:@"搜索相关音乐:%@",self.keeper.searchBar.text];
        [self.view addSubview:searchView];
    }

}

- (void)refreshFooter
{
    // [self updateSomeThing];
    if ([_searchText length]>0) {
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Music_Search]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:Limit_Constant,Parameter_Limit,[NSNumber numberWithInt:page],Parameter_page,[_searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"q", nil] Method:GetMethod auth:NO];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            
            if ([weakrequest responseStatusCode] == 200) {
                
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
                [self.searchArray addObjectsFromArray:[[muzzik new] makeMuzziksByMusicArray:[dic objectForKey:@"music"]]];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [myTableView reloadData];
                    [myTableView footerEndRefreshing];
                    if ([[dic objectForKey:@"music"] count]<[Limit_Constant integerValue] ) {
                        [myTableView removeFooter];
                    }else{
                        page ++;
                    }
                });
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MusicAndArtistCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MusicAndArtistCell" forIndexPath:indexPath];
    muzzik *localMuzzik = self.searchArray[indexPath.row];
    cell.songName.text = localMuzzik.music.name;
    cell.Artist.text = localMuzzik.music.artist;
    cell.index = indexPath.row;
    cell.songVC = self;
    Globle *glob = [Globle shareGloble];
    if ([[musicPlayer shareClass].localMuzzik.music.key isEqualToString:localMuzzik.music.key] && !glob.isPause) {
        [cell.playButton setImage:[UIImage imageNamed:@"stopImage_new"] forState:UIControlStateNormal];
    }else{
        [cell.playButton setImage:[UIImage imageNamed:@"playImage_new"] forState:UIControlStateNormal];
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    songDetailVCViewController *songDetail = [[songDetailVCViewController alloc] init];
    songDetail.detailMuzzik = self.searchArray[indexPath.row];
    [self.keeper.navigationController pushViewController:songDetail animated:YES];
}
-(void)updateDataSource:(NSString *)searchText{
    [self.searchArray removeAllObjects];
    [myTableView reloadData];
    if ([searchText length]>0) {
        searchLabel.text = [NSString stringWithFormat:@"搜索相关音乐:%@",self.keeper.searchBar.text];
        [self.view addSubview:searchView];
    }else {
        [searchView removeFromSuperview];
    }
}

-(void)searchDataSource:(NSString *)searchText{
     [searchView removeFromSuperview];
    _searchText = searchText;
    [self.searchArray removeAllObjects];
    if ([searchText length]>0) {
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Music_Search]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:Limit_Constant,Parameter_Limit,[searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"q", nil] Method:GetMethod auth:NO];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            
            if ([weakrequest responseStatusCode] == 200) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
                self.searchArray = [[muzzik new] makeMuzziksByMusicArray:[dic objectForKey:@"music"]];
                if ([[dic objectForKey:@"music"] count] == [Limit_Constant integerValue]) {
                    [myTableView addFooterWithTarget:self action:@selector(refreshFooter)];
                    page = 2;
                }
                [myTableView reloadData];
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
-(void)searchSong{
    [searchView removeFromSuperview];
    _searchText = self.keeper.searchBar.text;
    [self.searchArray removeAllObjects];
    if ([self.keeper.searchBar.text length]>0) {
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Music_Search]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:Limit_Constant,Parameter_Limit,[_searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"q", nil] Method:GetMethod auth:NO];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            
            if ([weakrequest responseStatusCode] == 200) {
            
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
                self.searchArray = [[muzzik new] makeMuzziksByMusicArray:[dic objectForKey:@"music"]];
                if ([[dic objectForKey:@"music"] count] == [Limit_Constant integerValue]) {
                    page = 2;
                    [myTableView addFooterWithTarget:self action:@selector(refreshFooter)];
                }
                [myTableView reloadData];
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

-(void)playnextMuzzikUpdate{
        [myTableView reloadData];
}
-(void)playMuzzikWithIndex:(NSInteger)index{
    musicPlayer *player = [musicPlayer shareClass];
    player.listType = TempList;
    player.MusicArray = self.searchArray;
    player.index = index;
    [player playSongWithSongModel:self.searchArray[index] Title:[NSString stringWithFormat:@"搜索 %@ 的歌曲",_searchText]];
    [MuzzikItem SetUserInfoWithMuzziks:self.searchArray title:Constant_userInfo_temp description:[NSString stringWithFormat:@"搜索 %@ 的歌曲",_searchText]];
    
    
}
-(void)commentMuzzikWithIndex:(NSInteger)index{
    muzzik *tempMuzzik = self.searchArray[index];
    MuzzikObject *mobject = [MuzzikObject shareClass];
    
    mobject.music = tempMuzzik.music;
    MessageStepViewController *messagebv = [[MessageStepViewController alloc] init];
    [self.keeper.navigationController pushViewController:messagebv animated:YES];
}

@end
