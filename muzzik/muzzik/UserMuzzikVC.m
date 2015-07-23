//
//  UserMuzzikVC.m
//  muzzik
//
//  Created by muzzik on 15/5/7.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "UserMuzzikVC.h"
#import "MuzzikTableVC.h"
#import "CommentTableVC.h"
@interface UserMuzzikVC()<SUNSlideSwitchViewDelegate>{
    SUNSlideSwitchView *sliderView;
}

@end

@implementation UserMuzzikVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self initNagationBar:@"我的Muzzik" leftBtn:Constant_backImage rightBtn:0];
    sliderView = [[SUNSlideSwitchView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    sliderView.tabItemNormalColor = Color_Text_1;
    sliderView.tabItemSelectedColor = Color_Active_Button_1;
    sliderView.shadowImage = [[UIImage imageNamed:@"red_line_and_shadow.png"]
                              stretchableImageWithLeftCapWidth:59.0f topCapHeight:0.0f];
    [self.view addSubview:sliderView];
    sliderView.slideSwitchViewDelegate = self;
    [sliderView buildUI];
    // Do any additional setup after loading the view.
}

#pragma mark - datasource delegate
- (NSUInteger)numberOfTab:(SUNSlideSwitchView *)view
{
    return 2;
}


- (UIViewController *)slideSwitchView:(SUNSlideSwitchView *)view viewOfTab:(NSUInteger)number
{
    if (number == 0) {
        MuzzikTableVC *muzzikTable = [[MuzzikTableVC alloc] init];
        muzzikTable.keeper = self;
        muzzikTable.title =@"信息";
        return muzzikTable;
    }
    else{
        CommentTableVC *commentvc = [[CommentTableVC alloc] init];
        commentvc.keeper = self;
        commentvc.title = @"评论";
        return commentvc;
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
