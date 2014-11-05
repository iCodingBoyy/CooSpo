//
//  CSSleepViewController.m
//  CooSpoClient
//
//  Created by 马远征 on 14-10-11.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "CSSleepViewController.h"
#import "CSRSleepTableViewCell.h"
#import "CSBluetooth.h"
#import "CooSpoDefine.h"

@interface CSSleepViewController()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *xPointsArray;
@property (nonatomic, strong) NSArray *listArray;
@property (nonatomic, strong) NSString *stTime;
@property (nonatomic, strong) NSString *spTime;
@end

@implementation CSSleepViewController
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.title = @"睡眠记录";
    }
    return self;
}

- (void)loadSleepData
{
    WEAKSELF;STRONGSELF;
    [[CSCoreData shared]fetchSwParams:YES result:^(NSDictionary *ret, NSError *error) {
        if (ret)
        {
            NSString *stTime = [NSString stringWithFormat:@"%@:%@:00",ret[@"stHour"],ret[@"stMininute"]];
            NSString *spTime = [NSString stringWithFormat:@"%@:%@:00",ret[@"spHour"],ret[@"spMininute"]];
            NSLog(@"---stTime[%@]---spTime[%@]-",stTime,spTime);
            NSInteger stHour = [ret[@"stHour"] integerValue];
            NSInteger spHour = [ret[@"spHour"]integerValue];
            spHour += [ret[@"spMininute"]integerValue] > 0 ? 1:0;
            NSMutableArray *array = [NSMutableArray array];
            if (stHour > spHour)
            {
                for (int i = stHour; i < 24; i++)
                {
                    NSString *hours = [NSString stringWithFormat:@"%d",i];
                    [array addObject:hours];
                }
                for (int j = 0; j <= spHour; j++)
                {
                    NSString *hours = [NSString stringWithFormat:@"%d",j];
                    [array addObject:hours];
                }
            }
            else
            {
                for (int i = stHour; i <= spHour; i++)
                {
                    NSString *hours = [NSString stringWithFormat:@"%d",i];
                    [array addObject:hours];
                }
            }
            [[CSCoreData shared]fetchDaliySleepData:YES stTime:stTime spTime:spTime result:^(NSArray *ret, NSError *error) {
                if (ret)
                {
                    NSLog(@"----array----%@",array);
                    strongSelf.xPointsArray = [NSArray arrayWithArray:array];
                    strongSelf.listArray = ret;
                    [strongSelf.tableView reloadData];
                }
            }];
        }
    }];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadSleepData];
    [[CSBluetooth shared]completeTransmission:^{
        WEAKSELF;
        [weakSelf loadSleepData];
    }];
}

- (NSString*)time:(NSInteger)time
{
    time = time >= 0 ? time:0;
    NSInteger minutes = time/60;
    NSInteger minute = minutes%60;
    NSInteger hour = (minutes - minute)/60;
    return [NSString stringWithFormat:@"%ld时%d分",(long)hour,minute];
}

- (NSString*)caclulateSleepTime:(NSDictionary*)dic
{
    if (dic == nil)
    {
        return @"深睡眠:0时0分 浅睡眠:0时0分 清醒:0时0分";
    }
    NSNumber *deeptime = dic[@"deepSleep"];
    NSNumber *lighttime = dic[@"lightSleep"];
    NSNumber *totaltime = dic[@"totalTime"];
//    NSLog(@"---deeptime[%@]--lighttime[%@]-totaltime[%@]",deeptime,lighttime,totaltime);
    NSString *deepString = [NSString stringWithFormat:@"深睡眠:%@",[self time:[deeptime integerValue]]];
    NSString *lightString = [NSString stringWithFormat:@"浅睡眠:%@",[self time:[lighttime integerValue]]];
    
    NSInteger aweekTime = abs([totaltime integerValue]) - abs([lighttime integerValue]) - abs([deeptime integerValue]);

    NSString *aweekString = [NSString stringWithFormat:@"清醒:%@",[self time:aweekTime]];
    return [NSString stringWithFormat:@"%@ %@ %@",deepString,lightString,aweekString];
}

#pragma mark- 
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 240;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    CSRSleepTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (indexPath.row < self.listArray.count)
    {
        NSDictionary *dic = [self.listArray objectAtIndex:indexPath.row];
        cell.textLabel.text = dic[@"date"];
        cell.detailTextLabel.text = [self caclulateSleepTime:dic];
        [cell setXPoints:self.xPointsArray.count-1];
        [cell.graphView setDateString:dic[@"date"]];
        [cell.graphView setXPointsArray:self.xPointsArray];
        [cell.graphView drawGraph:dic[@"records"]];
    }
    
    return cell;
}
@end
