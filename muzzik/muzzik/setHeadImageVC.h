//
//  setHeadImageVC.h
//  muzzik
//
//  Created by muzzik on 15/4/15.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "BaseNagationViewController.h"

@interface setHeadImageVC : BaseNagationViewController<UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate>{
    UIView *headerView;
    UIImageView *headImage;
    UILabel * notifyLabel;
    UIImage *userImage;
}

@end
