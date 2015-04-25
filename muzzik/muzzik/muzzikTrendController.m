//
//  specialOfferListCollectionViewController.m
//  ShopUU
//
//  Created by 林清泽 on 15/1/8.
//  Copyright (c) 2015年 IOS. All rights reserved.
//

#import "UIImageView+WebCache.h"
#import "muzzikTrendController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "RepostCell.h"
#import "NormalCell.h"
#import "TopicHeaderView.h"
#import "appConfiguration.h"
#import <MediaPlayer/MediaPlayer.h>
#import "userInfo.h"
#import "playListController.h"
#import "CXAHyperlinkLabel.h"
#import "ChooseMusicVC.h"
#import "LoginViewController.h"
#define length_to_left 10
#define length_to_right 10
#define length_to_top 10
#define length_to_buttom 10
@interface muzzikTrendController (){
    int numberOfProducts;
    BOOL needsLoad;
    ASIHTTPRequest *myrequest;
    UITableView *MytableView;
    BOOL isPlaying;
    UIButton *newButton;
    
}

@end

@implementation muzzikTrendController

//static NSString * const reuseIdentifier = @"Cell";


- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playnextMuzzikUpdate) name:String_SetSongPlayNextNotification object:nil];
   // [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    _musicplayer = [musicPlayer shareClass];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    MytableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-40)];
    [MytableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    MytableView.dataSource = self;
    MytableView.delegate = self;
    [self.view addSubview:MytableView];
    [MytableView registerClass:[RepostCell class] forCellReuseIdentifier:@"RepostCell"];
    [MytableView registerClass:[NormalCell class] forCellReuseIdentifier:@"NormalCell"];
    [self reloadMuzzikSource];
    newButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-70, SCREEN_HEIGHT-125, 55, 55)];
    newButton.layer.cornerRadius = 28;
    newButton.clipsToBounds = YES;
    
   
    
    [newButton addTarget:self action:@selector(newOrLogin) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:newButton];
    //Tecent info

    
}
-(void)viewDidLayoutSubviews{
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        [newButton setImage:[UIImage imageNamed:@"addsongImage"] forState:UIControlStateNormal];
    }
    else{
        [newButton setImage:[UIImage imageNamed:@"yellowlikedImage"] forState:UIControlStateNormal];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.view setNeedsLayout];
    myrequest.delegate = self;

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    needsLoad = NO;
    [myrequest cancel];
    myrequest.delegate = nil;
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

#pragma mark <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    
    return self.muzziks.count;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CXAHyperlinkLabel *label = [[CXAHyperlinkLabel alloc] initWithFrame:CGRectMake(75, 0, SCREEN_WIDTH-110, 500)];
    muzzik *tempMuzzik = [self.muzziks objectAtIndex:indexPath.row];
    [label setText:tempMuzzik.message];
    CGSize msize = [label sizeThatFits:CGSizeMake(SCREEN_WIDTH-110, 2000)];
    return 240+msize.height;
//    if ([[muzzikArray[indexPath.row] objectForKey:@"type"] isEqualToString:@"normal"]) {
//        return 150+msize.height;
//    }
//    else if ([[muzzikArray[indexPath.row] objectForKey:@"type"] isEqualToString:@"repost"]){
//        return 170;
//    }
//    else{
//        return 170;
//    }
}



