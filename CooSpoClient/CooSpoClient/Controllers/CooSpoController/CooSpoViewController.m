//
//  CooSpoViewController.m
//  CooSpoClient
//
//  Created by 马远征 on 14-10-10.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "CooSpoViewController.h"
#import "UIViewController+CSSide.h"
#import "CSSynchStatusView.h"
#import "CSSynchResultView.h"
#import "CSFinishGoalsView.h"
#import "CSTotalSumView.h"
#import "CSBluetooth.h"
#import "CooSpoDefine.h"

@interface CooSpoViewController()
@property (weak, nonatomic) IBOutlet CSSynchStatusView *synchStatusView;
@property (weak, nonatomic) IBOutlet CSSynchResultView *synchResultView;
@property (weak, nonatomic) IBOutlet CSTotalSumView *totalSumView;
@property (weak, nonatomic) IBOutlet CSFinishGoalsView *finishGoalView;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@end

@implementation CooSpoViewController

- (NSDateFormatter*)dateFormatter
{
    if (_dateFormatter)
    {
        return _dateFormatter;
    }
    NSTimeZone *GTMzone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [_dateFormatter setTimeZone:GTMzone];
    return _dateFormatter;
}

- (void)receiveGoalUpdateNotify
{
    NSLog(@"__%s__",__func__);
    [self updateUI];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveGoalUpdateNotify) name:@"Event_Goal_Setting_notify" object:nil];
    [self.synchStatusView setLastSynchTime:@"尚未同步数据"];
    [self connectDevice];
    [self updateUI];
}

- (void)updateUI
{
    WEAKSELF;
    STRONGSELF;
    // 查询最后同步时间
    [[CSCoreData shared]fetchLastSynchRecord:NO result:^(NSDictionary *ret, NSError *error) {
        if (ret)
        {
            NSTimeInterval utcTime = [ret[@"utcTime"]doubleValue];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:utcTime];
            NSString *dateString = [strongSelf.dateFormatter stringFromDate:date];
            strongSelf.synchStatusView.lastSynchTime = [NSString stringWithFormat:NSLocalizedString(@"最后同步时间:%@", nil) ,dateString];
            strongSelf.synchStatusView.synchStatus =NSLocalizedString(@"蓝牙设备未连接", nil);
        }
    }];
    
    //  查询当日运动记录
    [[CSCoreData shared]fetchSynchRecord:NO byDate:[NSDate date] result:^(NSDictionary *ret, NSError *error) {
        if (ret)
        {
            [strongSelf.synchResultView setSteps:[ret[@"steps"] integerValue]];
            [strongSelf.synchResultView setDistance:[ret[@"distance"] integerValue]];
            [strongSelf.synchResultView setCalories:[ret[@"calorie"] integerValue]];
        }
    }];
    
    // 查询目标与完成情况
    [[CSCoreData shared]fetchTGoal:NO result:^(NSArray *ret, NSError *error) {
        
        NSUInteger steps = 100000;
        if (ret && ret.count > 0)
        {
            NSDictionary *dict = [ret lastObject];
            if (dict)
            {
                steps = [dict[@"dailyGoals"] integerValue];
            }
        }
        NSUInteger cSteps = strongSelf.synchResultView.steps;
        CGFloat fillRate = (CGFloat)cSteps/(CGFloat)steps;
        NSString *fillRateString = [NSString stringWithFormat:@"%.5f",fillRate];
        [strongSelf.finishGoalView setFillRate:fillRateString];
        [strongSelf.finishGoalView setGoalSteps:steps];
    }];
    
    // 查询历史总记录
    [[CSCoreData shared]fetchTotalRecords:NO result:^(NSDictionary *ret, NSError *error) {
        if (ret)
        {
            [strongSelf.totalSumView setTotalSteps:[ret[@"steps"]unsignedIntValue]];
            [strongSelf.totalSumView setTotalDistance:[ret[@"distance"]unsignedIntValue]];
            [strongSelf.totalSumView setTotalCalories:[ret[@"calorie"]unsignedIntValue]];
        }
    }];
}

- (void)connectDevice
{
    WEAKSELF;
    [[CSBluetooth shared]startScaning:^(BluetoothStatus status) {
        STRONGSELF;
        switch (status)
        {
            case BluetoothStatusNoOperate:
            {
                [strongSelf.synchStatusView setSynchStatus:NSLocalizedString(@"蓝牙设备未连接",nil)];
            }
                break;
            case BluetoothStatusSearching:
            {
                [strongSelf.synchStatusView setSynchStatus:NSLocalizedString(@"正在搜索蓝牙设备",nil)];
            }
                break;
            case BluetoothStatusFoundPeripheral:
            {
                [strongSelf.synchStatusView setSynchStatus:NSLocalizedString(@"发现蓝牙设备",nil)];
            }
                break;
            case BluetoothStatusConnectOk:
            {
                [strongSelf.synchStatusView setSynchStatus:NSLocalizedString(@"成功连接蓝牙设备",nil)];
            }
                break;
            case BluetoothStatusConnectFailed:
            {
                [strongSelf.synchStatusView setSynchStatus:NSLocalizedString(@"连接蓝牙设备失败",nil)];
            }
                break;
            case BluetoothStatusTransferring:
            {
                [strongSelf.synchStatusView setSynchStatus:NSLocalizedString(@"正在读取蓝牙数据",nil)];
            }
                break;
            case BluetoothStatusCompleteTransfer:
            {
                [strongSelf.synchStatusView setSynchStatus:NSLocalizedString(@"完成蓝牙数据读取",nil)];
            }
                break;
            case BluetoothStatusDisConnect:
            {
                [strongSelf.synchStatusView setSynchStatus:NSLocalizedString(@"蓝牙设备断开连接",nil)];
            }
                break;
            default:
                break;
        }
    }];
    
    [[CSBluetooth shared]completeTransmission:^{
        [weakSelf updateUI];
    }];
}

- (IBAction)clickToShowLeftMenu:(id)sender
{
    if (self.navigationController.sideController)
    {
        [self.navigationController.sideController showLeftViewController:YES];
    }
}

@end
