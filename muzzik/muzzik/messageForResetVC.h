//
//  messageForResetVC.h
//  muzzik
//
//  Created by muzzik on 15/4/16.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "BaseNagationViewController.h"

@interface messageForResetVC : BaseNagationViewController<UITextFieldDelegate>{
    UITextField *checkcode;
    UITextField *passwordText;
    BOOL isOk;
    UIButton *visibleButton;
}
@property (nonatomic) NSString *phoneNumber;

@end
