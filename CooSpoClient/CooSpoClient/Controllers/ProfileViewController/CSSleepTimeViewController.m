//
//  CSSleepTimeViewController.m
//  CooSpoClient
//
//  Created by 马远征 on 14-10-15.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "CSSleepTimeViewController.h"
#import "CSCoreData.h"
#import "YZProgressHUD.h"
#import "CooSpoDefine.h"

@interface CSSleepTimeViewController()
@property (weak, nonatomic) IBOutlet UIDatePicker *stDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *spDatePicker;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation CSSleepTimeViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.title = @"睡眠设定";
    }
    return self;
}

- (NSDateFormatter*)dateFormatter
{
    if (_dateFormatter)
    {
        return _dateFormatter;
    }
    _dateFormatter = [[NSDateFormatter alloc]init];
    [_dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [_dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    return _dateFormatter;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.stDatePicker setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [self.spDatePicker setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    WEAKSELF; STRONGSELF;
    [[CSCoreData shared]fetchSwParams:YES result:^(NSDictionary *ret, NSError *error) {
        if (ret)
        {
            self.dateFormatter.dateFormat = @"HH:mm:ss";
            NSString *stTime = [NSString stringWithFormat:@"%@:%@:00",ret[@"stHour"],ret[@"stMininute"]];
            NSDate *stDate = [self.dateFormatter dateFromString:stTime];
            
            
            NSString *spTime = [NSString stringWithFormat:@"%@:%@:00",ret[@"spHour"],ret[@"spMininute"]];
            NSDate *spDate = [self.dateFormatter dateFromString:spTime];
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.stDatePicker setDate:stDate animated:YES];
                [strongSelf.spDatePicker setDate:spDate animated:YES];
            });
            
        }
    }];
}

#pragma mark -
#pragma mark UIControl

- (IBAction)clickToBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickToSaveSleepSetting:(id)sender
{
    self.dateFormatter.dateFormat = @"HH";
    NSString *startHour = [self.dateFormatter stringFromDate:self.stDatePicker.date];
    self.dateFormatter.dateFormat = @"mm";
    NSString *startMininute = [self.dateFormatter stringFromDate:self.stDatePicker.date];
    
    self.dateFormatter.dateFormat = @"HH";
    NSString *endHour = [self.dateFormatter stringFromDate:self.spDatePicker.date];
    self.dateFormatter.dateFormat = @"mm";
    NSString *endMininute = [self.dateFormatter stringFromDate:self.spDatePicker.date];
//    NSLog(@"--[%@:%@]--[%@:%@]",startHour,startMininute,endHour,endMininute);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@([startHour intValue]) forKey:@"stHour"];
    [params setObject:@([startMininute intValue]) forKey:@"stMininute"];
    [params setObject:@([endHour intValue]) forKey:@"spHour"];
    [params setObject:@([endMininute intValue]) forKey:@"spMininute"];
    [params setObject:@(YES) forKey:@"needUpdate"];
    [[CSCoreData shared]insertOrUpdateSwParams:params];
    [[YZProgressHUD HUD]showWithSuccess:self.view.window labelText:@"保存成功" detailText:nil];
//    [self.navigationController performSelector:@selector(popToRootViewControllerAnimated:) withObject:@(YES) afterDelay:1.5];
}
@end
