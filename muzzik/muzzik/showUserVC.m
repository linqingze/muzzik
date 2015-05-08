//
//  showUserVC.m
//  muzzik
//
//  Created by muzzik on 15/5/2.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "showUserVC.h"
#import "AtfreindCell.h"
#import "UIImageView+WebCache.h"
#import "UIScrollView+DXRefresh.h"
@interface showUserVC ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_tableView;
    NSMutableArray *userArray;
    NSString *URLString;
    int page;
}

@end

@implementation showUserVC

- (void)viewDidLoad {
    [super viewDidLoad];
    page = 1;
    if ([_showType isEqualToString:@"repost"]){
        [self initNagationBar:@"转发用户" leftBtn:Constant_backImage rightBtn:0];
        URLString = [NSString stringWithFormat:@"%@%@%@",BaseURL,URL_RepostUsers,_muzzik_id];
    }else if ([_showType isEqualToString:@"share"]){
        URLString = [NSString stringWithFormat:@"%@%@%@",BaseURL,URL_ShareUsers,_muzzik_id];
        [self initNagationBar:@"分享用户" leftBtn:Constant_backImage rightBtn:0];
    }else if ([_showType isEqualToString:@"moved"]){
        URLString = [NSString stringWithFormat:@"%@%@%@",BaseURL,URL_MovedUsers,_muzzik_id];
        [self initNagationBar:@"喜欢用户" leftBtn:Constant_backImage rightBtn:0];
    }
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView registerClass:[AtfreindCell class] forCellReuseIdentifier:@"AtfreindCell"];
    ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :URLString]];
    [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:page] ,Parameter_page,@"20",Parameter_Limit, nil] Method:GetMethod auth:NO];
    __weak ASIHTTPRequest *weakrequest = requestForm;
    [requestForm setCompletionBlock :^{
        NSLog(@"%@",[weakrequest responseString]);
        NSLog(@"%d",[weakrequest responseStatusCode]);
        if ([weakrequest responseStatusCode] == 200) {
            page++;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
            userArray = [[MuzzikUser new] makeMuzziksByUserArray:[dic objectForKey:@"users"]];
            if ([[dic objectForKey:@"users"] count]<[Limit_Constant integerValue]) {
                [_tableView removeFooter];
            }
            [_tableView reloadData];
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
    [_tableView addFooterWithTarget:self action:@selector(refreshFooter)];
    // Do any additional setup after loading the view.
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_tableView removeFooter];
}
- (void)refreshFooter
{
    // [self updateSomeThing];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :URLString]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:page] ,Parameter_page,@"20",Parameter_Limit, nil] Method:GetMethod auth:NO];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        NSLog(@"%@",[weakrequest responseString]);
        NSLog(@"%d",[weakrequest responseStatusCode]);
        if ([weakrequest responseStatusCode] == 200) {
            page++;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
            [userArray addObjectsFromArray:[[MuzzikUser new] makeMuzziksByUserArray:[dic objectForKey:@"users"]]];
            if ([[dic objectForKey:@"users"] count]<[Limit_Constant integerValue]) {
                [_tableView removeFooter];
            }
            [_tableView reloadData];
        }
        else{
            //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%@,%@",[weakrequest responseHeaders],[weakrequest responseString]);
    }];
    [request startAsynchronous];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    return userArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * cellName = @"AtfreindCell";
    AtfreindCell * cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[AtfreindCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    MuzzikUser *muzzikuser = userArray[indexPath.row];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell.headerImage setAlpha:0];
    [cell.headerImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,muzzikuser.avatar]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [cell.headerImage setAlpha:1];
    }];
    cell.label.text = muzzikuser.name;
    //self.dataSource[indexPath.section][@"data"][indexPath.row];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    
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

@end
