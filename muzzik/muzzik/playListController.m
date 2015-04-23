//
//  playListController.m
//  muzzik
//
//  Created by kevin's mac on 15/3/16.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "playListController.h"
#import "FMDatabase.h"

#import "appConfiguration.h"
@interface playListController ()
@property (nonatomic) NSMutableArray *localList;
@end

@implementation playListController
-(NSMutableArray *)localList{
    if (!_localList) {
        _localList = [[NSMutableArray alloc] init];
    }
    return _localList;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *dbPath = [DocumentsPath stringByAppendingPathComponent:@"myDataBase"];
    NSLog(@"%@",[fileMgr contentsOfDirectoryAtPath: DocumentsPath error:nil]);
    
    if (![fileMgr fileExistsAtPath:dbPath]) {
        NSString *srcPath = [[NSBundle mainBundle] pathForResource:@"myDataBase" ofType:@"db"];
        [fileMgr copyItemAtPath:srcPath toPath:dbPath error:NULL];
    }
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath] ;
    if (![db open]) {
        NSLog(@"Could not open db.");
        return ;
    }
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM SongList"];
    
    
    
    // 遍历结果集
    
    while ([rs next]) {
//        FMMySongModel *model = [[FMMySongModel alloc] init];
//        model.songName = [rs stringForColumn:@"SongName"];
//        model.song_key = [rs stringForColumn:@"SongKey"];
//        model.filepath = [rs stringForColumn:@"filepath"];
//        model.songArtist = [rs stringForColumn:@"Artist"];
//        model.song_id = [rs stringForColumn:@"music_id"];
//        NSLog(@"song:%@,filepath:%@",[rs stringForColumn:@"SongName"],[rs stringForColumn:@"filepath"]);
//        [self.localList addObject:model];
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.localList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"11"];
   // FMMySongModel *model = [_localList objectAtIndex:indexPath.row];
  //  cell.textLabel.text = [NSString stringWithFormat:@"%@        --%@",model.songName,model.songArtist];
    // Configure the cell...
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
