//
//  NetTypeHelper.m
//  muzzik
//
//  Created by muzzik on 15/4/19.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "NetTypeHelper.h"

@implementation NetTypeHelper
+(NetTypeHelper *) shareClass{
    static NetTypeHelper *myclass=nil;
    if(!myclass){
        myclass = [[super allocWithZone:NULL] init];
    }
    return myclass;
}

+(id)allocWithZone:(NSZone *)zone{
    return [self shareClass];
}
@end