//-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    detailViewController *detail = [[detailViewController alloc] init];
//    detail.product_id = [productArray[indexPath.row] objectForKey:@"product_id"];
//    UINavigationController *nac = [[UINavigationController alloc] initWithRootViewController:detail];
//    [self presentViewController:nac animated:YES completion:NULL];
//    
//}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (self.muzziks.count>0) {
        muzzik *tempMuzzik = [self.muzziks objectAtIndex:indexPath.row];
        if ([tempMuzzik.type isEqualToString:@"repost"]) {
            RepostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RepostCell" forIndexPath:indexPath];
            if (!cell.hasLoad) {
                [cell.userImage setAlpha:0];
                cell.hasLoad = YES;
            }
            if ([tempMuzzik.music.key isEqualToString:self.musicplayer.localMuzzik.music.key]) {
                cell.isPlaying = YES;
            }else{
                cell.isPlaying = NO;
            }
            [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,tempMuzzik.MuzzikUser.avatar]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [UIView animateWithDuration:0.5 animations:^{
                    [cell.userImage setAlpha:1];
                }];
                
            }];
            cell.userName.text = tempMuzzik.MuzzikUser.name;

            [cell.muzzikMessage setText: [self transformMessage:tempMuzzik.message withTopics:tempMuzzik.topics andColorString:[NSString stringWithFormat:@"%@",tempMuzzik.color]]];
            cell.isMoved = tempMuzzik.ismoved;
            cell.index = indexPath.row;
            cell.muzzikMessage.delegate = self;
            CGSize msize = [cell.muzzikMessage sizeThatFits:CGSizeMake(SCREEN_WIDTH-110, 2000)];
            [cell.muzzikMessage setFrame:CGRectMake(cell.muzzikMessage.frame.origin.x, cell.muzzikMessage.frame.origin.y, msize.width, msize.height)];
            NSLog(@"%f",cell.muzzikMessage.frame.size.height);
            [cell.musicPlayView setFrame:CGRectMake(0, 70+cell.muzzikMessage.bounds.size.height, SCREEN_WIDTH, cell.musicPlayView.frame.size.height)];
            cell.musicArtist.text =tempMuzzik.music.artist;
            cell.musicName.text = tempMuzzik.music.name;
            cell.timeStamp.text = tempMuzzik.date;
            cell.songModel = [self.muzziks objectAtIndex:indexPath.row];
            [cell colorViewWithColorString:[NSString stringWithFormat:@"%@",tempMuzzik.color]];
            cell.muzzik_id = tempMuzzik.muzzik_id;
            cell.homeVc=self;
            if ([tempMuzzik.moveds integerValue]>0) {
                [cell.moves setTitle:[NSString stringWithFormat:@"喜欢数%@",tempMuzzik.moveds] forState:UIControlStateNormal];
            }else{
                [cell.moves setTitle:@"喜欢数" forState:UIControlStateNormal];
            }
            if ([tempMuzzik.reposts integerValue]>0) {
                [cell.reposts setTitle:[NSString stringWithFormat:@"转发数%@",tempMuzzik.reposts] forState:UIControlStateNormal];
            }
            else{
                [cell.reposts setTitle:@"转发数" forState:UIControlStateNormal];
            }
            if ([tempMuzzik.comments integerValue]>0) {
                [cell.comments setTitle:[NSString stringWithFormat:@"评论数%@",tempMuzzik.comments ] forState:UIControlStateNormal];
            }
            else{
                [cell.comments setTitle:@"评论数" forState:UIControlStateNormal];
            }
            if ([tempMuzzik.shares integerValue]>0) {
                [cell.shares setTitle:[NSString stringWithFormat:@"分享数%@",tempMuzzik.shares] forState:UIControlStateNormal];
            }
            else{
                [cell.shares setTitle:@"分享数" forState:UIControlStateNormal];
            }
            return  cell;
            
        }
        else if ([tempMuzzik.type isEqualToString:@"normal"]) {
                NormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell" forIndexPath:indexPath];
            if (!cell.hasLoad) {
                [cell.userImage setAlpha:0];
                cell.hasLoad = YES;
            }
            if ([tempMuzzik.music.key isEqualToString:self.musicplayer.localMuzzik.music.key]) {
                cell.isPlaying = YES;
            }else{
                cell.isPlaying = NO;
            }
                [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,tempMuzzik.MuzzikUser.avatar]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    [UIView animateWithDuration:0.5 animations:^{
                        [cell.userImage setAlpha:1];
                    }];
                    
                }];
                cell.userName.text = tempMuzzik.MuzzikUser.name;
            [cell.muzzikMessage setText: [self transformMessage:tempMuzzik.message withTopics:tempMuzzik.topics andColorString:[NSString stringWithFormat:@"%@",tempMuzzik.color]]];
            cell.isMoved =tempMuzzik.ismoved;
            
            cell.index = indexPath.row;
            cell.muzzikMessage.delegate = self;
            CGSize msize = [cell.muzzikMessage sizeThatFits:CGSizeMake(SCREEN_WIDTH-110, 2000)];
            [cell.muzzikMessage setFrame:CGRectMake(cell.muzzikMessage.frame.origin.x, cell.muzzikMessage.frame.origin.y, msize.width, msize.height)];
            NSLog(@"%f",cell.muzzikMessage.frame.size.height);
            [cell.musicPlayView setFrame:CGRectMake(0, 70+cell.muzzikMessage.bounds.size.height, SCREEN_WIDTH, cell.musicPlayView.frame.size.height)];
            cell.musicArtist.text = tempMuzzik.music.artist;
            cell.musicName.text = tempMuzzik.music.name;
            cell.timeStamp.text = tempMuzzik.date;
            cell.songModel = [self.muzziks objectAtIndex:indexPath.row];
            [cell colorViewWithColorString:[NSString stringWithFormat:@"%@",tempMuzzik.color]];
            cell.muzzik_id = tempMuzzik.muzzik_id;
            cell.homeVc=self;
            if ([tempMuzzik.moveds integerValue]>0) {
                [cell.moves setTitle:[NSString stringWithFormat:@"喜欢数%@",tempMuzzik.moveds] forState:UIControlStateNormal];
            }else{
                [cell.moves setTitle:@"喜欢数" forState:UIControlStateNormal];
            }
            if ([tempMuzzik.reposts integerValue]>0) {
                [cell.reposts setTitle:[NSString stringWithFormat:@"转发数%@",tempMuzzik.reposts] forState:UIControlStateNormal];
            }
            else{
                [cell.reposts setTitle:@"转发数" forState:UIControlStateNormal];
            }
            if ([tempMuzzik.comments integerValue]>0) {
                [cell.comments setTitle:[NSString stringWithFormat:@"评论数%@",tempMuzzik.comments] forState:UIControlStateNormal];
            }
            else{
                [cell.comments setTitle:@"评论数" forState:UIControlStateNormal];
            }
            if ([tempMuzzik.shares integerValue]>0) {
                [cell.shares setTitle:[NSString stringWithFormat:@"分享数%@",tempMuzzik.shares] forState:UIControlStateNormal];
            }
            else{
                [cell.shares setTitle:@"分享数" forState:UIControlStateNormal];
            }
                return  cell;
        }else{
            return nil;
        }
        
        }

    return nil;
    
}

