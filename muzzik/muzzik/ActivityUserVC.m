//
//  ActivityUserVC.m
//  muzzik
//
//  Created by muzzik on 15/5/17.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "ActivityUserVC.h"
#import "searchUserCell.h"
#import "userDetailInfo.h"
#import "UIImageView+WebCache.h"
@interface ActivityUserVC ()<UITableViewDataSource,UITableViewDelegate,CellDelegate>{
    UITableView *userTableview;
    NSMutableArray *userArray;
    NSMutableDictionary *RefreshDic;
}

@end

@implementation ActivityUserVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataSourceUserUpdate:) name:String_UserDataSource_update object:nil];
    RefreshDic = [NSMutableDictionary dictionary];
    for (int i = 0; i<4; i++) {
        [RefreshDic setObject:[NSNumber numberWithInt:i] forKey:[NSString stringWithFormat:@"%d",i]];
    }
    [self initNagationBar:@"活跃用户" leftBtn:Constant_backImage rightBtn:0];
    userTableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    [self.view addSubview:userTableview];
    userTableview.delegate = self;
    userTableview.dataSource = self;
    userTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [userTableview registerClass:[searchUserCell class] forCellReuseIdentifier:@"searchUserCell"];
    [self followScrollView:userTableview];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/suggest",BaseURL]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:@"6" forKey:Parameter_Limit] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        //    NSLog(@"%@",weakrequest.originalURL);
        NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            
            MuzzikUser *muzzikToy = [MuzzikUser new];
            userArray = [muzzikToy makeMuzziksByUserArray:[dic objectForKey:@"users"]];
            [userTableview reloadData];
        }
        }];
        [request setFailedBlock:^{
            NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
        }];
        [request startAsynchronous];
    // Do any additional setup after loading the view.
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
    MuzzikUser *muzzikuser = userArray[indexPath.row];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (![[RefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%d",indexPath.row]]) {
        [RefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%d",indexPath.row]];
        [cell.headerImage setAlpha:0];
    }
    [cell.headerImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?imageView2/1/w/100/h/100",BaseURL_image,muzzikuser.avatar]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [UIView animateWithDuration:0.5 animations:^{
            [cell.headerImage setAlpha:1];
        }];
        
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MuzzikUser *attentionuser = userArray[indexPath.row];
    userDetailInfo *detailuser = [[userDetailInfo alloc] init];
    detailuser.uid = attentionuser.user_id;
    [self.navigationController pushViewController:detailuser animated:YES];
    
}
-(void)attention:(NSInteger)index{
    MuzzikUser *attentionuser = userArray[index];
    if (attentionuser.isFollow) {
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_user_Unfollow]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:attentionuser.user_id forKey:@"_id"] Method:PostMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            
            if ([weakrequest responseStatusCode] == 200) {
                attentionuser.isFollow = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:String_UserDataSource_update object:attentionuser];
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
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:attentionuser.user_id forKey:@"_id"] Method:PostMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            
            if ([weakrequest responseStatusCode] == 200) {
                attentionuser.isFollow = YES;
               [[NSNotificationCenter defaultCenter] postNotificationName:String_UserDataSource_update object:attentionuser];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dataSourceUserUpdate:(NSNotification *)notify{
    MuzzikUser *user = notify.object;
    if ([MuzzikItem checkMutableArray:userArray isContainUser:user]) {
        [userTableview reloadData];
    }
}

@end
