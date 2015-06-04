//
//  CommentTableVC.m
//  muzzik
//
//  Created by muzzik on 15/5/7.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "CommentTableVC.h"
#import "CommentMuzzikCell.h"
#import "UIButton+WebCache.h"
#import "TopicDetail.h"
#import "userDetailInfo.h"
#import "DetaiMuzzikVC.h"
@interface CommentTableVC ()<UITableViewDataSource,UITableViewDelegate,TTTAttributedLabelDelegate,CellDelegate>{
    int numberOfProducts;
    BOOL needsLoad;
    NSMutableDictionary *RefreshDic;
    UITableView *MytableView;
    BOOL isPlaying;
    UIButton *newButton;
    NSString *lastId;
    NSString *headId;
    NSMutableArray *commentArray;
}

@end

@implementation CommentTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.uid = [userInfo shareClass].uid;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteMuzzik:) name:String_Muzzik_Delete object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playnextMuzzikUpdate) name:String_SetSongPlayNextNotification object:nil];
    // [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    MytableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-94)];
    [MytableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    MytableView.dataSource = self;
    MytableView.delegate = self;
    [self.view addSubview:MytableView];
    [MytableView registerClass:[CommentMuzzikCell class] forCellReuseIdentifier:@"CommentMuzzikCell"];
    
    [self followScrollView:MytableView];
    RefreshDic = [NSMutableDictionary dictionary];
    for (int i = 0; i<4; i++) {
        [RefreshDic setObject:[NSNumber numberWithInt:i] forKey:[NSString stringWithFormat:@"%d",i]];
    }
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@/muzziks",BaseURL,self.uid]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"reply",Limit_Constant,Parameter_Limit, nil] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        // NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            muzzik *muzzikToy = [muzzik new];
            commentArray = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
            lastId = [dic objectForKey:Parameter_tail];
           [MytableView reloadData];
            
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
    }];
    [request startAsynchronous];
    [MytableView addHeaderWithTarget:self action:@selector(refreshHeader)];
    [MytableView addFooterWithTarget:self action:@selector(refreshFooter)];
}
- (void)refreshHeader
{
    // [self updateSomeThing];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@/muzziks",BaseURL,self.uid]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"reply",Limit_Constant,Parameter_Limit, nil] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        // NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            muzzik *muzzikToy = [muzzik new];
            commentArray = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
            lastId = [dic objectForKey:Parameter_tail];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MytableView reloadData];
                [MytableView headerEndRefreshing];
            });
            
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
    }];
    [request startAsynchronous];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self.keeper followScrollView:MytableView];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    
}
- (void)refreshFooter
{
    // [self updateSomeThing];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@/muzziks",BaseURL,self.uid]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"reply",lastId,Parameter_from,Limit_Constant,Parameter_Limit, nil] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        // NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            muzzik *muzzikToy = [muzzik new];
            [commentArray addObjectsFromArray:[muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]]];
            lastId = [dic objectForKey:@"tail"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MytableView footerEndRefreshing];
                [MytableView reloadData];
                
                if ([[dic objectForKey:@"muzziks"] count]<[Limit_Constant integerValue] ) {
                    [MytableView removeFooter];
                }
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
-(void)userDetail:(NSString *)user_id{
    userDetailInfo *detailuser = [[userDetailInfo alloc] init];
    detailuser.uid = user_id;
     [self.keeper.navigationController pushViewController:detailuser animated:YES];
}