-(NSString *)transformMessage:(NSString *)message withTopics:(NSArray *)topics andColorString:(NSString *)colorstring{
    //<a href='http://store.apple.com'>link to apple store</a>
    //<font face='HelveticaNeue-CondensedBold' size=20 color='#CCFF00'>
    NSMutableString *temp = [NSMutableString stringWithString:message];
    if ([topics count]>0) {
        for (NSDictionary *dic in topics) {
            temp = [NSMutableString stringWithFormat:@"%@",[temp stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"#%@#",[dic objectForKey:@"name"]] withString:[NSString stringWithFormat:@"<a href='%@'>#%@#</a>",[dic objectForKey:@"_id"],[dic objectForKey:@"name"]]]];
        }
    }
    return temp;
}

#pragma -mark Button_action
-(void) newOrLogin{
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        //new po
        ChooseMusicVC *choosevc = [[ChooseMusicVC alloc] init];
        [self.homeNav.navigationController pushViewController:choosevc animated:YES];
    }
    else{
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        [self.homeNav.navigationController pushViewController:loginVC animated:YES];
    }
}
-(void)rightBtnAction:(UIButton *)sender{
     
}

- (void)rtLabel:(id)rtLabel didSelectLinkWithURL:(NSURL*)url
{
   
}

-(void)playListAction{
    
//    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatSession];
//    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
//        if (response.responseCode == UMSResponseCodeSuccess) {
//            
//            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary]valueForKey:UMShareToWechatSession];
//            
//            NSLog(@"username is %@, uid is %@, token is %@ url is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
//            
//        }
//        
//    });

}
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    if (velocity.y>0) {
        [self.homeNav hideMusicView];
    }
    else if (velocity.y<0 && [[musicPlayer shareClass].MusicArray count]>0){
        [self.homeNav showMusicView];
    }
}

