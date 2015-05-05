//
//  SearchForSong.m
//  muzzik
//
//  Created by muzzik on 15/5/4.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "SearchForSong.h"
#import "MusicAndArtistCell.h"
#import "UIScrollView+DXRefresh.h"
#import "MessageStepViewController.h"
#import "MuzzikObject.h"
@interface SearchForSong (){
    NSInteger indexOfMuzzik;
    BOOL isSearch;
    NSString *pageID;
    NSInteger _index;
    NSString *_searchText;
    NSInteger page;
    UIView *searchView;
    UILabel *searchLabel;
}
@property(nonatomic,retain)NSMutableArray *searchArray;
@end

@implementation SearchForSong

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playnextMuzzikUpdate) name:String_SetSongPlayNextNotification object:nil];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
    [self.tableView registerClass:[MusicAndArtistCell class] forCellReuseIdentifier:@"MusicAndArtistCell"];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.keeper.activityVC = self;
    if ([self.keeper.searchBar.text length]>0 &&![_searchText isEqualToString:self.keeper.searchBar.text]) {
        searchLabel.text = [NSString stringWithFormat:@"搜索相关音乐:%@",self.keeper.searchBar.text];
        [self.view addSubview:searchView];
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

-(void)updateDataSource:(NSString *)searchText{
    [self.searchArray removeAllObjects];
    [self.tableView reloadData];
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
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:[searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"q"] Method:GetMethod auth:NO];
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
    }
}
-(void)searchSong{
    [searchView removeFromSuperview];
    _searchText = self.keeper.searchBar.text;
    [self.searchArray removeAllObjects];
    if ([self.keeper.searchBar.text length]>0) {
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Music_Search]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:[self.keeper.searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"q"] Method:GetMethod auth:NO];
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
    }
}

-(void)playnextMuzzikUpdate{
    if ([musicPlayer shareClass].listType == TempList) {
        [self.tableView reloadData];
    }
    
    
}
-(void)playMuzzikWithIndex:(NSInteger)index{
    musicPlayer *player = [musicPlayer shareClass];
    player.listType = TempList;
    player.MusicArray = self.searchArray;
    player.index = index;
    [player playSongWithSongModel:self.searchArray[index]];
    
    
}
-(void)commentMuzzikWithIndex:(NSInteger)index{
    muzzik *tempMuzzik = self.searchArray[index];
    MuzzikObject *mobject = [MuzzikObject shareClass];
    
    mobject.music = tempMuzzik.music;
    [self.keeper.searchView setHidden:YES];
    MessageStepViewController *messagebv = [[MessageStepViewController alloc] init];
    [self.keeper.navigationController pushViewController:messagebv animated:YES];
}

@end
