//
//  SearchForTopic.m
//  muzzik
//
//  Created by muzzik on 15/5/4.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "SearchForTopic.h"
#import "SearchtopicCell.h"
#import "MuzzikObject.h"
#import "MessageStepViewController.h"
#import "TopicDetail.h"
@interface SearchForTopic (){
    NSInteger indexOfMuzzik;
    BOOL isSearch;
    NSString *pageID;
    NSInteger _index;
    NSString *_searchText;
    NSInteger page;
    UIView *searchView;
    UILabel *searchLabel;
    UILabel *resultLabel;
    BOOL isNew;
    UITableView *myTableView;
}
@property(nonatomic,retain)NSMutableArray *searchArray;

@end

@implementation SearchForTopic
- (void)viewDidLoad {
    page = 1;
    [super viewDidLoad];
    myTableView  = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    [self.view addSubview:myTableView];
    myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    searchLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, SCREEN_WIDTH-60, 20)];
    [searchLabel setFont:[UIFont systemFontOfSize:14]];
    [searchLabel setTextColor:Color_Active_Button_1];
    [searchView addSubview:searchLabel];
    [searchView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchTopic)]];
    [MuzzikItem addLineOnView:searchView heightPoint:50 toLeft:13 toRight:13 withColor:Color_line_1];
    [myTableView registerClass:[SearchtopicCell class] forCellReuseIdentifier:@"SearchtopicCell"];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.keeper.activityVC = self;
    [self.keeper followScrollView:myTableView];
    if ([self.keeper.searchBar.text length]>0 &&![_searchText isEqualToString:self.keeper.searchBar.text]&& [self.searchArray count] == 0) {
        searchLabel.text = [NSString stringWithFormat:@"搜索相关音乐:%@",self.keeper.searchBar.text];
        [self.view addSubview:searchView];
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchtopicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchtopicCell" forIndexPath:indexPath];
    NSDictionary *dic = self.searchArray[indexPath.row];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    UIFont *font = [UIFont boldSystemFontOfSize:14];
    cell.index = indexPath.row;
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
    NSString *itemStr = @"#";
    NSAttributedString *item = [MuzzikItem formatAttrItem:itemStr color:Color_Additional_4 font:font];
    [text appendAttributedString:item];
    NSAttributedString *item1 = [MuzzikItem formatAttrItem:[dic objectForKey:@"name"] color:Color_Text_2 font:font];
    [text appendAttributedString:item1];
    NSString *itemStr1 = @"#";
    NSAttributedString *item2 = [MuzzikItem formatAttrItem:itemStr1 color:Color_Additional_4 font:font];
    [text appendAttributedString:item2];
    cell.topicLabel.attributedText = text;
    cell.songVC = self;
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TopicDetail *topic = [[TopicDetail alloc] init];
    topic.topic_id = [self.searchArray[indexPath.row] objectForKey:@"_id"];
    [self.keeper.navigationController pushViewController:topic animated:YES];
}
-(void)updateDataSource:(NSString *)searchText{
    [resultLabel removeFromSuperview];
    isNew = NO;
    [self.searchArray removeAllObjects];
    [myTableView reloadData];
    if ([searchText length]>0) {
        searchLabel.text = [NSString stringWithFormat:@"搜索相关音乐:%@",self.keeper.searchBar.text];
        [self.view addSubview:searchView];
    }else {
        [searchView removeFromSuperview];
    }
}

-(void)searchDataSource:(NSString *)searchText{
    [self searchTopic];
}

-(void) poAction:(NSInteger)index{
    MuzzikObject *mobject = [MuzzikObject shareClass];
    mobject.tempmessage = [NSString stringWithFormat:@"#%@#",[self.searchArray[index] objectForKey:@"name"]];
    MessageStepViewController *messagebv = [[MessageStepViewController alloc] init];
    [self.keeper.navigationController pushViewController:messagebv animated:YES];
}
-(void)searchTopic{
    [searchView removeFromSuperview];
    if (!isNew) {
        _searchText = self.keeper.searchBar.text;
        [self.searchArray removeAllObjects];
        if ([self.keeper.searchBar.text length]>0) {
            ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Topic_search]]];
            [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:[self.keeper.searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"q"] Method:GetMethod auth:NO];
            __weak ASIHTTPRequest *weakrequest = requestForm;
            [requestForm setCompletionBlock :^{
                NSLog(@"%@",[weakrequest responseString]);
                NSLog(@"%d",[weakrequest responseStatusCode]);
                
                if ([weakrequest responseStatusCode] == 200) {
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
                    self.searchArray = [dic objectForKey:@"topics"];
                    if ([self.searchArray count] == 0) {
                        isNew = YES;
                        UIFont *font = [UIFont boldSystemFontOfSize:14];
                        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
                        NSString *itemStr = @"添加一个话题";
                        NSAttributedString *item = [MuzzikItem formatAttrItem:itemStr color:Color_Text_2 font:font];
                        [text appendAttributedString:item];
                        NSAttributedString *item1 = [MuzzikItem formatAttrItem:self.keeper.searchBar.text color:Color_Active_Button_2 font:font];
                        [text appendAttributedString:item1];
                        searchLabel.attributedText = text;
                        NSMutableAttributedString *textResult = [[NSMutableAttributedString alloc] init];
                        NSString *itemStrtResult = @"没有搜索到同";
                        NSAttributedString *itemtResult = [MuzzikItem formatAttrItem:itemStrtResult color:Color_Text_2 font:font];
                        [textResult appendAttributedString:itemtResult];
                        NSAttributedString *itemtResult1 = [MuzzikItem formatAttrItem:[NSString stringWithFormat:@"#%@#",self.keeper.searchBar.text] color:Color_Active_Button_2 font:font];
                        [textResult appendAttributedString:itemtResult1];
                        [textResult appendAttributedString:[MuzzikItem formatAttrItem:@"相关的话题" color:Color_Text_2 font:font]];
                        resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 70, SCREEN_WIDTH-50, 20)];
                        resultLabel.attributedText = textResult;
                        [self.view addSubview:searchView];
                        [self.view addSubview:resultLabel];
                        
                    }
                    [myTableView reloadData];
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
    }else{
        [resultLabel removeFromSuperview];
        NSLog(@"new topic");
        MuzzikObject *mobject = [MuzzikObject shareClass];
        mobject.tempmessage = [NSString stringWithFormat:@"#%@#",self.keeper.searchBar.text];
        [self.keeper.searchView setHidden:YES];
        MessageStepViewController *messagebv = [[MessageStepViewController alloc] init];
        [self.keeper.navigationController pushViewController:messagebv animated:YES];
    }
    
}
@end
