//
//  topicProductCell.h
//  ShopUU
//
//  Created by 林清泽 on 15/1/8.
//  Copyright (c) 2015年 IOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CXAHyperlinkLabel.h"
#import "muzzikTrendController.h"
@interface RepostCell : UITableViewCell
@property (nonatomic) BOOL isPlaying;
@property (nonatomic) UILabel *repostUserName;                 //转发用户名
@property (nonatomic) UIImageView *repostImage;                //muzzik类型图标
@property (nonatomic) UIImageView *userImage;                  //用户头像
@property (nonatomic) UILabel *userName;                       //用户名
@property (nonatomic) UILabel *timeStamp;                      //时间
@property (nonatomic) UIProgressView *progress;
@property (nonatomic) UIView *musicPlayView;                   //播放器图层
@property (nonatomic) UIButton *playButton;
@property (nonatomic) UIButton *likeButton;
@property (nonatomic) CXAHyperlinkLabel *muzzikMessage;        //muzzik文字
@property (nonatomic) UILabel *musicName;                      //音乐名称
@property (nonatomic) UILabel *musicArtist;                    //音乐家
@property (nonatomic) UIImageView *timeImage;                  //时间图标
@property (nonatomic) UILabel *muzzikRepostText;               //转发文字
@property (nonatomic) UIView *socialView;                      //社交图层
@property (nonatomic) UIImageView *upperLine;
@property (nonatomic) UIImageView *downLine;
@property (nonatomic) UIButton *moves;
@property (nonatomic) UIButton *reposts;
@property (nonatomic) UIButton *shares;
@property (nonatomic) UIButton *comments;
@property (nonatomic) UIButton *repostButton;
@property (nonatomic) UIButton *shareButton;
@property (nonatomic) UIButton *commentButton;
@property (nonatomic) NSString *colorName;
@property (nonatomic,weak) muzzikTrendController *homeVc;
@property (nonatomic) muzzik *songModel;
@property (nonatomic) NSString *muzzik_id;
@property (nonatomic) BOOL isMoved;
@property (nonatomic) NSInteger index;
@property (nonatomic) BOOL hasLoad;
@property (nonatomic) BOOL isReposted;
-(void) colorViewWithColorString:(NSString *) colorString;
@end
