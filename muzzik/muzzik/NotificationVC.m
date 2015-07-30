//
//  NotificationVC.m
//  muzzik
//
//  Created by muzzik on 15/5/4.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "NotificationVC.h"
#import "NotifyObject.h"
#import "NotifyFollowCell.h"
#import "NotifyMuzzikCell.h"
#import "UIButton+WebCache.h"
#import "userDetailInfo.h"
#import "DetaiMuzzikVC.h"
#import "UIImageView+WebCache.h"
@interface NotificationVC ()<UITableViewDataSource,UITableViewDelegate,CellDelegate>{
    UITableView *notifyTabelView;
    NSMutableArray *notifyArray;
    int page;
    
}

@end

@implementation NotificationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    page =1;
    [[MuzzikObject shareClass].notifyBUtton setHidden:YES];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteMuzzik:) name:String_Muzzik_Delete object:nil];
    [self initNagationBar:@"通知" leftBtn:Constant_backImage rightBtn:0];
    notifyTabelView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    notifyTabelView.delegate = self;
    notifyTabelView.dataSource = self;
    [self.view addSubview:notifyTabelView];
    [self followScrollView:notifyTabelView];
    notifyTabelView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [notifyTabelView registerClass:[NotifyFollowCell class] forCellReuseIdentifier:@"NotifyFollowCell"];
    [notifyTabelView registerClass:[NotifyMuzzikCell class] forCellReuseIdentifier:@"NotifyMuzzikCell"];
     [notifyTabelView addFooterWithTarget:self action:@selector(refreshFooter)];
    
    [notifyTabelView addHeaderWithTarget:self action:@selector(refreshHeader)];
    [notifyTabelView addFooterWithTarget:self action:@selector(refreshFooter)];
    [self loadDataMessage];
}
-(void)loadDataMessage{
    page = 1;
    NSDictionary *requestDic = [NSDictionary dictionaryWithObjectsAndKeys:Limit_Constant,Parameter_Limit,[NSNumber numberWithBool:YES],@"full", nil];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Notify]]];
    [request addBodyDataSourceWithJsonByDic:requestDic Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        //    NSLog(@"%@",weakrequest.originalURL);
        NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            [MuzzikItem addObjectToLocal:data ForKey:Constant_Data_notify];
            page++;
            notifyArray = [[NotifyObject new] makeMuzziksByNotifyArray:[dic objectForKey:@"notifies"]];
            [notifyTabelView reloadData];
            
            if (notifyArray.count < 1) {
                [notifyTabelView removeFooter];
            }
        }
    }];
    [request setFailedBlock:^{
        if (![[weakrequest responseString] length]>0) {
            [self networkErrorShow];
        }
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
        if (![[weakrequest responseString] length]>0) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[MuzzikItem getDataFromLocalKey:Constant_Data_notify] options:NSJSONReadingMutableContainers error:nil];
            if (dic) {
                page++;
                notifyArray = [[NotifyObject new] makeMuzziksByNotifyArray:[dic objectForKey:@"notifies"]];
                [notifyTabelView reloadData];
                
            }
        }
    }];
    [request startAsynchronous];
}
-(void)reloadDataSource{
    [super reloadDataSource];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadDataMessage];
    });
    
    
}

