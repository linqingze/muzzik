//
//  settingSystemVC.m
//  muzzik
//
//  Created by muzzik on 15/5/11.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "settingSystemVC.h"
#import "SettingCell.h"
#import "TeachViewController.h"
#import "FeedBackVC.h"
@interface settingSystemVC ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *settingTable;
    
}

@end

@implementation settingSystemVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNagationBar:@"设置" leftBtn:Constant_backImage rightBtn:0];
    settingTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    settingTable.dataSource = self;
    settingTable.delegate = self;
    [settingTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:settingTable];
    [settingTable registerClass:[SettingCell class] forCellReuseIdentifier:@"SettingCell"];
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [settingTable reloadData];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.textColor = Color_Text_1;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell.textLabel setFont:[UIFont systemFontOfSize:14]];
    [MuzzikItem addLineOnView:cell heightPoint:60 toLeft:13 toRight:13 withColor:Color_line_1];

    if (indexPath.row == 0) {
        SettingCell *Scell = [tableView dequeueReusableCellWithIdentifier:@"SettingCell" forIndexPath:indexPath];
        Scell.label.text = @"摇一摇切歌";
        Scell.cellKeeper = self;
        NSString * shakeSwitch = [MuzzikItem getStringForKey:@"User_shakeActionSwitch"];
        if (![shakeSwitch isEqualToString:@"close"]) {
            _isClosed = NO;
            [Scell.shakeSwitch setOn:YES ];
        }else{
            _isClosed = YES;
            [Scell.shakeSwitch setOn:NO];
        }
        return Scell;
    }else if (indexPath.row == 1) {
        cell.textLabel.text = @"赏Muzzik 好评";
        
    }else if (indexPath.row == 2) {
        cell.textLabel.text = @"意见反馈";
    }else if (indexPath.row == 3) {
        cell.textLabel.text = @"关于Muzzik";
    }else if(indexPath.row == 4){
        userInfo *user = [userInfo shareClass];
        if ([user.token length]>0) {
            cell.textLabel.text = @"退出账号";
        }else{
            cell.textLabel.text = @"登录账号";
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0) {

    }else if (indexPath.row == 1) {
        NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@?mt=8",APP_ID ];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]]; 

        
    }else if (indexPath.row == 2) {
        FeedBackVC *feedback = [[FeedBackVC alloc] init];
        [self.navigationController pushViewController:feedback animated:YES];
    }else if (indexPath.row == 3) {
        TeachViewController *teach = [[TeachViewController alloc] initWithNibName:@"TeachViewController" bundle:nil];
        teach.showType = @"about";
        [self.navigationController pushViewController:teach animated:YES];
    }else if (indexPath.row == 4){
        userInfo *user = [userInfo shareClass];
        if ([user.token length]>0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确认退出登录" message:@"" delegate:self cancelButtonTitle:@"放弃" otherButtonTitles:nil];
            // optional - add more buttons:
            [alert addButtonWithTitle:@"确定"];
            [alert show];
        }else{
            [userInfo checkLoginWithVC:self];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        // do stuff
        userInfo *user = [userInfo shareClass];
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/notify/tokens/%@?type=APN",BaseURL,user.deviceToken]]];
        [request addBodyDataSourceWithJsonByDic:nil Method:DeleteMethod auth:YES];
        __weak ASIHTTPRequest *weakreq = request;
        [request setCompletionBlock :^{
            NSLog(@"%@",[weakreq responseString]);
            ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Logout]]];
            [requestForm addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
            __weak ASIHTTPRequest *weakrequest = requestForm;
            [requestForm setCompletionBlock :^{
                NSLog(@"%@",[weakrequest responseString]);
                NSLog(@"%d",[weakrequest responseStatusCode]);
                if ([weakrequest responseStatusCode] == 200) {
                    userInfo *user = [userInfo shareClass];
                    user.token = nil;
                    [MuzzikItem removeMessageFromLocal:@"LoginAcess"];
                    [MuzzikItem addObjectToLocal:nil ForKey:Constant_Data_moved];
                    [MuzzikItem addObjectToLocal:nil ForKey:Constant_Data_ownMuzzik];
                    [MuzzikItem addObjectToLocal:nil ForKey:Constant_Data_User_home];
                    [MuzzikItem addObjectToLocal:nil ForKey:Constant_Data_notify];
                    
                    [settingTable reloadData];
                    [userInfo checkLoginWithVC:self];
                }
                else{
                    
                    
                    //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
                }
            }];
            [requestForm setFailedBlock:^{
                NSLog(@"%@",[weakrequest error]);
                NSLog(@"hhhh%@  kkk%@",[weakrequest responseString],[weakrequest responseHeaders]);
            }];
            [requestForm startAsynchronous];
            
        }];
        [request setFailedBlock:^{
            NSLog(@"%@",[weakreq error]);
        }];
        [request startAsynchronous];
        
       
        
    }else{
        
    }

    
}
-(void)reloadTable{
    [settingTable reloadData];
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
