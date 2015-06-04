//
//  ChooseLyricVC.m
//  muzzik
//
//  Created by muzzik on 15/4/28.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "ChooseLyricVC.h"
#import "TableViewCell.h"
#import "RJTextView.h"
#import "TWPhotoPickerController.h"
#import "AppDelegate.h"
#import "ASIFormDataRequest.h"
#import "FontTableCell.h"
@interface ChooseLyricVC()<UITableViewDataSource,UITableViewDelegate,RJTextViewDelegate>{
    NSMutableArray *fontArray;
    NSMutableArray *lyricArray;
    NSArray *famousArray;
    UIImageView *headImage;
    
    BOOL isCharacterWhite;
    BOOL isShow;
    UIButton *fontButton;
    UIButton *ColorButton;
    UIButton *ImageButton;
    UIButton *LibraryButton;
    UIPageControl *PageControl;
    UIScrollView *Scroll;
    UIButton *nextButton;
    UIImageView *shareCycle;
    UIView *controlView;
    UIView *sharaView;
    NSInteger step;
    BOOL isShareToWeiChat;
    UIView *resultView;
    UIImage *Muzzikimage;
    RJTextView *shareLabel;
    UIColor *shareColor;
    
    UIView *lyricView;
    RJTextView *lyricTextView;
    UITableView *lyricTablenview;
    UIView *editView;
    RJTextView *editTextView;
    
    UIView *famousView;
    RJTextView *famousTextView;
    UITableView *famousTableview;
    
    UITableView *fontTableView;
    BOOL fontTableShowed;
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
    famousArray = @[@"此歌代表我的心",@"空气中的旋律，也是我对你的思念",@"爱在左，情在右，我在中间来回跑，只因有你",@"呼啦啦",@"Muzzik",@"I Need You",@"My name is "];
    //    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchOutside:)]];
    headImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
    headImage.contentMode = UIViewContentModeScaleAspectFit;
    headImage.image = self.image;
    if (self.image) {
        shareColor = [UIColor whiteColor];
    }else{
        shareColor = [UIColor blackColor];
    }
    [self.view addSubview:headImage];
    Scroll = [[UIScrollView alloc] initWithFrame:headImage.frame];
    [Scroll setContentSize:CGSizeMake(SCREEN_WIDTH*3, SCREEN_WIDTH)];
    [self.view addSubview:Scroll];
    lyricView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
    [Scroll addSubview:lyricView];
     [lyricView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideControl)]];
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
    
    
    famousView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
    [Scroll addSubview:famousView];
    [famousView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideControl)]];
    famousTableview = [[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
    famousTableview.delegate = self;
    famousTableview.dataSource = self;
    [Scroll addSubview:famousTableview];
    [famousTableview setBackgroundColor:[UIColor clearColor]];
    famousTableview.backgroundView  = nil;
    [famousTableview registerClass:[TableViewCell class] forCellReuseIdentifier:@"TableViewCell"];
    famousTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    
    editView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*2, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
    [Scroll addSubview:editView];
    //[editView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideControl)]];
    editTextView = [[RJTextView alloc] initWithFrame:CGRectMake(70, 100, SCREEN_WIDTH-140, 50)
                                         defaultText:@""
                                                font:[UIFont systemFontOfSize:15.f]
                                               color:shareColor
                                             minSize:CGSizeMake(SCREEN_WIDTH, 50)];
    editTextView.delegate = self;
    [editTextView.closeButton removeFromSuperview];
    [editView addSubview:editTextView];
    
    
    
    controlView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_WIDTH, SCREEN_WIDTH, 30)];
    [self.view addSubview:controlView];
    
    
    PageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-20, 0, 40, 30)];
    PageControl.numberOfPages = 3;
    [PageControl setCurrentPageIndicatorTintColor:Color_Active_Button_1];
    [PageControl setPageIndicatorTintColor:Color_line_1];
    [controlView addSubview:PageControl];
    
    ImageButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-73, 0, 30, 30)];
    [ImageButton setImage:[UIImage imageNamed:Image_SwitchingImage] forState:UIControlStateNormal];
    [controlView addSubview:ImageButton];
    [ImageButton addTarget:self action:@selector(swithImage) forControlEvents:UIControlEventTouchUpInside];
    
    ColorButton = [[UIButton alloc] initWithFrame:CGRectMake(13, 0, 30, 30)];
    
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
    [controlView addSubview:ColorButton];
    
    fontButton = [[UIButton alloc] initWithFrame:CGRectMake(43, 0, 30, 30)];
    [fontButton setImage:[UIImage imageNamed:Image_fontImage] forState:UIControlStateNormal];
    [fontButton setImage:[UIImage imageNamed:Image_fontclickImage] forState:UIControlStateHighlighted];
    [fontButton addTarget:self action:@selector(changFont) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:fontButton];
    fontTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SCREEN_WIDTH+31 , SCREEN_WIDTH, SCREEN_HEIGHT-SCREEN_WIDTH-95)];
    fontTableView.delegate = self;
    fontTableView.dataSource = self;
    [Scroll addSubview:fontTableView];
    [fontTableView registerClass:[FontTableCell class] forCellReuseIdentifier:@"FontTableCell"];
    fontTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    LibraryButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-43, SCREEN_WIDTH, 30, 30)];
    [LibraryButton setImage:[UIImage imageNamed:Image_addedpicImage] forState:UIControlStateNormal];
    [self.view addSubview:LibraryButton];
    
    [LibraryButton addTarget:self action:@selector(changeImage) forControlEvents:UIControlEventTouchUpInside];
    [MuzzikItem addLineOnView:self.view heightPoint:SCREEN_WIDTH+30 toLeft:13 toRight:13 withColor:Color_line_1];
    [self loadFont];
