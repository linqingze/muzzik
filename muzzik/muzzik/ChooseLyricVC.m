//
//  ChooseLyricVC.m
//  muzzik
//
//  Created by muzzik on 15/4/28.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "ChooseLyricVC.h"
#import "TableViewCell.h"
#import "IQLabelView.h"
#import "TWPhotoPickerController.h"
#import "AppDelegate.h"
#import "ASIFormDataRequest.h"
@interface ChooseLyricVC()<UITableViewDataSource,UITableViewDelegate,IQLabelViewDelegate>{
    UITableView *lyricTablenview;
    NSMutableArray *lyricArray;
    UIImageView *headImage;
    IQLabelView *currentlyEditingLabel;
    UIView *tapview;
    BOOL isCharacterWhite;
    BOOL isShow;
    UIButton *ColorButton;
    UIButton *ImageButton;
    UIButton *LibraryButton;
    UIPageControl *PageControl;
    UIScrollView *Scroll;
    UIButton *nextButton;
    UIImageView *shareCycle;
    UIView *sharaView;
    NSInteger step;
    BOOL isShareToWeiChat;
    UIView *resultView;
    UIImage *Muzzikimage;
}
@end
@implementation ChooseLyricVC

-(void)viewDidLoad{
    [super viewDidLoad];
    isShareToWeiChat = YES;
    lyricArray = [NSMutableArray array];
    [self initNagationBar:@"填选一句话（3/3）" leftBtn:Constant_backImage rightBtn:0];
    MuzzikObject *mobject = [MuzzikObject shareClass];
    if ([mobject.lyricArray count]>0) {
        for (NSDictionary *dic in mobject.lyricArray) {
            if ([[[dic allValues][0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] >0 ) {
                [lyricArray addObject:dic];
            }
        }
    }
//    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchOutside:)]];
    headImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
    headImage.contentMode = UIViewContentModeScaleAspectFit;
    headImage.image = self.image;
    [self.view addSubview:headImage];
    Scroll = [[UIScrollView alloc] initWithFrame:headImage.frame];
    [Scroll setContentSize:CGSizeMake(SCREEN_WIDTH*3, SCREEN_WIDTH)];
    [self.view addSubview:Scroll];
    //tapview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
    //[Scroll addSubview:tapview];
    //[tapview addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchOutside:)]];
    Scroll.delegate = self;
    Scroll.pagingEnabled = YES;
    [Scroll setShowsHorizontalScrollIndicator:NO];
    lyricTablenview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
    lyricTablenview.delegate = self;
    lyricTablenview.dataSource = self;
    [Scroll addSubview:lyricTablenview];
    [lyricTablenview setBackgroundColor:[UIColor clearColor]];
    lyricTablenview.backgroundView  = nil;
    [lyricTablenview registerClass:[TableViewCell class] forCellReuseIdentifier:@"TableViewCell"];
    lyricTablenview.separatorStyle = UITableViewCellSeparatorStyleNone;
    PageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-20, SCREEN_WIDTH, 40, 30)];
    PageControl.numberOfPages = 3;
    [PageControl setCurrentPageIndicatorTintColor:Color_Active_Button_1];
    [PageControl setPageIndicatorTintColor:Color_line_1];
    [self.view addSubview:PageControl];
    
    ImageButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-73, SCREEN_WIDTH, 30, 30)];
    [ImageButton setImage:[UIImage imageNamed:Image_SwitchingImage] forState:UIControlStateNormal];
    [self.view addSubview:ImageButton];
    [ImageButton addTarget:self action:@selector(swithImage) forControlEvents:UIControlEventTouchUpInside];
    
    ColorButton = [[UIButton alloc] initWithFrame:CGRectMake(13, SCREEN_WIDTH, 40, 30)];
    if (self.image) {
        isShow = YES;
        [ImageButton setHidden:NO];
        isCharacterWhite = YES;
        [ColorButton setImage:[UIImage imageNamed:Image_textwhiteImage] forState:UIControlStateNormal];
    }else{
        isCharacterWhite = NO;
        [ColorButton setImage:[UIImage imageNamed:Image_textblackImage] forState:UIControlStateNormal];
        [ImageButton setHidden:YES];
    }
    [ColorButton addTarget:self action:@selector(changColor) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:ColorButton];
    
    
    
    LibraryButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-43, SCREEN_WIDTH, 30, 30)];
    [LibraryButton setImage:[UIImage imageNamed:Image_addedpicImage] forState:UIControlStateNormal];
    [self.view addSubview:LibraryButton];
    
    [LibraryButton addTarget:self action:@selector(changeImage) forControlEvents:UIControlEventTouchUpInside];
    [MuzzikItem addLineOnView:self.view heightPoint:SCREEN_WIDTH+30 toLeft:13 toRight:13 withColor:Color_line_1];
    
    nextButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-67, SCREEN_HEIGHT-113, 54, 52)];
    [nextButton setImage:[UIImage imageNamed:Image_Next] forState:UIControlStateNormal];
    [self.view addSubview: nextButton];
    [nextButton addTarget:self action:@selector(summitAction) forControlEvents:UIControlEventTouchUpInside];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    headImage.image = self.image;
    if (self.image) {
        isShow = YES;
        [ImageButton setHidden:NO];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    return lyricArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCell" forIndexPath:indexPath];
    cell.label.text = [lyricArray[indexPath.row] allObjects][0];
    if (isCharacterWhite) {
        cell.label.textColor = [UIColor whiteColor];
    }else{
        cell.label.textColor = [UIColor blackColor];
    }
    NSLog(@"%@",[lyricArray[indexPath.row] allObjects][0]);
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TableViewCell *cell = (TableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    UITextField *aLabel = [[UITextField alloc] initWithFrame:cell.bounds];
    [aLabel setClipsToBounds:YES];
    [aLabel setAutoresizingMask:(UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin)];
    aLabel.textAlignment = NSTextAlignmentCenter;
    aLabel.text =cell.label.text;
    aLabel.font = [UIFont boldSystemFontOfSize:15];
    if (isCharacterWhite) {
        aLabel.textColor = [UIColor whiteColor];
    }else{
        aLabel.textColor = [UIColor blackColor];
    }
    
    [aLabel setEnabled:NO];
   // [aLabel sizeToFit];
    CGPoint point = [cell.superview convertPoint:cell.frame.origin toView:Scroll];
    IQLabelView *labelView = [[IQLabelView alloc] initWithFrame:CGRectMake(point.x, point.y, cell.frame.size.width, cell.frame.size.height)];
    [labelView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth)];
    labelView.delegate = self;
    [labelView setShowContentShadow:NO];
    [labelView setTextView:aLabel];
    [labelView sizeToFit];
    [Scroll addSubview:labelView];
    
    currentlyEditingLabel = labelView;
    [lyricTablenview removeFromSuperview];
    
}


