//
//  TopicVC.m
//  muzzik
//
//  Created by muzzik on 15/4/3.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "TopicVC.h"
#import "topicCell.h"


#define width_For_Cell 60.0
@interface TopicVC ()<UICollectionViewDataSource,UICollectionViewDelegate>{
    UICollectionView *hotTopicCollectionView;
    UICollectionView *hotUserCollectionView;
    NSArray *topicArray;
    NSArray *userArray;
    
}
@end

@implementation TopicVC

- (void)viewDidLoad {
    [super viewDidLoad];
    topicArray = @[@"324rdefw",@"32eftwe4rdefw",@"32verger4rdefw",@"324gergrerdefw",@"324rdefw",@"324rdefw",@"324rdefw",@"324rdefw"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIView *attentionView = [[UIView alloc] initWithFrame:CGRectMake(15, 15, SCREEN_WIDTH-30, 30)];
    [attentionView setBackgroundColor:[UIColor blueColor]];
    attentionView.layer.cornerRadius = 3;
    attentionView.clipsToBounds = YES;
    UITapGestureRecognizer *tapForAttention = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapForAttention)];
    [attentionView addGestureRecognizer:tapForAttention];
    [self.view addSubview:attentionView];
    
    UILabel * attentionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,0 , 30, 30)];
    [attentionLabel setText:@"关注"];
    [attentionLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [attentionLabel setTextColor:[UIColor whiteColor]];
    attentionLabel.textAlignment = NSTextAlignmentCenter;
    [attentionView addSubview:attentionLabel];
    
    UIImageView * nextImage = [[UIImageView alloc] initWithFrame:CGRectMake(attentionView.frame.size.width-30, 7, 16, 16)];
    nextImage.image = [UIImage imageNamed:@"黑返回向右"];
    [attentionView addSubview:nextImage];
    
    UICollectionViewFlowLayout  *flowLayout=[[ UICollectionViewFlowLayout alloc ] init ];
    
    [flowLayout setScrollDirection : UICollectionViewScrollDirectionVertical];
    flowLayout.minimumInteritemSpacing = 10;
    flowLayout.minimumLineSpacing = 10;
    
    hotTopicCollectionView = [[ UICollectionView alloc ] initWithFrame : CGRectMake (15,65,SCREEN_WIDTH-30,150) collectionViewLayout :flowLayout];
    [hotTopicCollectionView setBackgroundColor:[UIColor whiteColor]];
    //[hotTopicCollectionView setHeaderHidden:NO];
    hotTopicCollectionView.delegate = self;
    hotTopicCollectionView.dataSource = self;
    [hotTopicCollectionView setBackgroundColor:Color_underLine];
    [self.view addSubview:hotTopicCollectionView];
    
    UIView *TopicView = [[UIView alloc] initWithFrame:CGRectMake(15, 65, SCREEN_WIDTH-30, 30)];
    [TopicView setBackgroundColor:[UIColor clearColor]];
    TopicView.layer.cornerRadius = 3;
    TopicView.clipsToBounds = YES;
    UITapGestureRecognizer *tapForMoreTopic = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapForMoreTopic)];
    [TopicView addGestureRecognizer:tapForMoreTopic];
    [self.view addSubview:TopicView];
    
    UILabel * TopicLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,0 , 60, 30)];
    [TopicLabel setText:@"热门话题"];
    [TopicLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [TopicLabel setTextColor:[UIColor blackColor]];
    TopicLabel.textAlignment = NSTextAlignmentCenter;
    [TopicView addSubview:TopicLabel];
    
    UIImageView * nextImage1 = [[UIImageView alloc] initWithFrame:CGRectMake(attentionView.frame.size.width-30, 7, 16, 16)];
    nextImage1.image = [UIImage imageNamed:@"黑返回向右"];
    [TopicView addSubview:nextImage1];
    
    
    
    
    //    [_MycollectionView setFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    //    _MycollectionView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0);
    //  UINib *nib = [UINib nibWithNibName:@"TopicPictureCell" bundle:nil];
    //    [_MycollectionView registerNib:nib forCellWithReuseIdentifier:@"TopicPictureCell"];
    //    UINib *nib = [UINib nibWithNibName:@"topicProductCell" bundle:nil];
    //[_MycollectionView registerNib:nib forCellWithReuseIdentifier:@"topicProductCell"];
    [hotTopicCollectionView registerClass:[topicCell class] forCellWithReuseIdentifier:@"topicCell"];
    
  //  UIView *hotUserView = [UIView alloc] initWithFrame:CGRectMake(15, 230, self.view, <#CGFloat height#>)
    

//    UIView *activityUserView = [[UIView alloc] initWithFrame:CGRectMake(15, 60, SCREEN_WIDTH-30, 30)];
//    [activityUserView setBackgroundColor:[UIColor blueColor]];
//    activityUserView.layer.cornerRadius = 3;
//    activityUserView.clipsToBounds = YES;
//    UITapGestureRecognizer *tapForMoreUser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapForMoreUser)];
//    [attentionView addGestureRecognizer:tapForMoreUser];
//    [self.view addSubview:activityUserView];
    
    
    // Do any additional setup after loading the view.
}
#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return topicArray.count;
}

-( CGSize )collectionView:( UICollectionView *)collectionView layout:( UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:( NSIndexPath *)indexPath

{
    if (collectionView == hotTopicCollectionView) {
        UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
        [tempLabel setFont:[UIFont systemFontOfSize:12]];
        tempLabel.text = [topicArray objectAtIndex:indexPath.row];
        CGSize size = [tempLabel sizeThatFits:tempLabel.frame.size];
        return CGSizeMake(size.width+10, size.height+10);
    }
    else {
        return CGSizeMake ( 100 , 100 );
    }
    
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"111111");
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    topicCell *cell = [hotTopicCollectionView dequeueReusableCellWithReuseIdentifier:@"topicCell" forIndexPath:indexPath];
    cell.topicLabel.text = topicArray[indexPath.row];
    [cell setBackgroundColor:[UIColor orangeColor]];
    [cell sizeToFit];
    return cell;
}

#pragma mark <UICollectionViewDelegate>

-( UIEdgeInsets )collectionView:( UICollectionView *)collectionView layout:( UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:( NSInteger )section

{
    
    UIEdgeInsets top = UIEdgeInsetsMake(40, 5, 5, 5);
    
    return top;
    
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
#pragma -mark Action
-(void) tapForAttention{
    NSLog(@"tap");
}
-(void) tapForMoreUser{
    NSLog(@"user");
}
-(void) tapForMoreTopic{
    NSLog(@"topic");
}
@end
