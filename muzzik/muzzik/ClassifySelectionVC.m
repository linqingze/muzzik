//
//  ClassifySelectionVC.m
//  muzzik
//
//  Created by muzzik on 15/5/7.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "ClassifySelectionVC.h"
#import "topicCell.h"
@interface ClassifySelectionVC ()<UICollectionViewDataSource,UICollectionViewDelegate>{
    UICollectionView *GenreCollection;
    NSMutableArray *classArray;
    NSMutableDictionary *Fdictionary;
    BOOL ischange;
}

@end

@implementation ClassifySelectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNagationBar:@"选择风格" leftBtn:Constant_backImage rightBtn:3];
    UICollectionViewFlowLayout  *flowLayout=[[ UICollectionViewFlowLayout alloc ] init ];
    Fdictionary = [NSMutableDictionary dictionary];
    [flowLayout setScrollDirection : UICollectionViewScrollDirectionVertical];
    
    GenreCollection = [[ UICollectionView alloc ] initWithFrame : CGRectMake (0,0,SCREEN_WIDTH,SCREEN_HEIGHT-64) collectionViewLayout :flowLayout];
    [GenreCollection registerClass:[topicCell class] forCellWithReuseIdentifier:@"topicCell"];
    [GenreCollection setBackgroundColor:[UIColor whiteColor]];
    //[hotTopicCollectionView setHeaderHidden:NO];
    GenreCollection.delegate = self;
    GenreCollection.dataSource = self;
    [self.view addSubview:GenreCollection];
    ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Classify]]];
    [requestForm addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:NO];
    __weak ASIHTTPRequest *weakrequest = requestForm;
    [requestForm setCompletionBlock :^{
        NSLog(@"%@",[weakrequest responseString]);
        NSLog(@"%d",[weakrequest responseStatusCode]);
        if ([weakrequest responseStatusCode] == 200) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData]  options:NSJSONReadingMutableContainers error:nil];
            classArray = [dic objectForKey:@"genres"];
            for (NSDictionary *dic in _classifys) {
                for (int i = 0; i<classArray.count; i++) {
                    if ([[classArray[i] objectForKey:@"_id"] isEqualToString:[dic objectForKey:@"_id"]])    {
                        [Fdictionary setObject:classArray[i] forKey:[NSString stringWithFormat:@"%d",i]];
                    }
                }
            }
            [GenreCollection reloadData];
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
    // Do any additional setup after loading the view.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return classArray.count;
}

-( CGSize )collectionView:( UICollectionView *)collectionView layout:( UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:( NSIndexPath *)indexPath

{

    UILabel *tempLabel = [[UILabel alloc ] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [tempLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [tempLabel setText:[classArray[indexPath.row] objectForKey:@"data"]];
    [tempLabel sizeToFit];
    return CGSizeMake(tempLabel.frame.size.width+30, 30);

    
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    BOOL isSelected = NO;
    for (NSString *string in [Fdictionary allKeys]) {
        if ([string isEqualToString:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
            isSelected = YES;
            break;
        }
    }
    if (isSelected) {
        [Fdictionary removeObjectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
    }else{
        [Fdictionary setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
        
    }
    if (!ischange) {
        ischange = !ischange;
        [self initNagationBar:@"选择风格" leftBtn:Constant_backImage rightBtn:Constant_markImage];
    }
    [GenreCollection reloadData];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    topicCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"topicCell" forIndexPath:indexPath];
    UILabel *tempLabel = [[UILabel alloc ] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [tempLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [tempLabel setText:[classArray[indexPath.row] objectForKey:@"data"]];
    [tempLabel sizeToFit];
    [cell.topicLabel setFrame:CGRectMake(0, 0, tempLabel.frame.size.width+30, 30)];
    cell.topicLabel.text = [classArray[indexPath.row] objectForKey:@"data"];
    cell.topicLabel.textAlignment = NSTextAlignmentCenter;
    [cell.topicLabel setBackgroundColor:Color_line_2];
    cell.topicLabel.layer.cornerRadius = 10;
    cell.topicLabel.clipsToBounds = YES;
    BOOL isSelected = NO;
    for (NSString *string in [Fdictionary allKeys]) {
        if ([string isEqualToString:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
            isSelected = YES;
            break;
        }
    }
    if (isSelected) {
        cell.topicLabel.textColor = Color_Active_Button_1;
    }else{
         [cell.topicLabel setTextColor:[UIColor blackColor]];
    }
   
    return cell;
}

#pragma mark <UICollectionViewDelegate>

-( UIEdgeInsets )collectionView:( UICollectionView *)collectionView layout:( UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:( NSInteger )section

{
    
    UIEdgeInsets top = UIEdgeInsetsMake(10, 10, 10, 10);
    
    return top;
    
}
-(void)rightBtnAction:(UIButton *)sender{
    if (ischange) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSString *key in [Fdictionary allKeys]) {
            [array addObject:classArray[[key integerValue]]];
        }
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString : [NSString stringWithFormat:@"%@%@",BaseURL,URL_Update_Profile]]];
        NSMutableDictionary *dic= [NSMutableDictionary dictionaryWithObjectsAndKeys:array,@"genres", nil];
        [requestForm addBodyDataSourceWithJsonByDic:dic Method:PostMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            if ([weakrequest responseStatusCode] == 200 && [[dic objectForKey:@"result"] boolValue]) {
                [self.navigationController popViewControllerAnimated:YES];
                //
            }
        }];
        [requestForm setFailedBlock:^{
            // [SVProgressHUD showErrorWithStatus:@"network error"];
        }];
        [requestForm startAsynchronous];
    }
    
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