-(void)pressWithUrl:(NSURL *)url AndRange:(NSRange)rang{
    NSLog(@"%@",[url absoluteString]);
   // [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@",url]];
}
-(void)moveMuzzikWithId:(NSString *)muzzik_id isMoved:(BOOL) ismoved atIndex:(NSInteger) index{
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/%@/moved",BaseURL,muzzik_id]]];
        NSDictionary *dic;
        if (!ismoved ) {
            dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"ismoved"];
        }
        else{
            dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"ismoved"];
        }
        [requestForm addBodyDataSourceWithJsonByDic:dic];
        [requestForm setRequestMethod:@"POST"];
        //NSLog(@"json:%@,dic:%@",tempJsonData,dic);
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
              NSLog(@"%@",[weakrequest responseString]);
              NSLog(@"%d",[weakrequest responseStatusCode]);
            if ([weakrequest responseStatusCode] == 200) {
               // NSData *data = [weakrequest responseData];
                muzzik *localMuzzik = self.muzziks[index];
                localMuzzik.ismoved = [[dic objectForKey:@"ismoved"] boolValue];
                if ([[dic objectForKey:@"ismoved"] boolValue]) {
                    localMuzzik.moveds = [NSString stringWithFormat:@"%d",[localMuzzik.moveds integerValue]-1];
                }else{
                   localMuzzik.moveds = [NSString stringWithFormat:@"%d",[localMuzzik.moveds integerValue]-1];
                }
                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:index inSection:0];
                [MytableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
            }
            else{
                //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
            }
        }];
        [requestForm setFailedBlock:^{
            [KVNProgress showErrorWithStatus:@"网络请求超时"];
        }];
        [requestForm startAsynchronous];
    }
    
}
-(void)repostActionWithMuzzik_id:(NSString *)muzzik_id atIndex:(NSInteger) index{
    ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik",BaseURL]]];
    [requestForm setRequestMethod:@"PUT"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:muzzik_id forKey:@"repost"];
    [requestForm addBodyDataSourceWithJsonByDic:dictionary];
    //[requestForm setPostValue:@"true" forKey:@"ismoved"];
    
    __weak ASIHTTPRequest *weakrequest = requestForm;
    [requestForm setCompletionBlock :^{
        NSLog(@"%@",[weakrequest requestHeaders]);
        NSLog(@"%@",[weakrequest responseString]);
        NSLog(@"%d",[weakrequest responseStatusCode]);
        if ([weakrequest responseStatusCode] == 200) {
             muzzik *localMuzzik = self.muzziks[index];
            [KVNProgress showSuccessWithStatus:@"转发成功"];
            localMuzzik.reposts = [NSString stringWithFormat:@"%d",[localMuzzik.reposts integerValue]+1];
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:index inSection:0];
            [MytableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        }
        
        else if([weakrequest responseStatusCode] == 401){
            [userInfo checkLoginWithVC:self];
            //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
        }else if ([weakrequest responseStatusCode] == 400){
            [KVNProgress showSuccessWithStatus:@"此Muzzik您已转发过"];
        }
    }];
    [requestForm setFailedBlock:^{
        NSLog(@"%@",[weakrequest responseString]);
        [KVNProgress showErrorWithStatus:@"网络请求超时"];
    }];
    [requestForm startAsynchronous];
}
-(void)shareActionWithMuzzik_id:(NSString *)muzzik_id atIndex:(NSInteger)index{
    
}
-(void)reloadMuzzikSource{
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Muzzik_Trending]]];
    // [request setRequestMethod:@"PUT"];
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        [request addRequestHeader:@"X-Auth-Token" value:user.token];
    }
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            muzzik *muzzikToy = [muzzik new];
            self.muzziks = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
            [MytableView reloadData];
            
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%@,%@",[weakrequest responseHeaders],[weakrequest responseString]);
         [KVNProgress showErrorWithStatus:@"网络请求超时"];
    }];
    [request startAsynchronous];
}

-(void)playnextMuzzikUpdate{
    if ([musicPlayer shareClass].listType == SquareList) {
        [MytableView reloadData];
    }
    
    
}
-(void)playSongWithSongModel:(muzzik *)songModel{
    _musicplayer.listType = SquareList;
    _musicplayer.MusicArray = self.muzziks;
    [_musicplayer playSongWithSongModel:songModel];
    
    
    
    [self.homeNav checkShowMusicView];
}

@end
