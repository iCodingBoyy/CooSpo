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


#pragma mark -
#pragma mark Notify

- (void)receiveGoalUpdateNotify
{
    DEBUG_METHOD(@"__%s__",__func__);
    [self updateUI];
}

- (void)receiveUtcTimeNotify
{
    [self updateLastSynchTime];
}

- (void)registerNotify
{
    NSNotificationCenter *noteCenter = [NSNotificationCenter defaultCenter];
    [noteCenter removeObserver:self];
    [noteCenter addObserver:self selector:@selector(receiveGoalUpdateNotify)
                       name:@"Event_Goal_Setting_notify" object:nil];
    
    [noteCenter addObserver:self selector:@selector(receiveUtcTimeNotify)
                       name:@"Event_LastSynch_Time_Update_Notify" object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerNotify];
    [self.synchStatusView setLastSynchTime:@"尚未同步数据"];
    [self connectDevice];
    [self updateLastSynchTime];
    [self updateUI];
}


- (void)updateLastSynchTime
{
    // 读取最后同步时间
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *number = [userDefaults objectForKey:@"lastSynch.utcTime"];
    if (number)
    {
        NSTimeInterval utcTime = [number doubleValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:utcTime];
        NSString *dateString = [self.dateFormatter stringFromDate:date];
        self.synchStatusView.lastSynchTime = [NSString stringWithFormat:NSLocalizedString(@"最后同步时间:%@", nil) ,dateString];
        self.synchStatusView.synchStatus = NSLocalizedString(@"蓝牙设备未连接", nil);
    }
}

- (void)updateUI
{
    WEAKSELF; STRONGSELF;
    //  查询当日运动记录
    [[CSCoreData shared]fetchDailySumOfSportsData:YES byDate:[NSDate date]
                                           result:^(NSDictionary *ret, NSError *error) {
       if (ret)
       {
           dispatch_async(dispatch_get_main_queue(), ^{
           [strongSelf.synchResultView setSteps:[ret[@"sum.steps"]unsignedIntValue]];
           [strongSelf.synchResultView setDistance:[ret[@"sum.distance"]unsignedIntValue]];
           [strongSelf.synchResultView setCalories:[ret[@"sum.calorie"]unsignedIntValue]];
               
               [[CSCoreData shared]fetchLateLyGoal:YES result:^(NSDictionary *ret, NSError *error) {
                   NSInteger goal = 100000;
                   if (ret && ret[@"dailyGoals"])
                   {
                       goal = [ret[@"dailyGoals"] integerValue];
                   }
                   CGFloat fillRate = (CGFloat)strongSelf.synchResultView.steps*100/goal;
                   NSString *fillRateString = [NSString stringWithFormat:@"%.3f",fillRate];
                   
                   dispatch_async(dispatch_get_main_queue(), ^{
                       [strongSelf.finishGoalView setGoalSteps:goal];
                       [strongSelf.finishGoalView setFillRate:fillRateString];
                   });
                   
               }];
           });
       }//if
    }];
    
    // 查询历史总记录
    [[CSCoreData shared]fetchSumOfSportsData:YES result:^(NSDictionary *ret, NSError *error) {
        if (ret)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf.totalSumView setTotalSteps:[ret[@"sum.steps"]unsignedIntValue]];
            [strongSelf.totalSumView setTotalDistance:[ret[@"sum.distance"]unsignedIntValue]];
            [strongSelf.totalSumView setTotalCalories:[ret[@"sum.calorie"]unsignedIntValue]];
            });
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
