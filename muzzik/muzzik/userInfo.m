//
//  userInfo.m
//  ShopUpUp
//
//  Created by kevin's mac on 14-8-1.
//  Copyright (c) 2014年 IOS. All rights reserved.
//
#import "LoginViewController.h"
#import "userInfo.h"

@implementation userInfo
+(userInfo *) shareClass{
    static userInfo *myclass=nil;
    if(!myclass){
        myclass = [[super allocWithZone:NULL] init];
    }
    return myclass;
}

+(id)allocWithZone:(NSZone *)zone{
    return [self shareClass];
}
+(void)checkLoginWithVC:(UIViewController *)vc{
    LoginViewController *login = [[LoginViewController alloc] init];
    [vc.navigationController pushViewController:login animated:YES];
}

-(id)init{
    self = [super init];
    if(self){
        
        
        
     //   _token = [[NSString alloc]init];
     //   _customer_id = [[NSString alloc]init];
    }
    return self;
}

@end
