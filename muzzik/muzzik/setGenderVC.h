//
//  setGenderVC.h
//  muzzik
//
//  Created by muzzik on 15/4/16.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "BaseNagationViewController.h"
#import "ZHPickView.h"
@interface setGenderVC : BaseNagationViewController<UITextFieldDelegate,ZHPickViewDelegate>{
    UITextField *birthText;
    NSString *gender;
    ZHPickView *pickview;
    UIButton *maleButton;
    UIButton *femaleButton;
}

@end
