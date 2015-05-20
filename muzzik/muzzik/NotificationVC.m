//
//  NotificationVC.m
//  muzzik
//
//  Created by muzzik on 15/5/4.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "NotificationVC.h"
#import "UIScrollView+DXRefresh.h"
#import "NotifyObject.h"
#import "NotifyFollowCell.h"
#import "NotifyMuzzikCell.h"
#import "UIButton+WebCache.h"
#import "userDetailInfo.h"
#import "DetaiMuzzikVC.h"
@interface NotificationVC ()<UITableViewDataSource,UITableViewDelegate,CellDelegate>{
    UITableView *notifyTabelView;
    NSMutableArray *notifyArray;
    NSMutableDictionary *RefreshDic;
    int page;
    
}

@end

@implementation NotificationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    page =1;
    notifyTabelView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    notifyTabelView.delegate = self;
    notifyTabelView.dataSource = self;
    
    notifyTabelView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:notifyTabelView];
    [notifyTabelView registerClass:[NotifyFollowCell class] forCellReuseIdentifier:@"NotifyFollowCell"];
    [notifyTabelView registerClass:[NotifyMuzzikCell class] forCellReuseIdentifier:@"NotifyMuzzikCell"];
    RefreshDic = [NSMutableDictionary dictionary];
    for (int i = 0; i<4; i++) {
        [RefreshDic setObject:[NSNumber numberWithInt:i] forKey:[NSString stringWithFormat:@"%d",i]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reloadMuzzikSource];
    [notifyTabelView addFooterWithTarget:self action:@selector(refreshFooter)];
    
    // MytableView add
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [notifyTabelView removeFooter];
    // [MytableView removeKeyPath];
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
            notifyArray = [[NotifyObject new] makeMuzziksByNotifyArray:[dic objectForKey:@"notifies"]];
            [notifyTabelView reloadData];
            page++;
        }
    }];
    [request setFailedBlock:^{
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
    
    if ([tempNotify.type isEqualToString:@"follow"] ||[tempNotify.type isEqualToString:@"friend_registered"] || [tempNotify.type isEqualToString:@"frient_exists"]) {
      NotifyFollowCell*  cell = [tableView dequeueReusableCellWithIdentifier:@"NotifyFollowCell" forIndexPath:indexPath];
        if (tempNotify.readed) {
            [cell.preImage setImage:[UIImage imageNamed:Image_notifollowclickImage]];
        }else{
            [cell.preImage setImage:[UIImage imageNamed:Image_notifollowImage]];
        }
        if (![[RefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%d",indexPath.row]]) {
            [RefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%d",indexPath.row]];
            [cell.headImage setAlpha:0];
        }
        [cell.headImage sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,tempNotify.user.avatar]] forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [UIView animateWithDuration:0.5 animations:^{
                [cell.headImage setAlpha:1];
            }];
        }];
        cell.user_id = tempNotify.user.user_id;
        cell.nameLabel.attributedText = [self creatTextByName:tempNotify.user.name Date:tempNotify.date];
        if ([tempNotify.type isEqualToString:@"follow"]) {
            cell.message.text = @"关注了你";
        }else if ([tempNotify.type isEqualToString:@"friend_registered"]) {
            
        }else if ([tempNotify.type isEqualToString:@"frient_exists"]) {
            
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
        
        if (![[RefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%d",indexPath.row]]) {
            [RefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%d",indexPath.row]];
            [cell.headImage setAlpha:0];
        }
        [cell.headImage sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,tempNotify.user.avatar]] forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [UIView animateWithDuration:0.5 animations:^{
                [cell.headImage setAlpha:1];
            }];
        }];
        cell.user_id = tempNotify.user.user_id;
        cell.nameLabel.attributedText = [self creatTextByName:tempNotify.user.name Date:tempNotify.date];
        
        if ([tempNotify.type isEqualToString:@"moved"]) {
            cell.message.text = @"喜欢了这条Muzzik";
        }else if([tempNotify.type isEqualToString:@"repost"]){
            cell.message.text = @"转发了这条Muzzik";
        }else if([tempNotify.type isEqualToString:@"comment"] || [tempNotify.type isEqualToString:@"at"]){
            cell.message.text = @"评论了你的Muzzik";
        }else if([tempNotify.type isEqualToString:@"participate_topic"]){
            cell.message.text = @"参与了你发起的话题";
        }
        cell.commentLabel.text = tempNotify.muzzik.message;
        cell.songname.text = tempNotify.muzzik.music.name;
        cell.artist.text = tempNotify.muzzik.music.artist;
        return cell;

    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NotifyObject *tempNotify = notifyArray[indexPath.row];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Read_Notify]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:tempNotify.notify_id,@"_id", nil] Method:PostMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
    }];
    [request setFailedBlock:^{
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
    }];
    [request startAsynchronous];
    
    muzzik *tempMuzzik = tempNotify.muzzik;
    tempMuzzik.MuzzikUser = tempNotify.user;
    DetaiMuzzikVC *detail = [[DetaiMuzzikVC alloc] init];
    detail.localmuzzik = tempMuzzik;
    [self.navigationController pushViewController:detail animated:YES];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
     NotifyObject *tempNotify = [notifyArray objectAtIndex:indexPath.row];
    if ([tempNotify.type isEqualToString:@"follow"] ||[tempNotify.type isEqualToString:@"friend_registered"] || [tempNotify.type isEqualToString:@"frient_exists"]) {
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
    userDetailInfo *detailuser = [[userDetailInfo alloc] init];
    detailuser.uid = user_id;
    [self.navigationController pushViewController:detailuser animated:YES];
    
    
}

-(void)reloadMuzzikSource{
    NSDictionary *requestDic;
    if (page>1) {
        
        requestDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",notifyArray.count],Parameter_Limit,[NSNumber numberWithBool:YES],@"full", nil];
    }else{
        requestDic = [NSDictionary dictionaryWithObjectsAndKeys:Limit_Constant,Parameter_Limit,[NSNumber numberWithBool:YES],@"full", nil];
        page++;
    }
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Notify]]];
    [request addBodyDataSourceWithJsonByDic:requestDic Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        //    NSLog(@"%@",weakrequest.originalURL);
        NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            notifyArray = [[NotifyObject new] makeMuzziksByNotifyArray:[dic objectForKey:@"notifies"]];
            [notifyTabelView reloadData];
            
            if (notifyArray.count < [Limit_Constant longLongValue]) {
                [notifyTabelView removeFooter];
            }
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
    }];
    [request startAsynchronous];
}
@end