#pragma mark - Gesture

- (void)touchOutside:(UITapGestureRecognizer *)touchGesture
{
    [currentlyEditingLabel hideEditingHandles];
}

#pragma mark - IQLabelDelegate

- (void)labelViewDidClose:(IQLabelView *)label
{
    // some actions after delete label
    [self.view addSubview:lyricTablenview];
}

- (void)labelViewDidBeginEditing:(IQLabelView *)label
{
    // move or rotate begin
}

- (void)labelViewDidShowEditingHandles:(IQLabelView *)label
{
    // showing border and control buttons
    currentlyEditingLabel = label;
}

- (void)labelViewDidHideEditingHandles:(IQLabelView *)label
{
    // hiding border and control buttons
    currentlyEditingLabel = nil;
}

- (void)labelViewDidStartEditing:(IQLabelView *)label
{
    // tap in text field and keyboard showing
    currentlyEditingLabel = label;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sView
{
    NSInteger index = fabs(sView.contentOffset.x) / sView.frame.size.width;
    //NSLog(@"%d",index);
    [PageControl setCurrentPage:index];
}


#pragma -mark action
-(void) changColor{
    
    if (!isCharacterWhite) {
        isCharacterWhite = YES;
        [ColorButton setImage:[UIImage imageNamed:Image_textwhiteImage] forState:UIControlStateNormal];
        [currentlyEditingLabel.textView setTextColor:[UIColor whiteColor]];
    }else{
        isCharacterWhite = NO;
        [ColorButton setImage:[UIImage imageNamed:Image_textblackImage] forState:UIControlStateNormal];
        [currentlyEditingLabel.textView setTextColor:[UIColor blackColor]];
    }
    [lyricTablenview reloadData];
}

-(void) swithImage{
    if (isShow) {
        isShow = NO;
        headImage.image = nil;
    }else{
        isShow = YES;
        headImage.image = self.image;
    }
}

-(void) changeImage{
    TWPhotoPickerController *photoPicker = [[TWPhotoPickerController alloc] init];
    photoPicker.cropBlock = ^(UIImage *image) {
        self.image = image;
        [headImage setImage:image];
    };
    [self presentViewController:photoPicker animated:YES completion:NULL];
}

-(void) summitAction{
    if (step == 0) {
        step = 1;
        [headImage addSubview:currentlyEditingLabel];
        Muzzikimage = [MuzzikItem convertViewToImage:headImage];
        UIImageView *temp = [[UIImageView alloc] initWithImage:Muzzikimage];
        NSLog(@"%@",temp);
        tapview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, SCREEN_WIDTH)];
        [self.view addSubview:tapview];
        [tapview setBackgroundColor:[UIColor whiteColor]];
        [tapview addSubview:temp];
        resultView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 150, 100, 300 , 211)];
        [tapview addSubview:resultView];
        [self.view addSubview:sharaView];
        UIImageView *cover = [[UIImageView alloc] initWithImage:[UIImage imageNamed:Image_Cover]];
        [cover setFrame:CGRectMake(0, 0, 300, 211)];
        [resultView addSubview:cover];
        [tapview addSubview:temp];
        temp.layer.cornerRadius = 2;
        temp.clipsToBounds = YES;
        UIImageView *coverPage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:Image_Textcover]];
        //[coverPage setFrame:CGRectMake(SCREEN_WIDTH/2 - 141, 100, 189, 189)];
        [UIView animateWithDuration:0.5 animations:^{
            [temp setFrame:CGRectMake(SCREEN_WIDTH/2 - 139, 111, 189, 189)];
            [sharaView setFrame:CGRectMake(0, SCREEN_WIDTH, SCREEN_WIDTH, 30)];
        } completion:^(BOOL finished) {
            [temp setFrame:CGRectMake(11, 11, 189, 189)];
            [resultView addSubview:temp];
            //[tapview addSubview:coverPage];
        }];
        sharaView = [[UIView alloc] initWithFrame:CGRectMake(-SCREEN_WIDTH, SCREEN_WIDTH, SCREEN_WIDTH, 30)];
        [sharaView setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:sharaView];
        [sharaView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changShare)]];
        UILabel *notify = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, SCREEN_WIDTH-150, 30)];
        [notify setFont:[UIFont systemFontOfSize:12]];
        [notify setText:@"发送并同步到朋友圈"];
        [sharaView addSubview:notify];
        shareCycle = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-40, 0, 30, 30)];
        [shareCycle setImage:[UIImage imageNamed:Image_textblackImage]];
        [sharaView addSubview:shareCycle];
        [nextButton setImage:[UIImage imageNamed:Image_done] forState:UIControlStateNormal];
        
        
    }else{
        if (self.image && isShow) {
            ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString : [NSString stringWithFormat:@"%@%@",BaseURL,URL_Upload_Image]]];
            
            [requestForm addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
            __weak ASIHTTPRequest *weakrequest = requestForm;
            [requestForm setCompletionBlock :^{
                NSLog(@"%@    %@",[weakrequest originalURL],[weakrequest requestHeaders]);
                NSLog(@"%@",[weakrequest responseHeaders]);
                NSLog(@"%@",[weakrequest responseString]);
                NSLog(@"%d",[weakrequest responseStatusCode]);
                if ([weakrequest responseStatusCode] == 200) {
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
                    
                    ASIFormDataRequest *interRequest = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:[dic objectForKey:@"url"]]];
                    [ASIFormDataRequest clearSession];
                    [interRequest setPostFormat:ASIMultipartFormDataPostFormat];
                    [interRequest addRequestHeader:@"Host" value:@"upload.qiniu.com"];
                    [interRequest setPostValue:[[dic objectForKey:@"data"] objectForKey:@"token"] forKey:@"token"];
                    NSData *imageData = UIImageJPEGRepresentation(Muzzikimage, 0.75);
                    [interRequest addData:imageData forKey:@"file"];
                    __weak ASIFormDataRequest *form = interRequest;
                    [interRequest buildRequestHeaders];
                    NSLog(@"header:%@",interRequest.requestHeaders);
                    [interRequest setCompletionBlock:^{
                        NSDictionary *keydic = [NSJSONSerialization JSONObjectWithData:[form responseData] options:NSJSONReadingMutableContainers error:nil];
                        MuzzikObject *mobject = [MuzzikObject shareClass];
                        mobject.imageKey = [keydic objectForKey:@"key"];
                        ASIHTTPRequest *shareRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL,URL_Muzzik_new]]];
                        NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
                        if (mobject.isPrivate) {
                            [requestDic setObject:[NSNumber numberWithBool:YES] forKey:Parameter_private];
                        }
                        if ([mobject.imageKey length]>0) {
                            [requestDic setObject:mobject.imageKey forKey:Parameter_image_key];
                        }
                        if ([mobject.message length]>0) {
                            [requestDic setObject:mobject.message forKey:Parameter_message];
                        }
                        NSDictionary *musicDic = [NSDictionary dictionaryWithObjectsAndKeys:mobject.music.key,@"key",mobject.music.name,@"name",mobject.music.artist,@"artist", nil];
                        [requestDic setObject:musicDic forKey:@"music"];
                        [shareRequest addBodyDataSourceWithJsonByDic:requestDic Method:PutMethod auth:YES];
                        __weak ASIHTTPRequest *weakShare = shareRequest;
                        [shareRequest setCompletionBlock:^{
                            NSLog(@"data:%@",[weakShare responseString]);
                            if ([weakShare responseStatusCode] == 200) {
                                [self dismissViewControllerAnimated:YES completion:^{
                                    mobject.imageKey = nil;
                                    mobject.music = nil;
                                    mobject.message = nil;
                                    mobject.lyricArray = nil;
                                }];
                            }
                        }];
                        [shareRequest setFailedBlock:^{
                            NSLog(@"%@",[weakShare error]);
                        }];
                        [shareRequest startAsynchronous];
                        
                        
                    }];
                    [interRequest setFailedBlock:^{
                        NSLog(@"%@",[form responseString]);
                    }];
                    [interRequest startAsynchronous];
                    
                }
                else if([weakrequest responseStatusCode] == 400){
                }
                else if([weakrequest responseStatusCode] == 409){
                    
                }
            }];
            [requestForm setFailedBlock:^{
                NSLog(@"%@",[weakrequest error ]);
            }];
            [requestForm startAsynchronous];
        }
        else{
            MuzzikObject *mobject = [MuzzikObject shareClass];
            ASIHTTPRequest *shareRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL,URL_Muzzik_new]]];
            NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
            if (mobject.isPrivate) {
                [requestDic setObject:[NSNumber numberWithBool:YES] forKey:Parameter_private];
            }
            if ([mobject.imageKey length]>0) {
                [requestDic setObject:mobject.imageKey forKey:Parameter_image_key];
            }
            if ([mobject.message length]>0) {
                [requestDic setObject:mobject.message forKey:Parameter_message];
            }
            NSDictionary *musicDic = [NSDictionary dictionaryWithObjectsAndKeys:mobject.music.key,@"key",mobject.music.name,@"name",mobject.music.artist,@"artist", nil];
            [requestDic setObject:musicDic forKey:@"music"];
            [shareRequest addBodyDataSourceWithJsonByDic:requestDic Method:PutMethod auth:YES];
            __weak ASIHTTPRequest *weakShare = shareRequest;
            [shareRequest setCompletionBlock:^{
                NSLog(@"data:%@",[weakShare responseString]);
                if ([weakShare responseStatusCode] == 200) {
                    [self dismissViewControllerAnimated:YES completion:^{
                        mobject.imageKey = nil;
                        mobject.music = nil;
                        mobject.message = nil;
                        mobject.lyricArray = nil;
                    }];
                }
            }];
            [shareRequest setFailedBlock:^{
                NSLog(@"%@",[weakShare error]);
            }];
            [shareRequest startAsynchronous];
        }
        
        if (isShareToWeiChat) {
            
            
            AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [app sendImageContent:[MuzzikItem convertViewToImage:resultView]];
        }
    }
}

@end
