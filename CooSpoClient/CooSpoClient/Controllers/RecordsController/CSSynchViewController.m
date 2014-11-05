//
//  CSSynchViewController.m
//  CooSpoClient
//
//  Created by 马远征 on 14-10-11.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "CSSynchViewController.h"
#import "CSRSynchTableViewCell.h"
#import "CSBluetooth.h"

@interface CSSynchViewController() <UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *listArray;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSArray *utcArray;
@end

@implementation CSSynchViewController

- (NSDateFormatter*)dateFormatter
{
    if (_dateFormatter == nil)
    {
        _dateFormatter = [[NSDateFormatter alloc]init];
    }
    return _dateFormatter;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.title = @"每日统计";
    }
    return self;
}

- (void)loadSportsData
{
    WEAKSELF;STRONGSELF;
    [[CSCoreData shared]fetchAllGoals:YES result:^(NSArray *ret, NSError *error) {
        strongSelf.utcArray = ret;
        [[CSCoreData shared]fetchDailyRecord:YES result:^(NSArray *ret, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.listArray = ret;
                [strongSelf.tableView reloadData];
            });
        }];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.937 green:0.937 blue:0.937 alpha:1.0];
    [self loadSportsData];
    [[CSBluetooth shared]completeTransmission:^{
        WEAKSELF;
        [weakSelf loadSportsData];
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
    return 160;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    CSRSynchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (indexPath.row < self.listArray.count)
    {
        NSDictionary *dic = [self.listArray objectAtIndex:indexPath.row];
        
        CGFloat distanceValue = (CGFloat)[dic[@"distance"] integerValue]/100;
        NSString *distanceString = [NSString stringWithFormat:@"%.1f",distanceValue];
        [cell.synchView setDistance:distanceString];
        
        CGFloat caloriesValue = (CGFloat)[dic[@"calorie"] integerValue]/10;
        NSString *caloriesString = [NSString stringWithFormat:@"%.1f",caloriesValue];
        [cell.synchView setCalories:caloriesString];
        
        [cell.synchView setSteps:[dic[@"steps"] integerValue]];
        
        cell.textLabel.text =  dic[@"date"];
        
        NSString *dateString = [NSString stringWithFormat:@"%@ 23:59:59",dic[@"date"]];
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *date = [self.dateFormatter dateFromString:dateString];
        
        NSInteger goals = 100000;
        if (self.utcArray && self.utcArray.count > 0)
        {
            NSArray *array = [self.utcArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"utcTime <= %@",date]];
            if (array && array.count > 0)
            {
                goals = [((NSDictionary*)[array firstObject])[@"dailyGoals"]integerValue];
            }
        }
        
        if ([dic[@"steps"] integerValue] < goals)
        {
            [cell.synchView setFinishGoals:NO];
        }
        else
        {
            [cell.synchView setFinishGoals:YES];
        }
    }
    return cell;
}
@end
