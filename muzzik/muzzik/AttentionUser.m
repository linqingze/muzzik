//
//  AttentionUser.m
//  muzzik
//
//  Created by muzzik on 15/5/5.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "AttentionUser.h"

@implementation AttentionUser
-(NSMutableArray*)makeAttentionUserByArray:(NSMutableArray *)array{
    NSMutableArray *users = [NSMutableArray array];
    for (NSDictionary *dic in array) {
        AttentionUser *user = [AttentionUser new];
        user.name = [dic objectForKey:@"name"];
        user.uid = [dic objectForKey:@"_id"];
        user.isFans = [[dic objectForKey:@"isFans"] boolValue];
        user.isFollow = [[dic objectForKey:@"isFollow"] boolValue];
        user.avatar = [dic objectForKey:@"avatar"];
        user.gender = [dic objectForKey:@"gender"];
        user.descrip = [dic objectForKey:@"description"];
        [users addObject:user];
    }
    return users;
}
@end
