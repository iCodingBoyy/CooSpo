//
//  CSSportsViewController.m
//  CooSpoClient
//
//  Created by 马远征 on 14-10-11.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "CSSportsViewController.h"
#import "CSRSportsTableViewCell.h"
#import "CSBluetooth.h"

@interface CSSportsViewController() <UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *listArray;

@end

@implementation CSSportsViewController
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.title = @"运动记录";
    }
    return self;
}

- (void)loadDailyDetailData
{
    [[CSCoreData shared]fetchDailyDetailRecord:YES result:^(NSArray *ret, NSError *error) {
        if (ret)
        {
            WEAKSELF;STRONGSELF;
            strongSelf.listArray = ret;
            [strongSelf.tableView reloadData];
        }
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1.0];
    [self loadDailyDetailData];
    [[CSBluetooth shared]completeTransmission:^{
        WEAKSELF;
        [weakSelf loadDailyDetailData];
    }];
}
#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 240;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    CSRSportsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (indexPath.row < self.listArray.count)
    {
        NSDictionary *dic = [self.listArray objectAtIndex:indexPath.row];
        if (dic)
        {
            [cell.scView setDateString:dic[@"date"]];
            [cell.graphView execUpdate:dic[@"value"]];
        }
    }
    return cell;
}

@end
