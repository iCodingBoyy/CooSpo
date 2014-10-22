//
//  CSProfileViewController.m
//  CooSpoClient
//
//  Created by 马远征 on 14-10-11.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "CSProfileViewController.h"
#import "UIViewController+CSSide.h"
#import "CSProfileTableViewCell.h"
#import "CSSleepTimeViewController.h"
#import "CSBluetooth.h"
#import "CooSpoDefine.h"
#import "YZProgressHUD.h"
#import "CSActionSheet.h"

@interface CSProfileViewController() <UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>
@property (nonatomic, assign) NSInteger sex;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) NSInteger weight;
@property (nonatomic, assign) NSInteger stride;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, strong) NSDictionary *userInfoDic;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation CSProfileViewController

#pragma mark -
#pragma mark UIControl

- (IBAction)clickToSaveProfileSetting:(id)sender
{
    if (_sex > -1 && _age > 0 && _height > 0 && _weight > 0 && _stride > 0)
    {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:@(_sex) forKey:@"sex"];
        [params setObject:@(_age) forKey:@"age"];
        [params setObject:@(_height) forKey:@"height"];
        [params setObject:@(_weight) forKey:@"weight"];
        [params setObject:@(_stride) forKey:@"stride"];
        
        [[CSCoreData shared]insertOrUpdateUserInfo:params];
        [[YZProgressHUD HUD]showWithSuccess:self.view.window labelText:@"保存完成" detailText:nil];
    }
    else
    {
        [[YZProgressHUD HUD]showWithError:self.view.window labelText:@"保存失败，请重新设置" detailText:nil];
    }
}

- (IBAction)clickToShowLeftMenu:(id)sender
{
    if (self.navigationController.sideController)
    {
        [self.navigationController.sideController showLeftViewController:YES];
    }
}

#pragma mark -
#pragma mark loadView

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.937 green:0.937 blue:0.937 alpha:1.0];
    _sex = -1;
    [self updateUI];
    
    WEAKSELF;
    [[CSBluetooth shared]completeTransmission:^{
        [weakSelf updateUI];
    }];
    
}

- (void)updateUI
{
    WEAKSELF;STRONGSELF;
    [[CSCoreData shared]fetchUserInfo:NO result:^(NSDictionary *ret, NSError *error) {
        NSLog(@"-[%s]--ret---%@",__FUNCTION__,ret);
        if (!error)
        {
            strongSelf.userInfoDic = ret;
            _sex = [ret[@"sex"]integerValue];
            _age = [ret[@"age"]integerValue];
            _height = [ret[@"height"]integerValue];
            _weight = [ret[@"weight"]integerValue];
            _stride = [ret[@"stride"]integerValue];
            [strongSelf.tableView reloadData];
        }
    }];
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    CSProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (indexPath.section == 0)
    {
        cell.textLabel.text = @"性别：";
        if (self.userInfoDic)
        {
            NSInteger sex = [_userInfoDic[@"sex"]integerValue];
            cell.resultLabel.text = sex == 0 ? @"女":@"男";
        }
        
    }
    else if (indexPath.section == 1)
    {
        cell.textLabel.text = @"年龄：";
        if (self.userInfoDic)
        {
            NSInteger age = [self.userInfoDic[@"age"]integerValue];
            cell.resultLabel.text = [NSString stringWithFormat:@"%ld 岁",(long)age];
        }
        
    }
    else if (indexPath.section == 2)
    {
        cell.textLabel.text = @"身高：";
        if (self.userInfoDic)
        {
            NSInteger height = [self.userInfoDic[@"height"]integerValue];
            cell.resultLabel.text = [NSString stringWithFormat:@"%ld cm",(long)height];
        }
    }
    else if (indexPath.section == 3)
    {
        cell.textLabel.text = @"体重：";
        if (self.userInfoDic)
        {
            NSInteger weight = [self.userInfoDic[@"weight"]integerValue];
            cell.resultLabel.text = [NSString stringWithFormat:@"%d kg",weight/10];
        }
    }
    else
    {
        cell.textLabel.text = @"睡眠设定";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 4)
    {
        CSSleepTimeViewController *sleepTimeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CSSleepTimeViewController"];
        [self.navigationController pushViewController:sleepTimeVC animated:YES];
    }
    else if (indexPath.section == 0)
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"性别" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"男" otherButtonTitles:@"女", nil];
        [actionSheet showInView:self.view.window];
        
    }
    else if (indexPath.section == 1)
    {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComponent = [calendar components:NSYearCalendarUnit fromDate:[NSDate date]];
        NSInteger year = [dateComponent year];
        
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 1920; i <= year; i+=1)
        {
            NSString *age = [NSString stringWithFormat:@"%d",i];
            [array addObject:age];
        }
        WEAKSELF; STRONGSELF;
        CSActionSheet *actionSheet = [[CSActionSheet alloc]initWithTitle:@"请选择出身日期" Unit:@"年" Parmas:array];
        [actionSheet show:^(NSInteger result) {
            strongSelf->_age = year - result;
            CSProfileTableViewCell *cell = (CSProfileTableViewCell*)[strongSelf.tableView cellForRowAtIndexPath:indexPath];
            cell.resultLabel.text = [NSString stringWithFormat:@"%ld 岁",(long)strongSelf->_age];
        }];
    }
    else if (indexPath.section == 2)
    {
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 30; i < 260; i++)
        {
            NSString *height = [NSString stringWithFormat:@"%d",i];
            [array addObject:height];
        }
        WEAKSELF; STRONGSELF;
        CSActionSheet *actionSheet = [[CSActionSheet alloc]initWithTitle:@"请选择身高" Unit:@"cm" Parmas:array];
        [actionSheet show:^(NSInteger result) {
            strongSelf->_height = result;
            strongSelf->_stride = result*0.22;
            CSProfileTableViewCell *cell = (CSProfileTableViewCell*)[strongSelf.tableView cellForRowAtIndexPath:indexPath];
            cell.resultLabel.text = [NSString stringWithFormat:@"%ld cm",(long)strongSelf->_height];
        }];
    }
    else
    {
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 15; i < 300; i++)
        {
            NSString *height = [NSString stringWithFormat:@"%d",i];
            [array addObject:height];
        }
        WEAKSELF; STRONGSELF;
        CSActionSheet *actionSheet = [[CSActionSheet alloc]initWithTitle:@"请选择体重" Unit:@"kg" Parmas:array];
        [actionSheet show:^(NSInteger result) {
            strongSelf->_weight = result*10;
            CSProfileTableViewCell *cell = (CSProfileTableViewCell*)[strongSelf.tableView cellForRowAtIndexPath:indexPath];
            cell.resultLabel.text = [NSString stringWithFormat:@"%ld kg",(long)result];
        }];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 2)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        CSProfileTableViewCell *cell = (CSProfileTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.resultLabel.text = (buttonIndex == 0 ? @"男":@"女");
        _sex = (buttonIndex == 0 ? 1:0);
    }
}
@end
