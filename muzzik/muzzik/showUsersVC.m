//
//  showUsersVC.m
//  muzzik
//
//  Created by muzzik on 15/5/13.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "showUsersVC.h"
#import "UIScrollView+DXRefresh.h"
#import "searchUserCell.h"
#import "AttentionUser.h"
#import "UIButton+WebCache.h"
#import "userDetailInfo.h"
@interface showUsersVC ()<UITableViewDataSource,UITableViewDelegate,CellDelegate>{
    UITableView *userTableview;
    NSMutableArray *userArray;
    int page;
}

@end

@implementation showUsersVC

- (void)viewDidLoad {
    [super viewDidLoad];
    page = 2;
    userTableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    [self.view addSubview:userTableview];
    userTableview.delegate = self;
    userTableview.dataSource = self;
    userTableview.separatorStyle = UITableViewCellSeparatorStyleNone;

    [userTableview registerClass:[searchUserCell class] forCellReuseIdentifier:@"searchUserCell"];
    ASIHTTPRequest *requestForm;
    NSString *uid;
    if ([self.uid length]>0) {
        uid = self.uid;
    }else{
        uid = [userInfo shareClass].uid;
    }
    if ([self.showType isEqualToString:@"fans"]) {
        [self initNagationBar:@"粉丝" leftBtn:Constant_backImage rightBtn:0];
        requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@/fans",BaseURL,uid]]];
    }else{
        [self initNagationBar:@"关注" leftBtn:Constant_backImage rightBtn:0];
        requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@/follows",BaseURL,uid]]];
    }
    [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:Limit_Constant forKey:Parameter_Limit] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = requestForm;
    [requestForm setCompletionBlock :^{
        NSLog(@"%@",[weakrequest responseString]);
        NSLog(@"%d",[weakrequest responseStatusCode]);
        
        if ([weakrequest responseStatusCode] == 200) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
            userArray = [[AttentionUser new] makeAttentionUserByArray:[dic objectForKey:@"users"]];
            [userTableview reloadData];
            if ([userArray count]<[Limit_Constant integerValue]) {
                [userTableview removeFooter];
            }
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


- (void)refreshFooter
{
    ASIHTTPRequest *requestForm;
    NSString *uid;
    if ([self.uid length]>0) {
        uid = self.uid;
    }else{
        uid = [userInfo shareClass].uid;
    }
    if ([self.showType isEqualToString:@"fans"]) {
        requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@/fans",BaseURL,uid]]];
    }else{
        requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@/follows",BaseURL,uid]]];
    }
    [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:Limit_Constant,Parameter_Limit,[NSNumber numberWithInt:page],Parameter_page, nil] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = requestForm;
    [requestForm setCompletionBlock :^{
        NSLog(@"%@",[weakrequest responseString]);
        NSLog(@"%d",[weakrequest responseStatusCode]);
        
        if ([weakrequest responseStatusCode] == 200) {
            page++;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
            [userArray addObjectsFromArray :[[AttentionUser new] makeAttentionUserByArray:[dic objectForKey:@"users"]]];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [userTableview reloadData];
                [userTableview footerEndRefreshing];
                if ([[dic objectForKey:@"users"] count]<[Limit_Constant integerValue] ) {
                    [userTableview removeFooter];
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self.view setNeedsLayout];
    [userTableview addFooterWithTarget:self action:@selector(refreshFooter)];
    
    // MytableView add
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [userTableview removeFooter];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return userArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    searchUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchUserCell" forIndexPath:indexPath];
    AttentionUser *muzzikuser = userArray[indexPath.row];
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
-(void)attention:(NSInteger)index{
    AttentionUser *attentionuser = userArray[index];
    if (attentionuser.isFollow) {
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_user_Unfollow]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:attentionuser.uid forKey:@"_id"] Method:PostMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            
            if ([weakrequest responseStatusCode] == 200) {
                attentionuser.isFollow = NO;
                [userTableview reloadData];
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
                [userTableview reloadData];
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
    [self.navigationController pushViewController:detailuser animated:YES];
    
    
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
