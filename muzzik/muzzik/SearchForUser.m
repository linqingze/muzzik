//
//  SearchForUser.m
//  muzzik
//
//  Created by muzzik on 15/5/4.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "SearchForUser.h"
#import "searchUserCell.h"
#import "UIButton+WebCache.h"
#import "MuzzikObject.h"
#import "AttentionUser.h"
#import "userDetailInfo.h"
@interface SearchForUser ()<CellDelegate>{
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

@implementation SearchForUser

- (void)viewDidLoad {
    page = 1;
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    searchLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 13, SCREEN_WIDTH-60, 20)];
    [searchLabel setFont:[UIFont systemFontOfSize:14]];
    [searchLabel setTextColor:Color_Active_Button_1];
    UIImageView *searchImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 15, 15, 15)];
    [searchImage setImage:[UIImage imageNamed:Image_search_Oranger]];
    [searchView addSubview:searchImage];
    [searchView addSubview:searchLabel];
    [searchView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchUser)]];
    [MuzzikItem addLineOnView:searchView heightPoint:50 toLeft:13 toRight:13 withColor:Color_line_1];
    [self.tableView registerClass:[searchUserCell class] forCellReuseIdentifier:@"searchUserCell"];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.keeper.activityVC = self;
    if ([self.keeper.searchBar.text length]>0 &&![_searchText isEqualToString:self.keeper.searchBar.text]) {
        searchLabel.text = [NSString stringWithFormat:@"搜索相关音乐:%@",self.keeper.searchBar.text];
        [self.view addSubview:searchView];
    }
    
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
    return self.searchArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    searchUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchUserCell" forIndexPath:indexPath];
    AttentionUser *muzzikuser = self.searchArray[indexPath.row];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell.headerImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?imageView2/1/w/100/h/100",BaseURL_image,muzzikuser.avatar]] forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [cell.headerImage setAlpha:1];
    }];
    cell.delegate = self;
    cell.muzzikUser = muzzikuser;
    cell.index = indexPath.row;
    cell.label.text = muzzikuser.name;
    if (muzzikuser.isFollow &&muzzikuser.isFans) {
        [cell.attentionButton setImage:[UIImage imageNamed:Image_followedeachotherImageSQ] forState:UIControlStateNormal];
        [cell.attentionButton setFrame:CGRectMake(SCREEN_WIDTH-80, 0, 65, 60)];
    }else if(muzzikuser.isFollow){
        [cell.attentionButton setImage:[UIImage imageNamed:Image_followedImageSQ] forState:UIControlStateNormal];
        [cell.attentionButton setFrame:CGRectMake(SCREEN_WIDTH-70, 0, 55, 60)];
    }else{
        [cell.attentionButton setImage:[UIImage imageNamed:Image_followImageSQ] forState:UIControlStateNormal];
        [cell.attentionButton setFrame:CGRectMake(SCREEN_WIDTH-60, 0, 45, 60)];
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
    [self searchUser];
}
//关注用户
-(void)attention:(NSInteger)index{
    AttentionUser *attentionuser = self.searchArray[index];
    if (attentionuser.isFollow) {
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_user_Unfollow]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:attentionuser.uid forKey:@"_id"] Method:PostMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            
            if ([weakrequest responseStatusCode] == 200) {
                attentionuser.isFollow = NO;
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
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_User_Follow]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:attentionuser.uid forKey:@"_id"] Method:PostMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            
            if ([weakrequest responseStatusCode] == 200) {
                attentionuser.isFollow = YES;
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

-(void) searchUser{
    [searchView removeFromSuperview];
    _searchText = self.keeper.searchBar.text;
    [self.searchArray removeAllObjects];
    if ([self.keeper.searchBar.text length]>0) {
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Users_search]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:[self.keeper.searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"name"] Method:GetMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            
            if ([weakrequest responseStatusCode] == 200) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
                self.searchArray = [[AttentionUser new] makeAttentionUserByArray:[dic objectForKey:@"users"]];
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
-(void)userDetail:(NSString *)user_id{
    userDetailInfo *detailuser = [[userDetailInfo alloc] init];
    detailuser.uid = user_id;
    [self.keeper.navigationController pushViewController:detailuser animated:YES];
}
@end