//    nextButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-67, SCREEN_HEIGHT-113, 54, 52)];
//    [nextButton setImage:[UIImage imageNamed:Image_Next] forState:UIControlStateNormal];
//    [self.view addSubview: nextButton];
//    [nextButton addTarget:self action:@selector(summitAction) forControlEvents:UIControlEventTouchUpInside];
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    headImage.image = self.image;
    if (self.image) {
        isShow = YES;
        [ImageButton setHidden:NO];
    }
}

-(void) loadFont{
    fontArray = [NSMutableArray array];
    NSString *fontPath = [[NSBundle mainBundle] pathForResource:@"VNI_HLThuphap" ofType:@"ttf"];
    [fontArray addObject:[MuzzikItem customFontWithPath:fontPath]];
    
    NSString *fontPath1 = [[NSBundle mainBundle] pathForResource:@"Bluehigh" ofType:@"ttf"];
    [fontArray addObject:[MuzzikItem customFontWithPath:fontPath1]];
    
    NSString *fontPath2 = [[NSBundle mainBundle] pathForResource:@"calico_cyrillic" ofType:@"ttf"];
    [fontArray addObject:[MuzzikItem customFontWithPath:fontPath2]];
    
    NSString *fontPath3 = [[NSBundle mainBundle] pathForResource:@"kilsonburg" ofType:@"ttf"];
    [fontArray addObject:[MuzzikItem customFontWithPath:fontPath3]];

}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    if (tableView == lyricTablenview) {
        return lyricArray.count;
    }else if (tableView == famousTableview) {
        return famousArray.count;
    }else{
        return fontArray.count;
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == fontTableView) {
        FontTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FontTableCell" forIndexPath:indexPath];
        cell.label.text = fontArray[indexPath.row];
        cell.label.font = [UIFont fontWithName:fontArray[indexPath.row] size:15];
        return cell;
    }else{
        TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCell" forIndexPath:indexPath];
        if (tableView == lyricTablenview) {
            cell.label.text = [[lyricArray[indexPath.row] allObjects][0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];
        }else{
            cell.label.text = famousArray[indexPath.row];
        }
        if (isCharacterWhite) {
            cell.label.textColor = [UIColor whiteColor];
        }else{
            cell.label.textColor = [UIColor blackColor];
        }
        return cell;
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == fontTableView) {
        return 30;
    }else{
        UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, SCREEN_WIDTH-80, 50)];
        tempLabel.font = [UIFont boldSystemFontOfSize:15];
        tempLabel.numberOfLines = 0;
        if ([lyricArray count]>0) {
            tempLabel.text = [[lyricArray[indexPath.row] allObjects][0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];
        }
        
        CGSize msize = [tempLabel sizeThatFits:tempLabel.frame.size];
        return msize.height+20;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == fontTableView) {
        shareLabel.textView.font = [UIFont fontWithName:fontArray[indexPath.row] size:15.0];
        
    }else{
        TableViewCell *cell = (TableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        CGPoint point = [cell.superview convertPoint:cell.frame.origin toView:Scroll];
        RJTextView *textView = [[RJTextView alloc] initWithFrame:CGRectMake(cell.label.frame.origin.x-10, point.y, cell.label.frame.size.width+20, cell.label.frame.size.height+20)
                                                     defaultText:cell.label.text
                                                            font:[UIFont systemFontOfSize:15.f]
                                                           color:shareColor
                                                         minSize:CGSizeMake(SCREEN_WIDTH, 40)];
        
        [textView.textView setEditable:NO];
        textView.delegate = self;
        
        if (tableView == lyricTablenview) {
            [lyricView addSubview:textView];
            lyricTextView = textView;
            shareLabel = textView;
            [lyricTablenview removeFromSuperview];
        }else{
            [famousView addSubview:textView];
            famousTextView = textView;
            shareLabel = textView;
            [famousTableview removeFromSuperview];
        }
        [self checkNext];
    }
    
}


