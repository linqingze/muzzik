//
//  TopicHotVC.m
//  muzzik
//
//  Created by muzzik on 15/4/27.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "TopicHotVC.h"
#import "UIScrollView+DXRefresh.h"
#import "TopicModel.h"
@interface TopicHotVC()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>{
    UITableView *topicTableView;
    NSMutableArray *TopicArray;
    NSMutableArray *searchArray;
    BOOL isSearch;
    UIView *searchView;
    UISearchBar *searchBar;
    UIButton *cancelButton;
    NSInteger page;
    BOOL isNew;
}
@end

@implementation TopicHotVC


-(void)viewDidLoad{
    [super viewDidLoad];
    page = 1;
    [self initNagationBar:@"选择话题" leftBtn:Constant_backImage rightBtn:Constant_searchImage];
    topicTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-44)];
    [self.view addSubview:topicTableView];
    topicTableView.delegate = self;
    topicTableView.dataSource = self;
    ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Get_Topic]]];
    __weak ASIHTTPRequest *weakrequest = requestForm;
    [requestForm setCompletionBlock :^{
        NSLog(@"%@",[weakrequest responseString]);
        NSLog(@"%d",[weakrequest responseStatusCode]);
        if ([weakrequest responseStatusCode] == 200) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
            TopicArray = [[TopicModel new] makeTopicssByMuzzikArray:[dic objectForKey:@"topics"]];
            [topicTableView reloadData];
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
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [topicTableView addFooterWithTarget:self action:@selector(refreshFooter)];
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(50, 6, 0, 20)];
    //[searchBar.subviews[0] removeFromSuperview];
    [searchBar setBackgroundImage:[MuzzikItem createImageWithColor:Color_NavigationBar]];
    searchBar.placeholder = @"搜索";
    [searchBar setTintColor:Color_Orange];
    searchBar.delegate = self;
    UITextField *searchField;
    UIView *view = searchBar.subviews[0];
    
    for(int i = 0; i < [view.subviews count]; i++) {
        NSLog(@"%@",[[view.subviews objectAtIndex:i] class]);
        if([[view.subviews objectAtIndex:i] isKindOfClass:[UITextField class]]) {
            searchField = [view.subviews objectAtIndex:i];
        }
    }
    if(!(searchField == nil)) {
        searchField.textColor = [UIColor whiteColor];
        [searchField setFrame:CGRectMake(30, 5, searchBar.frame.size.width-30, searchBar.frame.size.height - 10)];
        [searchField setBackgroundColor:Color_search_background];//在这添加灰色的图片
        [searchField setBorderStyle:UITextBorderStyleNone];
        searchField.layer.cornerRadius = 5;
        searchField.clipsToBounds = YES;
    }
    searchBar.returnKeyType = UIReturnKeySearch;
    searchView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-150, 20, 0, 40)];
    [searchView setFrame:CGRectMake(0, 20, SCREEN_WIDTH, 40)];
    cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-52, 6, 40, 28)];
    [cancelButton setBackgroundImage:[MuzzikItem createImageWithColor:Color_search_background] forState:UIControlStateNormal];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [cancelButton setTitleColor:Color_Orange forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(searchBarBack) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.layer.cornerRadius = 5;
    cancelButton.clipsToBounds = YES;
    [searchView addSubview:cancelButton];
    
    [searchView setBackgroundColor:Color_NavigationBar];
    [searchView addSubview:searchBar];
}
- (void)refreshFooter
{
    // [self updateSomeThing];
    page++;
    ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Get_Topic]]];
    NSDictionary  *paraDic;
    if ([searchBar.text length]>0) {
        paraDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",page],Parameter_page,[searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"q", nil];
        
    }else{
         paraDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",page],Parameter_page, nil];
    }
    [requestForm addBodyDataSourceWithJsonByDic:paraDic Method:GetMethod auth:NO];
    __weak ASIHTTPRequest *weakrequest = requestForm;
    [requestForm setCompletionBlock :^{
        NSLog(@"%@",[weakrequest responseString]);
        NSLog(@"%d",[weakrequest responseStatusCode]);
        
        if ([weakrequest responseStatusCode] == 200) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
            if (isSearch) {
                
                [searchArray addObjectsFromArray:[[TopicModel new] makeTopicssByMuzzikArray:[dic objectForKey:@"topics"]]];
                
            }else{
                [TopicArray addObjectsFromArray:[[TopicModel new] makeTopicssByMuzzikArray:[dic objectForKey:@"topics"]]];
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [topicTableView reloadData];
                [topicTableView footerEndRefreshing];
            });
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
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [searchView removeFromSuperview];
    [topicTableView removeFooter];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    return isSearch ?[searchArray count]:[TopicArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * cellName = @"UITableViewCell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    if (!isNew) {
        UIFont *font = [UIFont boldSystemFontOfSize:14];
        TopicModel *topic = isSearch? searchArray[indexPath.row] : TopicArray[indexPath.row];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
        NSString *itemStr = @"#";
        NSAttributedString *item = [MuzzikItem formatAttrItem:itemStr color:Color_Additional_4 font:font];
        [text appendAttributedString:item];
        NSAttributedString *item1 = [MuzzikItem formatAttrItem:topic.name color:Color_Text_2 font:font];
        [text appendAttributedString:item1];
        NSString *itemStr1 = @"#";
        NSAttributedString *item2 = [MuzzikItem formatAttrItem:itemStr1 color:Color_Additional_4 font:font];
        [text appendAttributedString:item2];
        cell.textLabel.attributedText = text;
    }else{
        cell.textLabel.textColor = Color_Active_Button_2;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        cell.textLabel.text = searchArray[0];
    }
    
    //self.dataSource[indexPath.section][@"data"][indexPath.row];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TopicModel *tempTopic = [TopicModel new];
    MuzzikObject *mobject = [MuzzikObject shareClass];
    if (!isNew) {
        if (isSearch) {
            tempTopic = [searchArray objectAtIndex:indexPath.row];
        }
        else{
            tempTopic = [TopicArray objectAtIndex:indexPath.row];
        }
        
        mobject.tempmessage = [NSString stringWithFormat:@"#%@#",tempTopic.name];
    }else{
        mobject.tempmessage = [NSString stringWithFormat:@"#%@#",searchBar.text];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)rightBtnAction:(UIButton *)sender{
    searchBar.placeholder = @"搜索";
    [self.navigationController.view addSubview:searchView];
    [UIView animateWithDuration:0.3 animations:^{
        //        [searchView setFrame:CGRectMake(0, 20, SCREEN_WIDTH, 40)];
        [searchBar becomeFirstResponder];
        [searchBar setFrame:CGRectMake(6, 6, SCREEN_WIDTH-64, 28)];
    } completion:^(BOOL finished) {
        
    }];
    
}

-(void) searchBarBack{
    isSearch = NO;
    searchBar.text = @"";
    searchBar.placeholder = @"";
    ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Get_Topic]]];
    __weak ASIHTTPRequest *weakrequest = requestForm;
    [requestForm setCompletionBlock :^{
        NSLog(@"%@",[weakrequest responseString]);
        NSLog(@"%d",[weakrequest responseStatusCode]);
        if ([weakrequest responseStatusCode] == 200) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
            TopicArray = [[TopicModel new] makeTopicssByMuzzikArray:[dic objectForKey:@"topics"]];
            [topicTableView reloadData];
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
    [UIView animateWithDuration:0.3 animations:^{
        [searchBar resignFirstResponder];
        [searchBar setFrame:CGRectMake(SCREEN_WIDTH-52, 6, 40, 28)];
    } completion:^(BOOL finished) {
        [searchView removeFromSuperview];
    }];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{

    [searchArray removeAllObjects];
    if ([searchText length]>0) {
        isSearch = YES;
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Music_Search]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:[searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"q"] Method:GetMethod auth:NO];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            
            if ([weakrequest responseStatusCode] == 200) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
                searchArray = [[TopicModel new] makeTopicssByMuzzikArray:[dic objectForKey:@"music"]];
                if ([searchArray count] == 0) {
                    isNew = YES;
                    searchArray = [NSMutableArray arrayWithArray:@[[NSString stringWithFormat:@"添加新话题：#%@#",searchText]]];
                }else{
                    isNew = NO;
                }
                [topicTableView reloadData];
                
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
        isSearch = NO;
        [topicTableView reloadData];
    }

}
-(void)searchBarSearchButtonClicked:(UISearchBar *)loclsearchBar{
    NSLog(@"search%@",loclsearchBar.text);
    [searchBar resignFirstResponder];

}



@end
