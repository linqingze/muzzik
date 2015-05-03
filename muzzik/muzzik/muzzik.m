//
//  muzzik.m
//  muzzik
//
//  Created by muzzik on 15/4/11.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "muzzik.h"

@implementation muzzik
-(NSMutableArray*)makeMuzziksByMuzzikArray:(NSMutableArray *)array{
    NSMutableArray *muzziks = [NSMutableArray array];
    for (NSDictionary *dic in array) {
        muzzik *newmuzzik = [muzzik new];
        newmuzzik.muzzik_id = [dic objectForKey:@"_id"];
        newmuzzik.ismoved = [[dic objectForKey:@"ismoved"] boolValue];
        newmuzzik.date = [dic objectForKey:@"date"];
        newmuzzik.message = [dic objectForKey:@"message"];
        newmuzzik.image = [dic objectForKey:@"image"];
        newmuzzik.topics = [dic objectForKey:@"topics"];
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
        newmuzzik.reposter = [MuzzikUser new];
        newmuzzik.reposter.name = [[dic objectForKey:@"repostUser"] objectForKey:@"name"];
        newmuzzik.reposter.user_id = [[dic objectForKey:@"repostUser"] objectForKey:@"_id"];
        newmuzzik.reposter.avatar = [[dic objectForKey:@"repostUser"] objectForKey:@"avatar"];
        newmuzzik.reposter.gender = [[dic objectForKey:@"repostUser"] objectForKey:@"gender"];
        newmuzzik.reposter.repost_id = [[dic objectForKey:@"repostUser"] objectForKey:@"repostID"];
        newmuzzik.MuzzikUser = [MuzzikUser new];
        newmuzzik.MuzzikUser.avatar = [[dic objectForKey:@"user"] objectForKey:@"avatar"];
        newmuzzik.MuzzikUser.user_id = [[dic objectForKey:@"user"] objectForKey:@"_id"];
        newmuzzik.MuzzikUser.gender = [[dic objectForKey:@"user"] objectForKey:@"gender"];
        newmuzzik.MuzzikUser.name = [[dic objectForKey:@"user"] objectForKey:@"name"];
        newmuzzik.music = [music new];
        newmuzzik.music.music_id = [[dic objectForKey:@"music"] objectForKey:@"_id"];
         newmuzzik.music.artist = [[dic objectForKey:@"music"] objectForKey:@"artist"];
        //NSLog(@"%@",[[dic objectForKey:@"music"] objectForKey:@"artist"]);
        newmuzzik.music.key = [[dic objectForKey:@"music"] objectForKey:@"key"];
       // newmuzzik.music.block = [[[dic objectForKey:@"music"] objectForKey:@"block"] boolValue];
        newmuzzik.music.name = [[dic objectForKey:@"music"] objectForKey:@"name"];
//        if ([dic allKeys] containsObject:@"") {
//            <#statements#>
//        }
        [muzziks addObject:newmuzzik];
    }
    return muzziks;
}

-(NSMutableArray*)makeMuzziksByMusicArray:(NSMutableArray *)array{
    NSMutableArray *muzziks = [NSMutableArray array];
    for (NSDictionary *dic in array) {
        muzzik *newmuzzik = [muzzik new];
        newmuzzik.music = [music new];
        newmuzzik.music.music_id = [dic objectForKey:@"_id"];
        newmuzzik.music.artist = [dic objectForKey:@"artist"];
        newmuzzik.music.key = [dic objectForKey:@"key"];
        newmuzzik.music.name = [dic objectForKey:@"name"];
        [muzziks addObject:newmuzzik];
    }
    return muzziks;
}
@end