#pragma mark - Gesture

-(void)changFont{
    if (fontTableShowed) {
        fontTableShowed = NO;
        [fontButton setImage:[UIImage imageNamed:Image_fontImage] forState:UIControlStateNormal];
        [fontTableView removeFromSuperview];
        
    }else{
        fontTableShowed = YES;
        [fontButton setImage:[UIImage imageNamed:Image_fontclickImage] forState:UIControlStateNormal];
        [self.view addSubview:fontTableView];
    }
}

-(void) hideControl{
    if (shareLabel.hideView) {
        [shareLabel showTextViewBox];
    }else{
        [shareLabel hideTextViewBox];
    }
}
-(void)textViewDidEndEditing:(RJTextView *)textView{
    if ([textView.textView.text length]>0) {
        shareLabel = editTextView;
    }else{
        shareLabel = nil;
    }
    [self checkNext];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)sView
{
    [self.view endEditing:YES];
    NSInteger index = fabs(sView.contentOffset.x) / sView.frame.size.width;
    //NSLog(@"%d",index);
    [PageControl setCurrentPage:index];
    if (index == 0) {
        shareLabel = lyricTextView;
    }else if(index == 1){
        shareLabel = famousTextView;
    }else if(index == 2){
        [editTextView.textView becomeFirstResponder];
        if (editTextView.textView.text.length >0) {
            shareLabel = editTextView;
        }else{
            shareLabel = nil;
        }
        
    }
    [self checkNext];
}
-(void)checkNext{
    userInfo *user = [userInfo shareClass];
    if (shareLabel) {
        if(user.WeChatInstalled){
            [self initNagationBar:@"填选一句话（3/3）" leftBtn:Constant_backImage rightBtn:2];
        }else{
            [self initNagationBar:@"填选一句话（3/3）" leftBtn:Constant_backImage rightBtn:5];
        }
    }else{
        [self initNagationBar:@"填选一句话（3/3）" leftBtn:Constant_backImage rightBtn:0];
    }
}
-(void)rightBtnAction:(UIButton *)sender{
    if (shareLabel) {
        userInfo *user = [userInfo shareClass];
        MuzzikObject *mobject = [MuzzikObject shareClass];
        if (user.WeChatInstalled) {
            if (step == 0) {
                step = 1;
                [self initNagationBar:@"填选一句话（3/3）" leftBtn:Constant_backImage rightBtn:5];
                [shareLabel hideTextViewBox];
                [headImage addSubview:shareLabel];
                for (UIView *view in lyricView.subviews) {
                    [view removeFromSuperview];
                }
                Muzzikimage = [MuzzikItem convertViewToImage:headImage];
                UIImageView *temp = [[UIImageView alloc] initWithImage:Muzzikimage];
                NSLog(@"%@",temp);
                [self.view addSubview:lyricView];
                [lyricView setBackgroundColor:[UIColor whiteColor]];
                [lyricView addSubview:temp];
                resultView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 150, 100, 300 , 211)];
                [lyricView addSubview:resultView];
                [self.view addSubview:sharaView];
                UIImageView *cover = [[UIImageView alloc] initWithImage:[UIImage imageNamed:Image_Cover]];
                [cover setFrame:CGRectMake(0, 0, 300, 211)];
                [resultView addSubview:cover];
                [lyricView addSubview:temp];
                temp.layer.cornerRadius = 2;
                temp.clipsToBounds = YES;
                // UIImageView *coverPage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:Image_Textcover]];
                //[coverPage setFrame:CGRectMake(SCREEN_WIDTH/2 - 141, 100, 189, 189)];
                [UIView animateWithDuration:0.5 animations:^{
                    [temp setFrame:CGRectMake(SCREEN_WIDTH/2 - 139, 111, 189, 189)];
                    [sharaView setFrame:CGRectMake(0, SCREEN_WIDTH, SCREEN_WIDTH, 30)];
                } completion:^(BOOL finished) {
                    [temp setFrame:CGRectMake(11, 11, 189, 189)];
                    [resultView addSubview:temp];
                    //[lyricView addSubview:coverPage];
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
                [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    [sharaView setFrame:CGRectMake(0, SCREEN_WIDTH, SCREEN_WIDTH, 30)];
                    [controlView setFrame:CGRectMake(SCREEN_WIDTH, SCREEN_WIDTH, SCREEN_WIDTH, 30)];
                    
                } completion:^(BOOL finished) {
                    
                }];
                
                
            }else{
                
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
                        NSData *imageData = UIImageJPEGRepresentation(Muzzikimage, 1);
                        [interRequest addData:imageData forKey:@"file"];
                        __weak ASIFormDataRequest *form = interRequest;
                        [interRequest buildRequestHeaders];
                        NSLog(@"header:%@",interRequest.requestHeaders);
                        [interRequest setCompletionBlock:^{
                            NSDictionary *keydic = [NSJSONSerialization JSONObjectWithData:[form responseData] options:NSJSONReadingMutableContainers error:nil];
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
                            }else{
                                [requestDic setObject:@"I Love This Muzzik!" forKey:Parameter_message];
                            }
                            NSDictionary *musicDic = [NSDictionary dictionaryWithObjectsAndKeys:mobject.music.key,@"key",mobject.music.name,@"name",mobject.music.artist,@"artist", nil];
                            [requestDic setObject:musicDic forKey:@"music"];
                            [shareRequest addBodyDataSourceWithJsonByDic:requestDic Method:PutMethod auth:YES];
                            __weak ASIHTTPRequest *weakShare = shareRequest;
                            [shareRequest setCompletionBlock:^{
                                NSLog(@"data:%@",[weakShare responseString]);
                                NSDictionary *muzzikDic = [NSJSONSerialization JSONObjectWithData:[weakShare responseData] options:NSJSONReadingMutableContainers error:nil];
                                if ([weakShare responseStatusCode] == 200) {
                                    if (isShareToWeiChat) {
                                        UIView *weChatShareView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1316, 759)];
                                        UIImageView *CDcover = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 1064, 738)];
                                        [weChatShareView addSubview:CDcover];
                                        [CDcover setImage:[UIImage imageNamed:Image_cover_CD]];
                                        UIImageView *picImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 720, 720)];
                                        [picImage setImage:self.image];
                                        picImage.contentMode = UIViewContentModeScaleAspectFill;
                                        [weChatShareView addSubview:picImage];
                                        CGFloat scale = 720.0/SCREEN_WIDTH;
                                        [shareLabel setFrame:CGRectMake(shareLabel.frame.origin.x * scale, shareLabel.frame.origin.y * scale, shareLabel.frame.size.width * scale, shareLabel.frame.size.height *scale)];
                                        //                                    NSLog(@"%f",shareLabel.fontSize);
                                        //                                    shareLabel.textView.font = [UIFont boldSystemFontOfSize:shareLabel.fontSize*scale];
                                        [weChatShareView addSubview:shareLabel];
                                        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
                                        
                                        UIGraphicsBeginImageContextWithOptions(weChatShareView.bounds.size, NO, 1.0f);
                                        //    UIGraphicsBeginImageContext(v.bounds.size,YES,2.0f);
                                        
                                        [weChatShareView.layer renderInContext:UIGraphicsGetCurrentContext()];
                                        
                                        UIImage *timage = UIGraphicsGetImageFromCurrentImageContext();
                                        
                                        UIGraphicsEndImageContext();
                                        
                                        [app sendImageContent:timage];
                                        
                                    }
                                    [self setPoMuzzikMessage:muzzikDic];
                                    [mobject clearObject];
                                    [self.navigationController popToRootViewControllerAnimated:YES];
                                    
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
            
        }else{
            [headImage addSubview:shareLabel];
            Muzzikimage = [MuzzikItem convertViewToImage:headImage];
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
                    NSData *imageData = UIImageJPEGRepresentation(Muzzikimage, 1);
                    [interRequest addData:imageData forKey:@"file"];
                    __weak ASIFormDataRequest *form = interRequest;
                    [interRequest buildRequestHeaders];
                    NSLog(@"header:%@",interRequest.requestHeaders);
                    [interRequest setCompletionBlock:^{
                        NSDictionary *keydic = [NSJSONSerialization JSONObjectWithData:[form responseData] options:NSJSONReadingMutableContainers error:nil];
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
                        }else{
                            [requestDic setObject:@"I Love This Muzzik!" forKey:Parameter_message];
                        }
                        NSDictionary *musicDic = [NSDictionary dictionaryWithObjectsAndKeys:mobject.music.key,@"key",mobject.music.name,@"name",mobject.music.artist,@"artist", nil];
                        [requestDic setObject:musicDic forKey:@"music"];
                        [shareRequest addBodyDataSourceWithJsonByDic:requestDic Method:PutMethod auth:YES];
                        __weak ASIHTTPRequest *weakShare = shareRequest;
                        [shareRequest setCompletionBlock:^{
                            NSLog(@"data:%@",[weakShare responseString]);
                            if ([weakShare responseStatusCode] == 200) {
                                NSDictionary *muzzikDic = [NSJSONSerialization JSONObjectWithData:[weakShare responseData] options:NSJSONReadingMutableContainers error:nil];
                                
                                [self setPoMuzzikMessage:muzzikDic];
                                [mobject clearObject];
                                [self.navigationController popToRootViewControllerAnimated:YES];
                                
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
        

    }else{
        
    }
}
#pragma -mark action
-(void) changColor{
    
    if (!isCharacterWhite) {
        isCharacterWhite = YES;
        shareColor = [UIColor whiteColor];
        [ColorButton setImage:[UIImage imageNamed:Image_textwhiteImage] forState:UIControlStateNormal];
        shareLabel.textView.textColor = [UIColor whiteColor];
    }else{
        isCharacterWhite = NO;
        shareColor = [UIColor blackColor];
        [ColorButton setImage:[UIImage imageNamed:Image_textblackImage] forState:UIControlStateNormal];
        shareLabel.textView.textColor = [UIColor blackColor];
    }
    [lyricTablenview reloadData];
}
-(void)closeLabel:(RJTextView *)rjView{
    if (rjView == lyricTextView) {
        shareLabel = nil;
        [Scroll addSubview:lyricTablenview];
    }else{
        shareLabel = nil;
        [Scroll addSubview:famousTableview];
    }
    [self checkNext];
}

-(void) swithImage{
    if (isShow) {
        isShow = NO;
        headImage.image = nil;
        shareColor = [UIColor blackColor];
        [shareLabel.textView setTextColor:shareColor];
        [lyricTablenview reloadData];
    }else{
        isShow = YES;
        headImage.image = self.image;
        shareColor = [UIColor whiteColor];
        [shareLabel.textView setTextColor:shareColor];
        [lyricTablenview reloadData];
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
    }
-(void)setPoMuzzikMessage:(NSDictionary *)dic{
    userInfo *user = [userInfo shareClass];
    MuzzikObject *mobject = [MuzzikObject shareClass];
    muzzik *newmuzzik = [muzzik new];
    newmuzzik.muzzik_id = [dic objectForKey:@"_id"];
    newmuzzik.ismoved = NO;
    newmuzzik.date = [dic objectForKey:@"date"];
    newmuzzik.message = [dic objectForKey:@"message"];
    if ([mobject.imageKey length]>0 ) {
        newmuzzik.image = mobject.imageKey;
    }
    
    newmuzzik.topics = [dic objectForKey:@"topics"];
    newmuzzik.users = [dic objectForKey:@"users"];
    newmuzzik.type = [dic objectForKey:@"type"];
    newmuzzik.onlytext = [[dic objectForKey:@"onlytext"] boolValue];
    newmuzzik.isReposted = NO;
    newmuzzik.reposts = [dic objectForKey:@"reposts"];
    newmuzzik.shares = [dic objectForKey:@"shares"];
    newmuzzik.comments = [dic objectForKey:@"comments"];
    newmuzzik.color = [dic objectForKey:@"color"];
    newmuzzik.moveds = [dic objectForKey:@"moveds"];
    newmuzzik.isprivate = [[dic objectForKey:@"private"] boolValue];
    newmuzzik.plays = [dic objectForKey:@"plays"];
    newmuzzik.repostID = [dic objectForKey:@"repostID"];
    newmuzzik.title = [dic objectForKey:@"title"];
    newmuzzik.repostDate = [dic objectForKey:@"repostDate"];
    newmuzzik.reposter = [MuzzikUser new];
    newmuzzik.reposter.name = [[dic objectForKey:@"repostUser"] objectForKey:@"name"];
    newmuzzik.reposter.user_id = [[dic objectForKey:@"repostUser"] objectForKey:@"_id"];
    newmuzzik.reposter.avatar = [[dic objectForKey:@"repostUser"] objectForKey:@"avatar"];
    newmuzzik.reposter.gender = [[dic objectForKey:@"repostUser"] objectForKey:@"gender"];
    
    newmuzzik.MuzzikUser = [MuzzikUser new];
    newmuzzik.MuzzikUser.avatar = user.avatar;
    newmuzzik.MuzzikUser.user_id = user.uid;
    newmuzzik.MuzzikUser.gender = user.gender;
    newmuzzik.MuzzikUser.name = user.name;
    newmuzzik.MuzzikUser.isFollow = NO;
    newmuzzik.MuzzikUser.isFans = NO;
    newmuzzik.music = [music new];
    newmuzzik.music.music_id = mobject.music.music_id;
    newmuzzik.music.artist = mobject.music.artist;
    newmuzzik.music.key = mobject.music.key;
    newmuzzik.music.name = mobject.music.name;
    
    user.poMuzzik = newmuzzik;
}

@end
