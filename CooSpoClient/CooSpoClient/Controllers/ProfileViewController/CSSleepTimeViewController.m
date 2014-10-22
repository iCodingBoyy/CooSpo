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

@interface CSSleepTimeViewController()
@property (weak, nonatomic) IBOutlet UIDatePicker *startDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *endDatePicker;
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
    return _dateFormatter;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.startDatePicker setTimeZone:[NSTimeZone systemTimeZone]];
    [self.endDatePicker setTimeZone:[NSTimeZone systemTimeZone]];
}

#pragma mark -
#pragma mark UIControl

- (IBAction)clickToBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickToSaveSleepSetting:(id)sender
{
    NSDate *date = [self.startDatePicker date];
    self.dateFormatter.dateFormat = @"HH";
    NSString *startHour = [self.dateFormatter stringFromDate:date];
    self.dateFormatter.dateFormat = @"mm";
    NSString *startMininute = [self.dateFormatter stringFromDate:date];
    
    self.dateFormatter.dateFormat = @"HH";
    NSString *endHour = [self.dateFormatter stringFromDate:self.endDatePicker.date];
    self.dateFormatter.dateFormat = @"mm";
    NSString *endMininute = [self.dateFormatter stringFromDate:self.endDatePicker.date];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@([startHour intValue]) forKey:@"stHour"];
    [params setObject:@([startMininute intValue]) forKey:@"stMininute"];
    [params setObject:@([endHour intValue]) forKey:@"spHour"];
    [params setObject:@([endMininute intValue]) forKey:@"spMininute"];
    [params setObject:@(YES) forKey:@"needUpdate"];
    [[CSCoreData shared]insertOrUpdateSwParams:params];
    [[YZProgressHUD HUD]showWithSuccess:self.view.window labelText:@"保存成功" detailText:nil];
    [self.navigationController performSelector:@selector(popToRootViewControllerAnimated:) withObject:@(YES) afterDelay:1.5];
}
@end
