//
//  MessageStepViewController.m
//  muzzik
//
//  Created by muzzik on 15/4/27.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "MessageStepViewController.h"
#import "emojiCollectionCell.h"
#import "FriendVC.h"
#import "TopicHotVC.h"
#import "ChooseMusicVC.h"
#import "choosImageVC.h"
#import "HPGrowingTextView.h"
@interface MessageStepViewController ()<UITextViewDelegate>{
    UILabel *charaterLabel;
    UIView *actionView;
    UIButton *atButton;
    UIButton *privateButton;
    UITextView *textview;
    UILabel *placeHolder;
    UILabel *songName;
    UILabel *artist;
    BOOL isPrivate;
    UITextField *_textfield;
    UIButton *AtButton;
}
@end

@implementation MessageStepViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNagationBar:@"编辑信息（1/3）" leftBtn:Constant_backImage rightBtn:2];
    UIButton *topicButton = [[UIButton alloc] initWithFrame:CGRectMake(13, 16, SCREEN_WIDTH/2, 20)];
    topicButton.layer.cornerRadius = 5;
    topicButton.clipsToBounds = YES;
    [topicButton setBackgroundImage:[MuzzikItem createImageWithColor:Color_Active_Button_1] forState:UIControlStateNormal];
    [topicButton setTitle:@"#点我添加一个萌萌哒话题#" forState:UIControlStateNormal];
    [topicButton addTarget:self action:@selector(getTopic) forControlEvents:UIControlEventTouchUpInside];
    [topicButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    topicButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    topicButton.titleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:topicButton];
    privateButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-120, 16, 90, 20)];
    [privateButton setImage:[UIImage imageNamed:Image_visibleImage] forState:UIControlStateNormal];
    [privateButton addTarget:self action:@selector(changePrivateAction) forControlEvents:UIControlEventTouchUpInside];
    charaterLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-25, 16, 20, 20)];
    charaterLabel.text = @"140";
    charaterLabel.textColor = Color_Additional_5;
    charaterLabel.font = [UIFont boldSystemFontOfSize:9];
    [self.view addSubview:charaterLabel];
    [self.view addSubview:privateButton];
    placeHolder = [[UILabel alloc] initWithFrame:CGRectMake(17, 65, 200, 20)];
    placeHolder.text = @"这一刻你想到了什么...";
    placeHolder.textColor = Color_Text_2;
    placeHolder.font = [UIFont boldSystemFontOfSize:15];
    textview = [[UITextView alloc] initWithFrame:CGRectMake(13, 60, SCREEN_WIDTH-26, SCREEN_WIDTH-60)];
    textview.delegate = self;
    textview.textColor = Color_Text_2;
    textview.font = [UIFont systemFontOfSize:15];
    textview.tintColor = Color_Active_Button_1;
    textview.returnKeyType = UIReturnKeyDone;
    
    [self.view addSubview:textview];
    [self.view addSubview:placeHolder];
    
    
    [MuzzikItem addLineOnView:self.view heightPoint:SCREEN_WIDTH toLeft:13 toRight:13 withColor:Color_line_1];
    UIButton *changSongButton = [[UIButton alloc] initWithFrame:CGRectMake(13,CGRectGetMaxY(textview.frame)+20, 40, 40)];
    [changSongButton setImage:[UIImage imageNamed:Image_add_Song] forState:UIControlStateNormal];
    [changSongButton addTarget:self action:@selector(changsongAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changSongButton];
    songName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(changSongButton.frame)+20, CGRectGetMidY(changSongButton.frame)-20, SCREEN_WIDTH-CGRectGetMaxX(changSongButton.frame)-33, 20)];
    songName.textColor = Color_Theme_5;
    songName.font = [UIFont boldSystemFontOfSize:17];
    [self.view addSubview:songName];
    
    artist = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(changSongButton.frame)+20, CGRectGetMidY(changSongButton.frame), SCREEN_WIDTH-CGRectGetMaxX(changSongButton.frame)-33, 20)];
    artist.textColor = Color_Theme_5;
    artist.font = [UIFont boldSystemFontOfSize:17];
    [self.view addSubview:artist];
    
    AtButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-100, 20, 44, 44)];
    [AtButton setImage:[UIImage imageNamed:Image_At_button] forState:UIControlStateNormal];
    [AtButton addTarget:self action:@selector(AtFriend) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *tapOnview = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tapOnview];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.view addSubview:AtButton];
    MuzzikObject *mobject = [MuzzikObject shareClass];
    mobject.isMessageVCOpen = YES;
    if (mobject.music) {
        songName.text = mobject.music.name;
        artist.text = mobject.music.artist;
    }
    if ([mobject.tempmessage length]>0) {
        [placeHolder setHidden:YES];
        textview.text = [textview.text stringByAppendingString:mobject.tempmessage];
        mobject.tempmessage = nil;
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [AtButton removeFromSuperview];
}
#pragma textView Delegate
-(void)textViewDidChange:(UITextView *)textView{
    if (textview.text.length == 0) {
        [placeHolder setHidden:NO];
    }else{
        [placeHolder setHidden:YES];
        if ([[textview.text substringFromIndex:textview.text.length-1] isEqualToString:@"\n"] ) {
            textview.text =[textview.text substringToIndex:textview.text.length-1];
            [textview resignFirstResponder];
        }
    }
    if (textview.text.length>140) {
        textview.text =[textview.text substringToIndex:140];
    }
    charaterLabel.text = [NSString stringWithFormat:@"%lu",140 - textview.text.length];
    
}
#pragma -mark action
-(void) changePrivateAction{
    if (!isPrivate) {
        [privateButton setImage:[UIImage imageNamed:Image_invisibleImage] forState:UIControlStateNormal];
        
    }else{
        [privateButton setImage:[UIImage imageNamed:Image_visibleImage] forState:UIControlStateNormal];
    }
    isPrivate = !isPrivate;
}

-(void)getTopic{
    TopicHotVC *topicvc = [[TopicHotVC alloc] init];
    [self.navigationController pushViewController:topicvc animated:YES];
}

-(void) changsongAction{
    ChooseMusicVC *choosevc = [[ChooseMusicVC alloc] init];
    [self.navigationController pushViewController:choosevc animated:YES];
}

-(void)AtFriend{
    FriendVC *friendvc = [[FriendVC alloc] init];
    [self.navigationController pushViewController:friendvc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)rightBtnAction:(UIButton *)sender{
    MuzzikObject *mobject = [MuzzikObject shareClass];
    mobject.message = textview.text;
    mobject.isPrivate = isPrivate;
    choosImageVC *chooseimgevc = [[choosImageVC alloc] init];
    [self.navigationController pushViewController:chooseimgevc animated:YES];
    
}
-(void)tapAction:(UITapGestureRecognizer *)tap{
    if (_isNewSelected) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"是否保存编辑信息至草稿箱" message:@"" delegate:self cancelButtonTitle:@"放弃" otherButtonTitles:nil];
        // optional - add more buttons:
        [alert addButtonWithTitle:@"确定"];
        [alert show];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        // do stuff
        
       
    }else{
    
    }
    MuzzikObject *mobject = [MuzzikObject shareClass];
    mobject.music = nil;
    mobject.isMessageVCOpen = NO;
    mobject.tempmessage = @"";

    [self.navigationController popToRootViewControllerAnimated:YES];
    
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
