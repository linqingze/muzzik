//
//  muzzik.m
//  muzzik
//
//  Created by muzzik on 15/4/11.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "muzzik.h"

@implementation muzzik
-(NSMutableArray*)makeMuzziksByarray:(NSMutableArray *)array{
    NSMutableArray *muzziks = [NSMutableArray array];
    for (NSDictionary *dic in array) {
        muzzik *newmuzzik = [muzzik new];
        newmuzzik.muzzik_id = [dic objectForKey:@"_id"];
        newmuzzik.date = [dic objectForKey:@"date"];
        newmuzzik.message = [dic objectForKey:@"message"];
        newmuzzik.image = [dic objectForKey:@"image"];
        newmuzzik.tpoics = [dic objectForKey:@"tpoics"];
        newmuzzik.users = [dic objectForKey:@"users"];
        newmuzzik.type = [dic objectForKey:@"type"];
        newmuzzik.onlytext = [[dic objectForKey:@"onlytext"] boolValue];
        newmuzzik.reposts = [dic objectForKey:@"reposts"];
        newmuzzik.shares = [dic objectForKey:@"shares"];
        newmuzzik.comments = [dic objectForKey:@"comments"];
        newmuzzik.color = [dic objectForKey:@"color"];
        newmuzzik.moveds = [dic objectForKey:@"moveds"];
        newmuzzik.isprivate = [[dic objectForKey:@"private"] boolValue];
        newmuzzik.plays = [dic objectForKey:@"plays"];
        newmuzzik.user = [user new];
        newmuzzik.user.avatar = [[dic objectForKey:@"user"] objectForKey:@"avatar"];
        newmuzzik.user.user_id = [[dic objectForKey:@"user"] objectForKey:@"_id"];
        newmuzzik.user.gender = [[dic objectForKey:@"user"] objectForKey:@"gender"];
        newmuzzik.user.name = [[dic objectForKey:@"user"] objectForKey:@"name"];
        newmuzzik.music = [music new];
        newmuzzik.music.music_id = [[dic objectForKey:@"music"] objectForKey:@"_id"];
         newmuzzik.music.artist = [[dic objectForKey:@"music"] objectForKey:@"artist"];
        newmuzzik.music.key = [[dic objectForKey:@"music"] objectForKey:@"key"];
        newmuzzik.music.block = [[[dic objectForKey:@"music"] objectForKey:@"block"] boolValue];
        newmuzzik.music.name = [[dic objectForKey:@"music"] objectForKey:@"name"];
//        if ([dic allKeys] containsObject:@"") {
//            <#statements#>
//        }
        [muzziks addObject:newmuzzik];
    }
    return muzziks;
}
@end