#pragma -mark tableView Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    muzzik *tempMuzzik = commentArray[indexPath.row];
    TTTAttributedLabel *label = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-140, 2000)];
    label.text = tempMuzzik.message;
    
    [label setFont:[UIFont systemFontOfSize:15]];
    CGSize msize = [label  sizeThatFits:CGSizeMake(SCREEN_WIDTH-140, 2000)];
    
    if (tempMuzzik.onlytext) {
        return 70+msize.height-15;
    }else{
        return 95+msize.height-15;
    }
    
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    muzzik *tempMuzzik = commentArray[indexPath.row];
    CommentMuzzikCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentMuzzikCell" forIndexPath:indexPath];
    [cell.userImage sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?imageView2/1/w/100/h/100",BaseURL_image,tempMuzzik.MuzzikUser.avatar]] forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [UIView animateWithDuration:0.5 animations:^{
            [cell.userImage setAlpha:1];
        }];
    }];
    
    cell.delegate = self;
    Globle *glob = [Globle shareGloble];
    BOOL ispalying = false;
    if ([tempMuzzik.muzzik_id isEqualToString:[musicPlayer shareClass].localMuzzik.muzzik_id] &&!glob.isPause) {
        ispalying = YES;
    }
    cell.MuzzikModel = tempMuzzik;
    cell.userName.text = tempMuzzik.MuzzikUser.name;
    [cell.userName sizeToFit];
    [cell.privateImage setFrame:CGRectMake(cell.userName.frame.origin.x+cell.userName.frame.size.width+5, cell.userName.frame.origin.y-2, 20, 20)];
    if (tempMuzzik.isprivate ) {
        [cell.privateImage setHidden:NO];
    }else{
        [cell.privateImage setHidden:YES];
    }
    cell.message.text = tempMuzzik.message;
    [cell.message addClickMessageForAt];
    [cell.message addClickMessagewithTopics:tempMuzzik.topics];
    CGSize msize = [cell.message sizeThatFits:CGSizeMake(SCREEN_WIDTH-140, 2000)];
    [cell.message setFrame:CGRectMake(cell.message.frame.origin.x, cell.message.frame.origin.y, msize.width, msize.height)];
    cell.timeLabel.text = [MuzzikItem transtromTime:tempMuzzik.date];
    if (!tempMuzzik.onlytext) {
        [cell.songName setHidden:NO];
        UIColor *color;
        if ([tempMuzzik.color longLongValue] == 1) {
            color = [UIColor colorWithHexString:@"fea42c"];
            if (ispalying) {
                [cell.playButton setImage:[UIImage imageNamed:Image_detailstopyellowImage] forState:UIControlStateNormal];
            }else{
                [cell.playButton setImage:[UIImage imageNamed:Image_detailyellowplay] forState:UIControlStateNormal];
            }
        }
        else if([tempMuzzik.color longLongValue] == 2){
            //bluelikeImage
            color = [UIColor colorWithHexString:@"04a0bf"];
            if (ispalying) {
                [cell.playButton setImage:[UIImage imageNamed:Image_detailstopblueImage] forState:UIControlStateNormal];
            }else{
                [cell.playButton setImage:[UIImage imageNamed:Image_detailblueplay] forState:UIControlStateNormal];
            }
        }
        else{
            color = [UIColor colorWithHexString:@"f26d7d"];
            if (ispalying) {
                [cell.playButton setImage:[UIImage imageNamed:Image_detailstopredImage] forState:UIControlStateNormal];
            }else{
                [cell.playButton setImage:[UIImage imageNamed:Image_detailredplay] forState:UIControlStateNormal];
            }
        }
        [cell.songName setFrame:CGRectMake(66, cell.message.frame.size.height+cell.message.frame.origin.y+16, SCREEN_WIDTH-140, 20)];
        NSMutableAttributedString *attributesText = [[NSMutableAttributedString alloc] init];
        
        NSAttributedString *item = [MuzzikItem formatAttrItem:tempMuzzik.music.name color:color font:[UIFont boldSystemFontOfSize:15]];
        [attributesText appendAttributedString:item];
        
        NSAttributedString *item1 = [MuzzikItem formatAttrItem:[NSString stringWithFormat:@"  %@",tempMuzzik.music.artist] color:color font:[UIFont boldSystemFontOfSize:13]];
        [attributesText appendAttributedString:item1];
        cell.songName.attributedText = attributesText;
        [cell.lineview setFrame:CGRectMake(16, cell.message.frame.size.height+cell.message.frame.origin.y+42, SCREEN_WIDTH-32, 1)];
    }else{
        [cell.lineview setFrame:CGRectMake(16, cell.message.frame.size.height+cell.message.frame.origin.y+20, SCREEN_WIDTH-32, 1)];
        if (ispalying) {
            [cell.playButton setImage:[UIImage imageNamed:Image_detailstoporangeImage] forState:UIControlStateNormal];
        }else{
            [cell.playButton setImage:[UIImage imageNamed:Image_detailgreyplay] forState:UIControlStateNormal];
        }
        
        [cell.songName setHidden:YES];
    }
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return commentArray.count;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([commentArray[indexPath.row] isKindOfClass:[muzzik class]]) {
        muzzik *tempMuzzik = commentArray[indexPath.row];
        DetaiMuzzikVC *detail = [[DetaiMuzzikVC alloc] init];
        detail.localmuzzik = tempMuzzik;
        [self.keeper.navigationController pushViewController:detail animated:YES];
    }
    
    
}
-(void)deleteMuzzik:(NSNotification *)notify{
    muzzik *localMzzik = notify.object;
    for (muzzik *tempMuzzik in commentArray) {
        if ([tempMuzzik.muzzik_id isEqualToString:localMzzik.muzzik_id]) {
            [commentArray removeObject:localMzzik];
            [MytableView reloadData];
            break;
        }
    }
    
}
-(void)pressWithUrl:(NSURL *)url AndRange:(NSRange)rang{
    
    NSString *urlId = [url.lastPathComponent substringFromIndex:1];
    NSLog(@"%@",url.lastPathComponent);
    if ([[url.lastPathComponent substringToIndex:1] isEqualToString:@"#"]) {
        TopicDetail *topicDetail = [[TopicDetail alloc] init];
        topicDetail.topic_id = urlId;
        [self.keeper.navigationController pushViewController:topicDetail animated:YES];
        
    }else {
        userDetailInfo *uInfo = [[userDetailInfo alloc] init];
        uInfo.uid = [urlId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [self.keeper.navigationController pushViewController:uInfo animated:YES];
        NSLog(@"好友");
    }
    // [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@",url]];
}
-(void)playSongWithSongModel:(muzzik *)songModel{
    [musicPlayer shareClass].listType = TempList;
    [musicPlayer shareClass].MusicArray = [NSMutableArray arrayWithArray:@[songModel]];
    [[musicPlayer shareClass] playSongWithSongModel:songModel Title:[NSString stringWithFormat:@"单曲<%@>",songModel.music.name]];
    [MuzzikItem SetUserInfoWithMuzziks: [NSMutableArray arrayWithArray:@[songModel]] title:Constant_userInfo_temp description:[NSString stringWithFormat:@"单曲<%@>",songModel.music.name]];
    
    if ([[musicPlayer shareClass].MusicArray count]>0) {
        for (UIView *view in [self.keeper.navigationController.view subviews]) {
            if ([view isKindOfClass:[RFRadioView class]]) {
                RFRadioView *musicView = (RFRadioView*)view;
                musicView.isOpen = YES;
                [UIView animateWithDuration:0.3 animations:^{
                    [musicView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
                }];
                break;
            }
        }
    }
    
    
    
}
-(void)playnextMuzzikUpdate{

    [MytableView reloadData];
}
@end