-(void)refreshHeader{
    NSDictionary *requestDic = [NSDictionary dictionaryWithObjectsAndKeys:Limit_Constant,Parameter_Limit,[NSNumber numberWithBool:YES],@"full", nil];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Notify]]];
    [request addBodyDataSourceWithJsonByDic:requestDic Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        //    NSLog(@"%@",weakrequest.originalURL);
        NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            page =2 ;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [notifyTabelView headerEndRefreshing];
                notifyArray = [[NotifyObject new] makeMuzziksByNotifyArray:[dic objectForKey:@"notifies"]];
                 [notifyTabelView reloadData];
            });
            
            
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
    }];
    [request startAsynchronous];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [notifyTabelView reloadData];
    // MytableView add
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

}
-(void) refreshFooter{
  
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Notify]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:Limit_Constant,Parameter_Limit,[NSNumber numberWithInt:page],Parameter_page,[NSNumber numberWithBool:YES],@"full", nil] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        //    NSLog(@"%@",weakrequest.originalURL);
        NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            [notifyArray addObjectsFromArray:[[NotifyObject new] makeMuzziksByNotifyArray:[dic objectForKey:@"notifies"]]];
            page++;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [notifyTabelView footerEndRefreshing];
                [notifyTabelView reloadData];
                
                if ([[dic objectForKey:@"notifies"] count]<1 ) {
                    [notifyTabelView removeFooter];
                }
            });
        }
    }];
    [request setFailedBlock:^{
        [notifyTabelView footerEndRefreshing];
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
    }];
    [request startAsynchronous];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return notifyArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotifyObject *tempNotify = [notifyArray objectAtIndex:indexPath.row];
    NSLog(@"%d",[tempNotify.type isEqualToString:@"friend_exists"]);
    if ([tempNotify.type isEqualToString:@"follow"] ||[tempNotify.type isEqualToString:@"friend_registered"] || [tempNotify.type isEqualToString:@"friend_exists"]) {
      NotifyFollowCell*  cell = [tableView dequeueReusableCellWithIdentifier:@"NotifyFollowCell" forIndexPath:indexPath];
        if (tempNotify.readed) {
            [cell.preImage setImage:[UIImage imageNamed:Image_notifollowclickImage]];
        }else{
            [cell.preImage setImage:[UIImage imageNamed:Image_notifollowImage]];
        }
        [cell.headImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,tempNotify.user.avatar]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [UIView animateWithDuration:0.5 animations:^{
                [cell.headImage setAlpha:1];
            }];
        }];
        cell.user_id = tempNotify.user.user_id;
        cell.nameLabel.attributedText = [self creatTextByName:tempNotify.user.name Date:tempNotify.date];
        if ([tempNotify.type isEqualToString:@"follow"]) {
            cell.message.text = @"关注了你";
        }else if ([tempNotify.type isEqualToString:@"friend_registered"]) {
            cell.message.text = @"微博好友加入了Muzzik";
        }else if ([tempNotify.type isEqualToString:@"friend_exists"]) {
            cell.message.text = @"微博好友在Muzzik里等候你好久好久了....";
        }
       return cell;
    }else{
        NotifyMuzzikCell*  cell = [tableView dequeueReusableCellWithIdentifier:@"NotifyMuzzikCell" forIndexPath:indexPath];
        if (!tempNotify.readed) {
            if ([tempNotify.type isEqualToString:@"moved"]) {
                [cell.preImage setImage:[UIImage imageNamed:Image_notilikeImage]];
            }else if([tempNotify.type isEqualToString:@"repost"]){
                [cell.preImage setImage:[UIImage imageNamed:Image_notiretweetImage]];
            }else if([tempNotify.type isEqualToString:@"comment"] || [tempNotify.type isEqualToString:@"at"]){
                [cell.preImage setImage:[UIImage imageNamed:Image_notireplyImage]];
            }else if([tempNotify.type isEqualToString:@"participate_topic"]){
                [cell.preImage setImage:[UIImage imageNamed:Image_notitopicImage]];
            }
        }else{
            if ([tempNotify.type isEqualToString:@"moved"]) {
                [cell.preImage setImage:[UIImage imageNamed:Image_notilikeclickImage]];
            }else if([tempNotify.type isEqualToString:@"repost"]){
                [cell.preImage setImage:[UIImage imageNamed:Image_notiretweetclickImage]];
            }else if([tempNotify.type isEqualToString:@"comment"] || [tempNotify.type isEqualToString:@"at"]){
                [cell.preImage setImage:[UIImage imageNamed:Image_notireplyclickImage]];
            }else if([tempNotify.type isEqualToString:@"participate_topic"]){
                [cell.preImage setImage:[UIImage imageNamed:Image_notitopicclickImage]];
            }
        }

        [cell.headImage sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,tempNotify.user.avatar]] forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [UIView animateWithDuration:0.5 animations:^{
                [cell.headImage setAlpha:1];
            }];
        }];
        cell.user_id = tempNotify.user.user_id;
        cell.nameLabel.attributedText = [self creatTextByName:tempNotify.user.name Date:tempNotify.date];
        cell.delegate = self;
        if ([tempNotify.type isEqualToString:@"moved"]) {
            cell.message.text = @"喜欢了这条Muzzik";
        }else if([tempNotify.type isEqualToString:@"repost"]){
            cell.message.text = @"转发了这条Muzzik";
        }else if([tempNotify.type isEqualToString:@"comment"]){
            cell.message.text = @"回复了你的Muzzik";
        }else if([tempNotify.type isEqualToString:@"at"]){
             cell.message.text = @"提到了你";
        }else if([tempNotify.type isEqualToString:@"participate_topic"]){
            cell.message.text = @"参与了你发起的话题";
        }
        UIColor *color;
        if ([tempNotify.muzzik.color intValue]==1) {
            color = Color_Action_Button_1;
        }else if ([tempNotify.muzzik.color intValue]==2){
            color = Color_Action_Button_2;
        }else{
            color = Color_Action_Button_3;
        }
        cell.commentLabel.text = tempNotify.muzzik.message;
        cell.songname.text = tempNotify.muzzik.music.name;
        cell.artist.text = tempNotify.muzzik.music.artist;
        [cell.songname setTextColor:color];
        [cell.artist setTextColor:color];
        return cell;

    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NotifyObject *tempNotify = [notifyArray objectAtIndex:indexPath.row];
    tempNotify.readed = YES;
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Read_Notify]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:tempNotify.notify_id,@"_id", nil] Method:PostMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
    }];
    [request setFailedBlock:^{
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
    }];
    [request startAsynchronous];
    if ([tempNotify.type isEqualToString:@"follow"] ||[tempNotify.type isEqualToString:@"friend_registered"] || [tempNotify.type isEqualToString:@"friend_exists"]) {
        userInfo *user = [userInfo shareClass];
        if ([tempNotify.user.user_id isEqualToString:user.uid]) {
            UserHomePage *home = [[UserHomePage alloc] init];
            [self.navigationController pushViewController:home animated:YES];
        }else{
            userDetailInfo *detailuser = [[userDetailInfo alloc] init];
            detailuser.uid = tempNotify.user.user_id;
            [self.navigationController pushViewController:detailuser animated:YES];
        }
    }else{
        muzzik *tempMuzzik = tempNotify.muzzik;
        tempMuzzik.MuzzikUser = tempNotify.muzzik.MuzzikUser;
        DetaiMuzzikVC *detail = [[DetaiMuzzikVC alloc] init];
        detail.localmuzzik = tempMuzzik;
        [self.navigationController pushViewController:detail animated:YES];
    }
   
}
-(void)deleteMuzzik:(NSNotification *)notify{
    muzzik *localMzzik = notify.object;
    for (NotifyObject *tempMuzzik in notifyArray) {
        if ([tempMuzzik.muzzik.muzzik_id isEqualToString:localMzzik.muzzik_id]) {
            [notifyArray removeObject:localMzzik];
            [notifyTabelView reloadData];
            break;
        }
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
     NotifyObject *tempNotify = [notifyArray objectAtIndex:indexPath.row];
    if ([tempNotify.type isEqualToString:@"follow"] ||[tempNotify.type isEqualToString:@"friend_registered"] || [tempNotify.type isEqualToString:@"friend_exists"]) {
        return 72.0;
    }else{
        return 152;
    }
}
-(NSMutableAttributedString *)creatTextByName:(NSString *)name Date:(NSString *)date{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
    NSString *itemStr = name;
    NSAttributedString *item = [MuzzikItem formatAttrItem:itemStr color:Color_Text_1  font:[UIFont fontWithName:Font_Next_DemiBold size:16]];
    [text appendAttributedString:item];
    NSString *itemStr1 = [NSString stringWithFormat:@"    %@",[MuzzikItem transtromTime:date]];
    NSAttributedString *item1 = [MuzzikItem formatAttrItem:itemStr1 color:Color_Additional_5  font:[UIFont systemFontOfSize:9]];
    [text appendAttributedString:item1];
    return  text;
}
-(void)userDetail:(NSString *)user_id{
    userInfo *user = [userInfo shareClass];
    if ([user_id isEqualToString:user.uid]) {
        UserHomePage *home = [[UserHomePage alloc] init];
        [self.navigationController pushViewController:home animated:YES];
    }else{
        userDetailInfo *detailuser = [[userDetailInfo alloc] init];
        detailuser.uid = user_id;
        [self.navigationController pushViewController:detailuser animated:YES];
    }
}

@end
