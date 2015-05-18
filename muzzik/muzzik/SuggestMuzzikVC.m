//
//  SuggestMuzzikVC.m
//  muzzik
//
//  Created by muzzik on 15/5/17.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "SuggestMuzzikVC.h"
#import "suggestCollectionCell.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
@interface SuggestMuzzikVC ()<UICollectionViewDataSource,UICollectionViewDelegate>{
    NSMutableDictionary *RefreshDic;
    NSMutableArray *suggestMuzzik;
    UIPageControl *pagecontrol;
}

@end

@implementation SuggestMuzzikVC

- (void)viewDidLoad {
    [super viewDidLoad];
    RefreshDic = [NSMutableDictionary dictionary];
    [RefreshDic setValue:@"0" forKey:@"0"];
    pagecontrol = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 10, SCREEN_WIDTH, 10)];

    
    [pagecontrol setCurrentPageIndicatorTintColor:Color_Active_Button_1];
    [pagecontrol setPageIndicatorTintColor:Color_line_1];
    pagecontrol.numberOfPages = 10;
    [pagecontrol setCurrentPage:0];
    [self.view addSubview:pagecontrol];
    [self initNagationBar:@"选择风格" leftBtn:Constant_backImage rightBtn:0];
    UICollectionViewFlowLayout  *flowLayout=[[ UICollectionViewFlowLayout alloc ] init];
    [flowLayout setScrollDirection : UICollectionViewScrollDirectionHorizontal];
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    _suggestCollectionView = [[ UICollectionView alloc ] initWithFrame : CGRectMake (0,20,SCREEN_WIDTH,SCREEN_HEIGHT-64) collectionViewLayout :flowLayout];
    [_suggestCollectionView registerClass:[suggestCollectionCell class] forCellWithReuseIdentifier:@"suggestCollectionCell"];
    [_suggestCollectionView setBackgroundColor:[UIColor whiteColor]];
    //[hotTopicCollectionView setHeaderHidden:NO];
    _suggestCollectionView.delegate = self;
    _suggestCollectionView.dataSource = self;
    _suggestCollectionView.pagingEnabled = YES;
    [self.view addSubview:_suggestCollectionView];
    [self followScrollView:_suggestCollectionView];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/suggest",BaseURL]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"iamge",@"10",Parameter_Limit, nil] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        //    NSLog(@"%@",weakrequest.originalURL);
        NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic&&[[dic objectForKey:@"muzziks"]count]>0) {
            suggestMuzzik =  [[muzzik new] makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
            [_suggestCollectionView reloadData];
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
    }];
    [request startAsynchronous];
    // Do any additional setup after loading the view.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return suggestMuzzik.count;
}

-( CGSize )collectionView:( UICollectionView *)collectionView layout:( UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:( NSIndexPath *)indexPath

{
    
    return CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT-84);
    
    
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    muzzik *tempMuzzik = [suggestMuzzik objectAtIndex:indexPath.row];
    suggestCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"suggestCollectionCell" forIndexPath:indexPath];
    if (![[RefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%d",indexPath.row]]) {
        [RefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%d",indexPath.row]];
        [cell.headImage setAlpha:0];
        [cell.muzzikImage setAlpha:0];
    }
    [cell.muzzikImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?imageView2/1/w/600/h/600",BaseURL_image,tempMuzzik.image]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [UIView animateWithDuration:0.5 animations:^{
            [cell.muzzikImage setAlpha:1];
        }];
    }];
    [cell.headImage sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?imageView2/1/w/100/h/100",BaseURL_image,tempMuzzik.MuzzikUser.avatar]] forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [UIView animateWithDuration:0.5 animations:^{
            [cell.headImage setAlpha:1];
        }];
    }];
    cell.nameLabel.text = tempMuzzik.MuzzikUser.name;
    cell.timeLabel.text = [MuzzikItem transtromTime:tempMuzzik.date];
    cell.message.text = tempMuzzik.message;
    return cell;
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
- (void)scrollViewDidEndDecelerating:(UIScrollView *)sView
{
    NSInteger index = fabs(sView.contentOffset.x) / sView.frame.size.width;
    //NSLog(@"%d",index);
    [pagecontrol setCurrentPage:index];
}
@end
