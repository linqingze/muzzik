//
//  NetTypeHelper.h
//  muzzik
//
//  Created by muzzik on 15/4/19.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//
typedef enum{
    NotNet = 0,     //无网络连接
    WifiNet,           //wifi网络
    OtherNet,       //gprs/3g网络
}NetType;
#import <Foundation/Foundation.h>

@interface NetTypeHelper : NSObject
@property (nonatomic,assign) NetType nNetType;
+(NetTypeHelper *) shareClass;
@end
