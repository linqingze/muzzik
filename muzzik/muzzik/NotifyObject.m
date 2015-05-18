//
//  NotifyObject.m
//  muzzik
//
//  Created by muzzik on 15/5/18.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "NotifyObject.h"

@implementation NotifyObject
-(NSMutableArray*)makeMuzziksByNotifyArray:(NSMutableArray *)array{
     NSMutableArray *notifies = [NSMutableArray array];
    for (NSDictionary *dic in array) {
        NotifyObject *notify = [NotifyObject new];
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
        newmuzzik.repostID = [dic objectForKey:@"repostID"];
        newmuzzik.title = [dic objectForKey:@"title"];
        newmuzzik.repostDate = [dic objectForKey:@"repostDate"];
        newmuzzik.reposter = [MuzzikUser new];
        newmuzzik.reposter.name = [[dic objectForKey:@"repostUser"] objectForKey:@"name"];
        newmuzzik.reposter.user_id = [[dic objectForKey:@"repostUser"] objectForKey:@"_id"];
        newmuzzik.reposter.avatar = [[dic objectForKey:@"repostUser"] objectForKey:@"avatar"];
        newmuzzik.reposter.gender = [[dic objectForKey:@"repostUser"] objectForKey:@"gender"];
        
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
        if ([[dic allKeys ] containsObject:@"reply"]) {
            newmuzzik.reply = [ReplyObject new];
            newmuzzik.reply.reply_id = [[dic objectForKey:@"reply"] objectForKey:@"_id"];
            newmuzzik.reply.message = [[dic objectForKey:@"reply"] objectForKey:@"message"];
            newmuzzik.reply.color = [[dic objectForKey:@"reply"] objectForKey:@"color"];
        }
        notify.muzzik = newmuzzik;
        MuzzikUser *newUser = [MuzzikUser new];
        
        newUser.descrip = [dic objectForKey:@"description"];
        newUser.user_id = [dic objectForKey:Parameter_Id];
        newUser.avatar = [dic objectForKey:Parameter_avatar];
        newUser.gender = [dic objectForKey:Parameter_Gender];
        newUser.name = [dic objectForKey:Parameter_name];
        if ([[dic allKeys] containsObject:@"isFollow"]) {
            newUser.isFollow = [[dic objectForKey:@"isFollow"] boolValue];
        }
        if ([[dic allKeys] containsObject:@"isFans"]) {
            newUser.isFans = [[dic objectForKey:@"isFans"] boolValue];
        }
        notify.user = newUser;
        notify.notify_id = [dic objectForKey:@"_id"];
        notify.type = [dic objectForKey:@"type"];
        notify.date = [dic objectForKey:@"date"];
        notify.owner = [dic objectForKey:@"owner"];
        notify.readed = [[dic objectForKey:@"readed"] boolValue];
        notify.saw = [[dic objectForKey: @"saw"] boolValue];
        [notifies addObject:notify];
    }
    return notifies;
}
@end
